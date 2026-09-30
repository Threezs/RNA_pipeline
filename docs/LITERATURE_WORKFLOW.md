# Literature reading and evidence workflow

The repository treats literature as structured research data rather than a
folder of PDFs.

## 1. Capture

Use Zotero for the canonical library. Add a stable citekey with Better BibTeX,
and keep one collection per project or review question. Export only the needed
collection to analysis/manuscript/references.bib with Better BibTeX's
Keep updated option. This creates a repeatable hand-off to Quarto without
copying a proprietary Zotero database into Git.

For each record, keep the DOI or PubMed ID, species, model, tissue, time point,
assay, and exact claim relevant to the project. The templates in
templates/literature are deliberately narrow so that a future reader can trace
a claim back to a source.

## 2. Search log

Record each database, complete search string, date, filters, number retrieved,
number screened, and reason for exclusion. Do not overwrite an earlier search:
append a new row with a new search_id.

## 3. Evidence extraction

Extract one claim per row. Identify the source, experimental system,
comparison, endpoint, direction, effect estimate or quoted result, and
confidence. Separate what the paper directly reports from an inference made for
the current project.

For animal or human studies, record the biological replicate unit and sample
size. For computational studies, record reference genome, annotation release,
software versions, normalization, statistical model, and threshold.

## 4. Link evidence to analysis

Use record_id, citekey, and evidence_id in analysis notes and figure captions.
A result should be traceable as:

~~~text
figure/table -> analysis output -> script/config -> evidence or source data
~~~

Keep the project conclusion in PROJECT_STATUS.yml and uncertainty in its
limitations field. This prevents a plausible biological story from being
mistaken for a result directly demonstrated by a paper.

## 5. Review states

Use unread, screening, included, extracted, cited, or excluded. An excluded
paper should retain a short reason such as wrong species, wrong endpoint,
duplicate record, or insufficient primary data.

Useful references:

- Quarto citations: https://quarto.org/docs/authoring/citations.html
- Better BibTeX automatic export:
  https://retorque.re/zotero-better-bibtex/exporting/auto/
- rrtools research compendium: https://github.com/benmarwick/rrtools
