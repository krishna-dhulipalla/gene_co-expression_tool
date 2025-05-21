file_path <- "./data/cauline.rds"
mat <- readRDS(file_path)

# Load CSV with gene metadata
categories <- read.csv("./Raw_data/NEgenes.csv", stringsAsFactors = FALSE)

# Ensure necessary columns exist
required_cols <- c("GeneID", "category", "GeneName")
if (!all(required_cols %in% colnames(categories))) {
  stop("CSV must have columns named 'GeneID', 'category', and 'GeneName'")
}

# Set rownames for matching
rownames(categories) <- categories$GeneID

# Match GeneName using GeneID from mat
matched_gene_names <- categories[mat$GeneID, "GeneName", drop = FALSE]

# Check match statistics
num_matched <- sum(!is.na(matched_gene_names$GeneName))
num_unmatched <- sum(is.na(matched_gene_names$GeneName))

cat("✅ Number of GeneIDs matched to GeneName:", num_matched, "\n")
cat("❗ Number of GeneIDs without GeneName:", num_unmatched, "\n")

# Add GeneName column
mat$GeneName <- matched_gene_names$GeneName

# Save updated matrix
saveRDS(mat, "./cauline.rds")
