#!/bin/bash -ue
hifiasm \
    -o LPED_27-55-68 \
    -t 28 \
    --telo-m CCCTAAA \
    --h1 LPED_27-55-68_HindIII_cifi_R1.fastq.gz,LPED_27-55-68_DpnII_cifi_R1.fastq.gz \
    --h2 LPED_27-55-68_HindIII_cifi_R2.fastq.gz,LPED_27-55-68_DpnII_cifi_R2.fastq.gz \
    -l 3 \
    --hg-size 541m \
     \
    LPED_27-55-68.downsampled.fastq.gz

cat <<-END_VERSIONS > versions.yml
"HIFIASM_UNI":
    hifiasm: $(hifiasm --version 2>&1)
END_VERSIONS
