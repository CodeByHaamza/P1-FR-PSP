# Feuille de route — de « tout est traduit » à « la 1.0 »

Le texte du jeu est traduit à 100 % depuis le 03/10/2026 : **24 572 textes sur
24 584**, les douze derniers étant des répliques japonaises que le jeu n'utilise
pas et qui doivent rester vides.

Ce n'est pas la fin du projet, c'est la fin de sa première moitié. Ce document
dit ce qui reste, dans l'ordre où ça doit se faire, et pourquoi cet ordre-là.

Chaque étape finit par un critère vérifiable — une commande qui passe, pas une
impression. C'est ce qui permet de savoir qu'on a le droit de passer à la
suivante.

---

## ✅ Étape 1 — Rognage des blocs qui débordent *(faite le 03/10/2026)*

C'était le verrou. `budget_blocs.py` dit maintenant **« aucun bloc en
surplus »** : les 3 010 octets de départ sont rentrés.

Deux leviers, dans cet ordre. D'abord les **étiquettes de locuteur**, qui sont
encodées avec chaque réplique : trois caractères de trop sur quelqu'un qui
parle cinquante fois coûtent trois cents octets. Trois renommages ont rendu
512 octets et fait rentrer six blocs d'un coup — c'étaient aussi les plus
longues étiquettes du corpus, qui débordaient probablement la boîte du
locuteur, calibrée sur 21 caractères en anglais :

| avant | caractères | après |
|---|---|---|
| Proviseur adjoint Hanya | 23 | **Adjoint Hanya** |
| Proviseure adjointe Ooishi | 26 | **Adjointe Ooishi** |
| Fille aux cheveux courts | 24 | **Fille coupe courte** |

Ensuite le texte, bloc par bloc, du plus lourd au plus léger : **106 répliques
reformulées plus court, à sens égal**. La langue y gagne souvent, le français
traduit depuis l'anglais étant naturellement délayé (« C'est la raison pour
laquelle vous avez abandonné » → « C'est pour ça que vous avez abandonné »).

Deux cas ont demandé autre chose qu'un raccourcissement :

- `E3.BIN` bloc 005 : l'étiquette « Grenouille » coûte 240 octets à elle seule
  et ne peut pas raccourcir, c'est le nom du personnage. Les 91 caractères sont
  venus de son monologue, qui était bavard.
- Les huit blocs `E4.BIN` tenaient tous à la même phrase, répétée sur les sept
  monuments des péchés : « Le péché de X de l'homme est enterré ici » devient
  « Ici gît le péché de X de l'homme », plus court que l'anglais et plus juste
  pour *interred*.

Ce qu'on retient pour la suite : **toute correction qui rallonge une réplique
doit repasser par `budget_blocs.py`**, parce que le symptôme d'un bloc qui
déborde est un fichier entier en anglais, sans erreur.

<details>
<summary>L'état au départ, pour mémoire</summary>

Le jeu lit son texte par blocs de taille fixe. Traduire plus long que l'anglais
fait grossir un bloc, et **un bloc qui dépasse sa frontière fait rester tout son
fichier en anglais dans le jeu** — sans erreur au build, sans rien dans les
logs. C'est le plus sournois de nos problèmes, et c'est pour ça qu'il passe
avant la relecture : relire un texte qui ne s'affichera pas est du travail jeté.

État au 03/10/2026, mesuré par `python game/tools/budget_blocs.py` :

| | |
|---|---|
| blocs en surplus | **55** |
| à économiser | **3 010 octets, soit 1 505 caractères** |
| dont faciles (≤ 20 caractères) | 32 blocs |
| moyens (21 à 50) | 13 blocs |
| lourds (> 50) | 10 blocs |

Les pires : `E1.BIN` bloc 066 (+310 o), `E1.BIN` bloc 080 (+214 o), `E0.BIN`
bloc 215 (+188 o), `E3.BIN` bloc 005 (+182 o), `E0.BIN` bloc 147 (+172 o).

</details>

---

## ✅ Étape 2 — Construire l'ISO et la vérifier à la machine *(faite le 03/10/2026)*

Une fois les blocs rentrés dans leurs frontières, la chaîne complète peut
tourner pour la première fois avec les cinq zones à 100 % :

1. `p1es_apply.rb` cinq fois, une par zone, chacune lisant la sortie de la
   précédente ;
2. `p1es/build.rb` pour reconstruire l'ISO ;
3. `verif_iso.py` pour comparer l'ISO produite à l'originale.

Ce qu'on cherche ici n'est pas « est-ce beau », c'est « est-ce que le texte
français est bien arrivé ».

**Résultat.** Les 22 221 traductions sont posées dans les CSV, l'ISO se
construit, et `verif_iso.py` conclut **« OK, aucun fichier de données
déplacé »** : 58 fichiers modifiés en place, 198 identiques.

Un point a demandé vérification : le build affiche `apendado=1`. Le fichier
réécrit en fin d'image est `PSP_GAME/SYSDIR/EBOOT.BIN`, que le firmware charge
**par l'index ISO9660** — le réécrire ailleurs est donc sans danger. La règle
« un fichier de données ne doit jamais grossir » vise les `pack/E*.BIN`, que le
code du jeu adresse par LBA en dur, et ceux-là sont tous restés en place. Les
builds précédents ajoutaient déjà les mêmes 3 002 secteurs, soit exactement la
taille de l'EBOOT.

Reste que `verif_iso.py` ne prouve pas que le texte *dedans* est en français.
D'où `game/tools/verif_fr_iso.rb`, ajouté pour ça : il encode une phrase
française de chaque zone avec la table du jeu et la cherche dans les octets de
l'ISO construite. Les sept témoins sont trouvés, accents compris (« Ici gît le
péché », « Fragment de Miroir », « Grotte Alaya »). Le piège, au premier essai :
**l'espace n'est pas dans `persona1_psp.tbl`**, il s'encode `0x0000`, et le
chercher dans la table rend `nil` — les sept témoins paraissaient absents.

**Critère de sortie :** atteint.

---

## Étape 3 — Notre propre relecture, outillée  ⬅️ **la suivante**

Avant de faire lire des inconnus, on passe nous-mêmes. Trois passes, dans cet
ordre, parce que chacune rend la suivante moins bruyante.

### 3a. ✅ Les largeurs, mesurées *(03/10/2026)*

Les `[LARGEUR]` du validateur comptaient des caractères. Ça ne pouvait pas
marcher : la police est à chasse variable. `outils/largeur_pixels.py` mesure
désormais chaque ligne avec **la métrique du jeu**, lue dans l'EBOOT aux
emplacements que le moteur **p1es de Zenshou** utilise (`eboot.rb` :
`TABLA_DIALOGO_OFF`, huit octets par caractère, la largeur au `+4`, plus un
pixel d'avance, cinq pixels pour l'espace, et un accent qui hérite de la
métrique de sa lettre de base).

La limite n'est pas inventée non plus : l'anglais d'origine tient forcément,
donc sa ligne affichée la plus large est une borne observée — 375 px en
dialogues, 568 en négociations, 373 dans l'EBOOT, 344 dans les donjons.

Contrôle contre une capture réelle du jeu : la mesure donne 279 px là où la
capture en montre ~297, soit 6 % d'écart — **dans le même sens pour l'anglais et
le français**, et comme la limite vient de l'anglais mesuré pareil, la
comparaison reste exacte.

Sur 14 174 lignes françaises, **quatre dépassaient vraiment**. Corrigées. Les
quatre zones sont à zéro.

La table des largeurs est publiée (`outils/largeurs_glyphes.json`, 334 entiers)
pour que la mesure tourne ici aussi : l'EBOOT, lui, ne sort jamais.

### 3a bis. Les avertissements restants

`check_trad.rb` sort aujourd'hui 597 avertissements. Ils ne bloquent pas, mais
ils ne sont pas du bruit :

| type | nombre | ce que ça veut dire |
|---|---|---|
| `[BUDGET]` | 290 | entrée de l'EBOOT plus longue que l'anglais : elle passe par un code cave. **Ce n'est pas du travail de bureau** — aucun script ne peut dire si le menu est coupé à l'écran, donc c'est une feuille de contrôle pour la beta (étape 5), pas pour ici |
| `[LARGEUR]` | 275 → **90 dans les dialogues** | ligne plus large que l'anglais ; le mur réel est en pixels, pas en caractères, donc chacune demande un œil. L'étape 1 en a résorbé une bonne part au passage |
| `[OCTETS]` | 22 → **3 dans les dialogues** | la ligne pousse son bloc ; à surveiller même après l'étape 1 |
| `[PLACE]` | 9 | négociations : absorbé par les autres fichiers du démon, rien à faire |
| `[TERMINO]` | 1 | faux positif (« Maki Sonomura » signalé comme à aligner sur lui-même) |

### 3b. ✅ Uniformisation des noms — l'outil existe *(03/10/2026)*

C'est le trou le plus net de notre outillage. Deux incohérences réelles ont été
trouvées à la main pendant la dernière campagne, et seulement parce qu'on
cherchait ailleurs :

- « Mirror Shard » : « Éclat de miroir » dans la zone des noms, « Fragment de
  Miroir » dans les dialogues et le dictionnaire ;
- « Expel Mirror » : « Miroir de sortie » contre « Miroir Expel ».

Pour le joueur, ce sont deux objets différents. Aucun validateur ne le voyait,
car chaque fichier est correct **séparément**.

`outils/coherence_noms.py` comble le trou. Il prend les 423 noms de
`trad/noms` comme référence — c'est elle qui nomme l'objet dans l'inventaire —
et les cherche dans les 24 133 lignes traduites des quatre autres zones.

Son contrôle le plus sûr ne devine rien : **le jeu encadre le nom d'un objet**
pour le colorer à l'écran, donc ce qui est dans ce cadre *est* le nom. Comparer
le cadre français au cadre anglais est exact, pas heuristique.

Il a trouvé **sept contradictions** dès le premier passage, toutes dans les
messages « X obtenu », c'est-à-dire juste avant que le joueur ouvre son
inventaire :

| anglais | inventaire | dialogues | qui a raison |
|---|---|---|---|
| Phurba Dagger | Dague phurba | Poignard Phurba | l'inventaire (« Athame Knife » → « Couteau athamé ») |
| Spiegel Mail | Cotte Spiegel | Armure Spiegel | l'inventaire (« Mail Breaker » → « Brise-mailles ») |
| Full Moon Tablet | Plaque pleine lune | Tablette de Pleine Lune | l'inventaire (22 plaques, toutes en minuscules) |
| Scorching Tablet | Plaque brûlante | Plaque Brûlante | l'inventaire (même famille) |
| Bisonskin Drums | Tambours en bison | Tambour de bison | les dialogues (le tambour est en *peau* de bison) |
| Judgement Contract | Contrat de jugement | Contrat du Jugement | les dialogues (le Jugement est un arcane) |
| Stuffed Deer | Cerf en peluche | Cerf empaillé | les dialogues (c'est la blague d'E1_028) |

La règle qui s'en dégage, et qu'on garde : **la famille décide**, pas le dernier
qui a traduit. L'outil tourne maintenant à chaque proposition — pour information,
puisqu'une incohérence naît du rapprochement de deux fichiers dont un seul bouge
— et **bloque** avant la fabrication d'une version.

### 3c. Les passes de langue

- ✅ **Orthographe** *(03/10/2026)* — `outils/relire_fautes.py`. Pas de
  correcteur : aucun ne connaît Kandori, Mikage, SEBEC ni « hi-ho », et sur
  24 572 textes il rendrait des centaines de faux positifs que personne ne
  lirait. Le corpus sert de dictionnaire à lui-même — un vrai mot revient, une
  faute apparaît une fois. On ne cherche pas « à une lettre près » (ça
  rapproche `absurde` et `absurdes`) mais **trois accidents de frappe** :
  inversion de deux lettres, lettre tapée trois fois, apostrophe oubliée.
  Résultat : **douze signalements, deux vraies fautes** — `Commnet` pour
  « Comment » et `soritr` pour « sortir ». Corrigées. Les dix autres étaient
  de vrais mots français (`bougre`/`bouger`, `cirer`/`crier`), consignés dans
  `outils/fautes_tolerees.json` avec leur raison.
  Reste à faire, et ce n'est pas la même chose : **la grammaire** — accords,
  temps, et les fautes sur un mot qui n'a pas de voisin dans le corpus. Il
  faudra un vrai analyseur.
- **Tutoiement et vouvoiement**, par personnage. Nanjo vouvoie, Mark tutoie
  tout le monde, Elly vouvoie les adultes. C'est posé fichier par fichier
  depuis des mois, donc il y a sûrement des flottements — surtout aux endroits
  où deux campagnes se touchent.
- **Les tics de langage** : le « hi-ho » de Jack Frost, le « genre » d'Ayase,
  le « mec » de Mark. Vérifier qu'ils sont tenus de bout en bout.

**Critère de sortie :** zéro `[OCTETS]`, chaque `[LARGEUR]` arbitré, le script
de cohérence des noms écrit et vert, le correcteur passé.

---

## Étape 4 — Les images

Une partie du texte n'est pas dans les scripts : il est gravé dans des
textures. La méthode est tranchée (remplacement de textures PPSSPP, pas de
réinjection dans les `.BIN`) et quatre images sont faites. Détail dans
`game/images/SUIVI_IMAGES.md` du dépôt privé.

Ce qui reste :

- **trier**, et c'est le travail réel. 582 textures HD recensées, dont des
  portraits, des cartes d'arcane et des illustrations qui n'ont aucun intérêt à
  être traduits. Aucune mesure ne les distingue d'une étiquette d'interface. Le
  seul classement fiable est le dossier `Text/` du pack de Ryuubu : 58 images,
  du texte à coup sûr ;
- **écrire la liste des images retenues**, sinon chaque passage des outils
  rend la même liste brute et le tri est à refaire ;
- **vérifier deux largeurs en jeu** : `NOUVELLE PARTIE` fait 118 px contre
  94 px pour `NEW GAME`, et chaque étiquette est dessinée dans un rectangle UV
  calé sur l'encre anglaise. Si c'est coupé, resserrer ou raccourcir.

Cette étape est la seule qui peut avancer **en parallèle** des autres : elle ne
touche ni aux scripts ni à l'ISO.

**Critère de sortie :** la liste des images retenues existe et est versionnée,
et toutes celles du dossier `Text/` sont traduites ou écartées avec une raison.

---

## Étape 5 — Beta fermée, en jeu, avec de vrais joueurs

C'est ici que le projet apprend ce qu'aucune commande ne peut lui dire : est-ce
que ça se lit bien, est-ce que les blagues tombent, est-ce qu'un nom sonne
faux.

**Pas avant l'étape 2 au minimum**, et de préférence après l'étape 3 : faire
tester un texte qu'on sait encore mal relu, c'est gaspiller l'attention des
testeurs sur des fautes qu'on aurait trouvées seuls.

Comment la tenir :

- un petit groupe (cinq à dix personnes) recruté sur le Discord, qui joue avec
  une consigne claire sur ce qu'on cherche ;
- **un patch, jamais l'ISO** : le jeu est sous copyright, on ne distribue que
  la différence ;
- un gabarit d'issue pour les remontées, avec capture d'écran, lieu dans le jeu
  et sauvegarde si possible. Une remontée sans capture coûte une heure à
  retrouver ;
- ce qu'on cherche nommément : du texte coupé à l'écran, un fichier entier
  resté en anglais (symptôme d'un bloc qui déborde encore), un nom d'objet
  incohérent entre deux endroits, un plantage.

**Critère de sortie :** une session complète du jeu par au moins deux
personnes, sans texte coupé ni fichier en anglais.

---

## Étape 6 — Relecture communautaire sur remontées

Les retours de l'étape 5 reviennent dans les fichiers, par petites PR lisibles
plutôt qu'une grande. Chaque correction de largeur ou de longueur repasse par
`budget_blocs.py` : rallonger une réplique peut refaire déborder son bloc, et le
symptôme serait un fichier entier en anglais.

C'est aussi le moment d'ouvrir la relecture à qui veut, par lots, comme on l'a
fait pour la traduction. Relire est une porte d'entrée plus facile que traduire :
pas besoin de connaître les jetons ni les budgets.

**Critère de sortie :** plus aucune remontée ouverte, et le validateur et
`budget_blocs.py` toujours verts.

---

## Étape 7 — La 1.0

- un patch xdelta contre l'ISO Redump **USA `ULUS-10432`**, avec l'empreinte de
  l'ISO de départ écrite noir sur blanc ;
- des notes de version qui disent ce qui est traduit, ce qui ne l'est pas, et
  les limites connues ;
- les crédits : chaque contributeur, nommé. Le suivi garde déjà qui a travaillé
  quel fichier, y compris après fusion ;
- la licence `CC BY-NC-SA 4.0`, déjà en place ;
- un tag et une release GitHub.

---

## Ce qui ne doit pas bouger en chemin

- **Le dépôt privé est la seule source de vérité.** Le public est produit par
  `generer_public.py`, et tout ce qui arrive du public se rapatrie **avant** de
  republier, sinon on écrase le travail fusionné.
- **L'ISO, les `.BIN` et l'EBOOT ne sortent jamais.** Ce sont les fichiers du
  jeu, pas les nôtres.
- **Le nombre de `{SAUT}` suit l'anglais ligne pour ligne.** Le jeu ne renvoie
  jamais à la ligne tout seul.
- **Pas de release avant que la beta soit passée.** Un patch sorti trop tôt
  circule plus longtemps que sa correction.
