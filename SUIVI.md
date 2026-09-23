# Avancement de la traduction

> Fichier **généré**. Ne pas le modifier à la main : chaque fusion l'écrase.

```text
Dialogues      ████████████░░░░░░░░░░░░   51 %    4 375 / 8 572 textes
EBOOT          ████████████████████████  100 %    2 956 / 2 956 textes
Donjons        ████████████████████████  100 %      130 / 130 textes
Négociations   ██████░░░░░░░░░░░░░░░░░░   23 %    2 914 / 12 487 textes

Total          ██████████░░░░░░░░░░░░░░   43 %   10 375 / 24 145 textes
```

## Poids à surveiller

Ces entrées alourdissent leur fichier. Un bloc qui franchit sa frontière fait rester **tout le fichier en anglais** dans le jeu, sans erreur au build : c'est le plus sournois des avertissements.

- [`E0_024.json`](trad/dialogues/E0_024.json) — 1 entrée
- [`EBOOT_020.json`](trad/eboot/EBOOT_020.json) — 1 entrée

## À relire

Terminologie à confirmer — un terme du dictionnaire apparaît dans l'anglais sans sa traduction officielle dans le français. Ce n'est pas forcément une faute, mais ça mérite un avis.

- [`E1_001.json`](trad/dialogues/E1_001.json) — 1 terme
- [`E1_006.json`](trad/dialogues/E1_006.json) — 1 terme
- [`E2_005.json`](trad/dialogues/E2_005.json) — 1 terme
- [`E3_001.json`](trad/dialogues/E3_001.json) — 1 terme
- [`E3_006.json`](trad/dialogues/E3_006.json) — 1 terme
- [`EBOOT_022.json`](trad/eboot/EBOOT_022.json) — 1 terme
- [`EBOOT_024.json`](trad/eboot/EBOOT_024.json) — 2 termes
- [`EBOOT_025.json`](trad/eboot/EBOOT_025.json) — 2 termes

## Largeur à surveiller

Ces lignes sont plus larges que l'anglaise et approchent de la limite de la boîte. Elles ne débordent pas à coup sûr, mais un `{SAUT}` de plus serait plus sage.

- [`E0_028.json`](trad/dialogues/E0_028.json) — 5 lignes
- [`E0_043.json`](trad/dialogues/E0_043.json) — 1 ligne
- [`E0_044.json`](trad/dialogues/E0_044.json) — 2 lignes
- [`E1_001.json`](trad/dialogues/E1_001.json) — 3 lignes
- [`E1_002.json`](trad/dialogues/E1_002.json) — 1 ligne
- [`E1_009.json`](trad/dialogues/E1_009.json) — 2 lignes
- [`E1_026.json`](trad/dialogues/E1_026.json) — 5 lignes
- [`E1_030.json`](trad/dialogues/E1_030.json) — 3 lignes
- [`E1_031.json`](trad/dialogues/E1_031.json) — 1 ligne
- [`E2_001.json`](trad/dialogues/E2_001.json) — 2 lignes
- [`E2_002.json`](trad/dialogues/E2_002.json) — 2 lignes
- [`E2_005.json`](trad/dialogues/E2_005.json) — 2 lignes
- [`E2_008.json`](trad/dialogues/E2_008.json) — 2 lignes
- [`E2_009.json`](trad/dialogues/E2_009.json) — 1 ligne
- [`E2_015.json`](trad/dialogues/E2_015.json) — 3 lignes
- [`E2_017.json`](trad/dialogues/E2_017.json) — 1 ligne
- [`E3_004.json`](trad/dialogues/E3_004.json) — 1 ligne
- [`E3_005.json`](trad/dialogues/E3_005.json) — 4 lignes
- [`E3_006.json`](trad/dialogues/E3_006.json) — 6 lignes
- [`EBOOT_015.json`](trad/eboot/EBOOT_015.json) — 1 ligne
- [`EBOOT_019.json`](trad/eboot/EBOOT_019.json) — 1 ligne
- [`KUTISAKE_001.json`](trad/negociations/KUTISAKE_001.json) — 1 ligne
- [`KUTISAKE_002.json`](trad/negociations/KUTISAKE_002.json) — 3 lignes
- [`KUTISAKE_003.json`](trad/negociations/KUTISAKE_003.json) — 7 lignes
- [`TENSI_004.json`](trad/negociations/TENSI_004.json) — 4 lignes
- [`YAKUZA_001.json`](trad/negociations/YAKUZA_001.json) — 1 ligne
- [`YAKUZA_002.json`](trad/negociations/YAKUZA_002.json) — 6 lignes

## À vérifier en jeu

Ces lignes dépassent la place que l'anglais occupe dans l'exécutable. Le moteur les redirige vers un espace libre et ça marche — « Charger une partie » le fait déjà — mais c'est plus fragile que de tenir dans le budget. Un coup d'œil à l'écran suffit à confirmer.

- [`EBOOT_001.json`](trad/eboot/EBOOT_001.json) — 5 lignes
- [`EBOOT_002.json`](trad/eboot/EBOOT_002.json) — 2 lignes
- [`EBOOT_003.json`](trad/eboot/EBOOT_003.json) — 14 lignes
- [`EBOOT_004.json`](trad/eboot/EBOOT_004.json) — 1 ligne
- [`EBOOT_010.json`](trad/eboot/EBOOT_010.json) — 10 lignes
- [`EBOOT_011.json`](trad/eboot/EBOOT_011.json) — 5 lignes
- [`EBOOT_012.json`](trad/eboot/EBOOT_012.json) — 15 lignes
- [`EBOOT_013.json`](trad/eboot/EBOOT_013.json) — 5 lignes
- [`EBOOT_014.json`](trad/eboot/EBOOT_014.json) — 20 lignes
- [`EBOOT_015.json`](trad/eboot/EBOOT_015.json) — 21 lignes
- [`EBOOT_016.json`](trad/eboot/EBOOT_016.json) — 7 lignes
- [`EBOOT_017.json`](trad/eboot/EBOOT_017.json) — 1 ligne
- [`EBOOT_018.json`](trad/eboot/EBOOT_018.json) — 17 lignes
- [`EBOOT_019.json`](trad/eboot/EBOOT_019.json) — 8 lignes
- [`EBOOT_020.json`](trad/eboot/EBOOT_020.json) — 4 lignes
- [`EBOOT_021.json`](trad/eboot/EBOOT_021.json) — 27 lignes
- [`EBOOT_022.json`](trad/eboot/EBOOT_022.json) — 2 lignes
- [`EBOOT_023.json`](trad/eboot/EBOOT_023.json) — 5 lignes
- [`EBOOT_024.json`](trad/eboot/EBOOT_024.json) — 1 ligne
- [`EBOOT_025.json`](trad/eboot/EBOOT_025.json) — 10 lignes
- [`EBOOT_026.json`](trad/eboot/EBOOT_026.json) — 23 lignes
- [`EBOOT_027.json`](trad/eboot/EBOOT_027.json) — 16 lignes
- [`EBOOT_028.json`](trad/eboot/EBOOT_028.json) — 17 lignes
- [`EBOOT_029.json`](trad/eboot/EBOOT_029.json) — 22 lignes
- [`EBOOT_030.json`](trad/eboot/EBOOT_030.json) — 29 lignes
- [`EBOOT_031.json`](trad/eboot/EBOOT_031.json) — 5 lignes
- [`EBOOT_032.json`](trad/eboot/EBOOT_032.json) — 2 lignes

## Dialogues

Prends un fichier **libre**, dis-le en ouvrant ta proposition, et il passera en « en cours » dans la minute.

| Fichier | Textes | Traduits | % | État |
|---|---:|---:|---:|---|
| [`E0_001.json`](trad/dialogues/E0_001.json) | 99 | 99 | 100 % | terminé |
| [`E0_002.json`](trad/dialogues/E0_002.json) | 92 | 92 | 100 % | terminé |
| [`E0_003.json`](trad/dialogues/E0_003.json) | 40 | 40 | 100 % | terminé |
| [`E0_004.json`](trad/dialogues/E0_004.json) | 100 | 100 | 100 % | terminé |
| [`E0_005.json`](trad/dialogues/E0_005.json) | 100 | 100 | 100 % | terminé |
| [`E0_006.json`](trad/dialogues/E0_006.json) | 18 | 18 | 100 % | terminé |
| [`E0_007.json`](trad/dialogues/E0_007.json) | 97 | 97 | 100 % | terminé |
| [`E0_008.json`](trad/dialogues/E0_008.json) | 93 | 93 | 100 % | terminé |
| [`E0_009.json`](trad/dialogues/E0_009.json) | 100 | 100 | 100 % | terminé |
| [`E0_010.json`](trad/dialogues/E0_010.json) | 86 | 86 | 100 % | terminé |
| [`E0_011.json`](trad/dialogues/E0_011.json) | 67 | 67 | 100 % | terminé |
| [`E0_012.json`](trad/dialogues/E0_012.json) | 55 | 55 | 100 % | terminé |
| [`E0_013.json`](trad/dialogues/E0_013.json) | 85 | 85 | 100 % | terminé |
| [`E0_014.json`](trad/dialogues/E0_014.json) | 91 | 91 | 100 % | terminé |
| [`E0_015.json`](trad/dialogues/E0_015.json) | 66 | 66 | 100 % | terminé |
| [`E0_016.json`](trad/dialogues/E0_016.json) | 100 | 100 | 100 % | terminé |
| [`E0_017.json`](trad/dialogues/E0_017.json) | 56 | 56 | 100 % | terminé |
| [`E0_018.json`](trad/dialogues/E0_018.json) | 83 | 83 | 100 % | terminé |
| [`E0_019.json`](trad/dialogues/E0_019.json) | 58 | 58 | 100 % | terminé |
| [`E0_020.json`](trad/dialogues/E0_020.json) | 87 | 87 | 100 % | terminé |
| [`E0_021.json`](trad/dialogues/E0_021.json) | 89 | 89 | 100 % | terminé |
| [`E0_022.json`](trad/dialogues/E0_022.json) | 52 | 52 | 100 % | terminé |
| [`E0_023.json`](trad/dialogues/E0_023.json) | 65 | 65 | 100 % | terminé |
| [`E0_024.json`](trad/dialogues/E0_024.json) | 96 | 96 | 100 % | terminé · 1 à alléger |
| [`E0_025.json`](trad/dialogues/E0_025.json) | 93 | 93 | 100 % | terminé |
| [`E0_026.json`](trad/dialogues/E0_026.json) | 77 | 77 | 100 % | terminé |
| [`E0_027.json`](trad/dialogues/E0_027.json) | 40 | 40 | 100 % | terminé |
| [`E0_028.json`](trad/dialogues/E0_028.json) | 78 | 78 | 100 % | terminé par @vikmorp · 5 trop large |
| [`E0_029.json`](trad/dialogues/E0_029.json) | 55 | 5 | 9 % | commencé |
| [`E0_030.json`](trad/dialogues/E0_030.json) | 100 | 100 | 100 % | terminé |
| [`E0_031.json`](trad/dialogues/E0_031.json) | 74 | 6 | 8 % | commencé |
| [`E0_032.json`](trad/dialogues/E0_032.json) | 100 | 11 | 11 % | commencé |
| [`E0_033.json`](trad/dialogues/E0_033.json) | 74 | 74 | 100 % | terminé |
| [`E0_034.json`](trad/dialogues/E0_034.json) | 70 | 1 | 1 % | commencé |
| [`E0_035.json`](trad/dialogues/E0_035.json) | 57 | 10 | 18 % | commencé par @DiCEO0 |
| [`E0_036.json`](trad/dialogues/E0_036.json) | 53 | 5 | 9 % | commencé |
| [`E0_037.json`](trad/dialogues/E0_037.json) | 99 | 4 | 4 % | commencé |
| [`E0_038.json`](trad/dialogues/E0_038.json) | 79 | 1 | 1 % | commencé |
| [`E0_039.json`](trad/dialogues/E0_039.json) | 56 | 1 | 2 % | commencé |
| [`E0_040.json`](trad/dialogues/E0_040.json) | 89 | 2 | 2 % | commencé |
| [`E0_041.json`](trad/dialogues/E0_041.json) | 89 | 0 | 0 % | en cours par @Colonel-Maskou (#48) |
| [`E0_042.json`](trad/dialogues/E0_042.json) | 82 | 0 | 0 % | en cours par @s3rei (#43) |
| [`E0_043.json`](trad/dialogues/E0_043.json) | 100 | 36 | 36 % | en cours par @Colonel-Maskou (#47) · 1 trop large |
| [`E0_044.json`](trad/dialogues/E0_044.json) | 100 | 100 | 100 % | terminé · 2 trop large |
| [`E0_045.json`](trad/dialogues/E0_045.json) | 100 | 30 | 30 % | commencé |
| [`E0_046.json`](trad/dialogues/E0_046.json) | 92 | 12 | 13 % | commencé |
| [`E0_047.json`](trad/dialogues/E0_047.json) | 69 | 2 | 3 % | commencé |
| [`E0_048.json`](trad/dialogues/E0_048.json) | 50 | 50 | 100 % | terminé par @Gyotre, @ATMC14 |
| [`E1_001.json`](trad/dialogues/E1_001.json) | 80 | 77 | 96 % | commencé · 1 terme |
| [`E1_002.json`](trad/dialogues/E1_002.json) | 100 | 99 | 99 % | commencé · 1 trop large |
| [`E1_003.json`](trad/dialogues/E1_003.json) | 94 | 94 | 100 % | terminé |
| [`E1_004.json`](trad/dialogues/E1_004.json) | 87 | 4 | 5 % | commencé |
| [`E1_005.json`](trad/dialogues/E1_005.json) | 81 | 1 | 1 % | commencé |
| [`E1_006.json`](trad/dialogues/E1_006.json) | 77 | 37 | 48 % | commencé · 1 terme |
| [`E1_007.json`](trad/dialogues/E1_007.json) | 97 | 1 | 1 % | commencé |
| [`E1_008.json`](trad/dialogues/E1_008.json) | 74 | 0 | 0 % | en cours par @vikmorp (#51) |
| [`E1_009.json`](trad/dialogues/E1_009.json) | 75 | 27 | 36 % | commencé · 2 trop large |
| [`E1_010.json`](trad/dialogues/E1_010.json) | 63 | 63 | 100 % | terminé |
| [`E1_011.json`](trad/dialogues/E1_011.json) | 87 | 87 | 100 % | terminé |
| [`E1_012.json`](trad/dialogues/E1_012.json) | 83 | 1 | 1 % | commencé |
| [`E1_013.json`](trad/dialogues/E1_013.json) | 60 | 0 | 0 % | en cours par @Uolil-Raccoon (#49) |
| [`E1_014.json`](trad/dialogues/E1_014.json) | 43 | 43 | 100 % | terminé |
| [`E1_015.json`](trad/dialogues/E1_015.json) | 65 | 1 | 2 % | commencé |
| [`E1_016.json`](trad/dialogues/E1_016.json) | 100 | 0 | 0 % | libre |
| [`E1_017.json`](trad/dialogues/E1_017.json) | 38 | 38 | 100 % | terminé |
| [`E1_018.json`](trad/dialogues/E1_018.json) | 100 | 0 | 0 % | libre |
| [`E1_019.json`](trad/dialogues/E1_019.json) | 46 | 1 | 2 % | commencé |
| [`E1_020.json`](trad/dialogues/E1_020.json) | 67 | 3 | 4 % | commencé |
| [`E1_021.json`](trad/dialogues/E1_021.json) | 66 | 0 | 0 % | libre |
| [`E1_022.json`](trad/dialogues/E1_022.json) | 95 | 0 | 0 % | libre |
| [`E1_023.json`](trad/dialogues/E1_023.json) | 96 | 9 | 9 % | commencé |
| [`E1_024.json`](trad/dialogues/E1_024.json) | 93 | 1 | 1 % | commencé |
| [`E1_025.json`](trad/dialogues/E1_025.json) | 86 | 0 | 0 % | libre |
| [`E1_026.json`](trad/dialogues/E1_026.json) | 97 | 97 | 100 % | terminé · 5 trop large |
| [`E1_027.json`](trad/dialogues/E1_027.json) | 89 | 8 | 9 % | commencé |
| [`E1_028.json`](trad/dialogues/E1_028.json) | 79 | 79 | 100 % | terminé |
| [`E1_029.json`](trad/dialogues/E1_029.json) | 99 | 23 | 23 % | commencé |
| [`E1_030.json`](trad/dialogues/E1_030.json) | 96 | 96 | 100 % | terminé · 3 trop large |
| [`E1_031.json`](trad/dialogues/E1_031.json) | 97 | 28 | 29 % | commencé · 1 trop large |
| [`E2_001.json`](trad/dialogues/E2_001.json) | 95 | 29 | 31 % | commencé · 2 trop large |
| [`E2_002.json`](trad/dialogues/E2_002.json) | 100 | 39 | 39 % | commencé · 2 trop large |
| [`E2_003.json`](trad/dialogues/E2_003.json) | 96 | 7 | 7 % | commencé |
| [`E2_004.json`](trad/dialogues/E2_004.json) | 97 | 4 | 4 % | commencé |
| [`E2_005.json`](trad/dialogues/E2_005.json) | 92 | 92 | 100 % | terminé · 1 terme |
| [`E2_006.json`](trad/dialogues/E2_006.json) | 92 | 32 | 35 % | commencé |
| [`E2_007.json`](trad/dialogues/E2_007.json) | 99 | 7 | 7 % | commencé |
| [`E2_008.json`](trad/dialogues/E2_008.json) | 99 | 39 | 39 % | commencé · 2 trop large |
| [`E2_009.json`](trad/dialogues/E2_009.json) | 97 | 36 | 37 % | commencé · 1 trop large |
| [`E2_010.json`](trad/dialogues/E2_010.json) | 97 | 0 | 0 % | libre |
| [`E2_011.json`](trad/dialogues/E2_011.json) | 90 | 0 | 0 % | libre |
| [`E2_012.json`](trad/dialogues/E2_012.json) | 91 | 4 | 4 % | commencé |
| [`E2_013.json`](trad/dialogues/E2_013.json) | 88 | 0 | 0 % | libre |
| [`E2_014.json`](trad/dialogues/E2_014.json) | 95 | 36 | 38 % | commencé |
| [`E2_015.json`](trad/dialogues/E2_015.json) | 91 | 91 | 100 % | terminé · 3 trop large |
| [`E2_016.json`](trad/dialogues/E2_016.json) | 100 | 3 | 3 % | commencé |
| [`E2_017.json`](trad/dialogues/E2_017.json) | 80 | 37 | 46 % | commencé · 1 trop large |
| [`E3_001.json`](trad/dialogues/E3_001.json) | 93 | 14 | 15 % | commencé · 1 terme |
| [`E3_002.json`](trad/dialogues/E3_002.json) | 97 | 13 | 13 % | commencé |
| [`E3_003.json`](trad/dialogues/E3_003.json) | 70 | 70 | 100 % | terminé |
| [`E3_004.json`](trad/dialogues/E3_004.json) | 95 | 95 | 100 % | terminé · 1 trop large |
| [`E3_005.json`](trad/dialogues/E3_005.json) | 97 | 97 | 100 % | terminé · 4 trop large |
| [`E3_006.json`](trad/dialogues/E3_006.json) | 98 | 98 | 100 % | terminé · 1 terme |
| [`E3_007.json`](trad/dialogues/E3_007.json) | 96 | 0 | 0 % | libre |
| [`E3_008.json`](trad/dialogues/E3_008.json) | 66 | 1 | 2 % | commencé |

## EBOOT

Prends un fichier **libre**, dis-le en ouvrant ta proposition, et il passera en « en cours » dans la minute.

| Fichier | Textes | Traduits | % | État |
|---|---:|---:|---:|---|
| [`EBOOT_001.json`](trad/eboot/EBOOT_001.json) | 100 | 100 | 100 % | terminé · 5 à vérifier |
| [`EBOOT_002.json`](trad/eboot/EBOOT_002.json) | 100 | 100 | 100 % | terminé · 2 à vérifier |
| [`EBOOT_003.json`](trad/eboot/EBOOT_003.json) | 100 | 100 | 100 % | terminé · 14 à vérifier |
| [`EBOOT_004.json`](trad/eboot/EBOOT_004.json) | 100 | 100 | 100 % | terminé · 1 à vérifier |
| [`EBOOT_005.json`](trad/eboot/EBOOT_005.json) | 100 | 100 | 100 % | terminé |
| [`EBOOT_006.json`](trad/eboot/EBOOT_006.json) | 100 | 100 | 100 % | terminé |
| [`EBOOT_007.json`](trad/eboot/EBOOT_007.json) | 100 | 100 | 100 % | terminé |
| [`EBOOT_008.json`](trad/eboot/EBOOT_008.json) | 100 | 100 | 100 % | terminé |
| [`EBOOT_009.json`](trad/eboot/EBOOT_009.json) | 100 | 100 | 100 % | terminé |
| [`EBOOT_010.json`](trad/eboot/EBOOT_010.json) | 100 | 100 | 100 % | terminé · 10 à vérifier |
| [`EBOOT_011.json`](trad/eboot/EBOOT_011.json) | 60 | 60 | 100 % | terminé · 5 à vérifier |
| [`EBOOT_012.json`](trad/eboot/EBOOT_012.json) | 58 | 58 | 100 % | terminé · 15 à vérifier |
| [`EBOOT_013.json`](trad/eboot/EBOOT_013.json) | 82 | 82 | 100 % | terminé · 5 à vérifier |
| [`EBOOT_014.json`](trad/eboot/EBOOT_014.json) | 100 | 100 | 100 % | terminé · 20 à vérifier |
| [`EBOOT_015.json`](trad/eboot/EBOOT_015.json) | 100 | 100 | 100 % | terminé · 1 trop large |
| [`EBOOT_016.json`](trad/eboot/EBOOT_016.json) | 100 | 100 | 100 % | terminé · 7 à vérifier |
| [`EBOOT_017.json`](trad/eboot/EBOOT_017.json) | 18 | 18 | 100 % | terminé · 1 à vérifier |
| [`EBOOT_018.json`](trad/eboot/EBOOT_018.json) | 100 | 100 | 100 % | terminé · 17 à vérifier |
| [`EBOOT_019.json`](trad/eboot/EBOOT_019.json) | 100 | 100 | 100 % | terminé · 1 trop large |
| [`EBOOT_020.json`](trad/eboot/EBOOT_020.json) | 100 | 100 | 100 % | terminé · 1 à alléger |
| [`EBOOT_021.json`](trad/eboot/EBOOT_021.json) | 100 | 100 | 100 % | terminé · 27 à vérifier |
| [`EBOOT_022.json`](trad/eboot/EBOOT_022.json) | 100 | 100 | 100 % | terminé · 1 terme |
| [`EBOOT_023.json`](trad/eboot/EBOOT_023.json) | 100 | 100 | 100 % | terminé · 5 à vérifier |
| [`EBOOT_024.json`](trad/eboot/EBOOT_024.json) | 100 | 100 | 100 % | terminé · 2 termes |
| [`EBOOT_025.json`](trad/eboot/EBOOT_025.json) | 100 | 100 | 100 % | terminé · 2 termes |
| [`EBOOT_026.json`](trad/eboot/EBOOT_026.json) | 100 | 100 | 100 % | terminé · 23 à vérifier |
| [`EBOOT_027.json`](trad/eboot/EBOOT_027.json) | 100 | 100 | 100 % | terminé · 16 à vérifier |
| [`EBOOT_028.json`](trad/eboot/EBOOT_028.json) | 100 | 100 | 100 % | terminé · 17 à vérifier |
| [`EBOOT_029.json`](trad/eboot/EBOOT_029.json) | 100 | 100 | 100 % | terminé · 22 à vérifier |
| [`EBOOT_030.json`](trad/eboot/EBOOT_030.json) | 100 | 100 | 100 % | terminé · 29 à vérifier |
| [`EBOOT_031.json`](trad/eboot/EBOOT_031.json) | 100 | 100 | 100 % | terminé · 5 à vérifier |
| [`EBOOT_032.json`](trad/eboot/EBOOT_032.json) | 38 | 38 | 100 % | terminé · 2 à vérifier |

## Donjons

Prends un fichier **libre**, dis-le en ouvrant ta proposition, et il passera en « en cours » dans la minute.

| Fichier | Textes | Traduits | % | État |
|---|---:|---:|---:|---|
| [`DNG_001.json`](trad/donjons/DNG_001.json) | 99 | 99 | 100 % | terminé |
| [`DNG_002.json`](trad/donjons/DNG_002.json) | 31 | 31 | 100 % | terminé |

## Négociations

Prends un fichier **libre**, dis-le en ouvrant ta proposition, et il passera en « en cours » dans la minute.

| Fichier | Textes | Traduits | % | État |
|---|---:|---:|---:|---|
| [`ALIEN_001.json`](trad/negociations/ALIEN_001.json) | 100 | 100 | 100 % | terminé |
| [`ALIEN_002.json`](trad/negociations/ALIEN_002.json) | 5 | 5 | 100 % | terminé |
| [`BASKET_001.json`](trad/negociations/BASKET_001.json) | 100 | 0 | 0 % | libre |
| [`BASKET_002.json`](trad/negociations/BASKET_002.json) | 100 | 0 | 0 % | libre |
| [`BASKET_003.json`](trad/negociations/BASKET_003.json) | 100 | 0 | 0 % | libre |
| [`BASKET_004.json`](trad/negociations/BASKET_004.json) | 100 | 0 | 0 % | libre |
| [`BASKET_005.json`](trad/negociations/BASKET_005.json) | 100 | 0 | 0 % | libre |
| [`BASKET_006.json`](trad/negociations/BASKET_006.json) | 100 | 0 | 0 % | libre |
| [`BASKET_007.json`](trad/negociations/BASKET_007.json) | 100 | 0 | 0 % | libre |
| [`BASKET_008.json`](trad/negociations/BASKET_008.json) | 56 | 0 | 0 % | libre |
| [`DOPPEL_001.json`](trad/negociations/DOPPEL_001.json) | 100 | 100 | 100 % | terminé |
| [`DOPPEL_002.json`](trad/negociations/DOPPEL_002.json) | 100 | 100 | 100 % | terminé |
| [`DOPPEL_003.json`](trad/negociations/DOPPEL_003.json) | 14 | 14 | 100 % | terminé |
| [`ETC_001.json`](trad/negociations/ETC_001.json) | 100 | 100 | 100 % | terminé |
| [`ETC_002.json`](trad/negociations/ETC_002.json) | 100 | 100 | 100 % | terminé |
| [`ETC_003.json`](trad/negociations/ETC_003.json) | 100 | 100 | 100 % | terminé |
| [`ETC_004.json`](trad/negociations/ETC_004.json) | 24 | 24 | 100 % | terminé |
| [`GAKI_001.json`](trad/negociations/GAKI_001.json) | 100 | 100 | 100 % | terminé |
| [`GAKI_002.json`](trad/negociations/GAKI_002.json) | 100 | 100 | 100 % | terminé |
| [`GAKI_003.json`](trad/negociations/GAKI_003.json) | 28 | 28 | 100 % | terminé |
| [`HIHO_001.json`](trad/negociations/HIHO_001.json) | 100 | 0 | 0 % | libre |
| [`HIHO_002.json`](trad/negociations/HIHO_002.json) | 100 | 0 | 0 % | libre |
| [`HIHO_003.json`](trad/negociations/HIHO_003.json) | 100 | 0 | 0 % | libre |
| [`HIHO_004.json`](trad/negociations/HIHO_004.json) | 100 | 0 | 0 % | libre |
| [`HIHO_005.json`](trad/negociations/HIHO_005.json) | 100 | 0 | 0 % | libre |
| [`HIHO_006.json`](trad/negociations/HIHO_006.json) | 100 | 0 | 0 % | libre |
| [`HIHO_007.json`](trad/negociations/HIHO_007.json) | 68 | 0 | 0 % | libre |
| [`KEMONO_001.json`](trad/negociations/KEMONO_001.json) | 100 | 0 | 0 % | libre |
| [`KEMONO_002.json`](trad/negociations/KEMONO_002.json) | 100 | 0 | 0 % | libre |
| [`KEMONO_003.json`](trad/negociations/KEMONO_003.json) | 100 | 0 | 0 % | libre |
| [`KEMONO_004.json`](trad/negociations/KEMONO_004.json) | 100 | 0 | 0 % | libre |
| [`KEMONO_005.json`](trad/negociations/KEMONO_005.json) | 100 | 0 | 0 % | libre |
| [`KEMONO_006.json`](trad/negociations/KEMONO_006.json) | 100 | 0 | 0 % | libre |
| [`KEMONO_007.json`](trad/negociations/KEMONO_007.json) | 100 | 0 | 0 % | libre |
| [`KEMONO_008.json`](trad/negociations/KEMONO_008.json) | 100 | 0 | 0 % | libre |
| [`KEMONO_009.json`](trad/negociations/KEMONO_009.json) | 100 | 0 | 0 % | libre |
| [`KEMONO_010.json`](trad/negociations/KEMONO_010.json) | 69 | 0 | 0 % | libre |
| [`KOKURI_001.json`](trad/negociations/KOKURI_001.json) | 96 | 96 | 100 % | terminé par @ATMC14 |
| [`KOROU_001.json`](trad/negociations/KOROU_001.json) | 100 | 0 | 0 % | libre |
| [`KOROU_002.json`](trad/negociations/KOROU_002.json) | 100 | 0 | 0 % | libre |
| [`KOROU_003.json`](trad/negociations/KOROU_003.json) | 100 | 0 | 0 % | libre |
| [`KOROU_004.json`](trad/negociations/KOROU_004.json) | 100 | 0 | 0 % | libre |
| [`KOROU_005.json`](trad/negociations/KOROU_005.json) | 100 | 0 | 0 % | libre |
| [`KOROU_006.json`](trad/negociations/KOROU_006.json) | 100 | 0 | 0 % | libre |
| [`KOROU_007.json`](trad/negociations/KOROU_007.json) | 100 | 0 | 0 % | libre |
| [`KOROU_008.json`](trad/negociations/KOROU_008.json) | 100 | 0 | 0 % | libre |
| [`KOROU_009.json`](trad/negociations/KOROU_009.json) | 69 | 0 | 0 % | libre |
| [`KOSIKI_001.json`](trad/negociations/KOSIKI_001.json) | 100 | 0 | 0 % | libre |
| [`KOSIKI_002.json`](trad/negociations/KOSIKI_002.json) | 100 | 0 | 0 % | libre |
| [`KOSIKI_003.json`](trad/negociations/KOSIKI_003.json) | 100 | 0 | 0 % | libre |
| [`KOSIKI_004.json`](trad/negociations/KOSIKI_004.json) | 100 | 0 | 0 % | libre |
| [`KOSIKI_005.json`](trad/negociations/KOSIKI_005.json) | 100 | 0 | 0 % | libre |
| [`KOSIKI_006.json`](trad/negociations/KOSIKI_006.json) | 100 | 0 | 0 % | libre |
| [`KOSIKI_007.json`](trad/negociations/KOSIKI_007.json) | 25 | 0 | 0 % | libre |
| [`KOUMAN_001.json`](trad/negociations/KOUMAN_001.json) | 100 | 0 | 0 % | libre |
| [`KOUMAN_002.json`](trad/negociations/KOUMAN_002.json) | 100 | 0 | 0 % | libre |
| [`KOUMAN_003.json`](trad/negociations/KOUMAN_003.json) | 100 | 0 | 0 % | libre |
| [`KOUMAN_004.json`](trad/negociations/KOUMAN_004.json) | 100 | 0 | 0 % | libre |
| [`KOUMAN_005.json`](trad/negociations/KOUMAN_005.json) | 100 | 0 | 0 % | libre |
| [`KOUMAN_006.json`](trad/negociations/KOUMAN_006.json) | 100 | 0 | 0 % | libre |
| [`KOUMAN_007.json`](trad/negociations/KOUMAN_007.json) | 100 | 0 | 0 % | libre |
| [`KOUMAN_008.json`](trad/negociations/KOUMAN_008.json) | 100 | 0 | 0 % | libre |
| [`KOUMAN_009.json`](trad/negociations/KOUMAN_009.json) | 93 | 0 | 0 % | libre |
| [`KUTISAKE_001.json`](trad/negociations/KUTISAKE_001.json) | 100 | 100 | 100 % | terminé · 1 trop large |
| [`KUTISAKE_002.json`](trad/negociations/KUTISAKE_002.json) | 100 | 100 | 100 % | terminé · 3 trop large |
| [`KUTISAKE_003.json`](trad/negociations/KUTISAKE_003.json) | 81 | 81 | 100 % | terminé · 7 trop large |
| [`KYOUKI_001.json`](trad/negociations/KYOUKI_001.json) | 100 | 0 | 0 % | libre |
| [`KYOUKI_002.json`](trad/negociations/KYOUKI_002.json) | 100 | 0 | 0 % | libre |
| [`KYOUKI_003.json`](trad/negociations/KYOUKI_003.json) | 100 | 0 | 0 % | libre |
| [`KYOUKI_004.json`](trad/negociations/KYOUKI_004.json) | 100 | 0 | 0 % | libre |
| [`KYOUKI_005.json`](trad/negociations/KYOUKI_005.json) | 100 | 0 | 0 % | libre |
| [`KYOUKI_006.json`](trad/negociations/KYOUKI_006.json) | 100 | 0 | 0 % | libre |
| [`KYOUKI_007.json`](trad/negociations/KYOUKI_007.json) | 23 | 0 | 0 % | libre |
| [`MAYOERU_001.json`](trad/negociations/MAYOERU_001.json) | 100 | 100 | 100 % | terminé |
| [`MAYOERU_002.json`](trad/negociations/MAYOERU_002.json) | 100 | 100 | 100 % | terminé |
| [`MAYOERU_003.json`](trad/negociations/MAYOERU_003.json) | 39 | 39 | 100 % | terminé |
| [`POLUTAR_001.json`](trad/negociations/POLUTAR_001.json) | 100 | 0 | 0 % | libre |
| [`POLUTAR_002.json`](trad/negociations/POLUTAR_002.json) | 100 | 0 | 0 % | libre |
| [`POLUTAR_003.json`](trad/negociations/POLUTAR_003.json) | 100 | 0 | 0 % | libre |
| [`POLUTAR_004.json`](trad/negociations/POLUTAR_004.json) | 36 | 0 | 0 % | libre |
| [`QSIRUBA_001.json`](trad/negociations/QSIRUBA_001.json) | 100 | 0 | 0 % | libre |
| [`QSIRUBA_002.json`](trad/negociations/QSIRUBA_002.json) | 100 | 0 | 0 % | libre |
| [`QSIRUBA_003.json`](trad/negociations/QSIRUBA_003.json) | 20 | 0 | 0 % | libre |
| [`SINSI_001.json`](trad/negociations/SINSI_001.json) | 100 | 0 | 0 % | libre |
| [`SINSI_002.json`](trad/negociations/SINSI_002.json) | 100 | 0 | 0 % | libre |
| [`SINSI_003.json`](trad/negociations/SINSI_003.json) | 100 | 0 | 0 % | libre |
| [`SINSI_004.json`](trad/negociations/SINSI_004.json) | 100 | 0 | 0 % | libre |
| [`SINSI_005.json`](trad/negociations/SINSI_005.json) | 100 | 0 | 0 % | libre |
| [`SINSI_006.json`](trad/negociations/SINSI_006.json) | 100 | 0 | 0 % | libre |
| [`SINSI_007.json`](trad/negociations/SINSI_007.json) | 36 | 0 | 0 % | libre |
| [`SLIME_001.json`](trad/negociations/SLIME_001.json) | 100 | 100 | 100 % | terminé |
| [`SLIME_002.json`](trad/negociations/SLIME_002.json) | 100 | 100 | 100 % | terminé |
| [`SLIME_003.json`](trad/negociations/SLIME_003.json) | 20 | 20 | 100 % | terminé |
| [`SYOUJO_001.json`](trad/negociations/SYOUJO_001.json) | 100 | 0 | 0 % | libre |
| [`SYOUJO_002.json`](trad/negociations/SYOUJO_002.json) | 100 | 0 | 0 % | libre |
| [`SYOUJO_003.json`](trad/negociations/SYOUJO_003.json) | 100 | 0 | 0 % | libre |
| [`SYOUJO_004.json`](trad/negociations/SYOUJO_004.json) | 100 | 0 | 0 % | libre |
| [`SYOUJO_005.json`](trad/negociations/SYOUJO_005.json) | 100 | 0 | 0 % | libre |
| [`SYOUJO_006.json`](trad/negociations/SYOUJO_006.json) | 100 | 0 | 0 % | libre |
| [`SYOUJO_007.json`](trad/negociations/SYOUJO_007.json) | 9 | 9 | 100 % | terminé par @Uolil-Raccoon |
| [`TENSI_001.json`](trad/negociations/TENSI_001.json) | 100 | 100 | 100 % | terminé |
| [`TENSI_002.json`](trad/negociations/TENSI_002.json) | 100 | 100 | 100 % | terminé |
| [`TENSI_003.json`](trad/negociations/TENSI_003.json) | 100 | 100 | 100 % | terminé |
| [`TENSI_004.json`](trad/negociations/TENSI_004.json) | 100 | 100 | 100 % | terminé · 4 trop large |
| [`TENSI_005.json`](trad/negociations/TENSI_005.json) | 100 | 100 | 100 % | terminé |
| [`TENSI_006.json`](trad/negociations/TENSI_006.json) | 82 | 82 | 100 % | terminé |
| [`TINPRA_001.json`](trad/negociations/TINPRA_001.json) | 100 | 0 | 0 % | libre |
| [`TINPRA_002.json`](trad/negociations/TINPRA_002.json) | 100 | 0 | 0 % | libre |
| [`TINPRA_003.json`](trad/negociations/TINPRA_003.json) | 69 | 0 | 0 % | libre |
| [`TOILET_001.json`](trad/negociations/TOILET_001.json) | 100 | 0 | 0 % | en cours par @Uolil-Raccoon (#44) |
| [`TOILET_002.json`](trad/negociations/TOILET_002.json) | 100 | 0 | 0 % | libre |
| [`TOILET_003.json`](trad/negociations/TOILET_003.json) | 100 | 0 | 0 % | libre |
| [`TOILET_004.json`](trad/negociations/TOILET_004.json) | 19 | 19 | 100 % | terminé par @Uolil-Raccoon |
| [`WORM_001.json`](trad/negociations/WORM_001.json) | 100 | 0 | 0 % | libre |
| [`WORM_002.json`](trad/negociations/WORM_002.json) | 100 | 0 | 0 % | libre |
| [`WORM_003.json`](trad/negociations/WORM_003.json) | 100 | 0 | 0 % | libre |
| [`WORM_004.json`](trad/negociations/WORM_004.json) | 100 | 0 | 0 % | libre |
| [`WORM_005.json`](trad/negociations/WORM_005.json) | 100 | 0 | 0 % | libre |
| [`WORM_006.json`](trad/negociations/WORM_006.json) | 100 | 0 | 0 % | libre |
| [`WORM_007.json`](trad/negociations/WORM_007.json) | 100 | 0 | 0 % | libre |
| [`WORM_008.json`](trad/negociations/WORM_008.json) | 100 | 0 | 0 % | libre |
| [`WORM_009.json`](trad/negociations/WORM_009.json) | 86 | 0 | 0 % | libre |
| [`WTENSI_001.json`](trad/negociations/WTENSI_001.json) | 80 | 80 | 100 % | terminé par @ATMC14 |
| [`YAKUZA_001.json`](trad/negociations/YAKUZA_001.json) | 100 | 100 | 100 % | terminé · 1 trop large |
| [`YAKUZA_002.json`](trad/negociations/YAKUZA_002.json) | 100 | 100 | 100 % | terminé · 6 trop large |
| [`YAKUZA_003.json`](trad/negociations/YAKUZA_003.json) | 59 | 59 | 100 % | terminé |
| [`YOUEN_001.json`](trad/negociations/YOUEN_001.json) | 100 | 0 | 0 % | libre |
| [`YOUEN_002.json`](trad/negociations/YOUEN_002.json) | 100 | 0 | 0 % | libre |
| [`YOUEN_003.json`](trad/negociations/YOUEN_003.json) | 100 | 0 | 0 % | libre |
| [`YOUEN_004.json`](trad/negociations/YOUEN_004.json) | 100 | 0 | 0 % | libre |
| [`YOUEN_005.json`](trad/negociations/YOUEN_005.json) | 100 | 0 | 0 % | libre |
| [`YOUEN_006.json`](trad/negociations/YOUEN_006.json) | 87 | 0 | 0 % | libre |
| [`ZMBITYAN_001.json`](trad/negociations/ZMBITYAN_001.json) | 100 | 100 | 100 % | terminé |
| [`ZMBITYAN_002.json`](trad/negociations/ZMBITYAN_002.json) | 100 | 100 | 100 % | terminé |
| [`ZMBITYAN_003.json`](trad/negociations/ZMBITYAN_003.json) | 22 | 22 | 100 % | terminé |
| [`ZOMBIKO_001.json`](trad/negociations/ZOMBIKO_001.json) | 100 | 0 | 0 % | en cours par @ATMC14 (#46) |
| [`ZOMBIKO_002.json`](trad/negociations/ZOMBIKO_002.json) | 90 | 0 | 0 % | en cours par @ATMC14 (#45) |
| [`ZOMB_MAN_001.json`](trad/negociations/ZOMB_MAN_001.json) | 100 | 0 | 0 % | libre |
| [`ZOMB_MAN_002.json`](trad/negociations/ZOMB_MAN_002.json) | 82 | 36 | 44 % | commencé par @vikmorp |

