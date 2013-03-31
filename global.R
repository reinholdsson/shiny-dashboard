# Load libraries

library(Coldbir)
library(rHighcharts)
library(data.table)
library(zoo)

# Global variables

## Data source
.data_source <- "~/Desktop/prodstat/"
.db <- cdb(.data_source, type = "f")

## Load data into memory
.data <- data.table(
    arendeid = .db["arendeid"],
    process = .db["process"],
    processtyp = .db["processtyp"],
    arendetyp = .db["arendetyp"],
    klassificering = .db["klassificering"],
    startdatum = .db["startdatum"],
    slutdatum = .db["slutdatum"]
)

## Constants
#.months <- c("Januari", "Februari", "Mars", "April", "Maj", "Juni", "Juli", "Augusti", "September", "Oktober", "November", "December")
.months <- c("Jan", "Feb", "Mar", "Apr", "Maj", "Jun", "Jul", "Aug", "Sep", "Okt", "Nov", "Dec")