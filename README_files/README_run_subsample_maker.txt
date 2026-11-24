================================================================================
  Neotree Sample Maker -- run_subsample_maker.R
================================================================================

PURPOSE
-------
Cuts a subsample by date, facility, exclusion rules and column list. It reads
either the master datasets (master mode) or cleaned files (cleaned mode).


WHEN IT RUNS
------------
Master mode runs after run_all.R or run_sample_maker.R has written the master
datasets. Cleaned mode needs only the cleaned datasets in the input folder.


HOW THE SETTINGS ARE SUPPLIED
-----------------------------
The settings are one list named SUBSAMPLE_CONFIG (see
README_config_subsample_maker.txt). The script takes it from:

  1. a file given as the first command-line argument, or named in a session
     variable SUBSAMPLE_CONFIG_FILE. The path is tried as given and then under
     the working directory;
  2. otherwise, a SUBSAMPLE_CONFIG object already in the R session;
  3. otherwise, the block inside run_subsample_maker.R.

config_subsample_maker.R and the templates are not read unless passed in this
way.

INCLUDE_METABASE, near the top of the script, is FALSE by default. While it is
FALSE, a config with source = "from_metabase" stops the run, in either mode.


MASTER MODE  (source_type = "master")
-------------------------------------
The same steps are applied to master_joined and to master_joined_extended.

1. Dates. adm_date_parsed is parsed again from datetimeadmission.

2. Date and facility filter.
   Simple mode: keeps rows with an admission date from sub_start_date to
   sub_end_date, both inclusive, and a facility in sub_facility_filter. A
   setting that is NULL is not applied. When either date is set, rows with no
   parsable admission date are dropped.
   Advanced mode: keeps, for each entry of sub_facility_date_ranges, the rows
   of that facility inside its range. Each entry needs both dates. A row
   selected by two overlapping ranges is kept once; distinct rows are never
   merged.
   The run stops if no row is left.

3. Exclusion filters. Each filter removes the rows that meet its condition.
   Rows where the variable is missing are kept. When the filter value is a
   number the column is compared as numbers, otherwise as text. A filter on a
   column that does not exist is skipped and reported. An unknown operator
   stops the run. A filter on neotreeoutcome is applied to the discharge
   outcome, neotreeoutcome_dis, when the master has it (Zimbabwe admissions
   carry their own, mostly empty, neotreeoutcome column).

4. Column selection. With sub_variables set, the output keeps those columns
   and the columns uid, facility, uniquekey, datetimeadmission, baby_id,
   stay_no, match_key, adm_date_parsed, match_type and prob_match_similarity
   (those present), in their original order. Requested names that do not
   exist are reported and skipped. Selecting neotreeoutcome also keeps
   neotreeoutcome_dis when it exists.

5. Matched-only files. subsample_master_matched_only is the direct_match rows
   of the master subsample; subsample_master_extended_matched_only is the
   direct_match and prob_match rows of the extended subsample.

6. NA-coded files. With output_na_coded = TRUE, the script looks for a file
   named like each master file with _na_coded before .csv. If both exist, it
   writes an na_coded copy of each of the four subsample files, holding the
   same rows taken from the na_coded master files. Column selection is not
   applied to these copies. If either file is missing they are not written.

7. Profile of the master subsample.

Outputs, in output_dir. {prefix} is the part of the master_joined file name
before _master_joined.

  {prefix}_subsample_master_{label}.csv
  {prefix}_subsample_master_extended_{label}.csv
  {prefix}_subsample_master_matched_only_{label}.csv
  {prefix}_subsample_master_extended_matched_only_{label}.csv
  the same four names ending in _na_coded.csv           (step 6)
  {prefix}_subsample_report_{label}.txt
  profiles/{prefix}_subsample_master_{label}_variable_profile.csv / .txt

The report lists the input files, the filter, rows kept and dropped with a
breakdown by match_type, the rows removed by each exclusion filter, the column
selection, counts by facility, the matched-only counts, the distribution of
the discharge outcome among matched rows (neotreeoutcome_dis when admissions
also have a neotreeoutcome column), and the output files.


CLEANED MODE  (source_type = "cleaned")
---------------------------------------
Each dataset type with include = TRUE is processed on its own: admissions,
discharges, neolab, maternal. The file is found under
cleaning_pipeline_output_dir by country, source and dataset name; maternal
means maternal_outcomes for zim and combined_maternity_outcomes for mwi. A
type whose file is not found is skipped, and the others still run. The run
stops if no type is enabled.

1. Effective settings. sub_start_date, sub_end_date, sub_variables and
   sub_exclusion_filters set inside the dataset entry replace the global ones
   for that type. sub_end_date_offset_months then moves the end date by that
   number of calendar months.

2. Date and facility filter, on the type's date_column.
   Simple mode: keeps rows dated from the start date to the end date, both
   inclusive. Rows whose date is missing or cannot be read are kept. Then
   keeps the facilities in sub_facility_filter.
   Advanced mode (sub_use_advanced_mode = TRUE with a non-empty
   sub_facility_date_ranges): keeps, for each entry, the rows of that facility
   inside its range. A date given as NA leaves that side open. Rows with no
   date are kept only by an entry with both sides open.
   With date_column = NULL no date filter is applied and sub_facility_filter
   is still applied. With a date_column that is not in the file, neither the
   date filter nor the facility filter is applied.
   Dates are read as YYYY-MM-DD, YYYYMMDD, or a date-time that starts with
   YYYY-MM-DD.

3. Exclusion filters. As in master mode, except that values are compared as
   they are read, without conversion to numbers, and a filter with an unknown
   operator is skipped.

4. Column selection. With a column list, the output keeps the mandatory
   columns of the type, the date column, and the listed columns:

     admissions   uid, facility, uniquekey, datetimeadmission, baby_id, stay_no
     discharges   uid, facility, uniquekey, baby_id, stay_no
     neolab       uid, facility, uniquekey, datebct, and nuid if present
     maternal     uid, facility, uniquekey, dateadmission, baby_id
   (baby_id and stay_no only when the cleaned file has them)

5. NA-coded file. With output_na_coded = TRUE the script reads the type's
   _cleaned_na_coded.csv file and writes the rows at the same positions as
   the rows kept above, with all columns of that file. If the file is not
   found the na_coded output is skipped.

6. Profile of the subsample.

Outputs, in output_dir. {prefix} is the country in upper case and the source
code, for example ZIM_db.

  {prefix}_subsample_{type}_{label}.csv
  {prefix}_subsample_{type}_{label}_na_coded.csv        (step 5)
  {prefix}_subsample_{type}_{label}_report.txt
  profiles/{prefix}_subsample_{type}_{label}_variable_profile.csv / .txt

Missing values (NA in R) are written as the text NA in the cleaned-mode CSV
files and as empty cells in the master-mode standard files.

The report lists the row counts after each step, the date window and any date
window note, the facility filter, the exclusion filters, the column selection,
counts by facility (up to 20), value counts (up to 10 values) for bcresult,
bctype, org1, neotreeoutcome, matoutcome, modedelivery, typebirth and gender
where present, and the output files.


HOW TO RUN
----------
  Rscript run_subsample_maker.R config_subsample_mystudy.R
  Rscript run_subsample_maker.R

To build a data package covering joined and standalone files, run once with a
master-mode config and once with a cleaned-mode config that share one
output_dir, then run run_subsample_user_dict.R on that folder.
