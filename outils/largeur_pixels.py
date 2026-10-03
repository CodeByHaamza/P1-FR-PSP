#!/usr/bin/env python3
"""Une ligne tient-elle dans la boite de dialogue ? Mesure, au lieu de compter.

    python game/tools/largeur_pixels.py                      rapport sur tout le corpus
    python game/tools/largeur_pixels.py --glyphes            la table des largeurs
    python game/tools/largeur_pixels.py --zone dialogues
    python game/tools/largeur_pixels.py --marge 0            ne tolerer aucun depassement

Pourquoi
--------

La regle du projet dit « environ 40 caracteres par ligne ». C'est une regle de
pouce, et elle se trompe dans les deux sens : la police est a chasse variable,
donc `WWWWW` et `iiiii` ne font pas la meme largeur du tout. On refuse donc des
lignes qui tiendraient, et on en laisse passer qui debordent.

Or on peut mesurer. La police vit dans `pack/sys.bin`, en cases de 16x16 a
4 bits ; la largeur reelle d'un glyphe, c'est son encre. Il reste a connaitre la
largeur de la boite, et personne ne l'a ecrite nulle part.

D'ou l'etalonnage : **l'anglais d'origine tient forcement**. On mesure donc
toutes ses lignes et on prend la plus large comme limite. Ce n'est pas une
estimation, c'est une borne observee : le jeu affiche cette ligne-la sans la
couper, donc tout ce qui est en dessous passe.

Ce que l'outil ne sait pas
--------------------------

L'avance exacte entre deux glyphes (l'encre, plus combien ?) et la largeur de
l'espace, qui n'est pas dans la table de caracteres. On les prend en parametres,
et comme l'anglais et le francais sont mesures de la meme facon avec la meme
limite, une erreur constante se compense. Les valeurs par defaut sont calees sur
une capture du jeu : « Hehehe... Turns out there's more to it » fait 38 signes
pour environ 297 pixels, soit 7,8 par signe.
"""

from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path

RACINE = Path(__file__).resolve().parents[2]
ICI = Path(__file__).resolve().parent
sys.path.insert(0, str(ICI))


def a_cote(nom: str, *replis: Path) -> Path:
    """Le fichier a cote de l'outil (depot public), sinon son chemin prive.

    `generer_public.py` depose la table de caracteres et la table des largeurs
    dans `outils/`, a cote du script. Cote prive elles vivent ailleurs. Chercher
    les deux evite d'avoir a passer trois options a chaque appel.
    """
    proche = ICI / nom
    if proche.exists():
        return proche
    for r in replis:
        if r.exists():
            return r
    return replis[0] if replis else proche


JETON = re.compile(r"\{[A-Z]+\}|\(\*[^*]*\*\)|\[[0-9A-Fa-f]{4}\]")
# Le moteur remplace ces caracteres avant d'encoder : les mesurer autrement
# serait mesurer un texte que le jeu n'affiche pas.
ANCHOS = {"…": "...", "’": "'", "‘": "'", "“": '"', "”": '"', "—": "-", "–": "-"}


def lignes_affichees(texte: str) -> list[str]:
    """Le texte decoupe comme le jeu l'affiche : une entree par ligne a l'ecran."""
    for a, b in ANCHOS.items():
        texte = (texte or "").replace(a, b)
    # Tout ce qui termine une ligne a l'ecran : le saut manuel, le changement
    # de page, la fermeture de la boite, l'attente d'une touche, et le nom du
    # locuteur qui s'affiche dans son propre cadre.
    morceaux = re.split(r"\{SAUT\}|\{PAGE\}|\{FERME\}|\{ATTENTE\}|\(\*SPEAKER\*\)", texte)
    return [JETON.sub("", m) for m in morceaux]


# Une ligne de mise en scene (marqueurs de scene, remplissage) n'est jamais
# rendue dans une boite : l'inclure fausserait l'etalonnage, et la signaler
# serait du bruit. Trois signes suffisent a les ecarter.
REMPLISSAGE = re.compile(r"\s{6,}")
# Les repliques japonaises inutilisees : elles restent vides en francais et ne
# doivent pas servir d'etalon.
CJK = re.compile(r"[\u3040-\u30ff\u4e00-\u9fff]")


def est_affichee(ligne: str) -> bool:
    if REMPLISSAGE.search(ligne) or CJK.search(ligne):
        return False
    net = ligne.strip()
    return 0 < len(net) <= 60 and any(c.isalpha() for c in net)


# --- la metrique du jeu, pas une estimation ---------------------------------
#
# Offsets et regles repris de `game/tools/p1es/eboot.rb`, c'est-a-dire du
# moteur lui-meme. Ne pas les redefinir ailleurs : s'ils changent, ils doivent
# changer a un seul endroit.
TABLA_DIALOGO_OFF = 0x00264F0C
TABLA_MAPA_OFF = 0x0026460C
PASO_ENTRADA = 8
ESPACE_PX = 5  # `ori $t5, $zero, 5` dans ancho_glifo, pour le code 0
COPIAR = re.compile(r"\[(0x[0-9A-Fa-f]+),\s*(0x[0-9A-Fa-f]+),\s*'")


def substitutions(eboot_rb: Path) -> dict[int, int]:
    """{code accentue: code de la lettre de base}, lu dans eboot.rb.

    Le build recopie la metrique de la lettre de base sur chaque accent, parce
    qu'un accent ne change pas l'avancement (regle de Zenshou). Sans cette
    substitution, les accents valent (0,16) = 17 px et tout deborde.
    """
    texte = eboot_rb.read_text(encoding="utf-8", errors="replace")
    paires = {}
    for nom in ("COPIAR_ES", "COPIAR_PT", "COPIAR_FR"):
        debut = texte.find(nom + " = [")
        if debut < 0:
            continue
        fin = texte.find("]\n", debut)
        for a, b in COPIAR.findall(texte[debut:fin]):
            paires[int(a, 16)] = int(b, 16)
    return paires


def avances(eboot: Path, eboot_rb: Path, table=TABLA_DIALOGO_OFF) -> dict[int, int]:
    """{code: avance en pixels}, telle que le jeu la calcule."""
    octets = eboot.read_bytes()
    subs = substitutions(eboot_rb)
    out = {}
    for code in range(0x200):
        src = subs.get(code, code)
        off = table + src * PASO_ENTRADA
        if off + PASO_ENTRADA > len(octets):
            continue
        largeur = int.from_bytes(octets[off + 4 : off + 8], "little")
        # Au-dela de la plage latine on lit autre chose que la table : une
        # largeur de glyphe tient dans une case de 16 px, pas dans un mot de
        # 32 bits. Mieux vaut dire « inconnu » que mesurer du bruit.
        if largeur > 32:
            continue
        out[code] = largeur + 1
    out[0] = ESPACE_PX
    return out


def charger_police(sys_bin: Path):
    """{code du caractere: largeur d'encre en pixels}."""
    import patch_police as pp

    data = sys_bin.read_bytes()
    atlas = [pp.Atlas(data[o + pp.ENTETE : o + pp.ENTETE + pp.LARGEUR * h // 2], h) for o, h in pp.ATLAS]
    largeurs = {}
    for code in range(0x200):
        # Le meme partage que le moteur : en dessous de 0x100 la page des
        # majuscules, au-dessus la seconde page de l'atlas de dialogue.
        a = atlas[1] if code < 0x100 else atlas[2]
        if not a.contient(code if code < 0x100 else code - 0x100):
            continue
        grille = a.lire(code if code < 0x100 else code - 0x100)
        b = pp.bornes(grille)
        largeurs[code] = 0 if b is None else b[3] - b[2] + 1
    return largeurs


def avances_json(chemin: Path) -> dict[int, int]:
    """La table derivee, pour le depot public qui n'a pas l'EBOOT."""
    brut = json.loads(chemin.read_text(encoding="utf-8"))
    return {int(k): v for k, v in brut["avances"].items()}


def mesureur(
    tbl: Path,
    sys_bin: Path,
    avance: int,
    espace: int,
    eboot: Path = None,
    eboot_rb: Path = None,
    largeurs_json: Path = None,
):
    """Rend une fonction qui mesure une ligne en pixels.

    Avec l'EBOOT, on lit la metrique du jeu — c'est la seule mesure juste.
    Sans lui, on retombe sur l'encre de l'atlas, qui depanne mais se trompe
    jusqu'a sept pixels sur l'apostrophe.
    """
    codes = {}
    for ligne in tbl.read_text(encoding="utf-8").splitlines():
        if "=" not in ligne:
            continue
        hexa, car = ligne.split("=", 1)
        if len(hexa.strip()) == 4 and car:
            # Le DERNIER gagne, comme `car_a_valor[car] = valor` dans le moteur
            # (text.rb). La table donne deux codes a « é », 0x00AB et 0x00DA, et
            # seule la seconde case est dessinee par le patch de police.
            codes[car] = int(hexa.strip(), 16)
    if eboot and eboot.exists():
        largeurs = avances(eboot, eboot_rb)
        avance, espace = 0, largeurs[0]  # tout est deja dans la table
    elif largeurs_json and largeurs_json.exists():
        largeurs = avances_json(largeurs_json)
        avance, espace = 0, largeurs[0]
    else:
        # Dernier recours seulement : `patch_police` reste cote prive, et
        # l'encre est un proxy biaise (l'apostrophe y vaut 11 px pour 4 reels).
        largeurs = charger_police(sys_bin)
    inconnus = set()

    def mesurer(texte: str) -> int:
        total = 0
        for c in texte:
            if c == " ":
                total += espace
                continue
            code = codes.get(c)
            if code is None or code not in largeurs:
                inconnus.add(c)
                total += espace
                continue
            total += largeurs[code] + avance
        return total

    return mesurer, inconnus, largeurs, codes


def charger(zone_dir: Path):
    for chemin in sorted(zone_dir.glob("*.json")):
        if chemin.name.startswith("_"):
            continue
        entrees = json.loads(chemin.read_text(encoding="utf-8"))
        if isinstance(entrees, list):
            for e in entrees:
                if isinstance(e, dict):
                    yield chemin.name, e


def main(argv=None):
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument(
        "--racine",
        type=Path,
        default=RACINE / "game" / "scripts" if (RACINE / "game" / "scripts").is_dir() else Path("trad"),
    )
    ap.add_argument(
        "--sys",
        type=Path,
        default=RACINE / "game" / "extracted" / "PSP_GAME" / "USRDIR" / "pack" / "sys.bin",
    )
    ap.add_argument(
        "--tbl",
        type=Path,
        default=a_cote("persona1_psp.tbl", RACINE / "game" / "tools" / "p1es" / "persona1_psp.tbl"),
    )
    ap.add_argument("--zone", default="dialogues")
    ap.add_argument(
        "--eboot",
        type=Path,
        default=RACINE / ".work" / "game" / "EBOOT.BIN",
        help="EBOOT ou lire la metrique du jeu (sinon : mesure de l'encre, moins juste)",
    )
    ap.add_argument("--eboot-rb", type=Path, default=RACINE / "game" / "tools" / "p1es" / "eboot.rb")
    ap.add_argument(
        "--largeurs",
        type=Path,
        default=None,
        help="table derivee, employee quand l'EBOOT n'est pas la (depot public)",
    )
    ap.add_argument("--avance", type=int, default=1, help="pixels entre deux glyphes (defaut 1)")
    ap.add_argument("--espace", type=int, default=5, help="largeur de l'espace (defaut 5)")
    ap.add_argument("--marge", type=int, default=0, help="pixels tolerables au-dela de la limite")
    ap.add_argument("--glyphes", action="store_true", help="afficher la table des largeurs")
    ap.add_argument("--montrer", type=int, default=25, help="lignes fautives affichees")
    args = ap.parse_args(argv)

    # Sans --largeurs, chercher la table derivee a cote de l'outil : c'est la
    # disposition du depot public, ou `outils/` contient les deux.
    largeurs_json = args.largeurs or a_cote(
        "largeurs_glyphes.json", RACINE / "game" / "tools" / "largeurs_glyphes.json"
    )
    mesurer, inconnus, largeurs, codes = mesureur(
        args.tbl, args.sys, args.avance, args.espace, args.eboot, args.eboot_rb, largeurs_json
    )
    if args.eboot.exists():
        source = "table du jeu (EBOOT)"
    elif largeurs_json.exists():
        source = f"table derivee ({largeurs_json.name})"
    else:
        source = "encre de l'atlas — PROXY BIAISE, ne pas trancher la-dessus"

    if args.glyphes:
        par_car = sorted(
            ((c, largeurs.get(v, 0)) for c, v in codes.items() if v in largeurs),
            key=lambda x: -x[1],
        )
        print(f"  {len(par_car)} glyphes mesures dans {args.sys.name}")
        for c, lg in par_car[:20]:
            print(f"    {c!r:8} {lg:>3} px")
        print("    ...")
        for c, lg in par_car[-10:]:
            print(f"    {c!r:8} {lg:>3} px")
        return 0

    zone = args.racine / args.zone
    # L'etalonnage : la ligne anglaise la plus large du corpus tient forcement.
    limite, temoin = 0, ("", "")
    mesures_fr = []
    ecartees = 0
    for fichier, e in charger(zone):
        for ligne in lignes_affichees(e.get("en", "")):
            if not est_affichee(ligne):
                continue
            lg = mesurer(ligne)
            if lg > limite:
                limite, temoin = lg, (f"{fichier} {e['id']}", ligne)
        if e.get("fr"):
            for ligne in lignes_affichees(e["fr"]):
                if not est_affichee(ligne):
                    ecartees += 1
                    continue
                mesures_fr.append((mesurer(ligne), fichier, e["id"], ligne))

    print(f"  metrique : {source}, {len(largeurs)} codes")
    if inconnus:
        print(f"  {len(inconnus)} caractere(s) hors table, comptes comme un espace : {sorted(inconnus)[:12]}")
    print(f"\n  LIMITE ETALONNEE : {limite} px — la ligne anglaise la plus large de « {args.zone} »")
    print(f"    {temoin[0]}")
    print(f"    {temoin[1]!r}")

    plafond = limite + args.marge
    trop = sorted((m for m in mesures_fr if m[0] > plafond), reverse=True)
    print(
        f"\n  {len(mesures_fr)} lignes francaises mesurees ({ecartees} ecartees, techniques),"
        f" {len(trop)} au-dela de {plafond} px\n"
    )
    for lg, fichier, eid, ligne in trop[: args.montrer]:
        print(f"  +{lg - plafond:>3} px  ({lg} px)  {fichier} {eid}")
        print(f"      {ligne!r}")
    if len(trop) > args.montrer:
        print(f"  … et {len(trop) - args.montrer} autre(s)")
    return 1 if trop else 0


if __name__ == "__main__":
    sys.exit(main())
