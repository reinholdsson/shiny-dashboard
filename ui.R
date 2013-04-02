shinyUI(bootstrapPage(
    
    # Add javascript files for rHighcharts
    chart_js(),
    
    # Add custom CSS
    tagList(
        tags$head(
            tags$title("rHighcharts Dashboard Example"),
            tags$link(rel="stylesheet", type="text/css",
                      href="style.css")
        )
    ),
    
    # Header panel
    div(class="row",
        div(class="span2",
            selectInput("year", label = "Year", choices = .years, selected = max(.years))
        ),
        div(class="span2",
            selectInput("process", label = "Process", choices = .processes)
        )
    ),
    
    conditionalPanel(
        condition = "input.process",
        # Main panel
        #h3(textOutput("title")),
        div(class="row",
            div(class="span6",
                htmlOutput("flow")
            ),
            div(class="span6",
                htmlOutput("days")
            )
        ),
        div(class="row",
            div(class="span6",
                htmlOutput("types")
            ),
            div(class="span6",
                textOutput("text"),
                br(),
                strong(textOutput("text2")),
                htmlOutput("summary")
            )
        )
    )
))
