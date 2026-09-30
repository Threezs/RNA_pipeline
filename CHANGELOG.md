# Changelog

## 2026-10-01 (automation run)

- Replaced the fixed low-count cutoff with `edgeR::filterByExpr()` using the
  configured group column.
- Added a standard-library run-ledger recorder with configuration hashing.
- Added regression tests for valid/invalid count matrices and ledger rows, and
  run them in GitHub Actions.
- Updated the project status so completed templates are no longer listed as
  pending work.

## 2026-10-01

- Added a dependency-free count/metadata validator and made it a required
  quality-control gate before preprocessing.
- Removed the documented path to fabricated random counts when GEO supplementary
  files are unavailable.
- Made organism and STRING species configurable, and clarified that the
  historical tpm_clean.csv output contains CPM.
- Added literature search, article-record, evidence-extraction, project-status,
  run-ledger, and reproducibility templates.
- Added a lightweight GitHub Actions structural and Python syntax check.
