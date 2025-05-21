color_mapping <- colorRamp2(c(-1, 0, 1), c("blue", "white", "red"))
my_colors <- c(
  "#E41A1C",  # Red
  "#377EB8",  # Blue
  "#4DAF4A",  # Green
  "#984EA3",  # Purple
  "#FF7F00"   # Orange
)



create_heatmap <- function(mat, row_categories = NULL, highlight_category = NULL) {
  anno_obj <- NULL
  if (!is.null(row_categories)) {
    
    # If highlight_category is set, make a binary color map
    if (!is.null(highlight_category) && highlight_category != "") {
      cat_highlighted <- ifelse(row_categories == highlight_category, highlight_category, "Other")
      
      anno_obj <- rowAnnotation(
        category = cat_highlighted,
        col = list(
          category = c(
            setNames("red", highlight_category),
            setNames("gray", "Other")
          )
        )
      )
    } else {
      
      # Remove "Other" temporarily from count
      cat_counts <- sort(table(row_categories[row_categories != "Other"]), decreasing = TRUE)
      
      top5_levels <- names(cat_counts)[1:5]
      category_levels <- c(top5_levels, "Other") 
      category_levels <- category_levels[!is.na(category_levels)]
      
      row_categories <- factor(row_categories, levels = category_levels)
      
      local_colors <- setNames(my_colors[seq_along(category_levels)], category_levels)
      
      anno_obj <- rowAnnotation(
        category = row_categories,
        col = list(
          category = local_colors
        )
      )
    }
  }
  d <- dist(mat)
  hc_rows <- fastcluster::hclust(d)
  hc_cols <- fastcluster::hclust(d)
  Heatmap(
    mat,
    name = "Correlation",
    col = color_mapping,
    right_annotation = anno_obj,
    cluster_rows = as.dendrogram(hc_rows),
    cluster_columns = as.dendrogram(hc_cols),
    show_row_names = FALSE,
    show_column_names = FALSE,
    use_raster = TRUE
  )
}