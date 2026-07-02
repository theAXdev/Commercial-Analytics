# 📊 Commercial Analytics — Product Performance & Revenue Optimization

> An end-to-end analytics project transforming one year of raw pizza restaurant transactional data into a structured Star Schema data warehouse in PostgreSQL, then into a four-page interactive Power BI dashboard delivering actionable revenue and operational intelligence.

---

<img width="2263" height="5382" alt="BR_Commercial_Analytics_Dashboard" src="https://github.com/user-attachments/assets/4ef475ff-88a7-4edf-a995-623f385ebbfe" />


---

## 📌 Project Background

This project simulates a real-world commercial analytics engagement for Plato's Pizza — a full-service pizza restaurant business. The challenge mirrors what analytics and data engineering teams encounter daily: raw transactional data exported from a point-of-sale system, stored in a single flat table, with no structure suitable for multi-dimensional analysis.

The solution delivered here moves through the full analytics engineering pipeline — from raw data ingestion and relational database design in PostgreSQL, through to a stakeholder-ready, interactive Power BI dashboard. Every number on the dashboard is traceable back to a validated SQL query, and every recommendation is grounded in a specific analytical finding.

This project is part of the **AXdev Commercial Analytics Portfolio Series** — a collection of projects spanning retail, F&B, and e-commerce analytics.

---

## 🎯 Project Objectives

- Apply data warehousing principles to restructure a flat, denormalized dataset into a clean Star Schema relational model
- Validate all headline KPIs directly in PostgreSQL before connecting to Power BI — ensuring data integrity at the source
- Build a four-page interactive Power BI dashboard answering two core business questions:
  - **What is selling and where is the revenue coming from?** (Menu performance, category mix, size preference, seasonality)
  - **When is the business busiest and how should operations respond?** (Peak hours, staffing windows, demand troughs)
- Translate analytical findings into structured, evidence-based recommendations for both revenue growth and operational efficiency

---

## ⚙️ Tools & Technologies

| Tool | Role in This Project |
|---|---|
| **PostgreSQL** | Data ingestion, schema design, normalization, KPI validation, analytical querying |
| **SQL** | CREATE TABLE AS SELECT, normalization queries, aggregation, window functions, CASE logic |
| **Microsoft Power BI Desktop** | Star Schema modelling, DAX measures, interactive dashboard development |
| **DAX (Data Analysis Expressions)** | Custom KPI measures, dynamic filtering, calculated columns |
| **Power Query** | Data transformation and relationship configuration within Power BI |

---

## 📐 Analytical Methodology

This project applies two analytical modes in sequence:

**Descriptive Analytics** — Understanding what happened. Revenue totals, order counts, category breakdowns, and size distributions establish the factual baseline of the business.

**Diagnostic Analytics** — Understanding why it happened. Cross-dimensional analysis of time, product, and category reveals the patterns driving the numbers — peak demand windows, menu drag items, and seasonal troughs.

---

## 🗄️ Phase 1 — Data Engineering in PostgreSQL

### The Problem with Flat Data

The source dataset arrived as a single wide table (`plato_combined`) with 12 fields per order line — repeating pizza name, category, and ingredient data on every single row. This denormalized structure creates redundancy, inflates storage, and makes analytical querying slower and more error-prone.

### The Solution — Star Schema Normalization

Using `CREATE TABLE AS SELECT DISTINCT` queries, the flat source table was decomposed into four relational tables forming a **Star Schema**:

| Table | Type | Core Content | Primary Key |
|---|---|---|---|
| `order_details` | Fact Table | Records quantity sold and line_item_revenue per order line | order_details_id |
| `orders` | Dimension — Time | Captures unique order_id, date, and time of each transaction | order_id |
| `pizzas` | Dimension — Product SKU | Defines each pizza_id with associated size and unit price | pizza_id |
| `pizza_types` | Dimension — Product Info | Stores pizza_type_id, name, category, and full ingredient list | pizza_type_id |

The `order_details` Fact table sits at the centre of the schema, linked to all three Dimension tables — the structure that Power BI's relationship model maps directly onto.

### Key SQL Techniques Applied

- `CREATE TABLE AS SELECT DISTINCT` — dimension extraction with deduplication
- `LEFT(pizza_id, LENGTH(pizza_id) - 2)` — string manipulation to derive `pizza_type_id` from composite SKU codes
- `ALTER TABLE ADD PRIMARY KEY` — enforcing referential integrity on all four tables
- `EXTRACT(DOW FROM order_date)` — day-of-week extraction for temporal analysis
- `TO_CHAR(order_date, 'YYYY-MM')` — date formatting for monthly trend grouping
- `CASE WHEN EXTRACT(DOW...) IN (0,6) THEN 'Weekend' ELSE 'Weekday'` — day type classification
- `COUNT(DISTINCT order_id)` — accurate transaction counting independent of line item count

### KPI Validation in SQL

All five headline KPIs were validated directly in PostgreSQL before Power BI was connected — ensuring the dashboard numbers match the underlying data:

| KPI | SQL Logic | Result |
|---|---|---|
| Total Revenue | `SUM(total_price)` | $817,860.05 |
| Total Quantity Sold | `SUM(quantity)` | 49,574 |
| Total Orders | `COUNT(DISTINCT order_id)` | 21,350 |
| Average Order Value | `SUM(total_price) / COUNT(DISTINCT order_id)` | $38.31 |
| Average Daily Orders | `COUNT(DISTINCT order_id) / COUNT(DISTINCT order_date)` | 60 |

---

## 📊 Phase 2 — Data Modelling & Visualisation in Power BI

### The SQL ↔ Power BI Integration Model

PostgreSQL and Power BI operate in a deliberate division of labour:

- **PostgreSQL handles** extraction, cleaning, normalization, and KPI validation — the structural heavy lifting before any visualisation begins
- **Power BI handles** relationship modelling, DAX measure creation, and interactive presentation — the analytical and storytelling layer on top of the clean schema

### DAX Measures Built

- `Total Revenue` — SUM of line_item_revenue across the fact table
- `Total Quantity Sold` — SUM of quantity across all order lines
- `Total Orders` — DISTINCTCOUNT of order_id
- `Average Order Value` — DIVIDE([Total Revenue], [Total Orders])
- `Average Daily Orders` — DIVIDE([Total Orders], DISTINCTCOUNT(orders[date]))
- `Revenue by Day Type` — CALCULATE with FILTER for Weekday vs Weekend classification

### Dashboard Structure — Four Pages

#### Page 1: Performance Overview — Sales & Revenue Drivers
> Answers: *What is selling and where is the revenue coming from?*

| Visual | Chart Type | Key Finding |
|---|---|---|
| Monthly Revenue Trend | Line Chart | Peaks in July ($72.5K) and May ($71.4K); troughs in September ($64.1K) and October ($64.0K) |
| Top 5 Pizzas by Revenue | Horizontal Bar | Thai Chicken ($43K) and Barbecue Chicken ($43K) are the dual revenue leaders |
| Bottom 5 Pizzas by Revenue | Horizontal Bar | Brie Carre Pizza ($11.6K) is the lowest performer — a clear menu liability |
| Revenue by Pizza Category | Donut Chart | Classic leads ($220K), Veggie trails ($193K) — all four categories well-balanced |
| Quantity Sold by Pizza Size | Column Chart | Large (L) dominates at 18,960 units (38%); XL and XXL account for under 2% combined |
| Revenue by Day Type | Donut Chart | Weekdays drive 73% of revenue ($595K) vs 27% on weekends ($222K) |

#### Page 2: Time-Based Insights — Operational Efficiency & Demand
> Answers: *When is the business busiest and how should operations respond?*

| Visual | Chart Type | Key Finding |
|---|---|---|
| Orders by Day & Hour | Matrix Heatmap | Two peak windows confirmed: Weekday Lunch (12 PM–1 PM) and Friday/Saturday Dinner (6 PM–9 PM) |
| Total Revenue by Day | Line Chart | Friday peaks at $33.3K; Sunday is lowest at $23.7K |
| Quantity by Day of Week | Column Chart | Friday sells 8,242 units — the highest single-day volume in the week |
| Revenue by Day Type | Donut Chart | Confirms the 73%/27% weekday-weekend revenue split |

#### Page 3: Observations
Written analytical findings covering revenue base, menu performance, size dominance, daily and hourly patterns, and seasonal trends — structured for non-technical business stakeholders.

#### Page 4: Recommendations
Structured action-and-goal recommendations across two tracks: Revenue Growth and Operational Efficiency — each recommendation directly traceable to a specific query output or visual finding.

---

## 📈 Key Metrics

| Metric | Value |
|---|---|
| Total Revenue | $817,860.05 |
| Total Orders | 21,350 |
| Total Quantity Sold | 49,574 |
| Average Order Value | $38.31 |
| Average Daily Orders | 60 |
| Busiest Day | Friday — $33.3K revenue, 8,242 units |
| Slowest Day | Sunday — $23.7K revenue, 6,035 units |
| Peak Revenue Month | July — $72.5K |
| Trough Month | October — $64.0K |
| Top Pizza by Revenue | Thai Chicken Pizza — $43K |
| Worst Pizza by Revenue | Brie Carre Pizza — $11.6K |
| Dominant Size | Large (L) — 38% of all units sold |

---

## 🔍 Key Findings

### 1. Revenue Base Is Healthy But Under-Leveraged
$817,860 in annual revenue is a solid baseline — but an Average Order Value of $38.31 (equivalent to fewer than two large pizzas per order) signals a clear upselling opportunity that has not yet been captured.

### 2. Two SKUs Carry Disproportionate Weight
Thai Chicken Pizza and Barbecue Chicken Pizza together generate approximately $86K — nearly 10.5% of total annual revenue from just two menu items. These are the commercial backbone of the menu.

### 3. Brie Carre Is a Menu Liability
At $11.6K annual revenue, the Brie Carre Pizza requires specialist ingredients and kitchen preparation complexity that is entirely unjustified by its revenue contribution. The five bottom performers collectively generate around $72K — spread across five products with five separate ingredient requirements.

### 4. Large Size Dominates — XL and XXL Are Redundant
The Large size accounts for 38% of all units sold. XL and XXL combined account for under 2% — making them operationally costly SKUs that simplify operations at almost zero revenue cost if discontinued.

### 5. Friday Is the Commercial Peak — By a Significant Margin
Friday generates $33.3K in daily revenue and 8,242 units — the highest of any day in the week. The 6 PM–9 PM Friday window represents the single most resource-intensive period in the entire operating week.

### 6. Weekday Lunch Rush Is Predictable and High-Volume
The 12 PM–1 PM window records 370–438 orders per hour across every weekday — a consistent, high-frequency peak that rewards reliable staffing rather than reactive scheduling.

### 7. September and October Are Clear Trough Months
Both months bottom out at approximately $64K — roughly $8K below peak months. These represent the strongest opportunity window for targeted promotions and demand stimulation.

### 8. Weekend Demand Pattern Differs Structurally from Weekdays
Saturday and Sunday show significantly slower mornings but high evening volumes (5 PM–8 PM). Applying the same daytime staffing model from weekdays to weekends creates unnecessary labour cost during low-demand weekend hours.

---

## ✅ Recommendations

### Revenue Growth

1. **Launch a "Chicken Kingpin" Campaign** — Bundle Thai Chicken and Barbecue Chicken pizzas as a combo deal to increase Average Order Value beyond the $38.31 baseline
2. **Rationalise the Menu** — Remove Brie Carre Pizza immediately; review the other four bottom performers for removal or re-engineering to free up ingredient stock and kitchen capacity
3. **Discontinue XXL; Reposition XL** — Remove the XXL size entirely and reposition XL as a catering/advance-order product to simplify operations
4. **Target September & October** — Introduce time-bound promotional campaigns during the two trough months to smooth the revenue curve and utilise the fixed cost base

### Operational Efficiency

1. **Implement Three-Window Staffing Model** — Separate staffing schedules for Weekday Lunch (11:30 AM–1:30 PM), Weekday Dinner (5:00 PM–7:00 PM), and Weekend Peak (6:00 PM–9:00 PM)
2. **Mandate Thursday Afternoon Prep** — Stage all Classic and Chicken category ingredients by Thursday afternoon to prevent bottlenecks during the Friday demand spike
3. **Run a Sunday Activation Campaign** — Target the slowest day with a "Sunday Funday" style promotion (e.g. 15% off, free side) to increase utilisation of available capacity
4. **Back-Load Weekend Staffing** — Shift weekend coverage toward the evening peak (5 PM–8 PM) rather than matching the weekday daytime model

---

## ⚠️ Limitations

- **No cost data** — Ingredient and labour cost figures are absent; revenue analysis cannot be extended to profit margin or contribution margin analysis without this
- **Single year of data** — Seasonality findings are indicative but cannot be validated against prior-year trends without a multi-year dataset
- **No customer identifiers** — Repeat purchase rate, customer lifetime value, and retention analysis are outside the scope of this dataset
- **Fictional dataset** — Findings are analytically valid as a demonstration of method and skill; they are not real business intelligence for a real organisation

---

## 🔭 Future Extensions

- Build a Python or R predictive model to forecast daily order volumes using day-of-week, month, and seasonal variables
- Integrate actual cost data to shift from revenue analysis into contribution margin and profitability analysis
- Add customer cohort analysis if customer ID data becomes available — enabling churn and lifetime value modelling
- Extend to a multi-year dataset to validate seasonality assumptions and model year-over-year growth trends
- Automate the PostgreSQL-to-Power BI pipeline with a scheduled ETL process for real-time dashboard refresh

---

## 📁 Repository Structure
📦 Commercial-Analytics-Product-Performance-and-Revenue-Optimization
┣ 📊 Commercial_Analytics.pbix              ← Power BI dashboard file (open in Power BI Desktop)
┣ 🗄️ Commercial_Analytics_Queries.sql       ← Full PostgreSQL query file — normalization + KPI + analysis
┣ 📄 Commercial_Analytics_Technical_Report.docx  ← Full technical report
┣ 🖼️ Commercial_Analytics_Dashboard.jpg     ← Four-page dashboard preview (displayed in this README)
┣ 📋 plato_combined.csv                     ← Raw source dataset
┗ 📝 README.md                              ← Project documentation (you are here)

### How to Use This Repository

1. **To explore the dashboard** — download `Commercial_Analytics.pbix` and open it in [Power BI Desktop](https://powerbi.microsoft.com/desktop/) (free to download)
2. **To run the SQL queries** — open `Commercial_Analytics_Queries.sql` in PostgreSQL or any SQL editor; create the `plato_combined` source table first, then run the normalization and analysis queries in sequence
3. **To read the full analysis** — open `Commercial_Analytics_Technical_Report.docx` in Microsoft Word or Google Docs
4. **To work with the raw data** — open `plato_combined.csv` in Excel, Python, or any data tool

---

## 🏷️ Tags

`postgresql` `sql` `power-bi` `dax` `data-analytics` `star-schema` `commercial-analytics` `revenue-optimization` `data-warehousing` `portfolio` `food-and-beverage` `retail-analytics`

---

*Commercial Analytics Portfolio Series — SQL + Power BI End-to-End Project*
