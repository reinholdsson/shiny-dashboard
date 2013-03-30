require(markdown)
require(data.table)
require(ggplot2)
require(ggthemes)
require(googleVis)

shinyServer(function(input, output) {
    
    variable <- reactive({

        if(is.null(input$dims)) {
            i <- 1
        } else {
            i <- as.integer(input$dims)
        }
        
        sel <- d[[input$variable]][[i]]
        
        db[input$variable, sel]
    })
    
    output$dims <- renderUI({
        
        # If missing input, return to avoid error later in function
        if(is.null(input$variable))
            return()
        
        # Get available dims
        dims <- get_dims(db, input$variable)
        
        # Prepare choices (index number)
        index <- 1:length(dims)
        names(index) <- sapply(dims, function(x) { paste(x, collapse = "/") })
        names(index)[names(index) == ""] <- "None"

        radioButtons("dims", label = "Dimensions", choices = index)
    })
    
    output$table <- renderGvis({
        x <- variable()
        
        if (is.factor(x)) {
            x <- summary(x)
            x <- data.frame("Variable" = names(x), "N" = x)
        } else {
            stats <- c(
                "N" = length(x),
                "Min" = min(x, na.rm = TRUE), 
                "Median" = median(x, na.rm = TRUE), 
                "Mean" = mean(x, na.rm = TRUE), 
                "Max" = max(x, na.rm = TRUE),
                "Sd" = sd(x, na.rm = TRUE),
                "NA's" = length(x[is.na(x)])
            )
            x <- data.frame("Measure" = names(stats), "Value" = stats)
        }
        gvisTable(x, options = list(width = "100%", page = "enable", height = "300px"))
    })
    
    output$charts <- renderPlot({

        x <- variable()

        if (is.factor(x)) {
            x <- table(x)
            x <- as.data.frame(x)
            #x <- x[with(x, order(-Freq)), ]
            #x <- head(x, 10)
            
            #p <- ggplot(x) + geom_point(aes(x = reorder(x, Freq), y = Freq)) + labs(title = "Frequency")
            p <- ggplot(x) + geom_point(aes(x = x, y = Freq)) + labs(title = "Frequency")
        } else {
            
            # Sample for large vectors
            if (length(x) > 100000) {
                x <- sample(x, 100000)
            }
            
            x <- data.table(x = x)
            p <- ggplot(x) + geom_density(aes(x = x), fill = "lightblue") + labs(title = "Density")
        }

        p <- p + xlab(NULL) + ylab(NULL) + theme_tufte() + theme(legend.position="none")
        print(p)
    })
    
    output$docs <- renderText({
        markdown::markdownToHTML(text = list_to_md(get_doc(db, input$variable)), fragment.only = TRUE)
    })

})
