#!/bin/bash -ue
export XDG_CACHE_HOME=$(pwd)/.cache
mkdir -p .cache

genomescope2 \
    -i LPED_27-55-68.histo \
    -o LPED_27-55-68_genomescope2_out \
    -k 41 \
    -p 2 \

cat <<-END_VERSIONS > versions.yml
"GENOMESCOPE2":
    genomescope2: $(genomescope2 -v | sed 's/^.*version //')
END_VERSIONS
