# `input/`: cleaned datasets

The sample maker reads its input from this folder. The input is the output of the Neotree cleaning pipeline (`neotree-cleaning-pipeline`).

## Layout

Copy the cleaning pipeline's dataset folders into `input/` with their names unchanged, one folder per dataset:

```
input/
├── zim_db_admissions_2026-01-31/
│   ├── zim_db_admissions_2026-01-31_cleaned.csv
│   └── zim_db_admissions_2026-01-31_cleaned_na_coded.csv
├── zim_db_discharges_2026-01-31/
│   ├── zim_db_discharges_2026-01-31_cleaned.csv
│   └── zim_db_discharges_2026-01-31_cleaned_na_coded.csv
└── zim_db_neolab_2026-01-31/
    └── zim_db_neolab_2026-01-31_cleaned.csv
```

Folder names follow `{country}_{source}_{dataset}_{date}`:

| Part | Values |
|------|--------|
| `country` | `zim`, `mwi` |
| `source` | `db`, `mb` |
| `dataset` | `admissions`, `discharges`, `neolab`, `maternal_outcomes`, `combined_maternity_outcomes`, or any other dataset name |
| `date` | `YYYYMMDD`, `YYYYMMDDHHMM` or `YYYY-MM-DD` |

Each folder holds a file with the same name plus `_cleaned.csv`. The `_cleaned_na_coded.csv` file is optional; it is read only when `output_na_coded = TRUE`.

When several folders match the same country, source and dataset, the most recently modified `_cleaned.csv` file is used and a warning is shown.

`run_all.R` writes a `profiles/` folder inside each dataset folder.

## Reading another folder

To read the cleaned datasets from another location, set `cleaning_pipeline_output_dir` in `config_sample_maker.R` (and in the subsample config for cleaned mode) to that folder.

## Version control

`.gitignore` excludes everything in this folder except this file.
