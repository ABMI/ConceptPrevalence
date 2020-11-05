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

if(!require("stringr"))
  install.packages("stringr")

viewShiny <- function(dataFolder, pathToCsv){


  if (!file.exists(file.path(dataFolder,"Summary.rds"))){
    stop('No summary')
  }

  summary <- readRDS(file.path(dataFolder, "Summary.rds"))

  if (is.null(pathToCsv)){
    urlfile <- 'https://raw.githubusercontent.com/ohdsi-korea/OmopVocabularyKorea/master/measurement_guideline/source_to_concept_map.csv'
    df_standard <<- read.csv(url(urlfile))
    colnames(df_standard) <- tolower(colnames(df_standard))
  } else {
    df_standard <- read.csv(pathToCsv)
    colnames(df_standard) <- tolower(colnames(df_standard))
  }

  df_local <- summary[summary[,"TABLE_NAME"]=="measurement",]
  df_local <- df_local[df_local[,"CONCEPT_ID"] != 0,]
  results.df <<- readRDS(system.file("RDS", "recommended.RDS", package = "ConceptPrevalence"))

  #Overview
  sum(df_local$CONCEPT_COUNT)
  length(df_local$CONCEPT_COUNT) - length(which(df_local$CONCEPT_ID %in% df_standard$target_concept_id))

  sum(df_local$CONCEPT_COUNT) - sum(df_local[which(df_local$CONCEPT_ID %in% df_standard$target_concept_id),]$CONCEPT_COUNT)

  sum(df_local[which(df_local$CONCEPT_ID %in% df_standard$target_concept_id),]$CONCEPT_COUNT) / sum(df_local$CONCEPT_COUNT)


  #datatable
  #if(datatable==T){

    connection <- DatabaseConnector::connect(connectionDetails)
    #DatabaseConnector::executeSql(connection, "drop table #temp_concept")
    DatabaseConnector::insertTable(connection = connection, tableName = "#temp_concept",
                                   data = df_local, tempTable = T)
    sql <- system.file("sql", "GetConceptInfo.sql", package = "ConceptPrevalence")
    sql <- SqlRender::readSql(sql)
    sql <- SqlRender::renderSql(sql,
                                database_schema=cdmDatabaseSchema)$sql
    sql <- SqlRender::translateSql(sql, targetDialect = attr(connection, "dbms"))$sql
    ParallelLogger::logInfo("Constructing concept information on server")
    DatabaseConnector::executeSql(connection, sql, progressBar = TRUE, reportOverallTime = TRUE)
    sql <- SqlRender::translateSql("SELECT * FROM #concept_info", targetDialect = attr(connection, "dbms"))$sql
    preparedCounts <- DatabaseConnector::querySql(connection, sql)
    DatabaseConnector::disconnect(connection)

    preparedCounts$STANDARDIZED <- preparedCounts$CONCEPT_ID %in% df_standard$target_concept_id

    #Global
    df_local <<- df_local
    preparedCounts <<- preparedCounts

    #return(preparedCounts)
  #}


# as.datatable(
#               formattable(preparedCounts, list(
#                 CONCEPT_COUNT = color_tile("white", "orange"),
#                 STANDARDIZED = formatter("span",
#                                        style = x ~ style(color = ifelse(x, "green", "red")),
#                                        x ~ icontext(ifelse(x, "ok", "remove"), ifelse(x, "Yes", "No")))
#                 )
#               )
# )

  appDir <- system.file("shiny", package = "ConceptPrevalence")
  shiny::runApp(appDir)

}


