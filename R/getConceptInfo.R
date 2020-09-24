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

getConceptInfo <- function(connectionDetails, cdmDatabseSchema, conceptCounts){
  #conceptCounts <- readRDS(file.path(outputFolder, "ConceptCounts.rds"))
  connection <- DatabaseConnector::connect(connectionDetails)
  DatabaseConnector::insertTable(connection = connection, tableName = "#temp_concept",
                                 data = conceptCounts, tempTable = T)
  #DatabaseConnector::executeSql(connection, "drop table #temp_concept")
  sql <- system.file("sql", "GetConceptInfo.sql", package = "ConceptPrevalence")
  sql <- SqlRender::readSql(sql)
  sql <- SqlRender::renderSql(sql,
                              database_schema=cdmDatabaseSchema)$sql
  sql <- SqlRender::translateSql(sql, targetDialect = attr(connection, "dbms"))$sql
  ParallelLogger::logInfo("Constructing concept information on server")
  DatabaseConnector::executeSql(connection, sql, progressBar = TRUE, reportOverallTime = TRUE)
  preparedCounts <- DatabaseConnector::querySql(connection, "SELECT * FROM #concept_info")
  DatabaseConnector::disconnect(connection)
  return(preparedCounts)
}
