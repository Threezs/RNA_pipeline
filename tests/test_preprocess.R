#!/usr/bin/env Rscript

# Execute the production preprocessing entry point on a deterministic fixture.
if (!file.exists("scripts/preprocess_matrices.R")) {
  stop("Run this test from the repository root.")
}

output_dir <- tempfile("rna-preprocess-test-")
dir.create(output_dir)
on.exit(unlink(output_dir, recursive = TRUE), add = TRUE)

clean_file <- file.path(output_dir, "counts_clean.csv")
cpm_file <- file.path(output_dir, "counts_cpm.csv")
command_output <- system2(
  file.path(R.home("bin"), "Rscript"),
  args = c(
    "scripts/preprocess_matrices.R",
    "tests/fixtures/preprocess_counts.csv",
    "tests/fixtures/preprocess_metadata.csv",
    clean_file,
    cpm_file,
    "group"
  ),
  stdout = TRUE,
  stderr = TRUE
)
exit_status <- attr(command_output, "status")
if (is.null(exit_status)) exit_status <- 0L
if (exit_status != 0L) {
  stop("Preprocessing command failed:\n", paste(command_output, collapse = "\n"))
}

if (!file.exists(clean_file) || !file.exists(cpm_file)) {
  stop("Preprocessing did not create both expected output files.")
}

clean <- read.csv(clean_file, check.names = FALSE, stringsAsFactors = FALSE)
cpm <- read.csv(cpm_file, check.names = FALSE, stringsAsFactors = FALSE)

expected_genes <- c("GeneA", "GeneB")
if (!identical(clean$Gene, expected_genes)) {
  stop("Unexpected retained genes: ", paste(clean$Gene, collapse = ", "))
}
if (!identical(cpm$Gene, expected_genes)) {
  stop("Counts and CPM outputs contain different genes.")
}

expected_counts <- rbind(
  GeneA = c(S1 = 110, S2 = 130, S3 = 100, S4 = 120),
  GeneB = c(S1 = 50, S2 = 60, S3 = 55, S4 = 58)
)
observed_counts <- as.matrix(clean[, names(expected_counts[1, ]), drop = FALSE])
rownames(observed_counts) <- clean$Gene
if (!all(observed_counts == expected_counts)) {
  stop("Duplicate-gene aggregation or sample matching changed unexpectedly.")
}

cpm_values <- as.matrix(cpm[, names(expected_counts[1, ]), drop = FALSE])
if (any(!is.finite(cpm_values)) || any(cpm_values < 0)) {
  stop("CPM output contains non-finite or negative values.")
}
if (any(abs(colSums(cpm_values) - 1e6) > 1e-6)) {
  stop("Each CPM sample column must sum to one million.")
}
if (!any(grepl("CPM, not TPM", command_output, fixed = TRUE))) {
  stop("The preprocessing message no longer states the CPM/TPM distinction.")
}

cat("R preprocessing regression test passed.\n")
