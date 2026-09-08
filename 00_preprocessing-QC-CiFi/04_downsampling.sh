#!/bin/bash -ue
# 1. Get Total Bases from FASTQ
TOTAL_BASES=$(seqkit stats -T LPED_27-55-68.merged.fastq.gz | tail -n+2 | cut -f 5 | sed 's/,//g')
echo "Total Input Bases:       $TOTAL_BASES"
echo "Haploid Genome Size:     541000000"
echo "Haploid Target Coverage: 80x"

# 2. Calculate Proportion
# prop = (hap_genome_size * 80) / total_bases
PROP=$(awk -v g=541000000 -v c=80 -v t=$TOTAL_BASES \
    'BEGIN { if (t==0) print 1; else printf "%.6f", (g * c) / t }')
echo "Calculated Proportion: $PROP"

# 3. Downsample or pass through
DO_SAMPLE=$(awk -v p=$PROP 'BEGIN { if (p < 1.0) print 1; else print 0 }')

if [ "$DO_SAMPLE" -eq 1 ]; then
    echo "Downsampling to approx 80x..."
    # -s 11 is a fixed seed for reproducibility
    seqkit sample -p $PROP -s 11 LPED_27-55-68.merged.fastq.gz -o LPED_27-55-68.downsampled.fastq.gz
else
    echo "Current coverage is at or below target, keeping all reads."
    ln -s LPED_27-55-68.merged.fastq.gz LPED_27-55-68.downsampled.fastq.gz
fi

cat <<-END_VERSIONS > versions.yml
"DOWNSAMPLE_FASTQ":
    seqkit: $(echo $(seqkit version 2>&1) | sed 's/^.*v//; s/ .*$//')
END_VERSIONS
