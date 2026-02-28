# Implementation Plan: GEO RNA-seq Pipeline

## Context Checklist
- [x] Does this plan align with Snakemake Best Practices? Yes, it utilizes a modular graph of rules with defined inputs/outputs, decoupling logic into separate scripts.
- [x] Are all paths relative and placed in `config.yaml`? Yes, standard paths will be defined dynamically via the root Snakefile and config.
- [x] Do new rules declare their own conda environments? Yes, each downstream module uses its own isolated `envs/<rule_name>.yaml`.
- [x] Are Python scripts designed to be PEP8 compliant? Yes. (Note: Much of the domain logic will be in R, which will follow tidyverse/Google R style guides, while wrapper/setup scripts in Python will strictly follow PEP8).

## Proposed Architecture

Our solution is a fully automated Snakemake pipeline designed to ingest a GEO accession number and orchestrate a broad suite of bioinformatics analyses using isolated Conda environments.

**Key Components:**
1. **Configuration (`config.yaml`)**: The single source of truth for the user to define the GEO ID, the experimental design (control vs treatment strings), and statistical thresholds (e.g., p-value < 0.05, Log2FC > 1).
2. **Data Acquisition Sub-workflow**: Uses Bioconductor's `GEOquery` to systematically pull the author-supplied count matrices and clinical metadata directly from NCBI GEO, bypassing the heavy processing of raw FASTQs.
3. **Data Standardization**: Cleans up missing values, standardizes HGNC gene symbols, and normalizes counts to TPM format for cross-sample comparability.
4. **Downstream Modules (R-centric)**:
   - **Differential Expression:** Handled by `DESeq2`.
   - **Enrichment:** Handled by `clusterProfiler`.
   - **Network Analysis:** `WGCNA` and `STRINGdb`.
   - **Clinical/Immune:** TCGA integration for `survival`, and `immunedeconv` for tumor microenvironment estimation.
   - **Regulation:** Transcription Factor analysis via `decoupleR`.
   *(Note: Alternative Splicing conditionally requires transcript-level data. If missing, this rule safely skips).*

**Execution Flow:**
The user calls `snakemake --use-conda -c <cores>`. Snakemake reads the `Snakefile`, resolves the DAG, automatically provisions the required R/Python environments for each step, and executes the scripts in `scripts/` mapping `data/` inputs to `results/` outputs.

## Validation & Testing Plan
1. **Dry-run testing**: Execute `snakemake -n` to validate the DAG stringency and rule connections.
2. **Integration testing**: Run the pipeline end-to-end on a known small dataset (e.g., a well-characterized GEO set like GSE52553) to verify that all output PDFs and CSVs are generated without runtime errors.
3. **Data Integrity testing**: Manually verify that the sample metadata columns perfectly align with the columns of the generated TPM and Count matrices.
