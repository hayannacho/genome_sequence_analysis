# genome-sequence-analysis

This repository contains a collection of Bash scripts for genome sequence analysis.  
The scripts cover tasks ranging from perfect sequence matching to CRISPR spacer extraction and homolog identification.  
Developed during bioinformatics coursework, these scripts showcase experience in building automated sequence analysis workflows using BLAST and UNIX tools.

---

## 📂 Contents

### 1. `find_perfect_matches.sh`
- **Purpose**: Identify perfect matches of a query nucleotide sequence in a genome assembly.  
- **Method**: Uses `blastn` with strict filters (100% identity and full-length matches).  
- **Use case**: Detecting CRISPR repeat sequences or exact sequence motifs.  
- **Output**: List of perfect matches and their count.  

---

### 2. `find_homologs.sh`
- **Purpose**: Find homologous regions of a protein query in a nucleotide genome.  
- **Method**: Runs `tblastn` (protein vs nucleotide).  
- **Filters**: Sequence identity > 30% and alignment length ≥ 90% of the query.  
- **Use case**: Searching for conserved protein-coding regions.  
- **Output**: List of homologous hits and their count.  

---

### 3. `extract_spacers.sh`
- **Purpose**: Extract CRISPR spacer sequences from a genome.  
- **Method**:  
  1. Run `blastn` to locate CRISPR repeats.  
  2. Compute inter-repeat regions as spacer coordinates.  
  3. Extract spacer sequences using `seqtk subseq`.  
- **Use case**: Identifying stored viral DNA fragments in bacterial genomes.  
- **Output**: FASTA file of CRISPR spacer sequences.  

---

### 4. `homolog_identify.sh`
- **Purpose**: Map BLAST hits to annotated genes.  
- **Method**: Compares `tblastn` results with a BED file of gene annotations.  
- **Output**: Unique gene names where homologs are located and their total count.  
- **Use case**: Linking homologous regions to functional gene annotations.  

---

## 📑 Input Formats
- **FASTA (.fna / .faa)**:  
  - `.fna` = nucleotide sequences (e.g., genome assemblies, CRISPR repeats)  
  - `.faa` = protein sequences (e.g., protein queries)  

- **BED (.bed)**:  
  - Only required for `homolog_identify.sh`  
  - Gene annotations with 4 columns:  
    ```
    seqid   start   end   gene_name
    ```
  - Example:  
    ```
    chr1    100     500     geneA
    chr1    700     1200    geneB
    ```
  - Dataset included:  
    - `Escherichia_coli_K12.bed`  
    - `Pseudomonas_aeruginosa_PA14.bed`  
    - `Vibrio_cholerae_N16961.bed`  
    - `Wolbachia.bed`  

---

## 🚀 Example Usage

```bash
# Find perfect matches
./find_perfect_matches.sh query.fna assembly.fna matches.txt

# Find homologs
./find_homologs.sh protein.faa genome.fna homologs.txt

# Extract CRISPR spacers
./extract_spacers.sh repeats.fna genome.fna spacers.fna

# Identify homologs and map to genes
./homolog_identify.sh protein.faa genome.fna annotations.bed genes.txt


---

## 🛠 Skills Demonstrated
Genomic sequence search with BLAST (blastn, tblastn)
Automating workflows with Bash scripting
Processing sequence and annotation files (FASTA, BED)
Filtering results using awk and UNIX utilities
CRISPR repeat and spacer analysis
