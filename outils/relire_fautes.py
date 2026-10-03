#!/usr/bin/env python3
"""Les fautes qu'une machine trouve sans dictionnaire : le corpus se corrige lui-meme.

    python outils/relire_fautes.py                 toutes les zones
    python outils/relire_fautes.py --zone dialogues
    python outils/relire_fautes.py --rare 2 --frequent 8
    python outils/relire_fautes.py --tolerances outils/fautes_tolerees.json

Pourquoi pas un correcteur orthographique
-----------------------------------------

Un correcteur francais ne connait ni Kandori, ni Mikage, ni SEBEC, ni Yuriko,
ni « hi-ho », ni les trois cents autres noms du jeu. Sur 24 572 textes il
rendrait des centaines de faux positifs, et une liste d'exceptions aussi longue
que le corpus. Personne ne lit un rapport pareil, donc personne ne corrige rien.

Le corpus, lui, est son propre dictionnaire. Un nom propre revient : Kandori
apparait des centaines de fois. Une faute de frappe, non : elle apparait **une
seule fois**, et il existe presque toujours, ailleurs dans le corpus, le mot
juste a une lettre pres. C'est exactement la forme des fautes trouvees a la main
jusqu'ici : « surveun » pour « survenu », « enfnats » pour « enfants »,
« sommmes » pour « sommes », « Quest-ce » pour « Qu'est-ce ».

Ce qu'il trouve
---------------

  [TYPO]       un mot rare a une lettre d'un mot frequent
  [DOUBLON]    un mot repete (« de de », « le le »)
  [TYPOGRAPHIE] un ecart aux regles ecrites du projet : espace avant une
               ponctuation, guillemets francais, apostrophe courbe

Ce qu'il ne trouve pas, et il faut le savoir : les accords, les temps, et une
faute sur un mot qui n'a pas de voisin dans le corpus. Pour ca il faudra un
vrai analyseur grammatical — c'est une autre etape.
"""

from __future__ import annotations

import argparse
import collections
import json
import re
import sys
from pathlib import Path

RACINE = Path(__file__).resolve().parents[2]
ICI = Path(__file__).resolve().parent

JETON = re.compile(r"\{[A-Z]+\}|\(\*[^*]*\*\)|\[[0-9A-Fa-f]{4}\]")
MOT = re.compile(r"[A-Za-zÀ-ÿ]+(?:[''\-][A-Za-zÀ-ÿ]+)*")
CJK = re.compile(r"[぀-ヿ一-鿿]")

# Les regles de typographie du projet, telles que CONTRIBUTING.md les ecrit :
# pas d'espace avant une ponctuation, guillemets droits, apostrophe droite.
TYPOGRAPHIE = [
    # CONTRIBUTING.md ne nomme que « ! » et « ? » : le projet ecrit « blague! »
    # et « deja? ». Les deux-points gardent leur espace, comme en francais.
    (re.compile(r"\w\s+[!?]"), "espace avant ! ou ?"),
    (re.compile("[\u00ab\u00bb]"), "guillemets francais (le projet ecrit des guillemets droits)"),
    (re.compile("\u2019"), "apostrophe courbe (le projet ecrit l'apostrophe droite)"),
    (re.compile("\u2026"), "points de suspension en un signe (le projet en ecrit trois)"),
]

# Les blocs de mise en scene ne sont pas du texte : suites de marqueurs, paves
# d'espaces. Les passer au crible n'apprend rien et noie le rapport.
REMPLISSAGE = re.compile(r"\s{6,}")

# Deux fois le meme mot sans rien entre eux qu'un espace.
DOUBLE = re.compile(r"\b([A-Za-z\u00c0-\u00ff]{2,})\s+\1\b", re.IGNORECASE)
# « nous nous souvenons », « vous vous trompez » : la repetition est la langue.
DOUBLE_LEGITIME = {"nous", "vous", "si", "non", "oui", "ha", "he", "hi", "ho", "na", "la", "chut"}


def sans_jetons(t: str) -> str:
    # Du VIDE, pas un espace : les jetons sont des codes de controle de largeur
    # nulle. Les remplacer par un espace fabrique « l' hopital » la ou le jeu
    # affiche « l'hopital », et invente des fautes de typographie.
    return JETON.sub("", t or "")


def corrections(mot: str):
    """Les mots qu'on obtiendrait en reparant un accident de frappe.

    Trois accidents seulement, parce que ce sont les trois qui separent une
    faute d'un vrai mot. Chercher « a une lettre pres » attrape au contraire
    des milliers de paires legitimes (« absurde » / « absurdes »).
    """
    # Deux lettres voisines echangees.
    for i in range(len(mot) - 1):
        if mot[i] != mot[i + 1]:
            yield mot[:i] + mot[i + 1] + mot[i] + mot[i + 2 :], "inversion"
    # Une lettre tapee une fois de trop, la ou il y en a deja deux.
    for i in range(len(mot) - 2):
        if mot[i] == mot[i + 1] == mot[i + 2]:
            yield mot[:i] + mot[i + 1 :], "lettre repetee"
    # Une apostrophe oubliee.
    for i in range(1, len(mot)):
        yield mot[:i] + "'" + mot[i:], "apostrophe oubliee"


# Les cris et les rires ne sont pas des mots : trois lettres identiques y sont
# la regle, pas l'accident.
def interjection(mot: str) -> bool:
    return len(set(mot)) <= 3 or not any(c in "aeiouyàâéèêëîïôûù" for c in mot)


def charger(racine: Path, zones):
    for zone in zones:
        dossier = racine / zone
        if not dossier.is_dir():
            continue
        for chemin in sorted(dossier.glob("*.json")):
            if chemin.name.startswith("_"):
                continue
            entrees = json.loads(chemin.read_text(encoding="utf-8"))
            if not isinstance(entrees, list):
                continue
            for e in entrees:
                if isinstance(e, dict) and e.get("fr"):
                    yield f"{zone}/{chemin.name}", e


def main(argv=None):
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    defaut = RACINE / "game" / "scripts"
    ap.add_argument("--racine", type=Path, default=defaut if defaut.is_dir() else Path("trad"))
    ap.add_argument("--zone", default=None, help="une seule zone (defaut : toutes)")
    ap.add_argument("--rare", type=int, default=2, help="vu au plus N fois (defaut 2)")
    ap.add_argument("--frequent", type=int, default=8, help="vu au moins N fois (defaut 8)")
    ap.add_argument("--tolerances", type=Path, default=None)
    ap.add_argument("--montrer", type=int, default=60)
    args = ap.parse_args(argv)

    tolerees, doublons_ok = set(), set(DOUBLE_LEGITIME)
    chemin_tol = args.tolerances or ICI / "fautes_tolerees.json"
    if chemin_tol.exists():
        brut = json.loads(chemin_tol.read_text(encoding="utf-8"))
        tolerees = set(brut.get("mots", []))
        doublons_ok |= {m.lower() for m in brut.get("doublons", [])}

    zones = [args.zone] if args.zone else ["dialogues", "negociations", "eboot", "donjons"]
    freq = collections.Counter()
    ou = collections.defaultdict(list)
    doublons, typo_graphie = [], []
    lues = 0

    for fichier, e in charger(args.racine, zones):
        lues += 1
        texte = sans_jetons(e["fr"])
        if CJK.search(texte) or REMPLISSAGE.search(texte):
            continue
        mots = MOT.findall(texte)
        for m in mots:
            bas = m.lower()
            freq[bas] += 1
            if len(ou[bas]) < 3:
                ou[bas].append((fichier, e["id"], texte))
        # Un mot repete COLLE au precedent : « de de ». Si une ponctuation les
        # separe (« Persona! Persona! », « Ouais, ouais »), c'est une emphase
        # voulue, pas une faute.
        for m in DOUBLE.finditer(texte):
            if m.group(1).lower() not in doublons_ok:
                doublons.append((fichier, e["id"], m.group(1), texte))
        # Sur le texte BRUT : un jeton entre l'espace et la ponctuation n'est
        # pas un espace a l'ecran. « salut (*APELLIDO_HEROE*)! » s'affiche
        # « salut Naoya! », sans faute — le signaler serait du bruit.
        for motif, quoi in TYPOGRAPHIE:
            if motif.search(e["fr"]):
                typo_graphie.append((fichier, e["id"], quoi, texte))

    suspects = []
    for mot, n in freq.items():
        if n > args.rare or mot in tolerees or len(mot) < 4 or interjection(mot):
            continue
        trouves = {}
        for repare, comment in corrections(mot):
            if freq.get(repare, 0) >= args.frequent:
                trouves.setdefault(repare, comment)
        if trouves:
            ordre = sorted(trouves, key=lambda p: -freq[p])
            suspects.append((n, mot, [(p, trouves[p]) for p in ordre[:3]]))

    print(f"  {lues} lignes lues, {len(freq)} mots distincts dans {len(zones)} zone(s)")
    print(f"  rare = vu au plus {args.rare} fois, frequent = vu au moins {args.frequent} fois")

    soucis = 0
    if suspects:
        print(f"\n  {len(suspects)} mot(s) rares reparables par un accident de frappe — [TYPO] :\n")
        for n, mot, proches in sorted(suspects, key=lambda s: (s[0], s[1]))[: args.montrer]:
            voisins = ", ".join(f"{p} ×{freq[p]} ({c})" for p, c in proches)
            print(f"  [TYPO] {mot!r} ×{n}  →  {voisins}")
            for fichier, eid, texte in ou[mot][:1]:
                print(f"         {fichier} {eid}")
                print(f"         {texte.strip()[:88]}")
            soucis += 1
        if len(suspects) > args.montrer:
            print(f"  … et {len(suspects) - args.montrer} autre(s)")

    if doublons:
        print(f"\n  {len(doublons)} mot(s) repetes — [DOUBLON] :\n")
        for fichier, eid, mot, texte in doublons[:20]:
            print(f"  [DOUBLON] {mot!r}  {fichier} {eid}")
            print(f"            {texte.strip()[:88]}")
            soucis += 1

    if typo_graphie:
        par_quoi = collections.Counter(q for _f, _i, q, _t in typo_graphie)
        print(f"\n  {len(typo_graphie)} ecart(s) de typographie — [TYPOGRAPHIE] :\n")
        for quoi, n in par_quoi.most_common():
            print(f"  [TYPOGRAPHIE] {quoi} : {n}")
            for fichier, eid, q, texte in typo_graphie:
                if q == quoi:
                    print(f"         {fichier} {eid}  {texte.strip()[:80]}")
                    break
            soucis += 1

    if not soucis:
        print("\n  rien a signaler")
        return 0
    print(f"\n  {soucis} constat(s). Les mots justes mais rares vont dans fautes_tolerees.json")
    return 1


if __name__ == "__main__":
    sys.exit(main())
