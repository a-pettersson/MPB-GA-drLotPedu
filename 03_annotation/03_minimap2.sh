#!/bin/bash
minimap2 \
  -x asm5 \
  -t 8 \
  -k 19 \
  -p 0.8 \
  -N 5 \
  -K 50M \
  -X \
  raw-data/LPED_curated_final.renamed.fa raw-data/LPED_curated_final.renamed.fa > results/minimap2_all_vs_all/all_vs_all.raw.paf
