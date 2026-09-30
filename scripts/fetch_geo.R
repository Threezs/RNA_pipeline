#!/usr/bin/env Rscript
# Fetch GEO metadata and an author-provided count matrix.
# This script deliberately stops when a real count matrix cannot be identified.

args <- commandArgs(trailingOnly = TRUE)
if (length(args) < 3) {
  stop("Usage: Rscript fetch_geo.R <GEO_ID> <output_counts.csv> <output_meta.csv>")
}

geo_id <- args[[1]]
out_counts <- args[[2]]
out_meta <- args[[3]]

suppressPackageStartupMessages({
  library(GEOquery)
})

message(sprintf("Fetching GEO metadata for %s", geo_id))
gse <- getGEO(geo_id, GSEMatrix = TRUE)
if (length(gse) == 0) {
  stop("No GEO series matrix was returned for ", geo_id)
}
eset <- if (is.list(gse)) gse[[1]] else gse
pdata <- as.data.frame(Biobase::pData(eset), stringsAsFactors = FALSE)
pdata$sample_id <- rownames(pdata)

# Prefer an explicit group column. Otherwise make a conservative heuristic and
# leave unresolved samples as NA so the user must review the metadata.
if (!"group" %in% names(pdata)) {
  text_columns <- intersect(c("title", "source_name_ch1", "characteristics_ch1"),
                            names(pdata))
  sample_text <- if (length(text_columns)) {
    apply(pdata[, text_columns, drop = FALSE], 1, paste, collapse = " ")
  } else {
    rep("", nrow(pdata))
  }
  pdata$group <- ifelse(
    grepl("control|sham|vehicle|untreated", sample_text, ignore.case = TRUE),
    "Control",
    ifelse(grepl("treat|apap|acetaminophen|drug|injury", sample_text,
                 ignore.case = TRUE), "Treatment", NA_character_)
  )
}
write.csv(pdata, out_meta, row.names = FALSE, na = "")

supp_dir <- file.path(dirname(out_counts), "geo_supp")
dir.create(supp_dir, recursive = TRUE, showWarnings = FALSE)
supp <- getGEOSuppFiles(geo_id, makeDirectory = FALSE, baseDir = supp_dir)
if (is.null(supp) || nrow(supp) == 0) {
  stop("GEO has no supplementary files from which to obtain a count matrix. ",
       "Provide data/raw/counts_raw.csv and data/raw/sample_metadata.csv manually.")
}

paths <- normalizePath(rownames(supp), mustWork = FALSE)
archives <- paths[grepl("\\.(tar|tar\\.gz|tgz)$", tolower(paths))]
if (length(archives)) {
  unpack_dir <- file.path(supp_dir, "unpacked")
  dir.create(unpack_dir, recursive = TRUE, showWarnings = FALSE)
  for (archive in archives) {
    untar(archive, exdir = unpack_dir)
  }
}
all_files <- list.files(supp_dir, recursive = TRUE, full.names = TRUE)
all_files <- all_files[!dir.exists(all_files)]
candidate <- all_files[grepl(
  "count|matrix|raw|feature|umi|read", basename(all_files), ignore.case = TRUE
)]
if (!length(candidate)) {
  candidate <- all_files[grepl("\\.(csv|tsv|txt)(\\.gz)?$", tolower(all_files))]
}
if (!length(candidate)) {
  stop("Supplementary files were downloaded but no plausible count matrix was found. ",
       "Inspect ", supp_dir, " and supply a validated matrix manually.")
}
candidate <- candidate[order(!grepl("count|matrix|raw", basename(candidate),
                                    ignore.case = TRUE))]
matrix_path <- candidate[[1]]
message("Reading candidate count matrix: ", matrix_path)

plain_path <- sub("\\.gz$", "", tolower(matrix_path))
if (grepl("\\.csv$", plain_path)) {
  counts <- read.csv(matrix_path, check.names = FALSE, stringsAsFactors = FALSE)
} else {
  counts <- read.delim(matrix_path, check.names = FALSE, stringsAsFactors = FALSE)
}
if (ncol(counts) < 2) {
  stop("The selected supplementary file has fewer than two columns: ", matrix_path)
}
write.csv(counts, out_counts, row.names = FALSE)
message("Saved counts to ", out_counts)
