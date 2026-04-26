## scrape-pac.R
## HW 06 - Money in US Politics
##
## NOTE: OpenSecrets.org blocks automated scraping from all cloud environments
## (including JupyterHub) and most personal machines. The data for this
## assignment has been pre-collected and provided as data/pac-all.csv, which
## covers 12 election cycles (2000-2022).
##
## This script is provided so you can read, understand, and learn from the
## scraping workflow that was used to collect the data. You do NOT need to
## run it successfully to complete the homework -- start from Exercise 1
## in hw-06-money-in-politics.Rmd using the provided pac-all.csv.
##
## Learning goals for this script:
##   - Understand how read_html() fetches a webpage
##   - See how html_node() + html_table() extracts a table from HTML
##   - Learn how a custom function encapsulates a repeated task
##   - See how map_df() applies a function across multiple URLs
##   - Understand how str_sub() extracts the year from a URL string

# Load packages ---------------------------------------------------------------

library(tidyverse)
library(rvest)

# The scrape_pac() function ---------------------------------------------------
# This function takes a URL for one election year and returns a data frame.
# Study how each step works -- this is the kind of function you will write
# yourself in future data science work.

scrape_pac <- function(url) {

  # Step 1: Read the full HTML of the page
  page <- read_html(url)

  # Step 2: Find the contributions table using its CSS selector,
  #         then parse it into a data frame
  pac <- page %>%
    html_node(".DataTable-Partial") %>%
    html_table(fill = TRUE)

  # Step 3: Rename columns to snake_case
  pac <- pac %>%
    rename(
      name           = `PAC Name (Affiliate)`,
      country_parent = `Country of Origin/Parent Company`,
      total          = Total,
      dems           = Dems,
      repubs         = Repubs
    )

  # Step 4: Clean extra whitespace from the country/parent column
  pac <- pac %>%
    mutate(country_parent = str_squish(country_parent))

  # Step 5: Extract the year from the last 4 characters of the URL
  #         e.g. ".../foreign-connected-pacs/2022" -> "2022"
  pac <- pac %>%
    mutate(year = as.integer(str_sub(url, -4)))

  return(pac)
}

# The URLs for each election cycle (2000-2022) --------------------------------

urls <- paste0(
  "https://www.opensecrets.org/political-action-committees-pacs/foreign-connected-pacs/",
  seq(2000, 2022, by = 2)
)

# How the data was collected --------------------------------------------------
# map_df() applies scrape_pac() to each URL and stacks the results into
# one data frame. This is the iteration pattern covered in lecture.
#
# NOTE: This code is commented out because OpenSecrets blocks automated
# requests. The pre-collected output is provided as data/pac-all.csv.

# pac_all <- map_df(urls, scrape_pac)
# write_csv(pac_all, "data/pac-all.csv")

# Start here for your homework ------------------------------------------------
# Load the pre-collected data and proceed to Exercise 1 in the Rmd.

pac_all <- read_csv("hw-06/data/pac-all.csv")
glimpse(pac_all)
