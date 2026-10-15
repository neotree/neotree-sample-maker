# Neotree Sample Maker

R scripts that join cleaned Neotree admissions and discharges files into master datasets and cut subsamples from them. The input is the output of the Neotree cleaning pipeline (`neotree-cleaning-pipeline`), copied into `input/`.

## What it does

| Script | Purpose |
|--------|---------|
| `run_all.R` | Finds every admissions and discharges pair in `input/` and builds the master datasets for each. |
| `run_sample_maker.R` | Builds the master datasets for the one country and source named in `config_sample_maker.R`. |
| `run_subsample_maker.R` | Cuts a subsample by date, facility, exclusion rules and column list, from the master datasets or from cleaned files. |
| `run_subsample_user_dict.R` | Writes an Excel workbook that combines the user dictionary with a profile of each subsample file. |
| `run_anonymizer.R` | Removes identifier columns from any output CSV. |
| `run_data_profiler.R` | Writes a per-variable profile of any CSV. |

The join matches admissions to discharges on `uid` and `facility`. Admissions left without a discharge are then compared with the unmatched discharges on shared clinical variables, and the best one-to-one pairs at or above a similarity threshold are accepted.

## Repository layout

```
neotree-sample-maker/
├── run_all.R, run_sample_maker.R, run_subsample_maker.R
├── run_subsample_user_dict.R, run_anonymizer.R, run_data_profiler.R
├── config_sample_maker.R             settings for the join
├── config_subsample_maker.R          settings for a subsample
├── config_subsample_TEMPLATE.R       annotated subsample settings, both modes
├── config_subsample_master_TEMPLATE.R, config_subsample_cleaned_TEMPLATE.R
├── install_packages.r, install_packages_mirror.r, required_packages.txt
├── modules/                          functions, one README per module
├── README_files/                     one README per script and config file
├── README_run_all.txt
├── MANUAL.txt                        the READMEs compiled into one file
├── user_dictionaries/                dictionary workbooks read by run_subsample_user_dict.R
├── input/                            cleaned datasets (see input/README.md)
├── outputs/                          master datasets (created on first run)
└── subsamples/                       subsample outputs (default location)
```

## Requirements

All scripts except one use base R only. `run_subsample_user_dict.R` needs `openxlsx`. `rstudioapi` is used, when available, to find the script folder when a script is sourced in RStudio.

`install_packages.r` installs both packages from CRAN. `install_packages_mirror.r` installs them from an internal package mirror; set the mirror address and access token at the top of that script before running it.

## Quick start

1. Copy the cleaning pipeline's dataset folders into `input/` (see `input/README.md`).
2. Build the master datasets:

   ```
   Rscript run_all.R
   ```

3. Copy `config_subsample_master_TEMPLATE.R` or `config_subsample_cleaned_TEMPLATE.R`, fill it in, and cut a subsample:

   ```
   Rscript run_subsample_maker.R config_subsample_mystudy.R
   ```

## Documentation

| Topic | File |
|-------|------|
| Workflow, folders, file names, data package workbook | `README_files/README_PIPELINE.txt` |
| Batch runner | `README_run_all.txt` |
| Join script and its settings | `README_files/README_run_sample_maker.txt`, `README_files/README_config_sample_maker.txt` |
| Contents of the master dataset files | `README_files/README_master_dataset.txt` |
| Subsample script and its settings | `README_files/README_run_subsample_maker.txt`, `README_files/README_config_subsample_maker.txt` |
| Anonymiser | `README_files/README_run_anonymizer.txt` |
| Data profiler | `README_files/README_run_data_profiler.txt` |
| One module | `modules/README_<module>.txt` |
| Layout of `input/` | `input/README.md` |

## Data governance

The repository holds code, dictionaries and documentation. `.gitignore` excludes everything in `input/`, `outputs/` and `subsamples/`, every `*_na_coded.csv` file, and common credential files. Do not commit patient-level data or access tokens.

## Licence

MIT. See `LICENSE`.
