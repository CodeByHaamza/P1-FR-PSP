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
#   4. LARGEUR   — chaque ligne affichée doit tenir dans la boîte, et cela se
#      MESURE, en pixels. La police est à chasse variable : `WWWWW` et `iiiii`
#      n'occupent pas la même place, donc compter les caractères se trompe dans
#      les deux sens. L'ancienne règle des 40 signes sortait 273 avertissements
#      là où la mesure n'en trouve aucun, et un validateur qui crie sans raison,
#      on apprend à l'ignorer.
#      La borne de chaque zone est la ligne anglaise affichée la plus large,
#      relevée dans `largeurs_glyphes.json` : le jeu l'affiche sans la couper,
#      donc c'est une borne observée et non une estimation. Elle est absolue,
#      ce qui n'est plus injuste pour personne — l'original la respecte par
#      construction.
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
#   8bis. SLOT   — un nom (zone `noms`) plus long que son slot. Les noms vivent
#      dans des tables à slots réguliers que le jeu lit par calcul d'indice :
#      il n'y a pas de pointeur à rediriger, donc pas de code cave de secours,
#      et le build refuse. D'où une erreur là où BUDGET se contente d'un
#      avertissement. Ces entrées portent `_fixe`, et leur `max` est la place
#      mesurée dans le slot — souvent bien plus que l'anglais : « Rapier » fait
#      6 caractères dans un slot qui en accepte 19.
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
  # Plus de seuil en caractères : la largeur se mesure en pixels, cf. `metrique`.
  # Celui-ci reste, et c'est un PROXY assumé : l'autorité sur le budget des
  # blocs est `budget_blocs.py`, qui exige `_occurrences.json` et ne tourne donc
  # que côté privé, avant chaque construction.
  SEUIL_OCTETS = 48  # au-delà, une entrée pèse assez pour faire déborder un bloc

  # Repère un code de contrôle sous ses trois formes : nom lisible {SAUT},
  # balise du moteur (*TAG*) ou code brut [1234].
  JETON = /\{[A-Z]+\}|\(\*[^*]*\*\)|\[[0-9A-Fa-f]{4}\]/

  module_function

  def jetons(texte)
    texte.to_s.scan(JETON)
  end

  # Ce que le moteur remplace avant d'encoder : « … » devient trois points, donc
  # trois glyphes. Mesurer autrement, c'est mesurer un texte que le jeu
  # n'affiche pas.
  ANCHOS = {
    '…' => '...', '’' => "'", '‘' => "'",
    '“' => '"', '”' => '"', '—' => '-', '–' => '-'
  }.freeze

  # Une entrée de négociation contient PLUSIEURS répliques du démon : sa
  # réaction change selon ce que le joueur vient de dire. Elles sont séparées
  # par un marqueur encadré — `[FFFD]` un code `[F5xx]` — dont le milieu
  # s'écrit `[72FF]`, ou sous la forme du caractère que la table donne à ce
  # code : `É` pour 0x00FF, `α` pour 0x01FF. Comme il n'est reconnu qu'entre ses
  # crochets, « IMPÉRATRICE » reste un mot. Il n'apparaît que dans les
  # négociations, 3 118 fois.
  SEPARATEUR = /\[FFFD\](?:\[[0-9A-Fa-f]{4}\]|[^\[])*?\[F5[0-9A-Fa-f]{2}\](?:\[[0-9A-Fa-f]{4}\])*/
  # Deux entrées collent leurs répliques sans marqueur : ponctuation de fin,
  # deux espaces LITTÉRALES, une capitale. Nulle part ailleurs dans le corpus.
  COLLAGE = /(?<=[.!?])  +(?=[[:upper:]])/

  # Tout ce qui termine une ligne à l'écran. `{PAUSE}` n'en fait PAS partie :
  # il marque un temps, et le texte continue sur la même ligne — couper là
  # faisait croire à deux lignes courtes au lieu d'une longue. `(*SPEAKER*)` et
  # `(*RESPONSE*)`, eux, en terminent bien une.
  COUPE = /\{SAUT\}|\{PAGE\}|\{ATTENTE\}|\{FERME\}|\(\*SPEAKER\*\)|\(\*RESPONSE\*\)/

  # `[0000]` n'est pas un code de contrôle : c'est l'ESPACE. Elle n'est pas dans
  # la table, elle s'encode sur le code 0. La retirer avec les jetons, c'était
  # mesurer « Salledesprofs ».
  def lignes_affichees(texte)
    brut = texte.to_s.gsub(SEPARATEUR, "\n").gsub(COLLAGE, "\n").gsub('[0000]', ' ')
    ANCHOS.each { |a, b| brut = brut.gsub(a, b) }
    brut.split(COUPE).flat_map { |p| p.split("\n") }
        .map { |l| l.gsub(JETON, '').strip }
        .reject(&:empty?)
  end

  # Cette ligne est-elle rendue dans une boîte ?
  #
  # Un remplissage d'espaces appartient à un bloc de mise en scène, le japonais
  # inutilisé n'est jamais atteint, et au-delà d'une soixantaine de signes ce
  # n'est pas une ligne mais une entrée dont on ne modélise pas la découpe
  # interne. Le remplissage ne se juge que sur l'INTÉRIEUR : un libellé de menu
  # centré par des espaces de tête est bien affiché. Même règle que
  # `largeur_pixels.py`, et il faut que ce soit exactement la même : deux
  # filtres différents, c'est un outil qui contredit l'autre.
  def ligne_rendue?(ligne)
    net = ligne.strip
    return false if net.empty? || net.length > 60
    return false if net =~ /\s{6,}/
    return false if net =~ /[\u3040-\u30ff\u4e00-\u9fff]/

    net =~ /[[:alpha:]]/ ? true : false
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
  # Un même caractère peut apparaître plusieurs fois, et c'est le DERNIER qui
  # gagne — `car_a_valor[car] = valor` dans `text.rb`, sans garde. Vingt
  # caractères sont dans ce cas, tous les accentués compris, et l'écart n'est
  # pas cosmétique :
  #
  #   `é` 0x00AB (premier) : cellule vide, 17 px d'avance
  #   `é` 0x00DA (dernier) : le glyphe réel, 9 px
  #
  # Mesurer avec le premier gonflerait donc chaque accent de huit pixels, sur
  # une langue qui en est truffée. Et trois caractères (`Á`, `Ñ`, `ú`) ont un
  # premier code que la police ne dessine pas : le contrôle GLYPHE les aurait
  # déclarés muets le jour où quelqu'un les écrit.
  def charger_table(chemin)
    table = {}
    File.read(chemin, encoding: 'UTF-8').each_line do |ligne|
      ligne = ligne.chomp
      next if ligne.lstrip.empty? || ligne.lstrip.start_with?('#')

      hex, car = ligne.split('=', 2)
      next if car.nil? || car.empty?
      next unless hex.to_s.strip.length == 4

      code = Integer(hex.strip, 16) rescue next
      table[car] = code
    end
    table
  end

  # --- La métrique du jeu, pas une estimation -------------------------------
  #
  # `largeurs_glyphes.json` porte l'avance de chaque code en pixels et la borne
  # de chaque zone. Les deux sortent de l'EBOOT par `extraire_largeurs.py` : la
  # métrique vient des tables du moteur p1es de Zenshou, la borne est la ligne
  # anglaise affichée la plus large — donc une borne OBSERVÉE, puisque le jeu
  # l'affiche sans la couper.
  #
  # Avant, ce contrôle comptait des CARACTÈRES. La police est à chasse
  # variable : `WWWWW` et `iiiii` n'occupent pas la même place, donc compter se
  # trompe dans les deux sens — on refusait des lignes qui tiennent et on
  # laissait passer des lignes qui débordent. Sur le corpus entier, la règle des
  # 40 signes sortait 273 avertissements là où la mesure n'en trouve aucun. Un
  # validateur qui crie sans raison, on apprend à l'ignorer.
  def metrique
    return @metrique if defined?(@metrique)

    chemin = File.join(AQUI, 'largeurs_glyphes.json')
    @metrique = File.exist?(chemin) ? JSON.parse(File.read(chemin, encoding: 'UTF-8')) : nil
  rescue StandardError
    @metrique = nil
  end

  # { caractère => avance en pixels }, l'espace mis à part : il n'est pas dans
  # la table de caractères, il s'encode sur le code 0, et `ancho_glifo` lui
  # donne 5 px.
  def avances_car(tabla)
    return nil if metrique.nil?

    @avances_car ||= begin
      brut = metrique['avances']
      tabla.each_with_object({}) do |(car, code), h|
        px = brut[code.to_s]
        h[car] = px if px
      end
    end
  end

  def espace_px
    return 5 if metrique.nil?

    (metrique['avances']['0'] || 5)
  end

  # La borne de la zone, déduite du dossier qui contient le fichier.
  def limite_px(chemin)
    return nil if metrique.nil?

    zone = File.basename(File.dirname(File.expand_path(chemin)))
    fiche = (metrique['_limites'] || {})[zone]
    fiche && fiche['limite_px']
  end

  def mesurer_px(ligne, avances)
    ligne.each_char.sum { |c| c == ' ' ? espace_px : (avances[c] || 0) }
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
         # Un terme peut enjamber un saut de ligne : « la Reine des{SAUT}Neiges ».
         # Sans cette ligne, le controle terminologique ne le reconnaissait pas et
         # criait sur quatre repliques parfaitement traduites.
         .gsub(/\{[A-Z]+\}/, ' ')
         .squeeze(' ')
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
      # La case française peut porter une précision après un tiret cadratin
      # (« Persona — **féminin** : la Persona... ») : seule la forme qui
      # précède est le terme. On retire aussi le gras et la note en italique,
      # sinon le message d'avertissement recrache le Markdown du tableau.
      fr = cases[1].sub(/\*\(.*/, '')      # note en italique
                   .sub(/\s+[—–-]\s.*/, '') # précision après un tiret
                   .gsub('**', '').strip

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
    # La métrique et la borne de la zone, une fois pour tout le fichier. Sans
    # `largeurs_glyphes.json` à côté, la mesure ne se fait pas du tout plutôt
    # que de se faire mal : une largeur fausse est pire que pas de largeur.
    avances = avances_car(tabla)
    limite = limite_px(chemin)
    # Un contrôle qui disparaît en silence est pire que pas de contrôle : on
    # croit qu'il a passé. Si la métrique manque, ou si le dossier n'est pas une
    # zone connue, on le dit une fois.
    if (avances.nil? || limite.nil?) && !defined?(@largeur_dite)
      @largeur_dite = true
      raison = avances.nil? ? 'largeurs_glyphes.json absent' : "zone inconnue (#{File.basename(File.dirname(File.expand_path(chemin)))})"
      warn "  [LARGEUR] mesure desactivee : #{raison}"
    end
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
        if n > e['max'] && e['_fixe']
          # Slot fixe : pas de code cave possible, le build refuserait.
          soucis << "#{id} [SLOT] #{n} caractères pour un slot de #{e['max']} — à raccourcir, le jeu n'a pas la place"
        elsif n > e['max']
          avertis << "#{id} [BUDGET] #{n} caractères pour un maximum de #{e['max']} — passe par un code cave, à vérifier en jeu"
        end
      end

      # LARGEUR, en PIXELS. La borne de la zone est la ligne anglaise affichée
      # la plus large : le jeu l'affiche sans la couper, donc tout ce qui est en
      # dessous passe. Plus besoin de juger « par rapport à l'anglais » comme
      # du temps où l'on comptait des caractères — une borne absolue ne peut
      # pas, par construction, reprocher au traducteur une largeur que
      # l'original avait déjà.
      if avances && limite
        lignes_affichees(e['fr']).each do |l|
          next unless ligne_rendue?(l)

          px = mesurer_px(l, avances)
          if px > limite
            soucis << "#{id} [LARGEUR] #{px} px pour une boite de #{limite} px " \
                      "(+#{px - limite}) — la ligne sera coupee : #{l.inspect}"
          elsif px > limite * 93 / 100
            avertis << "#{id} [LARGEUR] #{px} px, la boite en fait #{limite} — il reste #{limite - px} px"
          end
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
        # Prudent sur ce qu'il affirme : on sait ce que CETTE entrée ajoute, pas
        # combien son bloc avait de marge. Un bloc qui déborde renvoie bien tout
        # son fichier en anglais, mais la plupart ont de la place — l'autorité
        # est `budget_blocs.py`, côté privé, avant chaque construction.
        avertis << "#{id} [OCTETS] +#{cout} octets (#{gonfle} car. x#{n} occurrences) — " \
                   'a confronter au budget des blocs, seul a connaitre la marge reelle'
      end

      termes_manquants(e['en'], e['fr'], termes).each do |en, fr|
        # Sur une entree a `max`, exiger le terme du dictionnaire n'a de sens que
        # s'il y entre. « Change Personas » tient dans 15 caracteres, « Changer
        # Personae » en fait 16 : le traducteur n'avait pas le choix, et le
        # signaler six fois de suite apprend juste a ignorer les avertissements.
        if e['max']
          court = rendus(fr).map(&:length).min.to_i
          next if e['fr'].gsub(JETON, '').length + court + 1 > e['max']
        end
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
      # Les fichiers techniques ne sont pas des fichiers de traduction : le
      # canari est lu par `charger_canari`, pas verifie comme une liste
      # d'entrees. Le glob documente (`trad/<zone>/*.json`) les ramasse, et la
      # CI les ecarte a la main depuis toujours ; les ecarter ici evite que la
      # meme commande plante quand on la joue sur son poste.
      next if File.basename(chemin).start_with?('_')

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
