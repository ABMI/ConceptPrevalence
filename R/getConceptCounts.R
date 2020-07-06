getConceptCounts <- function(connectionDetails, cdmDatabseSchema,
                             measurement = T, procedure = T, device = T, minCellCount = 5){
  connection <- DatabaseConnector::connect(connectionDetails)
  sql <- system.file("sql", "GetConceptCounts.sql", package = "ConceptPrevalence")
  sql <- readSql(sql)

  sql <- SqlRender::renderSql(sql,
                              database_schema=cdmDatabaseSchema,
                              measurement = measurement,
                              procedure = procedure,
                              device = device,
                              minCellCount = minCellCount)$sql

  sql <- SqlRender::translateSql(sql, targetDialect = attr(connection, "dbms"))$sql
  ParallelLogger::logInfo("Counting concepts on server")
  DatabaseConnector::executeSql(connection, sql, progressBar = TRUE, reportOverallTime = TRUE)
  counts <- DatabaseConnector::querySql(connection, "select * from #concept_count")
  DatabaseConnector::disconnect(connection)
  return(counts)
}
