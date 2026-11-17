################################################################################
# Neotree Sample Maker -- Module 01: Join Admissions & Discharges
# FILE:    modules/deduplicator.R
# PURPOSE: Detect and resolve repeated match keys (see joiner.R) in admissions
#          and discharges data frames, so that each key appears once in the
#          join.
#
# STRATEGY
#   When a key appears more than once in a file, keep one row:
#     * the row marked stay_form_primary = TRUE, when the file has that column
#       (discharges cleaned in episode mode: the other discharge forms of the
#       same stay are not joined; they stay in the cleaned discharge file);
#     * otherwise the row with the fewest NA values (the most complete record).
#   All groups are logged to a DUPLICATES_LOG CSV for manual review.
#
#   Possible genuine readmissions (same uid+facility, different admission
#   datetimes) are flagged in the log with possible_readmission = TRUE.  These
#   are not excluded automatically; they are listed in the log for review.
#
# FUNCTION EXPORTED
#   resolve_duplicates(df, label)
#     -> returns list(df, log, n_dup_keys, n_removed)
################################################################################

resolve_duplicates <- function(df, label) {

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

  cat(sprintf(
    "[dedup]   WARNING: %d duplicate uid+facility key(s) in %s -- resolving...\n",
    length(dup_keys), label
  ))

  log_rows       <- list()
  rows_to_remove <- integer(0)

  for (key in dup_keys) {
    idx       <- which(df$match_key == key)
    na_counts <- vapply(idx, function(i) sum(is.na(df[i, ])), integer(1))
    has_prim  <- "stay_form_primary" %in% names(df)
    primary   <- if (has_prim)
      idx[as.character(df$stay_form_primary[idx]) %in% c("TRUE", "True", "true", "1")] else integer(0)
    if (has_prim && length(primary) != 1)
      stop(sprintf(paste("[dedup] %s: a stay with %d discharge forms has %d forms marked stay_form_primary;",
                         "exactly one is expected. Check the cleaned discharges file."),
                   label, length(idx), length(primary)))
    keep      <- if (length(primary) == 1) primary else idx[which.min(na_counts)]
    remove    <- setdiff(idx, keep)

    # Flag if more than one row has a non-NA admission datetime
    # (possible genuine readmission rather than data-entry duplicate)
    if ("datetimeadmission" %in% names(df)) {
      adm_dates          <- df$datetimeadmission[idx]
      genuine_readmission <- sum(!is.na(adm_dates) & nchar(trimws(as.character(adm_dates))) > 0) > 1
    } else {
      genuine_readmission <- FALSE
    }

    if (genuine_readmission) {
      cat(sprintf(
        "[dedup]     *** POSSIBLE READMISSION: %s (%d rows with non-NA admission datetime -- review manually)\n",
        key, sum(!is.na(df$datetimeadmission[idx]))
      ))
    }

    for (r in idx) {
      log_rows[[length(log_rows) + 1]] <- data.frame(
        source               = label,
        match_key            = key,
        row_index_in_file    = r,
        na_count             = na_counts[which(idx == r)],
        action               = ifelse(r == keep, "KEPT",
                                      if (length(primary) == 1) "NOT JOINED (other form of the same stay)" else "REMOVED"),
        possible_readmission = genuine_readmission,
        stringsAsFactors     = FALSE
      )
    }

    rows_to_remove <- c(rows_to_remove, remove)
  }

  if (length(rows_to_remove) > 0) {
    df <- df[-rows_to_remove, ]
  }

  log_df <- do.call(rbind, log_rows)

  cat(sprintf(
    "[dedup]   %s: %d duplicate key(s) resolved -- %d row(s) removed\n",
    label, length(dup_keys), length(rows_to_remove)
  ))

  list(
    df         = df,
    log        = log_df,
    n_dup_keys = length(dup_keys),
    n_removed  = length(rows_to_remove)
  )
}
