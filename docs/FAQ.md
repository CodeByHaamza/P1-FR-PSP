# Questions fréquentes

## Sur la contribution

**Je ne sais pas coder. Je peux quand même aider ?**
Oui, et c'est le but. Tu remplis un champ dans une page web et tu cliques sur un
bouton vert. Aucune ligne de code, aucun logiciel.

**Il me faut le jeu ?**
Non. Le texte anglais est dans les fichiers, tu traduis en le lisant. Avoir joué
aide pour le contexte, mais ce n'est pas obligatoire — et si tu bloques sur une
scène, demande dans ta proposition.

**Combien de temps prend un fichier ?**
Une centaine de répliques, soit deux à quatre heures selon la densité. Tu n'es
pas obligé de le finir d'un coup : propose ce que tu as, indique que c'est en
cours, complète ensuite.

**Est-ce que je peux réserver plusieurs fichiers ?**
Prends-en un. Quand il est fusionné, prends le suivant. Un fichier réservé
depuis trois semaines et jamais rendu bloque tout le monde.

**Quelqu'un travaille déjà sur mon fichier ?**
[SUIVI.md](../SUIVI.md) indique qui est sur quoi, à partir des propositions
ouvertes. Il est recalculé automatiquement.

---

## Sur les refus du robot

**`[JSON] fichier illisible vers la ligne N`**
Le fichier n'est plus un JSON valide : une virgule en trop après la dernière
ligne d'une entrée, un guillemet effacé, un caractère tapé par mégarde après le
`"`. Regarde la ligne indiquée et celles juste avant. Tant que c'est là, le
robot ne peut rien vérifier d'autre.

**`[STRUCTURE] codes attendus [...], obtenus [...]`**
Un code entre accolades a été perdu, ajouté ou déplacé. Compare ta ligne à
l'anglais : ta traduction doit contenir exactement les mêmes, dans le même
ordre. Le plus fréquent : un `{SAUT}` oublié en reformulant.

**`[LARGEUR] 47 car. (debordement certain)`**
Une ligne dépasse la boîte de dialogue. Coupe-la avec un `{SAUT}` ou raccourcis.
La mesure porte sur le texte **entre deux codes**, pas sur la réplique entière.

**`[SLOT] 23 caractères pour un slot de 19`** *(zone `noms` seulement)*
Les noms d'objets, d'armes et de sorts ne vivent pas dans un fichier de texte :
chacun occupe une case de taille fixe dans l'exécutable, et le jeu la trouve en
comptant, pas en suivant un pointeur. Il n'y a donc nulle part où déborder, et
la construction du correctif refuserait. Le nombre après « slot de » est la
place réellement mesurée dans le jeu — souvent plus large que l'anglais :
« Rapier » fait 6 caractères pour 19 disponibles. Raccourcis, et préfère une
tournure courte à une abréviation inventée.

**`[ENCODAGE] X absent(s) de la table`**
Un caractère n'existe pas dans le jeu. Neuf fois sur dix, c'est un guillemet ou
une apostrophe recopiés depuis Word ou un site web. Retape-les.

**`[GLYPHE] X sans dessin dans la police`**
Le caractère existe dans le jeu mais sa case est vide : il s'afficherait comme
un blanc. Remplace-le.

**`[EFFACEMENT] une traduction existante est remplacée par du vide`**
Ta proposition part d'une vieille copie du fichier : des répliques que
quelqu'un a traduites depuis y sont encore vides, et fusionner effacerait son
travail. Ça arrive quand on édite depuis son fork sans l'avoir synchronisé.
Deux remèdes : sur la page de ton fork, **« Sync fork » → « Update branch »**,
puis recopie tes lignes ; ou repars du fichier sur le dépôt principal, où
GitHub crée la proposition à partir de la version à jour.

**`[CANARI] l'anglais d'origine a été modifié`**
Tu as tapé dans `en` ou `locuteur` au lieu de `fr` ou `locuteur_fr`. Restaure
le champ tel qu'il était. Si tu ne sais plus, l'onglet **Files changed** de ta
proposition montre exactement ce qui a bougé.

**`[TERMINO] « X » se traduit « Y » (dictionnaire)`**
Un terme validé apparaît dans l'anglais, mais sa traduction officielle n'est
pas dans ton français. **Ça ne bloque rien** — c'est une question. Si tu as
reformulé exprès, ou si le mot n'avait pas sa place, dis-le en un mot dans ta
proposition. Le but est d'éviter qu'un même nom soit traduit de trois façons
dans le jeu, pas de te forcer à répéter un mot là où le français n'en veut pas.

**`+55 px (430 px) ... ` dans « Largeur des lignes »**
Ta ligne est plus large que la boîte. Ce n'est pas un comptage de caractères,
c'est une **mesure** : la police du jeu est à chasse variable, donc `WWWWW` et
`iiiii` n'occupent pas la même place, et la règle des « 40 caractères » se
trompe dans les deux sens.

La largeur de chaque glyphe est lue dans la table du jeu — celle que le moteur
**p1es de Zenshou** sait localiser dans l'EBOOT — plus un pixel d'avance, et
cinq pixels pour l'espace. Un accent n'ajoute rien à la largeur : il hérite de
la métrique de sa lettre de base, règle donnée par Zenshou et appliquée par le
build.

La limite, elle, ne sort pas d'un chapeau : **l'anglais d'origine tient
forcément**, donc on mesure toutes ses lignes et on prend la plus large. Pour
les dialogues, c'est 375 px — `Holy son of a--Wh-Wh-Wh-What the hell!?`. Si ta
ligne dépasse ça, elle sera coupée à l'écran et le joueur ne saura pas qu'il lui
manque un mot.

Ce message **ne bloque pas** ta proposition ; il bloque la fabrication d'une
version.

**`[TYPO] 'commnet' ×1 → comment ×180 (inversion)`**
Une faute de frappe, trouvée **sans dictionnaire**. Le principe : un vrai mot
revient dans le corpus, une faute n'y apparaît qu'une fois — et il existe
presque toujours, ailleurs, le mot juste à un accident de frappe près.

On ne cherche pas « à une lettre près », ce qui rapprocherait des milliers de
vrais mots (`absurde` et `absurdes`, `agent` et `argent`). On cherche **trois
accidents** : deux lettres voisines échangées (`commnet`), une lettre tapée
trois fois (`sommmes`), une apostrophe oubliée (`Quest-ce`). Entre deux vrais
mots français, ces accidents-là sont rares.

Le corpus est propre depuis le 03/10/2026 : si ce message apparaît sur ta
proposition, c'est qu'elle l'a introduit.

**`[DOUBLON] 'de'`**
Le même mot deux fois de suite. Une ponctuation entre les deux ne compte pas :
« Persona! Persona! » est une emphase, pas une faute.

**`[TYPOGRAPHIE] espace avant ! ou ?`**
Le projet écrit `blague!` et `déjà?`, sans espace — c'est la typographie des
lignes déjà validées en jeu, pas celle du français soigné.

**`[NOM-ENCADRE] X — l'inventaire dit « Y »`**
Un nom d'objet affiché à l'écran ne s'écrit pas comme dans l'inventaire. C'est
le constat le plus sûr des trois, parce qu'il ne devine rien : le jeu **encadre**
le nom d'un objet pour le colorer, et ce qui est dans ce cadre, c'est le nom.
Si le message dit « Poignard Phurba obtenu » et que l'inventaire affiche « Dague
phurba », le joueur cherche deux objets différents. À corriger, toujours — reste
à décider lequel des deux a raison, et c'est **la famille** qui tranche : les
vingt-deux plaques s'écrivent « Plaque … » en minuscules, donc une « Tablette de
Pleine Lune » est fautive même si elle sonne bien.

**`[NOM-CASSE] X — à l'écran : « Y »`**
Même nom, autre écriture : « Plaque Brûlante » contre « Plaque brûlante ». Sans
gravité pour le jeu, visible pour le joueur. On uniformise.

**`[NOM-VARIANTE] X : « A » ×3, « B » ×1`**
Le même nom anglais est rendu de plusieurs façons dans le corpus. Il y a donc
forcément une erreur parmi elles — sauf si l'écart est imposé, et il l'est
parfois : « Masque Reine Neiges » tient dans les dix-neuf caractères de
l'inventaire, « masque de la Reine des Neiges » non, alors qu'en dialogue c'est
la seule forme juste. Ces cas-là se rangent dans `outils/noms_tolerances.json`,
**avec leur raison écrite** : une tolérance sans raison est une incohérence
qu'on a seulement cachée.

**Le robot refuse une ligne que je trouve correcte.**
Ça arrive. Dis-le dans ta proposition ; si l'outil a tort, on le corrige. Il
n'est pas sacré, il est juste plus rapide que nous.

---

## Sur le jeu

**Pourquoi les accents ont-ils été un problème ?**
Le jeu américain n'a pas de glyphes accentués : les cases correspondantes de sa
police sont vides. Il a fallu les dessiner, un par un, dans les atlas de
textures, puis régler leurs métriques. C'est fait — vingt-cinq caractères,
validés en jeu. C'est aussi pour ça qu'on ne les brade pas : écris un vrai
français.

**Pourquoi certaines choses ne sont-elles pas ouvertes à la traduction ?**
Les objets, les armes et les sorts descriptifs ont déjà été arbitrés en privé
(1 427 noms) et attendent d'être reportés dans l'exécutable ; les noms de démons,
de Personae et les sorts signature restent en anglais. Tout le reste est ouvert,
négociations comprises depuis septembre 2026.

**Les aliens parlent en chiffres, c'est normal ?**
Oui. Dans `trad/negociations/ALIEN_*.json`, les démons extraterrestres
s'expriment en suites de chiffres — c'est le jeu d'origine, pas un bug
d'extraction. Ces lignes sont déjà remplies à l'identique, il n'y a rien à
traduire.

**Comment je teste ma traduction en jeu ?**
Tu n'as pas à le faire. Les mainteneurs réinjectent et publient un correctif de
temps en temps. Si tu veux y jouer : il faut posséder le jeu, appliquer le
`.xdelta` sur l'ISO américaine, et activer le remplacement de textures dans
PPSSPP pour les accents.

**Vous distribuez le jeu ?**
Non, jamais. Uniquement un correctif, qui ne sert à rien sans une copie légale.

---

## Sur le projet

**C'est légal ?**
C'est une zone grise, comme toute traduction amateur. Le projet est non
lucratif, ne redistribue aucune donnée du jeu, et sera retiré à la première
demande d'un ayant droit. Atlus et SEGA restent propriétaires du jeu et du
texte anglais.

**Pourquoi le script anglais est-il publié ?**
Parce que c'est la seule façon de traduire à plusieurs sans que chacun
installe une chaîne d'outils complète. C'est la pratique du milieu, et c'est un
choix assumé.

**Qui est derrière ?**
Un projet de fans francophones. La chaîne technique repose largement sur le
travail de **Zenshou**, qui l'a partagée, et de **GarekMallen**. Ils sont
crédités dans le README, et ils le méritent : sans eux, rien de tout ceci
n'existerait.
