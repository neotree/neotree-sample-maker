================================================================================
  Module: file_finder.R
================================================================================

PURPOSE
-------
Finds the cleaned admissions file and the cleaned discharges file for one
country and source.


WHEN IT RUNS
------------
Step 1 of run_sample_maker.R and of each join run in run_all.R.


WHAT IT DOES
------------
With cleaning_pipeline_output_dir set (the supplied configuration):

1. Uses the folder as given; if it does not exist, looks for it under the
   script folder. Stops if it is not found.
2. Builds the name prefix {country}_{src}_{type}_, where country is in lower
   case, src is db for from_database and mb for from_metabase, and type is
   admissions or discharges.
3. Takes the direct subfolders whose names start with the prefix, and inside
   them the files that start with the prefix and end in _cleaned.csv. Matching
   ignores case.
4. If several files match, uses the most recently modified one and gives a
   warning naming the others.

It stops if source has another value, if no subfolder matches, or if no file
matches.

With cleaning_pipeline_output_dir = NULL the function reads a different
layout: {cleaned_files_dir}/{country}/{source}/{cleaning}/, where cleaning is
"Python_cleaned" or "R_cleaned". It takes the CSV files in that folder that
start with the same prefix and applies the same most-recent rule. The settings
cleaned_files_dir and cleaning are not in the supplied config file.


INPUTS
------
  cfg          Configuration list: country, source,
               cleaning_pipeline_output_dir.
  script_dir   Folder of the calling script, or NULL.


OUTPUTS
-------
A list:

  admissions_path   Path of the admissions file.
  discharges_path   Path of the discharges file.
  target_dir        Folder that was searched.


FUNCTION
--------
find_input_files(cfg, script_dir = NULL)

modules/pipeline_file_resolver.R holds a related function used by
run_subsample_maker.R in cleaned mode:

resolve_pipeline_file(output_dir, country, source, dataset_type,
                      use_na_coded = FALSE)

It applies the same search to one dataset type and returns one path.
use_na_coded = TRUE looks for the file ending in _cleaned_na_coded.csv.
