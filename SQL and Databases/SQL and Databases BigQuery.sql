/*==============================================================
-- 1 TASK 

-- 1.1 You’ve been asked to extract the data on products from the Product table where there exists a product subcategory. And also include the name of the ProductSubcategory.
-- Columns needed: ProductId, Name, ProductNumber, size, color, ProductSubcategoryId, Subcategory name.
-- Order results by SubCategory name.
==============================================================*/


SELECT
p.ProductId,
p.Name,
p.ProductNumber AS product_number,
p.Size,
p.Color,
p.ProductSubcategoryId AS product_subcategory_id,
ps.Name AS sub_category,

FROM tc-da-1.adwentureworks_db.product p

INNER JOIN tc-da-1.adwentureworks_db.productsubcategory ps
ON p.ProductSubcategoryID  = ps.ProductSubcategoryID

ORDER BY  sub_category



/*==============================================================

-- 1.2 In 1.1 query you have a product subcategory but see that you could use the category name.

-- Find and add the product category name.
-- Afterwards order the results by Category name.
==============================================================*/


SELECT

p.ProductId,
p.Name,
p.ProductNumber AS product_number,
p.Size,
p.Color,
p.ProductSubcategoryId AS product_subcategory_id,
ps.Name AS sub_category,
pc.Name AS category_name

FROM tc-da-1.adwentureworks_db.product p

INNER JOIN tc-da-1.adwentureworks_db.productsubcategory ps
ON p.ProductSubcategoryID  = ps.ProductSubcategoryID

INNER JOIN tc-da-1.adwentureworks_db.productcategory pc
ON ps.ProductCategoryID = pc.ProductCategoryID

ORDER BY category_name


/*==============================================================

-- 1.3 Use the established query to select the most expensive (price listed over 2000) bikes that are still actively sold (does not have a sales end date)

-- Order the results from most to least expensive bike.
==============================================================*/


SELECT 
p.ProductId,
p.Name,
p.ProductNumber AS product_number,
p.Size,
p.Color,
p.ProductSubcategoryId AS product_subcategory_id,
p.ListPrice AS list_price,
ps.Name AS sub_category,
pc.Name AS category_name

FROM tc-da-1.adwentureworks_db.product p

INNER JOIN tc-da-1.adwentureworks_db.productsubcategory ps
ON p.ProductSubcategoryID  = ps.ProductSubcategoryID

INNER JOIN tc-da-1.adwentureworks_db.productcategory pc
ON ps.ProductCategoryID = pc.ProductCategoryID

WHERE p.ListPrice >2000
AND p.SellEndDate IS NULL

ORDER BY List_price DESC


/*==============================================================
-- 2 TASK 

-- 2.1 Create an aggregated query to select the:

-- Number of unique work orders.
-- Number of unique products.
-- Total actual cost.
-- For each location Id from the 'workoderrouting' table for orders in January 2004.
==============================================================*/

SELECT 
LocationID,

COUNT(DISTINCT WorkOrderID) AS unique_workorders,
COUNT(DISTINCT ProductID) AS unique_productid,
SUM(ActualCost) AS total_cost

FROM `tc-da-1.adwentureworks_db.workorderrouting`

WHERE ActualStartDate >='2004-01-01'
AND ActualStartDate <'2004-02-01'

GROUP BY LocationID


/*==============================================================

-- 2.2 Update your 2.1 query by adding the name of the location and also add the average days 
-- amount between actual start date and actual end date per each location.

==============================================================*/


SELECT 
w.LocationID,
l.name AS location_name,

COUNT(DISTINCT w.WorkOrderID) AS unique_workorders,
COUNT(DISTINCT w.ProductID) AS unique_productid,
SUM(w.ActualCost) AS total_cost,
ROUND(AVG(DATE_DIFF( w.ActualEndDate, w.ActualStartDate, DAY))) AS avg_order_time_days


FROM `tc-da-1.adwentureworks_db.workorderrouting` w

LEFT JOIN `tc-da-1.adwentureworks_db.location` l
ON w.LocationID = l.LocationID

WHERE ActualStartDate >='2004-01-01'
AND ActualStartDate <'2004-02-01' 


GROUP BY LocationID, location_name



/*==============================================================

-- 2.3 Select all the expensive work Orders (above 300 actual cost) that happened through January 2004.

==============================================================*/


SELECT 
WorkOrderID,

FROM `tc-da-1.adwentureworks_db.workorderrouting`

SUM(ActualCost) AS actual_cost

WHERE ActualStartDate >='2004-01-01'

GROUP BY WorkOrderID

HAVING Actual_Cost>=300


/*==============================================================

-- 3. Query validation Below you will find 2 queries that need to be fixed/updated.


-- 3.1 Your colleague has written a query to find the list of orders connected to special offers. The query works fine but the numbers are off, investigate where the potential issue lies.

==============================================================*/

-- Primary Code

SELECT sales_detail.SalesOrderId
          ,sales_detail.OrderQty
          ,sales_detail.UnitPrice
          ,sales_detail.LineTotal
          ,sales_detail.ProductId
          ,sales_detail.SpecialOfferID
          ,spec_offer_product.ModifiedDate
          ,spec_offer.Category
          ,spec_offer.Description

    FROM `tc-da-1.adwentureworks_db.salesorderdetail`  as sales_detail

    left join `tc-da-1.adwentureworks_db.specialofferproduct` as spec_offer_product
    on sales_detail.productId = spec_offer_product.ProductID

    left join `tc-da-1.adwentureworks_db.specialoffer` as spec_offer
    on sales_detail.SpecialOfferID = spec_offer.SpecialOfferID

    order by LineTotal desc


— Fixed code to be correct

SELECT 
  sd.salesorderid,
  sd.orderqty,
  sd.unitprice,
  sd.linetotal,
  sd.productid,
  sd.specialofferid,
  sop.modifieddate,
  so.category,
  so.description

FROM `tc-da-1.adwentureworks_db.salesorderdetail` AS sd

INNER JOIN `tc-da-1.adwentureworks_db.specialofferproduct` AS sop
  ON sd.productid = sop.productid
 AND sd.specialofferid = sop.specialofferid

INNER JOIN `tc-da-1.adwentureworks_db.specialoffer` AS so
  ON sd.specialofferid = so.specialofferid

ORDER BY sd.linetotal DESC;


— *Naming Convention (Short alias, commas. Snake case,)
— *Incorrect JOIN method has been chosen. Both Left joins needs to be changed to INNER join as we want to have additional data for our table, not adding rows from other tables that do not have offer
— `tc-da-1.adwentureworks_db.specialofferproduct` - Required AND operator. As without it, only would Join Product ID, and would match to many rows. 


/*==============================================================

-- 3.2 Your colleague has written this query to collect basic Vendor information. The query does not work, 
-- look into the query and find ways to fix it. Can you provide any feedback on how to make this query be easier to debug/read?

==============================================================*/

— Primary Code 


SELECT  a.VendorId as Id,vendor_contact.ContactId, b.ContactTypeId,
        a.Name,
        a.CreditRating,
        a.ActiveFlag,
        c.AddressId,d.City

FROM `tc-da-1.adwentureworks_db.Vendor` as a

left join `tc-da-1.adwentureworks_db.vendorcontact` as vendor_contact
on vendor.VendorId = vendor_contact.VendorId
left join `tc-da1.adwentureworks_db.vendoraddress` as c on a.VendorId = c.VendorId

left join `tc-da-1.adwentureworks_db.address` as address
on vendor_address.VendorId = d.VendorId


— Fixed code to be correct

SELECT  
    v.VendorId AS vendor_id,
    vc.ContactId,
    vc.ContactTypeId,
    v.Name,
    v.CreditRating,
    v.ActiveFlag,
    va.AddressId,
    ad.City

FROM `tc-da-1.adwentureworks_db.vendor` v

LEFT JOIN `tc-da-1.adwentureworks_db.vendorcontact` vc
    ON v.VendorId = vc.VendorId

LEFT JOIN `tc-da-1.adwentureworks_db.vendoraddress` va
    ON v.VendorId = va.VendorId

LEFT JOIN `tc-da-1.adwentureworks_db.address` ad
    ON va.AddressId = ad.AddressId;



— Comments:
— * Naming Convention (Short alias,. Snake case,)
— * Naming tables as - not needed
— * Join formulas convention
— * `tc-da1 - Incorrect table name, did not allow to run a query
— * vendor.VendorId - was set as a - but in join part mentioned as vendor.
— * Alias mismatch - vendor_address - is stated as C,


