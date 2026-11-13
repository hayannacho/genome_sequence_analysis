# Source comparison and maintenance changes

Source: user-supplied `GATECH.zip`. Baseline public commit: `c6ed54f`. Full SHA-256 records and archive paths are in [source-comparison.json](source-comparison.json).

| Public file | Archive comparison before this update |
| --- | --- |
| `scripts/find_homologs.sh` | Exact match to `Fall2024/biol7200/perfect_hits/find_homologs/find_homologs.sh` |
| `scripts/extract_spacers.sh` | Same content apart from trailing whitespace at `Fall2024/biol7200/perfect_hits/extract_spacers.sh` |
| `scripts/homolog_identify.sh` | Same content apart from trailing whitespace at `Fall2024/biol7200/class4/ex4/homolog_identify.sh` |
| `scripts/find_perfect_matches.sh` | ZIP's corresponding class2/ex2 file is only an `echo "oops!"` placeholder; public code used as baseline |

## Changes in this edition

- All scripts: quoted input paths, argument/dependency checks, failure propagation, isolated temporary files, protection against output aliasing an input, and preservation of existing output until search/filtering succeeds.
- Spacer extraction: require full-query exact matches; sort and deduplicate normalized repeat coordinates; initialize the first repeat correctly; group by query/contig/strand; extract from the previous repeat's end to the next repeat's start using correct BED coordinates. Return sequences in forward genomic orientation.
- Gene mapping: normalize reverse alignments, convert BLAST 1-based inclusive coordinates to BED 0-based half-open intervals, require full containment, validate BED fields, and remove the `bc` dependency. Preserve the original ≥90% coverage rule.
- Exact/homolog filters: retain original thresholds and output columns.
- Add synthetic integration regression tests and an isolated environment. Rewrite README to match actual paths, dependencies, files and limits.

The ZIP is provenance evidence, not a complete individual authorship record. No sole-authorship or contribution-percentage claim is made. Original versions remain in Git history; these corrections are not represented as original course submissions.
