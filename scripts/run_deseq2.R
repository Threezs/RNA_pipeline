#!/usr/bin/env Rscript
args <- commandArgs(trailingOnly = TRUE)
if(length(args) < 7) {
  stop("Usage: Rscript run_deseq2.R <counts> <meta> <ctrl> <treat> <out_res> <out_volcano> <out_pca>")
}
counts_file <- args[1]
meta_file <- args[2]
control_grp <- args[3]
treat_grp <- args[4]
out_res <- args[5]
out_volcano <- args[6]
out_pca <- args[7]

library(DESeq2)
library(dplyr)
library(readr)
library(ggplot2)

counts <- read_csv(counts_file, show_col_types = FALSE)
counts_mat <- as.matrix(counts[,-1])
rownames(counts_mat) <- counts[[1]]
counts_mat <- round(counts_mat)

meta <- read_csv(meta_file, show_col_types = FALSE)

# Robustly determine group assignment
group_col <- 2 # Assume 2nd column has grouping info (like titles)
meta$Group <- ifelse(grepl(control_grp, meta[[group_col]], ignore.case=TRUE), "Control", 
              ifelse(grepl(treat_grp, meta[[group_col]], ignore.case=TRUE), "Treatment", "Unknown"))

# Filter to known groups just in case
meta <- meta %>% filter(Group != "Unknown")
counts_mat <- counts_mat[, meta[[1]], drop = FALSE]

dds <- DESeqDataSetFromMatrix(countData = counts_mat, colData = meta, design = ~ Group)
dds <- DESeq(dds)
res <- results(dds, contrast=c("Group", "Treatment", "Control"))

res_df <- as.data.frame(res) %>% tibble::rownames_to_column("Gene")
write_csv(res_df, out_res)

# PCA
vsd <- vst(dds, blind=FALSE)
pcaData <- plotPCA(vsd, intgroup=c("Group"), returnData=TRUE)
percentVar <- round(100 * attr(pcaData, "percentVar"))
p_pca <- ggplot(pcaData, aes(PC1, PC2, color=Group)) + 
    geom_point(size=3) +
    xlab(paste0("PC1: ",percentVar[1],"% variance")) +
    ylab(paste0("PC2: ",percentVar[2],"% variance")) +
    theme_minimal()
ggsave(out_pca, plot=p_pca, width=6, height=5)

# Volcano
p_volcano <- ggplot(res_df, aes(x=log2FoldChange, y=-log10(padj))) + 
    geom_point(aes(color=(padj < 0.05 & abs(log2FoldChange) > 1)), alpha=0.5) +
    theme_minimal() +
    scale_color_manual(values=c("grey", "red")) +
    theme(legend.position="none")
ggsave(out_volcano, plot=p_volcano, width=6, height=5)
