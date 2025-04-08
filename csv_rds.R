# Set the folder path containing the CSV files
folder_path <- "C:/Users/vamsi/OneDrive/Documents/R_Programming/Co-experession/complex_heatmap/data"  # Change this to your folder path
# List all CSV files in the folder
csv_files <- list.files(folder_path, pattern = "\\.csv$", full.names = TRUE)

# Loop over each CSV file
for (file in csv_files) {
  # Read CSV file: first row as header and first column as row names
  df <- read.csv(file, row.names = 1, check.names = FALSE)
  
  # Round all numeric values in the data frame to 3 decimal places
  df_rounded <- round(df, 3)
  
  # Create a new file name with .rds extension
  base <- sub("\\.csv$", "", file)
  new_file <- paste0(base, ".rds")
  
  # Save the rounded data frame as an RDS file
  saveRDS(df_rounded, new_file)
  
  cat(sprintf("Converted %s to %s\n", file, new_file))
}
