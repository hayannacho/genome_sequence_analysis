#!/usr/bin/env bash
# Coursework workflow; execution and coordinate fixes documented in docs/PROVENANCE.md.
set -euo pipefail
if [[ $# -ne 3 ]]; then
    echo "Usage: bash $0 query.fna subject.fna output.tsv" >&2
    exit 2
fi
[[ -r "$1" ]] || { echo "Cannot read input: $1" >&2; exit 2; }
[[ -r "$2" ]] || { echo "Cannot read input: $2" >&2; exit 2; }
for tool in blastn awk wc cat; do
    command -v "$tool" >/dev/null || { echo "Required command missing: $tool" >&2; exit 127; }
done
output=$3
if [[ -e "$output" && "$output" -ef "$1" ]]; then echo "Output must differ from inputs" >&2; exit 2; fi
if [[ -e "$output" && "$output" -ef "$2" ]]; then echo "Output must differ from inputs" >&2; exit 2; fi
scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT
blastn -query "$1" -subject "$2" -outfmt "6 qseqid sseqid pident length qlen slen" -out "$scratch/blast.tsv"
awk '$3 == 100 && $4 == $5' "$scratch/blast.tsv" > "$scratch/filtered.tsv"
cat "$scratch/filtered.tsv" > "$output"
echo "Filtered matches:"
cat "$output"
echo "Number of perfect matches: $(wc -l < "$output")"
