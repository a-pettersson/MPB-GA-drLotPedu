#!/bin/bash -ue
mkdir -p fastk_tmp

FastK \
    -v \
    -k41 \
    -t \
    -T28 \
    -Pfastk_tmp \
    -NLPED_27-55-68 \
     \
    LPED_27-55-68.downsampled.fastq.gz

# Generate GenomeScope2 input
Histex -G LPED_27-55-68.hist > LPED_27-55-68.histo

# Generate human readable text
Histex -A LPED_27-55-68.hist > LPED_27-55-68.txt

cat <<-END_VERSIONS > versions.yml
"FASTK":
    fastk: $(FastK -v | head -n 1 | awk '{print $2}')
END_VERSIONS
