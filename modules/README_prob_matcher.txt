================================================================================
  Module: prob_matcher.R
================================================================================

PURPOSE
-------
Pairs admissions that have no direct match with discharges that have no direct
match, by comparing clinical variables recorded on both forms.


WHEN IT RUNS
------------
Steps 9 and 10 of run_sample_maker.R and of each join run in run_all.R, after
the direct join.


WHAT IT DOES
------------

Variable selection: detect_match_variables()

The candidate variables are birthweight, gestation, temperature, apgar1,
apgar5, apgar10, gender, ofc, modedelivery and typebirth. A variable is used
when:

  - a column of that name exists in both files, and
  - the share of filled values (not NA, not empty) is at least
    prob_match_completeness_threshold in each file. The share is measured on
    the files as loaded.

A variable is numeric when more than half of its admission values convert to a
number; otherwise it is categorical. A numeric variable takes its tolerance
from the setting prob_match_{variable}_tolerance, or from the default below
when the setting is absent. Categorical variables are compared for equality.

  Variable       Default tolerance
  -------------  -----------------
  birthweight    50
  gestation      1
  ofc            1
  temperature    0.5
  apgar1         0
  apgar5         0
  apgar10        0

If no variable qualifies, a warning is given and no matching is done.

Scoring: find_prob_candidates()

Each unmatched admission is compared with the unmatched discharges of the same
facility. If there is no unmatched discharge in that facility and
prob_match_cross_facility is TRUE, it is compared with all unmatched
discharges.

Score of one variable for one pair, with d the absolute difference and t the
tolerance:

  Case                                      Score
  ----------------------------------------  --------------------------------
  Numeric, d = 0                            100
  Numeric, t = 0, d > 0                     0
  Numeric, 0 < d <= t                       100 * (1 - d / t)
  Numeric, t < d <= 2t                      50 * (1 - (d - t) / t)
  Numeric, d > 2t                           0
  Categorical, equal text                   100
  Categorical, different text               0

The overall similarity of a pair is the mean of the variable scores, over the
variables that are filled in both records. A pair with no such variable scores
0.

For each admission, the pairs with overall similarity of at least
prob_match_min_similarity are kept, up to prob_match_max_candidates, highest
first.

Assignment: assign_one_to_one()

The candidates are sorted by overall similarity, highest first, and taken in
that order. A pair is accepted if neither its admission nor its discharge is
already in an accepted pair. Each admission and each discharge is therefore in
at most one accepted pair.


INPUTS
------
  adm_full, dis_full   Admissions and discharges as loaded.
  unmatched_adm        From join_data().
  unmatched_dis        From join_data().
  var_info             From detect_match_variables().
  cfg                  Configuration list with the prob_match_ settings.
  candidates           From find_prob_candidates().


OUTPUTS
-------
  detect_match_variables()   List: vars (name -> TRUE if numeric),
                             tolerances, col_map_adm, col_map_dis.
  find_prob_candidates()     Data frame, one row per candidate pair:
                             adm_row_idx, dis_row_idx (row positions in the
                             unmatched data frames), overall_similarity,
                             adm_uid, adm_facility, dis_uid, dis_facility,
                             same_facility, and for each variable sim_{var},
                             adm_{var}, dis_{var}. Empty when nothing is
                             found.
  assign_one_to_one()        Data frame of the accepted pairs, same columns.


FUNCTIONS
---------
detect_match_variables(adm_full, dis_full, cfg)
find_prob_candidates(unmatched_adm, unmatched_dis, var_info, cfg)
assign_one_to_one(candidates)


CONFIGURATION
-------------
  prob_match_completeness_threshold   Lowest share of filled values for a
                                      variable to be used.
  prob_match_min_similarity           Lowest overall similarity kept.
  prob_match_max_candidates           Highest number of candidates kept per
                                      admission.
  prob_match_cross_facility           Allows comparison across facilities as
                                      described above.
  prob_match_{variable}_tolerance     Tolerance of a numeric variable.
