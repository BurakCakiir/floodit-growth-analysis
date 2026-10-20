-- 02 | Event overview
-- Question: What do players do in the game? Which actions are most common?
-- Key findings:
--   * Only 4,319 of 15,175 users (28%) had first_open in this period ->
--     retention will be calculated on new users only
--   * 67% started a quickplay level, only 37% completed one
--   * 42% of finished quickplay levels end in failure -> difficulty hypothesis
--   * Virality is near zero: 246 challenge_a_friend, 4 challenge_accepted
--   * Monetization is ad-driven: 27 IAP users vs 354 ad_reward users

SELECT
  event_name,
  COUNT(*) AS event_count,
  COUNT(DISTINCT user_pseudo_id) AS user_count
FROM `firebase-public-project.analytics_153293282.events_*`
GROUP BY event_name
ORDER BY event_count DESC
