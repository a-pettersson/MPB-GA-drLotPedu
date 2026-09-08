#!/usr/bin/env bash
set -euo pipefail

OUT_DIR="results/assembly-split"
PREFIX="drLotPedu.AARHUS.ETHZ.v1"

while getopts ":o:p:h" opt; do
  case "$opt" in
    o) OUT_DIR="$OPTARG" ;;
    p) PREFIX="$OPTARG" ;;
    h)
      cat <<'EOF'


Options:
  -o  Output directory 
  -p  Assembly name prefix
  -h  Show this help
EOF
      exit 0
      ;;
    \?) echo "Error: invalid option -$OPTARG" >&2; exit 1 ;;
    :)  echo "Error: option -$OPTARG requires an argument" >&2; exit 1 ;;
  esac
done

HAP1_FA="${OUT_DIR}/${PREFIX}.hap1.fa"
HAP2_FA="${OUT_DIR}/${PREFIX}.hap2.fa"
TSV="${OUT_DIR}/${PREFIX}.rename-map.tsv"

for fa in "$HAP1_FA" "$HAP2_FA"; do
  if [[ ! -f "$fa" ]]; then
    echo "Error: file not found: $fa" >&2
    exit 1
  fi
done

if [[ ! -f "$TSV" ]]; then
  echo "Error: TSV file not found: $TSV" >&2
  exit 1
fi

# Temporary files
HAP1_TMP="${HAP1_FA}.renamed.tmp"
HAP2_TMP="${HAP2_FA}.renamed.tmp"
TSV_TMP="${TSV}.renamed.tmp"

# Rename hap1
gawk '
/^>Scaffold_/ {
  chr_num = ++count
  print ">chr" chr_num
  next
}
{print}
' "$HAP1_FA" > "$HAP1_TMP"

declare -A map_h1
while read old new; do
  map_h1["$old"]="$new"
done < <(gawk '
/^>Scaffold_/ {
  old_name = substr($0, 2)
  chr_num = ++count
  new_name = "chr" chr_num
  print old_name, new_name
}
' "$HAP1_FA")

# Rename hap2
declare -A map_h2
while read old new; do
  map_h2["$old"]="$new"
done < <(gawk '
/^>Scaffold_/ {
  old_name = substr($0, 2)
  chr_num = ++count
  new_name = "chr" chr_num
  print old_name, new_name
}
' "$HAP2_FA")

# Rename hap2 file
gawk '
/^>Scaffold_/ {
  old_name = substr($0, 2)
  chr_num = ++count
  print ">chr" chr_num
  next
}
{print}
' "$HAP2_FA" > "$HAP2_TMP"

{
  head -1 "$TSV"
  tail -n +2 "$TSV" | while read old_name new_name haplotype; do
    if [[ "$haplotype" == "hap1" && -n "${map_h1[$old_name]:-}" ]]; then
      echo -e "$old_name\t${map_h1[$old_name]}\t$haplotype"
    elif [[ "$haplotype" == "hap2" && -n "${map_h2[$old_name]:-}" ]]; then
      echo -e "$old_name\t${map_h2[$old_name]}\t$haplotype"
    else
      # Unplaced sequences remain unchanged
      echo -e "$old_name\t$new_name\t$haplotype"
    fi
  done
} > "$TSV_TMP"

mv "$HAP1_TMP" "$HAP1_FA"
mv "$HAP2_TMP" "$HAP2_FA"
mv "$TSV_TMP" "$TSV"

echo "  $HAP1_FA"
echo "  $HAP2_FA"
