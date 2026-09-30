#!/usr/bin/env Rscript
# Infer TF activity from a species-matched CollecTRI network.
# A low gene overlap is treated as a data-source error, not as a valid result.

args <- commandArgs(trailingOnly = TRUE)
if (length(args) < 4) {
  stop("Usage: Rscript tf_prediction.R <de_res.csv> <organism> ",
       "<out_activities.csv> <out_heat.pdf>")
}
de_file <- args[[1]]
organism <- tolower(args[[2]])
out_acts <- args[[3]]
out_heat <- args[[4]]
if (!organism %in% c("human", "mouse", "rat")) {
  stop("organism must be human, mouse, or rat")
}

suppressPackageStartupMessages({
  library(decoupleR)
  library(pheatmap)
})

de_res <- read.csv(de_file, check.names = FALSE, stringsAsFactors = FALSE)
if (!all(c("Gene", "log2FoldChange") %in% names(de_res))) {
  stop("DE results must contain Gene and log2FoldChange columns.")
}
stat_column <- if ("stat" %in% names(de_res)) "stat" else "log2FoldChange"
stats <- as.numeric(de_res[[stat_column]])
names(stats) <- as.character(de_res$Gene)
stats <- stats[is.finite(stats)]
if (!length(stats)) stop("No finite ranking statistics are available.")

net <- tryCatch(
  get_collectri(organism = organism, split_complexes = FALSE),
  error = function(e) stop("Could not retrieve CollecTRI: ", conditionMessage(e))
)
required <- c("source", "target", "mor")
if (!all(required %in% names(net))) stop("CollecTRI network lacks source/target/mor columns.")
overlap <- sum(names(stats) %in% unique(net$target))
if (overlap < 10) {
  stop("Only ", overlap, " DE genes overlap the ", organism,
       " CollecTRI targets. Check gene identifiers and species; no TF result was written.")
}

acts <- run_wsum(mat = stats, network = net, .source = "source",
                 .target = "target", .mor = "mor", times = 100)
write.csv(as.data.frame(acts), out_acts, row.names = FALSE)

top_tfs <- acts[order(-abs(acts$score)), , drop = FALSE]
top_tfs <- head(top_tfs, 20)
pdf(out_heat, width = 7, height = 8)
barplot(rev(top_tfs$score), names.arg = rev(top_tfs$source), horiz = TRUE,
        las = 1, main = paste("Top TF activities:", organism),
        xlab = "Activity score",
        col = ifelse(rev(top_tfs$score) > 0, "firebrick", "dodgerblue"))
dev.off()
