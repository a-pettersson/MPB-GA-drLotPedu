#!/bin/bash -ue

export MPLCONFIGDIR=${PWD}/matplotlib_cache
export FONTCONFIG_PATH=${PWD}/fontconfig_cache
export XDG_CACHE_HOME=${PWD}/xdg_cache
mkdir -p ${MPLCONFIGDIR} ${FONTCONFIG_PATH} ${XDG_CACHE_HOME}

run_paqman() {
    local assembly_file="$1"
    local summary_suffix="$2"
    local output_prefix="$3"
    local converted_assembly=""
    local input_assembly="$assembly_file"

    if [[ "${input_assembly}" == *.gfa ]]; then
        converted_assembly="$(mktemp "${PWD}/assembly.XXXXXX.fa")"
        awk '/^S/{print ">"$2; print $3}' "${input_assembly}" > "${converted_assembly}"
        input_assembly="${converted_assembly}"
    fi

    rm -rf paqman_output

    paqman.sh \
        -a "${input_assembly}" \
        -l LPED_27-55-68.downsampled.fastq.gz \
        -x pacbio-hifi \
        --buscodb fabales \
        -t 20 \
        -r TTTAGGG \
        -cm 50 \
        -sm 19G \
        --meryldb LPED_27-55-68_k21.meryl \
        -w 30000 \
        -s 10000 \
        -p "${output_prefix}" \
        -c yes \
        --sequences contigs

    mv paqman_output/summary_stats.tsv "paqman_output/summary_stats_${summary_suffix}.tsv"

    if [[ -n "${converted_assembly}" ]]; then
        rm -f "${converted_assembly}"
    fi
}

run_paqman "LPED_27-55-68.hic.p_ctg.gfa" "LPED_27-55-68_hifiasm_primary" "LPED_27-55-68_hifiasm_primary"
run_paqman "LPED_27-55-68.hic.hap1.p_ctg.gfa" "LPED_27-55-68_hifiasm_hap1" "LPED_27-55-68_hifiasm_hap1"
run_paqman "LPED_27-55-68.hic.hap2.p_ctg.gfa" "LPED_27-55-68_hifiasm_hap2" "LPED_27-55-68_hifiasm_hap2"

cat <<-END_VERSIONS > versions.yml
"PAQMAN":
    paqman: $(paqman.sh --version 2>&1 || echo "unknown")
END_VERSIONS
