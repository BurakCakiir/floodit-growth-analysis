-- 01 | Dataset overview
-- Question: How much data do we have? How many players, over what period?
-- Result: 5.7M events | 15,175 players | 114 days (2018-06-12 to 2018-10-03)

SELECT
  COUNT(*) AS event_count,
  COUNT(DISTINCT user_pseudo_id) AS user_count,
  COUNT(DISTINCT event_date) AS day_count,
  MIN(event_date) AS first_day,
  MAX(event_date) AS last_day
FROM `firebase-public-project.analytics_153293282.events_*`
