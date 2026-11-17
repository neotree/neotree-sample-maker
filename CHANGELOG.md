# Changelog

Releases are tagged in the repository.

## [v2.0.1]

- Admissions and discharges cleaned in episode mode (columns `baby_id` and `stay_no`) are joined on `baby_id` + `stay_no` + facility; other files still join on `uid` + facility. The match key is created before the duplicate check, which now has an effect; when a stay has several discharge forms, the form marked `stay_form_primary` is joined. The join lines rows up by key and stops if a key is repeated.
- Probabilistic matches and the NA-coded master files identify rows by `match_key` or by `uid` + facility + `uniquekey`, since one `uid` + facility can hold several babies or stays. The advanced-mode date filters keep a row selected by two overlapping ranges once, by its position in the input, and no longer merge rows that share `uid` + facility.
- The anonymiser also removes `baby_id` and the discharge copies `uid_dis`, `uniquekey_dis` and `baby_id_dis`.
- `baby_id` and `stay_no` are mandatory columns of admissions, discharges and master subsamples, and `baby_id` of maternal subsamples, when present.
- The join stops if only one of the two files has `baby_id` and `stay_no`; the duplicate check stops if a stay does not have exactly one primary discharge form. In episode mode, an admission and a discharge with the same `uid` and facility are not offered as a probabilistic pair.
- New test script `tests/test_episode_join.R`.

## [v2.0.0]

This release contains the join scripts (`run_all.R`, `run_sample_maker.R`), which build the master datasets from cleaned admissions and discharges files by direct and probabilistic matching. It contains the subsample script (`run_subsample_maker.R`), which cuts subsamples from the master datasets or from cleaned files. It also contains the anonymiser, the data profiler and the data package workbook generator, with their configuration files, templates and documentation.
