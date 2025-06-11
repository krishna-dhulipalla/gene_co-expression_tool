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
  "Kelsey coexpression_bulk" = "https://raw.githubusercontent.com/krishna-dhulipalla/gene_co-expression_tool/master/data/cor_ordered_bulk.rds",
  "Kelsey coexpression_all" = "https://raw.githubusercontent.com/krishna-dhulipalla/gene_co-expression_tool/master/data/cor_ordered_all.rds",
  "Tylor coexpression_bulk" = "https://raw.githubusercontent.com/krishna-dhulipalla/gene_co-expression_tool/master/data/tylor_cor_ordered_bulk.rds",
  "Tylor coexpression_all" = "https://raw.githubusercontent.com/krishna-dhulipalla/gene_co-expression_tool/master/data/tylor_cor_ordered_all.rds",
  "Coexpression_all" = "https://raw.githubusercontent.com/krishna-dhulipalla/gene_co-expression_tool/master/data/dataset1.rds",
  "Coexpression_bulk" = "https://raw.githubusercontent.com/krishna-dhulipalla/gene_co-expression_tool/master/data/dataset2.rds",
  "ATH Leaf 2k Pearson" = "https://raw.githubusercontent.com/krishna-dhulipalla/gene_co-expression_tool/master/data/2k_pearson.rds",
  "ATH Leaf 2k Spearman" = "https://raw.githubusercontent.com/krishna-dhulipalla/gene_co-expression_tool/master/data/2k_spearman.rds",
  "Cauline" = "https://raw.githubusercontent.com/krishna-dhulipalla/gene_co-expression_tool/master/data/cauline.rds",
  "flower" = "https://raw.githubusercontent.com/krishna-dhulipalla/gene_co-expression_tool/master/data/flower.rds",
  "leaf" = "https://raw.githubusercontent.com/krishna-dhulipalla/gene_co-expression_tool/master/data/leaf.rds",
  "root" = "https://raw.githubusercontent.com/krishna-dhulipalla/gene_co-expression_tool/master/data/root.rds",
  "shoot" = "https://raw.githubusercontent.com/krishna-dhulipalla/gene_co-expression_tool/master/data/shoot.rds",
  "silique" = "https://raw.githubusercontent.com/krishna-dhulipalla/gene_co-expression_tool/master/data/silique.rds",
  "stem" = "https://raw.githubusercontent.com/krishna-dhulipalla/gene_co-expression_tool/master/data/stem.rds"
)


seurat_paths <- list(
  "Cauline" = "https://raw.githubusercontent.com/krishna-dhulipalla/gene_co-expression_tool/master/data/seurat/cauline_ne_seurat.rds",
  "flower" = "https://raw.githubusercontent.com/krishna-dhulipalla/gene_co-expression_tool/master/data/seurat/flower_ne_seurat.rds",
  "leaf" = "https://raw.githubusercontent.com/krishna-dhulipalla/gene_co-expression_tool/master/data/seurat/leaf_ne_seurat.rds",
  "root" = "https://raw.githubusercontent.com/krishna-dhulipalla/gene_co-expression_tool/master/data/seurat/root_ne_seurat.rds",
  "shoot" = "https://raw.githubusercontent.com/krishna-dhulipalla/gene_co-expression_tool/master/data/seurat/shoot_ne_seurat.rds",
  "silique" = "https://raw.githubusercontent.com/krishna-dhulipalla/gene_co-expression_tool/master/data/seurat/silique_ne_seurat.rds",
  "stem" = "https://raw.githubusercontent.com/krishna-dhulipalla/gene_co-expression_tool/master/data/seurat/stem_ne_seurat.rds"
)

npc_gene_ids <- c(
  "AT1G55540", "AT3G56900", "AT3G53110", "AT1G13120", "AT1G75340", 
  "AT1G80670", "AT1G33410", "AT2G05120", "AT3G14120", "AT1G80680",
  "AT4G32910", "AT4G30840", "AT2G30050", "AT3G01340", "AT1G64350",
  "AT2G39810", "AT5G40480", "AT1G73240", "AT5G51200", "AT1G14850",
  "AT3G16310", "AT2G41620", "AT3G57350", "AT5G05680", "AT1G10390",
  "AT1G59660", "AT4G37130", "AT1G24310", "AT2G45000", "AT1G79280",
  "AT1G52380", "AT3G15970", "AT4G11790", "AT3G10650", "AT4G15880",
  "AT3G06910", "AT4G38760", "AT1G07970", "AT5G64930", "AT5G20200"
)

