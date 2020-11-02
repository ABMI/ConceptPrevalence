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

getConceptCounts <- function(connectionDetails, cdmDatabaseSchema,
                             measurement = T, procedure = T, device = T, minCellCount = 5){
  connection <- DatabaseConnector::connect(connectionDetails)
  sql <- system.file("sql", "GetConceptCounts.sql", package = "ConceptPrevalence")
  sql <- SqlRender::readSql(sql)

  sql <- SqlRender::renderSql(sql,
                              database_schema=cdmDatabaseSchema,
                              measurement = measurement,
                              procedure = procedure,
                              device = device,
                              minCellCount = minCellCount)$sql

  sql <- SqlRender::translateSql(sql, targetDialect = attr(connection, "dbms"))$sql
  ParallelLogger::logInfo("Counting concepts on server")
  DatabaseConnector::executeSql(connection, sql, progressBar = TRUE, reportOverallTime = TRUE)
  sql <- SqlRender::translateSql("select * from #concept_count", targetDialect = attr(connection, "dbms"))$sql
  counts <- DatabaseConnector::querySql(connection, sql)

  DatabaseConnector::disconnect(connection)
  return(counts)
}
