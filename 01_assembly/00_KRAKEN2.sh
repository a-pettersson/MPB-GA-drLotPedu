#!/bin/bash -ue
# Verify DB exists (basic check)
if [ ! -f "Kraken2DB/hash.k2d" ] && [ ! -f "Kraken2DB/taxo.k2d" ]; then
    echo "Error: Kraken2 DB files not found in Kraken2DB"
    echo "Please run: ./setup.sh --setup-kraken2"
    exit 1
fi

kraken2 \
    --db Kraken2DB \
    --threads 28 \
    --report LPED_27-55-68.kraken2.report.txt \
     \
    --unclassified-out LPED_27-55-68.unclassified.fastq \
     \
    LPED_27-55-68.merged.fastq.gz > LPED_27-55-68.kraken2.output.txt

cat <<-END_VERSIONS > versions.yml
"KRAKEN2":
    kraken2: $(kraken2 --version 2>&1 | head -n 1 | sed 's/^.*version //; s/ .*$//')
END_VERSIONS
