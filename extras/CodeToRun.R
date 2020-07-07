library(ConceptPrevalence)

# The folder where the study intermediate and result files will be written:
outputFolder <- "s:/"

# Details for connecting to the server:
connectionDetails <- DatabaseConnector::createConnectionDetails(dbms = "pdw",
                                                                server = Sys.getenv("PDW_SERVER"),
                                                                user = NULL,
                                                                password = NULL,
                                                                port = Sys.getenv("PDW_PORT"))

# The name of the database schema where the CDM data can be found:
cdmDatabaseSchema <- "CDM.dbo"

# Some meta-information that will be used by the export function:
databaseId <- "Synpuf"

# For Oracle: define a schema that can be used to emulate temp tables:
oracleTempSchema <- NULL

execute(connectionDetails = connectionDetails,
        cdmDatabaseSchema = cdmDatabaseSchema,
        outputFolder = outputFolder,
        databaseId = databaseId,
        measurement = T,
        procedure = T,
        device = T,
        minCellCount = 5)

