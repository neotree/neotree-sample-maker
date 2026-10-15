================================================================================
  Neotree Sample Maker -- Subsample settings (SUBSAMPLE_CONFIG)
================================================================================

PURPOSE
-------
Lists the settings read by run_subsample_maker.R and their effect. How each
filter works is described in README_run_subsample_maker.txt.


CONFIG FILES
------------
  config_subsample_maker.R              A complete example with both modes.
  config_subsample_TEMPLATE.R           Annotated list of every setting.
  config_subsample_master_TEMPLATE.R    Starting point for a master-mode
                                        request.
  config_subsample_cleaned_TEMPLATE.R   Starting point for a cleaned-mode
                                        request.

Each defines one list named SUBSAMPLE_CONFIG. Copy a file, fill it in, and
pass the copy to run_subsample_maker.R as its first argument.


SETTINGS
--------

Mode

  source_type   "master": read the two master dataset files.
                "cleaned": read cleaned files from the input folder.
                Missing or empty is taken as "master". Any other value stops
                the run.

Master mode

  master_joined_file            Paths of the two master files. A path that
  master_joined_extended_file   does not exist as given is looked for under
                                the script folder. The run stops if either
                                file is missing.

Cleaned mode

  cleaning_pipeline_output_dir  Folder with the cleaned dataset folders. A
                                path that does not exist as given is looked
                                for under the script folder.
  country                       "zim" or "mwi".
  source                        "from_database" or "from_metabase". The
                                second is refused unless INCLUDE_METABASE is
                                TRUE in run_subsample_maker.R. The check is
                                made in master mode too when the setting is
                                present.
  datasets                      One entry per dataset type; see below.

Both modes

  output_dir               Folder for the outputs. NULL uses subsamples/
                           beside the script. A relative path is taken from
                           the script folder. The folder is created if needed.
  output_na_coded          TRUE: also write the na_coded files when the
                           na_coded sources exist. FALSE: standard files only.
  sub_start_date           "YYYY-MM-DD" or NULL (no lower bound).
  sub_end_date             "YYYY-MM-DD" or NULL (no upper bound).
  sub_facility_filter      NULL for all facilities, or a character vector of
                           facility names as they appear in the facility
                           column.
  sub_use_advanced_mode    TRUE: use sub_facility_date_ranges in place of the
                           two dates and the facility filter.
  sub_facility_date_ranges List of entries c("FACILITY", "start", "end").
                           Master mode needs both dates in every entry and
                           stops if the list is empty. Cleaned mode accepts NA
                           for an open side and, if the list is empty, falls
                           back to the two dates and the facility filter.
  sub_exclusion_filters    List of filters, each
                           list(variable = , operator = , value = ).
                           Rows that meet a condition are removed. Operators:
                           <, <=, >, >=, ==, !=, in, not_in. value may be a
                           vector for in and not_in.
  sub_variables            NULL keeps all columns. A character vector keeps
                           those columns and the mandatory ones.

  Master mode filters on the admission date. Cleaned mode filters each type
  on its own date_column.

Dataset entries (cleaned mode)

  datasets is a list with the entries admissions, discharges, neolab and
  maternal. Each entry is a list:

  include                     TRUE to process the type.
  date_column                 Column used for the date filter, or NULL for
                              none.
  sub_start_date              Replaces the global start date for this type.
  sub_end_date                Replaces the global end date for this type.
  sub_end_date_offset_months  Whole number of calendar months added to the
                              end date of this type. NULL or 0 adds none.
  date_window_note            Text printed in the report of this type. When
                              it is NULL or empty and an offset is set, the
                              report states the extension.
  sub_variables               Replaces the global column list when not NULL.
  sub_exclusion_filters       Replaces the global filters when not empty.


EXAMPLE
-------
  SUBSAMPLE_CONFIG <- list(
    source_type                  = "cleaned",
    cleaning_pipeline_output_dir = "input",
    country                      = "zim",
    source                       = "from_database",
    output_dir                   = "subsamples/mystudy",
    output_na_coded              = FALSE,
    sub_start_date               = "2025-01-01",
    sub_end_date                 = "2025-12-31",
    sub_facility_filter          = c("FACILITY_A"),
    sub_use_advanced_mode        = FALSE,
    sub_facility_date_ranges     = list(),
    sub_exclusion_filters        = list(
      list(variable = "gestation", operator = "<", value = 24)
    ),
    sub_variables                = NULL,
    datasets = list(
      admissions = list(
        include       = TRUE,
        date_column   = "datetimeadmission",
        sub_variables = c("birthweight", "gestation", "gender")
      ),
      discharges = list(
        include                    = TRUE,
        date_column                = "datetimedischarge",
        sub_end_date_offset_months = 1L
      )
    )
  )
