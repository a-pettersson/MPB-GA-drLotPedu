#!/bin/bash -ue
# Extract Length, GC, AvgQual

    # We add a header for pandas
    printf "ReadID\tLength\tGC\tAvgQual\n" > LPED_27-55-68_downsampled.fx2tab.tsv
    seqkit fx2tab -n -i -l -g -q LPED_27-55-68.downsampled.fastq.gz >> LPED_27-55-68_downsampled.fx2tab.tsv

    # --- ADVANCED QC ---
    
    # 1. Histograms (seqkit watch)
    # Dump (-y) histograms to text files (output goes to stderr)
    seqkit watch -f ReadLen  -y LPED_27-55-68.downsampled.fastq.gz 2> LPED_27-55-68_downsampled.readlen.hist
    seqkit watch -f MeanQual -y LPED_27-55-68.downsampled.fastq.gz 2> LPED_27-55-68_downsampled.qual.hist
    seqkit watch -f GC       -y LPED_27-55-68.downsampled.fastq.gz 2> LPED_27-55-68_downsampled.gc.hist
    
    cat <<-END_VERSIONS > versions.yml
    "SEQKIT_QC_DOWNSAMPLED":
        seqkit: $(seqkit version | sed 's/seqkit v//')
END_VERSIONS
