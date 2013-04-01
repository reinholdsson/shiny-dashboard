shinyUI(bootstrapPage(
    
    # Add javascript files for rHighcharts
    chart_js(),
    
    # Add custom CSS
    tagList(
        tags$head(
            tags$title("Produktionsstatistik"),
            tags$link(rel="stylesheet", type="text/css",
                      href="style.css")
        )
    ),
    
    # Header panel
    div(class="row",
        div(class="span2",
            uiOutput("year")
        ),
        div(class="span2",
            uiOutput("process")
        )
    ),
    
    # Main panel
    #h3(textOutput("title")),
    div(class="row",
        div(class="span6",
            uiOutput("flow")
        ),
        div(class="span6",
            uiOutput("days")
        )
    ),
    div(class="row",
        div(class="span6",
            uiOutput("types")
        ),
        div(class="span6",
            h4("Sammanfattning"),
            textOutput("text"),
            br(),
            strong(textOutput("text2")),
            htmlOutput("summary")
        )
    )
    
))