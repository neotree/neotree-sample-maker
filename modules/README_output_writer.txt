================================================================================
  Module: output_writer.R
================================================================================

PURPOSE
-------
Writes the data files and text reports of one join run.


WHEN IT RUNS
------------
Step 12 of run_sample_maker.R and of each join run in run_all.R.


WHAT IT DOES
------------
1. Creates the folder {output_dir}/{country}_master/{source}/, with country in
   lower case.
2. Builds the file prefix (country in upper case, underscore, db or mb) and
   takes the label from the date filter.
3. Writes the six data files. joined_admissions_discharges_extended is the
   rows of master_joined_extended whose match_type is not "unmatched".
   Missing values are written as empty cells.
4. If both na_coded data frames are supplied, builds and writes the na_coded
   master files. Rows are looked up by uid and facility in the na_coded
   sources, and the values of the admission and discharge columns are
   replaced by the values found there. match_type, prob_match_similarity,
   match_key and adm_date_parsed are left as they are. Discharge columns of
   unmatched rows are set to NA. For prob_match rows the discharge record is
   looked up by the discharge uid and facility of the accepted pair. If this
   step fails, a warning is printed and the run continues without these files.
5. Writes the candidates file and the assignments file when they have rows,
   and the duplicates log when either log has rows.
6. Writes the two reports and the pipeline log, which holds both reports.


INPUTS
------
  cfg   Configuration list: country, source, output_dir.
  ps    List holding the results of the earlier steps: admissions_path,
        discharges_path, n_adm_raw, n_dis_raw, date_window, filter_result,
        varfilt_result, adm_dedup, dis_dedup, join_result, var_info,
        prob_candidates, prob_assignments, master_joined,
        master_joined_extended, and optionally adm_na_coded and dis_na_coded.


OUTPUTS
-------
  {prefix}_joined_admissions_discharges_{label}.csv
  {prefix}_joined_admissions_discharges_extended_{label}.csv
  {prefix}_unmatched_admissions_{label}.csv
  {prefix}_unmatched_discharges_{label}.csv
  {prefix}_master_joined_{label}.csv
  {prefix}_master_joined_extended_{label}.csv
  {prefix}_master_joined_{label}_na_coded.csv              step 4
  {prefix}_master_joined_extended_{label}_na_coded.csv     step 4
  {prefix}_prob_match_candidates_{label}.csv               step 5
  {prefix}_prob_match_assignments_{label}.csv              step 5
  {prefix}_duplicates_log.csv                              step 5
  {prefix}_matching_statistics_{label}.txt
  {prefix}_prob_matching_report_{label}.txt
  {prefix}_pipeline_log_{label}.txt

The data files are described in README_files/README_master_dataset.txt.

Matching statistics report:

  Run metadata             Time, country, source, label.
  Input files              File names and rows read.
  Admission filter         Window, rows before and after.
  Deduplication            Duplicate keys and rows removed, per file.
  Direct matching summary  Matched pairs, unmatched admissions, unmatched
                           discharges, as counts and percentages.
  Neotree outcomes         Counts of the outcome column among direct matches,
                           and direct matches by facility.
  Unmatched breakdown      Unmatched admissions and discharges by facility.
  Master dataset summary   Rows by match_type in both master datasets.
  Output files             Names of the files written.

Probabilistic matching report:

  Run metadata             Time, country, source, label.
  Configuration            The four general prob_match_ settings.
  Variable selection       Variables used, their type, tolerance and columns.
  Candidate search         Candidate pairs, admissions with a candidate,
                           within-facility and cross-facility counts, and the
                           distribution of similarity.
  One-to-one assignments   Pairs accepted and summary of their similarity.
  Per-variable scores      Mean and median score of each variable among the
                           accepted pairs.
  Master_joined_extended   Rows by match_type and counts of the outcome
                           column.
  Top assignments          Up to 20 accepted pairs with their similarity and
                           the uid of the admission and of the discharge.
  Output files             Names of the files written.


FUNCTION
--------
write_outputs(cfg, ps) returns a named list of the output paths.
