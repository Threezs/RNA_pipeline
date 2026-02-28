#!/usr/bin/env Rscript
args <- commandArgs(trailingOnly = TRUE)
if(length(args) < 6) {
  stop("Usage: Rscript ppi_network.R <de_res.csv> <padj> <lfc> <score> <out_edges.csv> <out_net.pdf>")
}
de_res_file <- args[1]
padj_thresh <- as.numeric(args[2])
lfc_thresh <- as.numeric(args[3])
ppi_score <- as.numeric(args[4])
out_edges <- args[5]
out_net <- args[6]

library(dplyr)
library(readr)
library(STRINGdb)

de_res <- read_csv(de_res_file, show_col_types = FALSE)
sig_genes <- de_res %>% filter(padj < padj_thresh & abs(log2FoldChange) > lfc_thresh)

if(nrow(sig_genes) > 0) {
  # We use STRINGdb
  string_db <- STRINGdb$new(version="12.0", species=9606, score_threshold=ppi_score, network_type="full", input_directory="")
  
  mapped <- suppressWarnings(string_db$map(as.data.frame(sig_genes), "Gene", removeUnmappedRows = TRUE))
  
  if(nrow(mapped) > 0) {
    hits <- mapped$STRING_id
    interactions <- string_db$get_interactions(hits)
    write_csv(interactions, out_edges)
    
    pdf(out_net, width=8, height=8)
    if(length(hits) > 50) hits <- hits[1:50] 
    options(warn=-1)
    string_db$plot_network(hits)
    dev.off()
    quit(status=0)
  }
}

# Fallback
file.create(out_edges)
pdf(out_net)
plot.new()
text(0.5, 0.5, "No significant PPI network found")
dev.off()
