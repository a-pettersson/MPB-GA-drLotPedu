#!/bin/bash
apptainer exec \
  -B "raw-data/raw-data-eggnog:/usr/local/lib/python3.10/site-packages/data" \
  -B "raw-data:/input" \
  -B "results/eggnog:/output" \
  -B "/tmp:/temp" \
  raw-data/eggnog-mapper-v2.1.13.sif \
  emapper.py \
  -m mmseqs \
  -i "/input/proteins.fasta" \
  --itype proteins \
  --data_dir /data \
  -o eggnog_out \
  --output_dir /output \
  --cpu 14 \
  --tax_scope auto \
  --target_taxa "" \
  --go_evidence non-electronic
