# Load libraries
library(zoo)
library(lubridate)
library(Coldbir)
library(rHighcharts)
library(data.table)
library(hwriter)

# Global variables

## Data source
.db <- cdb("data", type = "f")

## Load data into memory
.data <- data.table(
    arendeid = .db["arendeid"],
    process = .db["process"],
    arendetyp = .db["arendetyp"],
    startdatum = .db["startdatum"],
    slutdatum = .db["slutdatum"]
)

## Constants
.months <- c("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec")
.processes <- sort(unique(.data$process), na.last = TRUE)
.years <- sort(unique(c(year(.data$startdatum), year(.data$slutdatum))))
