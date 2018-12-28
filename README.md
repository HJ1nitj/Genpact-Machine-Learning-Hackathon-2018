![title](genpact.jpg)

# Genpact-Machine-Learning-Hackathon-2018



## Introduction
Genpact and Analytics Vidhya presents the “Genpact Machine Learning Hackathon 2018”. A great opportunity to showcase your machine learning and analytical abilities and compete with the best data scientists out there.

## Problem Statement
Your client is a meal delivery company which operates in multiple cities. They have various fulfillment centers in these cities for dispatching meal orders to their customers. The client wants you to help these centers with demand forecasting for upcoming weeks so that these centers will plan the stock of raw materials accordingly.

The replenishment of majority of raw materials is done on weekly basis and since the raw material is perishable, the procurement planning is of utmost importance. Secondly, staffing of the centers is also one area wherein accurate demand forecasts are really helpful. Given the following information, the task is to predict the demand for the next 10 weeks (Weeks: 146-155) for the center-meal combinations in the test set:

#### Column	Description
* **id**	Unique transaction id
* **week**	Week number; training data had weeks 1 through 145
* **center_id**	Unique identifier for the branch of the online food delivery business
* **meal_id	Unique** identifier for the meal
* **checkout_price**	Price of the meal after discounts, coupons, etc
* **base_price**	Base price of the meal
* **emailer_for_promotion**	Boolean indicating whether the meal was promoted via email
* **homepage_featured**	Boolean indicating whether the meal was featured on the website’s homepage
* **num_orders**	The target (or dependent) variable we were asked to predict


There was also the following information about the branch of the food delivery business.

#### Column	Description
* **center_id**	Unique identifier for the branch of the online food delivery business
* **city_code**	Unique identifier for the city in which the branch operates
* **region_code**	Unique identifier for the region in which the branch operates
* **center_type**	Categorical variable for the branch type
* **op_area**	Operating area of the branch


Then, there was some information about the meal’s themselves.

#### Column	Description
* **meal_id**	Unique identifier for the meal
* **category**	The meal category
* **cuisine**	The meal cuisine (categorical variable)



**Total Particpants : 3872**

### Leaderboard
Public LB : 74th Rank

Private LB : 74th Rank 

### Link to hackathon
https://datahack.analyticsvidhya.com/contest/genpact-machine-learning-hackathon/
