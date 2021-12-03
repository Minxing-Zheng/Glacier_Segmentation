library(shiny)
library(shinycssloaders)
library(DT)
library(shiny)
library(DT)
library(RColorBrewer)
library(shinycssloaders)
library(tmap)
library(shiny)
library(tmaptools)
library("stringr")
library("tidyr")
library(DT)# for static and interactive maps
library(leaflet) # for interactive maps
library(ggplot2) # tidyverse data visualization package
library(rgdal)
library("purrr")
library("raster")
library("readr")
library("sf")
library("reticulate")
library("RStoolbox")
library("abind")
library("dplyr")
library("gdalUtils")
library("ggplot2")
library(plotly)
library(rsconnect)
library(cowplot)
library(gridExtra)
library(gridGraphics)
library(grid)
library(leaflet.extras)
#library(BiocManager)
library(sp)

# Begin UI for the R + reticulate example app
ui<-fluidPage(h3("Input Interactive Figures"),fluidRow(column(6,withSpinner(leafletOutput('Map',height=280))),column(6,withSpinner(plotlyOutput("curve",height=280)))),h3("Output Images"),fluidRow(column(12, withSpinner(plotOutput('grid',height = "300px")))),hr(),
              wellPanel(fluidRow(
  column(
    width = 12,
    h4("Information Panel"),textOutput("A"),textOutput("B"))
)))

