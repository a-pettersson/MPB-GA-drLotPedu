#!/bin/bash -ue

zcat LPED_27-55-68_DpnII.merged.fastq.gz | python3 /home/apettersson/projects/denovo-assembly/workflow/bin/cifi_expander.py \
    --input - \
    --r1_out LPED_27-55-68_DpnII_cifi_R1.fastq \
    --r2_out LPED_27-55-68_DpnII_cifi_R2.fastq \
    --enzyme DpnII \
    --min_len 50 \
     \
    --report_prefix LPED_27-55-68_DpnII_cifi

pigz -p 14 LPED_27-55-68_DpnII_cifi_R1.fastq &
pigz -p 14 LPED_27-55-68_DpnII_cifi_R2.fastq
wait  # Wait for both background pigz processes to complete

cat <<-END_VERSIONS > versions.yml
"CIFI_TO_HIC":
    cifi_expander: 1.0
    pigz: $(pigz --version 2>&1 | head -n 1 | sed 's/pigz //')
END_VERSIONS
