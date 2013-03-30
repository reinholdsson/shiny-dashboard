
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
    
    ### DATA PROCESSING ###

    # Reactive dataset
    pre_data <- reactive({
        
        # Ta hand om NA värden för slutdatum!
        if (TRUE) {
            endyear <- c(input$endyear, NA)
            endmonth <- c(input$endmonth, NA)
        } else {
            endyear <- input$endyear
            endmonth <- input$endmonth
        }
        
        data <- .data[
            process %in% input$process
            & year(startdatum) %in% input$startyear
            & month(startdatum) %in% input$startmonth
            & year(slutdatum) %in% endyear
            & month(slutdatum) %in% endmonth
            ]
        
    })
    
    data <- reactive({
        
        types <- input$arendetyp
        types[types == ""] <- NA  # fix för att få med NA-värden
        
        pre_data()[arendetyp %in% types]
    })
    
    time_table <- reactive({
        
        # Ladda data
        data <- data()
        
        # Beräkna handläggningstid per ärende
        data[ , hltid := as.Date(slutdatum) - as.Date(startdatum)]
        
        # Beräkna medel handläggningstid per år och månad
        data <- data[!is.na(slutdatum)][, mean(hltid, na.rm = TRUE), by = list(year(slutdatum), month(slutdatum))]
        
        data[, ym := paste(year, month, sep = "")]
        
        return(data)
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
    
    
    ### UI ###
    
    output$process <- renderUI({
        processes <- sort(unique(.data$process), na.last = TRUE)
        selectInput("process", label = "", choices = processes, selected = processes[1], multiple = TRUE)
    })
    
    output$arendetyp <- renderUI({
        types <- sort(unique(pre_data()$arendetyp), na.last = TRUE)
        selectInput("arendetyp", label = "", choices = types, selected = types, multiple = TRUE)
    })
    
    output$startyear <- renderUI({
        years <- year(min(.data$startdatum, na.rm = TRUE)):year(max(.data$startdatum, na.rm = TRUE))
        checkboxGroupInput("startyear", label = "Startår:", choices = years, selected = years[length(years)])
    })
    
    output$startmonth <- renderUI({
        selectInput("startmonth", label = "Startmånad:", choices = .months, selected = names(.months), multiple = TRUE)
    })
    
    output$startmissing <- renderUI({
        checkboxInput("startmissing", label = "Include NA", value = TRUE)
    })
    
    output$endyear <- renderUI({
        years <- year(min(.data$slutdatum, na.rm = TRUE)):year(max(.data$slutdatum, na.rm = TRUE))
        checkboxGroupInput("endyear", label = "Slutår:", choices = years, selected = years[length(years)])
    })
    
    output$endmonth <- renderUI({
        selectInput("endmonth", label = "Slutmånad:", choices = .months, selected = names(.months), multiple = TRUE)
    })
    
    output$endmissing <- renderUI({
        checkboxInput("endmissing", label = "Include NA", value = TRUE)
    })
    
    
    ### CHARTS ###
    
    output$frequency_chart <- renderChart({
        
        data <- frequency_table()

        # Skapa graf
        a <- rHighcharts:::Chart$new()
        a$title(text = "In- och utflöde")
        a$xAxis(categories = data$ym, tickInterval = 6)
        a$yAxis(title = list(text = "Antal ärenden"))
        
        a$data(x = data$ym, y = data$N.ongoing, type = "column", name = "Pågående")
        a$data(x = data$ym, y = data$N.started, type = "line", name = "Inkomna")
        a$data(x = data$ym, y = data$N.ended, type = "line", name = "Avslutade")
        a$data(x = data$ym, y = data$N.change, type = "column", name = "+/-")
        
        return(a)
    })
    
    output$time_chart <- renderChart({
        
        data <- time_table()
        
        # Skapa graf
        a <- rHighcharts:::Chart$new()
        a$title(text = "Handläggningstid")
        a$xAxis(categories = data$ym, tickInterval = 6)
        a$yAxis(title = list(text = "Dagar"))
        
        a$data(x = data$ym, y = data$V1, type = "column", name = "Handläggningstid")
        
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
