import random
import subprocess
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
RC = str.maketrans("ACGT", "TGCA")

def reverse(seq):
    return seq.translate(RC)[::-1]

class Workflows(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory(prefix="genome test ")
        self.addCleanup(self.tmp.cleanup)
        self.work = Path(self.tmp.name)
        self.rng = random.Random(7200)

    def dna(self, n):
        return "".join(self.rng.choice("ACGT") for _ in range(n))

    def fasta(self, name, records):
        p = self.work / name
        p.write_text("".join(f">{key}\n{seq}\n" for key, seq in records))
        return p

    def run_script(self, name, *args, success=True):
        proc = subprocess.run(["bash", str(ROOT / "scripts" / name), *map(str, args)], cwd=self.work, text=True, capture_output=True)
        if success:
            self.assertEqual(proc.returncode, 0, proc.stderr)
        else:
            self.assertNotEqual(proc.returncode, 0)
        return proc

    def protein_inputs(self):
        codons = dict(zip("ACDEFGHIKLMNPQRSTVWY", "GCT TGT GAT GAA TTT GGT CAT ATT AAA CTG ATG AAT CCT CAA CGT TCT ACT GTT TGG TAT".split()))
        protein = "".join(self.rng.choice(list(codons)) for _ in range(120))
        dna = "".join(codons[a] for a in protein)
        query = self.fasta("protein.faa", [("query", protein)])
        subject = self.fasta("coding.fna", [("forward", "A"*20+dna+"A"*20), ("reverse", "A"*20+reverse(dna)+"A"*20)])
        return query, subject

    def test_exact_match_and_no_hit(self):
        seq = self.dna(160)
        q = self.fasta("query with spaces.fna", [("query", seq)])
        s = self.fasta("subject.fna", [("subject", seq)])
        out = self.work / "exact.tsv"
        self.run_script("find_perfect_matches.sh", q, s, out)
        row = out.read_text().split()
        self.assertEqual(row[:2], ["query", "subject"])
        self.assertEqual(float(row[2]), 100)
        self.assertEqual(row[3:5], ["160", "160"])
        s = self.fasta("negative.fna", [("no_hit", "A"*360)])
        self.run_script("find_perfect_matches.sh", q, s, out)
        self.assertEqual(out.read_text(), "")

    def test_homolog_both_strands(self):
        q, s = self.protein_inputs()
        out = self.work / "homologs.tsv"
        self.run_script("find_homologs.sh", q, s, out)
        rows = [x.split() for x in out.read_text().splitlines()]
        self.assertEqual({x[1] for x in rows}, {"forward", "reverse"})
        self.assertTrue(all(float(x[2]) == 100 and x[3:5] == ["120", "120"] for x in rows))

    def test_gene_mapping_reverse_and_bed_boundaries(self):
        q, s = self.protein_inputs()
        bed = self.work / "genes.bed"
        bed.write_text("forward\t20\t380\tforward_gene\nreverse\t20\t380\treverse_gene\nforward\t21\t380\tmissing_first_base\nreverse\t100\t200\tinternal_decoy\n")
        out = self.work / "genes.txt"
        self.run_script("homolog_identify.sh", q, s, bed, out)
        self.assertEqual(out.read_text().splitlines(), ["forward_gene", "reverse_gene"])

    def test_spacers_first_pair_reverse_and_contig_boundaries(self):
        repeat, gap1, gap2 = self.dna(60), self.dna(41), self.dna(53)
        q = self.fasta("repeat.fna", [("repeat", repeat)])
        s = self.fasta("arrays.fna", [("array", repeat+gap1+repeat+gap2+repeat), ("reverse_array", reverse(repeat+gap1+repeat)), ("singleton", repeat)])
        out = self.work / "spacers.fna"
        self.run_script("extract_spacers.sh", q, s, out)
        records = out.read_text().split(">")
        sequences = ["".join(x.splitlines()[1:]) for x in records if x]
        self.assertCountEqual(sequences, [gap1, gap2, reverse(gap1)])
        self.assertFalse((self.work / "blast_results.txt").exists())

    def test_missing_input_preserves_output(self):
        out = self.work / "keep.txt"
        out.write_text("keep\n")
        self.run_script("find_homologs.sh", self.work/"missing", self.work/"missing2", out, success=False)
        self.assertEqual(out.read_text(), "keep\n")

if __name__ == "__main__":
    unittest.main()
