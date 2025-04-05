# Gene Co-Expression Heatmap Explorer

Interactive web application for exploring gene co-expression networks through clustered correlation matrices. Leverages hierarchical clustering and InteractiveComplexHeatmap for responsive visualization of large biological datasets.

![Demo Preview](hero.png) <!-- Replace with actual image path -->

## Features
- Interactive exploration of correlation matrices with hover value inspection
- Dynamic sub-heatmap generation through rectangular selection
- Multi-gene search functionality across matrix dimensions
- Dataset comparison with 8 preloaded plant co-expression matrices
- Client-side matrix reduction for optimized large dataset handling

## Requirements
- **R** (≥ 4.1.0)
- **R Packages**:
  - shiny (≥ 1.8.0)
  - ComplexHeatmap (≥ 2.14.0)
  - InteractiveComplexHeatmap (≥ 1.7.0)
  - circlize (≥ 0.4.15)
  - data.table (≥ 1.14.8)
  - shinycssloaders (≥ 1.0.0)
  - Cairo (≥ 1.6-0)

## Installation
```bash
git clone https://github.com/yourusername/gene-coexpression-shiny.git
cd gene-coexpression-shiny
```

Install required R packages:
```r
install.packages(c("shiny", "ComplexHeatmap", "InteractiveComplexHeatmap", 
                   "circlize", "data.table", "shinycssloaders", "Cairo"))
```

## Usage

### Quick Start
```r
shiny::runApp("app.R")
```

### Data Exploration
1. Select dataset from curated collection
2. Choose visualization mode:
   - **Full Matrix**: Complete correlation matrix (≤2000 genes recommended)
   - **Reduced Matrix**: Downsampled view for large datasets
3. Use InteractiveComplexHeatmap tools for:
   - Rectangular region selection
   - Multi-gene search
   - Value inspection
4. Export selected submatrices via interface controls

### Adding Custom Datasets
1. **Prepare Correlation Matrix**:
   - CSV file with gene IDs as row/column names
   - Square numerical matrix (-1 to 1 range recommended)

2. **Preprocessing Pipeline**:
   ```r
   # 1. Hierarchical clustering
   source("matrix_clustering.R")
   reorder_correlation_matrix("input.csv", "clustered_matrix.csv")
   
   # 2. Format conversion
   source("csv_to_rds_rounded_3.R")
   convert_csv_to_rds("clustered_matrix.csv")  # Creates .rds file
   ```

3. **Deployment**:
   - Move generated .rds file to `data/` directory
   - Add entry to `file_paths` list in global.R:
     ```r
     file_paths <- list(
       ...
       "Your Dataset" = "data/your_matrix.rds"
     )
     ```

## Performance Considerations
- Matrix Size Guidelines:
  - Full Matrix: ≤2000×2000 
  - Reduced Matrix: ≤1000×1000 for optimal responsiveness
- Preprocessing Time:
  - 2k×2k matrix: <1 min

## Support
For technical issues or feature requests, please [open an issue](https://github.com/yourusername/gene-coexpression-shiny/issues).  
<!--When using this tool in publications, please cite:
[comment]: <>(> **InteractiveComplexHeatmap**: Gu, Z. (2022) Bioinformatics.) -->

## License
MIT License © 2024
