#!/usr/bin/env bash
set -euo pipefail

list="$1"                    # text file: 1 FASTA path per line
mode="${2:-length}"          # id|name|sequence|length

case "$mode" in
  id)       flags=() ;;
  name)     flags=(-n) ;;
  sequence) flags=(-s) ;;
  length)   flags=(-l -r) ;;   # largest -> shortest
  *) echo "Mode must be: id | name | sequence | length" >&2; exit 1 ;;
esac

while IFS= read -r fa || [[ -n "$fa" ]]; do
  [[ -z "$fa" || "$fa" =~ ^# ]] && continue
  tmp="$(mktemp "${fa}.sorttmp.XXXXXX")"
  if seqkit sort "${flags[@]}" -2 -U "$fa" -o "$tmp"; then
    mv -f "$tmp" "$fa"
  else
    rm -f "$tmp"
    exit 1
  fi
done < "$list"