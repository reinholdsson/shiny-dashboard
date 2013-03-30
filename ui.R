library(rHighcharts)

# Conditional ui control
cond_ui <- function(cond, ui) {
    conditionalPanel(
        condition = paste("input", cond, sep = "."),
        uiOutput(ui)
    )   
}

shinyUI(bootstrapPage(
    sidebarPanel(
        selectInput("measure", label = "Mått", choices = c(
            "Antal ärenden" = 1, "Handläggningstid" = 2)),
        cond_ui("measure", "process"),
        cond_ui("process", "arendetyp")
    ),
    mainPanel(
        chart_js(),
        conditionalPanel(
            condition = "input.measure == 1",
            htmlOutput("freq")
        ),
        
        htmlOutput("us")
    )
))
