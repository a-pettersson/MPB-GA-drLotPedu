#!/bin/bash
apptainer exec \
  -B "raw-data/raw-data-interproscan/interproscan-5.77-108.0/data:/opt/interproscan/data" \
  -B "raw-data:/input" \
  -B "/tmp:/temp" \
  -B "results/interproscan:/output" \
  raw-data/interproscan_5.77-108.0.sif \
  /opt/interproscan/interproscan.sh \
  --input "/input/proteins.fasta" \
  --tempdir /temp \
  --output-dir /output \
  --cpu 7 \
  --formats TSV \
  --seqtype p \
  --disable-precalc
