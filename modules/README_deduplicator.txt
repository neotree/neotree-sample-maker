================================================================================
  Module: deduplicator.R
================================================================================

PURPOSE
-------
Finds records that share the same match_key within one data frame and keeps
one record for each key, or stops when it cannot tell which record to keep.


WHEN IT RUNS
------------
Step 6 of run_sample_maker.R and of each join run in run_all.R. Both scripts
call prepare_join_inputs(), which adds match_key to both files with
add_match_keys() (joiner.R) and then calls resolve_duplicates() once for
admissions and once for discharges.


WHAT IT DOES
------------
The function reads the column match_key (see joiner.R). A key can occur more
than once only in discharges cleaned in episode mode (match-key mode
"episode"), where the discharge forms of one stay share a key. For each such
key:

1. If exactly one row of the group is marked stay_form_primary = TRUE, that
   row is kept for the join; the other forms are not joined and stay in the
   cleaned discharge file. Otherwise the run stops.
2. If the data frame has a datetimeadmission column and the forms of the
   group carry two or more different non-empty values in it, the group is
   flagged possible_readmission, and the number of flagged groups is printed.

Every row of every repeated group is written to the log.

The function stops if the data frame has no match_key column. It also stops
if a key occurs more than once in any other case: in admissions, when the
match-key mode is "uid" (files joined on uid + facility, even if they carry
a stay_form_primary column), or when the discharges have no
stay_form_primary column. The rows may then be different records or stays,
and keeping one could drop a record or pair a discharge with the wrong
admission. No duplicates log is written and the join is not run; the message
gives the number of repeated keys and the columns the repeated rows share
(uid and facility, or baby_id, stay_no and facility). Files cleaned with the
earlier duplicate removal or in episode mode have no such keys; if a run
stops here, rerun the cleaning pipeline in episode mode or remove the
repeated rows.


INPUTS
------
  df      Data frame of admissions or discharges.
  label   Text naming the data frame in messages and in the log, for example
          "ADMISSIONS".
  mode           Match-key mode returned by add_match_keys(): "episode" or
                 "uid".
  resolve_forms  TRUE to let stay_form_primary choose between the forms of
                 one stay. prepare_join_inputs() sets it for episode-mode
                 discharges only; the default is FALSE.


OUTPUTS
-------
A list:

  df           Data frame with the removed rows left out.
  log          Data frame, one row per record in a duplicate group; empty when
               there are none. Columns: source, match_key, row_index_in_file
               (position in df), na_count, action (KEPT or NOT JOINED
               (other form of the same stay)), possible_readmission.
  n_dup_keys   Number of keys that occurred more than once.
  n_removed    Number of rows removed.

output_writer.R writes the two logs together as {prefix}_duplicates_log.csv
when they contain any row.


FUNCTIONS
---------
prepare_join_inputs(admissions, discharges)
  Returns list(admissions, discharges, adm_dedup, dis_dedup, mode), where
  adm_dedup and dis_dedup are the results of resolve_duplicates() and mode is
  "episode" or "uid" (see joiner.R).
resolve_duplicates(df, label, mode, resolve_forms = FALSE)
