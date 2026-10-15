================================================================================
  Modules: subsample_maker.R and subsample_maker_cleaned.R
================================================================================

PURPOSE
-------
Hold the filtering and writing functions used by run_subsample_maker.R.
subsample_maker.R serves master mode; subsample_maker_cleaned.R serves cleaned
mode.


WHEN IT RUNS
------------
Sourced by run_subsample_maker.R according to source_type. The script loads
the input files and the na_coded sources, and passes them to these functions.


WHAT IT DOES
------------
The filtering rules of both modes (date and facility filter, exclusion
filters, column selection, matched-only files) are described in
README_files/README_run_subsample_maker.txt, and the settings in
README_files/README_config_subsample_maker.txt.

In master mode, run_subsample_maker() applies the same steps to master_joined
and master_joined_extended and derives the two matched-only data frames.
Column selection is worked out on master_joined and applied to both.

In cleaned mode, run_subsample_maker_cleaned() processes one data frame. The
calling script passes the mandatory columns and the date column of the dataset
type.

Both keep the original row names of the input through filtering. The calling
script uses them to pick the same rows from the na_coded source.

The output label is built as described under FILE NAMES in
README_files/README_PIPELINE.txt.


INPUTS
------
Master mode:

  master_joined, master_joined_extended   Data frames read from the master
                                          files. Both need datetimeadmission.
  cfg                                     SUBSAMPLE_CONFIG.

Cleaned mode:

  df               Data frame read from one cleaned file.
  mandatory_cols   Columns always kept when a column list is set.
  date_col         Name of the date column, or NULL.
  cfg_global       SUBSAMPLE_CONFIG.
  cfg_dataset      The entry of SUBSAMPLE_CONFIG$datasets for this type, or
                   NULL.


OUTPUTS
-------
run_subsample_maker() returns a list:

  subsample_joined, subsample_joined_extended,
  subsample_joined_matched_only, subsample_joined_extended_matched_only
                                 The four data frames.
  meta_joined, meta_extended     Counts and date range after the date and
                                 facility filter.
  excl_joined, excl_extended     Rows removed by each exclusion filter.
  sub_filter_desc, sub_label     Filter description lines and output label.
  col_info                       Columns kept, mandatory, requested and not
                                 found.

run_subsample_maker_cleaned() returns a list with data (the filtered data
frame), label, the row counts n_raw, n_after_date, n_after_excl and n_final,
cols_selected, cols_not_found, the effective settings (date_col, start_date,
end_date, date_window_note, facility_filter, use_adv, adv_ranges,
excl_filters, sub_vars, mandatory_cols) and facility_breakdown.

The files written are listed in README_files/README_run_subsample_maker.txt.


FUNCTIONS
---------
subsample_maker.R

  run_subsample_maker(master_joined, master_joined_extended, cfg)
  write_subsample_outputs(sub_result, cfg, prefix, out_dir, na_coded = NULL)
      Writes the four CSV files and the report, and returns their paths.
      na_coded is NULL or a list with the elements joined, extended,
      joined_matched and extended_matched; when given, the four na_coded
      files are written too.

subsample_maker_cleaned.R

  run_subsample_maker_cleaned(df, mandatory_cols, date_col, cfg_global,
                              cfg_dataset = NULL)
  write_subsample_outputs_cleaned(result, prefix, type_label, out_dir,
                                  na_coded_data = NULL)
      Writes the CSV file and the report, and returns their paths. When
      na_coded_data is a data frame it is written as the na_coded file.

modules/subsample_maker_maternal.R and modules/subsample_maker_neolab.R define
run_subsample_maker_maternal(), write_subsample_outputs_maternal(),
run_subsample_maker_neolab() and write_subsample_outputs_neolab(). None of the
run scripts sources these two modules.
