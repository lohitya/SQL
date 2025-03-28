SELECT * FROM practice.orders_2022;

# TOTAL ORDER COUNT
SELECT count('Order ID') FROM practice.orders_2022;

# order count by ship mode
select `Ship Mode`, count(`Order ID`) AS 'Order count' from practice.orders_2022
group by `Ship Mode`;

# ORDER BY SEGMENT
select Segment, count('Order ID') as 'order_count', sum(revenue) AS 'Revenue by Segment', SUM(Profit) as 'Profit by Segment' FROM practice.orders_2022
GROUP BY Segment;

# Revenue, Profit by Region, Segment
SELECT  Region, Segment, sum(Revenue) as 'Region Revenue' , round(Sum(Profit),2) AS 'Regional profit' FROM practice.orders_2022
GROUP BY Region, Segment
ORDER BY Region ASC;

# Revenue by Category, Sub-Category
SELECT Category, `Sub-Category`, sum(Revenue) as 'Category Revenue' FROM practice.orders_2022
GROUP BY Category, `Sub-Category`
ORDER BY Category ASC, SUM(Revenue) DESC;

SELECT YEAR(`Order Date`) as Year, SUM(Revenue) as 'Tot_Revenue' FROM practice.orders_2022
GROUP BY Year ;

# year on year sales
SELECT YEAR(`Order Date`) AS YEAR , 
SUM(revenue) as 'Tot_Revenue',
LAG(SUM(revenue)) OVER ( ORDER BY YEAR(`Order Date`)) AS 'Previous_year_sales',
( SUM(revenue)- LAG(SUM(revenue)) OVER ( ORDER BY YEAR(`Order Date`)) ) AS 'YOY',
round(( SUM(revenue)- LAG(SUM(revenue)) OVER ( ORDER BY YEAR(`Order Date`))  ) /( LAG(SUM(revenue)) OVER ( ORDER BY YEAR(`Order Date`)))  * 100, 2) AS 'YOY_% CHANGE'
FROM practice.orders_2022
Group by YEAR(`Order Date`);


# year, month, revenue
select year(`Order Date`) as Year, month(`Order Date`) as Month , sum(revenue) as Revenue from practice.orders_2022
group by Year,Month;

# Sales by date 
SELECT `Order ID`, 
`Order Date`, 
revenue, 
sum(revenue) over ( ORDER BY `Order Date` RANGE BETWEEN unbounded preceding AND CURRENT ROW) AS `Running_total revenue`
FROM practice.orders_2022;


### REGIONAL ANALYSIS
## TOP 5 STATES BY REVENUE IN EACH COUNTRY
with Ranked as (
SELECT `Country/Region`, `State/Province`, Revenue,
dense_rank() OVER ( partition by  `Country/Region` ORDER BY Revenue DESC) as StateRank
FROM practice.orders_2022
)

select `Country/Region`, `State/Province`, Revenue 
from Ranked
where StateRank <= 5
order by `Country/Region`, StateRank ;

#find second highest and second lowest value order for each region
with ranked as(
select region, `order ID`, revenue,
dense_rank() over ( partition by region  order by revenue DESC) as 'highest_rank_no',
dense_rank() over ( partition by region  order by revenue asc) as 'Lowest_rank_no'
FROM practice.orders_2022
)
select region, `Order ID`, revenue, highest_rank_no, lowest_rank_no from ranked
where highest_rank_no = 2 or lowest_rank_no = 2
order by region,revenue;


# Revenue by regional Managers
select p.`Regional Manager`, sum(o.revenue) as Revenue 
from practice.orders_2022 as o
left join practice.people_2022 as p 
ON o.Region = p.Region
GROUP BY p.`Regional Manager`;

select * from practice.returns_2022; 

# No of returned orders
select count(distinct `Order ID`) as 'returned count' from practice.returns_2022;

# no of orders retunred whose revenue was below avg revenue
select count(distinct o.`Order ID`) as 'Order below Avg' 
from practice.orders_2022 AS o
inner join practice.returns_2022 as r
on o.`Order ID` = r.`Order ID`
WHERE o.revenue < (select avg(revenue)from practice.orders_2022 );

# no of orders returned, orders below avg revenue returned from each region
SELECT 
    o.Region, 
    COUNT(DISTINCT o.`Order ID`) AS `Returned Count`,
    COUNT(DISTINCT CASE 
        WHEN o.Revenue < (SELECT AVG(Revenue) FROM practice.orders_2022) 
        THEN o.`Order ID` 
    END) AS `Returned Below Avg Revenue`
FROM practice.orders_2022 AS o
INNER JOIN practice.returns_2022 AS r
ON o.`Order ID` = r.`Order ID`
GROUP BY o.Region;

# 
