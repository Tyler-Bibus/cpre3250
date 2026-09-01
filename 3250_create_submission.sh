# EE / CprE / CybE 3250: Machine Learning in ECpE
# Joseph Zambreno
# 06/28/26
# 3250_create_submission.sh - run this script to create a submission package for the lab assignment


#!/usr/bin/env bash

# Usage:
#   ../3250_create_submission.sh
# When run out of Lab-01, it will take Lab-01.ipynb and convert to Lab-01.pdf


set -e

DIR=$(basename "$(pwd)")
INFILE="$DIR.ipynb"
OUTPDF="$DIR.pdf"
OUTZIP="$DIR.zip"

OUTDIR=$(dirname "$OUTPDF")
OUTBASE=$(basename "$OUTPDF" .pdf)

TMP_NB=$(mktemp)
TMP_NB="${TMP_NB}.ipynb"

# --- Filter + inject CSS ---
python3 - "$INFILE" "$TMP_NB" <<'PYCODE'
import nbformat
from nbformat.v4 import new_markdown_cell
from datetime import datetime
import sys, os

infile = os.path.abspath(sys.argv[1])
outfile = sys.argv[2]

nb = nbformat.read(infile, as_version=4)

filtered = []


# ✅ Add lab header
lab_name = os.path.splitext(os.path.basename(infile))[0]
date_str = datetime.now().strftime("%Y-%m-%d %H:%M")

filtered.append(new_markdown_cell(f"## {lab_name} Report: Generated {date_str}"))


# ✅ Single reliable CSS injection (works with Chromium exporter)
css = """
<style>
pre, .jp-CodeCell pre, .jp-OutputArea pre {
    white-space: pre-wrap !important;
    word-break: break-word !important;
}

.jp-OutputArea, .jp-OutputArea-output {
    max-width: 100% !important;
}

img, svg {
    max-width: 100% !important;
    height: auto !important;
}

@page {
    margin: 0.75in;
}
</style>
"""

filtered.append(new_markdown_cell(css))

for cell in nb.cells:
    tags = cell.get("metadata", {}).get("tags", [])

    if cell.cell_type == "markdown" and "submit-answer" in tags:
        filtered.append(cell)

    elif cell.cell_type == "code" and "submit-code" in tags:
        filtered.append(cell)

nb.cells = filtered
nbformat.write(nb, outfile)
PYCODE

# --- Ensure output dir exists ---
mkdir -p "$OUTDIR"



# --- Convert using Chromium ---
jupyter nbconvert \
  --to webpdf \
  --template lab \
  --no-prompt \
  "$TMP_NB" \
  --output "$DIR" \
  --output-dir .



# --- Create ZIP with notebook ---
zip -q "$OUTZIP" "$INFILE"


rm -f "$TMP_NB"


# --- Colorized output message ---
GREEN="\033[0;32m"
BLUE="\033[1;34m"
YELLOW="\033[1;33m"
NC="\033[0m"  # No Color


printf "\n${GREEN}✅ Files successfully generated!${NC}\n\n"
printf "${BLUE}📄 PDF:${NC}  %s\n" "$OUTPDF"
printf "${BLUE}📦 ZIP:${NC}  %s\n\n" "$OUTZIP"
printf "${YELLOW}👉 Please upload BOTH files to Canvas:${NC}\n"
printf "   - %s\n" "$OUTPDF"
printf "   - %s\n\n" "$OUTZIP"



