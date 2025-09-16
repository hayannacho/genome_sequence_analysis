#!/usr/bin/env bash

# Usage: ./extract_spacers.sh <query file> <subject file> <output file>
# Description: Identifies CRISPR repeats, calculates the positions of spacers, and extracts the spacer sequences from the genome.

query=$1
subject=$2
output=$3

# BLAST search to find CRISPR repeat positions
blastn -query "$query" -subject "$subject" -outfmt "6 qseqid sseqid pident length sstart send" -out blast_results.txt

# Filter for perfect matches
awk '$3 == "100.000"' blast_results.txt > perfect_matches.txt

# Loop through the perfect matches and calculate spacer positions
awk 'NR>1 {
    if (prev_end && $5 > prev_end) {
        print $2, prev_end+1, $6-1
    }
    prev_end=$6
}' perfect_matches.txt > spacers.bed

# Extract spacer sequences
seqtk subseq "$subject" spacers.bed > "$output"

# Output the extracted spacer sequences
echo "$output"
