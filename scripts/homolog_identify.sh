#!/usr/bin/env bash

# Usage: homolog_identify.sh <query.faa> <subject.fna> <bedfile> <outfile>

query=$1
assembly=$2
bedfile=$3
outfile=$4

# Load the BED file
bed_lines=()
while read -r bed_seqid bed_start bed_end bed_name; do
    bed_lines+=("$bed_seqid $bed_start $bed_end $bed_name")
done < "$bedfile"

# Run tblastn and save the output
tblastn \
    -query "$query" \
    -subject "$assembly" \
    -outfmt '6 qseqid sseqid pident length sstart send qlen' \
    -task tblastn \
    -out blast_results.txt

# Ensure the output file is clean
: > "$outfile"

# Loop through BLAST results
while read -r qseqid sseqid pident length sstart send qlen; do
    # Filter hits with >30% identity and >90% alignment length of the query
    if (( $(echo "$pident > 30" | bc -l) )) && (( $(echo "$length >= 0.9 * $qlen" | bc -l) )); then
        # Loop over BED file entries
        for bed_entry in "${bed_lines[@]}"; do
            bed_seqid=$(echo "$bed_entry" | cut -d' ' -f1)
            bed_start=$(echo "$bed_entry" | cut -d' ' -f2)
            bed_end=$(echo "$bed_entry" | cut -d' ' -f3)
            bed_name=$(echo "$bed_entry" | cut -d' ' -f4)

            # Check if the BLAST hit lies within the boundaries of the gene
            if [[ "$sseqid" == "$bed_seqid" && "$sstart" -ge "$bed_start" && "$send" -le "$bed_end" ]]; then
                # Append gene name to the output if it's within boundaries
                echo "$bed_name" >> "$outfile"
            fi
        done
    fi
done < blast_results.txt

# Remove duplicate gene names from the output
sort -u "$outfile" -o "$outfile"

# Output the number of unique genes identified
match_count=$(wc -l < "$outfile")
echo "Number of genes : $match_count"
