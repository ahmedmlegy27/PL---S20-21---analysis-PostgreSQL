# ⚽ Premier League 2020/21 — SQL Analysis (PostgreSQL)

A complete SQL analysis project on the English Premier League 2020/21 season dataset, covering match results, team performance, discipline, and shooting statistics using PostgreSQL.

---

## 📁 Project Structure

```
PL - S20/21 - analysis PostgreSql/
│
├── data/
│   └── EPL_2020-21.csv          # Raw match dataset
│
├── queries/
│   └── analysis.sql             # All SQL queries (Q1 → Q45)
│
└── README.md
```

---

## 🗄️ Database Schema

```sql
CREATE TABLE matches (
    div      CHAR(2),
    date     DATE,
    time     TIME,
    hometeam TEXT,
    awayteam TEXT,
    fthg     SMALLINT,       -- Full Time Home Goals
    ftag     SMALLINT,       -- Full Time Away Goals
    ftr      CHAR(1),        -- Full Time Result (H/D/A)
    hthg     SMALLINT,       -- Half Time Home Goals
    htag     SMALLINT,       -- Half Time Away Goals
    htr      CHAR(1),        -- Half Time Result (H/D/A)
    referee  TEXT,
    hs       SMALLINT,       -- Home Shots
    "as"     SMALLINT,       -- Away Shots
    hst      SMALLINT,       -- Home Shots on Target
    ast      SMALLINT,       -- Away Shots on Target
    hf       SMALLINT,       -- Home Fouls
    af       SMALLINT,       -- Away Fouls
    hc       SMALLINT,       -- Home Corners
    ac       SMALLINT,       -- Away Corners
    hy       SMALLINT,       -- Home Yellow Cards
    ay       SMALLINT,       -- Away Yellow Cards
    hr       SMALLINT,       -- Home Red Cards
    ar       SMALLINT        -- Away Red Cards
);
```

---

## 📊 Analysis Coverage

### 🟢 Level 1 — Beginner
- Filtering match results by outcome (H / D / A)
- Listing matches by team (home or away)
- Finding high-scoring matches
- Identifying half-time vs full-time result differences

### 🔵 Level 2 — Intermediate
- Total goals and average goals per match
- Home win rate per team
- Top referees by matches officiated
- Yellow/red card totals per referee
- Teams with highest goals conceded

### 🟠 Level 3 — Intermediate+
- Full league table (Points, GF, GA, GD) using `UNION ALL`
- Comeback wins (losing at HT, winning at FT)
- Most common scorelines
- Teams with more away wins than home wins
- Match categorisation (High / Normal / Low scoring)

### 🔴 Level 4 — Advanced (Window Functions & CTEs)
- `ROW_NUMBER()` — ranking matches per team by goals scored
- `RANK()` — teams ranked by total goals scored
- `DENSE_RANK()` — best defensive teams with no rank gaps
- `LAG()` — comparing each match result to the previous one
- `LEAD()` — next fixture result for Liverpool
- `NTILE(4)` — dividing matches into quartiles by goals
- `SUM() OVER` — running total of home goals per team
- Multi-CTE chain — points gap from league leader
- Sliding window — last 5 match form per team

---

## 💡 Key Insights

- **380 matches** played across the 2020/21 season
- Analysed using **45 SQL queries** across 4 difficulty levels
- `"as"` column quoted in PostgreSQL to avoid conflict with reserved keyword `AS`
- Dates stored as `DATE` type in `YYYY-MM-DD` format for accurate time-series analysis

---

## 🛠️ Tools Used

| Tool | Purpose |
|------|---------|
| PostgreSQL 18 | Database engine |
| pgAdmin | Query editor & DB management |
| Microsoft Excel | Data cleaning & date formatting |
| GitHub Desktop | Version control |

---

## 🚀 How to Run

1. Clone the repository
2. Create the `matches` table using the schema above
3. Import `EPL_2020-21.csv` into PostgreSQL
4. Open `analysis.sql` and run any query in pgAdmin

---

## 👤 Author

**Ahmed Mamdouh Elmlegy**
Panel Operation Engineer @ SUMED | Aspiring Data Analyst
[LinkedIn](https://www.linkedin.com/in/ahmed-elmlegy-bb6abb1b9)

---

*Dataset source: football-data.co.uk*
