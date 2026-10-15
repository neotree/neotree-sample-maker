================================================================================
  Neotree Sample Maker -- run_data_profiler.R and modules/data_profiler.R
================================================================================

PURPOSE
-------
Writes a profile of a CSV file: one row per column with its type, missingness
and summary statistics, as a CSV and as a text report.


WHEN IT RUNS
------------
run_data_profiler.R is run on demand on any CSV file. The other scripts
produce the same profile through profile_and_write() in
modules/data_profiler.R:

  run_all.R               every CSV in the input folder; the two cleaned
                          inputs and the two master datasets of each join
  run_sample_maker.R      the two cleaned inputs and the two master datasets
  run_subsample_maker.R   the master subsample, or each cleaned-mode subsample


WHAT IT DOES
------------
A value is missing when it is NA, or, in a text column, empty or made of
spaces only.

Column type:

  boolean       The column is read by R as logical (TRUE/FALSE).
  numeric       Not boolean, at least one value present, the share of present
                values that convert to a number is at least numeric_threshold,
                and the number of distinct values is at most
                max_numeric_distinct.
  categorical   Everything else.

Columns of the profile CSV:

  All types     variable, type, n_total, n_present, n_missing, pct_missing,
                n_distinct, sample_values (the three most frequent values,
                separated by " | ")
  numeric       min, max, mean, median, sd (rounded to 4 decimals),
                mode_value (most frequent value)
  boolean       n_true, n_false, pct_true (share of present values)
  categorical   top1_value, top1_n, top2_value, top2_n, top3_value, top3_n

Fields that do not apply to a column's type are empty.

The text report has a header (source, rows, column counts by type), one table
for each type, and a list of the columns with missing values in descending
order of pct_missing.


SETTINGS
--------
PROFILER_CONFIG, inside run_data_profiler.R:

  input_file             Path of the CSV to profile. Replaced by the first
                         command-line argument when one is given; that path
                         is tried as given and then under the script folder.
  output_dir             NULL writes beside the input file. Otherwise the
                         folder to write to; it is created if needed.
  numeric_threshold      Default 0.90.
  max_numeric_distinct   Default 500.


OUTPUTS
-------
  {input file name}_variable_profile.csv
  {input file name}_variable_profile.txt


FUNCTION
--------
profile_and_write(df, out_path_base, numeric_threshold = 0.90,
                  max_numeric_distinct = 500, source_label = NULL,
                  quiet = FALSE)

Profiles the data frame df and writes {out_path_base}_variable_profile.csv and
{out_path_base}_variable_profile.txt, creating the folder if needed.
source_label is the name shown in the report header; the default is the last
part of out_path_base. quiet = TRUE suppresses console messages. Returns,
invisibly, a list with the two paths, csv and txt.


HOW TO RUN
----------
  Rscript run_data_profiler.R path/to/file.csv

or set input_file in PROFILER_CONFIG and run the script without arguments.
