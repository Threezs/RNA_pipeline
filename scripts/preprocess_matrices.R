#!/usr/bin/env Rscript
# preprocess_matrices.R
# Cleans raw counts, standardizes, filters low expression, and calculates TPM (approximation)

args <- commandArgs(trailingOnly = TRUE)
if (length(args) < 4) {
  stop("Usage: Rscript preprocess_matrices.R <raw_counts.csv> <meta.csv> <out_counts_clean.csv> <out_tpm_clean.csv>")
}

raw_counts_file <- args[1]
meta_file <- args[2]
out_counts <- args[3]
out_tpm <- args[4]

library(dplyr)
library(readr)
library(tibble)

counts <- read_csv(raw_counts_file, show_col_types = FALSE)
meta <- read_csv(meta_file, show_col_types = FALSE)

# Basic Standardization
# 1. Assume first column is genes
gene_col <- colnames(counts)[1]

# 2. Filter out rows with NA genes or duplicated genes
counts_clean <- counts %>%
  filter(!is.na(!!sym(gene_col))) %>%
  distinct(!!sym(gene_col), .keep_all = TRUE)

# 3. Filter out low expressed genes (e.g., at least 10 counts across all samples)
# For safety, coerce the numeric matrix part
counts_num <- counts_clean[, -1]
valid_genes <- rowSums(counts_num, na.rm = TRUE) >= 10
counts_clean <- counts_clean[valid_genes, ]

# Write cleaned counts
write_csv(counts_clean, out_counts)

# 4. Approximate TPM (If actual transcript lengths aren't available, we can't do true TPM.)
# Often 'TPM' in bulk pipelines without length info is approximated by RPM/CPM
# We will do CPM (Counts per million) as a stand-in for normalized depth.
cpm_matrix <- sweep(counts_clean[,-1], 2, colSums(counts_clean[,-1], na.rm=TRUE), "/") * 1e6

tpm_clean <- bind_cols(counts_clean[,1], cpm_matrix)
write_csv(tpm_clean, out_tpm)

message("Preprocessing complete. Cleaned counts and TPM approximations generated.")
