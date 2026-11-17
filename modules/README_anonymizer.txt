================================================================================
  Module: anonymizer.R
================================================================================

PURPOSE
-------
Removes identifier columns from a data frame and, on request, reduces
admission and discharge date-times to year and month.


WHEN IT RUNS
------------
Called by run_anonymizer.R, once for each input file.


WHAT IT DOES
------------
anonymize_dataset() applies these steps in order. Columns are matched by exact
name; a column that is absent is passed over.

  Step  Action
  ----  ----------------------------------------------------------------------
   1    Remove uid, uniquekey, match_key and baby_id, and the discharge
        copies uid_dis, uniquekey_dis and baby_id_dis.
   2    Remove adm_date_parsed.
   3    Remove the columns named in additional_remove. Names not found give a
        warning.
   4    If convert_datetimes is TRUE: replace datetimeadmission by
        adm_yearmonth and datetimedischarge by dis_yearmonth, in the same
        column position. Values are read as YYYY-MM-DD HH:MM:SS, or from their
        first ten characters as YYYY-MM-DD, and written as YYYY-MM. Values
        that cannot be read become NA.
   5    If add_anon_id is TRUE: add anon_id as the first column, numbering the
        rows from 1 in their current order.

Columns whose names differ from those listed, including the other _dis copies
in the master datasets (for example facility_dis), are kept unless they are
named in additional_remove.

The lists used in steps 1, 2 and 4 are the constants ANON_REMOVE_ALWAYS,
ANON_REMOVE_PIPELINE_COLS and ANON_DATETIME_CONVERT at the top of the module.

write_anonymizer_outputs() writes one {name}_anon.csv for each element of a
list of results, and anonymization_report.txt, into one folder.
run_anonymizer.R writes its files itself and uses only the report builder.


INPUTS
------
  df    Data frame to anonymise.
  cfg   List with additional_remove, convert_datetimes and add_anon_id.


OUTPUTS
-------
anonymize_dataset() returns a list:

  df              The anonymised data frame.
  removed         Names of the columns removed, including converted ones.
  converted       Text entries "original -> new" for converted columns.
  added           Names of the columns added.
  n_rows          Number of rows.
  n_cols_before   Number of columns before.
  n_cols_after    Number of columns after.


FUNCTIONS
---------
anonymize_dataset(df, cfg)
write_anonymizer_outputs(results_list, cfg, out_dir)


CONFIGURATION
-------------
  additional_remove   Further column names to remove.
  convert_datetimes   TRUE applies step 4.
  add_anon_id         TRUE applies step 5.
