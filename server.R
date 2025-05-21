#server.R (Optimized Version)

source("global.R")
source("heatmap.R")

data_cache <- reactiveVal(list(name = NULL, df = NULL))
label_map <- reactiveVal(NULL)

# Helpers
get_gene_labels <- function(df, use_name = FALSE) {
  if (use_name && "GeneName" %in% colnames(df) && !all(is.na(df$GeneName))) {
    return(df$GeneName)
  } else if ("GeneID" %in% colnames(df)) {
    return(df$GeneID)
  } else {
    return(rownames(df))
  }
}

normalize_categories <- function(vec) {
  vec[vec == ""] <- NA
  vec[is.na(vec)] <- "Other"
  return(as.character(vec))
}

process_matrix <- function(df, input) {
  if (input$matrix_type == "Reduced Matrix") {
    df <- reduce_matrix(df, input$matrix_size)
  } else if (input$matrix_type == "Top N Genes") {
    df <- filter_top_genes(df, input$top_n_genes)
  }
  if (input$filter_mode != "None") {
    df <- filter_matrix_by_mode(df, input)
  }
  return(df)
}

reduce_matrix <- function(df, target_size) {
  if (nrow(df) <= target_size) return(df)
  step <- ceiling(nrow(df) / target_size)
  idx <- seq(1, nrow(df), by = step)
  df_reduced <- df[idx, , drop = FALSE]
  numeric_cols <- !(colnames(df) %in% c("GeneID", "category", "GeneName"))
  mat_reduced <- df_reduced[, numeric_cols, drop = FALSE][, idx, drop = FALSE]
  cbind(df_reduced[, intersect(c("GeneID", "category", "GeneName"), colnames(df)), drop = FALSE], mat_reduced)
}

filter_matrix_by_mode <- function(df, input) {
  numeric_cols <- !(colnames(df) %in% c("GeneID", "category", "GeneName"))
  mat <- as.matrix(df[, numeric_cols, drop = FALSE])
  filtered_mat <- mat
  range <- if (input$filter_mode == "Inside Range") input$inside_range else input$outside_range
  if (input$filter_mode == "Inside Range") {
    filtered_mat[mat < range[1] | mat > range[2]] <- 0
  } else if (input$filter_mode == "Outside Range") {
    filtered_mat[mat >= range[1] & mat <= range[2]] <- 0
  }
  keep <- which(rowSums(abs(filtered_mat)) > 0)
  if (length(keep) < 2) return(NULL)
  df_filtered <- df[keep, , drop = FALSE]
  filtered_mat <- filtered_mat[keep, keep, drop = FALSE]
  cbind(df_filtered[, intersect(c("GeneID", "category", "GeneName"), colnames(df)), drop = FALSE], filtered_mat)
}

filter_top_genes <- function(df, top_n) {
  numeric_cols <- !(colnames(df) %in% c("GeneID", "category", "GeneName"))
  mat <- as.matrix(df[, numeric_cols, drop = FALSE])
  gene_scores <- rowSums(abs(mat))
  top_indices <- order(gene_scores, decreasing = TRUE)[1:min(top_n, nrow(mat))]
  df_top <- df[top_indices, , drop = FALSE]
  mat_top <- mat[top_indices, top_indices, drop = FALSE]
  cbind(df_top[, intersect(c("GeneID", "category", "GeneName"), colnames(df)), drop = FALSE], mat_top)
}

server <- function(input, output, session) {
  data <- reactiveVal()
  heatmap_obj <- reactiveVal()
  
  observeEvent(input$file, {
    updateSelectInput(session, "highlight_category", choices = NULL, selected = "Top5")
    updateRadioButtons(session, "matrix_type", selected = "Full Matrix")
    updateRadioButtons(session, "filter_mode", selected = "None")
    updateNumericInput(session, "matrix_size", value = 50)
    updateNumericInput(session, "top_n_genes", value = 100)
    updateSliderInput(session, "inside_range", value = c(-0.5, 0.5))
    updateSliderInput(session, "outside_range", value = c(-0.5, 0.5))
  })
  
  observeEvent(input$submit, {
    req(input$file)
    showNotification("Loading data...", duration = NULL, id = "load_msg")
    
    df <- if (!is.null(data_cache()$name) && identical(data_cache()$name, input$file)) {
      data_cache()$df
    } else {
      df <- readRDS(file_paths[[input$file]])
      data_cache(list(name = input$file, df = df))
      df
    }
    
    df <- process_matrix(df, input)
    if (is.null(df)) {
      showNotification("No genes left after filtering.", type = "error")
      removeNotification("load_msg")
      return()
    }
    
    gene_labels <- get_gene_labels(df, input$label_type == "GeneName")
    if (input$label_type == "GeneName" && "GeneName" %in% colnames(df)) {
      label_map(setNames(df$GeneID, df$GeneName))
    } else {
      label_map(NULL)
    }
    
    mat <- as.matrix(df[, !(colnames(df) %in% c("GeneID", "category", "GeneName"))])
    rownames(mat) <- gene_labels
    colnames(mat) <- gene_labels
    
    if ("category" %in% colnames(df)) {
      row_categories_full <- normalize_categories(setNames(df$category, gene_labels))
      highlight_category <- input$highlight_category
      cat_counts <- sort(table(row_categories_full), decreasing = TRUE)
      top_categories <- names(cat_counts)[1:5]
      row_categories_grouped <- ifelse(row_categories_full %in% top_categories, row_categories_full, "Other")
      if (highlight_category != "Top5") row_categories_grouped <- row_categories_full
      
      category_choices <- c("Top 5 Categories" = "Top5",
                            setNames(names(cat_counts), paste0(names(cat_counts), " (", cat_counts, ")")))
      updateSelectInput(session, "highlight_category", choices = category_choices, selected = highlight_category)
    } else {
      row_categories_full <- NULL
      row_categories_grouped <- NULL
      updateSelectInput(session, "highlight_category", choices = NULL, selected = "Top5")
    }
    
    data(list(
      mat = mat,
      row_categories = row_categories_grouped,
      row_categories_full = row_categories_full,
      top_categories = if (exists("top_categories")) top_categories else character(0)
    ))
    
    ht <- if (!is.null(row_categories_grouped)) {
      create_heatmap(mat, row_categories_grouped, if (highlight_category == "Top5") NULL else highlight_category)
    } else {
      create_heatmap(mat)
    }
    heatmap_obj(ht)
    removeNotification("load_msg")
  })
  
  observeEvent(heatmap_obj(), {
    ht <- draw(heatmap_obj(), test = FALSE)
    makeInteractiveComplexHeatmap(
      input, output, session, ht,
      heatmap_id = "heatmap_output",
      hover_action = function(df, input, output, session) {
        d <- data()
        mat <- d$mat
        row_categories <- d$row_categories
        idmap <- label_map()
        
        get_original <- function(label) {
          if (!is.null(idmap) && label %in% names(idmap)) {
            return(idmap[[label]])
          }
          return("")
        }
        
        if (!is.null(df)) {
          value <- round(mat[df$row_index, df$column_index], 3)
          row_lbl <- df$row_label
          col_lbl <- df$column_label
          orig_row <- get_original(row_lbl)
          orig_col <- get_original(col_lbl)
          
          label_fmt <- function(lbl, orig) {
            if (orig != "" && orig != lbl) paste0(lbl, " (", orig, ")") else lbl
          }
          
          category <- if (!is.null(row_categories)) row_categories[as.character(row_lbl)] else "—"
          
          msg <- paste0(
            "Row: ", label_fmt(row_lbl, orig_row), "\n",
            "Column: ", label_fmt(col_lbl, orig_col), "\n",
            "Value: ", value, "\n",
            "Category: ", category
          )
          
          shinyjs::runjs(sprintf(
            "document.getElementById('heatmap_tooltip').innerText = `%s`; document.getElementById('heatmap_tooltip').style.display = 'block';",
            gsub("`", "\\`", msg)
          ))
        } else {
          shinyjs::runjs("document.getElementById('heatmap_tooltip').style.display = 'none';")
        }
      },
      brush_action = function(df, input, output, session) {
        d <- data()
        mat <- d$mat
        row_categories <- d$row_categories
        selected_rows <- rownames(mat)[unique(unlist(df$row_index))]
        selected_cols <- colnames(mat)[unique(unlist(df$column_index))]
        
        selected_data <- mat[selected_rows, selected_cols, drop = FALSE]
        
        output$selected_table <- DT::renderDT({
          rownames(selected_data) <- selected_rows
          colnames(selected_data) <- selected_cols
          datatable(
            round(selected_data, 3),
            options = list(pageLength = 5, scrollX = TRUE)
          )
        })
        
        output$sub_heatmaply <- renderPlotly({
          if (nrow(selected_data) == 0 || ncol(selected_data) == 0) {
            return(NULL)
          }
          
          plot_data <- as.data.frame(as.table(selected_data))
          if (ncol(plot_data) >= 3) {
            colnames(plot_data)[1:3] <- c("Row", "Column", "Value")
          }
          
          plot_data$Value <- suppressWarnings(as.numeric(plot_data$Value))
          plot_data$Value[is.na(plot_data$Value)] <- 0
          
          plot_data$Category <- if (!is.null(row_categories)) row_categories[as.character(plot_data$Row)] else "Uncategorized"
          if (nrow(plot_data) == 0) return(NULL)
          
          plot_data$text <- paste0(
            "Row: ", plot_data$Row,
            "<br>Column: ", plot_data$Column,
            "<br>Value: ", round(plot_data$Value, 3),
            "<br>Category: ", plot_data$Category
          )
          
          text_matrix <- reshape2::acast(plot_data, Row ~ Column, value.var = "text")
          
          heatmaply(
            selected_data,
            text_matrix = text_matrix,
            colors = colorRampPalette(c("blue", "white", "red"))(256),
            limits = c(-1, 1),
            dendrogram = "none",
            Rowv = NULL,
            Colv = NULL,
            showticklabels = c(TRUE, TRUE),
            labRow = rownames(selected_data),
            labCol = colnames(selected_data),
            hide_colorbar = TRUE,
            fontsize_row = 8,
            fontsize_col = 8,
            plot_method = "plotly"
          ) %>% layout(margin = list(t = 5, b = 5, l = 5, r = 5), xaxis = list(tickangle = 270))
        })
        
        seurat_file <- seurat_paths[[input$file]]
        idmap <- label_map()
        valid_genes <- selected_rows
        display_labels <- selected_rows
        if (!is.null(idmap)) {
          valid_genes <- idmap[intersect(names(idmap), selected_rows)]
          display_labels <- names(valid_genes)
        }
        
        output$dotplot <- renderPlot({
          if (!is.null(seurat_file) && file.exists(seurat_file)) {
            seurat_obj <- readRDS(seurat_file)
            seurat_features <- rownames(seurat_obj)
            valid_genes <- intersect(valid_genes, seurat_features)
            
            if (length(valid_genes) > 0) {
              DotPlot(seurat_obj, features = valid_genes) +
                scale_color_gradient(low = "blue", high = "red") +
                scale_x_discrete(labels = display_labels) +
                theme_minimal() +
                theme(axis.text.x = element_text(angle = 90, hjust = 1))
            } else {
              ggplot() + annotate("text", x = 0.5, y = 0.5, label = "No valid genes for Seurat DotPlot", size = 6) + theme_void()
            }
          } else {
            ggplot() + annotate("text", x = 0.5, y = 0.5, label = "No Seurat object found for this dataset", size = 6) + theme_void()
          }
        })
      }
    )
  })
}
