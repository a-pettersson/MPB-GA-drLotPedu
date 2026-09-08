#!/usr/bin/env bash
set -euo pipefail

INPUT_FA="raw-data/LPED_curated_final.renamed.fa"
OUT_DIR="results/assembly-split"
PREFIX="drLotPedu.AARHUS.ETHZ.v1"

while getopts ":i:o:p:h" opt; do
  case "$opt" in
    i) INPUT_FA="$OPTARG" ;;
    o) OUT_DIR="$OPTARG" ;;
    p) PREFIX="$OPTARG" ;;
    h)
      cat <<'EOF'
Split a combined haplotype FASTA into hap1, hap2, and unplaced files.

Options:
  -i  Input FASTA          (default: raw-data/LPED_curated_final.renamed.fa)
  -o  Output directory     (default: results/assembly-split)
  -p  Assembly name prefix (default: drLotPedu.AARHUS.ETHZ.v1)
  -h  Show this help
EOF
      exit 0
      ;;
    \?) echo "Error: invalid option -$OPTARG" >&2; exit 1 ;;
    :)  echo "Error: option -$OPTARG requires an argument" >&2; exit 1 ;;
  esac
done

if [[ ! -f "$INPUT_FA" ]]; then
  echo "Error: input FASTA not found: $INPUT_FA" >&2
  exit 1
fi

if ! command -v gawk >/dev/null 2>&1; then
  echo "Error: gawk is required but not found in PATH." >&2
  exit 1
fi

if ! command -v seqkit >/dev/null 2>&1; then
  echo "Error: seqkit is required for the sorting step but not found in PATH." >&2
  exit 1
fi

mkdir -p "$OUT_DIR"

HAP1_FA="${OUT_DIR}/${PREFIX}.hap1.fa"
HAP2_FA="${OUT_DIR}/${PREFIX}.hap2.fa"
UP1_FA="${OUT_DIR}/${PREFIX}.hap1-unplaced.fa"
UP2_FA="${OUT_DIR}/${PREFIX}.hap2-unplaced.fa"
TSV="${OUT_DIR}/${PREFIX}.rename-map.tsv"


> "$HAP1_FA"; > "$HAP2_FA"; > "$UP1_FA"; > "$UP2_FA"


printf 'old_name\tnew_name\thaplotype\n' > "$TSV"

echo "[1/3] Splitting FASTA by haplotype..."

gawk \
  -v hap1="$HAP1_FA" \
  -v hap2="$HAP2_FA" \
  -v up1="$UP1_FA"   \
  -v up2="$UP2_FA"   \
  -v tsv="$TSV"      \
'
/^>/ {
  # Parse sequence name (first whitespace-delimited token after >)
  line = substr($0, 2)
  name = line
  sub(/ .*/, "", name)

  # Parse first contig in orig= field
  orig = line
  if (orig ~ /orig=/) {
    sub(/.*orig=/, "", orig)
    sub(/[, ].*/, "", orig)   # first token only
  }

  hap = substr(orig, 1, 2)   # "h1" or "h2"

  if (name ~ /^Scaffold_/) {
    new_name = name
    outf = (hap == "h1") ? hap1 : hap2
  } else {
    if (hap == "h1") { n1++; new_name = "unplaced-sequence-" n1; outf = up1 }
    else             { n2++; new_name = "unplaced-sequence-" n2; outf = up2 }
  }

  print ">" new_name > outf
  print name "\t" new_name "\t" hap >> tsv
  next
}
outf != "" { print > outf }
' "$INPUT_FA"

echo "[2/3] Sorting scaffold files by sequence length (largest first)..."

sort_scaffolds_by_length() {
  local fa="$1"
  local tmp="${fa}.sort.tmp"
  seqkit sort --by-length --reverse --out-file "$tmp" "$fa" && mv "$tmp" "$fa"
}

sort_scaffolds_by_length "$HAP1_FA"
sort_scaffolds_by_length "$HAP2_FA"

echo "[3/3] Summary:"
for fa in "$HAP1_FA" "$HAP2_FA" "$UP1_FA" "$UP2_FA"; do
  count=$(grep -c '^>' "$fa")
  printf "  %-65s  %d sequences\n" "$(basename "$fa")" "$count"
done

n_up1=$(grep -c '^>' "$UP1_FA")
n_up2=$(grep -c '^>' "$UP2_FA")
printf "  Total unplaced: %d (hap1: %d, hap2: %d)\n" \
  $(( n_up1 + n_up2 )) "$n_up1" "$n_up2"
echo "  Rename map: $TSV"
echo "Done."
