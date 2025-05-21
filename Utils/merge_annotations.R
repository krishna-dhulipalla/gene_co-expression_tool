file_path <- "./data/ne_stem_cor_ordered_bulk.rds"
mat <- readRDS(file_path)
categories <- read.csv("./Raw_data/NEgenes.csv", stringsAsFactors = FALSE) 

if (!all(c("GeneID", "category") %in% colnames(categories))) {
  stop("CSV must have columns named 'GeneID' and 'category'")
}

# Set GeneID as rownames for easier matching
rownames(categories) <- categories$GeneID

# Align categories to matrix rows (match by rownames of mat)
matched_categories <- categories[rownames(mat), , drop = FALSE]

# Add a column to help check which genes matched
matched_categories$matched <- !is.na(matched_categories$category)

# Check matching stats
num_matched <- sum(!is.na(matched_categories$category))
num_unmatched <- sum(is.na(matched_categories$category))

cat("✅ Number of genes matched to category:", num_matched, "\n")
cat("❗ Number of genes without category:", num_unmatched, "\n")

mat_with_category <- cbind(
  GeneID = rownames(mat),
  category = matched_categories$category,
  as.data.frame(mat)
)

# Save the updated matrix (now includes category + gene ID)
saveRDS(mat_with_category,"./data/stem.rds")