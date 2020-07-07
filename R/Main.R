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

#' Execute the Study
#'
#' @details
#' This function executes the ConceptPrevalence.
#'
#'
#' @param connectionDetails    An object of type \code{connectionDetails} as created using the
#'                             \code{\link[DatabaseConnector]{createConnectionDetails}} function in the
#'                             DatabaseConnector package.
#' @param cdmDatabaseSchema    Schema name where your patient-level data in OMOP CDM format resides.
#'                             Note that for SQL Server, this should include both the database and
#'                             schema name, for example 'cdm_data.dbo'.
#' @param oracleTempSchema     Should be used in Oracle to specify a schema where the user has write
#'                             priviliges for storing temporary tables.
#' @param outputFolder         Name of local folder to place results; make sure to use forward slashes
#'                             (/). Do not use a folder on a network drive since this greatly impacts
#'                             performance.
#' @param databaseId           A short string for identifying the database (e.g.
#'                             'Synpuf').
#' @param minCellCount         The minimum number of subjects contributing to a count before it can be included
#'                             in packaged results.
#'
#' @examples
#' \dontrun{
#' connectionDetails <- createConnectionDetails(dbms = "postgresql",
#'                                              user = "joe",
#'                                              password = "secret",
#'                                              server = "myserver")
#'
#' execute(connectionDetails,
#'         cdmDatabaseSchema = "cdm_data",
#'         oracleTempSchema = NULL,
#'         outputFolder = "c:/temp/study_results")
#' }
#'
#' @export
execute <- function(connectionDetails,
                    cdmDatabaseSchema,
                    oracleTempSchema,
                    outputFolder,
                    databaseId,
                    measurement = T,
                    procedure = T,
                    device = T,
                    minCellCount = 5) {
  if (!file.exists(outputFolder))
    dir.create(outputFolder, recursive = TRUE)

  ParallelLogger::addDefaultFileLogger(file.path(outputFolder, "log.txt"))
  on.exit(ParallelLogger::unregisterLogger("DEFAULT"))

  tableCounts <- getTableCounts(connectionDetails = connectionDetails,
                                  cdmDatabaseSchema = cdmDatabaseSchema
                                  #oracleTempSchema = oracleTempSchema
                                )
  saveRDS(tableCounts, file.path(outputFolder, "TableCounts.rds"))

  conceptCounts <- getConceptCounts(connectionDetails = connectionDetails,
                                   cdmDatabaseSchema = cdmDatabaseSchema,
                                   #oracleTempSchema = oracleTempSchema,
                                   measuremen = measurement,
                                   procedure = procedure,
                                   device = device,
                                   minCellCount = minCellCount)
  saveRDS(conceptCounts, file.path(outputFolder, "ConceptCounts.rds"))

  ParallelLogger::logInfo("Adding counts to zip file")
  zipName <- file.path(outputFolder, paste0("Results", databaseId, ".zip"))
  files <- list.files(outputFolder, pattern = ".*\\.rds$")
  oldWd <- setwd(outputFolder)
  on.exit(setwd(oldWd))
  DatabaseConnector::createZipFile(zipFile = zipName, files = files)
  ParallelLogger::logInfo("Results are ready for sharing at:", zipName)
}
