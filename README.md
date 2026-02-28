# Public Database RNA-seq Analysis Pipeline

This repository contains a fully automated, scalable Snakemake pipeline designed to ingest GEO accession numbers and orchestrate a broad suite of bioinformatics analyses using isolated Conda environments.

## Features
- **Automated Fetching:** Retrieves author-provided counts and metadata directly from GEO.
- **Robust Preprocessing:** Cleans gene names, filters low counts, and computes TPM equivalents.
- **DGE & Enrichment:** DESeq2 and clusterProfiler GO/KEGG pipelines.
- **Networks & Survival:** WGCNA modules, STRINGdb interactomes, and TCGA correlation Kaplan-Meier curves.
- **Advanced Profiling:** Tumor Microenvironment immune infiltration estimation (quanTIseq) and Transcription Factor activity inference (decoupleR).
- **Conditional Handling:** Gracefully handles alternative splicing capabilities depending on raw transcript availability.

## Prerequisites
- [Snakemake](https://snakemake.readthedocs.io/en/stable/)
- [Conda/Mamba](https://github.com/conda-forge/miniforge) for automated environment provisioning.

## Quickstart

1. **Configure Pipeline:**
   Edit `config.yaml` to set your target `geo_id` and define your `control_group` and `treatment_group` logic.

2. **Run Pipeline:**
   Execute the following command from the project root (adjust cores `-c` as needed):
   ```bash
   snakemake --use-conda -c 8
   ```

## Project Standards Adherence
- Follows strict Snakemake Best Practices.
- Isolated Conda `envs/*.yaml` definitions ensure 100% reproducibility.
- Purely relative paths managed via Snakemake working directories.
- Coding standards adhere to modern clean pipeline practices.
