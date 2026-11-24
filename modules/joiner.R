################################################################################
# Neotree Sample Maker -- Module 01: Join Admissions & Discharges
# FILE:    modules/joiner.R
# PURPOSE: Match admissions to discharges on a match key, producing three
#          output datasets.
#
# MATCH KEY
#   Cleaned files made in episode mode carry baby_id and stay_no: the key is
#   baby_id + stay_no + facility.  Otherwise the key is uid + facility.  The
#   same kind of key is used on both sides.  Rows without baby_id or stay_no
#   get a key of their own and are never matched directly.  The keys are
#   added by add_match_keys() before deduplication; join_data() adds them if
#   they are missing.
#
# MATCHING LOGIC
#   1. A match_key column is added to both data frames (see MATCH KEY).
#   2. Set intersection  -> matched pairs
#   3. Admissions with no discharge found    -> unmatched_admissions
#      (baby still admitted, or discharge record missing / entered under
#       different uid/facility)
#   4. Discharges with no corresponding admission in the filtered set
#      -> unmatched_discharges
#      (admission outside the selected date window, or missing admission record)
#
# MATCHED PAIRS DATASET
#   All admission columns are retained as-is.
#   Discharge columns that share a name with an admission column (except
#   match_key) are suffixed with "_dis" to avoid ambiguity.
#
# FUNCTIONS EXPORTED
#   match_key_mode(admissions, discharges) -> "episode" or "uid"
#   add_match_keys(admissions, discharges) -> list(admissions, discharges, mode)
#   join_data(admissions, discharges)
#     -> returns list(matched_pairs, unmatched_admissions, unmatched_discharges,
#                    n_matched, n_unmatched_adm, n_unmatched_dis,
#                    n_adm_total, n_dis_total)
################################################################################

match_key_mode <- function(admissions, discharges) {
  ep_cols <- c("baby_id", "stay_no")
  n_adm <- sum(ep_cols %in% names(admissions)); n_dis <- sum(ep_cols %in% names(discharges))
  if (n_adm == 2 && n_dis == 2) return("episode")
  if (n_adm == 0 && n_dis == 0) return("uid")
  stop(paste("[joiner] baby_id and stay_no are present in only one of the two files (or only one of them in a file).",
             "Clean admissions and discharges with the same deduplication mode before joining."))
}

.make_match_key <- function(df, mode, side) {
  if (mode == "episode") {
    k    <- paste(df$baby_id, df$stay_no, df$facility, sep = "_")
    none <- which(is.na(df$baby_id) | is.na(df$stay_no))
    k[none] <- paste0("nokey_", side, "_", none)
    k
  } else {
    paste(df$uid, df$facility, sep = "_")
  }
}

add_match_keys <- function(admissions, discharges) {
  mode <- match_key_mode(admissions, discharges)
  cat(sprintf("[joiner] Creating match keys (%s)...\n",
              if (mode == "episode") "baby_id + stay_no + facility" else "uid + facility"))
  admissions$match_key <- .make_match_key(admissions, mode, "adm")
  discharges$match_key <- .make_match_key(discharges, mode, "dis")
  list(admissions = admissions, discharges = discharges, mode = mode)
}

join_data <- function(admissions, discharges) {

  if (!"match_key" %in% names(admissions) || !"match_key" %in% names(discharges)) {
    k <- add_match_keys(admissions, discharges)
    admissions <- k$admissions; discharges <- k$discharges
  }
  for (side in list(list(admissions, "admissions"), list(discharges, "discharges"))) {
    n_dup <- sum(duplicated(side[[1]]$match_key))
    if (n_dup > 0)
      stop(sprintf("[joiner] %d repeated match key(s) in %s after deduplication; the join would pair the wrong rows.",
                   n_dup, side[[2]]))
  }

  n_adm_unique <- length(unique(admissions$match_key))
  n_dis_unique <- length(unique(discharges$match_key))
  cat(sprintf("[joiner]   Unique admission keys : %d\n", n_adm_unique))
  cat(sprintf("[joiner]   Unique discharge keys : %d\n\n", n_dis_unique))

  # ---------------------------------------------------------------------------
  # Set operations
  # ---------------------------------------------------------------------------
  adm_keys          <- admissions$match_key
  dis_keys          <- discharges$match_key

  matched_keys       <- intersect(adm_keys, dis_keys)
  unmatched_adm_keys <- setdiff(adm_keys, dis_keys)
  unmatched_dis_keys <- setdiff(dis_keys, adm_keys)

  n_matched       <- length(matched_keys)
  n_unmatched_adm <- length(unmatched_adm_keys)
  n_unmatched_dis <- length(unmatched_dis_keys)

  n_adm <- nrow(admissions)
  n_dis <- nrow(discharges)

  cat(sprintf(
    "[joiner] Matching results:\n  Matched pairs        : %d  (%.1f%% of admissions | %.1f%% of discharges)\n  Unmatched admissions : %d  (%.1f%%)\n  Unmatched discharges : %d  (%.1f%%)\n\n",
    n_matched,
    100 * n_matched / n_adm,
    100 * n_matched / n_dis,
    n_unmatched_adm, 100 * n_unmatched_adm / n_adm,
    n_unmatched_dis, 100 * n_unmatched_dis / n_dis
  ))

  # ---------------------------------------------------------------------------
  # Subset rows
  # ---------------------------------------------------------------------------
  adm_matched    <- admissions[admissions$match_key %in% matched_keys, ]
  dis_matched    <- discharges[discharges$match_key %in% matched_keys, ]
  unmatched_adm  <- admissions[admissions$match_key %in% unmatched_adm_keys, ]
  unmatched_dis  <- discharges[discharges$match_key %in% unmatched_dis_keys, ]

  # ---------------------------------------------------------------------------
  # Build matched pairs dataset
  # ---------------------------------------------------------------------------
  cat("[joiner] Building matched pairs dataset...\n")

  # Align each discharge row with its admission row by match_key
  adm_matched <- adm_matched[order(adm_matched$match_key), ]
  dis_matched <- dis_matched[match(adm_matched$match_key, dis_matched$match_key), ]

  # Rename overlapping discharge columns (except match_key) -> add _dis suffix
  adm_cols <- names(adm_matched)
  dis_cols <- names(dis_matched)
  overlap  <- setdiff(intersect(adm_cols, dis_cols), "match_key")

  if (length(overlap) > 0) {
    cat(sprintf(
      "[joiner]   %d column(s) shared between admissions and discharges -- adding '_dis' suffix to discharge copies:\n  %s\n",
      length(overlap),
      paste(head(overlap, 10), collapse = ", ")
    ))
    names(dis_matched)[names(dis_matched) %in% overlap] <-
      paste0(names(dis_matched)[names(dis_matched) %in% overlap], "_dis")
  }

  matched_pairs <- cbind(
    adm_matched,
    dis_matched[, names(dis_matched) != "match_key", drop = FALSE]
  )

  cat(sprintf(
    "[joiner]   Matched pairs dataset : %d rows x %d columns\n\n",
    nrow(matched_pairs), ncol(matched_pairs)
  ))

  # ---------------------------------------------------------------------------
  # Neotree outcome summary for matched pairs
  # ---------------------------------------------------------------------------
  outcome_col <- .find_outcome_col(matched_pairs)
  outcome_summary <- .build_outcome_summary(matched_pairs, outcome_col)

  list(
    matched_pairs      = matched_pairs,
    unmatched_adm      = unmatched_adm,
    unmatched_dis      = unmatched_dis,
    n_matched          = n_matched,
    n_unmatched_adm    = n_unmatched_adm,
    n_unmatched_dis    = n_unmatched_dis,
    n_adm_total        = n_adm,
    n_dis_total        = n_dis,
    outcome_col        = outcome_col,
    outcome_summary    = outcome_summary
  )
}

# ------------------------------------------------------------------------------
# Internal helpers
# ------------------------------------------------------------------------------
# The outcome is recorded on the discharge form. When admissions also have a
# neotreeoutcome column, the discharge copy is neotreeoutcome_dis.
.find_outcome_col <- function(df) {
  if ("neotreeoutcome_dis" %in% names(df)) return("neotreeoutcome_dis")
  if ("neotreeoutcome" %in% names(df))     return("neotreeoutcome")
  return(NULL)
}

.build_outcome_summary <- function(matched_pairs, outcome_col) {
  if (is.null(outcome_col)) {
    return(list(
      lines       = "  [neotreeoutcome column not found in matched pairs dataset]",
      col_used    = NULL
    ))
  }

  outcomes      <- matched_pairs[[outcome_col]]
  outcome_table <- sort(table(outcomes, useNA = "ifany"), decreasing = TRUE)
  total         <- nrow(matched_pairs)

  header <- c(
    sprintf("  Outcome column used : %s", outcome_col),
    sprintf("  Total matched pairs : %d", total),
    "",
    sprintf("  %-35s  %6s  %6s", "Outcome", "N", "%"),
    sprintf("  %-35s  %6s  %6s", strrep("-", 35), strrep("-", 6), strrep("-", 6))
  )

  rows <- vapply(seq_along(outcome_table), function(i) {
    label <- names(outcome_table)[i]
    if (is.na(label)) label <- "(missing / NA)"
    sprintf("  %-35s  %6d  %5.1f%%", label, outcome_table[i],
            100 * outcome_table[i] / total)
  }, character(1))

  # Facility breakdown
  fac_table <- sort(table(matched_pairs$facility), decreasing = TRUE)
  fac_header <- c("", "  Matched pairs by facility:")
  fac_rows <- vapply(seq_along(fac_table), function(i) {
    sprintf("    %-20s  %6d  %5.1f%%",
            names(fac_table)[i], fac_table[i],
            100 * fac_table[i] / total)
  }, character(1))

  list(
    lines    = c(header, rows, fac_header, fac_rows),
    col_used = outcome_col
  )
}
