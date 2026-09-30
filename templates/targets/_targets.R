library(targets)

tar_option_set(
  packages = c("readr")
)

source("R/functions.R")

list(
  tar_target(counts_file, "data/raw/counts_raw.csv", format = "file"),
  tar_target(metadata_file, "data/raw/sample_metadata.csv", format = "file"),
  tar_target(counts, read_counts(counts_file)),
  tar_target(metadata, read_metadata(metadata_file)),
  tar_target(checked, validate_sample_alignment(counts, metadata)),
  tar_target(cpm, counts_to_cpm(checked))
)
