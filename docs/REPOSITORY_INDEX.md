# Threezs bioinformatics repository index

This index is the hand-off point between the repositories used in the
bioinformatics projects.

| Repository | Main role | Use it for |
| --- | --- | --- |
| [RNA_pipeline](https://github.com/Threezs/RNA_pipeline) | Reproducible GEO/local bulk RNA-seq workflow | count validation, DESeq2, enrichment, WGCNA, PPI, immune and TF modules |
| [network-pharmacology-target-acquisition](https://github.com/Threezs/network-pharmacology-target-acquisition) | Network-pharmacology evidence and project archive | compound/target acquisition, disease targets, intersections, PPI, enrichment, figures and audit records |
| [ligand-receptor-docking-workflow](https://github.com/Threezs/ligand-receptor-docking-workflow) | Structure preparation and docking | receptor/ligand preparation, AutoDock Vina configuration, score summaries and docking QC |

## Recommended hand-off

1. Register the biological question, data source, species, groups, and
   replicate unit in PROJECT_STATUS.yml.
2. Run RNA_pipeline for count-based expression analysis and export only the
   documented result tables and figures.
3. Transfer target lists and evidence tables into the network-pharmacology
   project directory; retain the source accession, gene identifier type,
   species, and filtering rule.
4. Use the docking workflow only after the target and ligand structures,
   protonation, charge model, binding-site rationale, and parameter file have
   been recorded.
5. Link the final report back to the literature evidence IDs and Git commits.

Do not treat a high-throughput association, a network edge, or a docking score
as independent proof of a biological mechanism. Each repository records a
different layer of evidence and should keep its own assumptions visible.
