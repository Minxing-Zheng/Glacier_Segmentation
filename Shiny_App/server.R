# Import R packages needed for the app here:
library(shiny)
library(DT)
library(RColorBrewer)
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
library("BiocGenerics")
library(EBImage)
library(leaflet.extras)
library(sp)
source("data.R")
source("metrics.R")

# Define any Python packages needed for the app here:
PYTHON_DEPENDENCIES = c('pip', 'numpy')
# Begin app server

shinyServer(function(input, output) {
  
  # ------------------ App virtualenv setup (Do not edit) ------------------- #
  
  virtualenv_dir = Sys.getenv('VIRTUALENV_NAME')
  python_path = Sys.getenv('PYTHON_PATH')
  # Create virtual env and install dependencies
  reticulate::virtualenv_create(envname = virtualenv_dir, python = python_path)
  reticulate::virtualenv_install(virtualenv_dir, packages = PYTHON_DEPENDENCIES, ignore_installed=TRUE)
  reticulate::use_virtualenv(virtualenv_dir, required = T)
  
  # ------------------ App server logic (Edit anything below) --------------- #
  
  plot_cols <- brewer.pal(11, 'Spectral')
  
  # Import python functions to R
  reticulate::source_python('python_functions.py')
  ggplot_iou <- readRDS("iou_plotly.rds")
  #map<-readRDS("leafmap_shp.rds")
  y_path <- file.path("glaciers.geojson")
  basins <- read_csv("test_list.csv")
  geo <- read_sf(y_path) %>%
    filter(Sub_basin %in% basins$Sub_basin)
  geo<-geo[!st_is_empty(geo),]
  W_valid<-st_is_valid(geo)
  geo<-geo[c(which(W_valid)),]
  
  temp = list.files(path='csv',pattern="*.csv")
  center<-data.frame()
  len_csv<-c()
  for (file in temp) {
    new_csv<-read_csv(paste(c("csv/",file),collapse =''),col_names = c('id','Long','Lat'),skip=1)
    len_csv<-c(len_csv,nrow(new_csv))
    center <- rbind(center,new_csv)
  }
  center$id<-seq(1,length(center$id))
  center_df<-round(center,3)
  
  paths<-prediction_paths("predictions")
  id<-c()
  for (index in seq(1:nrow(paths))){
    ix1<-strtoi(paths[index,]$ix1)
    ix2<-strtoi(paths[index,]$ix2)
    i<-sum(len_csv[1:ix1-1])+ix2
    id<-c(id,i)
  }
  paths$id<-id
  gc()
  
  Icon <- makeIcon(
    iconUrl = "9521617427822_.pic.jpg",
    iconWidth = 15, iconHeight = 30, #10, 20 to 15,30
    iconAnchorX = 5, iconAnchorY = 20,)
  
  #type<-"train"
  # split_id<-c(unique(paths[paths$split==type,]$ix2))
  #load("iou_df_two_csv.rda")
  
  save<-c()
  
  output$A <- renderText({
    print("Glacier Map and Accuracy Cruve could be interacted by clicking")
  })
  
  output$B <- renderText({
    print("Contact: If you have any suggestions or questions in terms of this shiny app, please contant mzheng54@wisc.edu or ksankaran@wisc.edu.")
  })
  output$Map <- renderLeaflet({leafmap_shp<-tmap_leaflet(tm_shape(st_as_sf(as.data.frame(geo))) + tm_polygons("Glaciers",palette=c("#0433ff","#55aa00")) + tm_facets(nrow = 1, sync = TRUE))%>% 
    addMarkers(center_df$Long,center_df$Lat,popup=paste("ID:",center_df$id,"<br>","Longitude:", center_df$Long, "<br>","Latitude:", center_df$Lat), label =center_df$id,group = 'id', layerId = center_df$id,icon = Icon,clusterOptions = markerClusterOptions()) 
  leafmap_shp})
  #output$Map <- renderLeaflet(map)
  output$curve<-renderPlotly(ggplot_iou)

  click<-reactive(input$Map_marker_click)
  
  output$grid<-renderPlot({
    d <- event_data("plotly_click", source = "gg")
    id1<-click()$id
    id2<-d$pointNumber+1
    if(is.null(id1)){id1<-0}
    if(is.null(d)){id2<-0}
    save<<-c(save,id1,id2)
    if (length(save)==2){id<-1}
    if(length(save)>2){save<-save[(length(save)-3):length(save)]}
    if (length(save)>2){
      id<-ifelse((save[1]==save[3]),id2,id1)}
    print(id)
    print('id ok')
    
    result<-paths[paths$id==id& paths$split=="train",]
    #np_load(result[result$type=="x",]$path)
    
    y_hat_raster<-np_load(result[result$type=="y_hat",]$path) %>% as.array()%>%aperm(c(2, 3, 1))
    x_raster<-np_load(result[result$type=="x",]$path) %>% as.array()%>%aperm(c(2, 3, 1))
    y_raster<-np_load(result[result$type=="y",]$path) %>% as.array()%>%aperm(c(2, 3, 1))
    
    #someData <- rep(0, 512*512*3);
    #ar <- array(someData, c(512, 512, 3));  
    #ar[,,1]<- apply(x_raster[,,1], 2, rev)
    #ar[,,2]<- apply(x_raster[,,2], 2, rev)
    #ar[,,3]<- apply(x_raster[,,3], 2, rev)
    p3<-plot_rgb(x_raster %>% brick())
    
    #someData <- rep(0, 512*512*3);
    #ar <- array(someData, c(512, 512, 3));  
    #ar[,,1]<- apply(y_raster[,,1], 2, rev)
    #ar[,,2]<- apply(y_raster[,,2], 2, rev)
    #ar[,,3]<- apply(y_raster[,,3], 2, rev)
    p2<-plot_rgb(y_raster %>% brick())
    #p2<-plot_rgb(ar %>% brick())
    
    #someData <- rep(0, 512*512*3);
    #ar <- array(someData, c(512, 512, 3));  
    #ar[,,1]<- apply(y_hat_raster[,,1], 2, rev)
    #ar[,,2]<- apply(y_hat_raster[,,2], 2, rev)
    #ar[,,3]<- apply(y_hat_raster[,,3], 2, rev)
    p4<-plot_rgb(y_hat_raster %>% brick())
    #p4<-plot_rgb(ar %>% brick())
    grid.arrange(arrangeGrob(p3, top = textGrob("Raw Image", gp=gpar(fontsize=20,font=8))), arrangeGrob(p2, top = textGrob("Label", gp=gpar(fontsize=20,font=8))),arrangeGrob(p4, top = textGrob("Prediction", gp=gpar(fontsize=20,font=8))),ncol=3)

    })
    
})
