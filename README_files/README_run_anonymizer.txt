================================================================================
  Neotree Sample Maker -- run_anonymizer.R
================================================================================

PURPOSE
-------
Removes identifier columns from one or more CSV files and writes a copy of
each file with the suffix _anon.


WHEN IT RUNS
------------
On demand, on any CSV written by the other scripts.


WHAT IT DOES
------------
For each input file the script loads the CSV, calls anonymize_dataset() from
modules/anonymizer.R, and writes the result. The rules are in
modules/README_anonymizer.txt. In short:

  - uid, uniquekey, match_key and adm_date_parsed are removed;
  - the columns named in additional_remove are removed;
  - with convert_datetimes = TRUE, datetimeadmission and datetimedischarge
    are replaced by adm_yearmonth and dis_yearmonth (YYYY-MM);
  - with add_anon_id = TRUE, a column anon_id numbering the rows from 1 is
    added as the first column.

Columns are matched by exact name. Copies that carry the _dis suffix in the
master datasets, such as uid_dis, are removed only if they are listed in
additional_remove.


SETTINGS
--------
ANONYMIZER_CONFIG, inside run_anonymizer.R:

  input_files         Character vector of CSV paths. A path that does not
                      exist as given is looked for under the script folder.
                      The run stops if a file is not found or the vector is
                      empty.
  output_dir          NULL writes each output beside its input. A folder path
                      writes all outputs there; the folder is created if
                      needed.
  add_anon_id         TRUE or FALSE.
  convert_datetimes   TRUE or FALSE.
  additional_remove   Character vector of further column names to remove.
                      Names not present in a file give a warning.


OUTPUTS
-------
  {input file name}_anon.csv    One per input file.
  anonymization_report.txt      One per run, in output_dir, or beside the
                                first input file when output_dir is NULL. It
                                lists the settings, the columns removed and
                                converted, and for each file the row count and
                                the column counts before and after.

Missing values (NA in R) are written as the text NA.


HOW TO RUN
----------
Edit ANONYMIZER_CONFIG, then:

  Rscript run_anonymizer.R

or open the file in RStudio and click Source.
