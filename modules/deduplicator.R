################################################################################
# Neotree Sample Maker -- Module 01: Join Admissions & Discharges
# FILE:    modules/deduplicator.R
# PURPOSE: Detect and resolve repeated match keys (see joiner.R) in admissions
#          and discharges data frames, so that each key appears once in the
#          join.
#
# STRATEGY
#   A key may appear more than once only in discharges cleaned in episode mode
#   that carry stay_form_primary: the discharge forms of one stay share a key.  The
#   row marked stay_form_primary = TRUE is kept for the join; the other forms
#   are not joined and stay in the cleaned discharge file.  All groups are
#   logged to a DUPLICATES_LOG CSV.
#
#   Any other repeated key stops the run, before a duplicates log is written:
#   any repeated admission key, a file joined on uid + facility (even one that
#   carries stay_form_primary), or episode-mode discharges without
#   stay_form_primary.  Without a stay
#   identifier the rows may belong to different stays, and keeping one could
#   drop a record or pair a discharge with the wrong admission.  Files cleaned
#   with the earlier duplicate removal have no repeated uid + facility keys.
#
#   A group whose forms carry two or more different admission datetimes is
#   flagged possible_readmission in the log.
#
# FUNCTIONS EXPORTED
#   prepare_join_inputs(admissions, discharges)
#     -> adds the match keys (add_match_keys() in joiner.R), then removes
#        repeated keys from both files; returns list(admissions, discharges,
#        adm_dedup, dis_dedup, mode).  Both run scripts call this.
#   resolve_duplicates(df, label, mode, resolve_forms = FALSE)
#     -> returns list(df, log, n_dup_keys, n_removed)
#   df must already carry match_key; the function stops if the column is
#   missing.  mode is the match-key mode from add_match_keys().  Repeated keys
#   are resolved by stay_form_primary only when resolve_forms is TRUE and mode
#   is "episode"; prepare_join_inputs() sets resolve_forms for discharges only.
################################################################################

prepare_join_inputs <- function(admissions, discharges) {
  keyed     <- add_match_keys(admissions, discharges)
  adm_dedup <- resolve_duplicates(keyed$admissions, "ADMISSIONS", keyed$mode, resolve_forms = FALSE)
  dis_dedup <- resolve_duplicates(keyed$discharges, "DISCHARGES", keyed$mode,
                                  resolve_forms = identical(keyed$mode, "episode"))
  list(admissions = adm_dedup$df, discharges = dis_dedup$df,
       adm_dedup = adm_dedup, dis_dedup = dis_dedup, mode = keyed$mode)
}

resolve_duplicates <- function(df, label, mode, resolve_forms = FALSE) {

  if (!"match_key" %in% names(df))
    stop(sprintf("[dedup] %s has no match_key column; call add_match_keys() before resolve_duplicates().", label))

  dup_keys <- unique(df$match_key[duplicated(df$match_key)])

  if (length(dup_keys) == 0) {
    cat(sprintf("[dedup]   %s: no duplicate keys found\n", label))
    return(list(
      df          = df,
      log         = data.frame(),
      n_dup_keys  = 0L,
      n_removed   = 0L
    ))
  }

  if (!isTRUE(resolve_forms) || !identical(mode, "episode") || !"stay_form_primary" %in% names(df))
    stop(sprintf(paste("[dedup] %s: %d match key(s) occur more than once, and stay_form_primary can choose",
                       "between rows only in discharges cleaned in episode mode. The rows may be different",
                       "records or stays, so no duplicates log is written and nothing is joined. The",
                       "repeated rows share %s. Files cleaned in episode mode (DEDUP_MODE = \"episode\")",
                       "have none; rerun the cleaning pipeline in that mode or remove the repeated rows",
                       "before joining."),
                 label, length(dup_keys),
                 if (identical(mode, "episode")) "baby_id, stay_no and facility" else "uid and facility"))

  cat(sprintf(
    "[dedup]   WARNING: %d repeated match key(s) in %s -- resolving...\n",
    length(dup_keys), label
  ))

  log_rows       <- list()
  rows_to_remove <- integer(0)
  n_flagged      <- 0L

  for (key in dup_keys) {
    idx       <- which(df$match_key == key)
    na_counts <- vapply(idx, function(i) sum(is.na(df[i, ])), integer(1))
    primary   <- idx[as.character(df$stay_form_primary[idx]) %in% c("TRUE", "True", "true", "1")]
    if (length(primary) != 1)
      stop(sprintf(paste("[dedup] %s: a stay with %d discharge forms has %d forms marked stay_form_primary;",
                         "exactly one is expected. Check the cleaned discharges file."),
                   label, length(idx), length(primary)))
    keep      <- primary
    remove    <- setdiff(idx, keep)

    # Flag if the forms carry two or more different admission datetimes
    if ("datetimeadmission" %in% names(df)) {
      adm_dates           <- trimws(as.character(df$datetimeadmission[idx]))
      adm_dates           <- unique(adm_dates[!is.na(adm_dates) & nchar(adm_dates) > 0])
      genuine_readmission <- length(adm_dates) > 1
    } else {
      genuine_readmission <- FALSE
    }
    if (genuine_readmission) n_flagged <- n_flagged + 1L

    for (r in idx) {
      log_rows[[length(log_rows) + 1]] <- data.frame(
        source               = label,
        match_key            = key,
        row_index_in_file    = r,
        na_count             = na_counts[which(idx == r)],
        action               = ifelse(r == keep, "KEPT", "NOT JOINED (other form of the same stay)"),
        possible_readmission = genuine_readmission,
        stringsAsFactors     = FALSE
      )
    }

    rows_to_remove <- c(rows_to_remove, remove)
  }

  if (n_flagged > 0)
    cat(sprintf("[dedup]   %s: %d key(s) whose forms carry different admission datetimes were resolved by stay_form_primary\n",
                label, n_flagged))

  if (length(rows_to_remove) > 0) {
    df <- df[-rows_to_remove, , drop = FALSE]
  }

  log_df <- do.call(rbind, log_rows)

  cat(sprintf(
    "[dedup]   %s: %d repeated key(s) resolved -- %d row(s) removed\n",
    label, length(dup_keys), length(rows_to_remove)
  ))

  list(
    df         = df,
    log        = log_df,
    n_dup_keys = length(dup_keys),
    n_removed  = length(rows_to_remove)
  )
}
