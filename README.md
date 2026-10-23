# Flood-It! Growth Analysis: Why New Players Leave on Day 1

**Using GA4 event data from a mobile puzzle game, I found that 79% of new players never return after their first day. Players who win a level on day 0 come back 2.4x more often, and most players who don't win quit mid-level before ever losing. I propose a shorter first level to secure an early win, with a fully designed A/B test to validate it.**

> Role perspective: Growth / Product. The goal is not only to report metrics, but to show how each result was interpreted, which decision it led to, and how success would be measured.

---

## 1. The Problem

New players keep arriving, but the team doesn't know:
- How many of them keep playing
- At which point they are lost
- What could bring them back

## 2. Data

| | |
|---|---|
| Source | Google's public GA4 / Firebase sample dataset for *Flood-It!* (`firebase-public-project.analytics_153293282`) |
| Tool | BigQuery (SQL) |
| Size | 5.7M events, 15,175 players, 114 days (2018-06-12 to 2018-10-03) |
| New players in period | 4,319 (only 28% of all players had their `first_open` in this window) |

**Key decision:** Retention is calculated **only on new players**, because returning players' first day is unknown.

## 3. Data Quality Check

Daily active users jumped from ~430 to ~1,200 on 7 days between June 18 and July 1, with **zero new users** on those days.

Investigation (see `sql/03_anomaly_check.sql`):
- The spike came almost entirely from `screen_view` (429 → 1,214 users), while `user_engagement` barely moved (429 → 566).
- Gameplay events were internally inconsistent: more levels ended, but far fewer were completed (274 → 90).

**Conclusion:** A data artifact from obfuscation, not a real event.

**Decisions:**
1. DAU is defined as users with a `user_engagement` event (GA4 active-user logic). This removed most of the June 18-19 spike.
2. June 25 - July 1 stayed inflated under every definition, so **the analysis window starts on 2018-07-02**. Losing ~10% of new users was an acceptable trade-off for reliable retention numbers.

## 4. Player Overview (July - October)

- Engaged DAU grew from ~400 to ~500+
- New players grew from ~30 to ~50 per day
- ~1.35 sessions per active player per day
- **Monetization is ad-driven:** 354 players watched rewarded ads, only 27 made an in-app purchase
- **Virality is near zero:** 246 players sent a friend challenge, only 4 were accepted
- **Push notifications are nearly unused:** 1 `notification_foreground` event in the whole dataset

## 5. Retention

Cohort: new players with `first_open` between 2018-07-02 and 2018-09-03 (n = 2,538), so that D30 is measurable for everyone.

| | D1 | D7 | D30 |
|---|---|---|---|
| **Flood-It!** | **20.9%** | **5.9%** | **1.8%** |
| All mobile games (median) | ~22% | ~4% | ~0.7% |
| Puzzle games (average) | ~32% | ~12% | ~5% |

**Interpretation:** Retention is around the overall market median, but **~11 points below the puzzle genre on D1**. The biggest loss happens on day 1: **79 of every 100 new players never return.** The investigation therefore focuses on the first-day experience.

## 6. Why Do Players Leave?

### What players do on day 0 vs. whether they return (`sql/06_day0_segments.sql`)

| Day-0 behavior | Share of new players | D1 retention |
|---|---|---|
| Did not play | 14.1% | 12.3% |
| Played but never won | 26.6% | 11.3% |
| Played and won | 59.3% | **27.2%** |

- Players who win a level on day 0 return **2.4x more often**.
- Even winners stay below the puzzle average (~32%), so there is also **no strong reason to come back**.

### Did "played but never won" players struggle? (`sql/07_never_won_attempts.sql`)

| Attempts on day 0 | Share | Avg. fails | D1 |
|---|---|---|---|
| 1 | 35.7% | 0.1 | 9.1% |
| 2-3 | 31.9% | 0.6 | 9.8% |
| 4-9 | 22.4% | 1.4 | 15.2% |
| 10+ | 10.1% | 3.0 | 14.7% |

**68% tried at most 3 times and almost never lost.** They abandoned levels mid-way.

**Diagnosis: Players weren't beaten, they got bored.** The main issue is the first impression, not difficulty.

> ⚠️ These are correlations, not causation. Players who win may simply be more skilled or more interested in puzzles. This is why the recommendation below is paired with an A/B test.

## 7. Recommendations

### Options considered
| Idea | Decision | Why |
|---|---|---|
| Make the game harder | ❌ Rejected | Fewer day-0 wins would likely lower D1, since winners return 2.4x more |
| Gift extra moves at the start | ❌ Rejected | Extra moves help players who run out of moves, but most never-won players quit before running out. It solves difficulty, not boredom |
| **Shorter first level (~30 sec)** | ✅ **Test first** | Gives an early win before boredom sets in and creates curiosity for the next level |
| Daily streak rewards | ⏭️ Test second | Targets winners who don't return, but costs more to build and needs weeks to measure D7 |

### Prioritization
| | Shorter first level | Daily streak |
|---|---|---|
| Reach | 27% of new players | 59% of new players |
| Cost | Low | Medium (new system) |
| Speed to result | Fast (D1) | Slow (D7 / D30) |

**The shorter first level is a quick win: cheap, fast to measure, and low-risk.**

## 8. A/B Test Design

| | |
|---|---|
| **Hypothesis** | If we shorten the first level to ~30 seconds for new players, D1 retention will increase, because day-0 winners return 2.4x more often and 68% of never-won players abandon levels before losing |
| **Groups** | New players randomly assigned 50/50: A (control, current game) / B (shorter first level). Random assignment prevents factors like platform (iOS users retain better than Android) from biasing results |
| **Primary metric** | New-player D1 retention (baseline 20.9%) |
| **Secondary metric** | Share of new players completing at least one level on day 0 (baseline 59.3%) |
| **Guardrail metrics** | Rewarded ad views per new player (must not drop, since revenue is ad-driven) and D7 retention (must not drop) |
| **Sample size** | ~800 players per group to detect a +6 point lift (95% confidence, 80% power) |
| **Duration** | ~6 weeks at ~40 new players per day |
| **Decision rule (set before the test)** | Clearly better → roll out · flat but positive → extend the test · worse, or a guardrail drops → stop |

**Trade-off:** Detecting a smaller +4 point lift would require ~1,730 players per group (~3 months). I chose the faster 6-week test and accept that a small effect may go undetected. A 2-week test was rejected: with ~280 players per group, the result would mostly be noise.

## 9. Potential Impact (Scenario, Not a Result)

No change was actually implemented. The numbers below are an illustrative scenario, kept separate from measured results.

| | Current (D1 21%) | Scenario (D1 27%) |
|---|---|---|
| New players returning on day 1, per month (~1,200 new players) | 252 | 324 |
| **Difference** | | **+72 players / month (+29%)** |

Revenue cannot be calculated directly, because the dataset has no ad revenue per view. Framework for the team:

> **Extra revenue = extra returning players × ad views per player × revenue per ad view**

## 10. Limitations

- The dataset is **obfuscated**; some events are internally inconsistent and some fields contain placeholder values.
- Data is from **2018**; benchmarks are from 2025-2026 reports. Comparisons show direction, not exact gaps.
- The data shows **what** players did, not **why**. Whether the first level felt too easy, confusing or slow is unknown. **Next step:** short player interviews or session recordings.
- Findings are correlational; only the A/B test can confirm causation.

## 11. Repository Structure

```
sql/
  01_dataset_overview.sql      Size and date range of the data
  02_event_overview.sql        What players do in the game
  03_anomaly_check.sql         Investigation of the DAU spike
  04_daily_activity.sql        DAU, new users, sessions over time
  05_retention.sql             D1 / D7 / D30 retention
  06_day0_segments.sql         Day-0 behavior vs D1 retention
  07_never_won_attempts.sql    Why non-winners didn't win
```

## Sources

- [Google: Flood-It! GA4 sample dataset](https://developers.google.com/analytics/bigquery/app-gaming-demo-dataset)
- [GameAnalytics 2026 mobile benchmarks summary](https://investgame.net/wp-content/uploads/2026/01/2026-01-20-Mobile_retention_benchmarks_2026.pdf)
- [Genre retention benchmarks (Mistplay data, via Segwise)](https://segwise.ai/blog/mobile-gaming-app-user-retention-strategies.md)

---

**Author:** Burak Çakır · New Media & Communication, İstanbul Kültür University · [GitHub](https://github.com/BurakCakiir)
