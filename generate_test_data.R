# Produktionsstatistik testdata 

library(Coldbir)

a <- cdb("~/Desktop/prodstat")

a["arendeid"] <- 1:1000000
a["arendeid"] <- doc(title = "Ärende Id", description = "Ärende identifieringsid")

a["process"] <- sample(
    c(
        "Bostadstillägg och äldreförsörjningsstöd",
        "Premiepension",
        "Efterlevandepension",
        "Ålderspension",
        "Kravärende",
        "Ärendemottagning"
    ),
    1000000, replace = TRUE,
    prob = c(3,5,1,2,0.4,0.7))
a["process"] <- doc(title = "Process", description = "Process som ärendet tillhör")

a["processtyp"] <- sample(
    c(
        NA,
        "Nationellt",
        "Internationellt",
        "Utland"
    ),
    1000000, replace = TRUE,
    prob = c(5,2,2,1))
a["processtyp"] <- doc(title = "Processtyp", description = "Information om var den sökande är eller har varit bosatt")

a["arendetyp"] <- sample(
    c(
        NA,
        "Ansökan",
        "Omräkning",
        "Allmän",
        "Övrigt"
    ),
    1000000, replace = TRUE,
    prob = c(0.1,5,3,2,0.2))
a["arendetyp"] <- doc(title = "Ärendetyp", description = "Typ av ärende")

a["klassificering"] <- sample(
    c(
        "GARP",
        "Felberäkning",
        "Övrigt",
        "Testärende",
        "Omgående"
    ),
    1000000, replace = TRUE,
    prob = c(1,0.1,1,2,0.5))
a["klassificering"] <- doc(title = "Klassificering", description = "Klassificering av ärende (avser)")

a["startdatum"] <- as.POSIXct(runif(1000000, 0, 100000000), origin = '2010-06-01')
a["startdatum"] <- doc(title = "Startdatum", description = "När ärendet startades")

a["slutdatum"] <- as.POSIXct(a["startdatum"] + c(runif(900000, 0, 10000000), rep(NA, 100000)), origin = '2010-06-01')  # Lägg 10 % NA-värden för ärenden som inte avslutats
a["slutdatum"] <- doc(title = "Slutdatum", description = "När ärendet avslutades")

