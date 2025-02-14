library(shiny)
library(httr)
library(jsonlite)
library(glue)

source("prompts.R")

ui <- fluidPage(
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "styles.css")
  ),
  titlePanel("Social Media Post Generator"),
  sidebarLayout(
    sidebarPanel(
      textInput("github_link", "GitHub Markdown Link"),
      checkboxGroupInput("platforms", "Select Platforms", 
                         choices = c("LinkedIn", "Bluesky", "Mastodon"),
                         selected = c("LinkedIn", "Bluesky", "Mastodon")),
      selectInput("tone", "Select Tone", 
                  choices = c("Serious", "Playful", "Informative", "Casual"), selected = "Playful"),
      numericInput("n_gen", "Posts to Generate (per platform)", min = 1, max = 100, value = 3),
      checkboxInput("emojis", "Use Emojis?", TRUE),
      textInput("hashtags", "Hashtags to Include"),
      actionButton("generate", "Generate Posts")
    ),
    mainPanel(
      h4("Generated Posts"),
      textOutput("output_posts"),
    )
  )
)

server <- function(input, output) {
  
  output_text <- eventReactive(input$generate, {
    
    prompt <- get_prompt(
      input$github_link,
      input$platforms,
      input$n_gen,
      input$emojis,
      input$tone,
      input$hashtags
    )
    
    call_llm_api(prompt)
    
  })
  
  output$output_posts <- renderText({
    output_text()
  })
}

shinyApp(ui, server)
