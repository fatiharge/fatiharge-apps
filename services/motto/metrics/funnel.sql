-- The one question this version asks: does the result card get shared.
--
-- Read top to bottom. Every row is a step someone reached at least once, so
-- the counts only ever fall — a step that rises means an event is being sent
-- twice, not that more people arrived.
--
--   docker compose exec -T db psql -U motto -d motto < funnel.sql
WITH reached AS (
    SELECT name, count(DISTINCT device_id) AS devices
    FROM events
    WHERE occurred_at >= now() - interval '30 days'
    GROUP BY name
),
steps(step, name) AS (
    VALUES (1, 'app_open'),
           (2, 'test_start'),
           (3, 'test_complete'),
           (4, 'result_view'),
           (5, 'share_sheet_open'),
           (6, 'share_complete')
)
SELECT steps.step,
       steps.name,
       coalesce(reached.devices, 0) AS devices,
       -- Against the step above rather than against the top: a funnel read
       -- against its first row hides which step is the one losing people.
       round(
           100.0 * coalesce(reached.devices, 0)
               / nullif(lag(coalesce(reached.devices, 0)) OVER (ORDER BY steps.step), 0),
           1
       ) AS pct_of_previous
FROM steps
         LEFT JOIN reached ON reached.name = steps.name
ORDER BY steps.step;

-- Android cannot see which app was picked and answers `unavailable` to every
-- share. Splitting the counts keeps that visible instead of letting it read as
-- a platform that shares less.
SELECT properties ->> 'status' AS share_status,
       count(*)                AS shares
FROM events
WHERE name = 'share_complete'
  AND occurred_at >= now() - interval '30 days'
GROUP BY 1
ORDER BY 2 DESC;

-- Where the test is abandoned. The steepest drop between two neighbours is the
-- question to rewrite.
SELECT (properties ->> 'n')::int AS question,
       count(DISTINCT device_id) AS devices
FROM events
WHERE name = 'question_answered'
  AND occurred_at >= now() - interval '30 days'
GROUP BY 1
ORDER BY 1;
