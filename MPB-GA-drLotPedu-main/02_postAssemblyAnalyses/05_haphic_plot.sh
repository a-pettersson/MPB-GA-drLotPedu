#!/bin/bash -ue

mkdir -p viz
cd viz

/opt/HapHiC/scripts/HapHiC_plot.py \
    /scratch/alexander/haphicplot-pretextscaffoldedassembly/map.pretext.agp_1_corrected.agp \
    /scratch/alexander/haphicplot-pretextscaffoldedassembly/LPED_27-55-68_pretext_components.filtered.bam \
    --cmap viridis

cd ..

cat <<-END_VERSIONS > versions.yml
"HAPHIC_PLOT":
    haphic: $(haphic --version 2>&1 || echo 'unknown')
END_VERSIONS
