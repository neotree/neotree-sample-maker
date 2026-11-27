# Changelog

Releases are tagged in the repository.

## [v2.0.5]

- The user dictionaries in `user_dictionaries/` (used by `run_subsample_user_dict.R`) are updated from cleaning pipeline v2.0.3. They now list the HIV and syphilis clinical fields that the cleaning pipeline keeps in both countries, including the PHC files, and the Malawi admissions columns `antenatalcare_source` and `antenatalcare_category`.

## [v2.0.4]

- The outcome counts in the matching statistics report, the probabilistic matching report and the subsample report now read the discharge outcome. When admissions also have a `neotreeoutcome` column (Zimbabwe), the reports read `neotreeoutcome_dis`; before, they read the admissions column, which is almost always empty. The master files are not affected.
- Subsamples: an exclusion filter on `neotreeoutcome` is applied to `neotreeoutcome_dis` when the master has it, and selecting `neotreeoutcome` also keeps `neotreeoutcome_dis`. Before, on Zimbabwe masters, an outcome filter such as LAMA read the admissions column and removed almost nothing.
- `tests/test_episode_join.R` checks which outcome column the reports use and runs a subsample with conflicting admission and discharge outcomes.

## [v2.0.3]

- `run_all.R`, `run_sample_maker.R`, `run_anonymizer.R` and `run_data_profiler.R` now find their own folder when started with `Rscript` from another folder. Before, they kept the `--file=` prefix of the script path and worked with `Rscript` only when started from the `sample_maker_R` folder. RStudio was not affected.
- `tests/test_episode_join.R` starts `run_all.R` and `run_sample_maker.R` from another folder.

## [v2.0.2]

- `run_all.R` now creates the match keys before the duplicate check, as `run_sample_maker.R` already did. Before this, the duplicate check in `run_all.R` found no key column and removed nothing, and in episode mode the join stopped on repeated discharge keys. Files cleaned with the earlier duplicate removal have no repeated `uid` + facility keys, so master files built from them are not affected.
- Both run scripts call one function, `prepare_join_inputs()` in `modules/deduplicator.R`, which creates the match keys and then resolves repeated keys.
- The duplicate check stops if the data has no `match_key` column, and if a key is repeated anywhere except in discharges cleaned in episode mode that carry `stay_form_primary`; a repeated admission key always stops. Files joined on `uid` + facility are never resolved by `stay_form_primary`, since without a stay identifier the rows may be different stays; before, the most complete row was kept. When it stops, no duplicates log is written and the message gives the number of repeated keys and the columns the rows share. Repeated discharge keys in episode mode are still resolved by `stay_form_primary`. `possible_readmission` in the duplicates log now means two or more different admission datetimes, and the console no longer prints the keys.
- `run_all.R` run with `Rscript` exits with status 1 when a join run fails; in RStudio the session stays open.
- Console messages and the matching statistics report say "repeated match keys" instead of "uid+facility keys".
- `tests/test_episode_join.R` runs `prepare_join_inputs()` on made-up rows, runs `run_all.R` on made-up files with a repeated `uid` + facility key (it must stop with exit status 1 and write no master file), and checks that both run scripts call `prepare_join_inputs()`.

## [v2.0.1]

- Admissions and discharges cleaned in episode mode (columns `baby_id` and `stay_no`) are joined on `baby_id` + `stay_no` + facility; other files still join on `uid` + facility. The match key is created before the duplicate check, which now has an effect; when a stay has several discharge forms, the form marked `stay_form_primary` is joined. The join lines rows up by key and stops if a key is repeated.
- Probabilistic matches and the NA-coded master files identify rows by `match_key` or by `uid` + facility + `uniquekey`, since one `uid` + facility can hold several babies or stays. The advanced-mode date filters keep a row selected by two overlapping ranges once, by its position in the input, and no longer merge rows that share `uid` + facility.
- The anonymiser also removes `baby_id` and the discharge copies `uid_dis`, `uniquekey_dis` and `baby_id_dis`.
- `baby_id` and `stay_no` are mandatory columns of admissions, discharges and master subsamples, and `baby_id` of maternal subsamples, when present.
- The join stops if only one of the two files has `baby_id` and `stay_no`; the duplicate check stops if a stay does not have exactly one primary discharge form. In episode mode, an admission and a discharge with the same `uid` and facility are not offered as a probabilistic pair.
- New test script `tests/test_episode_join.R`.

## [v2.0.0]

This release contains the join scripts (`run_all.R`, `run_sample_maker.R`), which build the master datasets from cleaned admissions and discharges files by direct and probabilistic matching. It contains the subsample script (`run_subsample_maker.R`), which cuts subsamples from the master datasets or from cleaned files. It also contains the anonymiser, the data profiler and the data package workbook generator, with their configuration files, templates and documentation.
