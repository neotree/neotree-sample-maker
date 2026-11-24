================================================================================
  Module: joiner.R
================================================================================

PURPOSE
-------
Matches admissions to discharges on a match key: baby_id, stay_no and
facility when both files carry baby_id and stay_no (files cleaned in episode
mode), otherwise uid and facility.


WHEN IT RUNS
------------
Step 7 of run_sample_maker.R and of each join run in run_all.R, after the date
filter and the duplicate check.


WHAT IT DOES
------------
1. Uses the match_key added by add_match_keys() before the duplicate check,
   or adds it: baby_id, stay_no and facility joined by underscores when both
   data frames have baby_id and stay_no, otherwise uid and facility. A row
   without baby_id or stay_no gets a key of its own and is not matched
   directly. The join stops if a key still occurs more than once in either
   data frame, or if baby_id and stay_no are present in only one of the two
   files.
2. Splits the keys into three sets: keys in both data frames (matched), keys
   only in admissions, keys only in discharges.
3. Builds the matched pairs: each matched admission is placed beside the
   discharge with the same match_key. A discharge column whose name also
   exists in admissions gets the suffix _dis. match_key appears once.
4. Counts the values of the outcome column among the matched pairs, and the
   matched pairs by facility, for the statistics report. The outcome is taken
   from the discharge form: neotreeoutcome_dis when admissions also have a
   neotreeoutcome column, otherwise neotreeoutcome.


INPUTS
------
  admissions   Data frame with uid and facility, and baby_id and stay_no when
               cleaned in episode mode (filtered admissions).
  discharges   Data frame with the same columns (all discharges).


OUTPUTS
-------
A list:

  matched_pairs     Data frame, one row per matched key: admission columns,
                    then discharge columns.
  unmatched_adm     Admissions whose key is not in discharges.
  unmatched_dis     Discharges whose key is not in admissions.
  n_matched         Number of matched keys.
  n_unmatched_adm   Number of keys only in admissions.
  n_unmatched_dis   Number of keys only in discharges.
  n_adm_total       Number of admission rows.
  n_dis_total       Number of discharge rows.
  outcome_col       Name of the outcome column used, or NULL.
  outcome_summary   List with the report lines (lines) and the column used
                    (col_used).


FUNCTION
--------
join_data(admissions, discharges)
