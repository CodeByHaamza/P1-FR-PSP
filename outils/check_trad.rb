#!/usr/bin/env ruby
# frozen_string_literal: true

# Validateur des fichiers de traduction JSON.
#
#   depuis le dépôt public  : ruby outils/check_trad.rb trad/dialogues/E0_004.json
#   depuis le dépôt privé   : ruby game/tools/check_trad.rb game/scripts/dialogues/E0_004.json
#
# Ne modifie rien, ne touche à aucun fichier de jeu : il lit du JSON et
# signale. Six contrôles, du plus grave au moins grave :
#
#   1. STRUCTURE — les codes de contrôle du français doivent être identiques
#      à ceux de l'anglais, en nombre et en ordre. Un code perdu, et le moteur
#      lit la suite de travers.
#   2. ENCODAGE  — chaque caractère doit exister dans la table du jeu, ET son
#      glyphe doit être réellement dessiné dans la police. Les deux, parce que
#      ce n'est pas la même chose : les accents français ont tous un code dans
#      la table, mais leur case est vide ou ne contient qu'une marque isolée
#      dans `pack/sys.bin`. Encodable ≠ affichable — c'est précisément le genre
#      de fausse assurance qui a laissé passer la troncature pendant des mois.
#   3. CANARI    — la colonne anglaise doit être identique à l'extraction.
#      Un contributeur qui écrase une lettre de l'anglais en tapant sa
#      traduction fabrique une divergence que plus rien ne rattrape : le
#      moteur cherche la ligne d'origine et ne la retrouve pas.
#   4. LARGEUR   — chaque ligne affichée doit tenir dans la boîte, jugée PAR
#      RAPPORT à la ligne anglaise correspondante. Le script original compte
#      42 lignes au-delà de 43 caractères : refuser dans l'absolu reviendrait à
#      signaler un traducteur pour une largeur qu'il n'a pas créée. Erreur donc
#      seulement si le français est à la fois plus large que l'anglais ET
#      au-delà de 43 ; avertissement entre 40 et 43.
#
# Puis trois AVERTISSEMENTS, qui ne font jamais échouer :
#
#   5. OCTETS    — ce que la traduction ajoute au fichier de données, multiplié
#      par ses occurrences. Un bloc qui franchit sa frontière de 2 048 octets
#      renvoie tout le fichier en anglais, sans erreur.
#   6. TERMINO   — un terme validé au dictionnaire qui apparaît dans l'anglais
#      devrait se retrouver dans le français. Ce n'est pas une faute : le
#      français fléchit, et reformuler est souvent le bon choix. Mais sur
#      8 572 textes et des dizaines de traducteurs, c'est le seul défaut
#      qu'aucun relecteur humain ne verra.
#   7. BUDGET    — une entrée EBOOT plus longue que son `max`.
#
# Et une ERREUR propre aux donjons :
#
#   8. DONJON    — un texte de donjon plus long que l'anglais.
#   9. ESPACE    — `[0000]` dans le français quand l'anglais a de vrais espaces :
#      là, ce code termine la chaîne et le jeu n'affiche que le premier mot.
#  10. PLACE     — les fichiers d'un même démon (négociations) font ensemble
#      grossir le fichier de jeu, ce qui fige le jeu ; avertissement quand un
#      fichier ne tient que grâce aux économies des autres. La taille de ces
#      fichiers est inscrite dans l'exécutable ; en grossissant, ils laissent
#      le jeu sur un écran de chargement sans fin. Vu en jeu. Le moteur la
#      redirige vers un code cave : ça marche, c'est prouvé en jeu, mais c'est
#      plus fragile que de tenir dans la place d'origine. Les dialogues n'ont
#      pas de `max`, ce contrôle ne s'y déclenche donc jamais.
#  11. EFFACEMENT — avec `--base <ref>`, une traduction présente dans la version
#      de référence et vide dans celle-ci. Ce n'est jamais voulu : c'est une
#      proposition partie d'une copie périmée du fichier (fork pas synchronisé),
#      et la fusionner efface le travail des autres. Vu le 20/09/2026 : onze
#      répliques d'E0_043 effacées par une proposition qui en ajoutait une.
#
# Aucune dépendance au moteur p1es : la table de caractères est lue directement
# depuis le .tbl. C'est ce qui permet de publier ce fichier tel quel dans le
# dépôt communautaire, où le moteur, lui, n'a pas sa place.

require 'json'
require 'set'
require 'digest'

AQUI = File.dirname(File.expand_path(__FILE__)) unless defined?(AQUI)

module CheckTrad
  LARGEUR_MAX = 40   # visé ; le script anglais monte à 43 en chasse étroite
  LARGEUR_DURE = 43  # au-delà, débordement certain
  SEUIL_OCTETS = 48  # au-delà, une entrée pèse assez pour faire déborder un bloc

  # Repère un code de contrôle sous ses trois formes : nom lisible {SAUT},
  # balise du moteur (*TAG*) ou code brut [1234].
  JETON = /\{[A-Z]+\}|\(\*[^*]*\*\)|\[[0-9A-Fa-f]{4}\]/

  module_function

  def jetons(texte)
    texte.to_s.scan(JETON)
  end

  def lignes_affichees(texte)
    texte.to_s.split(/\{SAUT\}|\{PAGE\}|\{ATTENTE\}|\{FERME\}|\{PAUSE\}/)
         .map { |l| l.gsub(JETON, '').strip }
         .reject(&:empty?)
  end

  # Les fichiers de négociation (pack/talk/*.BIN) ne peuvent pas grossir
  # d'un octet. Vu en jeu le 17/09/2026 : SLIME.BIN à +98 octets, encore dans
  # son secteur, et le jeu se figeait sans message dès qu'on parlait à un
  # Slime ; ramené à sa taille d'origine, il répond en français. Comme pour
  # les donjons, le jeu lit ces fichiers à une adresse et une taille fixes.
  # La marge d'un démon est donc zéro : sur l'ensemble de ses fichiers, le
  # français ne doit pas dépasser l'anglais, en octets (2 par caractère,
  # multipliés par les occurrences).
  MARGE_TALK = 0
  DEMONS_TALK = %w[
    ALIEN BASKET DOPPEL ETC GAKI HIHO KEMONO KOKURI KOROU KOSIKI KOUMAN KUTISAKE
    KYOUKI MAYOERU POLUTAR QSIRUBA SINSI SLIME SYOUJO TENSI TINPRA TOILET WORM
    WTENSI YAKUZA YOUEN ZMBITYAN ZOMBIKO ZOMB_MAN
  ].freeze

  # Ce qu'un fichier JSON ajoute, en octets, au fichier de jeu qu'il traduit.
  def octets_ajoutes(entrees)
    entrees.sum do |e|
      next 0 unless e.is_a?(Hash) && !e['fr'].to_s.empty?

      gonfle = e['fr'].gsub(JETON, '').length - e['en'].to_s.gsub(JETON, '').length
      gonfle * 2 * e.fetch('_occurrences', 1)
    end
  end

  # PLACE — les négociations d'un démon sont réparties sur plusieurs fichiers
  # (SLIME_001, SLIME_002…) mais ne font qu'un seul fichier dans le jeu. On
  # additionne donc les fichiers frères du même dossier : le total ne doit pas
  # être positif. Avertissement quand il ne reste plus qu'un tiers de ce que
  # les fichiers déjà traduits ont économisé : un contributeur doit savoir
  # qu'il mange la place que les autres ont gagnée.
  def place_negociation(chemin, soucis, avertis)
    demon = File.basename(chemin, '.json').sub(/_\d+\z/, '')
    return unless DEMONS_TALK.include?(demon)
    return unless File.basename(chemin).match?(/\A#{Regexp.escape(demon)}_\d+\.json\z/)

    marge = MARGE_TALK

    freres = Dir.glob(File.join(File.dirname(chemin), "#{demon}_*.json")).sort
    total = freres.sum do |f|
      octets_ajoutes(JSON.parse(File.read(f, encoding: 'UTF-8')))
    rescue StandardError
      0
    end
    ici = octets_ajoutes(JSON.parse(File.read(chemin, encoding: 'UTF-8')))

    if total > marge
      soucis << "#{demon} [PLACE] +#{total} octets sur les #{freres.length} fichiers du démon " \
                "(ce fichier : #{ici >= 0 ? '+' : ''}#{ici}) — " \
                'un fichier de négociation ne peut pas grossir : le jeu se fige (vu en jeu)'
    elsif ici > 0
      avertis << "#{demon} [PLACE] ce fichier ajoute #{ici} octets, absorbés par les autres " \
                 "fichiers du démon (total #{total}) — il reste peu de place pour ce démon"
    end
  end

  # Lit la table de caractères du jeu : des lignes `XXXX=c`, hexadécimal à
  # gauche, caractère à droite. Rend { caractère => code }.
  #
  # Un même caractère peut apparaître plusieurs fois ; la première occurrence
  # gagne, comme dans le moteur.
  def charger_table(chemin)
    table = {}
    File.read(chemin, encoding: 'UTF-8').each_line do |ligne|
      ligne = ligne.chomp
      next if ligne.lstrip.empty? || ligne.lstrip.start_with?('#')

      hex, car = ligne.split('=', 2)
      next if car.nil? || car.empty?
      next unless hex.to_s.strip.length == 4

      code = Integer(hex.strip, 16) rescue next
      table[car] ||= code
    end
    table
  end

  def caracteres_hors_table(texte, tabla)
    texte.to_s.gsub(JETON, '').each_char.reject do |c|
      c == ' ' || tabla.key?(c)
    end.uniq
  end

  # Caractères encodables mais dont le glyphe n'est pas dessiné : ils
  # s'écriront dans le fichier et s'afficheront comme un blanc en jeu.
  #
  # Limité aux LETTRES à dessein. La ponctuation basse (virgule 0x0003, point
  # 0x0004…) partage ses codes avec des commandes du moteur, qui les rend par
  # un chemin à lui : sa case d'atlas est vide alors que le jeu l'affiche très
  # bien. L'inclure ne produirait que du faux positif.
  def caracteres_sans_glyphe(texte, tabla, glyphes)
    return [] if glyphes.nil?

    # Le relevé des glyphes s'arrête à 0x1FF : au-delà, on n'a pas regardé.
    # Absent de la liste ne veut donc « pas dessiné » que DANS cette plage.
    #
    # Sans cette borne, `β` (0x200) faisait échouer neuf entrées. Ce n'est même
    # pas du texte : il n'apparaît jamais ailleurs qu'accolé à
    # `(*SET_ANIM_LAYER*)`, suivi d'un `[XX]` — c'est un octet de paramètre
    # d'animation que l'extracteur a rendu comme un caractère. Le recopier
    # faisait rougir le validateur ; le retirer aurait cassé l'animation, sans
    # bruit.
    plafond = glyphes.max || 0

    texte.to_s.gsub(JETON, '').each_char.reject do |c|
      next true unless c =~ /[[:alpha:]]/

      code = tabla[c]
      code.nil? || code > plafond || glyphes.include?(code)
    end.uniq
  end

  def charger_glyphes
    chemin = File.join(AQUI, 'glyphes_disponibles.json')
    return nil unless File.exist?(chemin)

    JSON.parse(File.read(chemin))['codes'].to_set
  rescue StandardError
    nil
  end

  # --- Terminologie -------------------------------------------------------
  #
  # Sur 8 572 textes traduits par des dizaines de personnes, l'incohérence de
  # terminologie est le seul défaut qu'aucun relecteur n'attrapera : personne
  # ne se souvient qu'un autre a écrit « Chambre de Velours » trois mois plus
  # tôt. Une machine, si.
  #
  # C'est un AVERTISSEMENT, jamais un refus. Le français fléchit (« à la
  # Chambre de Velours »), et un traducteur a souvent raison de reformuler
  # plutôt que de répéter un nom. Bloquer là-dessus rendrait le validateur
  # insupportable, et un validateur qu'on contourne ne sert plus à rien.
  #
  # Seuls les termes ✅ sont contrôlés : les 🔶 sont des propositions, les
  # figer reviendrait à trancher à la place de l'équipe.
  ACCENTS_NUS = {
    'à' => 'a', 'â' => 'a', 'ä' => 'a', 'ç' => 'c', 'é' => 'e', 'è' => 'e',
    'ê' => 'e', 'ë' => 'e', 'î' => 'i', 'ï' => 'i', 'ô' => 'o', 'ö' => 'o',
    'ù' => 'u', 'û' => 'u', 'ü' => 'u', 'ÿ' => 'y', 'œ' => 'oe', 'æ' => 'ae'
  }.freeze

  def aplatir(texte)
    # `[0000]` est l'espace encodé des zones EBOOT. Sans cette ligne,
    # « Pic[0000]du[0000]Diable » ne ressemblait pas à « Pic du Diable » et le
    # contrôle terminologique ne voyait rien dans tout le dossier eboot/.
    texte.to_s
         .gsub('[0000]', ' ')
         .downcase
         .gsub(Regexp.union(ACCENTS_NUS.keys), ACCENTS_NUS)
  end

  # Lit les tableaux « | Anglais | Français | Statut | » du dictionnaire.
  # Rend [[terme anglais, terme français]] pour les seules lignes ✅.
  def charger_dictionnaire(chemin)
    return [] unless chemin && File.exist?(chemin)

    termes = []
    File.readlines(chemin, encoding: 'UTF-8').each do |ligne|
      cases = ligne.strip.split('|').map(&:strip)
      cases.shift if cases.first.to_s.empty?
      next unless cases.length >= 3 && cases[2].include?('✅')

      en = cases[0]
      fr = cases[1].sub(/\*\(.*/, '').strip # coupe la note en italique

      # Une case qui porte encore une parenthèse est une explication, pas un
      # terme : « (nom choisi par le joueur) » ne se cherche pas dans un texte.
      next if en.empty? || fr.empty? || en.include?('(') || fr.include?('(')
      next if en.include?('/') || fr.include?('/') # alternatives, trop ambigu
      next if en.length < 3

      termes << [en, fr]
    end
    termes.uniq
  rescue StandardError
    []
  end

  def chercher_dictionnaire
    ['Dictionnaire.md',
     File.join('..', 'docs', 'Dictionnaire.md'),
     File.join('..', 'scripts', 'Dictionnaire.md')]
      .map { |r| File.expand_path(r, AQUI) }
      .find { |c| File.exist?(c) }
  end

  # Un terme est signalé quand l'anglais le contient et que le français ne
  # contient pas sa traduction. Comparaison sans accents ni casse, pour que
  # « chambre de velours » et « Chambre de Velours » se valent.
  def termes_manquants(anglais, francais, termes)
    plat_en = aplatir(anglais)
    plat_fr = aplatir(francais)

    termes.select do |en, fr|
      next false unless plat_en.match?(/\b#{Regexp.escape(aplatir(en))}\b/)

      # Un terme peut avoir plusieurs rendus légitimes, séparés par « / » dans
      # le dictionnaire : « Arbre Agastya / Agastya ». La forme longue sert là
      # où la place le permet — la légende de la carte — et l'abrégée sur les
      # étiquettes à onze caractères. N'importe laquelle satisfait le contrôle.
      rendus(fr).none? { |r| plat_fr.include?(r) }
    end
  end

  # « Arbre Agastya / Agastya » -> les deux formes, aplaties.
  def rendus(francais)
    francais.to_s.split(' / ').map { |r| aplatir(r.strip) }.reject(&:empty?)
  end

  # Empreinte d'une entrée telle qu'extraite du jeu. Douze caractères
  # hexadécimaux suffisent : on cherche l'édition accidentelle, pas la fraude.
  def empreinte(anglais, locuteur)
    Digest::SHA256.hexdigest("#{locuteur} #{anglais}")[0, 12]
  end

  # Le canari se cherche à côté du fichier vérifié, puis dans le dossier
  # parent : les fichiers de travail vivent dans `trad/dialogues/`, le canari
  # à la racine de `trad/`. Absent, on ne contrôle rien — c'est le cas des
  # brouillons locaux, qui n'ont pas à en porter un.
  def charger_canari(chemin)
    dossier = File.dirname(File.expand_path(chemin))
    [dossier, File.dirname(dossier)].each do |d|
      candidat = File.join(d, '_canari.json')
      return JSON.parse(File.read(candidat, encoding: 'UTF-8')) if File.exist?(candidat)
    end
    nil
  rescue StandardError
    nil
  end

  # Un JSON cassé — une virgule de trop, un guillemet perdu en éditant dans le
  # navigateur — ne doit pas faire planter le validateur avec une pile Ruby
  # que le contributeur ne saura pas lire. On rend un message et la ligne
  # approximative : Ruby ne donne pas de position, mais son message recopie
  # tout ce qui reste à lire après l'accroc, ce qui suffit à la retrouver.
  def erreur_json(chemin)
    source = File.read(chemin, encoding: 'UTF-8')
    JSON.parse(source)
    nil
  rescue JSON::ParserError => e
    reste = e.message[/at '(.*)\z/m, 1].to_s
    ligne = [source.lines.count - reste.lines.count + 1, 1].max
    # Quand l'accroc est dans le premier objet, Ruby recopie tout le document
    # et la ligne calculée vaut 1, ce qui n'aide personne. On cherche alors
    # soi-même le coupable le plus fréquent : une virgule juste avant `}`.
    if ligne == 1 && (pos = source =~ /,\s*
\s*[}\]]/)
      ligne = source[0..pos].count("
") + 1
    end
    "[JSON] fichier illisible vers la ligne #{ligne} — une virgule, un guillemet ou "       'un caractère en trop ou en moins, souvent sur la ligne juste avant'
  end

  # EFFACEMENT — compare au même fichier dans une autre révision git. Rend
  # { id => [locuteur_fr, fr] } des entrées traduites là-bas, ou nil si le
  # fichier n'y existe pas (fichier nouveau) ou si git n'est pas là.
  def traductions_de_reference(chemin, ref)
    relatif = chemin.tr('\\', '/').sub(%r{\A\./}, '')
    source = IO.popen(['git', 'show', "#{ref}:#{relatif}"], err: File::NULL, &:read)
    return nil unless $?.success? && !source.to_s.empty?

    JSON.parse(source).each_with_object({}) do |e, h|
      next unless e.is_a?(Hash) && !e['fr'].to_s.empty?

      h[e['id']] = e['fr']
    end
  rescue StandardError
    nil
  end

  def effacements(entrees, reference, soucis)
    return unless reference

    entrees.each do |e|
      next unless e.is_a?(Hash) && e['fr'].to_s.empty? && reference[e['id']]

      soucis << "#{e['id']} [EFFACEMENT] une traduction existante est remplacée par du vide — "                 'ta copie du fichier est périmée : synchronise ton fork (« Sync fork ») '                 'ou repars du fichier sur le dépôt principal'
    end
  end

  def verifier(chemin, tabla, glyphes, canari = nil, termes = [], reference = nil)
    entrees = JSON.parse(File.read(chemin, encoding: 'UTF-8'))
    soucis = []
    avertis = []
    traduites = 0

    entrees.each do |e|
      id = e['id']

      if canari
        attendue = canari[id]
        if attendue.nil?
          soucis << "#{id} [CANARI] identifiant inconnu — entrée ajoutée à la main ?"
        elsif empreinte(e['en'], e['locuteur']) != attendue
          soucis << "#{id} [CANARI] l'anglais d'origine a été modifié — restaurer 'en' et 'locuteur'"
        end
      end

      # Le nom du personnage passe par la même table que le dialogue : un
      # caractère impossible s'y voit aussi peu, et s'affiche aussi blanc.
      unless e['locuteur_fr'].to_s.empty?
        hors = caracteres_hors_table(e['locuteur_fr'], tabla)
        soucis << "#{id} [ENCODAGE] locuteur : #{hors.join(' ')} absent(s) de la table" if hors.any?

        muets = caracteres_sans_glyphe(e['locuteur_fr'], tabla, glyphes)
        soucis << "#{id} [GLYPHE] locuteur : #{muets.join(' ')} sans dessin dans la police" if muets.any?
      end

      next if e['fr'].to_s.empty?

      traduites += 1

      # `[0000]` est l'espace encodé de certaines zones EBOOT, pas une
      # structure : le nombre de mots change forcément en français.
      attendus = jetons(e['en']).reject { |j| j == '[0000]' }
      obtenus  = jetons(e['fr']).reject { |j| j == '[0000]' }
      if attendus != obtenus
        soucis << "#{id} [STRUCTURE] codes attendus #{attendus.inspect}, obtenus #{obtenus.inspect}"
      end

      hors = caracteres_hors_table(e['fr'], tabla)
      soucis << "#{id} [ENCODAGE] #{hors.join(' ')} absent(s) de la table" if hors.any?

      muets = caracteres_sans_glyphe(e['fr'], tabla, glyphes)
      soucis << "#{id} [GLYPHE] #{muets.join(' ')} sans dessin dans la police" if muets.any?

      # AVERTISSEMENT, pas erreur — et c'est une correction.
      #
      # On a longtemps cru que depasser `max` faisait garder l'anglais par le
      # moteur. Une capture du 05/09/2026 (game/images/captures_jeu/) montre
      # l'inverse : « Charger une partie », 18 caracteres pour un `max` de 17,
      # s'affiche ENTIER sur l'ecran-titre. Le moteur redirige bien la chaine
      # trop longue vers un code cave, comme game/CLAUDE.md le decrivait.
      #
      # Depasser reste plus fragile que tenir dans le budget, donc on le dit.
      # Mais bloquer sur ce motif interdisait des mots que le francais n'a pas
      # plus courts : « No » fait deux caracteres, « Non » en fait trois.
      if e['max']
        # `max` est un nombre de caractères, jetons non comptés : compter pareil.
        n = e['fr'].gsub(JETON, '').length
        if n > e['max']
          avertis << "#{id} [BUDGET] #{n} caractères pour un maximum de #{e['max']} — passe par un code cave, à vérifier en jeu"
        end
      end

      # La largeur se juge PAR RAPPORT À L'ANGLAIS. 42 lignes du script
      # original dépassent déjà 43 caractères : un traducteur fidèle y serait
      # refusé pour une largeur qu'il n'a pas créée. On ne reproche donc que ce
      # que le français ajoute — et on n'avertit qu'à partir de 40, comme
      # annoncé aux contributeurs.
      anglaises = lignes_affichees(e['en'])
      lignes_affichees(e['fr']).each_with_index do |l, i|
        origine = (anglaises[i] || anglaises.max_by(&:length) || '').length
        next unless l.length > LARGEUR_MAX

        if l.length <= origine
          # Aussi large que l'original : par définition pas une régression. Rien
          # à reprendre, donc rien à signaler — un avertissement sur lequel
          # personne ne peut agir noie ceux sur lesquels on peut.
          next
        elsif origine > LARGEUR_DURE
          # L'anglais lui-même dépasse déjà la boîte : ce n'est donc pas une
          # ligne affichée. Ce sont les blocs de mise en scène — des centaines
          # de (*SCENE_LOAD*) et (*SET_ANIM_LAYER*) dont les espaces se
          # retrouvent dans le texte — avec une phrase courte au bout.
          #
          # Mesuré sur E0.BIN:016:0285 : 1 491 caractères annoncés pour 19 de
          # texte réellement affiché (« > Vous avez pièces. »). La largeur n'a
          # pas de sens sur ces entrées, et le traducteur n'y peut rien : on ne
          # signale pas.
          next
        elsif l.length > LARGEUR_DURE
          soucis << "#{id} [LARGEUR] #{l.length} car. contre #{origine} en anglais (debordement certain) : #{l.inspect}"
        else
          avertis << "#{id} [LARGEUR] #{l.length} car. contre #{origine} en anglais — a surveiller"
        end
      end

      # BUDGET D'OCTETS. Le jeu ne cherche pas ses fichiers de données par leur
      # nom : il lit à une adresse fixe. Un `.BIN` qui grossit est réécrit
      # ailleurs, et le jeu continue de lire l'ancien — tout redevient anglais,
      # sans une erreur. Chaque caractère coûte 2 octets, et un texte répété
      # coûte autant de fois qu'il apparaît. Le nom du locuteur compte aussi :
      # il est encodé avec la réplique.
      #
      # On ne mesure pas ici la marge réelle du bloc, qu'on ignore. On signale
      # ce qui s'allonge et combien ça coûte, pour que la dérive se voie tôt
      # plutôt qu'au build.
      # Le seuil existe pour que l'avertissement reste lisible : quelques
      # octets sont absorbés par la marge du bloc, et signaler chaque +8
      # noierait les cas qui comptent vraiment — un texte d'aide recopié neuf
      # fois a fait déborder trois fichiers d'un coup.
      n = e.fetch('_occurrences', 1)
      gonfle = (e['fr'].gsub(JETON, '').length - e['en'].gsub(JETON, '').length) +
               (e['locuteur_fr'].to_s.empty? ? 0 : e['locuteur_fr'].length - e['locuteur'].to_s.length)
      cout = gonfle * 2 * n
      # `[0000]` n'est l'espace que dans les zones EBOOT où l'anglais l'emploie
      # lui-même (« That's[0000]not[0000]true. »). Partout ailleurs c'est une
      # FIN DE CHAÎNE : « C'est[0000]bien[0000]cela? » s'affiche « C'est » en
      # combat. Vu en jeu le 17/09/2026 sur 132 lignes de menus.
      if e['fr'].to_s.include?('[0000]') && !e['en'].to_s.include?('[0000]')
        soucis << "#{id} [ESPACE] [0000] dans le francais alors que l'anglais a de vrais espaces — " \
                  'ici [0000] coupe la chaine, ecrire des espaces'
      end

      if id.to_s.start_with?('DNG:') && gonfle > 0
        # Les fichiers de donjon sont à part : ils ne peuvent pas grossir d'un
        # octet. Leur taille est inscrite dans l'exécutable, et un donjon qui
        # dépasse laisse le jeu sur un écran de chargement infini — vu en jeu
        # le 17/09/2026 en sortant de l'infirmerie, pour quelques octets de
        # trop dans quatre fichiers. Erreur, donc, pas avertissement.
        soucis << "#{id} [DONJON] #{gonfle} car. de plus que l'anglais — " \
                  'un fichier de donjon ne peut pas grossir (chargement infini)'
      elsif cout > SEUIL_OCTETS
        avertis << "#{id} [OCTETS] +#{cout} octets (#{gonfle} car. x#{n} occurrences) — " \
                   'un bloc qui deborde renvoie tout le fichier en anglais'
      end

      termes_manquants(e['en'], e['fr'], termes).each do |en, fr|
        avertis << "#{id} [TERMINO] « #{en} » se traduit « #{fr} » (dictionnaire) — " \
                   'volontaire ? sinon aligner'
      end
    end

    place_negociation(chemin, soucis, avertis)
    effacements(entrees, reference, soucis)

    [entrees.length, traduites, soucis, avertis]
  end

  # Numéro de ligne de chaque entrée dans le fichier JSON, repéré sur son `id`.
  # Les fichiers sont écrits en JSON indenté : un `id` par ligne, dans l'ordre.
  # Sert aux annotations GitHub, qui se posent alors sur la bonne ligne du diff
  # — y compris pour une proposition venue d'un fork, où le robot n'a pas le
  # droit d'écrire un commentaire.
  def lignes_des_ids(chemin)
    lignes = {}
    File.readlines(chemin, encoding: 'UTF-8').each_with_index do |ligne, i|
      m = ligne.match(/"id"\s*:\s*"?([^",]+)"?/)
      lignes[m[1]] ||= i + 1 if m
    end
    lignes
  rescue StandardError
    {}
  end

  # Format attendu par GitHub Actions. Les retours à la ligne doivent être
  # échappés, sinon l'annotation est tronquée à la première.
  def annoter(chemin, ligne, message, niveau = 'error')
    propre = message.gsub('%', '%25').gsub("\r", '%0D').gsub("\n", '%0A')
    titre = niveau == 'warning' ? 'Terminologie' : 'Traduction'
    puts "::#{niveau} file=#{chemin},line=#{ligne},title=#{titre}::#{propre}"
  end

  def main(argv)
    annotations = argv.delete('--annoter')
    # `--json` sert au suivi, qui a besoin de savoir quels fichiers sont sains.
    # Une sortie machine plutôt qu'un texte à relire : reformuler un message ne
    # doit pas casser le tableau d'avancement.
    en_json = argv.delete('--json')
    # `--base <ref>` : la révision à laquelle comparer, pour attraper les
    # traductions effacées. L'action passe le `base.sha` de la proposition.
    base = nil
    if (i = argv.index('--base'))
      base = argv[i + 1]
      argv.slice!(i, 2)
    end

    if argv.empty?
      # Le chemin réellement invoqué, et non un chemin en dur : le même fichier
      # vit sous `outils/` dans le dépôt public et sous `game/tools/` dans le
      # privé, et afficher l'autre envoie le contributeur dans le mur.
      puts "usage: ruby #{$PROGRAM_NAME} [--annoter] [--json] [--base <ref>] <fichier.json> [...]"
      return 2
    end

    tbl = [File.join(AQUI, 'persona1_psp.tbl'),
           File.join(AQUI, 'p1es', 'persona1_psp.tbl')].find { |c| File.exist?(c) }
    if tbl.nil?
      warn 'erreur : persona1_psp.tbl introuvable'
      return 2
    end

    tabla = charger_table(tbl)
    glyphes = charger_glyphes
    warn 'note : glyphes_disponibles.json absent — contrôle des glyphes ignoré' if glyphes.nil?

    termes = charger_dictionnaire(chercher_dictionnaire)
    warn 'note : Dictionnaire.md introuvable — contrôle terminologique ignoré' if termes.empty?

    total_soucis = 0
    total_avertis = 0
    rapport = []

    argv.each do |chemin|
      if (casse = erreur_json(chemin))
        ligne = casse[/ligne (\d+)/, 1].to_i
        if en_json
          rapport << { 'fichier' => File.basename(chemin), 'textes' => 0, 'traduites' => 0,
                       'soucis' => [{ 'id' => '', 'ligne' => ligne, 'message' => casse }],
                       'avertissements' => [] }
        else
          puts "❌ 1  #{chemin} — #{casse}"
          annoter(chemin, ligne, casse) if annotations
        end
        total_soucis += 1
        next
      end

      canari = charger_canari(chemin)
      reference = base ? traductions_de_reference(chemin, base) : nil
      total, traduites, soucis, avertis = verifier(chemin, tabla, glyphes, canari, termes, reference)

      if en_json
        # Le numéro de ligne accompagne chaque souci : c'est lui qui permet au
        # suivi de pointer directement dans le fichier, sans que personne ait à
        # chercher la réplique à la main.
        ou = lignes_des_ids(chemin)
        detaille = lambda do |liste|
          liste.map do |s|
            id = s.split(' ', 2).first
            { 'id' => id, 'ligne' => ou[id] || 1, 'message' => s }
          end
        end

        rapport << { 'fichier' => File.basename(chemin), 'textes' => total,
                     'traduites' => traduites,
                     'soucis' => detaille.call(soucis),
                     'avertissements' => detaille.call(avertis) }
        total_soucis += soucis.length
        next
      end

      etat = if soucis.any?
               "❌ #{soucis.length}"
             elsif avertis.any?
               "⚠ #{avertis.length}"
             else
               '✅'
             end
      puts "#{etat}  #{chemin} — #{traduites}/#{total} traduites"
      soucis.each { |s| puts "      #{s}" }
      avertis.each { |a| puts "      #{a}" }
      total_soucis += soucis.length
      total_avertis += avertis.length

      next unless annotations && (soucis.any? || avertis.any?)

      lignes = lignes_des_ids(chemin)
      soucis.each { |s| annoter(chemin, lignes[s.split(' ', 2).first] || 1, s) }
      avertis.each { |a| annoter(chemin, lignes[a.split(' ', 2).first] || 1, a, 'warning') }
    end

    if en_json
      puts JSON.generate(rapport)
      return total_soucis.zero? ? 0 : 1
    end

    # Les avertissements ne font PAS échouer : ils demandent un avis humain, ils
    # ne constatent pas une faute.
    puts "#{total_avertis} avertissement(s) — à relire, pas bloquant" if total_avertis.positive?

    total_soucis.zero? ? 0 : 1
  end
end

exit(CheckTrad.main(ARGV)) if __FILE__ == $PROGRAM_NAME
