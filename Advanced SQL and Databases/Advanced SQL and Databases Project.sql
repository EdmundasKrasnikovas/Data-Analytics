/*==============================================================
 Advanced SQL Project: Customer Sales Analysis
 Detailed Overview of Individual Customers
 Task: 1.1  
 Description:
   Create a detailed overview of all individual customers. 
   Individual customers are defined by CustomerType = 'I' 
   and/or are stored in the individual customer table.

 Requirements:
   - Include the following columns:
       CustomerId, FirstName, LastName, FullName, Addressing_Title,
       Email, Phone, AccountNumber, CustomerType, City, State, 
       Country, Address, NumberOfOrders, TotalAmountWithTax, LastOrderDate
   - FullName = FirstName + ' ' + LastName
   - Addressing_Title = customer's title + last name (or 'Dear {LastName}' if missing)
   - Include sales info: number of orders, total amount (with tax), last order date
   - For customers with multiple addresses, take the latest available (max(AddressId))
   - Limit results to top 200 rows ordered by TotalAmountWithTax DESC
==============================================================*/
  -- initial table set up with main attributes which will be called in the other SQL parts
WITH
  individual_customers AS (
  SELECT
    customerID,
    AccountNumber,
    CustomerType
  FROM
    tc-da-1.adwentureworks_db.customer
  WHERE
    CustomerType = 'I' ),
  -- adding customer information
  customer_information AS (
  SELECT
    individual_customers.CustomerId,
    contact.FirstName,
    contact.LastName,
    CONCAT(contact.FirstName, ' ', contact.LastName) AS full_name,
  IF
    (contact.title IS NOT NULL, CONCAT(contact.title, ' ', contact.LastName), CONCAT('Dear ', contact.LastName)) AS addressing_title,
    contact.EmailAddress,
    contact.Phone,
    individual_customers.AccountNumber,
    individual_customers.CustomerType
  FROM
    individual_customers
  LEFT JOIN
    tc-da-1.adwentureworks_db.individual individual
  ON
    individual_customers.CustomerId = individual.CustomerId
  LEFT JOIN
    tc-da-1.adwentureworks_db.contact contact
  ON
    individual.ContactID = contact.ContactID ),
  --Adding address information 
  customer_address AS (
  SELECT
    latest_address.CustomerId,
    address.City,
    address.AddressLine1,
    address.AddressLine2,
    state_province.StateProvinceCode AS State, -- as there is no name for a ProvinceCode
    country.name AS Country
  FROM (
    SELECT
      *,
      ROW_NUMBER() OVER (PARTITION BY CustomerID ORDER BY ModifiedDate DESC) AS rn -- assigning the value of 1 to the latest address per customer
    FROM
      tc-da-1.adwentureworks_db.customeraddress ) latest_address
  LEFT JOIN
    tc-da-1.adwentureworks_db.address address
  ON
    latest_address.AddressID = address.AddressID
  LEFT JOIN
    tc-da-1.adwentureworks_db.stateprovince state_province
  ON
    address.StateProvinceID = state_province.StateProvinceID
  LEFT JOIN
    tc-da-1.adwentureworks_db.countryregion country
  ON
    state_province.CountryRegionCode = country.CountryRegionCode
  WHERE
    latest_address.rn = 1 ), -- filtering out only by the newest address
  --Aggregation part, information about customers
  sales_information AS (
  SELECT
    individual_customers.customerID,
    COUNT(sales_order.customerID) AS number_orders,
    ROUND(SUM(sales_order.totalDue), 2) AS total_amount,
    MAX(sales_order.OrderDate) AS date_last_order
  FROM
    individual_customers
  INNER JOIN
    tc-da-1.adwentureworks_db.salesorderheader sales_order
  ON
    individual_customers.customerID = sales_order.customerID
  GROUP BY
    individual_customers.customerID )
  -- Final call
SELECT
  customer_information.*,
  customer_address.City,
  customer_address.AddressLine1,
  customer_address.AddressLine2,
  customer_address.State,
  customer_address.Country,
  sales_information.number_orders,
  sales_information.total_amount,
  sales_information.date_last_order
FROM
  customer_information
LEFT JOIN
  customer_address
ON
  customer_information.CustomerID = customer_address.CustomerID
LEFT JOIN
  sales_information
ON
  customer_information.CustomerID = sales_information.CustomerID
ORDER BY
  total_amount DESC
LIMIT
  200;

/*==============================================================
 Advanced SQL Project: Customer Sales Analysis
 Detailed Overview of Individual Customers with Inactivity Filter
 Task: 1.2  
 Description:
   Identify the top 200 customers with the highest total amount 
   (including tax) who have not placed any orders in the last 365 days.

 Requirements:
   - Use results or logic from Task 1.1
   - Include customers’ total purchase amount (including tax)
   - Determine inactivity: last order date older than 365 days
   - Rank by TotalAmountWithTax in descending order
   - Return top 200 customers
==============================================================*/


WITH
  individual_customers AS (
  SELECT
    customerID,
    AccountNumber,
    CustomerType
  FROM
    tc-da-1.adwentureworks_db.customer
  WHERE
    CustomerType = 'I' ),
  -- Adding customer Information
  customer_information AS (
  SELECT
    individual_customers.CustomerId,
    contact.FirstName,
    contact.LastName,
    CONCAT(contact.FirstName, ' ', contact.LastName) AS full_name,
  IF
    (contact.title IS NOT NULL, CONCAT(contact.title, ' ', contact.LastName), CONCAT('Dear ', contact.LastName)) AS addressing_title,
    contact.EmailAddress,
    contact.Phone,
    individual_customers.AccountNumber,
    individual_customers.CustomerType
  FROM
    individual_customers
  LEFT JOIN
    tc-da-1.adwentureworks_db.individual individual
  ON
    individual_customers.CustomerId = individual.CustomerId
  LEFT JOIN
    tc-da-1.adwentureworks_db.contact contact
  ON
    individual.ContactID = contact.ContactID ),
  -- Adding address information
  customer_address AS (
  SELECT
    latest_address.CustomerId,
    address.City,
    address.AddressLine1,
    address.AddressLine2,
    state_province.StateProvinceCode AS State,-- as there is no name for a ProvinceCode
    country_region.Name AS Country
  FROM (
    SELECT
      *,
      ROW_NUMBER() OVER (PARTITION BY CustomerID ORDER BY ModifiedDate DESC) AS rn -- asignes the value of 1 to the latest address per customer
    FROM
      tc-da-1.adwentureworks_db.customeraddress ) latest_address
  LEFT JOIN
    tc-da-1.adwentureworks_db.address address
  ON
    latest_address.AddressID = address.AddressID
  LEFT JOIN
    tc-da-1.adwentureworks_db.stateprovince state_province
  ON
    address.StateProvinceID = state_province.StateProvinceID
  LEFT JOIN
    tc-da-1.adwentureworks_db.countryregion country_region
  ON
    state_province.CountryRegionCode = country_region.CountryRegionCode
  WHERE
    latest_address.rn = 1 ),
  -- Aggregation: customer sales information
  sales_information AS (
  SELECT
    individual_customers.CustomerID,
    COUNT(sales_order.CustomerID) AS number_orders,
    ROUND(SUM(sales_order.TotalDue), 2) AS total_amount,
    MAX(sales_order.OrderDate) AS date_last_order
  FROM
    individual_customers
  INNER JOIN
    tc-da-1.adwentureworks_db.salesorderheader sales_order
  ON
    individual_customers.CustomerID = sales_order.CustomerID
  GROUP BY
    individual_customers.CustomerID ),
  -- Single value: latest order date, latter on will be used 
  latest_order_date AS (
  SELECT
    MAX(OrderDate) AS latest_order_date_value
  FROM
    tc-da-1.adwentureworks_db.salesorderheader ),
  -- Inactive customers who did not order 365 days
  inactive_customers AS (
  SELECT
    customer_information.*,
    customer_address.City,
    customer_address.AddressLine1,
    customer_address.AddressLine2,
    customer_address.State,
    customer_address.Country,
    sales_information.number_orders,
    sales_information.total_amount,
    sales_information.date_last_order
  FROM
    customer_information
  LEFT JOIN
    customer_address
  USING
    (CustomerID)
  LEFT JOIN
    sales_information
  USING
    (CustomerID)
  CROSS JOIN -- as latest order date is one row value, added to all row values,
    latest_order_date
  WHERE
    sales_information.date_last_order < latest_order_date.latest_order_date_value - INTERVAL 365 DAY )

  -- Final call
SELECT
  *
FROM
  inactive_customers
ORDER BY
  total_amount DESC
LIMIT
  200;

/*==============================================================
 Advanced SQL Project: Customer Sales Analysis
 Customer Activity Flag – Active vs Inactive
 Task: 1.3  
 Description:
   Add a new column that flags customers as Active or Inactive, 
   based on whether they have placed an order within the last 365 days.

 Requirements:
   - Extend Task 1.1 SELECT
   - Add column ActivityStatus:
       • 'Active' → last order within 365 days
       • 'Inactive' → last order > 365 days ago
   - Return top 500 rows, ordered by CustomerId DESC
==============================================================*/


WITH
  individual_customers AS (
  SELECT
    customerID,
    AccountNumber,
    CustomerType
  FROM
    tc-da-1.adwentureworks_db.customer
  WHERE
    CustomerType = 'I' ),
  -- Adding customer Information
  customer_information AS (
  SELECT
    individual_customers.CustomerId,
    contact.FirstName,
    contact.LastName,
    CONCAT(contact.FirstName, ' ', contact.LastName) AS full_name,
  IF
    (contact.title IS NOT NULL, CONCAT(contact.title, ' ', contact.LastName), CONCAT('Dear ', contact.LastName)) AS addressing_title,
    contact.EmailAddress,
    contact.Phone,
    individual_customers.AccountNumber,
    individual_customers.CustomerType
  FROM
    individual_customers
  LEFT JOIN
    tc-da-1.adwentureworks_db.individual individual
  ON
    individual_customers.CustomerId = individual.CustomerId
  LEFT JOIN
    tc-da-1.adwentureworks_db.contact contact
  ON
    individual.ContactID = contact.ContactID ),
  -- Adding address information
  customer_address AS (
  SELECT
    latest_address.CustomerId,
    address.City,
    address.AddressLine1,
    address.AddressLine2,
    state_province.StateProvinceCode AS State,
    -- as there is no name for a ProvinceCode
    country_region.Name AS Country
  FROM (
    SELECT
      *,
      ROW_NUMBER() OVER (PARTITION BY CustomerID ORDER BY ModifiedDate DESC) AS rn -- asignes the value of 1 to the latest address per customer
    FROM
      tc-da-1.adwentureworks_db.customeraddress ) latest_address
  LEFT JOIN
    tc-da-1.adwentureworks_db.address address
  ON
    latest_address.AddressID = address.AddressID
  LEFT JOIN
    tc-da-1.adwentureworks_db.stateprovince state_province
  ON
    address.StateProvinceID = state_province.StateProvinceID
  LEFT JOIN
    tc-da-1.adwentureworks_db.countryregion country_region
  ON
    state_province.CountryRegionCode = country_region.CountryRegionCode
  WHERE
    latest_address.rn = 1 ),
  -- Aggregation: customer sales information
  sales_information AS (
  SELECT
    individual_customers.CustomerID,
    COUNT(sales_order.CustomerID) AS number_orders,
    ROUND(SUM(sales_order.TotalDue), 2) AS total_amount,
    MAX(sales_order.OrderDate) AS date_last_order
  FROM
    individual_customers
  INNER JOIN
    tc-da-1.adwentureworks_db.salesorderheader sales_order
  ON
    individual_customers.CustomerID = sales_order.CustomerID
  GROUP BY
    individual_customers.CustomerID ),
  -- Single value: latest order date
  latest_order_date AS (
  SELECT
    MAX(OrderDate) AS latest_order_date_value
  FROM
    tc-da-1.adwentureworks_db.salesorderheader ),
  -- Inactive customers who did not order 365 days
  inactive_customers AS (
  SELECT
    customer_information.*,
    customer_address.City,
    customer_address.AddressLine1,
    customer_address.AddressLine2,
    customer_address.State,
    customer_address.Country,
    sales_information.number_orders,
    sales_information.total_amount,
    sales_information.date_last_order
  FROM
    customer_information
  LEFT JOIN
    customer_address
  USING
    (CustomerID)
  LEFT JOIN
    sales_information
  USING
    (CustomerID)
  CROSS JOIN
    latest_order_date )
  --Final call
SELECT
  *,
  CASE
    WHEN date_last_order >= latest_order_date_value - INTERVAL 365 DAY THEN 'Active'
    ELSE ('Inactive')
END
  AS activity_flag
FROM
  inactive_customers
CROSS JOIN
  latest_order_date
ORDER BY
  CustomerID DESC
LIMIT
  500;

/*==============================================================
 Advanced SQL Project: Customer Sales Analysis
 Active Customers in North America – Purchase & Order Threshold
 Task: 1.4  
 Description:
   Provide data on all active customers from North America 
   who meet either of the following:
       • TotalAmountWithTax >= 2500
       • NumberOfOrders >= 5
   Additionally, split the customers' address into two columns: 
       Address_No, Address_St

 Requirements:
   - Include only customers meeting the above criteria
   - Include all relevant customer details
   - Split address into Address_No and Address_St
==============================================================*/

WITH
individual_customers AS (
SELECT
customerID,
AccountNumber,
CustomerType
FROM
tc-da-1.adwentureworks_db.customer
WHERE
CustomerType = 'I' ),

-- Adding customer Information

customer_information AS (
SELECT
individual_customers.CustomerId,
contact.FirstName,
contact.LastName,
CONCAT(contact.FirstName, ' ', contact.LastName) AS full_name,
IF
(contact.title IS NOT NULL, CONCAT(contact.title, ' ', contact.LastName), CONCAT('Dear ', contact.LastName)) AS addressing_title,
contact.EmailAddress,
contact.Phone,
individual_customers.AccountNumber,
individual_customers.CustomerType
FROM
individual_customers
LEFT JOIN
tc-da-1.adwentureworks_db.individual individual
ON
individual_customers.CustomerId = individual.CustomerId
LEFT JOIN
tc-da-1.adwentureworks_db.contact contact
ON
individual.ContactID = contact.ContactID ),

-- Adding address information

customer_address AS (
SELECT
latest_address.CustomerId,
address.City,
address.AddressLine1,
address.AddressLine2,
state_province.StateProvinceCode AS State, -- as there is no name for a ProvinceCode
country_region.Name AS Country
FROM (
SELECT
*,
ROW_NUMBER() OVER (PARTITION BY CustomerID ORDER BY ModifiedDate DESC) AS rn -- asignes the value of 1 to the latest address per customer
FROM
tc-da-1.adwentureworks_db.customeraddress ) latest_address
LEFT JOIN
tc-da-1.adwentureworks_db.address address
ON
latest_address.AddressID = address.AddressID
LEFT JOIN
tc-da-1.adwentureworks_db.stateprovince state_province
ON
address.StateProvinceID = state_province.StateProvinceID
LEFT JOIN
tc-da-1.adwentureworks_db.countryregion country_region
ON
state_province.CountryRegionCode = country_region.CountryRegionCode
WHERE
latest_address.rn = 1 
),

-- Aggregation: customer sales information

sales_information AS (
SELECT
individual_customers.CustomerID,
COUNT(sales_order.CustomerID) AS number_orders,
ROUND(SUM(sales_order.TotalDue), 2) AS total_amount,
MAX(sales_order.OrderDate) AS date_last_order
FROM
individual_customers
INNER JOIN
tc-da-1.adwentureworks_db.salesorderheader sales_order
ON
individual_customers.CustomerID = sales_order.CustomerID
GROUP BY
individual_customers.CustomerID ),

-- Single value: latest order date

latest_order_date AS (
SELECT
MAX(OrderDate) AS latest_order_date_value
FROM
tc-da-1.adwentureworks_db.salesorderheader ),

-- Inactive customers who did not order 365 days

inactive_customers AS (
SELECT
customer_information.*,
customer_address.City,
customer_address.AddressLine1,
customer_address.State,
customer_address.Country,
sales_information.number_orders,
sales_information.total_amount,
sales_information.date_last_order,
CASE
WHEN date_last_order >= latest_order_date_value - INTERVAL 365 DAY THEN 'Active'
ELSE ('Inactive')
END AS activity_flag
FROM
customer_information
LEFT JOIN
customer_address
USING
(CustomerID)
LEFT JOIN
sales_information
USING
(CustomerID)
CROSS JOIN
latest_order_date
),
-- Additional request (Address,only_active,aggregation filter, location )
final_customers AS(
SELECT
inactive_customers.*,
salesterritory.Name as teritory_name,
salesterritory.Group as state_name,
inactive_customers.addressLine1,
REGEXP_EXTRACT(inactive_customers.AddressLine1, r'^\s*(\d+)') AS address_no,
REGEXP_REPLACE(inactive_customers.AddressLine1, r'[^A-Za-z\s]+', '') AS address_st
FROM inactive_customers 
LEFT JOIN tc-da-1.adwentureworks_db.customer
ON inactive_customers.customerID = customer.CustomerID
LEFT JOIN tc-da-1.adwentureworks_db.salesterritory
ON customer.TerritoryID = salesterritory.TerritoryID
WHERE 
inactive_customers.activity_flag = 'Active'
AND (inactive_customers.total_amount >= 2500
OR inactive_customers.number_orders >=5 )
AND salesterritory.Group = 'North America'
)

--Final call

SELECT *
FROM
final_customers;


/*==============================================================
 Reporting Sales Numbers
 Monthly Sales Figures by Country and Region
 Task: 2.1  
 Description:
   Report monthly sales figures by Country and Region. 

 Requirements:
   - Include Number of orders
   - Include Number of unique customers
   - Include Number of salespersons
   - Include Total amount (with tax)
   - Cover all customer types
==============================================================*/

SELECT
  LAST_DAY(DATE(sales.OrderDate), MONTH) AS order_month,
  sales_territory.CountryRegionCode,
  sales_territory.Name AS Region,
  COUNT(DISTINCT sales.SalesOrderID) AS number_orders,
  COUNT(DISTINCT sales.CustomerID) AS number_customers,
  COUNT(DISTINCT sales.SalesPersonID) AS no_salesPersons,
  ROUND(SUM(sales.TotalDue)) AS Total_w_tax
FROM
  tc-da-1.adwentureworks_db.salesorderheader AS sales
LEFT JOIN
  tc-da-1.adwentureworks_db.salesterritory AS sales_territory
ON
  sales.TerritoryID = sales_territory.TerritoryID
GROUP BY
  CountryRegionCode,
  Region,
  order_month

/*==============================================================
 Reporting Sales Numbers
 Monthly Sales Figures with Cumulative Total by Country and Region
 Task: 2.2  
 Description:
   Enhance Task 2.1 by adding a cumulative sum of the total amount 
   (with tax) earned per Country and Region.

 Requirements:
   - Include cumulative sum column per Country and Region
   - Use a CTE or subquery to implement the cumulative sum
   - Keep all previous metrics from Task 2.1
==============================================================*/

WITH
  monthly_sales AS (
  SELECT
    LAST_DAY(DATE(sales.OrderDate), MONTH) AS order_month,
    sales_territory.CountryRegionCode,
    sales_territory.Name AS Region,
    COUNT(DISTINCT sales.SalesOrderID) AS number_orders,
    COUNT(DISTINCT sales.CustomerID) AS number_customers,
    COUNT(DISTINCT sales.SalesPersonID) AS no_sales_persons,
    ROUND(SUM(sales.TotalDue)) AS Total_w_tax
  FROM
    tc-da-1.adwentureworks_db.salesorderheader AS sales
  LEFT JOIN
    tc-da-1.adwentureworks_db.salesterritory AS sales_territory
  ON
    sales.TerritoryID = sales_territory.TerritoryID
  GROUP BY
    CountryRegionCode,
    name,
    order_month )
SELECT
  monthly_sales.*,
  SUM(Total_w_tax) OVER(
    PARTITION BY CountryRegionCode,Region
    ORDER BY 
    CountryRegionCode,
    Region,
    Total_w_tax
  ) AS cumulative_sum
 
FROM
  monthly_sales

/*==============================================================
 Reporting Sales Numbers
 Monthly Sales Figures with Regional Ranking by Country
 Task: 2.3  
 Description:
   Enhance Task 2.2 by adding a sales_rank column that ranks rows 
   from highest to lowest total amount (with tax) per country and month.

 Requirements:
   - Rank regions from highest to lowest TotalAmountWithTax per country and month
   - Assign rank 1 to the region with the highest total amount
==============================================================*/

WITH
  monthly_sales AS (
  SELECT
    LAST_DAY(DATE(sales.OrderDate), MONTH) AS order_month,
    sales_territory.CountryRegionCode,
    sales_territory.Name AS Region,
    COUNT(DISTINCT sales.SalesOrderID) AS number_orders,
    COUNT(DISTINCT sales.CustomerID) AS number_customers,
    COUNT(DISTINCT sales.SalesPersonID) AS no_sales_persons,
    ROUND(SUM(sales.TotalDue)) AS Total_w_tax
  FROM
    tc-da-1.adwentureworks_db.salesorderheader AS sales
  LEFT JOIN
    tc-da-1.adwentureworks_db.salesterritory AS sales_territory
  ON
    sales.TerritoryID = sales_territory.TerritoryID
  GROUP BY
    CountryRegionCode,
    name,
    order_month )
SELECT
  monthly_sales.*,
  SUM(Total_w_tax) OVER(
    PARTITION BY CountryRegionCode,Region
    ORDER BY 
    CountryRegionCode,
    Region,
    Total_w_tax DESC
  ) AS cumulative_sum,
  RANK() OVER(
    PARTITION BY CountryRegionCode,Region
    ORDER BY 
    CountryRegionCode,
    Region,
    Total_w_tax DESC
  ) AS sales_rank
FROM
  monthly_sales

/*==============================================================
 Reporting Sales Numbers
 Monthly Sales Figures with Country-Level Tax Details
 Task: 2.4  
 Description:
   Enhance Task 2.3 by adding country-level tax details.

 Requirements:
   - Add mean_tax_rate: average tax rate per country (highest per province if multiple)
   - Add perc_provinces_w_tax: percentage of provinces/states with available tax rates
==============================================================*/

WITH
  monthly_sales AS (
  SELECT
    LAST_DAY(DATE(sales.OrderDate), MONTH) AS order_month,
    sales_territory.CountryRegionCode,
    sales_territory.Name AS Region,
    COUNT(DISTINCT sales.SalesOrderID) AS number_orders,
    COUNT(DISTINCT sales.CustomerID) AS number_customers,
    COUNT(DISTINCT sales.SalesPersonID) AS no_sales_persons,
    ROUND(SUM(sales.TotalDue)) AS Total_w_tax
  FROM
    tc-da-1.adwentureworks_db.salesorderheader AS sales
  LEFT JOIN
    tc-da-1.adwentureworks_db.salesterritory AS sales_territory
  ON
    sales.TerritoryID = sales_territory.TerritoryID
  GROUP BY
    CountryRegionCode,
    name,
    order_month ),
  province_tax AS (
  SELECT
    state_province.StateProvinceCode,
    state_province.countryRegionCode,
    MAX(s_tax_rate.TaxRate) AS max_tax_rate
  FROM
    tc-da-1.adwentureworks_db.stateprovince AS state_province
  LEFT JOIN
    tc-da-1.adwentureworks_db.salestaxrate s_tax_rate
  ON
    state_province.StateProvinceID = s_tax_rate.StateProvinceID
  GROUP BY
    StateProvinceCode,
    CountryRegionCode ),
  country_tax AS(
  SELECT
    CountryRegioncode,
    ROUND(AVG(max_tax_rate),2) AS mean_tax_rate,
    ROUND(COUNT(CASE
          WHEN max_tax_rate IS NOT NULL THEN 1
      END
        ) / COUNT(*),2) AS perc_provinces_w_tax -- Percentage of provinces with tax data (how many values / total)
  FROM
    province_tax
  GROUP BY
    CountryRegionCode )
SELECT
  monthly_sales.*,
  SUM(Total_w_tax) OVER(PARTITION BY CountryRegionCode, Region ORDER BY CountryRegionCode, Region, Total_w_tax DESC ) AS cumulative_sum,
  RANK() OVER(PARTITION BY CountryRegionCode, Region ORDER BY CountryRegionCode, Region, Total_w_tax DESC ) AS sales_rank,
  country_tax.mean_tax_rate,
  country_tax.perc_provinces_w_tax
FROM
  monthly_sales
LEFT JOIN
  country_tax
USING
  (CountryRegionCode)
