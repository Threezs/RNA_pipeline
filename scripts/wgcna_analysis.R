#!/usr/bin/env Rscript
args <- commandArgs(trailingOnly = TRUE)
if(length(args) < 4) {
  stop("Usage: Rscript wgcna_analysis.R <tpm_clean.csv> <meta.csv> <out_modules.csv> <out_traits.pdf>")
}
tpm_file <- args[1]
meta_file <- args[2]
out_modules <- args[3]
out_traits <- args[4]

library(WGCNA)
library(dplyr)
library(readr)

options(stringsAsFactors = FALSE)
allowWGCNAThreads()

# Prepare data
tpm <- read_csv(tpm_file, show_col_types = FALSE)
datExpr <- as.data.frame(tpm[,-1])
rownames(datExpr) <- tpm[[1]]
datExpr <- t(datExpr) # WGCNA expects samples in rows, genes in cols

meta <- read_csv(meta_file, show_col_types = FALSE)
# Just a placeholder for trait parsing, we'll convert factors to numeric
traitData <- meta[,-1] 
traitData <- data.frame(lapply(traitData, function(x) as.numeric(as.factor(x))))
rownames(traitData) <- meta[[1]]

# Very simplified WGCNA pipeline
powers <- c(c(1:10), seq(from = 12, to=20, by=2))
sft <- pickSoftThreshold(datExpr, powerVector = powers, verbose = 5)
power <- sft$powerEstimate
if(is.na(power)) power <- 6

net <- blockwiseModules(datExpr, power = power,
                        TOMType = "unsigned", minModuleSize = 30,
                        reassignThreshold = 0, mergeCutHeight = 0.25,
                        numericLabels = TRUE, pamRespectsDendro = FALSE,
                        saveTOMs = FALSE, verbose = 3)

moduleColors <- labels2colors(net$colors)
gene_modules <- data.frame(Gene = colnames(datExpr), Module = moduleColors)
write_csv(gene_modules, out_modules)

# Basic plot (to satisfy output requirements)
pdf(out_traits)
plotDendroAndColors(net$dendrograms[[1]], moduleColors[net$blockGenes[[1]]],
                    "Module colors", dendroLabels = FALSE, hang = 0.03,
                    addGuide = TRUE, guideHang = 0.05)
dev.off()
