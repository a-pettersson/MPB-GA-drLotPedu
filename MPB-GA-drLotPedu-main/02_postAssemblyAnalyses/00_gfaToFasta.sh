#!/bin/bash -ue
awk '/^S/{print ">"$2; print $3}' LPED_27-55-68.hic.hap1.p_ctg.gfa > hap1.fa
awk '/^S/{print ">"$2; print $3}' LPED_27-55-68.hic.hap2.p_ctg.gfa > hap2.fa
cat hap1.fa hap2.fa > LPED_27-55-68_combined.fa
bwa index LPED_27-55-68_combined.fa

cat <<-END_VERSIONS > versions.yml
"PREPARE_ASSEMBLY":
    bwa: $(bwa 2>&1 | grep Version | sed 's/Version: //')
END_VERSIONS
