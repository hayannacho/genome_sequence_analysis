#!/usr/bin/env bash
# Coursework workflow; execution and coordinate fixes documented in docs/PROVENANCE.md.
set -euo pipefail
if [[ $# -ne 4 ]]; then
    echo "Usage: bash $0 protein.faa subject.fna annotations.bed output.txt" >&2
    exit 2
fi
[[ -r "$1" ]] || { echo "Cannot read input: $1" >&2; exit 2; }
[[ -r "$2" ]] || { echo "Cannot read input: $2" >&2; exit 2; }
[[ -r "$3" ]] || { echo "Cannot read input: $3" >&2; exit 2; }
for tool in tblastn awk sort wc cat; do
    command -v "$tool" >/dev/null || { echo "Required command missing: $tool" >&2; exit 127; }
done
output=$4
if [[ -e "$output" && "$output" -ef "$1" ]]; then echo "Output must differ from inputs" >&2; exit 2; fi
if [[ -e "$output" && "$output" -ef "$2" ]]; then echo "Output must differ from inputs" >&2; exit 2; fi
if [[ -e "$output" && "$output" -ef "$3" ]]; then echo "Output must differ from inputs" >&2; exit 2; fi
scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT
# Require ordinary 0-based, half-open BED intervals with at least four columns.
awk 'NF && $0 !~ /^#/ {
    if (NF < 4 || $2 !~ /^[0-9]+$/ || $3 !~ /^[0-9]+$/ || $3 <= $2) exit 1
}' "$3" || { echo "Invalid BED: expected seqid, start, end, gene" >&2; exit 2; }
tblastn -query "$1" -subject "$2" -outfmt "6 qseqid sseqid pident length sstart send qlen" -out "$scratch/blast.tsv"
awk 'FILENAME == ARGV[1] {
    if (NF && $0 !~ /^#/) { n++; sid[n]=$1; lo[n]=$2; hi[n]=$3; gene[n]=$4 }
    next
}
$3 > 30 && $4 >= 0.9 * $7 {
    start=($5<$6 ? $5 : $6)-1
    end=($5>$6 ? $5 : $6)
    for (i=1;i<=n;i++)
        if ($2 == sid[i] && start >= lo[i] && end <= hi[i]) print gene[i]
}' "$3" "$scratch/blast.tsv" | LC_ALL=C sort -u > "$scratch/genes.txt"
cat "$scratch/genes.txt" > "$output"
echo "Number of genes: $(wc -l < "$output")"
