#!/usr/bin/env bash

# Usage: ./find_perfect_matches.sh <query file> <subject file> <output file>
# Description: Runs a BLAST search for perfect matches between a query and a subject.
# Writes perfect matches to the output file and prints the number of perfect matches.

# Input files
query_file=$1
assembly_file=$2
output_file=$3

# Perform BLAST search
blastn -query $query_file -subject $assembly_file -outfmt "6 qseqid sseqid pident length qlen slen" > blast_results.txt

# Filter for perfect matches (100% identity and length equal to the query length)
awk '$3 == 100 && $4 == $5' blast_results.txt > $output_file

# Count the number of perfect matches
match_count=$(wc -l < $output_file)

# Output results
echo "Filtered matches:"
cat $output_file
echo "Number of perfect matches: $match_count"
