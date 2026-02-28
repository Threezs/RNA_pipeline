# Data Model & File Architecture

## High-Level Folder Structure
```text
project_root/
├── Snakefile                # Main orchestration workflow
├── config.yaml              # Pipeline configuration (GEO IDs, thresholds)
├── envs/                    # Conda environments per rule
│   ├── fetch.yaml
│   ├── dge.yaml
│   ├── wgcna.yaml
│   └── ...
├── scripts/                 # PEP8 / R style compliant scripts
│   ├── fetch_geo.R
│   ├── run_deseq2.R
│   ├── ...
├── data/
│   ├── raw/                 # Downloaded GEO matrices & metadata
│   ├── processed/           # Standardized counts and TPM matrices
└── results/                 # Final output reports and figures
    ├── dge/
    ├── enrichment/
    ├── wgcna/
    ├── ppi/
    ├── survival/
    ├── immune/
    └── tf/
```

## Data Flow (Rules & Artifacts)

### Rule 1: `fetch_data`
- **Input:** `config.yaml` specifying `geo_id: "GSEXXXXX"`
- **Logic:** Uses `GEOquery` to download series matrix files and supplementary gene counts.
- **Output:** `data/raw/counts_raw.csv`, `data/raw/sample_metadata.csv`

### Rule 2: `preprocess_matrices`
- **Input:** `data/raw/counts_raw.csv`, `data/raw/sample_metadata.csv`
- **Logic:** Standardizes gene names, filters low-expressed genes, calculates TPM.
- **Output:** `data/processed/counts_clean.csv`, `data/processed/tpm_clean.csv`

### Rule 3: `dge_analysis`
- **Input:** `data/processed/counts_clean.csv`, `data/raw/sample_metadata.csv`
- **Logic:** Runs `DESeq2` based on design formula in config.
- **Output:** `results/dge/de_results.csv`, `results/dge/volcano.pdf`, `results/dge/pca.pdf`

### Rule 4: `functional_enrichment`
- **Input:** `results/dge/de_results.csv`
- **Logic:** `clusterProfiler` for GO and KEGG.
- **Output:** `results/enrichment/go_kegg_results.csv`, `results/enrichment/dotplot.pdf`

### Rule 5: `wgcna_analysis`
- **Input:** `data/processed/tpm_clean.csv`, `data/raw/sample_metadata.csv`
- **Logic:** Co-expression network construction.
- **Output:** `results/wgcna/module_traits.pdf`, `results/wgcna/gene_modules.csv`

### Rule 6: `ppi_network`
- **Input:** `results/dge/de_results.csv` (filtered for significance)
- **Logic:** `STRINGdb` mapping.
- **Output:** `results/ppi/ppi_network.pdf`, `results/ppi/ppi_edges.csv`

### Rule 7: `survival_analysis`
- **Input:** `results/dge/de_results.csv`, dynamically fetched TCGA clinical data
- **Logic:** Cox regression and Kaplan-Meier curves for top Hub/DE genes.
- **Output:** `results/survival/km_plots.pdf`

### Rule 8: `immune_infiltration`
- **Input:** `data/processed/tpm_clean.csv`
- **Logic:** `immunedeconv` execution.
- **Output:** `results/immune/infiltration_scores.csv`, `results/immune/barplot.pdf`

### Rule 9: `tf_prediction`
- **Input:** `results/dge/de_results.csv`, `data/processed/tpm_clean.csv`
- **Logic:** `decoupleR` based activity inference.
- **Output:** `results/tf/tf_activities.csv`, `results/tf/tf_heatmap.pdf`

### Rule 10: `alternative_splicing` (Optional / Conditional)
- *Only runs if transcript-level data is identified in `fetch_data`.*
