
# Conditional ui control
cond_ui <- function(cond, ui) {
    conditionalPanel(
        condition = paste("input", cond, sep = "."),
        uiOutput(ui)
    )   
}

m_title <- function(variable) {
    h3(get_doc(.db, variable)$title)
}

m_desc <- function(variable) {
    helpText(get_doc(.db, variable)$description)
}

shinyUI(bootstrapPage(
    
    # Add JavaScript files
    chart_js(),  # rHighcharts
    
    # Add custom CSS
    tagList(
        tags$head(
            tags$title("Produktionsstatistik"),
            tags$link(rel="stylesheet", type="text/css",
                      href="style.css")
        )
    ),

    div(class="row",

        # Left panel
        div(class="span3",
            
            # Mått
            h3("Mått"),
            helpText("Välj lämpligt mått"),
            selectInput("measure", label = "", choices = c(
                "Antal ärenden" = 1, "Handläggningstid" = 2)),
            
            # Process
            m_title("process"),
            m_desc("process"),
            cond_ui("measure", "process"),
            
            # Ärendetyp
            m_title("arendetyp"),
            m_desc("arendetyp"),
            cond_ui("process", "arendetyp")
            
        ),
        
        # Main panel
        div(class="span8", 
            div(class="row",
                # Startdatum
                div(class="span1", uiOutput("startyear")),
                div(class="span3", uiOutput("startmonth")),
                
                # Slutdatum
                div(class="span1", uiOutput("endyear")),
                div(class="span3", uiOutput("endmonth"))
            ),
            conditionalPanel(
                condition = "input.measure == 1",
                htmlOutput("frequency_chart")
            ),
            htmlOutput("us")
        )
    )
    
))
