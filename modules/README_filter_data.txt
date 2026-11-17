================================================================================
  Module: filter_data.R
================================================================================

PURPOSE
-------
Parses the admission date, works out the admission date window, and keeps the
admissions inside it.


WHEN IT RUNS
------------
Steps 3 to 5 of run_sample_maker.R and of each join run in run_all.R, after
loading and before the join. Discharges are not filtered.


WHAT IT DOES
------------
Date parsing. parse_admission_dates() adds the column adm_date_parsed
(date-time, UTC). datetimeadmission is read as YYYY-MM-DD HH:MM:SS; values
that fail are read from their first ten characters as YYYY-MM-DD. Values that
still fail are NA and are counted in a console warning.

Date window. resolve_date_window() returns the window and the output label.

  Setting                      Window
  ---------------------------  -----------------------------------------------
  use_advanced_mode = TRUE     None here; the per-facility ranges are applied
                               by the filter.
  adm_end_date given           adm_start_date to adm_end_date.
  adm_end_date = NULL          adm_start_date to the latest parsed admission
                               date minus one calendar month.

Filter. apply_admission_filter() keeps:

  Simple mode     Admissions dated from the start date (if set) to the end
                  date at 23:59:59. When a bound is set, admissions with an
                  NA date are dropped. If the configuration list has a
                  facility_filter element, only those facilities are kept;
                  the supplied config file does not define one.
  Advanced mode   For each entry c("FACILITY", "start", "end") of
                  facility_date_ranges, the admissions of that facility with
                  a date in the range. Each entry must have three elements,
                  and both dates must be given. A row selected by two
                  overlapping ranges is kept once; distinct rows are never
                  merged.

The function stops if no admission is left, or if advanced mode is on and
facility_date_ranges is empty.

apply_variable_filter() keeps the admissions whose value in the column
variable_filter_col is one of variable_filter_values. It returns the data
unchanged when either setting is NULL. The run scripts do not call it.


INPUTS
------
  admissions    Data frame with datetimeadmission, uid and facility.
  cfg           Configuration list: use_advanced_mode, adm_start_date,
                adm_end_date, facility_date_ranges.
  date_window   Result of resolve_date_window().


OUTPUTS
-------
  parse_admission_dates()    The data frame with adm_date_parsed added.
  resolve_date_window()      List: adm_start, adm_end, auto_mode, label.
  apply_admission_filter()   List: admissions (filtered), n_before, n_after,
                             n_excluded, filter_desc (lines for the report),
                             filter_label.
  apply_variable_filter()    List: admissions, n_excluded_varfilt,
                             var_filter_desc.

The label is built as described under FILE NAMES in
README_files/README_PIPELINE.txt.


FUNCTIONS
---------
parse_admission_dates(admissions)
resolve_date_window(admissions, cfg)
apply_admission_filter(admissions, date_window, cfg)
apply_variable_filter(admissions, cfg, filter_result)
