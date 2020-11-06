# Copyright 2020 Observational Health Data Sciences and Informatics
#
# This file is part of ConceptPrevalence
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

if(!require("shiny"))
  install.packages("shiny")
library(shiny)

if(!require("shinydashboard"))
  install.packages("shinydashboard")
library(shinydashboard)

if(!require("dygraphs"))
  install.packages("dygraphs")
library(dygraphs)

if(!require("formattable"))
  install.packages("formattable")
library(formattable)

if(!require("DT"))
  install.packages("DT")
library(DT)

###START THE APP

ui <- dashboardPage(
  skin="yellow",
  dashboardHeader(
    title="Concept Prevalence",
    titleWidth = 450
  ),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Source code for app",href="https://github.com/ABMI/conceptprevalence", icon=icon("github"))
    )
  ),
  dashboardBody(
    #boxes to be put in a row (or column)
    fluidRow(
      valueBoxOutput("sessionBox"),
      valueBoxOutput("goalBox"),
      valueBoxOutput("goalCRBox")
    ),

    fluidRow(
    box(title="Measurement concepts",
        status="primary",
        solidHeader = TRUE,
        DT::dataTableOutput("table"),
        height=500, width=12)
     ,
     box(title="Concept recommend",
         status="primary",solidHeader = TRUE,
         uiOutput("recommendQuery"),
         dataTableOutput('recommendTable'),
         height=700, width=12)
    )
    )
)


server <- function(input, output) {

  output$sessionBox <- renderValueBox({
    valueBox(
      format(length(preparedCounts$CONCEPT_COUNT),format="d",big.mark=","),
      "Concepts", icon = icon("area-chart"), color = "blue")
  })

  output$goalBox <- renderValueBox({
    valueBox(
      format(sum(preparedCounts$CONCEPT_COUNT),format="d",big.mark=","),
      "Rows", icon = icon("shopping-cart"), color = "blue")
  })

  output$goalCRBox <- renderValueBox({
    valueBox(
      paste(round(sum(preparedCounts[which(preparedCounts$CONCEPT_ID %in% df_standard$target_concept_id),]$CONCEPT_COUNT) / sum(preparedCounts$CONCEPT_COUNT)*100, digit=2),"%"), "Standard-covered rate",
      icon = icon("Standard-covered rate"), color = "blue")
  })

  output$table <- DT::renderDataTable( {
    return(as.datatable(
      formattable(preparedCounts, list(
        CONCEPT_COUNT = color_tile("white", "orange"),
        STANDARDIZED = formatter("span",
                                 style = x ~ style(color = ifelse(x, "green", "red")),
                                 x ~ icontext(ifelse(x, "ok", "remove"), ifelse(x, "Yes", "No")))
      ))))
  })

  output$recommendQuery <- renderUI({
    selectInput("recommendQuery", "Select query", choices = results.df$querylist)
  })

  output$table2 <- renderDT({
    df_standard[c(idx),]
  })



  #showTopresults(query = 'pressure', n=5)

  render.table <- eventReactive(input$recommendQuery,{
    table <- showTopresults(query = input$recommendQuery, n=20)
    table
  })


  output$recommendTable <- renderDataTable(
    render.table()
  )

}

shinyApp(ui, server)


