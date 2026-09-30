#!/usr/bin/env python3
"""Validate a count matrix and its sample metadata.

The script intentionally uses only Python's standard library so it can run
before an R or Conda environment is available.
"""

from __future__ import annotations

import argparse
import csv
import math
import sys
from collections import Counter
from pathlib import Path


def read_csv(path: Path) -> tuple[list[str], list[dict[str, str]]]:
    if not path.exists():
        raise ValueError(f"missing file: {path}")
    with path.open("r", encoding="utf-8-sig", newline="") as handle:
        reader = csv.DictReader(handle)
        if not reader.fieldnames:
            raise ValueError(f"no header found: {path}")
        return list(reader.fieldnames), list(reader)


def duplicate_values(values: list[str]) -> list[str]:
    return sorted(value for value, count in Counter(values).items() if value and count > 1)


def validate(args: argparse.Namespace) -> tuple[list[str], list[str]]:
    errors: list[str] = []
    warnings: list[str] = []
    count_fields, count_rows = read_csv(Path(args.counts))
    meta_fields, meta_rows = read_csv(Path(args.metadata))

    if args.gene_column not in count_fields:
        errors.append(f"count matrix lacks gene column: {args.gene_column}")
    elif count_fields[0] != args.gene_column:
        errors.append("gene identifier column must be the first count-matrix column")
    for column in (args.sample_id_column, args.group_column):
        if column not in meta_fields:
            errors.append(f"metadata lacks required column: {column}")
    if errors:
        return errors, warnings

    genes = [row[args.gene_column].strip() for row in count_rows]
    if any(not gene for gene in genes):
        errors.append("count matrix contains an empty gene identifier")
    if duplicate_values(genes):
        errors.append("count matrix contains duplicated gene identifiers")

    sample_ids = count_fields[1:]
    metadata_ids = [row[args.sample_id_column].strip() for row in meta_rows]
    if not sample_ids:
        errors.append("count matrix has no sample columns")
    if len(sample_ids) != len(set(sample_ids)):
        errors.append("count matrix contains duplicated sample columns")
    if any(not sample_id for sample_id in metadata_ids):
        errors.append("metadata contains an empty sample ID")
    if duplicate_values(metadata_ids):
        errors.append("metadata contains duplicated sample IDs")

    missing_metadata = sorted(set(sample_ids) - set(metadata_ids))
    extra_metadata = sorted(set(metadata_ids) - set(sample_ids))
    if missing_metadata:
        errors.append("samples missing from metadata: " + ", ".join(missing_metadata))
    if extra_metadata:
        errors.append("metadata samples absent from counts: " + ", ".join(extra_metadata))

    groups: dict[str, int] = {}
    for row in meta_rows:
        group = row[args.group_column].strip()
        groups[group] = groups.get(group, 0) + 1
    if "" in groups:
        errors.append("metadata contains an empty group")
    for group, size in sorted(groups.items()):
        if size < args.min_replicates:
            warnings.append(
                f"group {group!r} has {size} replicate(s); "
                f"recommended minimum is {args.min_replicates}"
            )

    for row_number, row in enumerate(count_rows, start=2):
        for field in sample_ids:
            raw = row[field].strip()
            try:
                value = float(raw)
            except ValueError:
                errors.append(f"non-numeric count at row {row_number}, column {field}")
                continue
            if not math.isfinite(value) or value < 0 or not value.is_integer():
                errors.append(
                    f"count must be a finite non-negative integer at row "
                    f"{row_number}, column {field}: {raw!r}"
                )

    return errors, warnings


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--counts", required=True)
    parser.add_argument("--metadata", required=True)
    parser.add_argument("--gene-column", default="Gene")
    parser.add_argument("--sample-id-column", default="sample_id")
    parser.add_argument("--group-column", default="group")
    parser.add_argument("--min-replicates", type=int, default=2)
    args = parser.parse_args()

    try:
        errors, warnings = validate(args)
    except (OSError, UnicodeError, ValueError) as exc:
        print(f"ERROR: {exc}")
        return 2

    print(f"counts: {args.counts}")
    print(f"metadata: {args.metadata}")
    print(f"gene_column: {args.gene_column}")
    print(f"sample_id_column: {args.sample_id_column}")
    print(f"group_column: {args.group_column}")
    for warning in warnings:
        print(f"WARNING: {warning}")
    for error in errors:
        print(f"ERROR: {error}")
    if errors:
        print(f"validation: FAILED ({len(errors)} error(s))")
        return 1
    print("validation: PASSED")
    return 0


if __name__ == "__main__":
    sys.exit(main())
