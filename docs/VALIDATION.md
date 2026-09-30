# Input and interpretation checks

The pipeline applies these checks before normalization:

1. The count matrix and metadata both exist and are valid UTF-8 CSV files.
2. The first count column is the configured gene identifier column.
3. Gene IDs and metadata sample IDs are non-empty and unique.
4. Count values are numeric, finite, integer-valued, and non-negative.
5. Every count-matrix sample has exactly one metadata row, and no metadata sample
   is absent from the count matrix.
6. Each declared group has at least two biological replicates. A warning is
   emitted for an unbalanced group; the workflow does not silently drop samples.

The validator writes a human-readable report to
results/qc/input_validation.txt. A non-zero exit status stops Snakemake.

The validator cannot establish that samples are biologically independent, that
a batch effect is absent, or that a GEO matrix contains raw counts rather than
already-normalized values. Those questions must be documented in the project
status file and checked against the source study.

## Normalization naming

The historical output path data/processed/tpm_clean.csv is kept so existing
rules remain compatible. The values are CPM computed from raw counts. Do not
describe them as TPM in a manuscript unless lengths were used.

## Module validity

- DESeq2 receives raw integer counts only.
- WGCNA and immune deconvolution receive the CPM table.
- PPI uses the species code in config.yaml; do not mix human annotations into a
  mouse analysis without an explicit orthology decision.
- Survival analysis requires user-supplied expression and clinical data and is
  not part of the default workflow.
