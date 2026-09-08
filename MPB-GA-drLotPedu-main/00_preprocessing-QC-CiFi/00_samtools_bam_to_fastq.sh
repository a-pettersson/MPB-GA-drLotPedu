#!/bin/bash -ue
samtools fastq \
     \
    -n \
    -@ 4 \
    m84151_251216_180049_s2.hifi_reads_bc2145.bam \
    | bgzip -@ 20 > LPED_27-55-68.fastq.gz

cat <<-END_VERSIONS > versions.yml
"SAMTOOLS_FASTQ":
    samtools: $(echo $(samtools --version 2>&1) | sed 's/^.*samtools //; s/Using.*$//')
END_VERSIONS
