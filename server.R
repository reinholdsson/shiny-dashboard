# Server application
shinyServer(function(input, output) {
    
    # Reactive text
    output$title <- renderText({
        paste(input$process, input$year)
    })
    
    # UI controls    
    output$process <- renderUI({
        processes <- sort(unique(.data$process), na.last = TRUE)
        selectInput("process", label = "Process", choices = processes)
    })
    
    output$year <- renderUI({
        years <- sort(unique(c(year(.data$startdatum), year(.data$slutdatum))))  # borttaget: na.last = TRUE
        selectInput("year", label = "År", choices = years, selected = max(years))
    })
    
    # Data
    data <- reactive({
        .data[
            process %in% input$process
            ]
    })
    
    # Charts
    output$flow <- renderChart({
        
        # Load data
        data <- data()
        
        # Calculate frequencies
        data <- merge(
            data[ , .N, by = list(year(startdatum), month(startdatum))],  # started
            data[!is.na(slutdatum)][ , .N, by = list(year(slutdatum), month(slutdatum))],  # ended (excl. ongoing)
            by = c("year", "month"), 
            suffixes = c(".started", ".ended"), 
            all = TRUE
        )
        data[ , N.change := sum(N.started, -N.ended, na.rm = TRUE), by=1:NROW(data)]  # net change
        data[ , N.ongoing := cumsum(N.change)]  # ongoing
        
        # Cut data on the last year (move this?)
        data <- data[year == input$year]
        data[ , N.started_sum := cumsum(N.started)]  # sum started
        data[ , N.ended_sum := cumsum(N.ended)]  # sum ended

        # Replace month with labels
        data[ , month := .months[data$month]]
        
        # Skapa graf
        a <- rHighcharts:::Chart$new()
        a$title(text = "In- och utflöde")
        a$subtitle(text = "Inkomna och avslutade ärenden")
        a$xAxis(categories = data$month)
        a$yAxis(title = list(text = "Antal ärenden"))
        
        a$data(x = data$month, y = data$N.ongoing, type = "column", name = "Pågående")
        a$data(x = data$month, y = data$N.started, type = "line", name = "Inkomna")
        a$data(x = data$month, y = data$N.started_sum, type = "line", name = "Inkomna (aggregerat)")
        a$data(x = data$month, y = data$N.ended, type = "line", name = "Avslutade")
        a$data(x = data$month, y = data$N.ended_sum, type = "line", name = "Avslutade (aggregerat)")
        a$data(x = data$month, y = data$N.change, type = "column", name = "+/-")
        
        return(a)
    })
    
    output$days <- renderChart({
        
        # Ladda data
        data <- data()
        
        # Begränsa data till ärenden som avslutads valt år
        data <- data[year(slutdatum) == input$year]

        # Beräkna handläggningstid för avslutade ärenden
        data[ , days := as.Date(slutdatum) - as.Date(startdatum)]
        
        # Beräkna medel handläggningstid per år och månad
        data <- data[, mean(days, na.rm = TRUE), by = list(year(slutdatum), month(slutdatum))]
        data <- data[order(year, month)]  # sortera
        
        # Replace month with labels
        data[ , month := .months[data$month]]

        # Skapa graf
        a <- rHighcharts:::Chart$new()
        a$title(text = "Handläggningstid")
        a$subtitle(text = "Avslutade ärenden")
        a$xAxis(categories = data$month)
        a$yAxis(title = list(text = "Dagar"))
        
        a$data(x = data$month, y = data$V1, type = "column", name = "Handläggningstid")
        
        return(a)
    })
    
})