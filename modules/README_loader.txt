================================================================================
  Module: loader.R
================================================================================

PURPOSE
-------
Reads the cleaned admissions and discharges files and checks that the columns
needed for the join are present.


WHEN IT RUNS
------------
Step 2 of run_sample_maker.R and of each join run in run_all.R. run_all.R also
calls load_na_coded_data() when output_na_coded is TRUE.


WHAT IT DOES
------------
load_data() reads each file with read.csv, keeping text as text and column
names unchanged. It stops if a file does not exist, cannot be read, has no
rows, or lacks a required column:

  admissions   uid, facility, datetimeadmission
  discharges   uid, facility

load_na_coded_data() takes the two paths, replaces _cleaned.csv with
_cleaned_na_coded.csv, and reads those files. A file that is missing or cannot
be read gives a message and a NULL result; the run continues.


INPUTS
------
  admissions_path   Path of the cleaned admissions file.
  discharges_path   Path of the cleaned discharges file.


OUTPUTS
-------
load_data() returns a list:

  admissions   Data frame.
  discharges   Data frame.
  n_adm_raw    Number of admission rows read.
  n_dis_raw    Number of discharge rows read.

load_na_coded_data() returns a list with adm_na_coded and dis_na_coded, each a
data frame or NULL.


FUNCTIONS
---------
load_data(admissions_path, discharges_path)
load_na_coded_data(admissions_path, discharges_path)
