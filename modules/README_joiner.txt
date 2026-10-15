================================================================================
  Module: joiner.R
================================================================================

PURPOSE
-------
Matches admissions to discharges on uid and facility.


WHEN IT RUNS
------------
Step 7 of run_sample_maker.R and of each join run in run_all.R, after the date
filter and the duplicate check.


WHAT IT DOES
------------
1. Adds match_key to both data frames: uid, an underscore, facility.
2. Splits the keys into three sets: keys in both data frames (matched), keys
   only in admissions, keys only in discharges.
3. Builds the matched pairs: the matched admissions and the matched
   discharges are each sorted by match_key and placed side by side. A
   discharge column whose name also exists in admissions gets the suffix _dis.
   match_key appears once. The side-by-side placement relies on each key
   occurring once in each data frame.
4. Counts the values of the outcome column among the matched pairs, and the
   matched pairs by facility, for the statistics report. The outcome column is
   neotreeoutcome, or neotreeoutcome_dis if the first is absent.


INPUTS
------
  admissions   Data frame with uid and facility (filtered admissions).
  discharges   Data frame with uid and facility (all discharges).


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
