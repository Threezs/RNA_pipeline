# TF network provenance and species checks

The default configuration requests a mouse CollecTRI network. The decoupleR
documentation states that get_collectri supports human, mouse, and rat. The
workflow still checks the returned network against the DE gene identifiers
because network retrieval can fail or return an unexpected organism-specific
symbol set.

The TF script:

1. uses the DESeq2 Wald statistic when available, otherwise log2 fold change;
2. requests the configured organism explicitly;
3. requires source, target, and mode-of-regulation columns;
4. requires at least ten DE genes to overlap the returned target symbols; and
5. stops without writing a TF result when the overlap is too small.

For a mouse analysis, a human CollecTRI table must not be silently applied.
If the CollecTRI endpoint is unavailable or the overlap check fails, use a
versioned mouse TRRUST or another documented mouse regulon as a sensitivity
analysis, record its release date, and keep the network file with the run
record. Do not rescue a failed species check by simply changing gene symbols
to uppercase; use an explicit orthology table and report the mapping loss.

Reference: https://saezlab.github.io/decoupleR/reference/get_collectri.html
