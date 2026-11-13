# Genome sequence analysis workflows

**Search nucleotide matches, find protein-to-genome candidates, extract repeat-flanked spacers, and map alignments to annotated genes.** Four small Bash workflows associated with Georgia Tech BIOL 7200, Fall 2024.

## Functions

| Script | Inputs | Output and selection |
| --- | --- | --- |
| `scripts/find_perfect_matches.sh` | Nucleotide query FASTA, nucleotide subject FASTA | BLAST TSV: 100% identity and alignment length equal to full query length |
| `scripts/find_homologs.sh` | Protein FASTA, nucleotide subject FASTA | TBLASTN TSV: identity >30%, alignment length >90% of query length |
| `scripts/extract_spacers.sh` | Repeat nucleotide FASTA, nucleotide subject FASTA | FASTA intervals between adjacent full-length exact repeats on the same contig, query and strand |
| `scripts/homolog_identify.sh` | Protein FASTA, nucleotide subject FASTA, BED annotations | Sorted unique gene names containing a qualifying hit: identity >30%, alignment length **≥90%** of query length |

The two homolog scripts intentionally retain their different original coverage comparisons. These filters select candidates, not proven homologs or orthologs. Counts refer to alignment rows except in `homolog_identify.sh`, which counts unique gene names.

## Run

Requirements: Bash, NCBI BLAST+ (`blastn`, `tblastn`), `seqtk`, and standard UNIX tools (`awk`, `sort`, `wc`, `cat`, `mktemp`). Python 3 is needed only for the regression tests. No prebuilt BLAST database is required.

From the repository root, substitute paths to your own files:

```sh
bash scripts/find_perfect_matches.sh query.fna assembly.fna matches.tsv
bash scripts/find_homologs.sh protein.faa assembly.fna homologs.tsv
bash scripts/extract_spacers.sh repeats.fna assembly.fna spacers.fna
bash scripts/homolog_identify.sh protein.faa assembly.fna genes.bed genes.txt
```

Quote paths containing spaces. Inputs must be readable and output paths must differ from the inputs. A successful run replaces the requested output; temporary search files are isolated and removed automatically. Missing dependencies, missing inputs and BLAST errors cause a nonzero exit instead of a misleading successful count.

## Input and output formats

- Query and subject sequences are FASTA. `tblastn` queries are amino-acid sequences; subjects are DNA.
- Gene annotations use BED with at least four whitespace-separated columns: `seqid start end gene`. Coordinates are **0-based, half-open**, and sequence IDs must match the subject FASTA. Empty/comment lines are allowed; `track`/`browser` header lines are not supported.
- Exact-match TSV columns: `qseqid sseqid pident length qlen slen`.
- Homolog TSV columns: `qseqid sseqid pident length qlen`; alignment/query lengths are amino-acid positions.
- Spacer sequences are returned in the subject's forward genomic orientation, including intervals found between reverse-strand repeats. They are not automatically reverse-complemented.

No external genome assemblies or BED annotation datasets are bundled. The earlier README incorrectly listed supplied BED files and omitted the `scripts/` directory in execution commands; those descriptions are corrected here.

## Verified synthetic regression checks

```sh
python3 -m unittest discover -s tests -v
```

Or use the supplied isolated environment:

```sh
docker build --platform linux/amd64 -t genome-workflows .
docker run --rm --platform linux/amd64 -v "$PWD:/project:ro" -w /project genome-workflows
```

**Five tests passed** with real BLAST+ and seqtk: exact match/no hit and paths with spaces; protein hits on both strands; BED boundary and reverse-strand gene containment; first-pair/multi-contig/reverse-strand spacer extraction; and missing-input failure without overwriting a prior result. All test sequences are synthetic and created in temporary directories. [Validation](docs/VALIDATION.md).

## Interpretation limits

BLAST uses its default search settings and may miss short or low-complexity matches. Separate alignments are not merged for coverage. Repeat-flanked intervals are only spacer candidates: there is no CRISPR-array validation or maximum spacer-distance filter. Repeats are grouped by query, contig and strand; biological array boundaries are not inferred. Gene mapping uses full alignment containment, not strand-aware gene function or orthology assignment.

## Coursework, provenance and changes

The archive locates the homolog, spacer and gene-mapping scripts in **Fall 2024 BIOL 7200**. The public homolog script matched its archived counterpart byte-for-byte; the other two matched apart from trailing whitespace. The ZIP's `class2/ex2/find_perfect_matches.sh` is only an `echo "oops!"` placeholder, so it cannot validate the full published implementation. The published script was retained as the correction baseline rather than replacing it with that placeholder.

The repository demonstrates Bash workflow integration, BLAST filtering, coordinate handling and sequence/annotation processing. The archive and public history establish provenance, not exclusive line-by-line authorship. The underlying BLAST and seqtk algorithms are not claimed as personal implementations.

This edition corrects coordinate conversion, reverse-strand containment, repeat ordering/grouping, quoting, temporary-file isolation and failure handling. These are current maintenance changes, not claimed original coursework deliverables. [Detailed source comparison and changes](docs/PROVENANCE.md).
