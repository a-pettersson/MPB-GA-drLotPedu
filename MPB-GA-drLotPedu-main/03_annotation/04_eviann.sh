#!/bin/bash
eviann.sh \
  -t 20 \
  -g raw-data/genome.fa \
  -r raw-data/reads_list.txt \
  -p raw-data/protein.db \
  -d 2 \
  --verbose
