#!/bin/bash -ue
cat */*.fastq.gz > LPED_27-55-68_DpnII.merged.fastq.gz

cat <<-END_VERSIONS > versions.yml
"CONCAT_FASTQ":
    cat: $(echo $(cat --version 2>&1) | sed 's/^.*coreutils) //; s/ .*$//')
END_VERSIONS
