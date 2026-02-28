<!--
Sync Impact Report:
- Version change: 0.0.0 -> 1.0.0
- List of modified principles: Added Core Principles for Bioinformatics Data Processing
- Added sections: Governance, Principles
- Removed sections: None
- Templates requiring updates: ✅ plan-template.md, ✅ spec-template.md, ✅ tasks-template.md
- Follow-up TODOs: None
-->

# Project Constitution

**Version**: 1.0.0
**Ratification Date**: 2026-02-27
**Last Amended**: 2026-02-27

## Governance

- **Amendment Procedure**: Changes to this constitution require a PR modifying this file directly, accompanied by explicit justification.
- **Versioning Policy**: Semantic versioning. MAJOR for backward-incompatible rule changes, MINOR for new rules, PATCH for clarifications.
- **Compliance Review**: All proposed architecture, PRs, and plans must be validated against these principles.

## Principles

### 1. Snakemake Best Practices Compliance
All analysis workflows MUST strictly adhere to official Snakemake best practices.
- **Rationale**: Ensures reproducibility, scalability, and maintainability of the bioinformatics pipeline.

### 2. Relative Paths & Config Management
All file paths MUST be relative and MUST be defined in `config.yaml`.
- **Rationale**: Prevents hardcoded absolute paths, enabling the project to be run seamlessly on any system or server environment.

### 3. Isolated Conda Environments
Each analysis step (Rule) MUST specify a dedicated and independent Conda environment configuration file (`.yaml`).
- **Rationale**: Avoids dependency conflicts and guarantees that each tool runs with exactly the software versions it requires.

### 4. PEP8 Standard for Python Scripts
Any supplementary or custom Python scripts MUST strictly conform to the PEP8 style guide.
- **Rationale**: Maintains a clean, readable, and uniform codebase, facilitating code review and future development.
