================================================================================
  Neotree Sample Maker -- run_sample_maker.R
================================================================================

PURPOSE
-------
Joins the cleaned admissions file and the cleaned discharges file of one
country and source, and writes the master datasets and matching reports.


WHEN IT RUNS
------------
After the cleaned datasets are in the input folder. run_all.R carries out the
same steps for every country and source it finds.


WHAT IT DOES
------------
  Step  Action                                           Module
  ----  -----------------------------------------------  ------------------
   1    Find the admissions and discharges files         file_finder.R
   2    Load both files and check required columns       loader.R
   3    Parse datetimeadmission                          filter_data.R
   4    Resolve the admission date window                filter_data.R
   5    Keep admissions inside the window                filter_data.R
   6    Add the match key and resolve repeated keys      deduplicator.R
   7    Join on the match key                            joiner.R
   8    Build master_joined                              master_builder.R
   9    Choose the variables for probabilistic matching  prob_matcher.R
  10    Score unmatched admissions against unmatched
        discharges and accept one-to-one pairs           prob_matcher.R
  11    Build master_joined_extended                     master_builder.R
  12    Write CSV files and reports                      output_writer.R
  13    Profile the two cleaned inputs and the two
        master datasets                                  data_profiler.R

Each module has a README in modules/. Discharges are not filtered by date:
every discharge record is available for matching.

Step 9 measures completeness on the files as loaded, before the date filter.


INPUTS
------
  Config file     First command-line argument if given; otherwise
                  config_sample_maker.R beside the script; otherwise config.R
                  beside the script. See README_config_sample_maker.txt.
  Cleaned files   {country}_{src}_admissions_{date}_cleaned.csv and
                  {country}_{src}_discharges_{date}_cleaned.csv, each in a
                  folder of the same name under cleaning_pipeline_output_dir.

Required columns: uid, facility and datetimeadmission in admissions; uid and
facility in discharges.


OUTPUTS
-------
Written to {output_dir}/{country}_master/{source}/. {prefix} is the country in
upper case and the source code, for example ZIM_db. {label} describes the date
window, for example to_20260131 (see README_PIPELINE.txt).

  {prefix}_master_joined_{label}.csv
  {prefix}_master_joined_extended_{label}.csv
  {prefix}_joined_admissions_discharges_{label}.csv
  {prefix}_joined_admissions_discharges_extended_{label}.csv
  {prefix}_unmatched_admissions_{label}.csv
  {prefix}_unmatched_discharges_{label}.csv
  {prefix}_prob_match_candidates_{label}.csv     only if candidates were found
  {prefix}_prob_match_assignments_{label}.csv    only if pairs were accepted
  {prefix}_duplicates_log.csv                    only if duplicates were found
  {prefix}_matching_statistics_{label}.txt
  {prefix}_prob_matching_report_{label}.txt
  {prefix}_pipeline_log_{label}.txt              the two reports in one file
  profiles/{prefix}_cleaned_admissions_{label}_variable_profile.csv / .txt
  profiles/{prefix}_cleaned_discharges_{label}_variable_profile.csv / .txt
  profiles/{prefix}_master_joined_{label}_variable_profile.csv / .txt
  profiles/{prefix}_master_joined_extended_{label}_variable_profile.csv / .txt

The contents of the data files are described in README_master_dataset.txt
and the reports in modules/README_output_writer.txt.

run_sample_maker.R does not load the _cleaned_na_coded.csv files, so it does
not write the na_coded master files. run_all.R does.

A relative output_dir is taken from the working directory.


HOW TO RUN
----------
  Rscript run_sample_maker.R
  Rscript run_sample_maker.R path/to/my_config.R

or open the file in RStudio and click Source. The script returns the list of
output paths invisibly.
