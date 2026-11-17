================================================================================
  Module: deduplicator.R
================================================================================

PURPOSE
-------
Finds records that share the same match_key within one data frame and keeps
one record for each key.


WHEN IT RUNS
------------
Step 6 of run_sample_maker.R and of each join run in run_all.R, once for
admissions and once for discharges.


WHAT IT DOES
------------
The function reads the column match_key (see joiner.R). For each key that
occurs more than once:

1. It counts the NA values in each row of the group.
2. If the data frame has a stay_form_primary column and exactly one row of the
   group is marked TRUE (several discharge forms of one stay, cleaned in
   episode mode), it keeps that row; the other forms are not joined and stay
   in the cleaned discharge file. If the column exists but the group does not
   have exactly one row marked TRUE, the run stops. Without the column it
   keeps the row with the fewest NA values; on a tie, the first. The other
   rows are left out of the join.
3. If the data frame has a datetimeadmission column and more than one row of
   the group has a non-empty value in it, the group is flagged
   possible_readmission and a message is printed. Flagged groups are resolved
   in the same way.

Every row of every duplicate group is written to the log.

A data frame that has no match_key column is returned unchanged, with zero
duplicates reported. The run scripts add match_key with add_match_keys()
before calling this function.


INPUTS
------
  df      Data frame of admissions or discharges.
  label   Text naming the data frame in messages and in the log, for example
          "ADMISSIONS".


OUTPUTS
-------
A list:

  df           Data frame with the removed rows left out.
  log          Data frame, one row per record in a duplicate group; empty when
               there are none. Columns: source, match_key, row_index_in_file
               (position in df), na_count, action (KEPT, REMOVED, or NOT
               JOINED (other form of the same stay)),
               possible_readmission.
  n_dup_keys   Number of keys that occurred more than once.
  n_removed    Number of rows removed.

output_writer.R writes the two logs together as {prefix}_duplicates_log.csv
when they contain any row.


FUNCTION
--------
resolve_duplicates(df, label)
