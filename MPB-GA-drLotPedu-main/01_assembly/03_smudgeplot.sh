#!/bin/bash -ue
export MPLCONFIGDIR=$(pwd)/.matplotlib
export PATH=$PATH:$(pwd)/fastk_bin
mkdir -p .matplotlib

REAL_KTAB=$(readlink -f "LPED_27-55-68.ktab")
FASTK_WORKDIR=$(dirname "$REAL_KTAB")

# Copy the hidden chunk files to the current directory safely
cp "$FASTK_WORKDIR"/.*LPED_27-55-68.ktab.* . 2>/dev/null || true

# Step 1: Hetmers (Search)
smudgeplot hetmers \
    -L 12 \
    -t 20 \
    -o LPED_27-55-68_smudge \
    LPED_27-55-68.ktab

# Step 2: Plotting
smudgeplot all \
    -o LPED_27-55-68_smudgeplot \
    LPED_27-55-68_smudge.smu

cat <<-END_VERSIONS > versions.yml
"SMUDGEPLOT":
    smudgeplot: $(smudgeplot --version | sed 's/^.*version //')
END_VERSIONS

rm -f .*LPED_27-55-68.ktab.*
