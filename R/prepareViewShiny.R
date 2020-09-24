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

prepareViewShiny <- function(connectionDetails, cdmDatabseSchema, dataFolder){

  folders <- list.dirs(path = dataFolder, recursive = T, full.names = F)
  folders <- folders[nchar(folders) >0]

  if (!file.exists(file.path(dataFolder,"Summary.rds"))){
    if(length(folders)==0){
      stop('No results to export')
    }

    conceptCounts <- data.frame()

    for(folder in folders){
      #load rds all sites
      if(file.exists(file.path(dataFolder, folder, "ConceptCounts.rds"))) {
        tempTable <- readRDS(file.path(dataFolder, folder, "ConceptCounts.rds"))
        tempTable <- getConceptInfo(connectionDetails, cdmDatabseSchema, conceptCounts=tempTable)
        tempTable$DB_NAME <- folder
        conceptCounts <- rbind(conceptCounts, tempTable)
      } else {
        files <- list.files(file.path(dataFolder, folder), pattern = ".*\\.zip$")

        if(length(files)==0){
          stop('Please contain only one .zip file')
        }
          if(length(files)>1){
            stop('Please put only one .zip file')
          }

        utils::unzip(file.path(dataFolder, folder, files), exdir = file.path(dataFolder, folder))
        tempTable <- readRDS(file.path(dataFolder, folder, "ConceptCounts.rds"))
        tempTable <- getConceptInfo(connectionDetails, cdmDatabseSchema, conceptCounts=tempTable)
        tempTable$DB_NAME <- folder
        conceptCounts <- rbind(conceptCounts, tempTable)
      }
    }
    saveRDS(conceptCounts, file.path(dataFolder, "Summary.rds"))
    ParallelLogger::logInfo("Results are ready for shiny view at:", dataFolder, "/Summary.rds")
  }
}
