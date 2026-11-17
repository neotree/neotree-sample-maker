================================================================================
  Module: master_builder.R
================================================================================

PURPOSE
-------
Assembles master_joined and master_joined_extended from the results of the
join and of the probabilistic matching.


WHEN IT RUNS
------------
Steps 8 and 11 of run_sample_maker.R and of each join run in run_all.R.


WHAT IT DOES
------------
build_master_joined() stacks two sets of rows:

  Matched pairs          match_type = "direct_match".
  Unmatched admissions   match_type = "unmatched"; every column they lack
                         (the discharge columns) is added as NA.

prob_match_similarity is NA in every row. The columns are in the order of the
matched pairs, followed by match_type and prob_match_similarity.

build_master_joined_extended() starts from master_joined. With no accepted
pair it returns master_joined as it is. Otherwise, for each accepted pair:

1. It takes the unmatched row of master_joined with the match_key of the
   pair's admission. If there is not exactly one such row, it rebuilds the
   row from the unmatched admissions data frame.
2. It fills the discharge columns from the pair's discharge record. Discharge
   columns are the columns of master_joined that are not admission columns,
   match_key, match_type or prob_match_similarity; a name ending in _dis is
   filled from the discharge column without the suffix.
3. It sets match_type = "prob_match" and prob_match_similarity to the pair's
   overall similarity.

The result is the direct_match rows, then the prob_match rows, then the
unmatched rows that were not paired.


INPUTS
------
  matched_pairs      From join_data().
  unmatched_adm      From join_data().
  master_joined      From build_master_joined().
  assignments        From assign_one_to_one().
  unmatched_adm_df   From join_data().
  unmatched_dis_df   From join_data().


OUTPUTS
-------
Each function returns one data frame. The files written from them are
described in README_files/README_master_dataset.txt.


FUNCTIONS
---------
build_master_joined(matched_pairs, unmatched_adm)
build_master_joined_extended(master_joined, assignments, unmatched_adm_df,
                             unmatched_dis_df)
