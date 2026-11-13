#!/usr/bin/env bash
# Coursework workflow; execution and coordinate fixes documented in docs/PROVENANCE.md.
set -euo pipefail
if [[ $# -ne 3 ]]; then
    echo "Usage: bash $0 repeat.fna subject.fna output.fna" >&2
    exit 2
fi
[[ -r "$1" ]] || { echo "Cannot read input: $1" >&2; exit 2; }
[[ -r "$2" ]] || { echo "Cannot read input: $2" >&2; exit 2; }
for tool in blastn awk sort seqtk cat; do
    command -v "$tool" >/dev/null || { echo "Required command missing: $tool" >&2; exit 127; }
done
output=$3
if [[ -e "$output" && "$output" -ef "$1" ]]; then echo "Output must differ from inputs" >&2; exit 2; fi
if [[ -e "$output" && "$output" -ef "$2" ]]; then echo "Output must differ from inputs" >&2; exit 2; fi
scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT
# Retain full-query exact matches and normalize both genomic orientations.
blastn -query "$1" -subject "$2" -outfmt "6 qseqid sseqid pident length sstart send qlen" -out "$scratch/blast.tsv"
awk 'BEGIN { OFS="\t" }
    $3 == 100 && $4 == $7 {
        start=($5<$6 ? $5 : $6); end=($5>$6 ? $5 : $6)
        strand=($5<=$6 ? "+" : "-")
        print $1,$2,strand,start,end
    }' "$scratch/blast.tsv" | LC_ALL=C sort -k1,1 -k2,2 -k3,3 -k4,4n -k5,5n -u > "$scratch/repeats.tsv"
# BLAST is 1-based inclusive; BED is 0-based half-open.
# Pair adjacent non-overlapping repeats only within the same query, contig and strand.
awk 'BEGIN { OFS="\t" }
    {
        key=$1 SUBSEP $2 SUBSEP $3
        if (key == prev_key) {
            if ($4 > prev_end+1) print $2,prev_end,$4-1
            if ($5 > prev_end) prev_end=$5
        } else { prev_end=$5 }
        prev_key=key
    }' "$scratch/repeats.tsv" | LC_ALL=C sort -k1,1 -k2,2n -k3,3n -u > "$scratch/spacers.bed"
if [[ -s "$scratch/spacers.bed" ]]; then
    seqtk subseq "$2" "$scratch/spacers.bed" > "$scratch/spacers.fna"
else
    : > "$scratch/spacers.fna"
fi
cat "$scratch/spacers.fna" > "$output"
echo "$output"
