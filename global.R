library(shiny)
library(shinydashboard)
library(data.table)
library(ComplexHeatmap)
library(InteractiveComplexHeatmap)
library(circlize)
library(shinycssloaders)
library(Cairo)

file_paths <- list(
  "Kelsey coexpression_bulk" = "data/cor_ordered_bulk.rds",
  "Kelsey coexpression_all" = "data/cor_ordered_all.rds",
  "tylor coexpression_bulk" = "data/tylor_cor_ordered_bulk.rds",
  "tylor coexpression_all" = "data/tylor_cor_ordered_all.rds",
  "ATH Leaf 2k Pearson" = "data/2k_pearson.rds",
  "ATH Leaf 2k Spearman" = "data/2k_spearman.rds",
  "Coexpression_all" = "data/dataset1.rds",
  "Coexpression_bulk" = "data/dataset2.rds"
)