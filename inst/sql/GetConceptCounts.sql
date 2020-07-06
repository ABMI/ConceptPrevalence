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
IF OBJECT_ID('tempdb..#concept_count', 'U') IS NOT NULL
	DROP TABLE #concept_count;

IF OBJECT_ID('tempdb..#concept_count_measurement', 'U') IS NOT NULL
	DROP TABLE #concept_count_measurement;

IF OBJECT_ID('tempdb..#concept_count_procedure', 'U') IS NOT NULL
	DROP TABLE #concept_count_procedure;

IF OBJECT_ID('tempdb..#concept_count_device', 'U') IS NOT NULL
	DROP TABLE #concept_count_device;

CREATE TABLE #concept_count (
	concept_id BIGINT,
	concept_count INT,
	table_name varchar(32)
	);

-- Concept prevalence by tables
{@measurement} ? {
	SELECT measurement_concept_id, count(*) as concept_count, 'measurement' as table_name
	INTO #concept_count_measurement
	FROM @database_schema.measurement
	GROUP BY measurement_concept_id
;
 INSERT INTO #concept_count (
   	 concept_id,
		 concept_count,
		 table_name
	)
SELECT measurement_concept_id, concept_count, table_name
FROM #concept_count_measurement
WHERE concept_count >= @minCellCount
;
}

{@procedure} ? {
	SELECT procedure_concept_id, count(*) as concept_count, 'procedure' as table_name
	INTO #concept_count_procedure
	FROM @database_schema.procedure_occurrence
	GROUP BY procedure_concept_id
	;
	INSERT INTO #concept_count (
  	 concept_id,
		 concept_count,
		 table_name
	)
SELECT procedure_concept_id, concept_count, table_name
FROM #concept_count_procedure
WHERE concept_count >= @minCellCount
;
}

{@device} ? {
	SELECT device_concept_id, count(*) as concept_count, 'device' as table_name
	INTO #concept_count_device
	FROM @database_schema.device_exposure
	GROUP BY device_concept_id
	;
	 INSERT INTO #concept_count (
   	 concept_id,
		 concept_count,
		 table_name
	)
SELECT device_concept_id, concept_count, table_name
FROM #concept_count_device
WHERE concept_count >= @minCellCount
;
}


--SELECT * from #concept_count;

{@measurement} ? {
TRUNCATE TABLE #concept_count_measurement;
DROP TABLE #concept_count_measurement;
}

{@procedure} ? {
TRUNCATE TABLE #concept_count_procedure;
DROP TABLE #concept_count_procedure;
}

{@device} ? {
TRUNCATE TABLE concept_count_device;
DROP TABLE concept_count_device;
}

--TRUNCATE TABLE #concept_count;
--DROP TABLE #concept_count;
