# Execution validation

Checked 2026-11-13 using Linux amd64 under Docker, Python 3.12.3, NCBI BLAST+ 2.12.0+ and seqtk 1.4-r122.

The same five synthetic integration tests were run against the public baseline and corrected scripts. The baseline passed one test and failed four (three assertion failures and one missing-output error); the corrected scripts passed all five.

| Regression | Baseline | Corrected |
| --- | --- | --- |
| Exact search with paths containing spaces | Output missing | Pass, plus no-hit check |
| Protein search on both strands | Pass | Pass |
| Gene containment and BED boundaries | Incorrect internal/partial genes included | Only the two fully containing genes |
| Spacer coordinates and repeat grouping | Incorrect sequence boundaries | Exact expected three spacers |
| Missing input | Returned success | Nonzero exit, existing output preserved |

Command: `python3 -m unittest discover -s tests -v`.

These checks execute actual external tools, not mocked BLAST results. They do not establish biological accuracy, large-genome performance or exhaustive sequence discovery. Package versions may change when rebuilding the Ubuntu-based Dockerfile; the tested versions above are observations, not a complete dependency lock.
