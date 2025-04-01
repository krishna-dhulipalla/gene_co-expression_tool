# ui.R
source("global.R")

header <- dashboardHeader(
  title = "Gene Co-Expression Analysis",
  titleWidth = 250
)

sidebar <- dashboardSidebar(
  width = 250,
  sidebarMenu(
    id = "tabs",
    menuItem("Home", tabName = "home", icon = icon("home")),
    menuItem("Heatmap", tabName = "heatmap", icon = icon("th"))
  ),
  
  conditionalPanel(
    condition = "input.tabs == 'heatmap'",
    selectInput("file", "Select Dataset", names(file_paths)),
    radioButtons("matrix_type", "Matrix Type:",
                 choices = c("Full Matrix", "Reduced Matrix"),
                 selected = "Full Matrix"),
    conditionalPanel(
      condition = "input.matrix_type == 'Reduced Matrix'",
      numericInput("matrix_size", "Submatrix Size", 
                   value = 50, min = 10, max = 10000, step = 50)
    ),
    actionButton("submit", "Generate Heatmap"),
    tags$hr()
  )
)

body <- dashboardBody(
  tags$head(
    tags$style(HTML("
    #heatmap_tooltip {
    pointer-events: none;
    position: fixed !important;  /* Changed from absolute to fixed */
    z-index: 9999;
    max-width: 300px;
    background: white;
    border: 1px solid #ddd;
    padding: 8px;
    border-radius: 4px;
    box-shadow: 0 2px 4px rgba(0,0,0,0.1);
    transform: translate(15px, 15px); /* Offset from cursor */
  }
      /* Add these new styles */
      .main-heatmap { 
        overflow: auto;
        position: relative;
        padding: 15px;
        margin: -15px; /* Counteract box padding */
      }
      
      /* Contain InteractiveComplexHeatmap controls */
      .control-ui-container {
        position: relative !important;
        z-index: 500;
        background: white;
        padding: 10px;
        border-bottom: 1px solid #eee;
      }
      
      /* Adjust control panel positioning */
      .control_panel {
        max-width: 100% !important;
        left: 15px !important;
        right: 15px !important;
        margin-top: 10px !important;
      }
      
      /* Style the buttons and inputs */
      .control_panel button, 
      .control_panel input {
        margin: 3px;
        padding: 5px 10px;
        font-size: 0.9em;
      }
      
      /* Existing styles with adjustments */
      .shiny-output-error { color: #ff4444; }
      .loading-message { 
        font-size: 18px; 
        padding: 20px; 
        text-align: center;
      }
      .box { 
        overflow: visible !important; 
        position: relative;
      }
      .box-body { 
        padding: 0 !important;
        overflow: hidden !important;
      }
      img{width:100%;}
    "))
  ),
  
  tabItems(
    tabItem(
      tabName = "home",
      fluidRow(
        box(
          width = 12,
          title = "Welcome to Gene Co-Expression Analysis",
          status = "primary",
          solidHeader = TRUE,
          tabBox(
            width = 12,
            tabPanel(
              "About",
              h3("Features:"),
              tags$ul(
                tags$li("Interactive heatmap exploration with zooming and value inspection"),
                tags$li("Multiple dataset support with different correlation metrics"),
                tags$li("Adjustable matrix sizes for optimal performance"),
                tags$li("Cluster analysis visualization")
              ),
              tags$img(src = "hero.png", height = "500px", width = "500px")
            ),
            tabPanel(
              "Datasets",
              h3("Available Datasets:"),
              div(class = "dataset-info",
                  h4("Arabidopsis Thaliana Leaf Datasets:"),
                  tags$ul(
                    tags$li(strong("ATH Leaf 2k Pearson:"), "2000 genes with Pearson correlations"),
                    tags$li(strong("ATH Leaf 2k Spearman:"), "2000 genes with Spearman correlations")
                  ),
                  h4("General Co-expression:"),
                  tags$ul(
                    tags$li(strong("Coexpression_all:"), "Full genome co-expression matrix"),
                    tags$li(strong("Coexpression_bulk:"), "Bulk tissue-specific co-expression")
                  )
              )
            ),
            tabPanel(
              "Quick Start",
              h3("Getting Started:"),
              tags$ol(
                tags$li("Navigate to the 'Heatmap' tab"),
                tags$li("Select a dataset from the dropdown"),
                tags$li("Choose matrix size (reduced for faster processing)"),
                tags$li("Click 'Generate Heatmap' to visualize"),
                tags$li("Use interactive features: hover, zoom, click")
              )
            )
          )
        )
      )
    ),
    
    tabItem(
      tabName = "heatmap",
      fluidRow(
        column(
          width = 12,
          box(
            width = 12, 
            status = "primary", 
            solidHeader = TRUE,
            div(class = "main-heatmap",
                withSpinner(
                  InteractiveComplexHeatmapOutput("heatmap_output"),
                  type = 4, 
                  color = "#0dc5c1", 
                  size = 2
                )
            )
          )
        )
      )
    )
  )
)

ui <- dashboardPage(header, sidebar, body)