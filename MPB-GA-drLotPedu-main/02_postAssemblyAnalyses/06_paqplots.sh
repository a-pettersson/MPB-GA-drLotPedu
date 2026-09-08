#!/bin/bash -ue

summary_files=(
    summary_stats_LPED_27-55-68_hifiasm_hap1.tsv
    summary_stats_LPED_27-55-68_hifiasm_primary.tsv
    summary_stats_LPED_27-55-68_hifiasm_hap2.tsv
    summary_stats_LPED_27-55-68_haphic_combined.tsv
)

head -n 1 "${summary_files[0]}" > combined_summary.tsv
for summary_file in "${summary_files[@]}"; do
    tail -n +2 "${summary_file}" >> combined_summary.tsv
done

paqplots.sh \
    -s combined_summary.tsv \
    -p LPED_27-55-68 \
    -o paqplot_output

cat <<-END_VERSIONS > versions.yml
"PAQPLOTS":
    paqplots: $(paqplots.sh --version 2>&1 || echo "unknown")
END_VERSIONS
