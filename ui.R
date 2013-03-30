
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
        div(class="span3",
            # Startdatum
            m_title("startdatum"),
            uiOutput("startyear"),
            uiOutput("startmonth"),
            m_desc("startdatum"),
            
            # Slutdatum
            m_title("slutdatum"),
            uiOutput("endyear"),
            uiOutput("endmonth"),
            m_desc("startdatum")
        ),
        
        div(class="span10", 
            div(class="row",
                div(class="span3",
                    h3("Mått"),
                    selectInput("measure", label = "", choices = c(
                        "Antal ärenden" = 1, "Handläggningstid" = 2)),
                    helpText("Välj lämpligt mått")
                    
                ),
                div(class="span3",
                    m_title("process"),
                    cond_ui("measure", "process"),
                    m_desc("process")
                ),
                div(class="span3",
                    m_title("arendetyp"),
                    cond_ui("process", "arendetyp"),
                    m_desc("arendetyp")
                ),
    
                div(class="row",
                    conditionalPanel(
                        condition = "input.measure == 1",
                        htmlOutput("frequency_chart")
                    ),
                    htmlOutput("us")
                )
            )
        )
    )
))
