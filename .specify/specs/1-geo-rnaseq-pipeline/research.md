# Research & Technology Decisions: Downstream RNA-seq Analysis

## Technology Stack Selection

### 1. Differential Gene Expression (DGE)
- **Decision:** `DESeq2` (R package)
- **Rationale:** Industry standard for bulk RNA-seq differential expression from raw integer counts. Highly robust for small replicates.
- **Alternatives considered:** `edgeR`, `limma-voom`.

### 2. Functional Enrichment Analysis
- **Decision:** `clusterProfiler` (R package)
- **Rationale:** Comprehensive suite for both GO (Gene Ontology) and KEGG enrichment, with excellent visualization (dotplots, network plots).
- **Alternatives considered:** `gprofiler2`, `WebGestalt`.

### 3. Dimensionality Reduction & Clustering
- **Decision:** Base R `prcomp` + `ggplot2`, and `pheatmap`
- **Rationale:** Native R functions provide the most control for PCA and hierarchical clustering visualization.

### 4. Weighted Gene Co-expression Network Analysis (WGCNA)
- **Decision:** `WGCNA` (R package)
- **Rationale:** The canonical tool for identifying co-expressed gene modules and relating them to phenotypic traits.

### 5. Protein-Protein Interaction (PPI)
- **Decision:** `STRINGdb` (R package)
- **Rationale:** Automates the querying of the STRING database directly from R and plots interaction networks based on DEGs.

### 6. Survival Analysis
- **Decision:** `survival` and `survminer` (R packages) + TCGA data via `TCGAbiolinks`
- **Rationale:** `survival` handles the Kaplan-Meier modeling, `survminer` produces publication-quality plots. `TCGAbiolinks` allows programmatic retrieval of TCGA clinical data to evaluate the prognostic value of our GEO-derived genes.

### 7. Immune Infiltration
- **Decision:** `immunedeconv` (R package) / `CIBERSORT` algorithm
- **Rationale:** `immunedeconv` provides a unified interface to multiple deconvolution methods (CIBERSORT, xCell, MCP-counter, EPIC).
- **Alternatives considered:** Manual CIBERSORT implementation.

### 8. Transcription Factor (TF) Prediction
- **Decision:** `decoupleR` (R package) + `CollecTRI` network
- **Rationale:** State-of-the-art framework to infer transcription factor pathway activities from bulk transcriptomics.

### 9. Alternative Splicing
- **Decision:** `DEXSeq` / `tximport` (R packages) - *CONDITIONAL*
- **Rationale:** *CRITICAL NOTE*: Alternative splicing fundamentally requires transcript-level or exon-level quantification. If the GEO dataset only provides gene-level summarized counts (which is most common), alternative splicing analysis **cannot** be performed. The pipeline will attempt to run this ONLY if transcript-level data is provided by the authors.

## Architecture Orchestration
- **Decision:** `Snakemake`
- **Rationale:** Dictated by project constitution. Ensures reproducible, graph-based execution of the above R scripts.
- **Environment Management:** `Conda/Mamba` via Snakemake's `--use-conda` flag. Each step will have its own `envs/<step>.yaml`.
