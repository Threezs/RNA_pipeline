#!/usr/bin/env python3
"""Append a reproducibility record to a tab-separated run ledger."""

from __future__ import annotations

import argparse
import csv
import hashlib
import subprocess
from datetime import datetime, timezone
from pathlib import Path


FIELDS = [
    "run_id", "date_utc", "git_commit", "config_sha256",
    "command", "status", "notes",
]


def git_commit() -> str:
    try:
        return subprocess.check_output(
            ["git", "rev-parse", "HEAD"], text=True, stderr=subprocess.DEVNULL
        ).strip()
    except (OSError, subprocess.CalledProcessError):
        return "unknown"


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--ledger", required=True, type=Path)
    parser.add_argument("--config", required=True, type=Path)
    parser.add_argument("--run-id", required=True)
    parser.add_argument("--command", required=True)
    parser.add_argument(
        "--status", choices=("planned", "running", "passed", "failed"), required=True
    )
    parser.add_argument("--notes", default="")
    args = parser.parse_args()

    if not args.config.is_file():
        parser.error(f"configuration file not found: {args.config}")
    digest = hashlib.sha256(args.config.read_bytes()).hexdigest()
    args.ledger.parent.mkdir(parents=True, exist_ok=True)
    has_header = args.ledger.is_file() and args.ledger.stat().st_size > 0
    with args.ledger.open("a", encoding="utf-8", newline="") as handle:
        writer = csv.DictWriter(
            handle, fieldnames=FIELDS, delimiter="\t", lineterminator="\n"
        )
        if not has_header:
            writer.writeheader()
        writer.writerow(
            {
                "run_id": args.run_id,
                "date_utc": datetime.now(timezone.utc).isoformat(),
                "git_commit": git_commit(),
                "config_sha256": digest,
                "command": args.command,
                "status": args.status,
                "notes": args.notes,
            }
        )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
