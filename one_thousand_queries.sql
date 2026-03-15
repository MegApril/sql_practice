-- "Instead of doing 1000 tutorials, write 1000 queries." - Ian K

-- 1. Counting number of rows in entire table
SELECT  COUNT(*) AS total_rows_in_table
FROM `police-staffing-spd-west.spd_west.2024` LIMIT 1000

-- 2. Counting 2024 events in Queens Sector
SELECT COUNT(*) AS number_of_queen_events
FROM `police-staffing-spd-west.spd_west.2024`
WHERE dispatch_sector = "QUEEN";

-- 3. Counting 2024 events in Kings Sector
SELECT COUNT(*) AS number_of_king_events
FROM `police-staffing-spd-west.spd_west.2024`
WHERE dispatch_sector = "KING";

-- 4. Counting 2024 events in Marys Sector
SELECT COUNT(*) AS number_of_mary_events
FROM `police-staffing-spd-west.spd_west.2024`
WHERE dispatch_sector = "MARY";

-- 5. Counting 2024 events in Davids Sector
SELECT COUNT(*) AS number_of_david_events
FROM `police-staffing-spd-west.spd_west.2024`
WHERE dispatch_sector = "DAVID";

-- 6. Finding earliest 2024 event
SELECT MIN(cad_event_original_time_queued) AS earliest_event
FROM `police-staffing-spd-west.spd_west.2024`;

-- 7. Finding latest 2024 event !! This returned December 31st at 12:XX PM - could indicate a time issue but data type is a string, not a datetime at this point so the issue could be related to that too.
SELECT MAX(cad_event_original_time_queued) AS latest_event
FROM `police-staffing-spd-west.spd_west.2024`;

-- 8. Counting events in each sector in 1 query
SELECT
  dispatch_sector,
  COUNT(*) AS count_of_events_in_dispatch_sector
FROM `police-staffing-spd-west.spd_west.2024`
GROUP BY dispatch_sector;

-- 9. Counting each call type
SELECT
  final_call_type,
  COUNT(*) AS count_of_call_types
FROM `police-staffing-spd-west.spd_west.2024`
GROUP BY final_call_type
ORDER BY count_of_call_types DESC;

-- 10. Attempting to see if Date would be returned from `cad_event_original_time_queued`. Unsuprisingly, this does not work yet.
SELECT DATE(cad_event_original_time_queued) as DATE
FROM `police-staffing-spd-west.spd_west.2024`
LIMIT 5;

-- 11. Returns how many rows have whitespace
SELECT 
  initial_call_type,
  LENGTH(TRIM(initial_call_type)) <> LENGTH(initial_call_type) AS has_leading_trailing_whitespace
FROM `police-staffing-spd-west.spd_west.2024`
ORDER BY has_leading_trailing_whitespace ASC;

-- 12. Replaces dash with space in initial call types
SELECT 
  initial_call_type,
  REPLACE(initial_call_type, '-', ' ') AS call_type_no_symbols
FROM `police-staffing-spd-west.spd_west.2024`;

-- 13. Gives number of events based on sector in a sentence.
SELECT 
  'Sector '|| LOWER(dispatch_sector) || ' contained ' || COUNT(*) || ' events in 2024.'
FROM `police-staffing-spd-west.spd_west.2024`
GROUP BY dispatch_sector;

-- 14. Gives values of records with or without trailing and leading whitespace
SELECT 
  has_leading_trailing_whitespace,
  COUNT(*)
  FROM
    (SELECT 
      initial_call_type,
      LENGTH(TRIM(initial_call_type)) <> LENGTH(initial_call_type) AS has_leading_trailing_whitespace
    FROM `police-staffing-spd-west.spd_west.2024`
    ORDER BY has_leading_trailing_whitespace ASC)

GROUP BY has_leading_trailing_whitespace;

-- 15. Updates record values in `cad_event_clearance_description` to remove white spaces
UPDATE police-staffing-spd-west.spd_west.twenty_twenty_four_staging
SET cad_event_clearance_description = TRIM(cad_event_clearance_description)
WHERE LENGTH(cad_event_clearance_description) != LENGTH(TRIM(cad_event_clearance_description));

-- 16. Adding column
ALTER TABLE `police-staffing-spd-west.spd_west.twenty_twenty_four_staging`
ADD COLUMN total_time INT64;

-- 17. Drop the column
ALTER TABLE `police-staffing-spd-west.spd_west.twenty_twenty_four_staging`
DROP COLUMN total_time;

-- 18. Re-name the table (not actually going to rename, just for the example)
ALTER TABLE `police-staffing-spd-west.spd_west.twenty_twenty_four_staging`
RENAME to `2024_staging`;

-- 19. Inspecting schema
SELECT *
FROM `police-staffing-spd-west.spd_west.INFORMATION_SCHEMA.COLUMNS`

-- 20. Checking for cad event numbers with multiple entries, possible insights could be most complex case as the top cad event number has 47 line items associated with it. 
SELECT 
  COUNT(*) as cad_duplicates_count,
  cad_event_number
FROM `police-staffing-spd-west.spd_west.twenty_twenty_four_staging`
GROUP BY cad_event_number
ORDER BY cad_duplicates_count DESC;

-- 21. Finding number of different call_types  in 2024
SELECT
  COUNT(*) AS call_type_aggregated,
  call_type
FROM `police-staffing-spd-west.spd_west.twenty_twenty_four_staging`
GROUP BY call_type;

-- 22. Finding number of calls associated with different priority levels, grouped by priority and ordered to indicate which priority has the highest number of calls
SELECT
  COUNT(*) AS number_of_calls_by_priority,
  priority
FROM `police-staffing-spd-west.spd_west.twenty_twenty_four_staging`
GROUP BY priority
ORDER BY priorities DESC;

--23. How many calls were responded to by CARE, SPD or both.
SELECT 
  cad_event_response_category,
  COUNT(*) AS number_of_calls_by_response_category
FROM `police-staffing-spd-west.spd_west.twenty_twenty_four_staging`
GROUP BY cad_event_response_category;

--24. Fixing datatype in date/time categories. Different columns use different formats. Additionally, while some columns have numeric month types (%m), others have abbreviated month names, necessitating %b.
CREATE OR REPLACE TABLE `police-staffing-spd-west.spd_west.twenty_twenty_four_staging` AS 
SELECT
  * EXCEPT(cad_event_original_time_queued, first_spd_call_sign_at_scene_time, call_sign_inservice_time, call_sign_at_scene_time, last_spd_call_sign_dispatch_time, first_spd_call_sign_dispatch_time, call_sign_dispatch_time, cad_event_arrived_time),
  SAFE.PARSE_DATETIME('%m/%d/%Y %I:%M:%S %p', cad_event_original_time_queued)
    AS cad_event_original_time_queued,
  SAFE.PARSE_DATETIME('%Y %b %d %I:%M:%S %p', first_spd_call_sign_at_scene_time)
    AS first_spd_call_sign_at_scene_time,
  SAFE.PARSE_DATETIME('%Y %b %d %I:%M:%S %p', call_sign_inservice_time)
    AS call_sign_inservice_time,
  SAFE.PARSE_DATETIME('%Y %b %d %I:%M:%S %p', call_sign_at_scene_time)
    AS call_sign_at_scene_time,
  SAFE.PARSE_DATETIME('%Y %b %d %I:%M:%S %p', last_spd_call_sign_dispatch_time)
    AS last_spd_call_sign_dispatch_time,
  SAFE.PARSE_DATETIME('%Y %b %d %I:%M:%S %p', first_spd_call_sign_dispatch_time)
    AS first_spd_call_sign_dispatch_time,
  SAFE.PARSE_DATETIME('%Y %b %d %I:%M:%S %p', call_sign_dispatch_time)
    AS call_sign_dispatch_time,
  SAFE.PARSE_DATETIME('%Y %b %d %I:%M:%S %p', cad_event_arrived_time)
    AS cad_event_arrived_time,
FROM `police-staffing-spd-west.spd_west.twenty_twenty_four_staging`

--25. Verifying correct casting by removing commas from columns that will be changed to INT64.
SELECT
  * EXCEPT(care_call_sign_total_service_time_in_seconds, dispatch_latitude, dispatch_longitude, coresponse_call_sign_total_service_time_in_seconds, spd_call_sign_total_service_time_in_seconds, call_sign_total_service_time_in_seconds, first_spd_call_sign_dispatch_delay_time_in_seconds, first_spd_call_sign_response_time_in_seconds, call_sign_dispatch_delay_time_in_seconds, call_sign_response_time_seconds, cad_event_first_response_time_seconds),
  REGEXP_REPLACE(care_call_sign_total_service_time_in_seconds, ',', '') AS care_call_sign_total_service_time_in_seconds,
  REGEXP_REPLACE(coresponse_call_sign_total_service_time_in_seconds, ',', '') AS coresponse_call_sign_total_service_time_in_seconds,
  REGEXP_REPLACE(spd_call_sign_total_service_time_in_seconds, ',', '') AS spd_call_sign_total_service_time_in_seconds,
  REGEXP_REPLACE(call_sign_total_service_time_in_seconds, ',', '') AS call_sign_total_service_time_in_seconds,
  REGEXP_REPLACE(first_spd_call_sign_dispatch_delay_time_in_seconds, ',', '') AS first_spd_call_sign_dispatch_delay_time_in_seconds,
  REGEXP_REPLACE(first_spd_call_sign_response_time_in_seconds, ',', '') AS first_spd_call_sign_response_time_in_seconds,
  REGEXP_REPLACE(call_sign_dispatch_delay_time_in_seconds, ',', '') AS call_sign_dispatch_delay_time_in_seconds,
  REGEXP_REPLACE(call_sign_response_time_seconds, ',', '') AS call_sign_response_time_seconds,
  REGEXP_REPLACE(cad_event_first_response_time_seconds, ',', '') AS cad_event_first_response_time_seconds,
FROM `police-staffing-spd-west.spd_west.twenty_twenty_four_staging`;

--26.  Updating table to reflect the previously run datatype changes
CREATE OR REPLACE TABLE `police-staffing-spd-west.spd_west.twenty_twenty_four_staging` AS
SELECT
  * EXCEPT(care_call_sign_total_service_time_in_seconds, dispatch_latitude, dispatch_longitude, coresponse_call_sign_total_service_time_in_seconds, spd_call_sign_total_service_time_in_seconds, call_sign_total_service_time_in_seconds, first_spd_call_sign_dispatch_delay_time_in_seconds, first_spd_call_sign_response_time_in_seconds, call_sign_dispatch_delay_time_in_seconds, call_sign_response_time_seconds, cad_event_first_response_time_seconds),
  REGEXP_REPLACE(care_call_sign_total_service_time_in_seconds, ',', '') AS care_call_sign_total_service_time_in_seconds,
  REGEXP_REPLACE(coresponse_call_sign_total_service_time_in_seconds, ',', '') AS coresponse_call_sign_total_service_time_in_seconds,
  REGEXP_REPLACE(spd_call_sign_total_service_time_in_seconds, ',', '') AS spd_call_sign_total_service_time_in_seconds,
  REGEXP_REPLACE(call_sign_total_service_time_in_seconds, ',', '') AS call_sign_total_service_time_in_seconds,
  REGEXP_REPLACE(first_spd_call_sign_dispatch_delay_time_in_seconds, ',', '') AS first_spd_call_sign_dispatch_delay_time_in_seconds,
  REGEXP_REPLACE(first_spd_call_sign_response_time_in_seconds, ',', '') AS first_spd_call_sign_response_time_in_seconds,
  REGEXP_REPLACE(call_sign_dispatch_delay_time_in_seconds, ',', '') AS call_sign_dispatch_delay_time_in_seconds,
  REGEXP_REPLACE(call_sign_response_time_seconds, ',', '') AS call_sign_response_time_seconds,
  REGEXP_REPLACE(cad_event_first_response_time_seconds, ',', '') AS cad_event_first_response_time_seconds,
FROM `police-staffing-spd-west.spd_west.twenty_twenty_four_staging`;

-- 27. Casting previous columns that included seconds as INT64 data types
CREATE OR REPLACE TABLE `police-staffing-spd-west.spd_west.twenty_twenty_four_staging` AS
SELECT
  * EXCEPT(care_call_sign_total_service_time_in_seconds, coresponse_call_sign_total_service_time_in_seconds, spd_call_sign_total_service_time_in_seconds, call_sign_total_service_time_in_seconds, first_spd_call_sign_dispatch_delay_time_in_seconds, first_spd_call_sign_response_time_in_seconds, call_sign_dispatch_delay_time_in_seconds, call_sign_response_time_seconds, cad_event_first_response_time_seconds),
  SAFE_CAST(care_call_sign_total_service_time_in_seconds AS INT64) AS care_call_sign_total_service_time_in_seconds,
  SAFE_CAST(coresponse_call_sign_total_service_time_in_seconds AS INT64) AS coresponse_call_sign_total_service_time_in_seconds,
  SAFE_CAST(spd_call_sign_total_service_time_in_seconds AS INT64) AS spd_call_sign_total_service_time_in_seconds,
  SAFE_CAST(call_sign_total_service_time_in_seconds AS INT64) AS call_sign_total_service_time_in_seconds,
  SAFE_CAST(first_spd_call_sign_dispatch_delay_time_in_seconds AS INT64) AS first_spd_call_sign_dispatch_delay_time_in_seconds,
  SAFE_CAST(first_spd_call_sign_response_time_in_seconds AS INT64) AS first_spd_call_sign_response_time_in_seconds,
  SAFE_CAST(call_sign_dispatch_delay_time_in_seconds AS INT64) AS call_sign_dispatch_delay_time_in_seconds,
  SAFE_CAST(call_sign_response_time_seconds AS INT64) AS call_sign_response_time_seconds,
  SAFE_CAST(cad_event_first_response_time_seconds AS INT64) AS cad_event_first_response_time_seconds,
FROM `police-staffing-spd-west.spd_west.twenty_twenty_four_staging`;

-- 28. Playing with substrings
SELECT 
  call_type, 
  SUBSTR(call_type, 0, 5) AS call_type_substring
FROM `police-staffing-spd-west.spd_west.twenty_twenty_four_staging`
LIMIT 5;

-- 29. Playing with INSTRING
SELECT 
  INSTR(UPPER(call_type), 'OF') AS position_of_of,
  call_type
FROM `police-staffing-spd-west.spd_west.twenty_twenty_four_staging`
WHERE INSTR(UPPER(call_type), 'OF') > 0;
--LIMIT 5;

-- 30. Checking that cleaning `cad_event_arrived_time` didn't result in wrongful NULL's by verifying that the number of NULL values matches in both tables.
SELECT 
 cad_event_number,
 cad_event_arrived_time
FROM `police-staffing-spd-west.spd_west.2024`
WHERE cad_event_arrived_time IS NULL;

SELECT 
 cad_event_number,
 cad_event_arrived_time
FROM `police-staffing-spd-west.spd_west.twenty_twenty_four_staging`
WHERE cad_event_arrived_time IS NULL;

-- 31. Number of unique CAD events
SELECT 
 COUNT(DISTINCT(cad_event_number)),
FROM `police-staffing-spd-west.spd_west.twenty_twenty_four_staging`;

-- 32. Determining which cad events had the most entries, which could indicate the most complex or most time consuming cases
SELECT 
 cad_event_number,
 COUNT(cad_event_number) AS number_of_entries
FROM `police-staffing-spd-west.spd_west.twenty_twenty_four_staging`
GROUP BY  cad_event_number
ORDER BY number_of_entries DESC;

-- 33. Find all calls where the response time was longer than the average response time for the entire dataset.
SELECT *
FROM `police-staffing-spd-west.spd_west.twenty_twenty_four_staging`
WHERE (cad_event_first_response_time_seconds/60) >
-- returns average response time for 2024 calls
(SELECT 
  AVG(response_time_in_minutes)
  FROM
    -- Inner subquery that returns response time in minutes for each distinct cad event.
    (SELECT 
      DISTINCT(cad_event_number),
      (cad_event_first_response_time_seconds/60) AS response_time_in_minutes
    FROM `police-staffing-spd-west.spd_west.twenty_twenty_four_staging`))

-- 34.
