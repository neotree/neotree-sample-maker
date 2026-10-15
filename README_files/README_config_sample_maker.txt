================================================================================
  Neotree Sample Maker -- config_sample_maker.R
================================================================================

PURPOSE
-------
Holds the settings of the join, as one list named CONFIG. It is read by
run_sample_maker.R and run_all.R.


SETTINGS
--------

Data selection

  country    "zim" or "mwi". Selects input folders that start with this code
             and sets the output prefix and folder.
  source     "from_database" or "from_metabase". Selects input folders with
             the source code db or mb. Any other value stops the run.

  run_all.R replaces both values for each pair it finds.

Admission date window

  use_advanced_mode      FALSE: one window for all facilities, from
                         adm_start_date and adm_end_date.
                         TRUE: one window per facility, from
                         facility_date_ranges; the two date settings are
                         ignored.
  adm_start_date         "YYYY-MM-DD", or NULL for no lower bound.
  adm_end_date           "YYYY-MM-DD", or NULL. With NULL the end date is the
                         latest parsed admission date in the file minus one
                         calendar month.
  facility_date_ranges   List of entries c("FACILITY", "start", "end") with
                         dates as "YYYY-MM-DD". Only admissions of the listed
                         facilities, inside their own range, are kept. Each
                         entry needs three elements and both dates. With
                         use_advanced_mode = TRUE an empty list stops the run.

  Both bounds are inclusive; the end date runs to 23:59:59. When a bound is
  set, admissions whose datetimeadmission cannot be parsed are left out.
  Discharges are never filtered by date. The run stops if no admission is left.

Paths

  cleaning_pipeline_output_dir   Folder that holds the cleaned dataset
                                 folders. Default "input". A path that does
                                 not exist as given is looked for under the
                                 script folder.
  output_dir                     Root folder for outputs. Default "outputs".
                                 run_all.R always uses the outputs/ folder
                                 beside the script.

Probabilistic matching

  prob_match_min_similarity          Lowest overall score, 0 to 100, for a
                                     pair to be kept as a candidate. 100
                                     accepts only pairs that agree on every
                                     compared variable.
  prob_match_max_candidates          Highest number of candidates kept for
                                     one admission, taken in order of score.
  prob_match_completeness_threshold  Proportion, 0 to 1. A variable is used
                                     only if at least this share of its
                                     values is filled in both files.
  prob_match_cross_facility          FALSE: an admission is compared only
                                     with unmatched discharges of the same
                                     facility. TRUE: when there is no
                                     unmatched discharge in the admission's
                                     facility, it is compared with all
                                     unmatched discharges.
  prob_match_birthweight_tolerance   Tolerances of the numeric variables, in
  prob_match_gestation_tolerance     the units of the data (birthweight in
  prob_match_ofc_tolerance           grams, gestation in weeks, ofc in cm,
  prob_match_temperature_tolerance   temperature in degrees Celsius). 0 means
  prob_match_apgar1_tolerance        only equal values score. A difference of
  prob_match_apgar5_tolerance        twice the tolerance or more scores 0.
  prob_match_apgar10_tolerance       A setting left out takes the default in
                                     modules/prob_matcher.R.

  The scoring rule is in modules/README_prob_matcher.txt.

NA-coded output

  output_na_coded   TRUE: run_all.R also writes na_coded versions of
                    master_joined and master_joined_extended, built from the
                    _cleaned_na_coded.csv files beside the cleaned inputs. If
                    either file is missing the na_coded versions are skipped
                    and the run continues.
                    FALSE: only the standard files are written.
                    run_sample_maker.R does not read this setting.


HOW TO USE
----------
Edit the values in config_sample_maker.R, or copy the file and pass the copy
to run_sample_maker.R as its first argument. run_all.R always reads
config_sample_maker.R from the script folder.
