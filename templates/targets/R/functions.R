read_counts <- function(path) {
  x <- read.csv(path, check.names = FALSE, stringsAsFactors = FALSE)
  if (ncol(x) < 2) stop("Counts need a gene column and sample columns.")
  gene_ids <- trimws(as.character(x[[1]]))
  if (any(!nzchar(gene_ids)) || anyDuplicated(gene_ids)) {
    stop("Gene identifiers must be non-empty and unique.")
  }
  mat <- as.matrix(data.frame(lapply(x[, -1, drop = FALSE], as.numeric),
                              check.names = FALSE))
  if (anyNA(mat) || any(mat < 0) ||
      any(abs(mat - round(mat)) > 1e-8)) {
    stop("Counts must be finite, non-negative integers.")
  }
  rownames(mat) <- gene_ids
  mat
}

read_metadata <- function(path) {
  x <- read.csv(path, check.names = FALSE, stringsAsFactors = FALSE)
  if (!all(c("sample_id", "group") %in% names(x))) {
    stop("Metadata needs sample_id and group columns.")
  }
  if (anyDuplicated(x$sample_id) || any(!nzchar(x$sample_id))) {
    stop("Metadata sample_id values must be unique and non-empty.")
  }
  x
}

validate_sample_alignment <- function(counts, metadata) {
  if (!setequal(colnames(counts), metadata$sample_id)) {
    stop("Count columns and metadata sample_id values do not match.")
  }
  counts[, metadata$sample_id, drop = FALSE]
}

counts_to_cpm <- function(counts) {
  library_sizes <- colSums(counts)
  if (any(!is.finite(library_sizes) | library_sizes <= 0)) {
    stop("Library sizes must be positive.")
  }
  sweep(counts, 2, library_sizes, "/") * 1e6
}
