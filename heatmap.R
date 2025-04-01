color_mapping <- colorRamp2(c(-1, 0, 1), c("blue", "white", "red"))

create_heatmap <- function(mat) {
  Heatmap(
    mat,
    name = "Correlation",
    cluster_rows = FALSE, 
    cluster_columns = FALSE,
    col = color_mapping,
    show_row_names = FALSE,
    show_column_names = FALSE,
    use_raster = TRUE
  )
}