#!/usr/bin/env Rscript
args <- commandArgs(trailingOnly = TRUE)
if (length(args) < 7) {
  stop("Usage: Rscript ppi_network.R <de_res.csv> <padj> <lfc> <score> ",
       "<species> <out_edges.csv> <out_net.pdf>")
}

de_res_file <- args[[1]]
padj_thresh <- as.numeric(args[[2]])
lfc_thresh <- as.numeric(args[[3]])
ppi_score <- as.numeric(args[[4]])
species <- as.numeric(args[[5]])
out_edges <- args[[6]]
out_net <- args[[7]]

suppressPackageStartupMessages({
  library(STRINGdb)
})
de_res <- read.csv(de_res_file, check.names = FALSE, stringsAsFactors = FALSE)
sig_genes <- de_res[!is.na(de_res$padj) & de_res$padj < padj_thresh &
                    abs(de_res$log2FoldChange) > lfc_thresh, , drop = FALSE]
if (!nrow(sig_genes)) {
  write.csv(data.frame(), out_edges, row.names = FALSE)
  pdf(out_net); plot.new(); text(0.5, 0.5, "No significant PPI input"); dev.off()
  quit(status = 0)
}

string_db <- STRINGdb$new(version = "12.0", species = species,
                          score_threshold = ppi_score, network_type = "full",
                          input_directory = "")
mapped <- suppressWarnings(string_db$map(sig_genes, "Gene",
                                         removeUnmappedRows = TRUE))
if (!nrow(mapped) || !"STRING_id" %in% names(mapped)) {
  write.csv(data.frame(), out_edges, row.names = FALSE)
  pdf(out_net); plot.new(); text(0.5, 0.5, "No genes mapped to STRING"); dev.off()
  quit(status = 0)
}

hits <- unique(mapped$STRING_id)
interactions <- string_db$get_interactions(hits)
write.csv(interactions, out_edges, row.names = FALSE)
pdf(out_net, width = 8, height = 8)
plot_hits <- if (length(hits) > 50) hits[seq_len(50)] else hits
string_db$plot_network(plot_hits)
dev.off()
