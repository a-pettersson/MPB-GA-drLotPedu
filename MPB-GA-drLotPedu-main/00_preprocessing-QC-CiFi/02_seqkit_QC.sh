#!/bin/bash -ue    
    # We add a header for pandas
    printf "ReadID\tLength\tGC\tAvgQual\n" > LPED_27-55-68_DpnII.fx2tab.tsv
    seqkit fx2tab -n -i -l -g -q LPED_27-55-68_DpnII.merged.fastq.gz >> LPED_27-55-68_DpnII.fx2tab.tsv
    
    # 1. Histograms w/ seqkit watch
    seqkit watch -f ReadLen  -y LPED_27-55-68_DpnII.merged.fastq.gz 2> LPED_27-55-68_DpnII.readlen.hist
    seqkit watch -f MeanQual -y LPED_27-55-68_DpnII.merged.fastq.gz 2> LPED_27-55-68_DpnII.qual.hist
    seqkit watch -f GC       -y LPED_27-55-68_DpnII.merged.fastq.gz 2> LPED_27-55-68_DpnII.gc.hist
    
    cat <<-END_VERSIONS > versions.yml
    "SEQKIT_QC":
        seqkit: $(seqkit version | sed 's/seqkit v//')
END_VERSIONS
