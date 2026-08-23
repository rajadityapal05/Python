\# 🎧 SoundIQ — Music Business Intelligence with PostgreSQL



SoundIQ is a business intelligence project built with PostgreSQL to analyze

customer behavior, purchasing patterns, product performance, artist

performance, genre demand, and revenue concentration.



The project transforms the Chinook music-store database into actionable

business insights using advanced SQL analytics.



\---



\## 📊 Business Problem



A digital music business needs to understand:



\- Who are its most valuable customers?

\- Which customers are at risk of becoming inactive?

\- Which tracks and artists generate the most revenue?

\- Which products have never been purchased?

\- Which genres perform best?

\- How efficiently do artists monetize their catalogs?

\- Is revenue concentrated among a small number of products?

\- Which customer segments deserve targeted marketing?



SoundIQ answers these questions using PostgreSQL and analytical SQL.



\---



\## 🎯 Project Objectives



The analysis focuses on four major business areas:



\### 👥 Customer Intelligence



\- Customer segmentation

\- RFM analysis

\- Recency, frequency, and monetary scoring

\- Customer lifetime value

\- Customer value tiers

\- Geographic customer analysis



\### 🎵 Product Intelligence



\- Top-selling tracks

\- Never-purchased tracks

\- Album performance

\- Genre performance

\- Artist performance

\- Catalog efficiency

\- Revenue concentration



\### 💰 Revenue Intelligence



\- Revenue contribution

\- Average order value

\- Revenue concentration

\- Product-level revenue share

\- Customer-level revenue contribution



\### 🌍 Geographic Intelligence



\- Revenue by country

\- Customers by country

\- Revenue per customer

\- Average order value by market



\---



\## 🧠 Key SQL Techniques



This project demonstrates practical PostgreSQL skills including:



\- `JOIN`

\- `LEFT JOIN`

\- `GROUP BY`

\- `HAVING`

\- `CASE`

\- Common Table Expressions (`WITH`)

\- Window functions

\- `SUM() OVER()`

\- Ranking

\- Percentile-style scoring

\- Conditional aggregation

\- `COUNT(DISTINCT ...)`

\- Revenue calculations

\- Customer segmentation

\- RFM analysis



\---



\## 📁 Project Structure



```text

soundiq/

│

├── data/

│

├── sql/

│   ├── 01\_data\_quality.sql

│   ├── 02\_sales\_intelligence.sql

│   ├── 03\_customer\_intelligence.sql

│   └── 04\_product\_intelligence.sql

│

├── reports/

│   └── insights.md

│

├── screenshots/

│

├── README.md

└── .gitignore

