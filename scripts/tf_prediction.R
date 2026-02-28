#!/usr/bin/env Rscript
args <- commandArgs(trailingOnly = TRUE)
if(length(args) < 3) {
  stop("Usage: Rscript tf_prediction.R <de_res.csv> <out_acts.csv> <out_heat.pdf>")
}
de_file <- args[1]
out_acts <- args[2]
out_heat <- args[3]

library(decoupleR)
library(dplyr)
library(readr)
library(pheatmap)

de_res <- read_csv(de_file, show_col_types = FALSE)
# We need a named vector of statistics (e.g. log2FoldChange)
if(nrow(de_res) > 0) {
  stats <- setNames(de_res$log2FoldChange, de_res$Gene)
  
  # Load CollecTRI
  net <- get_collectri(organism='human', split_complexes=FALSE)
  
  # Run prediction using wsum
  acts <- run_wsum(mat=stats, network=net, .source='source', .target='target', .mor='mor', times = 100)
  
  write_csv(as.data.frame(acts), out_acts)
  
  # Top TFs
  top_tfs <- acts %>% arrange(desc(abs(score))) %>% head(20)
  
  pdf(out_heat, width=6, height=8)
  barplot(sort(setNames(top_tfs$score, top_tfs$source)), horiz=TRUE, las=1, 
          main="Top TF Activities (decoupleR)", xlab="Activity Score",
          col=ifelse(sort(top_tfs$score) > 0, "firebrick", "dodgerblue"))
  dev.off()
} else {
  file.create(out_acts)
  pdf(out_heat); plot.new(); text(0.5, 0.5, "No DEGs for TF prediction"); dev.off()
}
