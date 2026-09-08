#!/bin/bash -ue

samtools merge -@ 14 LPED_27-55-68_combined.merged.bam LPED_27-55-68_combined_HindIII.bam LPED_27-55-68_combined_DpnII.bam

ln -s LPED_27-55-68_combined.merged.bam LPED_27-55-68_combined.filtered.bam

cat <<-END_VERSIONS > versions.yml
"MERGE_FILTER_BAM":
    samtools: $(samtools --version | head -1 | sed 's/samtools //')
END_VERSIONS
