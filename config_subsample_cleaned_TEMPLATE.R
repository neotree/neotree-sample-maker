#!/usr/bin/env Rscript

################################################################################
# Neotree Sample Maker -- Pipeline 2: Subsample from cleaned pipeline files
# FILE:    config_subsample_cleaned_TEMPLATE.R
# PURPOSE: Template for data access requests requiring standalone subsamples
#          from the cleaned source files (admissions, discharges, neolab,
#          maternal -- each processed independently, no join required).
#
#          Use this template when the request needs:
#            - Standalone per-type files
#            - Custom variable lists per dataset type
#            - Neolab or maternal records alongside admission/discharge records
#
#          Copy and rename this file for each request, e.g.:
#            config_subsample_REQUEST_cleaned.R
#
#          Then run:
#            Rscript run_subsample_maker.R config_subsample_REQUEST_cleaned.R
#
#          A request can use both a master-mode config (primary joined
#          dataset) and this cleaned-mode config (standalone per-type files).
#          Write both to the same output_dir so that run_subsample_user_dict.R
#          can auto-discover all files in one pass.
#
# Full option reference: see config_subsample_TEMPLATE.R
################################################################################

SUBSAMPLE_CONFIG <- list(

  # ============================================================================
  # 1. SOURCE TYPE
  # ============================================================================
  source_type = "cleaned",

  # ============================================================================
  # 2. CLEANED SOURCE SETTINGS
  # ============================================================================
  #
  # Path to the input/ folder (relative to run_subsample_maker.R, or absolute).
  # country and source must match the subdirectory names in input/.
  #
  cleaning_pipeline_output_dir = "input",
  country = "zim",            # "zim" | "mwi"
  source  = "from_database",  # "from_database" | "from_metabase"

  # ============================================================================
  # 3. OUTPUT DIRECTORY
  # ============================================================================
  #
  # Use the same directory as the companion master config so that
  # run_subsample_user_dict.R finds both in one pass.
  #
  # Convention: outputs/{country}/{source}/subsamples/{researcher_name}/
  #
  output_dir = "outputs/zim_master/from_database/subsamples/researcher_name",

  # ============================================================================
  # 4. GLOBAL DATE WINDOW
  # ============================================================================
  #
  # Applied to each dataset type via its date_column (Section 8).
  # Per-dataset overrides can be set in Section 8 if needed.
  #
  sub_start_date = "YYYY-MM-DD",   # first day of study period (inclusive)
  sub_end_date   = "YYYY-MM-DD",   # last day of study period (inclusive)

  # ============================================================================
  # 5. GLOBAL FACILITY FILTER
  # ============================================================================
  #
  # NULL          -> all facilities
  # "FACILITY_A"  -> single facility
  # c("FACILITY_A", "FACILITY_B")  -> multiple facilities
  #
  sub_facility_filter = NULL,

  # ============================================================================
  # 5b. ADVANCED MODE  (leave FALSE for most requests)
  # ============================================================================
  sub_use_advanced_mode    = FALSE,
  sub_facility_date_ranges = list(),

  # ============================================================================
  # 6. GLOBAL EXCLUSION FILTERS  (leave empty for most requests)
  # ============================================================================
  sub_exclusion_filters = list(),

  # ============================================================================
  # 7. GLOBAL COLUMN SELECTION
  # ============================================================================
  #
  # NULL here -- column selection is controlled per dataset in Section 8,
  # because the admission and discharge files have different column names.
  #
  sub_variables = NULL,

  # ============================================================================
  # 8. DATASET SETTINGS
  # ============================================================================
  #
  # Set include = TRUE for each dataset type to be produced.
  # Mandatory columns are always retained:
  #   admissions : uid, facility, uniquekey, datetimeadmission, baby_id, stay_no
  #   discharges : uid, facility, uniquekey, baby_id, stay_no
  #   neolab     : uid, facility, uniquekey, datebct
  #   maternal   : uid, facility, uniquekey, dateadmission, baby_id
  #   (baby_id and stay_no only when the cleaned file has them)
  #

  datasets = list(

    # --------------------------------------------------------------------------
    # ADMISSIONS
    # --------------------------------------------------------------------------
    admissions = list(
      include               = TRUE,
      date_column           = "datetimeadmission",
      sub_exclusion_filters = list(),   # empty = use global filters
      sub_variables = c(
        # Uncomment / add the variables required.
        # Use the variable profile to confirm names and completeness.
        # "age",
        # "agecategory",
        # "birthweight",
        # "gestation",
        # "modedelivery",
        # "inorout",
        # "admittedfrom",
        # "admreason",
        # "feedsadm",
        # "respsup",
        # "surgadm",
        # "bloodsinitial",
        # "bloodsdone",
        # "bloodsfinal",
        # "bloods1",
        # "bloods2",
        # "bcresist",
        # "medsgiven",
        # "rfsepsis"
      )
    ),

    # --------------------------------------------------------------------------
    # DISCHARGES
    # --------------------------------------------------------------------------
    #
    # datetimeadmission is re-entered by hand on the discharge form and can
    # be blank.  To filter by admission date, use a master mode config (which
    # filters by datetimeadmission on the admission record and links
    # discharges via uid).
    #
    # For a standalone discharge file filtered by discharge date:
    #   date_column = "datetimedischarge"
    #   sub_end_date_offset_months = 1L   (to capture babies discharged after the window)
    #
    # For a standalone discharge file with no date filter (all records, facility only):
    #   date_column = NULL
    #
    discharges = list(
      include                    = TRUE,
      date_column                = "datetimeadmission",   # or "datetimedischarge" or NULL
      sub_end_date_offset_months = NULL,                  # set to 1L if using datetimedischarge
      date_window_note           = NULL,
      sub_exclusion_filters      = list(),
      sub_variables = c(
        # "neotreeoutcome",
        # "diagdis1",
        # "causedeath",
        # "contcausedeath",
        # "datetimedeath",
        # "datetimedischarge",
        # "respsup",
        # "surgadm",
        # "bloodsinitial",
        # "bloodsdone",
        # "bloodsfinal",
        # "bloods1",
        # "bloods2",
        # "bcresist",
        # "medsgiven"
      )
    ),

    # --------------------------------------------------------------------------
    # NEOLAB  (blood culture records)
    # --------------------------------------------------------------------------
    neolab = list(
      include               = FALSE,    # set TRUE if neolab records are requested
      date_column           = "datebct",
      sub_exclusion_filters = list(),
      sub_variables = c(
        # "bcresult",
        # "bctype",
        # "datebcr",
        # "org1",
        # "org2",
        # "gram",
        # "sens",
        # "resistance",
        # "resmech",
        # "poshours",
        # "episode"
      )
    ),

    # --------------------------------------------------------------------------
    # MATERNAL
    # --------------------------------------------------------------------------
    maternal = list(
      include               = FALSE,    # set TRUE if maternal records are requested
      date_column           = "dateadmission",
      sub_exclusion_filters = list(),
      sub_variables         = NULL      # NULL = all columns
    )

  )

)
