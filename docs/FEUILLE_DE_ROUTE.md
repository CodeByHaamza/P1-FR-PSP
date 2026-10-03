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

## Étape 1 — Rognage des blocs qui débordent

**C'est le verrou.** Rien d'autre ne peut avancer avant.

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

**Par quoi commencer.** Un levier rend beaucoup pour peu d'effort : les
étiquettes de locuteur. `locuteur_fr` est écrit une fois par réplique, donc
« Proviseur adjoint Hanya » (23 caractères) contre « Vice-Principal Hanya » (20)
coûte trois caractères **à chaque ligne du personnage**. Le bloc 066 d'`E1.BIN`,
le pire du lot, est en grande partie payé par Hanya et Ooishi. Raccourcir une
étiquette répare des dizaines de lignes d'un coup, sans toucher au dialogue.
`budget_blocs.py` signale ce coût ligne par ligne.

Ensuite seulement, raccourcir les répliques elles-mêmes, en commençant par les
blocs lourds.

**Critère de sortie :** `budget_blocs.py` finit par « aucun bloc en surplus ».

---

## Étape 2 — Construire l'ISO et le vérifier à la machine

Une fois les blocs rentrés dans leurs frontières, la chaîne complète peut
tourner pour la première fois avec les cinq zones à 100 % :

1. `p1es_apply.rb` cinq fois, une par zone, chacune lisant la sortie de la
   précédente ;
2. `p1es/build.rb` pour reconstruire l'ISO ;
3. `verif_iso.py` pour comparer l'ISO produite à l'originale.

Ce qu'on cherche ici n'est pas « est-ce beau », c'est « est-ce que le texte
français est bien arrivé » : aucun fichier retombé en anglais, le compte de
lignes françaises conforme, la taille et la structure de l'ISO saines.

**Critère de sortie :** `verif_iso.py` passe, et un relevé des octets du jeu
construit montre du français dans chacune des cinq zones.

---

## Étape 3 — Notre propre relecture, outillée

Avant de faire lire des inconnus, on passe nous-mêmes. Trois passes, dans cet
ordre, parce que chacune rend la suivante moins bruyante.

### 3a. Les avertissements du validateur

`check_trad.rb` sort aujourd'hui 597 avertissements. Ils ne bloquent pas, mais
ils ne sont pas du bruit :

| type | nombre | ce que ça veut dire |
|---|---|---|
| `[BUDGET]` | 290 | entrée de l'EBOOT plus longue que l'anglais : elle passe par un code cave, qui marche mais demande une vérification en jeu |
| `[LARGEUR]` | 275 | ligne plus large que l'anglais ; le mur réel est en pixels, pas en caractères, donc chacune demande un œil |
| `[OCTETS]` | 22 | la ligne pousse son bloc ; à surveiller même après l'étape 1 |
| `[PLACE]` | 9 | négociations : absorbé par les autres fichiers du démon, rien à faire |
| `[TERMINO]` | 1 | faux positif (« Maki Sonomura » signalé comme à aligner sur lui-même) |

### 3b. Uniformisation du dictionnaire — **il manque un outil**

C'est le trou le plus net de notre outillage. Deux incohérences réelles ont été
trouvées à la main pendant la dernière campagne, et seulement parce qu'on
cherchait ailleurs :

- « Mirror Shard » : « Éclat de miroir » dans la zone des noms, « Fragment de
  Miroir » dans les dialogues et le dictionnaire ;
- « Expel Mirror » : « Miroir de sortie » contre « Miroir Expel ».

Pour le joueur, ce sont deux objets différents. Aucun validateur ne le voit, car
chaque fichier est correct **séparément**. Il faut un script qui prenne chaque
nom d'objet, de sort, d'arme et d'armure de `game/scripts/noms/`, le cherche
dans les dialogues, et signale toute forme française qui ne correspond pas. Tant
qu'il n'existe pas, cette cohérence repose sur la chance.

### 3c. Les passes de langue

- **Orthographe et grammaire** sur les 24 572 textes, avec un correcteur
  automatique (le texte est dans des JSON, donc facile à extraire et à
  réinjecter). Il faudra apprendre au correcteur à ignorer les jetons et les
  noms propres du jeu.
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
