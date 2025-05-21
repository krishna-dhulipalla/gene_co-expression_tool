library(shiny)
library(shinydashboard)
library(data.table)
library(ComplexHeatmap)
library(InteractiveComplexHeatmap)
library(circlize)
library(shinycssloaders)
library(Cairo)
library(DT)
library(ggplot2)
library(shinyjs)
library(heatmaply)
library(plotly)
library(ggnewscale)
library(Seurat)

file_paths <- list(
  "Kelsey coexpression_bulk" = "data/cor_ordered_bulk.rds",
  "Kelsey coexpression_all" = "data/cor_ordered_all.rds",
  "Tylor coexpression_bulk" = "data/tylor_cor_ordered_bulk.rds",
  "Tylor coexpression_all" = "data/tylor_cor_ordered_all.rds",
  "Coexpression_all" = "data/dataset1.rds",
  "Coexpression_bulk" = "data/dataset2.rds",
  "ATH Leaf 2k Pearson" = "data/2k_pearson.rds",
  "ATH Leaf 2k Spearman" = "data/2k_spearman.rds",
  "Cauline" = "data/cauline.rds",
  "flower" = "data/flower.rds",
  "leaf" = "data/leaf.rds",
  "root" = "data/root.rds",
  "shoot" = "data/shoot.rds",
  "silique" = "data/silique.rds",
  "stem" = "data/stem.rds"
)

seurat_paths <- list(
  "Cauline" = "data/seurat/cauline_ne_seurat.rds",
  "flower" = "data/seurat/flower_ne_seurat.rds",
  "leaf" = "data/seurat/leaf_ne_seurat.rds",
  "root" = "data/seurat/root_ne_seurat.rds",
  "shoot" = "data/seurat/shoot_ne_seurat.rds",
  "silique" = "data/seurat/silique_ne_seurat.rds",
  "stem" = "data/seurat/stem_ne_seurat.rds"
)