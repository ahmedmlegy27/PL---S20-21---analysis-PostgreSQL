-- create matches table and insert csv file
drop table if exists matches;
CREATE TABLE matches (
    div      TEXT,
    date     DATE,
    time     TIME,
    hometeam TEXT,
    awayteam TEXT,
    fthg     SMALLINT,
    ftag     SMALLINT,
    ftr      CHAR(1),
    hthg     SMALLINT,
    htag     SMALLINT,
    htr      CHAR(1),
    referee  TEXT,
    hs       SMALLINT,
    "as"       SMALLINT,
    hst      SMALLINT,
    ast      SMALLINT,
    hf       SMALLINT,
    af       SMALLINT,
    hc       SMALLINT,
    ac       SMALLINT,
    hy       SMALLINT,
    ay       SMALLINT,
    hr       SMALLINT,
    ar       SMALLINT
);
SELECT *
from matches;
ALTER TABLE matches
ADD COLUMN id BIGSERIAL PRIMARY KEY;

-- 🟢 Level 1 — Beginner (SELECT, WHERE, ORDER BY)

-- Q1	List all matches played along with the hom
e team, away team, and full-time result.

SELECT hometeam, awayteam, ftr
from matches;

-- Q2   Show all matches where the home team won (FTR = 'H'), ordered by date

select *
from matches
where ftr = 'H';

-- Q3   Find all matches that ended in a draw 

select *
from matches
where ftr = 'D';

-- Q4	List all distinct referees who officiated matches in the season.

select distinct referee
from matches;

-- Q5	Show all matches where Manchester City was the home team.
SELECT *
from matches
where hometeam = 'Man City';

--Q6	List the top 10 highest-scoring matches by total goals (FTHG + FTAG), ordered descending.
  
SELECT *
from matches
order by (fthg + ftag) DESC
limit 10;

-- Q7	Find all matches where the away team scored more than 3 goals.

select *
from matches 
where ftag > 3;

-- Q8	Show matches where both teams had 0 goals at half time (HTHG = 0 AND HTAG = 0).

select *
from matches 
where hthg = 0 and htag = 0;

-- Q9	List all matches involving Liverpool — either as home or away team.

select * 
from matches
where hometeam = 'Liverpool' or awayteam = 'Liverpool';

-- Q10	Find matches where the half-time result differed from the full-time result (HTR <> FTR).

select *
from matches
where ftr <> htr;

-- 🔵 Level 2 — Intermediate (Aggregations, GROUP BY, HAVING)

--Q11	Count the total number of matches played in the season.

SELECT count(*) AS total_matches
from matches;

-- Q12	Calculate the total goals scored across all matches.

select sum(fthg + ftag) as total_goals
from matches;

-- Q13	For each home team, count how many home wins, draws, and losses they had.
SELECT
	hometeam,
	SUM(
		CASE
			WHEN ftr = 'H' THEN 1
			ELSE 0
		END
	) AS home_wins,
	SUM(
		CASE
			WHEN ftr = 'A' THEN 1
			ELSE 0
		END
	) AS home_loses,
	SUM(
		CASE
			WHEN ftr = 'D' THEN 1
			ELSE 0
		END
	) AS home_draws
FROM
	matches
GROUP BY
	hometeam
ORDER BY
	2 DESC;
-- Q14	Find the average number of goals scored per match (home + away combined).

SELECT
	ROUND(AVG(fthg + ftag), 2) AS avg_goals
FROM
	matches;

-- Q15	Which referee officiated the most matches? Show top 5.

select referee, count(*) as total_matches
from matches
group by matches
order by total_matches desc;

-- Q16	List teams that conceded more than 40 goals at home across the season.

select hometeam, sum(fthg) as home_goals
from matches
group by hometeam
having sum(fthg) > 40;

-- Q17	Calculate the home win rate per team (home wins / total home games * 100).

select hometeam, avg(case when ftr = 'H' then 1
						  ELSE 0 end) * 100 as home_win_rate
from matches
group by hometeam;

-- Q18	Find the match with the biggest goal difference (ABS(FTHG - FTAG)) in the season.

SELECT *
from matches
where (ABS(FTHG - FTAG)) = (select
								max(ABS(FTHG - FTAG))
							from matches);
-- Q19	Show total yellow cards given per referee, only for referees who gave more than 50 yellow cards.

Select referee,
SUM(hy + ay) AS total_yellow
FROM
	matches
GROUP BY
	referee
HAVING
	SUM(hy + ay) > 50;

-- Q20	For each team (home or away), compute their total goals scored across the entire season.

SELECT
	team,
	SUM(goals) AS total_goals
FROM
	(
		SELECT
			hometeam AS team,
			fthg AS goals
		FROM
			matches
		UNION ALL
		SELECT
			awayteam AS team,
			ftag AS goals
		FROM
			matches
	)
GROUP BY
	team;

-- Q21	Build a full league table: for each team, calculate Points (W=3, D=1, L=0), Goals For, Goals Against,
--and Goal Difference, sorted by points descending.
SELECT
	team,
	sum(goals_for) as goals_for,
	sum(goals_against) as goals_against,
	sum(gd) as gd,
	sum(points) as points
FROM
	(
		SELECT
			hometeam AS team,
			case WHEN ftr = 'H' THEN 3
				 WHEN ftr = 'D' THEN 1
				 ELSE 0 END AS points,
			fthg as goals_for,
			ftag AS goals_against,
			fthg - ftag as GD
		FROM matches
		UNION ALL
		SELECT
			awayteam AS team,
			case WHEN ftr = 'A' THEN 3
				 WHEN ftr = 'D' THEN 1
				 ELSE 0 END AS points,
			ftag as goals_for,
			fthg AS golas_against,
			ftag - fthg as GD
		from matches
	)
GROUP BY team
ORDER by points DESC, gd DESC;

-- Q22	Find all matches where a team came from behind at half time to win the full match.
SELECT
	*
FROM
	matches
WHERE
	(
		ftr = 'H'
		AND htr = 'A'
	)
	OR (
		ftr = 'A'
		AND htr = 'H'
	);

-- Q23	Using a subquery, find teams whose average shots on target (HST) as home team is above the overall
--average HST across all teams.

select hometeam, avg(hst)
from matches
group by hometeam
having avg(hst) > (select
						avg(hst)
					FROM matches);
--Q24	Find the team that received the most red cards across the whole season (home + away combined).
SELECT team,
		sum(reds) as total_reds
FROM
	(
		select hometeam as team, hr as reds
		from matches
		UNION All
		select awayteam, ar
		from matches
	)
GROUP by team
order by total_reds DESC
LIMIT 1;

-- Q25	Categorise each match as 'High Scoring' (total goals >= 4), 'Normal' (2-3 goals), 
-- or 'Low Scoring' (0-1 goals), and count how many matches fall into each category.
select category, count(id) as number
FROM
	(
		SELECT *,
				case when (fthg+ftag) >= 4 then 'High Scoring'
					 WHEN (fthg+ftag) between 2 and 3 then 'Normal'
					 else 'Low Scoring' END as category
		from matches)
group by category;

-- Q26	Show each match along with a column indicating whether the result was an upset — 
-- i.e., the away team won while having fewer shots on target (AST < HST).

SELECT
	hometeam,
	awayteam,
	ftr,
	hst,
	ast,
	CASE
		WHEN (
			ftr = 'h'
			AND ast > hst
		)
		OR (
			ftr = 'A'
			AND hst > ast
		) THEN 'upset'
	END AS status
FROM
	matches
where
	(
		ftr = 'h'
		AND ast > hst
	)
		OR (
			ftr = 'A'
			AND hst > ast
		);

-- Q27	Find teams that won more games away from home than at home.
  select a.awayteam as team, a.away_wins, h.home_wins
  FROM
  (select awayteam, count(case when ftr = 'A' then id END) as away_wins
  from matches
  group by awayteam) as a
  INNER join 
  (select hometeam, count(case when ftr = 'H' then id END) as home_wins
  from matches
  group by hometeam) as h
  ON a.awayteam = h.hometeam
  where away_wins > home_wins 

-- Q28	List the top 3 most common scorelines (e.g., 1-0, 2-1) in the season.

SELECT
   concat(greatest(fthg, ftag),'-',
    LEAST(fthg, ftag)) as result,
    COUNT(*) AS matches_count
FROM matches
GROUP BY
    LEAST(fthg, ftag),
    GREATEST(fthg, ftag)
ORDER BY matches_count DESC
limit 3;

-- Q29	For each referee, show the average total goals per match they officiated.

 select referee, round(avg(fthg + ftag),2) as avg_goals
 from matches
 group by referee;

 -- Q30	Find all matches where the number of corners was unequal but the team with fewer corners still won.
SELECT
	hometeam,
	awayteam,
	ftr,
	hc,
	ac
FROM
	matches
WHERE
	(
		hc > ac
		AND ftr = 'A'
	)
	OR (
		hc < ac
		AND ftr = 'h'
	)
 
-- 🔴 Level 4 — Advanced (CTEs, Window Functions)

-- Q31	Using a CTE, build a league table and then select only the top 4 teams (Champions League spots).
with league_table as (
						SELECT
							team,
							sum(goals_for) as goals_for,
							sum(goals_against) as goals_against,
							sum(gd) as gd,
							sum(points) as points
						FROM
							(
								SELECT
									hometeam AS team,
									case WHEN ftr = 'H' THEN 3
										 WHEN ftr = 'D' THEN 1
										 ELSE 0 END AS points,
									fthg as goals_for,
									ftag AS goals_against,
									fthg - ftag as GD
								FROM matches
								UNION ALL
								SELECT
									awayteam AS team,
									case WHEN ftr = 'A' THEN 3
										 WHEN ftr = 'D' THEN 1
										 ELSE 0 END AS points,
									ftag as goals_for,
									fthg AS golas_against,
									ftag - fthg as GD
								from matches
							)
						GROUP BY team
						ORDER by points DESC, gd DESC)

select team
from league_table
limit 4;

-- Q32	Using ROW_NUMBER(), rank matches for each team by the number of goals they scored in each game,
-- partitioned by the team.

SELECT team, goals, row_number() over(partition by team ORDER by goals DESC)
FROM (
		select hometeam as team, fthg as goals
		FROM matches
		UNION all
		select awayteam, ftag
		from matches);
				   
-- Q33	Use RANK() to rank all teams by total goals scored, handling ties correctly.
with league_table as (
						SELECT
							team,
							sum(goals_for) as goals_for,
							sum(goals_against) as goals_against,
							sum(gd) as gd,
							sum(points) as points
						FROM
							(
								SELECT
									hometeam AS team,
									case WHEN ftr = 'H' THEN 3
										 WHEN ftr = 'D' THEN 1
										 ELSE 0 END AS points,
									fthg as goals_for,
									ftag AS goals_against,
									fthg - ftag as GD
								FROM matches
								UNION ALL
								SELECT
									awayteam AS team,
									case WHEN ftr = 'A' THEN 3
										 WHEN ftr = 'D' THEN 1
										 ELSE 0 END AS points,
									ftag as goals_for,
									fthg AS golas_against,
									ftag - fthg as GD
								from matches
							)
						GROUP BY team
						ORDER by points DESC, gd DESC)

select team, goals_for, rank() over(order by goals_for desc)
 from league_table;

-- Q34	Using LAG(), find each team's previous match result and compare it to the current
-- match result to detect winning/losing streaks.
with t1 as(
			select date,
				   hometeam as team,
				   case	
				   		when ftr = 'H' then 'Win'
						WHEN ftr = 'A' then 'Lose'
						ELSE 'Draw' END as match_result
			from matches
			UNION all	
			select date,
				   awayteam,
				   case	
				   		when ftr = 'A' then 'Win'
						WHEN ftr = 'H' then 'Lose'
						ELSE 'Draw' END 
			from matches)
select *,
		lag(match_result,1) over(partition by team order by date) as prev_result
from t1
order by team, date;

-- Q35	Calculate a running total of goals scored by each home team across the season 
-- using SUM() as a window function.
select date, hometeam, fthg,
		sum(fthg) over(partition by hometeam order by date) as running_total
from matches
order by hometeam, date

-- Q36	For each match, use NTILE(4) to divide all matches into quartiles based on total goals scored, 
-- and show how many matches fall in each quartile.
with t1 as(
select
	   date, hometeam,awayteam, fthg,ftag, (fthg+ftag) as total_goals
from matches
),
	t2 as(
select *, ntile(4) over(order by total_goals) as quartile
from t1
)
select quartile, count(*) as n_matches
from t2
group by quartile
order by quartile

-- Q37	Using DENSE_RANK(), produce a table showing each team's rank by 
-- fewest goals conceded (best defence), with no gaps in ranking for ties.

WITH
	t1 AS (
		SELECT
			hometeam AS team,
			ftag AS goals_against
		FROM
			matches
		UNION ALL
		SELECT
			awayteam AS team,
			fthg AS golas_against
		FROM
			matches
	),
	t2 AS (
		SELECT
			team,
			SUM(goals_against) AS goals_against
		FROM
			t1
		GROUP BY
			team
	)
SELECT
	team,
	goals_against,
	DENSE_RANK() OVER (
		ORDER BY
			goals_against
	) as ranking
FROM
	t2;

-- Q38	Using LEAD(), for each match involving Liverpool (home or away), show the result of their next fixture.
with 
	t1 as (
			SELECT
				date,
				hometeam,
				awayteam,
				ftr,
				case when (hometeam = 'Liverpool' and ftr= 'H') OR
				      	  (awayteam = 'Liverpool' and ftr= 'A') then 'win'
					 when (hometeam = 'Liverpool' and ftr= 'A') or 
					      (awayteam = 'Liverpool' and ftr= 'H') then 'lose'
					 else 'Draw' end as reds_result
			FROM
				matches
			WHERE
				
					hometeam = 'Liverpool'
					OR awayteam = 'Liverpool'
			)
select *, lead(reds_result,1) over(order by date)
from t1
order by date;

-- Q39	Write a CTE chain (2 CTEs) to: (1) compute each team's total points, 
-- and (2) compute the gap in points between each team and the league leader.

with league_table as (
						SELECT
							team,
							sum(points) as points
						FROM
							(
								SELECT
									hometeam AS team,
									case WHEN ftr = 'H' THEN 3
										 WHEN ftr = 'D' THEN 1
										 ELSE 0 END AS points
								FROM matches
								UNION ALL
								SELECT
									awayteam AS team,
									case WHEN ftr = 'A' THEN 3
										 WHEN ftr = 'D' THEN 1
										 ELSE 0 END AS points
								from matches
							)
						GROUP BY team
						ORDER by points DESC)
select team,points, first_value(points) over(order by points desc) - points as diff
from league_table

-- Q40	Using a window function, calculate each team's form — the average points earned in their last 5 matches.
CREATE TABLE date_sequence (
    seq_date DATE
);

INSERT INTO date_sequence(seq_date)
SELECT generate_series(
    '2020-09-12'::date,
    '2021-05-23'::date,
    '1 day'::interval
);
select *
from date_sequence;

with t1 as(
SELECT
	date,
	hometeam AS team,
	case WHEN ftr = 'H' THEN 3
		 WHEN ftr = 'D' THEN 1
		 ELSE 0 END AS points
FROM matches
UNION ALL
SELECT
	date,
	awayteam AS team,
	case WHEN ftr = 'A' THEN 3
		 WHEN ftr = 'D' THEN 1
		 ELSE 0 END AS points
from matches
)
select 
	date,
	team,
	points,
	round(avg(points) over(partition by team order by date ROWS between 4 PRECEDING and current row),2) as avg_last_5th
from t1
order by team, date;

-- ⚫ Level 5 — Expert (Complex Multi-Step Queries)

-- Q41	Find the longest unbeaten run (wins + draws) for any single team in the season, 
-- using window functions to detect breaks in the run.
 with t1 as(
select date, hometeam as team,ftr,
		case when ftr = 'H' or ftr = 'D' then 'W/D'
			 ELSE 'L' end as status
from matches
UNION all
select date, awayteam, ftr,
		case when ftr = 'A' or ftr = 'D' then 'W/D'
			 ELSE 'L' end as status
from matches
),
t2 as(
select *, ROW_NUMBER() OVER (PARTITION BY team ORDER BY date) -
        ROW_NUMBER() OVER (PARTITION BY team, status ORDER BY date) AS grp
from t1
order by team, date
),
t3 as(
select team,grp,count(*) as n_series
from t2
where status ='W/D'
group by team, grp
order by n_series desc, team
)
select team, n_series
from t3
where n_series = (select max(n_series)
					from t3)

-- Q42	Identify matches that were 'momentum shifters' — where a team was losing at half time by 2+ goals
-- but drew or won full time.

 select hometeam, awayteam, hthg, htag, fthg, ftag, ftr
 from matches
 where (hthg - htag >= 2 and (ftr = 'A' or ftr = 'D'))
 	or (htag - hthg >= 2 and (ftr = 'H' or ftr = 'D'))
 
-- Q43	Using a recursive CTE or multiple CTEs, compute each team's cumulative points 
-- after every match day, then show which team led the table at the most match days.
with t1 as (
SELECT
	date,
	hometeam AS team,
	case WHEN ftr = 'H' THEN 3
		 WHEN ftr = 'D' THEN 1
		 ELSE 0 END AS points,
		 fthg - ftag as GD
FROM matches
UNION ALL
SELECT 
	date,
	awayteam AS team,
	case WHEN ftr = 'A' THEN 3
		 WHEN ftr = 'D' THEN 1
		 ELSE 0 END AS points,
		 ftag - fthg as gd
from matches
),t2 as (
select distinct hometeam as team 
from matches
),
t4 as (
select seq_date  as date, team
from t2
cross join date_sequence 
), t5 as(
select t4.date, t4.team,t1.points, t1.gd
from t4
left join t1
on t4.date = t1.date
	and t4.team = t1.team
order by date
), t6 as(
select date, team, COALESCE(points, 0) AS points, COALESCE(gd, 0) AS gd
from t5
), t7 as (
select *,
		sum(points) over(partition by team order by date) as acc_pt,
		sum(GD) over(partition by team order by date) as acc_GD
from t6
order by date
), t8 as(
select date, team, acc_pt, acc_GD,
 rank() over(partition by date order by acc_pt desc, acc_GD desc, team ) as rn
from t7
order by date, rn
), t9 as(
select date, team, acc_pt, acc_GD
from t8
where rn = 1
)
select team, count(date) as n_days_top
from t9
group by team
order by n_days_top desc
limit 1;

-- Q44	For each referee, compute a 'controversy score' = total red cards issued / total matches officiated,
-- and rank them from most to least controversial.
with t1 as(
select referee, sum(hr + ar)::float/ count(id) as controversy_score
from matches
group by referee
)
select *, rank() over(order by controversy_score desc) as rn
from t1 
order by controversy_score desc;

-- Q45	Detect all 'six-pointer' matches — matches between teams that 
-- finished in the top 6 of the final league table — and show how many points each of those top-6 teams earned in six-pointers alone.
with t1 AS(
SELECT
	team,
	sum(gd) as gd,
	sum(points) as points
FROM
	(
		SELECT
			hometeam AS team,
			case WHEN ftr = 'H' THEN 3
				 WHEN ftr = 'D' THEN 1
				 ELSE 0 END AS points,
			fthg - ftag as GD
		FROM matches
		UNION ALL
		SELECT
			awayteam AS team,
			case WHEN ftr = 'A' THEN 3
				 WHEN ftr = 'D' THEN 1
				 ELSE 0 END AS points,
			 ftag - fthg as GD
		from matches
	)
GROUP BY team
ORDER by points DESC, gd DESC
limit 6),
t2 as(
select *
from matches
where hometeam in(select team from t1)
	and awayteam in (select team from t1)
),
t4 as(
select 
	hometeam, 
	case 
		when ftr = 'H' then 3
		when ftr = 'A' then 0 
		else 1 end as points
from t2
UNION all
select 
	awayteam, 
	case 
		when ftr = 'A' then 3
		when ftr = 'H' then 0 
		else 1 end as points
from t2
)
select hometeam as team, sum(points) as points
from t4
group by hometeam
order by points desc

-- 💡 finiiiiiiiish 