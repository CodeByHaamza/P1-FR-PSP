# 📖 Dictionnaire de traduction — Persona 1 PSP (FR)

> **Caractères disponibles.** Tous les accents français s'écrivent normalement :
> `é è ê à â ù û ô î ï ç`, majuscules comprises (`É À Ê Î Ô Ç`). En revanche la
> ligature **`œ` n'existe pas** dans la police du jeu : on écrit « coeur »,
> « oeuvre », « soeur » en deux lettres. Le validateur refuse `œ` (`[ENCODAGE]`).

> [!WARNING]
> **Référence officielle du projet.** Tout traducteur est tenu de la consulter et de la respecter. **Aucun terme non validé** : pour garantir une cohérence parfaite, un terme se traduit **toujours** de la même manière, partout.

**Légende statut :** ✅ validé · 🔶 proposition à valider ensemble · 💬 à débattre

> 🔧 Règle d'or : dès qu'on **choisit** une traduction pour un terme, on l'inscrit ici **immédiatement** (statut ✅), avant même de continuer à traduire.

---

## 🏛️ Concepts & univers

| Anglais | Français | Statut |
|---|---|---|
| Agastya Tree | Arbre Agastya / Agastya | ✅ *(l'arbre-sauvegarde ; forme abrégée sur les étiquettes de carte, 13 caractères pour un budget de 12)* |
| Avidya World | Monde Avidya | ✅ |
| Demon / Demons | Démon / Démons | ✅ |
| Magnetite (Mag) | Magnétite (Mag) | ✅ |
| Persona | Persona — **féminin** : *la* Persona, *une* Persona, *ta* Persona | ✅ |
| Personas | Personae — féminin pluriel : *des Personae neuves* | ✅ *(cohérent avec P2IS)* |
| SEBEC | SEBEC | ✅ *(nom propre conservé)* |
| Shadow / Shadows | Ombre / Ombres | ✅ |
| Snow Queen | Reine des Neiges | ✅ |
| the blue room | la chambre bleue | E2_008.json | ✅ *(description de la Chambre de Velours vue de l'extérieur — « A blue room and a blue piano » ; en minuscules, ce n'est pas le nom du lieu)* |
| Snow Queen Quest | Quête de la Reine des Neiges | ✅ |
| Velvet Room | Chambre de Velours / Velours | ✅ *(forme abrégée sur les étiquettes de carte : 18 caractères pour un budget de 10)* |

## 📍 Lieux

| Anglais | Français | Statut |
|---|---|---|
| Devil's Peak | Pic du Diable | ✅ |
| Lunarvale | Mikage-cho | ✅ *(la PSP a restauré les noms japonais : « Lunarvale » était le nom de la localisation US)* |
| Mikage-cho | Mikage-cho | ✅ *(conserver le toponyme ?)* |
| St. Hermelin High School | Lycée St. Hermelin | ✅ |
| Yamakumo High | Lycée Yamakumo | ✅ |

## 👤 Personnages

> La version **PSP a restauré les noms japonais d'origine** (vs anciens noms US « Revelations »). On part sur les noms **japonais conservés**.

| Anglais / Original | Français | Statut |
|---|---|---|
| Eriko "Elly" Kirishima | Eriko Kirishima | ✅ *(surnom « Elly » ?)* |
| Hidehiko "Brown" Uesugi | Hidehiko Uesugi | ✅ |
| Igor | Igor | ✅ |
| Kei Nanjo | Kei Nanjo | ✅ |
| Kumi | Kumi | ✅ *(nom conservé)* |
| Maki Sonomura | Maki Sonomura | ✅ *(nom conservé)* |
| Mariko Yabe | Mariko Yabe | ✅ *(nom conservé)* |
| Masao "Mark" Inaba | Masao Inaba | ✅ *(garder le surnom « Mark » ?)* |
| Nyarlathotep | Nyarlathotep | ✅ *(nom conservé)* |
| Pandora | Pandore | ✅ *(le boss final ; nom mythologique francisé — cf. « boîte de Pandore », cohérent avec Philémon)* |
| Para Stone | Pierre Para | E2_014.json | ✅ *(sur le modèle des « Pierre Mabufu » / « Pierre Vie » de l'EBOOT)* |
| Philemon | Philémon | ✅ *(accent, cohérent avec P2)* |
| Protagonist (héros) | (nom choisi par le joueur — placeholder) | ✅ |
| Reiji Kido | Reiji Kido | ✅ |
| Takahisa Kandori | Takahisa Kandori | ✅ |
| Trish (PNJ de soin) | Trish | ✅ *(nom conservé)* |
| Tsutomu | Tsutomu | ✅ *(nom conservé)* |
| Yuka Ayase | Yuka Ayase | ✅ |
| Yukino Mayuzumi | Yukino Mayuzumi | ✅ |

## 🗣️ Titres & formules

| Anglais | Français | Statut |
|---|---|---|
| Mr. (homme) | M. | ✅ |
| Ms. / Miss (femme) | Mme / Mlle selon contexte | ✅ |

---

## ⏳ À ajouter au fil de la traduction

*(Démons, sorts, objets, lieux secondaires… On complète ici à mesure qu'on les rencontre.)*

### 🤖 Propositions auto (à valider)

> Zone tampon **remplie par la routine de traduction**. Termes propres importants
> rencontrés mais **pas encore validés** — à relire, corriger, puis remonter dans les
> tables validées ci-dessus (statut ✅). **Statut par défaut : 🔶 (proposition).**

| Anglais | Proposition FR | Vu dans | Statut |
|---|---|---|---|
| affinity | affinité | EBOOT_009.json | ✅ |
| Agastya Tree (locuteur) | Arbre Agastya | E0_001.json, E1_027.json, E3_006.json, E3_008.json, E2_005.json | ✅ *(l'etiquette complete, sur les 14 repliques. Elle coute 3 468 octets — 3 des entrees sont repetees 1 714 fois a elles seules — mais aucun bloc ne deborde pour autant : verifie avec `budget_blocs.py`. L'anglais ecrit `Agastya Tree` 11 fois et `Atastya Tree` 3 fois (coquille de la VO) : les deux portent la meme etiquette francaise)* |
| Aki | Aki | E0_020.json | ✅ |
| Alaya Shrine / Alaya Cavern | Temple Alaya / Grotte Alaya | EBOOT_002.json | ✅ *(« Temple » comme dans P2-FR-IS-PSP)* |
| Ambrosia | Ambroisie | E1_014.json, E1_020.json, E1_025.json | ✅ *(à reporter dans la liste d'objets de l'EBOOT)* |
| bet (casino) | mise | EBOOT_005.json | ✅ |
| big / small reels | grands / petits rouleaux | EBOOT_005.json | ✅ |
| catégories d'armes à feu | Pistolet / Auto / Pompe / Fusil / Balles | EBOOT_012.json | ✅ |
| catégories d'inventaire | Épée 1M / Épée 2M / Lance / Hache / Fouet / Jet / Arc / Poing | EBOOT_012.json | ✅ |
| Cerberus (Persona) | Cerbère | E3_007.json, ETC_002.json | ✅ *(forme française de la localisation officielle : vérifié en jeu dans P3R et P4G. Voir la règle des noms mythologiques plus bas)* |
| Chewing Soul / Bead | conservés | EBOOT_011.json | ✅ *(noms de série, comme Hiranya et Soma)* |
| Chisato Kasai | Chisato Kasai | E2_018.json | ✅ |
| Class 2-4 (salle de classe) | Salle 2-4 | EBOOT_001.json | ✅ *(« Classe » dépasse d'un caractère)* |
| Clerk (locuteur) | Vendeur | EBOOT_010.json, E2_005.json | ✅ *(forme majoritaire des dialogues, boutiques ; « Employé » abandonné le 20/09/2026)* |
| Cloak / Puppet / Counter / Fury / Berserk / Wolf | Voile / Pantin / Riposte / Rage / Berserk / Loup | EBOOT_013.json | ✅ |
| Code Breaker (mini-jeu) | Casse-code | EBOOT_004.json | ✅ |
| Coins | pièces | EBOOT_011.json | ✅ |
| commandes de combat | Coup / Contact / Analyse / Rang / Auto / Fuite / Assaut / Tirer / Don / Persona / Objet / Garde | EBOOT_013.json | ✅ |
| compact | poudrier | E0_020.json | ✅ |
| Crawling Chaos / faceless god | Chaos Rampant / dieu sans visage | E0_017.json | ✅ *(Persona de Kandori = Nyarlathotep)* |
| deadly sins (Lust, Envy…) | Luxure, Envie, Gourmandise, Paresse, Colère, Orgueil | DNG_001.json | ✅ |
| dealer (blackjack) | croupier | EBOOT_005.json | ✅ |
| Death / Occult / Nerve / Prayer / Miracle | Mort / Arcane / Nerf / Prière / Miracle | EBOOT_013.json | ✅ |
| Demon Den / Demon House | Antre / Repaire | EBOOT_011.json | ✅ *(« démon » ne tient ni dans 8 ni dans 10 ; deux mots distincts pour deux lots distincts)* |
| Demon Mirror | miroir des démons | EBOOT_017.json | ✅ *(« Le miroir reconstitué » reste un titre de scène, pas un terme)* |
| Deva System | système Deva | DNG_001.json | ✅ |
| Deva Yuga | Deva Yuga | EBOOT_016.json | ✅ |
| Devil Summoner | Devil Summoner | E0_020.json | ✅ *(conservé tel quel, comme dans P2-FR-IS-PSP)* |
| Devil-Boy | Devil-Boy | E0_006.json (surnom) | ✅ |
| dice game / multiplier | jeu de dés / multiplicateur | EBOOT_004.json | ✅ |
| Dimensional Variable Accelerator System | système accélérateur de variables dimensionnelles | E0_018.json | ✅ *(l'acronyme « Deva » ne se reforme pas en français — nom propre conservé)* |
| Dis-Sick / Dis-Poison | Anti-Mal / Antipoison | EBOOT_011.json | ✅ |
| Divine Voice / Millionaire Bomb | Voix Divine / Bombe Million | EBOOT_011.json | ✅ |
| Dr. Nicholai | Dr. Nicholai | E2_018.json | ✅ |
| Dream World | Monde des Rêves | E1_008.json | ✅ |
| Electric / Nuclear / Blast / Gravity | Élec / Atome / Éclat / Gravité | EBOOT_013.json | ✅ |
| Element / Force (types) | Élément / Force | EBOOT_007.json | ✅ |
| Element / Force / Dark / Light (types) | Élément / Force / Noir / Blanc | EBOOT_013.json | ✅ *(« Noir / Blanc » fait paire en français et tient dans 4 et 5, contrairement à « Ombre / Lumière »)* |
| emplacements d'armure | Tête / Corps / Bras / Jambes | EBOOT_012.json | ✅ |
| EX-File / EX-Files | EX-File / EX-Files | WORM_009.json, KEMONO_009.json | ✅ *(clin d'oeil à X-Files, dont le titre reste « X-Files » en français : traduire casserait la blague)* |
| Erusaer Tsymmom (formule inversee d'Aki = "Mommys Treasure") | Namam ed Rosert ("Tresor de maman" inverse) | E0_018.json | ✅ |
| essence(s) | essence(s) | E0_025.json | ✅ |
| Estoma / Traesto | gardes (sorts signature : fuite/teleport) | names_eboot.json | ✅ |
| états de combat | Joie / Affolé / Charmé / Gelé / Choc / Lié / Dort / Muet / Cécité / Poisse / Effroi / Faute / Poison / Paralysé / Pierre / Mal / KO | EBOOT_013.json | ✅ |
| Eternal Night | Nuit Éternelle | E1_023.json, DNG_002.json, EBOOT_017.json | ✅ *(⚠️ **la majuscule et l'accent comptent** : c'est le nom de l'évènement. Sept lignes portaient « nuit éternelle », « nuit Eternelle » ou « Nuit Eternelle » — unifiées le 01/10/2026)* |
| Expel / Curse / Bless | conservés | EBOOT_013.json | ✅ *(éléments signature, cf. « Miroir Expel »)* |
| Expel Mirror | Miroir Expel | EBOOT_016.json | ✅ *(sort signature gardé. ⚠️ E2_017 disait « miroir d'Expulsion » sur trois lignes et « Miroir Expel » sur deux autres, dans le même fichier — unifié le 01/10/2026)* |
| Extra Game | partie bonus | EBOOT_007.json | ✅ |
| Fever Crown / Core Shield | Couronne / Bouclier | EBOOT_011.json | ✅ *(le qualificatif ne tient pas dans 10)* |
| Fire / Death (sous-types) | Feu / Mort | EBOOT_007.json | ✅ |
| Fire / Ice / Wind / Earth | Feu / Gel / Vent / Terre | EBOOT_013.json | ✅ *(« Glace » ne tient pas dans 3)* |
| fusion accident | accident de fusion | EBOOT_008.json | ✅ |
| gem(s) | gemme(s) | E0_025.json | ✅ |
| Gingerbread House | Pain d'épice | EBOOT_002.json | ✅ |
| Girl in black (locuteur) | Fille en noir | E0_018.json | ✅ *(cohérent avec « Girl in white » → Fille en blanc)* |
| Girl under attack (locuteur) | Fille attaquée | E0_020.json | ✅ |
| Guided Fusion / Manual Fusion | fusion guidée / fusion libre | EBOOT_003.json, EBOOT_007.json | ✅ |
| Gun / Shoot | Tir / Tirer | EBOOT_014.json, EBOOT_013.json | ✅ *(« Feu » entrerait en collision avec l'élément Feu)* |
| Harem Queen | Reine du Harem | E2_018.json | ✅ |
| Hariti | Hariti | EBOOT_003.json | ✅ *(démon, nom conservé)* |
| Harried girl / Restless boy (locuteurs) | Fille affolée / Garçon agité | E0_019.json | ✅ |
| haunted mansion | manoir hante | E0_020.json | ✅ |
| Himeno Mansion | Manoir Himeno | EBOOT_016.json | ✅ |
| Hiranya / Soma | gardes (items signature serie) | names_eboot.json | ✅ |
| Historical Society / Convenience Store | Société d'histoire / Supérette | EBOOT_014.json | ✅ |
| Hit / Stand / Double Down / Split | Tirer / Rester / Doubler / Split | EBOOT_005.json | ✅ *(Split gardé faute de place)* |
| HP / SP | HP / SP | EBOOT_016.json | ✅ *(convention de la série en français, et déjà en jeu dans les fichiers traduits)* |
| HP / SP Incense | Encens HP / Encens SP | EBOOT_011.json | ✅ |
| Hypnos | Hypnos | E1_008.json | ✅ |
| Sir Hypnos | Sire Hypnos | E1_010.json | ✅ *(Kumi ne l'appelle jamais autrement, c'est tout son rapport au personnage. Le titre tombait dans E1_013 et perdait sa majuscule dans E1_010)* |
| Hypnos / Nemesis / Thanatos Chamber | Salle Hypnos / Némésis / Thanatos | EBOOT_001.json | ✅ |
| Hypnos / Nemesis / Thanatos Tower | Tour Hypnos / Némésis / Thanatos | E1_014.json, EBOOT_017.json, EBOOT_023.json | ✅ *(majuscule à « Tour » : c'est le nom du lieu. Pas de « Tour de X », proposé sur le Discord : le slot du nom de lieu dans EBOOT_001 fait 11 à 13 caractères, « Tour de Thanatos » en fait 16 — il faudrait le code cave sur les trois libellés les plus visibles du jeu)* |
| Ice Castle | Château de Glace / Glace | E1_023.json, EBOOT_002.json | ✅ *(forme abrégée sur les étiquettes)* |
| Infirmary / Lab | Infirmerie / Labo | EBOOT_001.json | ✅ *(dépassent d'un caractère, sans équivalent plus court)* |
| Injured boy (locuteur) | Garçon blessé | E0_020.json | ✅ |
| insurance bet | assurance | EBOOT_005.json | ✅ |
| Journey to the West | Voyage vers l'Ouest | DNG_001.json (énigme) | ✅ |
| Kandori | Kandori | E0_005.json | ✅ |
| Kenta (garcon amoureux d'Ayase) | Kenta | E3_003.json | ✅ |
| Khamenturun / Turunkhamen / Mannequin | noms conservés | EBOOT_010.json | ✅ |
| Kumi Hirose | Kumi Hirose | E1_008.json | ✅ |
| Longinus / Gleipnir / Gae Bolg / Brionac / Kusanagi / Fang Tian Huaji / Claimh Solais / Megin Gjord | gardes (armes mythologiques reelles) | names_eboot.json | ✅ |
| Lost Forest | Forêt perdue / Forêt | EBOOT_002.json, EBOOT_014.json | ✅ *(forme abrégée sur les étiquettes)* |
| magical girl | fille magique | E0_020.json | ✅ |
| Mai (fillette magique) | Mai | E0_020.json | ✅ |
| main type / subtype | type principal / sous-type | EBOOT_008.json | ✅ |
| mains de poker | 2 paires / Brelan / Suite / Flush / Full / Carré / Quinte flush / Cinq pareils / Flush royal | EBOOT_006.json | ✅ *(« Flush » gardé : « Couleur » nomme déjà le jeu Red & Black)* |
| Mana Castle | Château Mana / Mana | EBOOT_002.json, EBOOT_014.json | ✅ *(forme abrégée sur les étiquettes)* |
| "many worlds" theory | théorie des « mondes multiples » | E0_020.json | ✅ |
| Masao / Kei | Masao / Kei | E0_006.json | ✅ |
| Medicine | Remède | EBOOT_011.json | ✅ |
| Metal Card | Carte Métal / Métal | EBOOT_011.json | ✅ *(forme courte sur les lots du casino, où le budget est de 10)* |
| N yen | N yens, séparateur par espace : « 2 000 yens » | E2_008.json, E2_017.json | ✅ *(forme déjà en jeu dans E2_017 ; les autres montants de Trish suivent)* |
| Michiko (Reine de la tour Hypnos) | Michiko | E1_017.json | ✅ *(nom conservé)* |
| Mikage-cho 1st Ward | Mikage-cho quartier 1 | EBOOT_014.json | ✅ |
| Mirror Shard | Fragment de Miroir | E1_014.json, E1_017.json, DNG_002.json | ✅ *(cohérent avec « megalith shard » → « fragment de mégalithe », E0_002)* |
| moon phase | phase de la lune | EBOOT_009.json | ✅ |
| Ms. Saeko (enseignante) | Mme Saeko | E1_023.json | ✅ |
| Mysterious butterfly | Papillon mysterieux | E0_005.json | ✅ |
| Nanjo Group | groupe Nanjo | E0_017.json | ✅ |
| Nemesis (déesse / Persona) | Némésis | E1_002.json, E1_018.json | ✅ *(orthographe française du nom grec ; le dépôt l'écrivait déjà ainsi dans E1_018 et « Nemesis » partout ailleurs — unifié le 29/09/2026)* |
| Night Queen (Persona/masque) | Reine de la Nuit | E1_023.json | ✅ |
| noms mythologiques des énigmes | conservés (Seiryuu, Airgetlam, Verdandi, Susano-o…) | DNG_001.json | ✅ |
| Nurse Natsumi | Natsumi (infirmiere) | E0_006.json | ✅ |
| Order / Type (fusion de cartes) | Ordre / Type | EBOOT_016.json | ✅ |
| Orthrus (Persona) | Orthros | ETC_002.json | ✅ *(forme française du nom grec ; c'est le frère de Cerbère, les deux doivent suivre la même règle)* |
| Pandora's Nest | Nid de Pandore | EBOOT_002.json | ✅ |
| parallel world | monde parallèle | E0_020.json | ✅ |
| Petra / Para / Poisma / Nerve / Posumudi / Paraladi / Petradi / Nervundi | gardes (prefixes sorts de soin statut) | names_eboot.json | ✅ |
| Physical / Magical Guard | Garde Physique / Garde Magique | EBOOT_011.json | ✅ |
| Platinum Queen / Seventh Coat | Reine Platine / Manteau 7 | EBOOT_011.json | ✅ |
| potential | potentiel | EBOOT_009.json | ✅ |
| President Saeki | président Saeki | E0_017.json | ✅ |
| Principal Ooishi | Proviseure Ooishi | E0_002.json, E0_006.json | ✅ *(c'est une femme : « ever since I was a girl »)* |
| Vice-Principal Hanya | Proviseur adjoint Hanya | E0_011.json | ✅ *(« vice-proviseur » est un calque : en lycée c'est proviseur adjoint. Une autre ligne du dictionnaire portait « Vice-proviseur Hanya » — meme terme, deux formes : celle-ci fait foi)* |
| Principal Hanya / Vice-Principal Ooishi | Proviseur Hanya / Proviseure adjointe Ooishi | E1_007.json | ✅ *(⚠️ **ce n'est pas une coquille de la VO**. Le bloc `E1.BIN:048` est un reve ou les deux roles sont inversés, et le dialogue le dit : Nanjo « ici, les roles sont inversés », Brown « Hanya est le proviseur et Ooishi l'adjointe!? ». Hors du reve, Ooishi est la proviseure et Hanya son adjoint)* |
| Principal's Office | Bureau du proviseur | EBOOT_001.json | ✅ |
| Queen Asura | Reine Asura | EBOOT_017.json | ✅ |
| races de démons (Genma, Megami, Kishin, Yoma, Fiend, Tyrant…) | conservées en anglais | EBOOT_013.json, EBOOT_015.json | ✅ *(même politique que les noms de démons)* |
| Raiho | Raiho | E1_020.json | ✅ |
| rank (d'un Persona) | rang | EBOOT_009.json | ✅ |
| Rattle Drink / Muscle Drink | Fiole Rattle / Fiole Force | EBOOT_011.json | ✅ *(« Rattle » gardé : son effet n'a pas été vérifié en jeu, un nom opaque vaut mieux qu'un contresens)* |
| Red & Black / Big & Small / High & Low | Couleur / Haut & Bas / Plus haut | EBOOT_007.json | ✅ *(noms des jeux du casino, budgets de 8 à 9 caractères)* |
| Reiho | Reiho | E1_020.json | ✅ |
| Rosa Candida / Satomi Tadashi / Sennen Mannen-Do | noms conservés (boutiques) | EBOOT_016.json | ✅ |
| Sea of Souls | Mer des Âmes | EBOOT_017.json | ✅ |
| second-year student | élève de première | E0_019.json | ✅ *(équivalence scolaire FR ; 2e année du lycée japonais)* |
| security card | carte de sécurité | E0_016.json | ✅ |
| Set (lot du casino) | Lot | EBOOT_011.json | ✅ |
| Setsuko Sonomura | Setsuko Sonomura | E0_005.json | ✅ |
| Hiremon Stone | Pierre Hiremon | E2_008.json | ✅ *(le mégalithe du lycée, exhumé en 1963 ; « Hiremon » est l'abrégé de St. Hermelin, conservé)* |
| skill (commande de combat) | don | EBOOT_013.json, EBOOT_015.json | ✅ *(distinct de `power` → pouvoir et de `spell` → sort, qui se disputaient le mot)* |
| skill (d'un Persona) | pouvoir | EBOOT_008.json, EBOOT_010.json | ✅ *(« compétence » ne tient pas dans les budgets)* |
| skill inheritance | héritage des pouvoirs | EBOOT_008.json | ✅ |
| Snow Queen (masque) | Reine des Neiges | E0_006.json | ✅ |
| spell card(s) | carte(s) de sort | E0_025.json | ✅ |
| sports festival | festival sportif | E0_001.json, E0_019.json | ✅ *(festival scolaire japonais)* |
| Stern-faced man (locuteur) | Homme sévère | E0_017.json | ✅ *(cohérent avec « Voix sévère », DNG_001)* |
| Stone (objet conso, ex: Agidyne Stone) | Pierre (mot ajoute apres le sort garde) | names_eboot.json | ✅ |
| Student Council Room | Conseil des élèves | EBOOT_001.json | ✅ |
| Robed man | Homme en toge | E1_009.json | ✅ *(Hypnos avant qu'il se nomme ; suit la forme des autres locuteurs descriptifs, « Homme en noir », « Vieil homme en livrée »)* |
| Policeman's spirit | Esprit du policier | E2_006.json | ✅ *(cf. « Esprit d'élève »)* |
| Nurse Natsumi's boyfriend | Copain de Natsumi | E1_008.json | ✅ |
| Rumor-loving student | Amateur de ragots | E2_008.json | ✅ |
| SEBEC employee / Angry SEBEC employee | Employé SEBEC / Employé furieux | E2_008.json | ✅ |
| Cheerful schoolgirl | Élève enjouée | E1_021.json | ✅ |
| Kaneda / Katsue / Kiichi | Kaneda / Katsue / Kiichi | E2_006.json, E2_017.json | ✅ *(patronymes conservés)* |
| Night Queen's voice | Voix de la Reine de la Nuit | E1_030.json | ✅ *(⚠️ portait « Voix de la Reine », **comme la Reine des Neiges** : deux personnages sous un seul nom, alors que la Reine des Neiges annonce elle-même qu'elle part l'invoquer. Corrigé le 01/10/2026)* |
| Succubus (Persona) | Succube | ETC_002.json | ✅ *(nom commun français ; « Succubus » est le latin)* |
| Suspicious-looking man (locuteur) | Homme suspect | E0_017.json | ✅ *(cohérent avec « Voix suspecte », DNG_001)* |
| Tablet (objet conso, ex: Evil Fire Tablet) | Plaque (+ Maudit/e si "Evil") | names_eboot.json | ✅ |
| Takeda | Takeda | DNG_001.json | ✅ |
| Tartarus | le Tartare | E3_007.json | ✅ *(le nom français du lieu des Enfers grecs, et Persona 3 en français dit aussi « le Tartare ». La réplique d'Elly parle explicitement de mythologie grecque : le nom français y fait son effet)* |
| Terra / Luna | Terra / Luna | E0_025.json (fusion) | ✅ |
| the Tailors (bande de Mark) | les Tailors | E0_016.json | ✅ *(nom de bande conservé)* |
| time slip | saut dans le temps | E0_019.json | ✅ |
| Tomomi | Tomomi | E1_023.json | ✅ |
| Toro | Toro | E1_017.json | ✅ *(nom conservé)* |
| Totem | Totem | E1_020.json | ✅ |
| totem | totem | EBOOT_009.json | ✅ |
| Trish | Trish | E0_025.json | ✅ |
| Tsutomu Kurouri | Tsutomu Kurouri | E0_006.json | ✅ |
| Vice-Principal Hanya | Proviseur adjoint Hanya | E0_006.json | ✅ *(forme unique, cf. la ligne du tableau alphabetique)* |
| world after death | le monde qui succède à la mort | E3_007.json | ✅ *(attention à la construction : succéder **à**. Forme courte quand la boîte est serrée : « l'au-delà »)* |
| Yamaoka | Yamaoka | E1_020.json | ✅ |
| Yosuke | Yosuke | E2_018.json | ✅ |
| Yosuke Naito | Yosuke Naito | E0_019.json | ✅ |
| Young man (locuteur) | Jeune homme | E0_027.json | ✅ |
| Yuka / Yuko | Yuka / Yuko | E0_006.json | ✅ |

---

## ＊marqueurs d'action＊

Le jeu note certaines actions entre `＊` pleine largeur : `＊sigh＊`, `＊gasp＊`.
Ce sont des **mots**, pas des codes : ils se traduisent. Mais un même mot anglais
doit toujours donner le même mot français, sinon le joueur croit à deux gestes
différents. Une forme par marqueur, sans exception :

| anglais | français | anglais | français |
|---|---|---|---|
| ＊ahem＊ | ＊hum＊ | ＊shiver＊ / ＊shudder＊ | ＊frisson＊ |
| ＊bleep＊ | ＊biiip＊ | ＊sigh＊ | ＊soupir＊ |
| ＊blub＊ / ＊glub＊ | ＊glub＊ | ＊smirk＊ / ＊snort＊ | ＊ricane＊ |
| ＊blush＊ | ＊rougit＊ | ＊sniffle＊ | ＊snif＊ |
| ＊cough＊ | ＊tousse＊ | ＊sob＊ | ＊sanglot＊ |
| ＊crackle＊ | ＊grésille＊ | ＊splat＊ | ＊splat＊ |
| ＊gasp＊ | ＊hoquet＊ | ＊squeal＊ | ＊cri＊ |
| ＊giggle＊ | ＊pouffe＊ |  |  |
| ＊hic＊ | ＊hic＊ | ＊urrrrp＊ | ＊rrrot＊ |
| ＊gulp＊ / ＊glug＊ / ＊ulp＊ | ＊gloup＊ / ＊glou＊ / ＊oulp＊ | ＊shriek＊ | ＊hurle＊ |
| ＊pant＊ / ＊huff＊ | ＊halète＊ | ＊whimper＊ / ＊whine＊ | ＊gémit＊ |
| ＊puke＊ / ＊gag＊ | ＊vomit＊ | ＊whistle＊ | ＊sifflement＊ |
| ＊hack＊ | ＊râle＊ | ＊dreamy sigh＊ | ＊soupir rêveur＊ |
| ＊ring＊ | ＊dring＊ | ＊yawn＊ | ＊bâille＊ |
|  |  | ＊yip＊ | ＊ouaf＊ |

**Une seule exception, et elle est voulue : `＊sniff＊` a deux sens en jeu.**
Sur les 18 lignes qui le portent, le flair n'en concerne que deux : « I can
smell lies » (la replique de HIHO, dupliquee 8 fois) et « I can smell demons »
(SYOUJO). Partout ailleurs le personnage pleure.
Quand le personnage pleure, c'est `＊snif＊` ; quand il flaire (« I can smell
lies »), c'est `＊renifle＊`. Le contexte tranche.

⚠️ **Le nombre de marqueurs doit suivre l'anglais.** Sept lignes en avaient
perdu ou ajoute un : `＊gasp＊ You couldn't have...!` etait devenu
« Oh... C'est impossible...! », geste efface.

⚠️ Les `＊` allongés suivent l'anglais : `＊siiigh＊` → `＊souuupir＊`.

⚠️ **Une seule ligne porte trois gestes anglais différents d'affilée** :
`E1.BIN:081:0010` a `＊cough＊ ＊gag＊ ＊puke＊`. Comme le tableau fait tomber
`＊gag＊` et `＊puke＊` sur le même `＊vomit＊`, le français y écrit
`＊tousse＊ ＊suffoque＊ ＊vomit＊` : trois gestes pour trois gestes, sans répéter
`＊vomit＊`. C'est la seule exception, et elle s'arrête à cette ligne.

⚠️ Une seule ligne a deux marqueurs français pour un seul anglais, et c'est
voulu : `HIHO.BIN:text:0609` porte `＊huff ＊huff＊` dans la VO, où il manque
un `＊`. Le français écrit les deux.

⚠️ `＊I＊` n'est pas une action mais une **emphase** sur le mot : il faut
souligner le mot français correspondant, pas recopier le mot anglais.

## 🏷️ Noms de l'EBOOT (objets / armes / armures / sorts / démons / Personae)

Source : EBOOT **déchiffré**, extraits par `game/tools/_ancien_pipeline/p1_names.py` (ancien pipeline) → `game/scripts/names/names_eboot.json`
(`{off, en, max, fr}`). **Politique de traduction validée (convention série) :**

- ✅ **Traduire** : objets, objets-clés, armes, armures, accessoires, **sorts descriptifs**
  (« Crystal Wall », « Hell Drop »…).
- 🚫 **GARDER en anglais** : les **sorts signature** de la série (Agi, Bufu, Garu, Zio,
  Dia, Mudo, Hama…), et les noms de **démons et de Personae qui n'ont pas de forme
  française consacrée** — noms inventés (Captain Kidd), noms japonais (Seimen Kongou),
  créatures dont le nom anglais *est* le nom de série (Pixie, Lilim).
- ✍️ **TRADUIRE** en revanche les noms de **figures mythologiques qui ont une forme
  française établie** : `Cerberus` → **Cerbère**, `Nemesis` → **Némésis**,
  `Succubus` → **Succube**, `Orthrus` → **Orthros**. C'est ce que fait la localisation
  française officielle — @Uolil-Raccoon a vérifié Cerbère en jeu dans P3R **et** P4G —
  et le dépôt le faisait déjà sans le dire (`Cupid` → Cupidon dans E1_011, `Hades` →
  Hadès dans ETC_002, `Angel` → Anges dans EBOOT_018). Les noms sanskrits et japonais
  s'écrivent pareil en français et ne posent pas la question (Kali, Shiva, Ganesha,
  Garuda, Izanagi, Susano-o).
  ⚠️ Un nom changé ici doit l'être **aussi** dans la zone des noms du dépôt privé,
  sinon le joueur lit « Cerbère » en dialogue et « Cerberus » à l'écran de fusion.
  Ce sont **`names_fr.json` et `names_todo.json`** qu'il faut modifier, tous les deux :
  `names_eboot.json` n'est lu que comme inventaire des 7 444 champs de la zone, son `fr`
  n'est jamais utilisé. Les deux vont ensemble parce que `be2_phrases.py` garde une entrée
  privée si elle porte une traduction dans `names_fr.json` **ou** si elle est à `[]` dans
  `names_todo.json` : n'en remplir qu'un seul republierait le nom au public.
  **Fait** pour `Némésis` (7 champs), `Succube` (2) et `Orthros` (1) — sortie publique
  vérifiée identique après coup. `Cerberus` **n'est pas dans la zone des noms** : il
  n'apparaît qu'en dialogue, donc rien à répercuter pour lui. Les trois formes reportées
  font 7 glyphes, dont un champ plafonné à 7 : elles tiennent.
- ⚠️ Contrainte technique : le FR doit **tenir dans la longueur du champ EN** (`max`).
  Noms multi-mots = plusieurs champs (slots fixes) → l'ordre des mots suit l'anglais
  pour l'instant (cf. `game/PERIMETRE.md`, format des records à finir de reverser).
- Pour **garder** un nom : laisser `fr` vide. Pour **traduire** : remplir `fr` (accents
  compris — ils sont supportés depuis le chantier « police » — dans la limite de `max`
  caractères).
