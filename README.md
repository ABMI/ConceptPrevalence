ConceptPrevalence
==============================


Requirements
============

- A database in [Common Data Model version 5](https://github.com/OHDSI/CommonDataModel) in one of these platforms: SQL Server, Oracle, PostgreSQL, IBM Netezza, Apache Impala, Amazon RedShift, Google BigQuery, or Microsoft APS.
- R version 3.5.0 or newer
- On Windows: [RTools](http://cran.r-project.org/bin/windows/Rtools/)
- [Java](http://java.com)
- 25 GB of free disk space

See [these instructions](https://ohdsi.github.io/MethodsLibrary/rSetup.html) on how to set up the R environment on Windows.

How to run
==========
1. In `R`, use the following code to install the dependencies:

	```r
	install.packages("devtools")
	library(devtools)
	install_github("ohdsi/ParallelLogger", ref = "v1.1.1")
	install_github("ohdsi/SqlRender", ref = "v1.6.3")
	install_github("ohdsi/DatabaseConnector", ref = "v2.4.1")
	```

	If you experience problems on Windows where rJava can't find Java, one solution may be to add `args = "--no-multiarch"` to each `install_github` call, for example:
	
	```r
	install_github("ohdsi/SqlRender", args = "--no-multiarch")
	```
	
	Alternatively, ensure that you have installed only the 64-bit versions of R and Java, as described in [the Book of OHDSI](https://ohdsi.github.io/TheBookOfOhdsi/OhdsiAnalyticsTools.html#installR)
	
2. In `R`, use the following `devtools` command to install the ConceptPrevalence package:

	```r
	devtools::install_github('ABMI/ConceptPrevalence')
	```
	
3. Once installed, you can execute the study by modifying and using the code below. For your convenience, this code is also provided under `extras/CodeToRun.R`:

	```r
	library(ConceptPrevalence)
  
	# Minimum cell count when exporting data:
	minCellCount <- 5
	
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
            oracleTempSchema = oracleTempSchema,
            outputFolder = outputFolder,
            databaseId = databaseId,
            measurement = T,
            procedure = T,
            device = T,
            minCellCount = 5)
	```

4. Upload the file ```outputFolder/Results<DatabaseId>.zip``` in the output folder to the study coordinator:

License
=======
The ConceptPrevalence package is licensed under Apache License 2.0

Development
===========
ConceptPrevalence was developed in ATLAS and R Studio.

### Development status

[Under development]
