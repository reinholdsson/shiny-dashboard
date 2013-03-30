
# Load data into memory
.data <- data.table(
    arendeid = .db["arendeid"],
    process = .db["process"],
    processtyp = .db["processtyp"],
    arendetyp = .db["arendetyp"],
    klassificering = .db["klassificering"],
    startdatum = .db["startdatum"],
    slutdatum = .db["slutdatum"]
)

# Server application
shinyServer(function(input, output) {
    
    # Reactive dataset
    data <- reactive({
        .data[
            process %in% input$process
            & year(startdatum) %in% input$startyear
            & month(startdatum) %in% input$startmonth
            & year(slutdatum) %in% input$endyear
            & month(slutdatum) %in% input$endmonth
            ]
    })
    
    output$process <- renderUI({
        processes <- unique(.data$process)
        selectInput("process", label = "", choices = processes, selected = processes[1], multiple = TRUE)
    })
    
    output$arendetyp <- renderUI({
        selectInput("arendetyp", label = "", choices = unique(data()$arendetyp), multiple = TRUE)
    })
    
    output$startyear <- renderUI({
        years <- year(min(.data$startdatum, na.rm = TRUE)):year(max(.data$startdatum, na.rm = TRUE))
        selectInput("startyear", label = "", choices = years, selected = years[length(years)], multiple = TRUE)
    })
    
    output$startmonth <- renderUI({
        selectInput("startmonth", label = "", choices = .months, selected = names(.months), multiple = TRUE)
    })
    
    output$endyear <- renderUI({
        years <- year(min(.data$slutdatum, na.rm = TRUE)):year(max(.data$slutdatum, na.rm = TRUE))
        selectInput("endyear", label = "", choices = years, selected = years[length(years)], multiple = TRUE)
    })
    
    output$endmonth <- renderUI({
        selectInput("endmonth", label = "", choices = .months, selected = names(.months), multiple = TRUE)
    })
    
    frequency_table <- reactive({
        
        # Bearbetning av data
        data <- data()
        
        # Beräkna frekvenser
        freq <- merge(
            
            # Beräkna antalet startade ärenden per år och månad
            data[ , .N, by = list(year(startdatum), month(startdatum))], 
            
            # Beräkna antalet avslutade ärenden per år och månad
            data[!is.na(slutdatum)][ , .N, by = list(year(slutdatum), month(slutdatum))],  # exkludera pågående ärenden
            
            by = c("year", "month"), 
            suffixes = c(".started", ".ended"), 
            all = TRUE
        )
        
        # Beräkna nettoförändring
        freq[ , N.change := sum(N.started, -N.ended, na.rm = TRUE), by=1:NROW(freq)]
        
        # Beräkna antalet pågående ärenden per år och månad
        freq[ , N.ongoing := cumsum(N.change)]
        
        freq[, ym := paste(year, month, sep = "")]
    })

    output$frequency_chart <- renderChart({
        
        freq <- frequency_table()

        # Skapa graf
        a <- rHighcharts:::Chart$new()
        a$title(text = "In- och utflöde")
        a$xAxis(categories = freq$ym, tickInterval = 6)
        a$yAxis(title = list(text = "Antal ärenden"))
        
        a$data(x = freq$ym, y = freq$N.ongoing, type = "column", name = "Pågående")
        a$data(x = freq$ym, y = freq$N.started, type = "line", name = "Inkomna")
        a$data(x = freq$ym, y = freq$N.ended, type = "line", name = "Avslutade")
        a$data(x = freq$ym, y = freq$N.change, type = "column", name = "+/-")
        
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
