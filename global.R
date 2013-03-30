# Load libraries

library(Coldbir)
library(rHighcharts)
library(data.table)
library(zoo)

# Global variables

## Data source
.data_source <- "~/Desktop/prodstat/"
.db <- cdb(.data_source, type = "f")

## Months
.months <- c("Januari" = 1, "Februari" = 2, "Mars" = 3, "April" = 4, "Maj" = 5, "Juni" = 6, "Juli" = 7, "Augusti" = 8, "September" = 9, "Oktober" = 10, "November" = 11, "December" = 12)
