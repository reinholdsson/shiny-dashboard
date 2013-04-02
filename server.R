# Server application
shinyServer(function(input, output) {
    
    # Reactive text
    output$title <- renderText({
        paste(input$process, input$year, sep = ", ")
    })
    
    output$text <- renderText({
        "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged."
    })
    
    output$text2 <- renderText({
        paste("Key indicators", input$year)
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
        a$title(text = "In- och outflow")
        a$subtitle(text = "Started and ended cases")
        a$xAxis(categories = data$month)
        a$yAxis(title = list(text = "Number of cases"))
        
        a$data(x = data$month, y = data$N.ongoing, type = "column", name = "Ongoing")
        a$data(x = data$month, y = data$N.started, type = "column", name = "Started")
        a$data(x = data$month, y = data$N.ended, type = "column", name = "Ended")
        a$data(x = data$month, y = data$N.change, type = "line", name = "+/-")
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
        data <- data[, list(sum(days, na.rm = TRUE), .N), by = list(year(slutdatum), month(slutdatum))]
        data[ , mean := V1/N]
        
        data <- data[order(year, month)]  # sortera
        
        # Beräkna aggregerade summor
        data[ , N_sum := cumsum(N)]
        data[ , V1_sum := cumsum(as.integer(V1))]
        data[ , mean_sum := V1_sum/N_sum]

        # Beräkna handläggningstid för pågående ärenden (mer komplext!)
        
        ## Begränsa data till avslutade under året samt 
        ongoing <- data()[is.na(slutdatum) | year(slutdatum) == input$year]
        
        ## Beräkna hltid för pågende ärenden per månad (för den sista dagen i respektive månad)
        ### TODO: Nedan behöver dubbelkollas
        ### (Denna är väldigt långsam!!)
        ongoing_months <- 1:12
        ongoing_times <- sapply(ongoing_months, function(m) {

            # Ange vald månads sista dag
            m_last_date <- as.Date(paste(input$year, m, days_in_month(m), sep = "-"))
            
            # Hämta ärenden som avslutats efter angiven månad, eller är NA
            d <- ongoing[as.Date(startdatum) <= m_last_date & (month(slutdatum) > m | is.na(slutdatum))]

            # Beräkna handläggningstid
            d[ , days := m_last_date - as.Date(startdatum)]
            d <- d[, mean(days, na.rm = TRUE)]
            return(d)
        })
        
        # Skapa dataset för respektive typ
        ended <- data
        ongoing <- data.table(
            year = input$year,
            month = ongoing_months,
            V1 = ongoing_times)
        
        # Slå samman
        times <- merge(
            ended,
            ongoing,
            by = "month", all = TRUE, suffixes = c(".ended", ".ongoing"))
            
        # Replace month with labels
        times$month <- .months[times$month]

        # Skapa graf
        a <- rHighcharts:::Chart$new()
        a$title(text = "Processing time")
        a$subtitle(text = "Ongoing and ended cases")
        a$xAxis(categories = times$month)
        a$yAxis(title = list(text = "Days"))

        a$data(x = times$month, y = as.double(times$mean), type = "column", name = "Ended")
        a$data(x = times$month, y = times$mean_sum, type = "line", name = "Ended (aggregated)")
        a$data(x = times$month, y = times$V1.ongoing, type = "line", name = "Ongoing")

        return(a)
    })
    
    output$types <- renderChart({
        
        data <- data()[year(slutdatum) == input$year]
        data <- data[ , .N, by = arendetyp]
        data <- data[order(N, decreasing = TRUE)]
        
        # Skapa graf
        a <- rHighcharts:::Chart$new()
        a$title(text = "Type of cases")
        a$subtitle(text = "Ended cases")
        a$data(x = data$arendetyp, y = data$N, type = "pie", name = "Amount", size = 150)
        return(a)
    })
    
    output$summary <- renderText({
        
        data <- data()[year(slutdatum) == input$year]
        days <- data$slutdatum - data$startdatum

        stats <- c(
            "Ended cases, amount" = nrow(data),
            "Started cases, amount" = nrow(data()[year(startdatum) == input$year]),
            "Ongoing cases, amount at 31/12" = nrow(data()[year(startdatum) <= input$year & (is.na(slutdatum) | year(slutdatum) > input$year)]),
            "Processing time, mean days" = round(mean(days)),
            "Processing turnover time, median days" = round(median(days))
            )
        x <- data.frame("Key" = names(stats), "Value" = stats)
        hwrite(x, row.names=FALSE, col.names=FALSE, width = "75%")
    })
    
})
