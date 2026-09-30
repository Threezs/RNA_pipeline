#!/usr/bin/env Rscript
args <- commandArgs(trailingOnly = TRUE)
if (length(args) < 9) {
  stop("Usage: Rscript run_deseq2.R <counts> <meta> <ctrl> <treat> ",
       "<sample_col> <group_col> <out_res> <out_volcano> <out_pca>")
}

counts_file <- args[[1]]
meta_file <- args[[2]]
control_grp <- args[[3]]
treat_grp <- args[[4]]
sample_col <- args[[5]]
group_col <- args[[6]]
out_res <- args[[7]]
out_volcano <- args[[8]]
out_pca <- args[[9]]

suppressPackageStartupMessages({
  library(DESeq2)
  library(ggplot2)
})

counts <- read.csv(counts_file, check.names = FALSE, stringsAsFactors = FALSE)
meta <- read.csv(meta_file, check.names = FALSE, stringsAsFactors = FALSE)
if (!sample_col %in% names(meta) || !group_col %in% names(meta)) {
  stop("Metadata lacks configured columns: ", sample_col, " and/or ", group_col)
}
if (ncol(counts) < 2) stop("Count matrix has no sample columns.")
gene_ids <- as.character(counts[[1]])
count_mat <- as.matrix(data.frame(lapply(counts[, -1, drop = FALSE], as.numeric),
                                  check.names = FALSE))
if (anyNA(count_mat) || any(count_mat < 0) ||
    any(abs(count_mat - round(count_mat)) > 1e-8)) {
  stop("DESeq2 requires finite, non-negative integer counts.")
}
rownames(count_mat) <- gene_ids
sample_ids <- as.character(meta[[sample_col]])
if (anyDuplicated(sample_ids) || !all(colnames(count_mat) %in% sample_ids)) {
  stop("Metadata sample IDs must be unique and include every count column.")
}

groups <- as.character(meta[[group_col]])
is_control <- grepl(control_grp, groups, ignore.case = TRUE)
is_treat <- grepl(treat_grp, groups, ignore.case = TRUE)
if (any(is_control & is_treat) || sum(is_control) < 2 || sum(is_treat) < 2) {
  stop("Both groups need at least two non-overlapping biological replicates.")
}
keep_samples <- is_control | is_treat
meta2 <- data.frame(
  Group = factor(ifelse(is_treat[keep_samples], "Treatment", "Control"),
                 levels = c("Control", "Treatment")),
  row.names = sample_ids[keep_samples]
)
count_mat <- count_mat[, rownames(meta2), drop = FALSE]

dds <- DESeqDataSetFromMatrix(countData = round(count_mat),
                              colData = meta2, design = ~ Group)
dds <- DESeq(dds)
res <- results(dds, contrast = c("Group", "Treatment", "Control"))
res_df <- as.data.frame(res)
res_df$Gene <- rownames(res_df)
res_df <- res_df[, c("Gene", setdiff(names(res_df), "Gene"))]
write.csv(res_df, out_res, row.names = FALSE)

vsd <- vst(dds, blind = FALSE)
pca_data <- plotPCA(vsd, intgroup = "Group", returnData = TRUE)
percent_var <- round(100 * attr(pca_data, "percentVar"))
p_pca <- ggplot(pca_data, aes(PC1, PC2, color = Group)) +
  geom_point(size = 3) +
  xlab(paste0("PC1: ", percent_var[[1]], "% variance")) +
  ylab(paste0("PC2: ", percent_var[[2]], "% variance")) +
  theme_minimal()
ggsave(out_pca, plot = p_pca, width = 6, height = 5)

plot_df <- res_df
plot_df$neg_log10_padj <- ifelse(is.na(plot_df$padj), NA_real_,
                                 -log10(pmax(plot_df$padj, .Machine$double.xmin)))
plot_df$significant <- !is.na(plot_df$padj) &
  plot_df$padj < 0.05 & abs(plot_df$log2FoldChange) > 1
p_volcano <- ggplot(plot_df, aes(log2FoldChange, neg_log10_padj,
                                 color = significant)) +
  geom_point(alpha = 0.6, na.rm = TRUE) +
  scale_color_manual(values = c("grey60", "firebrick")) +
  theme_minimal() + theme(legend.position = "none")
ggsave(out_volcano, plot = p_volcano, width = 6, height = 5)
