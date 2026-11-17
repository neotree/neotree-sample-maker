################################################################################
# Neotree Sample Maker -- tests for joining files cleaned in episode mode
# FILE:    tests/test_episode_join.R
# PURPOSE: Checks, on made-up records, the match key, deduplication, join,
#          probabilistic-match lookup, NA-coded lookup, advanced date filters
#          and anonymization when
#          the cleaned files carry baby_id and stay_no, and that files without
#          them still join on uid + facility.
#
# USAGE (from the sample_maker_R folder):
#   Rscript tests/test_episode_join.R
#   Exit status 0 = all tests passed; 1 = at least one failure.
################################################################################

.args     <- commandArgs(trailingOnly = FALSE)
.file_arg <- sub("^--file=", "", grep("^--file=", .args, value = TRUE))
ROOT <- if (length(.file_arg)) normalizePath(file.path(dirname(.file_arg[1]), "..")) else getwd()
for (m in c("joiner.R", "deduplicator.R", "master_builder.R", "output_writer.R", "anonymizer.R", "prob_matcher.R",
            "filter_data.R", "subsample_maker.R"))
  invisible(capture.output(source(file.path(ROOT, "modules", m))))

n_pass <- 0L; n_fail <- 0L
check <- function(label, ok) {
  ok <- isTRUE(ok)
  cat(sprintf("  [%s] %s\n", if (ok) "PASS" else "FAIL", label))
  if (ok) n_pass <<- n_pass + 1L else n_fail <<- n_fail + 1L
}
quiet <- function(expr) { out <- NULL; invisible(capture.output(out <- expr)); out }

# Two babies under TEST-01 (A stay 1, B stay 1), one baby with two stays under
# TEST-02, one admission without a baby_id.  Discharges: one per stay, plus a
# second form for TEST-01.A stay 1 (not primary), and a discharge with no
# admission.
adm <- data.frame(
  uid = c("TEST-01", "TEST-01", "TEST-02", "TEST-02", "TEST-03"), facility = "H1",
  uniquekey = c("a1", "a2", "a3", "a4", "a5"),
  baby_id = c("TEST-01.A", "TEST-01.B", "TEST-02.A", "TEST-02.A", NA),
  stay_no = c(1L, 1L, 1L, 2L, NA), label = c("A1", "B1", "C1", "C2", "X"),
  stringsAsFactors = FALSE)
dis <- data.frame(
  uid = c("TEST-01", "TEST-01", "TEST-01", "TEST-02", "TEST-02", "TEST-09"), facility = "H1",
  uniquekey = c("d1", "d2", "d3", "d4", "d5", "d6"),
  baby_id = c("TEST-01.B", "TEST-01.A", "TEST-01.A", "TEST-02.A", "TEST-02.A", "TEST-09.A"),
  stay_no = c(1L, 1L, 1L, 2L, 1L, 1L), stay_form_primary = c(TRUE, FALSE, TRUE, TRUE, TRUE, TRUE),
  label = c("B1", "A1-old", "A1", "C2", "C1", "Y"), outcome = c("DC", "DC", "NND", "DC", "DC", "DC"),
  stringsAsFactors = FALSE)

cat("\n1. Match key\n")
k <- quiet(add_match_keys(adm, dis))
check("files with baby_id and stay_no use the episode key", k$mode == "episode")
check("episode key is baby_id + stay_no + facility", k$admissions$match_key[1] == "TEST-01.A_1_H1")
check("a row without baby_id gets a key of its own", startsWith(k$admissions$match_key[5], "nokey_"))
k0 <- quiet(add_match_keys(adm[, c("uid", "facility", "uniquekey")], dis[, c("uid", "facility", "uniquekey")]))
check("files without baby_id use uid + facility", k0$mode == "uid" && k0$admissions$match_key[1] == "TEST-01_H1")
check("baby_id in only one of the two files stops the run",
      inherits(try(quiet(add_match_keys(adm, dis[, c("uid", "facility", "uniquekey")])), silent = TRUE), "try-error"))

cat("\n2. Deduplication\n")
ad <- quiet(resolve_duplicates(k$admissions, "ADMISSIONS"))
dd <- quiet(resolve_duplicates(k$discharges, "DISCHARGES"))
check("admissions: nothing removed (keys unique)", ad$n_removed == 0 && nrow(ad$df) == 5)
check("discharges: the non-primary form of a stay is not joined", dd$n_removed == 1 && !"d2" %in% dd$df$uniquekey)
check("discharges: the primary form is kept", "d3" %in% dd$df$uniquekey)
bad <- k$discharges; bad$stay_form_primary[bad$uniquekey == "d2"] <- TRUE
check("two primary forms for one stay stop the run",
      inherits(try(quiet(resolve_duplicates(bad, "DISCHARGES")), silent = TRUE), "try-error"))

cat("\n3. Join\n")
j <- quiet(join_data(ad$df, dd$df))
mp <- j$matched_pairs
check("four stays matched", j$n_matched == 4 && nrow(mp) == 4)
check("each discharge sits beside its own admission", all(mp$label == mp$label_dis))
check("two babies under one uid stay apart", sum(mp$uid == "TEST-01") == 2)
check("admission without baby_id and discharge without admission are unmatched",
      j$n_unmatched_adm == 1 && j$n_unmatched_dis == 1)
check("repeated keys stop the join", inherits(try(quiet(join_data(k$admissions, k$discharges)), silent = TRUE), "try-error"))

cat("\n4. Probabilistic match lookup\n")
mj <- quiet(build_master_joined(matched_pairs = mp, unmatched_adm = j$unmatched_adm))
ua <- j$unmatched_adm; ud <- j$unmatched_dis
asg <- data.frame(adm_row_idx = 1L, dis_row_idx = 1L, overall_similarity = 90,
                  adm_uid = ua$uid[1], adm_facility = ua$facility[1], adm_uniquekey = ua$uniquekey[1],
                  dis_uid = ud$uid[1], dis_facility = ud$facility[1], dis_uniquekey = ud$uniquekey[1],
                  stringsAsFactors = FALSE)
mje <- quiet(build_master_joined_extended(mj, asg, ua, ud))
check("the prob-matched admission is found by its match key", sum(mje$match_type == "prob_match") == 1 &&
        mje$label[mje$match_type == "prob_match"] == "X" && sum(mje$match_type == "unmatched") == 0)

pa <- data.frame(uid = c("TEST-20", "TEST-21"), facility = "H1", uniquekey = c("p1", "p2"),
                 baby_id = c("TEST-20.A", "TEST-21.A"), stay_no = 1L, birthweight = 2500, gestation = 37,
                 stringsAsFactors = FALSE)
pd <- data.frame(uid = c("TEST-20", "TEST-22"), facility = "H1", uniquekey = c("q1", "q2"),
                 baby_id = c("TEST-20.B", "TEST-22.A"), stay_no = 1L, birthweight = 2500, gestation = 37,
                 stringsAsFactors = FALSE)
pcfg <- list(prob_match_completeness_threshold = 0.5, prob_match_min_similarity = 100,
             prob_match_max_candidates = 5, prob_match_cross_facility = FALSE)
vi <- quiet(detect_match_variables(pa, pd, pcfg))
pc <- quiet(find_prob_candidates(pa, pd, vi, pcfg))
check("episode mode: no probabilistic pair with the same uid and facility",
      nrow(pc) > 0 && !any(pc$adm_uid == pc$dis_uid))
check("episode mode: pairs with different uids are still offered",
      any(pc$adm_uid == "TEST-20" & pc$dis_uid == "TEST-22"))

cat("\n5. NA-coded lookup\n")
adm_nc <- adm; adm_nc$label <- paste0(adm_nc$label, "-nc")
dis_nc <- dis; dis_nc$label <- paste0(dis_nc$label, "-nc")
nc <- .build_na_coded_master_joined(mj, adm_nc, dis_nc)
dm <- nc$match_type == "direct_match"
check("NA-coded values come from the right admission and discharge rows",
      all(nc$label[dm] == paste0(mj$label[dm], "-nc")) && all(nc$label_dis[dm] == paste0(mj$label_dis[dm], "-nc")))

cat("\n6. Anonymization\n")
an <- anonymize_dataset(mj, list())$df
check("baby_id and the discharge copies of uid, uniquekey and baby_id are removed",
      !any(c("uid", "uid_dis", "uniquekey", "uniquekey_dis", "baby_id", "baby_id_dis", "match_key") %in% names(an)))
check("stay_no is kept", "stay_no" %in% names(an))

cat("\n7. Advanced date filters\n")
fa <- data.frame(uid = c("TEST-30", "TEST-30", "TEST-31", "TEST-31"), facility = "H1",
                 uniquekey = c("f1", "f2", "f3", "f4"),
                 baby_id = c("TEST-30.A", "TEST-30.A", NA, NA), stay_no = c(1L, 1L, NA, NA),
                 adm_date_parsed = as.POSIXct(c("2024-01-10", "2024-01-10", "2024-01-12", "2024-01-12"), tz = "UTC"),
                 stringsAsFactors = FALSE)
one  <- list(c("H1", "2024-01-01", "2024-01-31"))
both <- list(c("H1", "2024-01-01", "2024-01-31"), c("H1", "2024-01-05", "2024-02-28"))
fr1 <- quiet(apply_admission_filter(fa, NULL, list(use_advanced_mode = TRUE, facility_date_ranges = one)))
fr2 <- quiet(apply_admission_filter(fa, NULL, list(use_advanced_mode = TRUE, facility_date_ranges = both)))
check("admission filter: distinct rows sharing baby_id, stay_no and facility are all kept",
      nrow(fr1$admissions) == 4 && setequal(fr1$admissions$uniquekey, fa$uniquekey))
check("admission filter: overlapping ranges keep each row once, rows without baby_id included",
      nrow(fr2$admissions) == 4 && !anyDuplicated(fr2$admissions$uniquekey))
sr1 <- quiet(.apply_sub_filter(fa, list(sub_use_advanced_mode = TRUE, sub_facility_date_ranges = one), NULL, "t"))
sr2 <- quiet(.apply_sub_filter(fa, list(sub_use_advanced_mode = TRUE, sub_facility_date_ranges = both), NULL, "t"))
check("subsample filter: distinct rows sharing baby_id, stay_no and facility are all kept",
      sr1$n_kept == 4 && setequal(sr1$df$uniquekey, fa$uniquekey))
check("subsample filter: overlapping ranges keep each row once, rows without baby_id included",
      sr2$n_kept == 4 && !anyDuplicated(sr2$df$uniquekey))

cat(sprintf("\n=== %d test(s): %d passed, %d failed ===\n", n_pass + n_fail, n_pass, n_fail))
quit(status = if (n_fail > 0) 1 else 0)
