-- 03 | Anomaly check: Jun 17 (normal) vs Jun 18 (spike)
-- Context: DAU jumped from ~430 to ~1,200 on 7 days between Jun 18 - Jul 1, 2018,
--          with zero new users on those days.
-- Finding: The spike comes almost entirely from screen_view (429 -> 1,214 users),
--          while user_engagement barely moved (429 -> 566). Gameplay events are
--          internally inconsistent (level_end up, level_complete down 274 -> 90).
-- Conclusion: Data artifact from dataset obfuscation, not a real event.
-- Decision: Define DAU as users with a user_engagement event (GA4 active user logic).

SELECT
  event_name,
  COUNT(DISTINCT IF(event_date = '20180617', user_pseudo_id, NULL)) AS users_jun17_normal,
  COUNT(DISTINCT IF(event_date = '20180618', user_pseudo_id, NULL)) AS users_jun18_spike
FROM `firebase-public-project.analytics_153293282.events_*`
WHERE _TABLE_SUFFIX IN ('20180617', '20180618')
GROUP BY event_name
ORDER BY users_jun18_spike DESC
