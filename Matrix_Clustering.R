reorder_correlation_matrix <- function(input_file, output_file, method = "complete") {
  # Read correlation matrix from CSV (with row names in first column)
  cor_matrix <- as.matrix(read.csv(input_file, row.names = 1))
  
  # Verify matrix is square
  if (nrow(cor_matrix) != ncol(cor_matrix)) {
    stop("Input matrix is not square")
  }
  
  # Convert correlations to distances (1 - correlation)
  dist_matrix <- as.dist(1 - cor_matrix)
  
  # Perform hierarchical clustering
  hc <- hclust(dist_matrix, method = method)
  
  # Get optimal ordering
  order <- hc$order
  
  # Reorder the matrix
  reordered_matrix <- cor_matrix[order, order]
  
  # Save reordered matrix to CSV
  write.csv(reordered_matrix, file = output_file)
  
  return(reordered_matrix)
}

result <- reorder_correlation_matrix(
  input_file = "R_Programming/Co-experession/coexpression_tools/corr_matrixes/GSM3145906_corr_spearman.csv",
  output_file = "R_Programming/Co-experession/coexpression_tools/corr_clust_matrixes/2k_spearman.csv",
  method = "complete"
)