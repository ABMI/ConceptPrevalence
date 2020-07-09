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

CREATE TABLE #concept_info (
	concept_id BIGINT,
	concept_count BIGINT,
	table_name varchar(32),
	domain_id varchar(32),
	standard_concept varchar(1),
	concept_name varchar(255),
	invalid_reason varchar(1)
	);

-- get concept info
 INSERT INTO #concept_info (
   	 concept_id,
		 concept_count,
		 table_name,
		 domain_id,
		 standard_concept,
		 concept_name,
		 invalid_reason
	)
SELECT a.concept_id, a.concept_count, a.table_name, b.domain_id, b.standard_concept, b.concept_name, b.invalid_reason
FROM #temp_concept A LEFT JOIN @database_schema.concept b
	ON a.concept_id = b.concept_id;
;
