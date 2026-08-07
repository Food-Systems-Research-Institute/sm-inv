# Excel processing
# 2025-09-11

#' This script takes our 'revised_secondary_metrics.xlsx' from OneDrive and
#' combines it with the literature justifications to get one very large, some
#' might even say giant, table. It may be saved back to OneDrive for reference,
#' but it is not a final product. We will use this table to:
#'   1. Create the body table that will go in the body of the paper. This
#'    will include just the essential information for the reader: dimension,
#'    indicator, metric, definition, weighting, source, and shorthand citations.
#'    Subject to revision.
#'  2. Create the supplementary table with stuff for nerds: level of analysis,
#'    indicator type, state coverage, county coverage, first year, last year, year
#'    range, url, resolution, updates, probably others. I suppose it's just
#'    everything else that is of any use.


# Housekeeping ------------------------------------------------------------

pacman::p_load(
  dplyr,
  purrr,
  stringr,
  readxl,
  openxlsx2,
  tidyr,
  readr,
  remotes,
  writexl,
  httr2,
  knitr,
  kableExtra,
  here
)

pacman::p_load_current_gh(
  "ChrisDonovan307/projecter",
  "Food-Systems-Research-Institute/SMdata"
)

conflicted::conflicts_prefer(
  dplyr::filter(),
  dplyr::select(),
  .quiet = TRUE
)

options(scipen = 9999)


# Pull Metrics Revised and Lit Justification Excel files -----------------
## Set Paths ---------------------------------------------------------------

root_metric_path <- "/mnt/c/Users/cdonov12/OneDrive - University of Vermont/Food Systems Research Center/Sustainability Metrics/2026 Sustainability Metrics Manuscript/Metrics/"
og_xl_path <- paste0(root_metric_path, "secondary_metrics_revised.xlsx")
lit_path <- paste0(root_metric_path, "literature_justifying_indicators.xlsx")

# Relative path to where we will save a copy of the secondary metrics xl locally
new_xl_path <- here::here("1_intro", "output", "secondary_metrics.xlsx")


## Read Revised Metrics files (5 sheets of Metrics file) -------------------

sheet_names <- excel_sheets(og_xl_path)

combined_df <- lapply(sheet_names[1:5], function(sheet) {
  df <- read_excel(og_xl_path, sheet = sheet)
  df$quality <- as.character(df$quality)
  df$dimension <- sheet
  df
}) %>%
  bind_rows() %>%
  filter(!is.na(indicator))
get_str(combined_df)


## Existing Metrics --------------------------------------------------------

# Pull out existing SMdata metrics
existing_metrics <- SMdata::metrics %>%
  filter(variable_name %in% combined_df$variable_name) %>%
  SMdata::filter_fips("neast") %>%
  bind_rows(SMdata::metrics %>%
    filter(variable_name == "cpi"))
get_str(existing_metrics)


## Coverage Stats ----------------------------------------------------------

# Get a summary table of existing metrics
sum_stats <- existing_metrics %>%
  group_by(variable_name) %>%
  summarize(
    n_states = length(unique(fips[nchar(fips) == 2])),
    n_counties = length(unique(fips[nchar(fips) == 5])),
    n_years = length(unique(sort(year))),
    first_year = min(unique(year)),
    latest_year = max(unique(year)),
    year_range = max(unique(as.numeric(year))) - min(unique(as.numeric(year)))
  )
get_str(sum_stats)


# Join to combined_df
new_table_with_sum <- combined_df %>%
  left_join(sum_stats, by = "variable_name")
get_str(new_table_with_sum)


## Lit Justifications ------------------------------------------------------

lit_xl <- read_excel(lit_path)
get_str(lit_xl)

# Reformat shorthand citations to be separated by commas
head(lit_xl$`Shorthand Citations`)
lit_xl <- lit_xl %>%
  mutate(
    shorthand_citations = `Shorthand Citations` %>%
      str_replace_all("\\r\\n", ", "),
    .keep = "unused"
  )
head(lit_xl$shorthand_citations)

# Check indicator counts in lit_xl and combined_df
lit_ind_count <- length(unique(lit_xl$indicator))
df_ind_count <- length(unique(new_table_with_sum$indicator))
if (lit_ind_count != df_ind_count) {
  warning(
    paste(
      "There should be the same number of indicators in the lit xl and the summary table",
      "The lit XL has", lit_ind_count, "and the summary table has", df_ind_count
    )
  )
}

# Combine summary table with justification
giant_table <- new_table_with_sum %>%
  left_join(
    select(lit_xl, indicator, shorthand_citations),
    by = "indicator"
  ) %>%
  fill(indicator, index, shorthand_citations, .direction = "down") %>%
  select(quality, dimension, everything())
get_str(giant_table)


# Summary Stats -----------------------------------------------------------

# Simplify resolution into only county or state.
(all_res <- giant_table$resolution %>% unique())
giant_table <- giant_table %>%
  mutate(resolution = case_when(
    resolution %in% c("system", "state") ~ "state",
    resolution %in% c("county", "30m", "4km") ~ "county",
    .default = NA
  ))
get_str(giant_table)

# Get mean and standard deviation depending on the resolution of metric
get_str(existing_metrics)
county_stats <- existing_metrics %>%
  SMdata::filter_fips("counties") %>%
  filter(variable_name %in% giant_table$variable_name[giant_table$resolution == "county"]) %>%
  mutate(value = as.numeric(value)) %>%
  group_by(variable_name) %>%
  summarize(
    mean = mean(value, na.rm = TRUE),
    sd = sd(value, na.rm = TRUE)
  ) %>%
  ungroup()
county_stats

state_stats <- existing_metrics %>%
  SMdata::filter_fips("states") %>%
  filter(variable_name %in% giant_table$variable_name[giant_table$resolution == "state"]) %>%
  mutate(value = as.numeric(value)) %>%
  group_by(variable_name) %>%
  summarize(
    mean = mean(value, na.rm = TRUE),
    sd = sd(value, na.rm = TRUE)
  ) %>%
  ungroup()
state_stats

# Combine them
all_stats <- bind_rows(county_stats, state_stats)
get_str(all_stats)

# Add them to giant table
giant_table <- giant_table %>%
  left_join(all_stats)
get_str(giant_table)


# Save Giant Table --------------------------------------------------------

# Saving to OneDrive and as RDS
# Note that this is not a final product, just a way to reference our giant table

# OneDrive as excel
giant_table_path <- paste0(
  root_metric_path,
  Sys.Date(),
  "_giant_table.xlsx"
)
openxlsx2::write_xlsx(
  giant_table,
  giant_table_path,
  widths = c(15, "auto"),
  na.strings = "NA"
)

# Save to outputs
openxlsx2::write_xlsx(
  giant_table,
  here::here("0_prep", "output", "giant_table.xlsx"),
  widths = c(15, "auto"),
  na.strings = "NA"
)


# Save DP Objects ---------------------------------------------------------

## dp_tree ----
# For making framework diagrams
# Includes NONE_# as placeholder when we are missing a metric
dp_tree <- giant_table %>%
  select(dimension, index, indicator, metric)
count <- sum(dp_tree$metric == "NONE")
dp_tree$metric[dp_tree$metric == "NONE"] <- paste0("NONE_", 1:count)

saveRDS(dp_tree, here::here("0_prep", "output", "dp_tree.rds"))


## dp_meta ----
# all metadata for just dp_metrics based on excel sheet in OneDrive
dp_meta <- giant_table
saveRDS(dp_meta, here::here("0_prep", "output", "dp_meta.rds"))


## dp_metrics ----
# Only the metrics where we have state and county level that are used in dp
# get_str(existing_metrics)
dp_metrics <- existing_metrics %>%
  mutate(across(c(year, value), as.numeric))
saveRDS(dp_metrics, here::here("0_prep", "output", "dp_metrics.rds"))


## dp_weight_vars ----
# Variable names and metric names of weighting variables from utils sheet
dp_weight_vars <- read_excel(
  og_xl_path,
  sheet = "utilities"
) %>%
  filter(status != "stall") %>%
  select(metric, variable_name)
saveRDS(dp_weight_vars, here::here("0_prep", "output", "dp_weight_vars.rds"))


## dp_weights ----
# Get another DF of weighting variables
dp_weights <- SMdata::metrics %>%
  filter(variable_name %in% dp_weight_vars$variable_name) %>%
  filter_fips("neast")
saveRDS(dp_weights, here::here("0_prep", "output", "dp_weights.rds"))


## dp_metrics_county ----
# Pull out county and state separately, based on spec in metadata
county_vars <- dp_meta %>%
  filter(resolution %in% c("county", "30m", "4km")) %>%
  pull(variable_name)
dp_metrics_county <- dp_metrics %>%
  filter(variable_name %in% county_vars) %>%
  SMdata::filter_fips("counties")
saveRDS(dp_metrics_county, here::here("0_prep", "output", "dp_metrics_county.rds"))


## dp_metrics_state ----
# Only take state data for which there is no county data
# Also pull CPI which is system level. Join this with state metrics
state_vars <- dp_meta %>%
  filter(resolution %in% c("state", "system")) %>%
  pull(variable_name)
dp_metrics_state <- dp_metrics %>%
  filter(variable_name %in% state_vars) %>%
  SMdata::filter_fips("states")
cpi <- dp_metrics %>%
  filter(variable_name == "cpi")
dp_metrics_state <- bind_rows(dp_metrics_state, cpi)
saveRDS(dp_metrics_state, here::here("0_prep", "output", "dp_metrics_state.rds"))


## dp_metrics_county_wide ----
# Pivot wider for transformations, then alphabetize columns
dp_metrics_county_wide <- dp_metrics_county %>%
  # Remove one weird doubled up value
  filter(!(
    fips == "42" & year == 2022 & variable_name == "hayYieldMeasuredInTonsAcre"
  )) %>%
  pivot_wider(
    id_cols = c(fips, year),
    values_from = "value",
    names_from = "variable_name"
  ) %>%
  select(fips, year, sort(names(.)[2:length(names(.))]))
saveRDS(
  dp_metrics_county_wide,
  here::here("0_prep", "output", "dp_metrics_county_wide.rds")
)


# Inflation Adjustment ----------------------------------------------------

# Making another set of data for dp county metrics and dp state metrics that
# have accounted for inflation

usd_metrics <- SMdocs::dp_meta %>%
  filter(str_detect(units, "USD")) %>%
  select(metric, variable_name, units, resolution, source)
usd_metrics

# Pull CPI - All Items data
cpi <- SMdata::metrics %>%
  filter(variable_name == "cpiAllItems") %>%
  select(year, value) %>%
  rename(cpi = value)

# Pull 2024 CPI as constant
cpi_2024 <- cpi$cpi[cpi$year == "2024"]

# Adjust columns that are in USD
dfs <- list(dp_metrics_county, dp_metrics_state)
adj_dfs <- map(dfs, ~ {
  .x %>%
    left_join(cpi, by = join_by(year)) %>%
    mutate(value = case_when(
      variable_name %in% usd_metrics$variable_name ~ value * (cpi_2024 / cpi),
      !variable_name %in% usd_metrics$variable_name ~ value,
      .default = NA
    )) %>%
    select(-cpi)
}) %>%
  setNames(c("county", "state"))
get_str(adj_dfs, 3)

# Save these as new DFs to keep them separate from nominal values

## dp_metrics_county_adj ----
dp_metrics_county_adj <- adj_dfs$county
saveRDS(dp_metrics_county_adj, here::here("0_prep", "output", "dp_metrics_county_adj.rds"))

## dp_metrics_state_adj ----
dp_metrics_state_adj <- adj_dfs$state
saveRDS(dp_metrics_state_adj, here::here("0_prep", "output", "dp_metrics_state_adj.rds"))
