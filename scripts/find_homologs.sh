#!/usr/bin/env bash

# Usage: ./find_homologs.sh <query file> <subject file> <output file>
# Description: Performs a BLAST search of a protein query against a nucleotide subject,
# filters hits with >30% identity and >90% match length,
# writes matches to the output file, and prints the number of matches identified.

query=$1
subject=$2
output=$3

# Perform BLAST search using tblastn
tblastn -query "$query" -subject "$subject" -outfmt "6 qseqid sseqid pident length qlen" -out blast_results.txt

# Filter for >30% sequence identity and >90% of query sequence length
awk '{ 
    if ($3 > 30 && $4 > (0.9 * $5)) 
        print $0 
}' blast_results.txt > "$output"

# Count the number of matches
match=$(wc -l < "$output")

# Output results
echo "Number of matches: $match"
