-- 04 | Daily activity: DAU, new users, sessions
-- Finding: Redefining DAU as users with user_engagement removes most of the
--          Jun 18-19 spike, but Jun 25 - Jul 1 stays inflated (~800+ engaged users,
--          ~1,200 sessions vs ~400 / ~600 on normal days).
-- Decision: Analysis window starts on 2018-07-02. Cleaner data is worth losing
--           ~10% of new users (~425 of 4,319).
-- Trend (Jul-Oct): Engaged DAU grows from ~400 to ~500+, new users from ~30 to ~50/day,
--          ~1.35 sessions per active user per day.

SELECT
  PARSE_DATE('%Y%m%d', event_date) AS date,
  COUNT(DISTINCT user_pseudo_id) AS dau_all_events,
  COUNT(DISTINCT IF(event_name = 'user_engagement', user_pseudo_id, NULL)) AS dau_engaged,
  COUNT(DISTINCT IF(event_name = 'first_open', user_pseudo_id, NULL)) AS new_users,
  COUNTIF(event_name = 'session_start') AS sessions
FROM `firebase-public-project.analytics_153293282.events_*`
GROUP BY date
ORDER BY date
