#!/usr/bin/env Rscript
args <- commandArgs(trailingOnly = TRUE)
if (length(args) < 6) {
  stop("Usage: Rscript functional_enrichment.R <de_res.csv> <padj> <lfc> ",
       "<organism> <out_res.csv> <out_dot.pdf>")
}

de_res_file <- args[[1]]
padj_thresh <- as.numeric(args[[2]])
lfc_thresh <- as.numeric(args[[3]])
organism <- tolower(args[[4]])
out_res <- args[[5]]
out_dot <- args[[6]]

suppressPackageStartupMessages({
  library(clusterProfiler)
  library(ggplot2)
})

orgdb_pkg <- switch(organism,
  mouse = "org.Mm.eg.db",
  human = "org.Hs.eg.db",
  stop("organism must be mouse or human")
)
suppressPackageStartupMessages(library(orgdb_pkg, character.only = TRUE))
orgdb <- get(orgdb_pkg)
de_res <- read.csv(de_res_file, check.names = FALSE, stringsAsFactors = FALSE)
if (!all(c("Gene", "padj", "log2FoldChange") %in% names(de_res))) {
  stop("DE result must contain Gene, padj, and log2FoldChange columns.")
}

gene_ids <- sub("\\..*$", "", as.character(de_res$Gene))
from_type <- if (all(grepl("^[0-9]+$", gene_ids))) {
  "ENTREZID"
} else if (any(grepl("^ENS(MUS)?G", gene_ids, ignore.case = TRUE))) {
  "ENSEMBL"
} else {
  "SYMBOL"
}
mapped <- suppressWarnings(bitr(unique(gene_ids), fromType = from_type,
                                toType = "ENTREZID", OrgDb = orgdb))
if (!nrow(mapped)) stop("No DE genes mapped to the configured OrgDb.")

sig_ids <- gene_ids[!is.na(de_res$padj) & de_res$padj < padj_thresh &
                    abs(de_res$log2FoldChange) > lfc_thresh]
sig_map <- mapped[mapped[[from_type]] %in% sig_ids, , drop = FALSE]
universe_map <- mapped[mapped[[from_type]] %in% unique(gene_ids), , drop = FALSE]
if (!nrow(sig_map)) {
  write.csv(data.frame(), out_res, row.names = FALSE)
  pdf(out_dot); plot.new(); text(0.5, 0.5, "No significant mapped genes"); dev.off()
  quit(status = 0)
}

go <- tryCatch(enrichGO(gene = unique(sig_map$ENTREZID),
                        universe = unique(universe_map$ENTREZID),
                        OrgDb = orgdb, keyType = "ENTREZID", ont = "BP",
                        pAdjustMethod = "BH", readable = TRUE),
               error = function(e) NULL)
kegg_code <- if (organism == "mouse") "mmu" else "hsa"
kegg <- tryCatch(enrichKEGG(gene = unique(sig_map$ENTREZID),
                            universe = unique(universe_map$ENTREZID),
                            organism = kegg_code, pAdjustMethod = "BH"),
                 error = function(e) NULL)

tables <- list()
if (!is.null(go) && nrow(as.data.frame(go))) {
  go_df <- as.data.frame(go); go_df$term_type <- "GO_BP"; tables[[length(tables) + 1]] <- go_df
}
if (!is.null(kegg) && nrow(as.data.frame(kegg))) {
  kegg_df <- as.data.frame(kegg); kegg_df$term_type <- "KEGG"; tables[[length(tables) + 1]] <- kegg_df
}
if (length(tables)) {
  out_df <- do.call(rbind, tables)
  write.csv(out_df, out_res, row.names = FALSE)
  best <- if (!is.null(go) && nrow(as.data.frame(go))) go else kegg
  pdf(out_dot, width = 8, height = 6)
  print(dotplot(best, showCategory = 15) + ggtitle("Functional enrichment"))
  dev.off()
} else {
  write.csv(data.frame(), out_res, row.names = FALSE)
  pdf(out_dot); plot.new(); text(0.5, 0.5, "No significant enrichment"); dev.off()
}
