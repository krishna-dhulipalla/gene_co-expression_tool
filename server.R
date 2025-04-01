# server.R
source("global.R")
source("heatmap.R")

reduce_matrix <- function(mat, target_size) {
  if (nrow(mat) <= target_size) return(mat)
  step <- ceiling(nrow(mat)/target_size)
  idx <- seq(1, nrow(mat), by = step)
  mat[idx, idx, drop = FALSE]
}


server <- function(input, output, session) {
  data <- reactiveVal()
  
  observeEvent(input$submit, {
    req(input$file)
    showNotification("Loading data...", duration = NULL, id = "load_msg")
    
    df <- readRDS(file_paths[[input$file]])
    mat <- as.matrix(df[, -1])
    rownames(mat) <- df[[1]]
    
    if(input$matrix_type == "Reduced Matrix") {
      mat <- reduce_matrix(mat, input$matrix_size)
    }
    
    storage.mode(mat) <- "double"
    data(mat)
    removeNotification("load_msg")
  })
  
  heatmap_obj <- reactive({
    req(data())
    create_heatmap(data())
  })
  
  observeEvent(heatmap_obj(), {
    ht <- draw(heatmap_obj())
    makeInteractiveComplexHeatmap(
      input, output, session, ht,
      heatmap_id = "heatmap_output",
      hover = TRUE
    )
  })
  
  output$heatmap_hover <- renderUI({
    req(input$heatmap_output_hover)
    div(
      id = "heatmap_tooltip",
      # ... keep tooltip styling from original ...
      HTML(paste0(
        "<b>Row:</b> ", input$heatmap_output_hover$row_label, "<br>",
        "<b>Column:</b> ", input$heatmap_output_hover$column_label, "<br>",
        "<b>Value:</b> ", round(input$heatmap_output_hover$value, 3)
      ))
    )
  })
}