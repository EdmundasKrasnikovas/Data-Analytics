# Advanced SQL and Databases

This project is part of the Data Analytics course at Turing College. The goal is to work with the AdventureWorks 2005 database using SQL queries to solve various business questions. The database is accessible through the BigQuery account provided by Turing College.

Within this folder, you will find a `.sql` file containing the queries used to generate all required outputs.  

You can also review the executed queries together with their resulting datasets in the following:

[Google Sheet — Queries & Results](https://docs.google.com/spreadsheets/d/1ax9KGGGl7BNdh-0jgTbLjBez3g319kOO-Eyy3jLGCEw/edit?gid=2048538382#gid=2048538382)  

---

## Tasks Overview

---

## 1. Customer Data Analysis

### 1.1 Create a Detailed Overview of Individual Customers

Extract:

- Customer identity information: CustomerId, Firstname, Last Name, FullName.  
- Include addressing_title (e.g., "Mr. Achong", default to "Dear Achong" if missing).  
- Contact information: Email, Phone, AccountNumber, CustomerType.  
- Location information: City, State, Country, Address.  
- Sales: number of orders, total amount (with Tax), and date of the last order.  

**Limit:** Top 200 rows ordered by total amount (with tax).

---

### 1.2 Identify Customers Who Have Not Ordered in the Last 365 Days

- Use a temporary table, CTE, or subquery of 1.1.  
- Filter customers who have not placed an order in the last 365 days.  
- Output the top 200 customers with the highest total amount (with tax).

---

### 1.3 Mark Active vs Inactive Customers

- Extend the 1.1 query.  
- Add a column to mark active customers based on whether they’ve ordered within the last 365 days.  

**Limit:** Top 500 rows ordered by CustomerId in descending order.

---

### 1.4 Extract Data for Active Customers from North America

Criteria:  
- Customers who have either ordered **more than 2500** in total amount (with tax)  
  **or**  
- Ordered **5+ times**.

Additional requirements:  
- Split their address line into two columns: `address_no` and `address_st`.  
- Order by country, state, and date_last_order.

---

## 2. Reporting Sales Numbers

### 2.1 Monthly Sales Numbers by Country and Region

Query monthly sales data including:

- Number of orders  
- Number of customers  
- Number of salespersons  
- Total amount (with tax) per country and region

---

### 2.2 Cumulative Sum of Total Amount Earned

Extend 2.1 by adding:

- Cumulative sum of the total amount (with tax) per country and region  
- Use a CTE or subquery

---

### 2.3 Rank Sales by Total Amount Earned per Country

Add:

- A `sales_rank` column that ranks rows from best to worst  
- Ranking is based on total amount earned each month per country/region

---

### 2.4 Add Tax Information at the Country Level

Include:

- Average tax rate (`mean_tax_rate`) for each country  
- Percentage of provinces with available tax rates (`perc_provinces_w_tax`)  

Rules:  
- Only count the **highest tax rate** in provinces with multiple rates  
- Ignore the `isonlystateprovinceFlag`
