# Reproducible project workflow

This pipeline combines Snakemake's dependency graph with a lightweight research
compendium layout.

## Minimum project record

For every analysis, keep these files under version control:

- config.yaml with accession, organism, groups, thresholds, and column names.
- data/raw/sample_metadata.csv or a data-use statement when raw data cannot be
  redistributed.
- results/qc/input_validation.txt.
- PROJECT_STATUS.yml copied from templates/project/PROJECT_STATUS.yml.
- A run log containing the Git commit, date, command, and Conda environment.

Do not commit patient-level data, credentials, or large raw files. Store hashes
and a controlled-access location when needed.

## Suggested directory additions

~~~text
analysis/
├── literature/
│   ├── article_records.tsv
│   ├── evidence_extraction.tsv
│   └── search_log.tsv
├── manuscript/
│   ├── manuscript.qmd
│   └── references.bib
└── figures/
~~~

The templates/literature files provide stable columns for these tables. Zotero
can maintain references.bib automatically through Better BibTeX's Keep updated
export. Quarto can render citations from the bibliography.

## Run ledger

Record one row per run:

~~~text
run_id | date_utc | git_commit | command | config_sha256 | status | notes
~~~

A run is complete only after output files, the validation report, and
interpretation notes have been reviewed. A failed or exploratory run should
remain visible in the ledger rather than being overwritten.

Use `python scripts/record_run.py` to append a run record without replacing
earlier runs. The helper records the UTC timestamp, Git commit when available,
SHA-256 of the configuration file, command, status, and notes.

## Design review

Before interpreting differential expression, record the experimental unit and
replicate counts, group and batch variables, primary contrast and reference
level, filtering and normalization, primary DE method, sensitivity analyses,
and known limitations.

This structure follows the research-compendium pattern used by rrtools and the
dependency-oriented approach documented for targets.
