# Tasks: GEO RNA-seq Pipeline

## Context
This document outlines the actionable execution steps to implement the GEO RNA-seq pipeline as per the specifications and implementation plan. 

## Implementation Strategy
- **MVP (Phase 3)**: Establish the core data retrieval and normalization flow to guarantee we can produce clean TPM & Count matrices.
- **Incremental Delivery**: Subsequent phases (Phases 4-6) will add the downstream analytical modules sequentially, allowing independent validation.

## Phase 1: Setup
**Goal:** Initialize the project structure and Snakemake configuration.
- [x] T001 Initialize basic project directory structure (envs, scripts, data, results) in `e:/流程/`.
- [x] T002 Draft the initial `config.yaml` specifying input GEO ID and global thresholds.
- [x] T003 Draft the structural skeleton of the `Snakefile` defining the `rule all` target outputs.

## Phase 2: Foundational
**Goal:** Establish shared tools and environments.
- [x] T004 [P] Create conda environment file `envs/fetch.yaml` with `GEOquery` and base data manipulation libraries.
- [x] T005 [P] Create conda environment file `envs/dge.yaml` with `DESeq2` and `tidyverse`.

## Phase 3: Core Data Flow (US1 MVP)
**Goal:** End-to-end processing: Downloading author-provided matrices and generating clean TPM/Count matrices.
**Test Criteria:** Running the Snakefile successfully outputs `data/processed/tpm_clean.csv` and `data/processed/counts_clean.csv` for the target GEO ID, with matching sample metadata.
- [x] T006 [US1] Implement `scripts/fetch_geo.R` to download series matrix and supplementary data.
- [x] T007 [US1] Add `rule fetch_data` to `Snakefile` invoking `fetch_geo.R`.
- [x] T008 [US1] Implement `scripts/preprocess_matrices.R` to clean, normalize, and emit standardized TPM/counts.
- [x] T009 [US1] Add `rule preprocess_matrices` to `Snakefile` invoking `preprocess_matrices.R`.

## Phase 4: Core Analysis (DGE & Enrichment)
**Goal:** Perform differential expression and functional enrichment clustering.
**Test Criteria:** Generated volcano plots, PCA plots, and GO/KEGG dotplots appear in the `results/` directory.
- [x] T010 [P] [US1] Create conda environment `envs/enrichment.yaml` with `clusterProfiler`.
- [x] T011 [US1] Implement `scripts/run_deseq2.R` and add `rule dge_analysis` to `Snakefile`.
- [x] T012 [US1] Implement `scripts/functional_enrichment.R` and add `rule functional_enrichment` to `Snakefile`.

## Phase 5: Network & Prognostic Modules (WGCNA, PPI, Survival)
**Goal:** Build co-expression networks, PPIs, and evaluate TCGA survival kinetics.
**Test Criteria:** WGCNA module trait heatmaps, STRINGdb network PDFs, and Kaplan-Meier curves are successfully generated.
- [x] T013 [P] [US1] Create conda environment `envs/network_survival.yaml` with `WGCNA`, `STRINGdb`, `survival`, and `TCGAbiolinks`.
- [x] T014 [US1] Implement `scripts/wgcna_analysis.R` and add `rule wgcna_analysis` to `Snakefile`.
- [x] T015 [US1] Implement `scripts/ppi_network.R` and add `rule ppi_network` to `Snakefile`.
- [x] T016 [US1] Implement `scripts/survival_analysis.R` and add `rule survival_analysis` to `Snakefile`.

## Phase 6: Advanced Profiling (Immune, TF, Splicing)
**Goal:** Estimate tumor microenvironment, predict TF activities, and evaluate conditional splicing.
**Test Criteria:** Immune infiltration barplots and TF activity heatmaps are generated. Splicing gracefully skips or executes if transcript data is present.
- [x] T017 [P] [US1] Create conda environment `envs/advanced_profiling.yaml` with `immunedeconv` and `decoupleR`.
- [x] T018 [US1] Implement `scripts/immune_infiltration.R` and add `rule immune_infiltration` to `Snakefile`.
- [x] T019 [US1] Implement `scripts/tf_prediction.R` and add `rule tf_prediction` to `Snakefile`.
- [x] T020 [US1] Implement conditional logic in `Snakefile` and `scripts/alternative_splicing.R` for `rule alternative_splicing`.

## Phase 7: Polish & Documentation
**Goal:** Ensure PEP8/clean code compliance and final documentation.
- [x] T021 Run linter (e.g., `styler` for R, `flake8` for Python) across `scripts/` to ensure formatting compliance.
- [x] T022 Generate `README.md` containing execution instructions (`snakemake --use-conda`) and expected output structures.

## Dependencies & Completion Order
1. Phase 1 (Setup) and Phase 2 (Foundational) must complete first.
2. Phase 3 (Core Data Flow) blocks all subsequent analytical phases.
3. Once Phase 3 finishes, Phases 4, 5, and 6 can be developed largely in parallel (they all branch off the processed TPM/Count matrices).
4. Phase 7 executes last.
