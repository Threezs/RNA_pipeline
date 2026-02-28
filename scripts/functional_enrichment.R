#!/usr/bin/env Rscript
args <- commandArgs(trailingOnly = TRUE)
if(length(args) < 5) {
  stop("Usage: Rscript functional_enrichment.R <de_res.csv> <padj_thresh> <lfc_thresh> <out_res.csv> <out_dot.pdf>")
}
de_res_file <- args[1]
padj_thresh <- as.numeric(args[2])
lfc_thresh <- as.numeric(args[3])
out_res <- args[4]
out_dot <- args[5]

library(clusterProfiler)
library(org.Hs.eg.db)
library(dplyr)
library(readr)
library(ggplot2)

de_res <- read_csv(de_res_file, show_col_types = FALSE)
sig_genes <- de_res %>% 
  filter(padj < padj_thresh & abs(log2FoldChange) > lfc_thresh) %>% 
  pull(Gene)

if(length(sig_genes) > 0) {
  eg <- suppressWarnings(bitr(sig_genes, fromType="SYMBOL", toType="ENTREZID", OrgDb="org.Hs.eg.db"))
  
  if(nrow(eg) > 0) {
    ego <- enrichGO(gene = eg$ENTREZID, OrgDb = org.Hs.eg.db, ont = "BP", pAdjustMethod = "BH", qvalueCutoff = 0.05)
    
    if(!is.null(ego) && nrow(as.data.frame(ego)) > 0) {
      write_csv(as.data.frame(ego), out_res)
      p <- dotplot(ego, showCategory=15) + ggtitle("GO Enrichment")
      ggsave(out_dot, plot=p, width=8, height=6)
      quit(status=0)
    }
  }
}

# Fallback: Create empty outputs if no enrichment
file.create(out_res)
pdf(out_dot)
plot.new()
text(0.5, 0.5, "No significant enrichment found")
dev.off()
