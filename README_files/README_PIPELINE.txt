================================================================================
  Neotree Sample Maker -- Overview of the scripts
================================================================================

PURPOSE
-------
Describes how the scripts fit together, where files are read and written, how
output files are named, and the data package workbook. Each script and config
file has its own README in this folder; each module has one in modules/.


WORKFLOW
--------
  1. Place the cleaned datasets in input/                  input/README.md
  2. Build the master datasets
       all pairs in input/         run_all.R               ../README_run_all.txt
       one country and source      run_sample_maker.R      README_run_sample_maker.txt
  3. Cut a subsample               run_subsample_maker.R   README_run_subsample_maker.txt
  4. Optional:
       data package workbook       run_subsample_user_dict.R   this file
       remove identifiers          run_anonymizer.R        README_run_anonymizer.txt
       profile any CSV             run_data_profiler.R     README_run_data_profiler.txt

Step 3 in cleaned mode reads the cleaned datasets directly and does not need
step 2.


SCRIPTS AND THEIR SETTINGS
--------------------------
  Script                      Settings
  --------------------------  ------------------------------------------------
  run_all.R                   config_sample_maker.R; RUN_ALL_FILTER and
                              RUN_ALL_SKIP in the script
  run_sample_maker.R          config_sample_maker.R, or a file given as the
                              first argument
  run_subsample_maker.R       SUBSAMPLE_CONFIG block in the script, or a file
                              given as the first argument;
                              INCLUDE_METABASE in the script
  run_subsample_user_dict.R   DICT_CONFIG block in the script, or a file
                              given as the first argument
  run_anonymizer.R            ANONYMIZER_CONFIG block in the script
  run_data_profiler.R         PROFILER_CONFIG block in the script; the input
                              file may be given as the first argument


FOLDERS
-------
  input/{country}_{src}_{dataset}_{date}/     cleaned datasets
  input/{...}/profiles/                       profiles written by run_all.R
  outputs/{country}_master/{source}/          master datasets and reports
  outputs/{country}_master/{source}/profiles/ profiles of inputs and masters
  subsamples/                                 subsample files (default)
  subsamples/profiles/                        subsample profiles
  user_dictionaries/                          neotree_user_dict_zim.xlsx and
                                              neotree_user_dict_mwi.xlsx
  modules/                                    functions sourced by the scripts

{src} is db or mb in input names; {source} is from_database or from_metabase
in output folders.


FILE NAMES
----------
Output names have the form {prefix}_{content}_{label}.

  {prefix}   Country in upper case, underscore, source code: ZIM_db, MWI_mb.

  {label}    Built from the filter settings:

               Start and end date        20250101_to_20260131
               End date only             to_20260131
               Start date only           from_20250101
               No date                   ALL
               Facility filter           facility names appended, joined by _.
                                         With no date, the join and master
                                         mode give the facility names alone;
                                         cleaned mode gives ALL and the names.
               Per-facility ranges       earliest start, latest end, then the
                                         facility names. Cleaned mode uses
                                         the global dates and no names.
               Exclusion filters set     _excl appended     (subsamples only)
               Column list set           _{n}vars appended  (subsamples only)

             Example: 20250101_to_20260131_FACILITY_A_excl_12vars


DATA PACKAGE WORKBOOK  (run_subsample_user_dict.R)
--------------------------------------------------
Purpose
  Writes one Excel workbook that lists, for each subsample file, the
  dictionary entry of every variable beside counts and summary statistics
  computed from the file. Needs the openxlsx package.

What it does
  1. Finds the subsample files, from subsample_files or by scanning
     subsample_dir.
  2. Loads each file and profiles every column with the rules of the data
     profiler (README_run_data_profiler.txt).
  3. Reads the matching sheet of neotree_user_dict_{country}.xlsx: Admissions,
     Discharges, Neolab, Master, and for maternal files Maternal Outcomes
     (zim) or combined_maternity_outcomes (mwi). If the workbook or the sheet
     is missing, the dataset sheet is built from the profile alone.
  4. Matches dictionary variables to data columns by name, ignoring case, and
     failing that ignoring underscores as well.
  5. Writes the workbook.

Workbook sheets
  About        Study name, country, time of the run, and for each dataset
               sheet the source file name with its row and column counts.
  Admissions, Discharges, Master, Neolab, Maternal
               One sheet per dataset type found. Columns: Description,
               Variable Name, Type, Values / Codes, n present, Missing %,
               Statistics, NA Codes. Rows follow the dictionary order, with
               the dictionary's section headings. Dictionary variables absent
               from the file have empty count and statistics cells. Columns
               of the file that are not in the dictionary follow under
               "Pipeline / System Variables" or "Additional Variables (not in
               current dictionary version)". Missing % above 10 is shown in
               red.
  NA Codes     Legend of the numeric codes -6 to -9 used in na_coded files
               and of the text codes used on the forms.

  Statistics shows range, mean and median for numeric variables, TRUE and
  FALSE counts for boolean variables, and the three most frequent values with
  their counts for categorical variables.

Settings (DICT_CONFIG)
  study_name            Text shown on the About sheet.
  country               "zim" or "mwi". NULL takes it from the first file
                        name: ZIM_ or MWI_ at the start.
  subsample_dir         Folder to scan for files whose names contain
                        _subsample_ and end in .csv. The dataset type is read
                        from the name: admissions, discharges, neolab,
                        maternal or master. Of the master-mode files only
                        {prefix}_subsample_master_{label}.csv is used. When
                        several files have the same type the first is kept.
  subsample_files       Named list, type = path. When it is not empty it is
                        used and subsample_dir is not scanned.
  user_dict_dir         Folder with the dictionary workbooks. Default
                        "user_dictionaries". The run stops if the folder does
                        not exist.
  output_dir            Folder for the workbook. NULL uses subsample_dir, or
                        the folder of the first file.
  numeric_threshold     As in the data profiler.
  max_numeric_distinct  As in the data profiler.

  Relative paths are resolved against the script folder.

Output
  {prefix}_data_package_{label}.xlsx, with {prefix} and {label} taken from the
  name of the first subsample file. An existing file of that name is
  overwritten.

How to run
  Rscript run_subsample_user_dict.R
  Rscript run_subsample_user_dict.R my_dict_config.R

  The config file must define DICT_CONFIG. In RStudio, a DICT_CONFIG object
  already in the session is used instead of the block in the script.


REQUIREMENTS
------------
Base R for every script except run_subsample_user_dict.R, which needs
openxlsx. rstudioapi is used, if installed, to find the script folder when a
script is sourced in RStudio. install_packages.r installs both from CRAN;
install_packages_mirror.r installs them from an internal package mirror.
