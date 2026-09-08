#!/bin/bash
busco \
  -i input.fasta \
  -m transcriptome \
  -o busco_output \
  --out_path results/busco \
  -c 12 \
  --auto-lineage

agat_sp_statistics.pl --gff input.gff --output agat_stats.txt

agat_sp_keep_longest_isoform.pl -gff input.gff -o longest_isoforms.gff
