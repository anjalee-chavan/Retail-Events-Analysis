## 🛒Retail Events Analysis

### 🔍Problem Statement
AtliQ Mart is a retail giant with over 50 supermarkets in the southern region of India. All their 50 stores ran a massive promotion during the Diwali 2023 and Sankranti 2024. Now the sales director wants to understand which promotions did well and which did not so that they can make informed decisions for their next promotional period.

### 📊Task
As a Data Analyst, I provided insightful analyses and recommendations for AtliQ's products based on ad-hoc queries and strategic questions.

### 📂Dataset Information
#### Given SQL database file contain following tables<br>
dim_campaigns<br>
dim_products<br>
dim_stores<br>
fact_events<br>

### ⚙️Tools Used
Programming Language : SQL <BR>
RDBMS : MySQL 

### Recommended Insights
1)Provide alist of products with a base price greater than 500 and that are featured in promo type of 'BOGOF' (Buy One Get One Free). This information will help us identify high-value products that are currently being heavily discounted, which can be useful for evaluating our pricing and promotion strategies.<br>
2)Generate a report that provides an overview of the number of stores in each city.The results will be sorted in descending order of store counts, allowing us to identify the cities with the highest store presence.The report includes two essential fields: city and store count, which will assist in optimizing our retail operations.<br>
3)Generate a report that displays each campaign along with the total revenue generated before and after the campaign? The report includes three key fields: campaign_name, total_revenue(before_promotion),total_revenue(after_promotion). This report should help in evaluating the financial impact of our promotional campaigns. (Display the values in millions) <br>
4)Produce a report that calculates the Incremental Sold Quantity (ISU%) for each category during the Diwali campaign. Additionally, provide rankings for the categories based on their ISU%. The report will include three key fields: category, isu%, and rank order. This information will assist in assessing the category-wise success and impact of the Diwali campaign on incremental sales.<br>
5)Create a report featuring the Top 5 products, ranked by Incremental Revenue Percentage (IR%), across all campaigns. The report will provide essential information including product name, category, and ir%. This analysis helps identify the most successful products in terms of incremental revenue across our campaigns, assisting in product optimization.<br>

#### Store Performance Analysis
1)Which are the top 10 stores in terms of Incremental Revenue (IR) generated from the promotions?<br>
2)Which are the bottom 10 stores when it comes to Incremental Sold Units (ISU)
during the promotional period?<br>
3)How does the performance of stores vary by city? Are there any common
characteristics among the top-performing stores that could be leveraged across
other stores?<br>

#### Promotion Type Analysis
1)What are the top 2 promotion types that resulted in the highest Incremental
Revenue?<br>
2)What are the bottom 2 promotion types in terms of their impact on Incremental
Sold Units?<br>
3)Is there a significant difference in the performance of discount-based promotions
versus BOGOF (Buy One Get One Free) or cashback promotions?500 cashback and BOGOF<br>
4)Which promotions strike the best balance between Incremental Sold Units and
maintaining healthy margins? 500 cashback and BOGOF<br>

#### Product and Category Analysis
1)Which product categories saw the most significant lift in sales from the
promotions?<br>
2)Are there specific products that respond exceptionally well or poorly to
promotions?<br>
2)What is the correlation between product category and promotion type
effectiveness?<br>
