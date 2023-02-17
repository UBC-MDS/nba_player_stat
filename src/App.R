library(shiny)

ui <- fluidPage(
  sliderInput(inputId='slider',
              label='I am a label',
              min=0,
              max=10,
              value=5 ),
  plotOutput(outputId = 'distplot')
)

server <- function(input, output, session) {
  
  output$distplot <-  renderPlot({
    
    # generate bins 
    x    <- faithful[, 2]
    bins <- seq(min(x), max(x), length.out = input$slider + 1)
    
    # draw the histogram with the specified number of bins
    hist(x, breaks = bins, col = 'darkgray', border = 'white',
         xlab = 'Waiting time to next eruption (in mins)',
         main = 'Histogram of waiting times')
  })
}

shinyApp(ui, server)