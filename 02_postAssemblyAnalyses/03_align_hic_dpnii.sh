#!/bin/bash -ue

bwa mem -5SP \
    -R '@RG\tID:DpnII\tSM:LPED_27-55-68' \
    -t 28 \
    LPED_27-55-68_combined.fa \
    LPED_27-55-68_DpnII_cifi_R1.fastq.gz \
    LPED_27-55-68_DpnII_cifi_R2.fastq.gz \
    | samtools view -@ 14 -S -h -b -F 2316 \
    -o LPED_27-55-68_combined_DpnII.bam

cat <<-END_VERSIONS > versions.yml
"ALIGN_HIC":
    bwa: $(bwa 2>&1 | grep Version | sed 's/Version: //')
    samtools: $(samtools --version | head -1 | sed 's/samtools //')
END_VERSIONS
