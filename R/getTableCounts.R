getTableCounts <- function(connectionDetails, cdmDatabaseSchema){
  connection <- DatabaseConnector::connect(connectionDetails)
  sql <- system.file("sql", "GetTableCounts.sql", package = "ConceptPrevalence")
  sql <- SqlRender::readSql(sql)

  sql <- SqlRender::renderSql(sql,
                              database_schema=cdmDatabaseSchema)$sql

  sql <- SqlRender::translateSql(sql, targetDialect = attr(connection, "dbms"))$sql
  ParallelLogger::logInfo("Counting tables on server")
  DatabaseConnector::executeSql(connection, sql, progressBar = TRUE, reportOverallTime = TRUE)
  counts <- DatabaseConnector::querySql(connection, "select * from #table_count")
  DatabaseConnector::disconnect(connection)
  return(counts)
}
