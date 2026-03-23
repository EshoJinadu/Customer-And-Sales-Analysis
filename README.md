# Customer & Sales Analytics (SQL Project)

# Overview
This project presents an end-to-end SQL-driven analysis of customer and sales data for a retail business. Using PostgreSQL, the analysis uncovers key business insights related to revenue trends, product performance, and customer segmentation.

The goal is to transform raw transactional data into actionable intelligence that supports strategic decision-making in marketing, customer retention, and product optimisation.

---

## Business Problem
The business lacked a structured understanding of:
- Revenue trends over time
- Product and category performance
- Customer value and retention patterns

Without these insights, decision-making relied heavily on intuition rather than data.

---

## Objectives
- Analyse year-on-year revenue trends and growth patterns
- Identify top-performing products and categories
- Segment customers based on value and behaviour
- Develop key performance indicators (KPIs) for customer analysis

---

## Tools & Technologies
- PostgreSQL
- SQL (Window Functions, CTEs, CASE Statements)
- Data Modelling (Star Schema)

---

## Dataset
The dataset consists of three relational tables:
- **customer** → customer demographics and details  
- **products** → product information and categories  
- **sales** → transactional sales records  

The data was provided as part of a guided project and stored in a PostgreSQL database. No external data sources or APIs were used.

---

## Data Processing & Methodology
The entire analysis was performed in SQL using:

- **Data Cleaning**
  - Removed NULL values in key fields (e.g., order_date)
  - Standardised date formats using `EXTRACT()`

- **Data Transformation**
  - Customer age and lifespan calculations
  - KPI derivation (AOV, Recency, Monthly Spend)

- **Advanced SQL Techniques**
  - Window Functions (`SUM OVER`, `AVG OVER`, `LAG`)
  - Common Table Expressions (CTEs)
  - CASE statements for segmentation

- **Data Modelling**
  - Star schema with `sales` as fact table
  - `customer` and `products` as dimension tables

---

## Key Insights
- **Revenue Growth**: Positive overall trend, but uneven across years  
- **Product Performance**: A small number of products drive most revenue  
- **Category Risk**: High dependency on a few product categories  
- **Customer Segmentation**:
  - VIP customers contribute disproportionately to revenue  
  - Lapsing customers represent a churn risk  
- **Retention Impact**: Longer customer lifespan strongly correlates with higher spend  

---

## Recommendations
- Launch a **VIP retention programme**
- Implement **targeted win-back campaigns** for inactive customers
- Prioritise **high-performing products**
- Diversify revenue across product categories
- Improve **customer onboarding and retention strategies**

---

## Project Structure

---

## How to Use
1. Load the dataset into PostgreSQL  
2. Run SQL queries from the `/sql` folder  
3. Reproduce analysis and insights  

---

## Limitations
- No external benchmarking or market comparison  
- Some missing values required filtering  
- Dataset represents a historical snapshot (no real-time data)  

---

## Author
**Fawaz Ayofe**  
MSc International Business and Management  
University of Sunderland  

---

## Project Value
This project demonstrates the ability to:
- Perform end-to-end SQL data analysis  
- Translate data into business insights  
- Apply analytical thinking to real-world problems  

It serves as a practical example of data-driven decision-making in a retail business context.
