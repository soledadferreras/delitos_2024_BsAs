PostgreSQL + Power BI | SQL EDA | Business Intelligence Dashboard

delitos_2024_BsAs
Crime Data Analysis – Buenos Aires 2024


This project performs an end-to-end Exploratory Data Analysis (EDA) of crime incidents recorded in Buenos Aires during 2024. The objective was to identify patterns, trends, seasonality effects, and geographic concentration of crime using SQL for data transformation and Power BI for visualization.

Analytical Objectives
Measure total crime volume and monthly averages
Calculate month-over-month (MoM) variation
Identify high-incidence communes
Analyze weapon usage proportion
Determine most frequent crime categories
Detect seasonal trends

Key Findings
155,000+ total crime records analyzed.
Average monthly crimes: ~12.9k incidents.
5% of crimes involved weapon usage.
Latest recorded month shows a 3% decrease compared to the previous month.
Commune 1 has the highest crime volume.
Communes 8 and 4 show higher proportions of weapon-related crimes.
Robbery and theft are the dominant categories.
A noticeable decline trend from mid-year to early Q4, followed by recovery.

Technical Approach
Data Preparation (PostgreSQL)
Data cleaning and duplicate handling
Type conversion (text → date, numeric corrections)
Aggregations and grouping analysis
Creation of analytical views
Window functions (LAG, RANK) for growth rate and ranking analysis
Month ordering logic using CASE expressions
Percentage and rate calculations

Analytical Techniques Used
Month-over-month growth rate
Ranking by crime volume
Ratio analysis (weapon usage %)
Comparative analysis by commune
Trend and seasonality evaluation

Visualization (Power BI)
KPI Cards (Total Crimes, Monthly Variation %, Weapon Usage %)
Line + Column trend analysis
Top-N commune ranking
Category breakdown
Interactive filtering

Dashboard Purpose
The dashboard is designed to simulate a real-world analytical environment, where stakeholders can:
Monitor crime evolution
Compare geographic distribution
Evaluate severity indicators
Detect shifts in crime patterns
