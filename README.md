# Reproducible RNA-seq Analysis Pipeline

This repository provides a Snakemake workflow for public GEO data and compatible
local count matrices. R is used for statistical analysis and plotting; Python
is used for lightweight, dependency-free input validation. The workflow fails
early when a data or metadata assumption is not satisfied.

## What is included

- GEO metadata and supplementary-file retrieval.
- Count-matrix validation, duplicate-gene aggregation, low-expression filtering,
  CPM normalization, DESeq2 differential expression, and PCA/volcano plots.
- GO/KEGG enrichment with a configurable mouse or human annotation database.
- WGCNA, STRING PPI, quanTIseq immune deconvolution, and decoupleR TF activity
  as optional downstream modules.
- A literature workflow compatible with Zotero + Better BibTeX + Quarto.
- Project-status, evidence-extraction, search-log, and manuscript templates.

The default workflow does not fabricate data. If a GEO supplementary file is
missing or cannot be parsed, the run stops with an actionable error.

## Quick start

1. Install Snakemake and a Conda/Mamba implementation.
2. Copy config.yaml to a project-specific configuration and set geo_id,
   control_group, treatment_group, organism, and metadata column names.
3. Run:

~~~bash
snakemake --use-conda --cores 8
~~~

For an existing local matrix, place files at
data/raw/counts_raw.csv and data/raw/sample_metadata.csv, then run
~~~bash
snakemake --use-conda --cores 8 --until validate_inputs
~~~
before starting the full workflow.

## Input contract

counts_raw.csv must contain one gene identifier column followed by integer,
non-negative sample counts. sample_metadata.csv must contain a unique sample_id
column, a group column, and one row per count-matrix sample. The sample IDs must
match exactly. See docs/VALIDATION.md.

The file named tpm_clean.csv is retained for backward compatibility with the
original repository, but it contains CPM-normalized expression (not TPM),
because true TPM requires transcript or gene lengths.

## Scope and interpretation

The workflow is a computational template, not a substitute for design review.
Use biological replicates as the experimental unit, record batch and other
covariates in metadata, and inspect sample-level QC before interpreting
differential expression. Survival analysis is excluded from the default target
list because it requires matched clinical data; it must never use simulated data.

## Reproducibility

Use the Conda environment files under envs/, commit configuration and logs, and
record the Git commit used for each result. For a research compendium, see
docs/REPRODUCIBILITY.md and templates/.

## References

- Snakemake best practices:
  https://snakemake.readthedocs.io/en/stable/snakefiles/best_practices.html
- DESeq2 vignette:
  https://bioconductor.org/packages/release/bioc/vignettes/DESeq2/inst/doc/DESeq2.html
- targets user manual: https://books.ropensci.org/targets/
- rrtools research compendium: https://github.com/benmarwick/rrtools
- Better BibTeX automatic export:
  https://retorque.re/zotero-better-bibtex/exporting/auto/
