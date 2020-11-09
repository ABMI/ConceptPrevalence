/************************************************************************
Copyright 2020 Observational Health Data Sciences and Informatics

This file is part of ConceptPrevalence

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
************************************************************************/
IF OBJECT_ID('tempdb..#table_count', 'U') IS NOT NULL
	DROP TABLE #table_count;

CREATE TABLE #table_count (
	table_count BIGINT,
	table_name varchar(32)
	);

-- Table counts

INSERT INTO #table_count (
  table_count,
  table_name
  )
	  SELECT count(*) as table_count, 'person' as table_name
	  FROM @database_schema.person
	  UNION
  	SELECT count(*) as table_count, 'measurement' as table_name
  	FROM @database_schema.measurement
  	UNION
  	SELECT count(*) as table_count, 'procedure' as table_name
  	FROM @database_schema.procedure_occurrence
  	UNION
  	SELECT count(*) as table_count, 'device' as table_name
  	FROM @database_schema.device_exposure
;

--TRUNCATE TABLE #table_count;
--DROP TABLE #table_count;
