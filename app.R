#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(readr)
library(plotly)
library(dplyr)
library(openxlsx)
library(reshape2)
library('biomaRt')
library('Biobase')

## load in and process all the Beat AML data.
source("R/global.R")

##load the plotting functions
source("R/plotFns.R") ## loads all helper functions 

## load the UI and server
source("R/UI.R") ## loads the 'ui' object
source("R/server.R") ## loads the 'server' object

## Run the shiny app in interactive R sessions
if (interactive()) {
  shinyApp(ui = ui, server = server)
}
  