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

-- Page 116 checking for duplicates
