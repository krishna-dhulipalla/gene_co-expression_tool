# Heatmap preparation and rendering logic --------------------------------------

#' Prepare heatmap data and metadata
prepare_heatmap_data <- function(input, df, session) {
  # Detect presence of metadata
  meta_cols <- intersect(c("GeneID", "category", "GeneName"), colnames(df))
  
  if (length(meta_cols) > 0) {
    # Case 1: Has explicit metadata columns
    meta <- df[, meta_cols, drop = FALSE]
    mat <- as.matrix(df[, !(colnames(df) %in% meta_cols), drop = FALSE])
    
    if ("GeneID" %in% meta_cols) {
      rownames(mat) <- meta$GeneID
      colnames(mat) <- meta$GeneID
    }
  } else {
    # Case 2: Matrix-only case — use row/col names as gene IDs
    mat <- as.matrix(df)
    
    if (is.null(rownames(mat))) {
      warning("Row names missing — using fallback gene names")
      rownames(mat) <- paste0("Gene", seq_len(nrow(mat)))
    }
    if (is.null(colnames(mat))) {
      colnames(mat) <- rownames(mat)
    }
    
    meta <- data.frame(
      GeneID = rownames(mat),
      GeneName = rownames(mat),
      category = rep("Uncategorized", nrow(mat)),
      stringsAsFactors = FALSE
    )
  }
  
  rownames(mat) <- meta$GeneID
  colnames(mat) <- meta$GeneID
  display_vec <- get_display_labels(meta, input$label_type == "GeneName")
  
  d <- dist(mat)
  hc_rows <- fastcluster::hclust(d)
  clusters <- cutree(hc_rows, k = input$num_clusters)
  updateSelectInput(session, "selected_cluster", 
                    choices = c("None", sort(unique(clusters))))
  
  row_categories_full <- NULL
  row_categories_grouped <- NULL
  top_categories <- character(0)
  
  if ("category" %in% colnames(df)) {
    # Step 1: Add npc_flag column
    npc_flag_map <- setNames(ifelse(df$GeneID %in% npc_gene_ids, "Yes", "No"), df$GeneID)
    
    row_categories_full <- normalize_categories(setNames(df$category, df$GeneID))
    
    # Step 2: Count Top 5 (exclude NPC group entirely)
    cat_counts <- sort(table(row_categories_full), decreasing = TRUE)
    top_categories <- names(cat_counts)[1:5]
    
    # Step 3: Generate row_categories_grouped
    row_categories_grouped <- row_categories_full
    if (input$highlight_category == "Top5") {
      row_categories_grouped[!row_categories_grouped %in% top_categories] <- "Other"
    }
    
    # Step 4: Category dropdown: NPC + Top5 + All others
    cat_counts <- sort(table(row_categories_full), decreasing = TRUE)
    
    # Step 2: Get list of categories sorted by count
    sorted_cats_by_freq <- names(cat_counts)
    
    # Step 3: Build display names like "Abiotic (152)"
    category_display_names <- paste0(sorted_cats_by_freq, " (", cat_counts, ")")
    
    # Step 4: Named vector (values = category name, names = display name)
    named_categories <- setNames(sorted_cats_by_freq, category_display_names)
    
    # Step 5: Final dropdown list with NPC at the top
    category_choices <- c("Top 5 Categories" = "Top5", "NPC", named_categories)
    
    if ("Other" %in% row_categories_grouped) {
      category_choices <- c(category_choices, "Other (aggregated)" = "Other")
    }
    
    updateSelectInput(session, "highlight_category", choices = category_choices, selected = input$highlight_category)
    
    # Step 5: Replace row_categories_grouped with npc_flag if NPC selected
    if (input$highlight_category == "NPC") {
      row_categories_grouped <- npc_flag_map
    }
  }
  else {
    updateSelectInput(session, "highlight_category", choices = NULL, selected = "Top5")
  }
  
  highlight_final <- if (input$highlight_category == "Top5") NULL else input$highlight_category
  
  ht <- create_heatmap(
    mat = mat,
    row_categories = row_categories_grouped,
    highlight_category = highlight_final,
    num_clusters = input$num_clusters,
    hc_rows = hc_rows
  )
  
  list(
    heatmap = ht,
    mat = mat,
    meta = meta,
    hc_rows = hc_rows,
    clusters = clusters,
    display_labels = display_vec,
    row_categories = row_categories_grouped,
    row_categories_full = row_categories_full,
    top_categories = top_categories
  )
}