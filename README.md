# Superstore Sales & Profit Analysis (SQL)

Sales isn't profit. Using SQL to uncover where a retail store really makes and loses money.

## The Story
Superstore looked successful: thousands of orders and growing sales. But the owner had
one worry: "We sell a lot, but are we actually making money?" This project answers that
using only SQL on four years of retail data (about 10,000 transactions).

## Problem Statement
Superstore wants to understand its sales and profitability. Using SQL, I analysed
four years of transaction data to find loss-making products, measure the impact of
discounts, track growth over time, and segment customers by value.

## Dataset
Superstore Sales dataset from Kaggle (9,994 rows, 21 columns, 2014-2017).
Link: https://www.kaggle.com/datasets/vivek468/superstore-dataset-final

## Tools
MySQL 8.0, DBeaver

## Data Cleaning
- Imported the CSV into MySQL and kept the raw table unchanged as a backup
- Checked for duplicate Row IDs and missing values
- Checked value ranges for sales, quantity, discount and profit
- Converted text dates to DATE using STR_TO_DATE(order_date, '%m/%d/%Y')
- Created a clean table with consistent column names

## Questions Answered
1. What are the total sales, profit, orders and customers?
2. Which categories and regions are most and least profitable?
3. Which sub-categories lose money?
4. Do higher discounts reduce profit?
5. How did sales grow year over year, and which months are busiest?
6. Who are the top products in each category?
7. Which customers are Champions, At Risk or Lost (RFM segmentation)?

## SQL Concepts Used
GROUP BY, HAVING, CASE WHEN, CTEs, window functions (LAG, RANK, NTILE),
date functions, subqueries

## How to Run
1. Import the dataset into MySQL
2. Run the cleaning steps
3. Run the queries in superstore_analysis.sql in order
