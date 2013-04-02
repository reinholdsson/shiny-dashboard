shinyUI(bootstrapPage(

    # Add custom CSS
    tagList(
        tags$head(
            tags$title("Shiny Dashboard Example"),
            tags$link(rel="stylesheet", type="text/css",
                      href="style.css")
        )
    ),
    
    div(class="row",
        div(class="span2",
            selectInput("year", label = "Year", choices = .years, selected = max(.years))
        ),
        div(class="span2",
            selectInput("process", label = "Process", choices = .processes)
        )
    ),
    
    HTML("<hr>"),
    
    conditionalPanel(
        condition = "input.process",
        
        div(class="row",
            div(class="span6",
                chartOutput("flow")
            ),
            div(class="span6",
                chartOutput("days")
            )
        ),
        div(class="row",
            div(class="span6",
                chartOutput("types")
            ),
            div(class="span6",
                textOutput("text"),
                br(),
                strong(textOutput("text2")),
                htmlOutput("summary")
            )
        )
    ),
    
    HTML("<hr>"),
    HTML("Shiny Dashboard Example (<a href=\"https://github.com/reinholdsson/shiny-dashboard\">source code</a>) by Thomas Reinholdsson. For Highcharts in R, see <a href=\"https://github.com/metagraf/rHighcharts\">https://github.com/metagraf/rHighcharts</a>.")
    
))
