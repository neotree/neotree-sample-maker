# Contributing

## Rules

1. Do not commit data or secrets: no patient-level records, passwords or access tokens. Check staged changes with `git diff --cached` before committing. `install_packages_mirror.r` must keep its `YOUR_MIRROR_ADDRESS_HERE` and `YOUR_TOKEN_HERE` placeholders.
2. If the package set changes, update `install_packages.r`, `install_packages_mirror.r` and `required_packages.txt` together.
3. When a module changes, update `modules/README_<module>.txt`. When a run script or config file changes, update its README in `README_files/` (or `README_run_all.txt`).
4. `MANUAL.txt` is a compiled copy of the READMEs. Update it when a README changes.
5. Documentation describes what the code does. See the style of the existing READMEs.

## Workflow

1. Branch from the default branch.
2. Make the change and run the affected script end to end on test data.
3. Keep paths relative or configurable. No machine-specific absolute paths in committed code.
4. Open a pull request that describes the change and how it was tested.

## Input naming convention

The scripts find cleaned files by folder and file name: `{country}_{source}_{dataset}_{date}/{country}_{source}_{dataset}_{date}_cleaned.csv`. The convention is read in `run_all.R`, `modules/file_finder.R` and `modules/pipeline_file_resolver.R`. A change to it must be made in all three and in `input/README.md`.

## Code style

- `snake_case` object names, two-space indentation.
- UK English in prose, ASCII characters in code.
