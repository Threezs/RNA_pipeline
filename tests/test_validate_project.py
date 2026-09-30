#!/usr/bin/env python3
"""Regression tests for the dependency-free input validator."""

from __future__ import annotations

import csv
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
VALIDATOR = ROOT / "scripts" / "validate_project.py"
RECORDER = ROOT / "scripts" / "record_run.py"


def write_csv(path: Path, rows: list[list[str]]) -> None:
    with path.open("w", encoding="utf-8", newline="") as handle:
        csv.writer(handle).writerows(rows)


class ValidatorTests(unittest.TestCase):
    def test_valid_matrix_passes(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            write_csv(
                root / "counts.csv",
                [["Gene", "S1", "S2", "S3", "S4"], ["G1", "1", "2", "3", "4"]],
            )
            write_csv(
                root / "meta.csv",
                [["sample_id", "group"], ["S1", "C"], ["S2", "C"], ["S3", "T"], ["S4", "T"]],
            )
            result = subprocess.run(
                [sys.executable, str(VALIDATOR), "--counts", str(root / "counts.csv"), "--metadata", str(root / "meta.csv")],
                capture_output=True, text=True, check=False,
            )
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
            self.assertIn("validation: PASSED", result.stdout)

    def test_invalid_matrix_fails(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            write_csv(
                root / "counts.csv",
                [["Gene", "S1", "S2"], ["G1", "1", "bad"], ["G1", "2", "3"]],
            )
            write_csv(root / "meta.csv", [["sample_id", "group"], ["S1", "C"], ["S3", "T"]])
            result = subprocess.run(
                [sys.executable, str(VALIDATOR), "--counts", str(root / "counts.csv"), "--metadata", str(root / "meta.csv")],
                capture_output=True, text=True, check=False,
            )
            self.assertNotEqual(result.returncode, 0)
            self.assertIn("duplicated gene", result.stdout)
            self.assertIn("non-numeric count", result.stdout)

    def test_run_recorder_appends_hash_and_status(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            config = root / "config.yaml"
            ledger = root / "run_ledger.tsv"
            config.write_text("answer: 42\n", encoding="utf-8")
            command = [
                sys.executable, str(RECORDER), "--ledger", str(ledger),
                "--config", str(config), "--run-id", "test-1",
                "--command", "unit test", "--status", "passed", "--notes", "ok",
            ]
            subprocess.run(command, check=True)
            with ledger.open(encoding="utf-8") as handle:
                rows = list(csv.DictReader(handle, delimiter="\t"))
            self.assertEqual(len(rows), 1)
            self.assertEqual(rows[0]["status"], "passed")
            self.assertEqual(len(rows[0]["config_sha256"]), 64)


if __name__ == "__main__":
    unittest.main()
