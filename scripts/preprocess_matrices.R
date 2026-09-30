#!/usr/bin/env Rscript
# Clean raw integer counts and write a CPM table for downstream modules.

args <- commandArgs(trailingOnly = TRUE)
if (length(args) < 5) {
  stop("Usage: Rscript preprocess_matrices.R <raw_counts.csv> <meta.csv> ",
       "<out_counts_clean.csv> <out_cpm.csv> <group_column>")
}

raw_counts_file <- args[[1]]
meta_file <- args[[2]]
out_counts <- args[[3]]
out_cpm <- args[[4]]
group_column <- args[[5]]

suppressPackageStartupMessages(library(edgeR))

counts <- read.csv(raw_counts_file, check.names = FALSE, stringsAsFactors = FALSE)
meta <- read.csv(meta_file, check.names = FALSE, stringsAsFactors = FALSE)
if (ncol(counts) < 2) stop("Count matrix must contain a gene column and samples.")
if (!"sample_id" %in% names(meta)) stop("Metadata must contain sample_id.")
if (!group_column %in% names(meta)) {
  stop("Metadata must contain configured group column: ", group_column)
}

gene_ids <- trimws(as.character(counts[[1]]))
if (anyNA(gene_ids) || any(!nzchar(gene_ids))) stop("Gene IDs must be non-empty.")
sample_ids <- colnames(counts)[-1]
if (anyDuplicated(sample_ids)) stop("Count matrix sample columns must be unique.")
if (!setequal(sample_ids, as.character(meta$sample_id))) {
  stop("Count-matrix sample columns do not match metadata$sample_id.")
}
count_df <- counts[, -1, drop = FALSE]
count_mat <- suppressWarnings(as.matrix(data.frame(lapply(count_df, as.numeric),
                                                    check.names = FALSE)))
if (anyNA(count_mat)) stop("Count matrix contains non-numeric or missing values.")
if (any(count_mat < 0) || any(abs(count_mat - round(count_mat)) > 1e-8)) {
  stop("Raw counts must be finite, non-negative integers.")
}
mode(count_mat) <- "numeric"
rownames(count_mat) <- gene_ids

# Aggregate duplicated gene identifiers by summing counts before filtering.
count_mat <- rowsum(count_mat, group = rownames(count_mat), reorder = FALSE)
group <- factor(meta[[group_column]][match(colnames(count_mat), meta$sample_id)])
if (anyNA(group) || nlevels(group) < 2) {
  stop("The configured group column must match all samples and contain at least two groups.")
}
keep <- edgeR::filterByExpr(edgeR::DGEList(counts = count_mat), group = group)
count_mat <- count_mat[keep, , drop = FALSE]
if (!nrow(count_mat)) stop("No genes remain after low-expression filtering.")

lib_sizes <- colSums(count_mat)
if (any(!is.finite(lib_sizes) | lib_sizes <= 0)) stop("Sample library size is zero.")
cpm_mat <- sweep(count_mat, 2, lib_sizes, "/") * 1e6

clean_df <- data.frame(Gene = rownames(count_mat), count_mat, check.names = FALSE)
cpm_df <- data.frame(Gene = rownames(count_mat), cpm_mat, check.names = FALSE)
write.csv(clean_df, out_counts, row.names = FALSE)
write.csv(cpm_df, out_cpm, row.names = FALSE)
message("Wrote ", nrow(count_mat), " genes and ", ncol(count_mat),
        " samples. The normalized table is CPM, not TPM.")
