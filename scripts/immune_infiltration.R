#!/usr/bin/env Rscript
args <- commandArgs(trailingOnly = TRUE)
if(length(args) < 3) {
  stop("Usage: Rscript immune_infiltration.R <tpm.csv> <out_scores.csv> <out_bar.pdf>")
}
tpm_file <- args[1]
out_scores <- args[2]
out_bar <- args[3]

library(immunedeconv)
library(dplyr)
library(readr)
library(ggplot2)
library(tidyr)

tpm <- read_csv(tpm_file, show_col_types = FALSE)
expr_mat <- as.matrix(tpm[,-1])
rownames(expr_mat) <- tpm[[1]]

# Run quantiseq as it's built-in and robust (cibersort needs external files usually)
res <- deconvolute(expr_mat, "quantiseq")

res_df <- as.data.frame(res)
write_csv(res_df, out_scores)

res_long <- res_df %>%
  pivot_longer(cols = -cell_type, names_to = "Sample", values_to = "Score")

p <- ggplot(res_long, aes(x=Sample, y=Score, fill=cell_type)) +
  geom_bar(stat="identity") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle=90, hjust=1)) +
  labs(title="Immune Infiltration (quanTIseq)", y="Fraction")

ggsave(out_bar, plot=p, width=8, height=6)
