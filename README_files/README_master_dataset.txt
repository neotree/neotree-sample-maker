================================================================================
  Neotree Sample Maker -- Contents of the master dataset files
================================================================================

PURPOSE
-------
Describes what each data file written by the join (run_all.R,
run_sample_maker.R) contains, and the matching files written by
run_subsample_maker.R in master mode. File naming is described in
README_PIPELINE.txt.


ROWS
----
One row is one admission, except in unmatched_discharges, where one row is one
discharge.

  File                                    Rows
  --------------------------------------  ------------------------------------
  master_joined                           Every admission in the date window.
                                          Discharge columns are filled for
                                          direct matches and empty otherwise.
  master_joined_extended                  The same admissions. Discharge
                                          columns are filled for direct and
                                          probabilistic matches.
  joined_admissions_discharges            Direct matches only.
  joined_admissions_discharges_extended   Direct and probabilistic matches.
  unmatched_admissions                    Admissions with no discharge of the
                                          same match key.
  unmatched_discharges                    Discharges with no admission of the
                                          same match key among the
                                          admissions in the date window.

master_joined and master_joined_extended have the same number of rows. In
master_joined_extended the rows are ordered: direct matches, probabilistic
matches, unmatched admissions.

A direct match is an admission and a discharge with the same match key:
baby_id, stay_no and facility for files cleaned in episode mode, otherwise uid
and facility. When a stay has several discharge forms, the primary form
(stay_form_primary) is the one joined. A probabilistic match is a pair
accepted by the similarity rule in modules/README_prob_matcher.txt; its
admission and discharge have different uid or facility values.


COLUMNS
-------
  Columns                   Content
  ------------------------  --------------------------------------------------
  Admission columns         All columns of the cleaned admissions file, with
                            their names unchanged.
  Discharge columns         All columns of the cleaned discharges file. A
                            discharge column whose name also exists in the
                            admissions file has the suffix _dis, for example
                            uid_dis, facility_dis.
  match_key                 baby_id, stay_no and facility of the admission
                            joined by underscores (uid and facility for files
                            without baby_id).
  adm_date_parsed           datetimeadmission parsed as a date-time.
  match_type                direct_match, prob_match or unmatched.
                            master_joined contains only direct_match and
                            unmatched.
  prob_match_similarity     Similarity score, 0 to 100, of a prob_match row;
                            empty for all other rows.

joined_admissions_discharges has no match_type or prob_match_similarity
column. unmatched_admissions has the admission columns, match_key and
adm_date_parsed. unmatched_discharges has the discharge columns under their
original names and match_key.

Missing values are written as empty cells.


NA-CODED FILES
--------------
{prefix}_master_joined_{label}_na_coded.csv and
{prefix}_master_joined_extended_{label}_na_coded.csv have the same rows and
columns as the standard files. The values of the admission and discharge
columns are taken from the cleaning pipeline's _cleaned_na_coded.csv files, in
which missing values carry numeric codes. match_type, prob_match_similarity,
match_key and adm_date_parsed are the same as in the standard files. Discharge
columns of unmatched rows are empty.


SUPPORTING FILES
----------------
  prob_match_candidates    One row per candidate pair at or above the
                           similarity threshold: row positions, uid and
                           facility of both records, overall_similarity,
                           same_facility, and for each matching variable its
                           score (sim_), admission value (adm_) and discharge
                           value (dis_).
  prob_match_assignments   The accepted pairs, same columns.
  duplicates_log           One row per record that shares a key with another
                           record (see modules/README_deduplicator.txt).
  matching_statistics      Text report of the direct join.
  prob_matching_report     Text report of the probabilistic matching.
  pipeline_log             The two reports in one file.
  profiles/                Per-variable profiles (README_run_data_profiler.txt).


SUBSAMPLE FILES (MASTER MODE)
-----------------------------
  File                                     Taken from
  ---------------------------------------  -----------------------------------
  subsample_master                         master_joined
  subsample_master_extended                master_joined_extended
  subsample_master_matched_only            subsample_master, direct_match rows
  subsample_master_extended_matched_only   subsample_master_extended,
                                           direct_match and prob_match rows

Each holds the rows that pass the subsample filters and the selected columns
(see README_run_subsample_maker.txt).
