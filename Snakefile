configfile: "config.yaml"

rule all:
    input:
        "results/qc/input_validation.txt",
        "data/processed/tpm_clean.csv",
        "data/processed/counts_clean.csv",
        "results/dge/de_results.csv",
        "results/enrichment/go_kegg_results.csv",
        "results/wgcna/gene_modules.csv",
        "results/ppi/ppi_edges.csv",
        "results/immune/infiltration_scores.csv",
        "results/tf/tf_activities.csv"

rule fetch_data:
    output:
        counts = "data/raw/counts_raw.csv",
        meta = "data/raw/sample_metadata.csv"
    params:
        geo_id = config["geo_id"]
    conda:
        "envs/fetch.yaml"
    shell:
        "Rscript scripts/fetch_geo.R {params.geo_id} {output.counts} {output.meta}"

rule validate_inputs:
    input:
        counts = "data/raw/counts_raw.csv",
        meta = "data/raw/sample_metadata.csv"
    output:
        report = "results/qc/input_validation.txt"
    params:
        gene_col = config.get("gene_column", "Gene"),
        sample_col = config.get("sample_id_column", "sample_id"),
        group_col = config.get("group_column", "group")
    shell:
        "python scripts/validate_project.py --counts {input.counts} "
        "--metadata {input.meta} --gene-column {params.gene_col} "
        "--sample-id-column {params.sample_col} --group-column {params.group_col} "
        "> {output.report}"

rule preprocess_matrices:
    input:
        counts = "data/raw/counts_raw.csv",
        meta = "data/raw/sample_metadata.csv",
        validation = "results/qc/input_validation.txt"
    output:
        counts_clean = "data/processed/counts_clean.csv",
        tpm_clean = "data/processed/tpm_clean.csv"
    conda:
        "envs/fetch.yaml"
    shell:
        "Rscript scripts/preprocess_matrices.R {input.counts} {input.meta} "
        "{output.counts_clean} {output.tpm_clean}"

rule dge_analysis:
    input:
        counts_clean = "data/processed/counts_clean.csv",
        meta = "data/raw/sample_metadata.csv"
    output:
        res = "results/dge/de_results.csv",
        volcano = "results/dge/volcano.pdf",
        pca = "results/dge/pca.pdf"
    params:
        ctrl = config["control_group"],
        treat = config["treatment_group"],
        sample_col = config.get("sample_id_column", "sample_id"),
        group_col = config.get("group_column", "group")
    conda:
        "envs/dge.yaml"
    shell:
        "Rscript scripts/run_deseq2.R {input.counts_clean} {input.meta} "
        "'{params.ctrl}' '{params.treat}' '{params.sample_col}' '{params.group_col}' "
        "{output.res} {output.volcano} {output.pca}"

rule functional_enrichment:
    input:
        res = "results/dge/de_results.csv"
    output:
        go_res = "results/enrichment/go_kegg_results.csv",
        dotplot = "results/enrichment/dotplot.pdf"
    params:
        padj = config["thresholds"]["padj"],
        lfc = config["thresholds"]["log2fc"],
        organism = config.get("organism", "mouse")
    conda:
        "envs/enrichment.yaml"
    shell:
        "Rscript scripts/functional_enrichment.R {input.res} {params.padj} "
        "{params.lfc} {params.organism} {output.go_res} {output.dotplot}"

rule wgcna_analysis:
    input:
        tpm = "data/processed/tpm_clean.csv",
        meta = "data/raw/sample_metadata.csv"
    output:
        modules = "results/wgcna/gene_modules.csv",
        traits = "results/wgcna/module_traits.pdf"
    conda:
        "envs/network_survival.yaml"
    shell:
        "Rscript scripts/wgcna_analysis.R {input.tpm} {input.meta} "
        "{output.modules} {output.traits}"

rule ppi_network:
    input:
        res = "results/dge/de_results.csv"
    output:
        edges = "results/ppi/ppi_edges.csv",
        net = "results/ppi/ppi_network.pdf"
    params:
        padj = config["thresholds"]["padj"],
        lfc = config["thresholds"]["log2fc"],
        score = config["thresholds"]["ppi_score"],
        species = config.get("string_species", 10090)
    conda:
        "envs/network_survival.yaml"
    shell:
        "Rscript scripts/ppi_network.R {input.res} {params.padj} {params.lfc} "
        "{params.score} {params.species} {output.edges} {output.net}"

rule immune_infiltration:
    input:
        tpm = "data/processed/tpm_clean.csv"
    output:
        scores = "results/immune/infiltration_scores.csv",
        bar = "results/immune/barplot.pdf"
    conda:
        "envs/advanced_profiling.yaml"
    shell:
        "Rscript scripts/immune_infiltration.R {input.tpm} {output.scores} {output.bar}"

rule tf_prediction:
    input:
        res = "results/dge/de_results.csv"
    output:
        acts = "results/tf/tf_activities.csv",
        heat = "results/tf/tf_heatmap.pdf"
    conda:
        "envs/advanced_profiling.yaml"
    shell:
        "Rscript scripts/tf_prediction.R {input.res} {output.acts} {output.heat}"
