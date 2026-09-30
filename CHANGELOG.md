# Changelog

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
