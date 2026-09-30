# R targets starter

Use this template for an R-first project where the main steps are functions
rather than command-line tools. Keep Snakemake for mixed-language workflows or
when Conda isolation per rule is the main requirement.

Copy _targets.R and R/functions.R into a project, then run:

~~~r
targets::tar_make()
~~~

The starter reads a count matrix and metadata, checks sample alignment, and
creates a CPM table. Replace the example targets with the project-specific
DE, enrichment, and figure targets. Keep raw files outside Git when they are
large or controlled-access, and record their checksums in PROJECT_STATUS.yml.
