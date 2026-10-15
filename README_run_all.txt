================================================================================
  Neotree Sample Maker -- run_all.R
================================================================================

PURPOSE
-------
Builds the master datasets for every admissions and discharges pair found in
the input folder, in one run.


WHEN IT RUNS
------------
After the cleaned datasets have been placed in input/ (see input/README.md).
It replaces separate runs of run_sample_maker.R for each country and source.


WHAT IT DOES
------------
1. Reads config_sample_maker.R from the script folder.

2. Lists the subfolders of the input folder and reads each name as
   {country}_{source}_{dataset}_{date}:

     country   zim | mwi
     source    db | mb
     dataset   any text
     date      YYYYMMDD, YYYYMMDDHHMM or YYYY-MM-DD

   Matching ignores case. Folders whose names do not fit are listed as
   skipped.

3. Groups the folders by country and source. A group that has both an
   admissions folder and a discharges folder gives one join run. Folders of
   any other dataset type are listed as skipped; run_subsample_maker.R in
   cleaned mode reads those.

4. Prints the run plan. If there is no join run, the script stops here.

5. Profiles every CSV file under the input folder, at any depth, except files
   inside a profiles/ folder and files ending in _variable_profile.csv. The
   two profile files for each CSV are written to a profiles/ folder beside
   it. A file that cannot be profiled gives a warning and the run continues.

6. For each join run, carries out the steps of run_sample_maker.R (see
   README_files/README_run_sample_maker.txt) with country and source set from
   the folder names. When output_na_coded is TRUE it also loads the
   _cleaned_na_coded.csv files and writes the na_coded master files; if
   either na_coded file is missing, the na_coded master files are not written.

7. An error in one join run is reported and the next run starts. A summary of
   succeeded and failed runs is printed at the end.


INPUTS
------
  config_sample_maker.R        Date window, matching and output settings.
                               country and source are replaced for each run.
  Input folder                 cleaning_pipeline_output_dir from the config.
                               A relative path is resolved against the script
                               folder.


OUTPUTS
-------
  outputs/{country}_master/{source}/      Files of one join run, as listed in
                                          README_files/README_run_sample_maker.txt.
                                          source is from_database or
                                          from_metabase.
  outputs/{country}_master/{source}/profiles/
                                          Profiles of the two cleaned inputs
                                          and the two master datasets.
  {input folder}/{dataset}/profiles/      Profiles of the cleaned input files.

Outputs always go to the outputs/ folder beside the script; output_dir in the
config is not used by run_all.R.


SETTINGS
--------
Two objects near the top of run_all.R:

  RUN_ALL_FILTER   NULL, or a regular expression. Only input folders whose
                   name matches it are considered. Matching ignores case.
                   Example: "^zim_" keeps folders that start with zim_.

  RUN_ALL_SKIP     Character vector of exact folder names to leave out.

All other settings come from config_sample_maker.R (see
README_files/README_config_sample_maker.txt) and apply to every join run.


HOW TO RUN
----------
  Rscript run_all.R

or open the file in RStudio and click Source. The script takes no arguments.
