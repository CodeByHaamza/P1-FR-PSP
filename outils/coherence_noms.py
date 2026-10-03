#!/usr/bin/env python3
"""Un nom d'objet s'ecrit-il pareil dans les menus et dans les dialogues ?

    python outils/coherence_noms.py                 (depuis la racine du depot)
    python outils/coherence_noms.py --racine <chemin>
    python outils/coherence_noms.py --tolerances outils/noms_tolerances.json

Pourquoi cet outil existe
-------------------------

`check_trad.rb` valide chaque fichier **separement**, et chaque fichier peut
etre parfaitement correct pendant que le corpus se contredit. C'est exactement
ce qui s'est produit deux fois :

  « Mirror Shard »  -> « Eclat de miroir » dans la zone des noms,
                       « Fragment de Miroir » dans les dialogues
  « Expel Mirror »  -> « Miroir de sortie » contre « Miroir Expel »

Pour le joueur, ce sont deux objets differents : il cherche dans son inventaire
un objet dont le dialogue vient de lui donner un autre nom. Les deux ont ete
trouvees par hasard, en travaillant ailleurs, sur 439 noms. Personne ne tient
439 noms en tete.

Ce qu'il mesure
---------------

La zone `trad/noms` est la reference : c'est elle qui nomme l'objet dans
l'inventaire. Pour chaque nom anglais qu'elle contient, on cherche ce nom dans
l'anglais des autres zones, et on verifie que le francais en face emploie bien
la forme de l'inventaire.

Deux constats, de gravite differente :

  [NOM-VARIANTE]  le meme nom anglais est rendu par plusieurs formes
                  francaises dans le corpus. C'est le cas grave : il y a
                  forcement une erreur parmi elles.
  [NOM-ABSENT]    le nom anglais est la, la forme de l'inventaire n'est pas.
                  Souvent legitime (« a mirror shard » employe comme nom
                  commun, une tournure qui evite le nom), d'ou le fichier de
                  tolerances.

Il ne bloque pas : il rapporte, et un oeil tranche. Les cas admis se rangent
dans `outils/noms_tolerances.json`, pour que le rapport reste lisible.
"""

from __future__ import annotations

import argparse
import collections
import json
import re
import sys
import unicodedata
from pathlib import Path

# Les jetons du moteur : ils coupent le texte et ne doivent jamais compter dans
# une correspondance (« (*TEXTBOX_PARAM,0500*)Rapiere » contient « Rapiere »).
JETON = re.compile(r"\{[A-Z]+\}|\(\*[^*]*\*\)|\[[0-9A-Fa-f]{4}\]")

# Un nom trop court ou trop commun se retrouve partout et noie le rapport.
# « Key », « Life », « Gem » matchent des phrases entieres sans parler d'objet.
TROP_COMMUN = {
    "key",
    "life",
    "gem",
    "ring",
    "mail",
    "coat",
    "boots",
    "guard",
    "helm",
    "rod",
    "club",
    "bow",
    "gun",
    "cap",
    "hat",
    "suit",
    "robe",
    "belt",
    "shoes",
    "medal",
    "stone",
    "card",
    "drink",
    "water",
    "oil",
    "bomb",
    "seed",
    "doll",
    "mirror",
    "mask",
    "sword",
    "spear",
    "axe",
    "knife",
    "shield",
    "armor",
}
LONGUEUR_MINI = 5


def sans_jetons(texte: str) -> str:
    return JETON.sub("", texte or "")


def nom_propre(brut: str) -> str:
    """Le nom seul : sans jetons, sans octets techniques, sans espaces morts.

    La zone des noms porte des entrees comme
    `p [B004] [2100][08A0]Rapier(*TERMINATOR*)` : les octets de statistiques se
    decodent en lettres et precedent le nom. `sans_jetons` enleve les crochets,
    reste a jeter ce qui traine devant.
    """
    t = sans_jetons(brut).strip()
    # Ce qui precede le nom est de la ferraille : lettres isolees et espaces.
    t = re.sub(r"^(?:[a-z]\s+)+", "", t)
    return t.strip()


def motif_forme(forme: str) -> re.Pattern:
    """Un motif tolerant pour chercher une forme dans une phrase.

    Tolere le pluriel sur chaque mot (« Fragments de Miroir »), une
    ponctuation ou un mot court intercale (« Medaille des ruines »), et la
    casse. Ne tolere PAS un autre mot plein : c'est ce qui distingue
    « Fragment de Miroir » de « Eclat de miroir ».
    """
    mots = [m for m in re.split(r"[\s'-]+", forme) if m]
    morceaux = []
    for i, m in enumerate(mots):
        if i:
            # entre deux mots : espaces, apostrophe, trait d'union, ou un petit
            # mot de liaison (de, du, des, la, le, les, d')
            morceaux.append(r"(?:[\s'-]+|[\s]+(?:de|du|des|la|le|les|d')[\s']+)")
        morceaux.append(re.escape(m) + r"s?")
    return re.compile("".join(morceaux), re.IGNORECASE)


def sans_accents(t: str) -> str:
    return "".join(c for c in unicodedata.normalize("NFD", t) if unicodedata.category(c) != "Mn")


# Un nom d'objet affiche a l'ecran est encadre : le jeu le colore pour le
# distinguer de la phrase. Soit par le jeton de couleur, soit par le marqueur de
# style `b` grec. Ce qui suit ce marqueur EST le nom de l'objet, sans ambiguite
# — c'est la que le controle devient exact au lieu d'heuristique.
MARQUEUR = re.compile(r"(?:\(\*TEXTBOX_PARAM,0500\*\)|β)([^(){}\[\]!?\n]+)")


def encadres(brut: str) -> list[str]:
    """Les noms encadres d'une ligne, dans l'ordre ou ils apparaissent."""
    return [m.group(1).strip() for m in MARQUEUR.finditer(brut or "")]


def commence_par(phrase: str, forme: str) -> bool:
    """La phrase encadree commence-t-elle par cette forme ?

    On compare un debut, pas une egalite : apres le nom vient souvent le reste
    de la phrase (« Tambour de bison obtenu »), parce que le jeton de fermeture
    ne tombe pas toujours juste apres le nom.
    """
    a = sans_accents(phrase).lower().lstrip()
    b = sans_accents(forme).lower().strip()
    if a.startswith(b):
        return True
    # tolerer le pluriel, d'un cote comme de l'autre
    return a.startswith(b + "s") or (b.endswith("s") and a.startswith(b[:-1]))


def charger_noms(racine: Path, zone: str) -> dict[str, str]:
    """{nom anglais: nom francais} depuis la zone de reference."""
    table = {}
    dossier = racine / zone
    for chemin in sorted(dossier.glob("*.json")):
        if chemin.name.startswith("_"):
            continue
        for e in json.loads(chemin.read_text(encoding="utf-8")):
            en, fr = nom_propre(e.get("en", "")), nom_propre(e.get("fr", ""))
            if not en or not fr:
                continue
            if len(en) < LONGUEUR_MINI or en.lower() in TROP_COMMUN:
                continue
            # Deux entrees peuvent porter le meme nom anglais (objet et sort
            # homonymes) : on garde la premiere, et si elles divergent c'est
            # deja un probleme que le rapport dira.
            table.setdefault(en, fr)
    return table


def charger_lignes(racine: Path, zones: list[str]):
    for zone in zones:
        for chemin in sorted((racine / zone).glob("*.json")):
            if chemin.name.startswith("_"):
                continue
            entrees = json.loads(chemin.read_text(encoding="utf-8"))
            if not isinstance(entrees, list):
                continue
            for e in entrees:
                if not isinstance(e, dict) or not e.get("fr"):
                    continue
                yield f"{zone}/{chemin.name}", e


def main(argv=None):
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--racine", type=Path, default=Path("trad"))
    ap.add_argument("--tolerances", type=Path, default=None)
    ap.add_argument("--exemples", type=int, default=3, help="exemples montres par constat (defaut 3)")
    ap.add_argument(
        "--absents",
        action="store_true",
        help="montrer aussi les [NOM-ABSENT], bruyants par nature",
    )
    args = ap.parse_args(argv)

    racine = args.racine
    if not (racine / "noms").is_dir():
        print(f"  {racine / 'noms'} introuvable — lancer depuis la racine du depot", file=sys.stderr)
        return 2

    tolerees, ignores = set(), set()
    if args.tolerances and args.tolerances.exists():
        brut = json.loads(args.tolerances.read_text(encoding="utf-8"))
        tolerees = set(brut.get("ignorer", []))
        ignores = set(brut.get("noms_ignores", []))

    noms = {en: fr for en, fr in charger_noms(racine, "noms").items() if en not in ignores}
    zones = [z for z in ("dialogues", "negociations", "eboot", "donjons") if (racine / z).is_dir()]

    # Un seul balayage : une alternance de tous les noms anglais, du plus long
    # au plus court pour que « Chaos Mirror Shard » gagne sur « Mirror Shard ».
    ordre = sorted(noms, key=len, reverse=True)
    grande = re.compile("|".join(re.escape(n) for n in ordre), re.IGNORECASE)
    motifs = {en: motif_forme(fr) for en, fr in noms.items()}

    variantes = collections.defaultdict(collections.Counter)
    absents = collections.defaultdict(list)
    cadres = []
    casses = collections.defaultdict(collections.Counter)
    lues = 0
    par_en = {en.lower(): (en, fr) for en, fr in noms.items()}

    for fichier, e in charger_lignes(racine, zones):
        lues += 1

        # Controle exact : les noms encadres, apparies dans l'ordre.
        en_cadres, fr_cadres = encadres(e["en"]), encadres(e["fr"])
        for k, brut_en in enumerate(en_cadres):
            trouve = next(
                (par_en[c] for c in par_en if brut_en.lower().startswith(c)),
                None,
            )
            if trouve is None or k >= len(fr_cadres):
                continue
            cle, ref = trouve
            if f"{e['id']}|{cle}" in tolerees or cle in ignores:
                continue
            if not commence_par(fr_cadres[k], ref):
                cadres.append((cle, ref, fichier, e["id"], brut_en, fr_cadres[k]))
            elif not fr_cadres[k].startswith(ref):
                # La forme est la, l'ecriture non : casse ou accent. Visible a
                # l'ecran, donc a uniformiser, mais sans gravite.
                casses[(cle, ref)][fr_cadres[k][: len(ref) + 2].strip()] += 1

        en_nu, fr_nu = sans_jetons(e["en"]), sans_jetons(e["fr"])
        vus = set()
        for trouve in grande.finditer(en_nu):
            # Retrouver la clef exacte (la recherche est insensible a la casse).
            brut = trouve.group(0)
            cle = next((n for n in ordre if n.lower() == brut.lower()), None)
            if cle is None or cle in vus:
                continue
            vus.add(cle)
            ref = noms[cle]
            if motifs[cle].search(fr_nu):
                variantes[cle][ref] += 1
                continue
            # La forme de l'inventaire est absente. Deux lectures : une autre
            # forme francaise du meme objet (grave), ou une tournure qui evite
            # le nom (benin). On ne sait pas trancher, on rapporte les deux.
            if f"{e['id']}|{cle}" in tolerees:
                continue
            absents[cle].append((fichier, e["id"], en_nu, fr_nu))

    # Deuxieme passe : chercher, parmi les lignes ou la forme de reference
    # manquait, une autre forme francaise employee ailleurs pour le meme objet.
    # C'est ce qui separe « Eclat de miroir » (vraie variante) d'une periphrase.
    suspects = {}
    for cle, cas in absents.items():
        tete = noms[cle].split()[0]
        if len(tete) < 4:
            continue
        motif_tete = re.compile(r"\b" + re.escape(sans_accents(tete)[:-1] or tete) + r"\w*", re.IGNORECASE)
        for fichier, eid, en_nu, fr_nu in cas:
            # Le nom de reference commence par le meme mot ? alors le francais
            # dit probablement la meme chose autrement : on le montre d'abord.
            if motif_tete.search(sans_accents(fr_nu)):
                suspects.setdefault(cle, []).append((fichier, eid, en_nu, fr_nu))

    print(f"  {len(noms)} noms de reference, {lues} lignes traduites lues dans {len(zones)} zones")
    if ignores:
        print(f"  {len(ignores)} nom(s) ecartes par outils/noms_tolerances.json")

    graves = {c: v for c, v in variantes.items() if len(v) > 1}
    soucis = 0

    if cadres:
        groupes = collections.defaultdict(list)
        for cle, ref, fichier, eid, brut_en, brut_fr in cadres:
            groupes[(cle, ref)].append((fichier, eid, brut_en, brut_fr))
        print(f"\n  {len(groupes)} nom(s) encadres a l'ecran sous une autre forme — [NOM-ENCADRE] :\n")
        for (cle, ref), cas in sorted(groupes.items()):
            print(f"  [NOM-ENCADRE] {cle} — l'inventaire dit « {ref} »")
            for fichier, eid, brut_en, brut_fr in cas[: args.exemples]:
                print(f"        {fichier} {eid}")
                print(f"          EN encadre : {brut_en[:70]}")
                print(f"          FR encadre : {brut_fr[:70]}")
            if len(cas) > args.exemples:
                print(f"        … et {len(cas) - args.exemples} autre(s)")
            soucis += 1

    if graves:
        print(f"\n  {len(graves)} nom(s) rendus de plusieurs facons — [NOM-VARIANTE] :\n")
        for cle, formes in sorted(graves.items()):
            detail = ", ".join(f"« {f} » ×{n}" for f, n in formes.most_common())
            print(f"  [NOM-VARIANTE] {cle} : {detail}")
            soucis += 1

    if suspects:
        print(f"\n  {len(suspects)} nom(s) dits autrement alors que l'inventaire a une forme :\n")
        for cle, cas in sorted(suspects.items()):
            print(f"  [NOM-VARIANTE] {cle} — l'inventaire dit « {noms[cle]} », mais :")
            for fichier, eid, en_nu, fr_nu in cas[: args.exemples]:
                print(f"        {fichier} {eid}")
                print(f"          EN {en_nu[:88]}")
                print(f"          FR {fr_nu[:88]}")
            if len(cas) > args.exemples:
                print(f"        … et {len(cas) - args.exemples} autre(s)")
            soucis += 1

    if casses:
        print(f"\n  {len(casses)} nom(s) encadres ecrits avec une autre casse — [NOM-CASSE] :\n")
        for (cle, ref), formes in sorted(casses.items()):
            vues = ", ".join(f"« {f} » ×{n}" for f, n in formes.most_common())
            print(f"  [NOM-CASSE] {cle} — l'inventaire dit « {ref} », a l'ecran : {vues}")
            soucis += 1

    restants = sum(len(c) for cle, c in absents.items() if cle not in suspects)
    if args.absents:
        print(f"\n  [NOM-ABSENT] {restants} ligne(s) ou le nom anglais est la sans la forme francaise :\n")
        for cle, cas in sorted(absents.items()):
            if cle in suspects:
                continue
            print(f"  [NOM-ABSENT] {cle} (« {noms[cle]} ») — {len(cas)} ligne(s)")
            for fichier, eid, en_nu, fr_nu in cas[: args.exemples]:
                print(f"        {fichier} {eid}")
                print(f"          EN {en_nu[:88]}")
                print(f"          FR {fr_nu[:88]}")
    elif restants:
        print(f"\n  {restants} ligne(s) en [NOM-ABSENT] — souvent legitimes, `--absents` pour les voir")

    if not soucis:
        print("\n  aucun nom contredit entre l'inventaire et le reste du corpus")
        return 0
    print(f"\n  {soucis} nom(s) a arbitrer. Les cas admis vont dans outils/noms_tolerances.json")
    return 1


if __name__ == "__main__":
    sys.exit(main())
