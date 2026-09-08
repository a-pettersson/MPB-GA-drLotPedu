#!/bin/bash -ue

MERGED_BAM=${MERGED_BAM:-LPED_27-55-68_combined.merged.bam}
REFERENCE_FA=${REFERENCE_FA:-LPED_27-55-68_combined.fa}
PRETEXT_DIR=${PRETEXT_DIR:-pretextview}
PRETEXT_MAP=${PRETEXT_MAP:-${PRETEXT_DIR}/map.pretext}
CURRENT_AGP=${CURRENT_AGP:-${PRETEXT_DIR}/current/map.agp}
CORRECTED_AGP=${CORRECTED_AGP:-corrected_scaffs.agp}
CURATED_FA=${CURATED_FA:-curated.fa}

mkdir -p "${PRETEXT_DIR}" "${PRETEXT_DIR}/current"

samtools view -@ 11 -h "${MERGED_BAM}" \
    | PretextMap -o "${PRETEXT_MAP}" \
        --sortby length \
        --sortorder descend \
        --mapq 0 \
        --ultraRes

if [[ -f "${CURRENT_AGP}" ]]; then
    AGPCorrect "${REFERENCE_FA}" "${CURRENT_AGP}" > "${CORRECTED_AGP}"
    agp_to_fasta "${CORRECTED_AGP}" "${REFERENCE_FA}" > "${CURATED_FA}"
else
    cat <<EOF
Pretext map written to: ${PRETEXT_MAP}
EOF
fi

cat <<-END_VERSIONS > versions.yml
"PRETEXT_BRIDGE":
    samtools: $(samtools --version | head -1 | sed 's/samtools //')
    pretextmap: $(PretextMap --version 2>&1 || echo "unknown")
    agpcorrect: $(AGPCorrect 2>&1 | head -1 || echo "unknown")
    agp_to_fasta: $(agp_to_fasta 2>&1 | head -1 || echo "unknown")
END_VERSIONS
