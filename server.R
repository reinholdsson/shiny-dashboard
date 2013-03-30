library(Coldbir)
library(rHighcharts)
library(data.table)

# Load data into memory
.data_source <- "~/Desktop/prodstat/"
.db <- cdb(.data_source, type = "f")
.data <- data.table(
    arendeid = .db["arendeid"],
    process = .db["process"],
    processtyp = .db["processtyp"],
    arendetyp = .db["arendetyp"],
    klassificering = .db["klassificering"],
    startdatum = .db["startdatum"],
    slutdatum = .db["slutdatum"]
)
    
shinyServer(function(input, output) {
    
    # Reactive dataset
    data <- reactive({
        .data[process == input$process]
    })
    
    output$process <- renderUI({
        selectInput("process", label = get_doc(.db, "process")$title, choices = unique(.data$process))
    })
    
    output$arendetyp <- renderUI({
        selectInput("arendetyp", label = get_doc(.db, "arendetyp")$title, choices = unique(data()$arendetyp), multiple = TRUE)
    })

    output$freq <- renderChart({
        
        # Bearbetning av data
        data <- .data[process == "Ålderspension"]
        data[ , startar := year(startdatum)]  # skapa kolumn för startår
        data[ , slutar := year(slutdatum)]  # skapa kolumn för slutår
        
        # Beräkna antalet startade ärenden per år
        started <- data[ , .N, by = startar]
        setnames(started,'startar','year')
        
        # Beräkna antalet avslutade ärenden per år
        ended <- data[!is.na(slutar)][ , .N, by = slutar]  # ta inte med pågående ärenden
        setnames(ended,'slutar','year')

        # Beräkna frekvens av netto
        freq <- merge(started, ended, by = "year", suffixes = c(".started", ".ended"), all = TRUE)
        freq[ , N.change := ifelse(is.na(N.ended), NA, N.started - N.ended)]
        
        # Beräkna antalet pågående ärenden per år
        freq[ , N.ongoing := cumsum(N.change)]
        
        # Skapa graf
        a <- rHighcharts:::Chart$new()
        a$title(text = "In- och utflöde")
        
        a$data(x = freq$year, y = freq$N.ongoing, type = "area", name = "Pågående")
        a$data(x = freq$year, y = freq$N.started, type = "column", name = "Inkomna")
        a$data(x = freq$year, y = freq$N.ended, type = "column", name = "Avslutade")
        a$data(x = freq$year, y = freq$N.change, type = "line", name = "+/-")
        
        return(a)
    })
    
    output$fruits <- renderChart({
        a <- rHighcharts:::Chart$new()
        a$title(text = "Fruits")
        a$data(x = c("Apples","Bananas","Oranges"), y = c(15, 20, 30), type = "pie", name = "Amount")
        a
    })
    
    output$us <- renderChart({
        x <- as.data.frame(t(USPersonalExpenditure))
        a <- rHighcharts:::Chart$new()
        a$chart(type = "bar")
        a$plotOptions(column = list(stacking = "normal"))
        a$xAxis(categories = rownames(x))
        a$title(text = "US Personal Expenditure")
        a$yAxis(title = list(text = "US dollars"))
        a$data(x)
        a
    })

})
