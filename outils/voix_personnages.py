#!/usr/bin/env python3
"""Chaque personnage se tient-il a sa voix d'un bout a l'autre du jeu ?

    python outils/voix_personnages.py              le rapport complet
    python outils/voix_personnages.py --qui Nanjo  un seul personnage
    python outils/voix_personnages.py --tics       seulement les tics de langage

Un personnage traduit sur neuf mois par plusieurs mains derive sans que
personne s'en apercoive : chaque fichier est juste, et pourtant Nanjo vouvoie
dans un couloir et tutoie dans le suivant. Le joueur, lui, entend la meme voix
du debut a la fin — c'est lui qui le remarque.

Deux controles, de nature differente.

**Le tutoiement.** On compte, par personnage, les repliques qui tutoient et
celles qui vouvoient, et on montre la minorite quand elle est franche. Ce n'est
PAS un verdict : un personnage a le droit de vouvoyer un adulte et de tutoyer un
ami. Et « vous » est aussi le pluriel — un « vous » chez Mark s'adresse au
groupe, il ne vouvoie personne. C'est donc un rapport a lire, pas un test a
faire passer. Il est juste beaucoup plus rapide de regarder huit lignes que
quatre mille.

**Les tics.** Ceux-la se verifient : si l'anglais porte la marque et que le
francais ne la rend pas, c'est un oubli. Les regles vivent dans
`tics_personnages.json`, avec leur raison.
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
TU = re.compile(r"\b(tu|t'(?:es|as|en|y)|te|toi|ton|ta|tes|tien|tienne)\b", re.I)
VOUS = re.compile(r"\b(vous|votre|vos)\b", re.I)


def sans_jetons(t: str) -> str:
    return JETON.sub("", t or "")


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
    ap.add_argument("--qui", default=None, help="un seul personnage")
    ap.add_argument("--tics", action="store_true", help="seulement les tics")
    ap.add_argument("--minimum", type=int, default=25, help="repliques minimum pour juger (defaut 25)")
    ap.add_argument("--seuil", type=float, default=0.15, help="minorite en dessous de laquelle on montre (defaut 0,15)")
    ap.add_argument("--regles", type=Path, default=None)
    ap.add_argument("--montrer", type=int, default=8)
    args = ap.parse_args(argv)

    zones = ["dialogues", "negociations"]
    compte = collections.defaultdict(collections.Counter)
    exemples = collections.defaultdict(list)
    lignes = []

    for fichier, e in charger(args.racine, zones):
        loc = e.get("locuteur_fr")
        fr = sans_jetons(e["fr"])
        lignes.append((fichier, e, fr))
        if not loc or (args.qui and loc != args.qui):
            continue
        a_tu, a_vous = bool(TU.search(fr)), bool(VOUS.search(fr))
        if a_tu and not a_vous:
            compte[loc]["tu"] += 1
            exemples[(loc, "tu")].append((fichier, e["id"], sans_jetons(e["en"]), fr))
        elif a_vous and not a_tu:
            compte[loc]["vous"] += 1
            exemples[(loc, "vous")].append((fichier, e["id"], sans_jetons(e["en"]), fr))

    soucis = 0

    if not args.tics:
        print("  Tutoiement et vouvoiement — un rapport a lire, pas un verdict")
        print("  (« vous » est aussi le pluriel : chez un personnage qui parle au groupe,")
        print("   ce n'est pas du vouvoiement)\n")
        for loc, c in sorted(compte.items(), key=lambda x: -(x[1]["tu"] + x[1]["vous"])):
            total = c["tu"] + c["vous"]
            if total < args.minimum:
                continue
            minoritaire = "tu" if c["tu"] < c["vous"] else "vous"
            part = min(c["tu"], c["vous"]) / total
            drapeau = "  <-- a regarder" if 0 < part <= args.seuil else ""
            print(f"  {loc:26} tu {c['tu']:>4}   vous {c['vous']:>4}   minorite {part:4.0%}{drapeau}")
            if drapeau:
                soucis += 1
                for fichier, eid, en, fr in exemples[(loc, minoritaire)][: args.montrer]:
                    print(f"        {fichier} {eid}")
                    print(f"          EN {en[:80]}")
                    print(f"          FR {fr[:80]}")
                reste = len(exemples[(loc, minoritaire)]) - args.montrer
                if reste > 0:
                    print(f"        … et {reste} autre(s)")
                print()

    # --- les tics, eux, se verifient ---------------------------------------
    chemin_regles = args.regles or ICI / "tics_personnages.json"
    if not chemin_regles.exists():
        print(f"\n  {chemin_regles.name} absent — pas de tic a verifier")
        return 1 if soucis else 0

    regles = json.loads(chemin_regles.read_text(encoding="utf-8")).get("tics", [])
    print(f"\n  Tics de langage — {len(regles)} regle(s)\n")
    for r in regles:
        motif_en = re.compile(r["anglais"], re.I)
        motif_fr = re.compile(r["francais"], re.I)
        manques = []
        vus = 0
        for fichier, e, fr in lignes:
            if r.get("locuteur") and e.get("locuteur_fr") != r["locuteur"]:
                continue
            if not motif_en.search(sans_jetons(e["en"])):
                continue
            vus += 1
            if not motif_fr.search(fr):
                manques.append((fichier, e["id"], sans_jetons(e["en"]), fr))
        rendu = vus - len(manques)
        taux = rendu / vus if vus else 1.0
        seuil = r.get("taux_minimum", 0.5)
        etat = "✅" if taux >= seuil else "⚠"
        print(f"  {etat}  {r['quoi']} : rendu {rendu}/{vus} ({taux:.0%})")
        # On ne detaille que si la voix s'effondre. Un tic rendu deux fois sur
        # trois est un style, pas un oubli.
        if taux < seuil:
            soucis += 1
            for fichier, eid, en, fr in manques[: args.montrer]:
                print(f"        {fichier} {eid}")
                print(f"          EN {en[:80]}")
                print(f"          FR {fr[:80]}")
            if len(manques) > args.montrer:
                print(f"        … et {len(manques) - args.montrer} autre(s)")

    return 1 if soucis else 0


if __name__ == "__main__":
    sys.exit(main())
