#!/usr/bin/env python3
import sys
import argparse
import itertools
import random
from Bio import Restriction

import os

os.environ['MPLCONFIGDIR'] = '/tmp/matplotlib'

# Must be done before importing pyplot
try:
    import matplotlib
    matplotlib.use('Agg') # Force non-interactive backend
    import matplotlib.pyplot as plt
    import seaborn as sns
    import pandas as pd
    VIZ_AVAILABLE = True
except ImportError:
    VIZ_AVAILABLE = False

def parse_fastq(file_handle):
    """Memory efficient 4-line FASTQ parser."""
    while True:
        header = file_handle.readline()
        if not header: break
        seq = file_handle.readline()
        sep = file_handle.readline()
        qual = file_handle.readline()
        yield header.strip(), seq.strip(), qual.strip()

def reservoir_sample(data_list, item, max_size=1_000_000):
    """
    Prevent Memory Explosion.
    """
    if len(data_list) < max_size:
        data_list.append(item)
    else:
        if random.random() < (max_size / (len(data_list) + 10000)):
             idx = random.randint(0, len(data_list) - 1)
             data_list[idx] = item

def calculate_expected_pairs(num_monomers, max_dist=None):
    """
    Calculate the expected number of pairs for a given number of monomers
    and optional max_dist constraint.
    
    With no max_dist: C(n,2) = n*(n-1)/2 (all pairwise combinations)
    With max_dist d:  sum from k=1 to min(d, n-1) of (n-k)
    
    This is used for the binomial integrity check.
    """
    if num_monomers < 2:
        return 0
    if max_dist is None:
        return (num_monomers * (num_monomers - 1)) // 2
    else:
        return sum(num_monomers - k for k in range(1, min(max_dist + 1, num_monomers)))

def generate_pairs(monomers, max_dist=None):
    if max_dist is None:
        return list(itertools.combinations(monomers, 2))
    else:
        pairs = []
        n = len(monomers)
        for i in range(n):
            for j in range(i + 1, min(i + 1 + max_dist, n)):
                pairs.append((monomers[i], monomers[j]))
        return pairs

def generate_report(stats, args, output_prefix): 
    total_expanded = stats['expanded']
    total_processed = stats['processed']
    enz_name = args.enzyme
    
    # 1. Text Report
    report_file = f"{output_prefix}_report.txt"
    try:
        with open(report_file, 'w') as f:
            f.write("="*40 + "\n")
            f.write("       CONCATEMER EXPANSION REPORT\n")
            f.write("="*40 + "\n")
            f.write(f"total input concatemers: {total_processed}\n")
            f.write(f"enzyme: {enz_name}\n")
            f.write(f"minimum fragment length: {args.min_len} bp\n")
            if args.max_dist is not None:
                f.write(f"max pair distance: {args.max_dist} (proximity-limited pairing)\n")
            else:
                f.write(f"max pair distance: unlimited (all pairwise combinations)\n")
            f.write("\n")
            
            n_frags = stats['frag_counts']
            n_short = stats['short_counts']
            n_pairs = stats['pair_counts']
            
            f.write(f"stream ({enz_name}):\n")
            f.write(f"  - recovered concatemers: {total_expanded}\n")
            f.write(f"  - total fragments: {n_frags}\n")
            f.write(f"  - fragments < min_len: {n_short}\n")
            f.write(f"  - synthetic pairs generated: {n_pairs}\n")
            
            if stats['total_generated_pairs'] == stats['total_theoretical_pairs']:
                f.write(f"  - combinatorial logic check: pass ({stats['total_generated_pairs']} == {stats['total_theoretical_pairs']})\n")
            else:
                f.write(f"  - combinatorial logic check: fail ({stats['total_generated_pairs']} =/= {stats['total_theoretical_pairs']})\n")

    except Exception as e:
        sys.stderr.write(f"Warning: Could not write text report: {e}\n")

    # 2. Visualization
    if VIZ_AVAILABLE and stats['valid_lengths_sample']:
        png_file = f"{output_prefix}_report.png"
        svg_file = f"{output_prefix}_report.svg"
        
        try:
            sns.set_theme(style="whitegrid", font="monospace")
            fig, axs = plt.subplots(1, 3, figsize=(21, 6))
            
            df_frags = pd.DataFrame(stats['valid_lengths_sample'], columns=['Length', 'Enzyme'])
            df_pairs = pd.DataFrame(stats['pairs_per_concatemer_sample'], columns=['Pairs', 'Enzyme'])
            df_frags_per_conc = pd.DataFrame(stats['frags_per_concatemer_sample'], columns=['Fragments', 'Enzyme'])
            
            # Plot 1 (Left): Fragment length distribution (box + strip)
            strip1 = sns.stripplot(data=df_frags, x='Enzyme', y='Length', ax=axs[0], 
                                  color='black', alpha=0.1, size=2, jitter=True, zorder=0)
            box1 = sns.boxplot(data=df_frags, x='Enzyme', y='Length', ax=axs[0], 
                              color='skyblue', showfliers=False, zorder=10)
            for collection in axs[0].collections:
                if isinstance(collection, matplotlib.collections.PathCollection):
                    collection.set_rasterized(True)
            
            axs[0].set_title('Fragment length distribution')
            axs[0].set_ylabel('Length [bp]')
            axs[0].set_xlabel('Enzyme')
            
            median_len = df_frags['Length'].median() if not df_frags.empty else 0
            dist_label = f"max_dist: {args.max_dist}" if args.max_dist is not None else "max_dist: all"
            stats_text = f"median: {median_len:.1f} bp\nmin len: {args.min_len} bp\n{dist_label}"
            axs[0].text(0.95, 0.95, stats_text, transform=axs[0].transAxes, 
                       ha='right', va='top', fontsize=10, 
                       bbox=dict(facecolor='white', alpha=0.5))

            # Plot 2: Expansion Power (Boxplot)
            strip2 = sns.stripplot(data=df_pairs, x='Enzyme', y='Pairs', ax=axs[1], 
                                  color='black', alpha=0.1, size=2, jitter=True, zorder=0)
            box2 = sns.boxplot(data=df_pairs, x='Enzyme', y='Pairs', ax=axs[1], 
                              color='salmon', showfliers=False, zorder=10)
            for collection in axs[1].collections:
                if isinstance(collection, matplotlib.collections.PathCollection):
                    collection.set_rasterized(True)
                
            axs[1].set_title('Expansion power (pairs/concatemer)')
            axs[1].set_ylabel('Synthetic pairs generated [count]')
            axs[1].set_xlabel('Enzyme')

            # Plot 3: Fragments per concatemer (Histogram)
            frag_values = df_frags_per_conc['Fragments']
            max_frags = int(frag_values.max()) if not frag_values.empty else 1
            bins = range(0, max_frags + 2)
            hist_plot = axs[2].hist(frag_values, bins=bins, color='steelblue', 
                                    edgecolor='white', align='left')
            for patch in axs[2].patches:
                patch.set_rasterized(True)
                
            axs[2].set_title('Fragments per concatemer')
            axs[2].set_xlabel('Fragments per concatemer [count]')
            axs[2].set_ylabel('Concatemer [count]')

            plt.tight_layout()
            
            plt.savefig(png_file, dpi=300, bbox_inches='tight')
            plt.savefig(svg_file, format='svg', bbox_inches='tight')
            plt.close()
            
            print(f"Saved: {png_file} (300 DPI)")
            print(f"Saved: {svg_file} (rasterized content, vector text/axes)")
        except Exception as e:
            sys.stderr.write(f"Warning: Could not create visualization: {e}\n")
    elif not VIZ_AVAILABLE:
        sys.stderr.write("Note: Visualization skipped (matplotlib/seaborn/pandas not found).\n")

def main():
    parser = argparse.ArgumentParser(description="CiFi Expander: Convert long reads to synthetic Hi-C pairs.")
    parser.add_argument('--input', required=True, help="Input FASTQ (or use '-' for stdin)")
    parser.add_argument('--r1_out', required=True, help="Output R1 filename")
    parser.add_argument('--r2_out', required=True, help="Output R2 filename")
    parser.add_argument('--enzyme', required=True, help="Single enzyme name (e.g. DpnII)")
    parser.add_argument('--min_len', type=int, default=100, help="Min monomer length (bp)")
    parser.add_argument('--max_dist', type=int, default=None,
                        help="Max distance between monomer positions for pair generation. "
                             "1 = adjacent only (recommended for scaffolding), "
                             "2 = adjacent + one-skip. "
                             "Default: None (all pairwise combinations). "
                             "Uses position in filtered monomer list, not orig_idx.")
    parser.add_argument('--report_prefix', required=False, help="Prefix for report files (optional)")
    args = parser.parse_args()

    # Parse enzyme
    try:
        enzyme = getattr(Restriction, args.enzyme)
    except AttributeError:
        sys.stderr.write(f"Error: Enzyme '{args.enzyme}' not found in Bio.Restriction.\n")
        sys.exit(1)

    # Log pairing mode
    if args.max_dist is not None:
        sys.stderr.write(f"[INFO] Proximity-limited pairing: max_dist={args.max_dist} "
                         f"(only monomers within {args.max_dist} position(s) of each other "
                         f"in the filtered list will be paired)\n")
    else:
        sys.stderr.write(f"[INFO] All-pairwise pairing: generating C(n,2) pairs per concatemer\n")
            
    # Open output handles
    f1 = open(args.r1_out, 'w', buffering=1024*1024)
    f2 = open(args.r2_out, 'w', buffering=1024*1024)

    if args.input == '-':
        input_handle = sys.stdin
    else:
        input_handle = open(args.input, 'r')

    # Stats
    stats = {
        'processed': 0,
        'expanded': 0,
        'valid_lengths_sample': [], 
        'pairs_per_concatemer_sample': [], 
        'frags_per_concatemer_sample': [],
        'lost_pairs_per_concatemer_sample': [],
        'frag_counts': 0,
        'short_counts': 0,
        'pair_counts': 0,
        'total_theoretical_pairs': 0,
        'total_generated_pairs': 0
    }

    cut_site = enzyme.site
    
    for header, seq, qual in parse_fastq(input_handle):
        stats['processed'] += 1
        seq_upper = seq.upper()
        
        # In-silico digest
        frags = seq_upper.split(cut_site)
        
        monomers = []
        valid_count = 0
        short_count = 0
        
        for i, s in enumerate(frags):
            if len(s) >= args.min_len:
                monomers.append( {'seq': s, 'orig_idx': i} )
                valid_count += 1
            else:
                short_count += 1
        
        num_total_frags = valid_count + short_count
        expected_total = calculate_expected_pairs(num_total_frags, args.max_dist)
        
        # Filter
        if valid_count < 2:
            stats['short_counts'] += short_count
            if num_total_frags >= 2:
                reservoir_sample(stats['lost_pairs_per_concatemer_sample'], (expected_total, args.enzyme), max_size=100_000_000)
            continue
            
        # Expanded concatemer
        stats['expanded'] += 1
        stats['frag_counts'] += num_total_frags
        stats['short_counts'] += short_count
        
        # 1. calculate theoretical pairs
        num_monomers = len(monomers)
        expected_valid = calculate_expected_pairs(num_monomers, args.max_dist)
        lost_pairs = expected_total - expected_valid
        
        stats['total_theoretical_pairs'] += expected_valid
        reservoir_sample(stats['lost_pairs_per_concatemer_sample'], (lost_pairs, args.enzyme), max_size=100_000_000)

        for m in monomers:
            reservoir_sample(stats['valid_lengths_sample'], (len(m['seq']), args.enzyme), max_size=100_000_000)

        # Reservoir sample fragments per concatemer
        reservoir_sample(stats['frags_per_concatemer_sample'], (num_monomers, args.enzyme), max_size=100_000_000)
            
        base_id = header.split()[0]
        
        # 2. Generate pairs
        pairs = generate_pairs(monomers, args.max_dist)
        
        # 3. Track actual pairs
        num_actual = len(pairs)
        stats['total_generated_pairs'] += num_actual
        stats['pair_counts'] += num_actual
        
        # Reservoir sample pair counts per concatemer
        reservoir_sample(stats['pairs_per_concatemer_sample'], (num_actual, args.enzyme), max_size=100_000_000)
        
        for pair_idx, (m1, m2) in enumerate(pairs):
            dist = abs(m1['orig_idx'] - m2['orig_idx'])
            meta = f"ENZ={enzyme} DIST={dist}"
            id_suffix = f"_syn{pair_idx}"
            
            f1.write(f"{base_id}{id_suffix}/1 {meta}\n")
            f1.write(f"{m1['seq']}\n+\n")
            f1.write(f"{'I' * len(m1['seq'])}\n") 
            
            f2.write(f"{base_id}{id_suffix}/2 {meta}\n")
            f2.write(f"{m2['seq']}\n+\n")
            f2.write(f"{'I' * len(m2['seq'])}\n")

    f1.close()
    f2.close()
    if args.input != '-':
        input_handle.close()
    
    # Final integrity check
    if stats['total_theoretical_pairs'] == stats['total_generated_pairs']:
        sys.stderr.write(f"[SUCCESS] Integrity Verified: {stats['total_generated_pairs']} pairs generated "
                         f"matches expected count.\n")
    else:
        sys.stderr.write(f"[FATAL ERROR] Pair count mismatch! Expected {stats['total_theoretical_pairs']} "
                         f"but wrote {stats['total_generated_pairs']}.\n")
        sys.exit(1)
        
    sys.stderr.write(f"Processed {stats['processed']} concatemers. Expanded {stats['expanded']} concatemers.\n")
    
    if args.report_prefix:
        generate_report(stats, args, args.report_prefix)

if __name__ == "__main__":
    main()
