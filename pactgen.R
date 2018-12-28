require(xgboost)
require(Matrix)
require(dplyr)
require(recipes)
require(keras)
###############################################################################################

train= read.csv("C:/Users/ssharan/Desktop/pactgen/train/train.csv")
meal_info= read.csv("C:/Users/ssharan/Desktop/pactgen/train/meal_info.csv")
fulfilment_center_infoo= read.csv("C:/Users/ssharan/Desktop/pactgen/train/fulfilment_center_info.csv")

test=read.csv("C:/Users/ssharan/Desktop/pactgen/test.csv")

submission <- read.csv("C:/Users/ssharan/Desktop/pactgen/sample_submission.csv")

################################################################################################

#test

master_data<- merge(x=train,y=meal_info,by='meal_id',all.x = T)
master_data<- merge(x=master_data,y=fulfilment_center_infoo,by='center_id',all.x = T)

#train master

master_data_test<- merge(x=test,y=meal_info,by='meal_id',all.x = T)
master_data_test<- merge(x=master_data_test,y=fulfilment_center_infoo,by='center_id',all.x = T)



total_data <- rbind(master_data[,!names(master_data) %in% c("num_orders")],master_data_test)



############################### Wrangling ############################

meal_info_group <- data.frame(master_data %>%  group_by(meal_id) %>% summarise( Total_Orders_meal=sum(num_orders)))
centre_id_group <- data.frame(master_data %>% group_by(center_id) %>% summarise( Total_Orders_center=sum(num_orders)))

city_code_group <- data.frame(master_data %>% group_by(city_code) %>% summarise( Total_Orders_city=sum(num_orders)))


region_code_group <- data.frame(master_data %>% group_by(region_code) %>% summarise( Total_Orders_region=sum(num_orders)))




meal_info_group <- meal_info_group[order(meal_info_group[,c("Total_Orders_meal")]),]
meal_info_group$meal_id_type <- as.factor(ifelse(meal_info_group$Total_Orders_meal < 1018280,"Low",
                                       ifelse(meal_info_group$Total_Orders_meal >= 8346246,"Very High",
                                              ifelse(((meal_info_group$Total_Orders_meal < 8346246) & (meal_info_group$Total_Orders_meal >= 4712795) ),"High","Medium"))))


centre_id_group <- centre_id_group[order(centre_id_group[,c("Total_Orders_center")]),]
centre_id_group$centre_id_type <- as.factor(ifelse(centre_id_group$Total_Orders_center < 1015920,"Low",
                                                 ifelse(centre_id_group$Total_Orders_center >= 3920294,"Very High",
                                                        ifelse(((centre_id_group$Total_Orders_center < 3920294) & (centre_id_group$Total_Orders_center > 2427542) ),"High","Medium"))))



city_code_group <- city_code_group[order(city_code_group[,c("Total_Orders_city")]),]
city_code_group$city_code_type <- as.factor(ifelse(city_code_group$Total_Orders_city < 1015920,"Low",
                                                 ifelse(city_code_group$Total_Orders_city > 9207953,"Very High",
                                                        ifelse(((city_code_group$Total_Orders_city <= 9207953) & (city_code_group$Total_Orders_city >= 6662450) ),"High","Medium"))))



region_code_group <- region_code_group[order(region_code_group[,c("Total_Orders_region")]),]
region_code_group$region_code_type <- as.factor(ifelse(region_code_group$Total_Orders_region <= 1366290,"Low",
                                                   ifelse(region_code_group$Total_Orders_region > 24051733,"Very High",
                                                          ifelse(((region_code_group$Total_Orders_region <= 24051733) & (region_code_group$Total_Orders_region > 8685386) ),"High","Medium"))))






master_data = merge(x=master_data,y=meal_info_group, on="meal_id",all.x = T)
master_data = merge(x=master_data,y=centre_id_group, on="center_id",all.x = T)
master_data = merge(x=master_data,y=city_code_group, on="city_code",all.x = T)
master_data = merge(x=master_data,y=region_code_group, on="region_code",all.x = T)


master_data_test = merge(x=master_data_test,y=meal_info_group, on="meal_id",all.x = T)
master_data_test = merge(x=master_data_test,y=centre_id_group, on="center_id",all.x = T)
master_data_test = merge(x=master_data_test,y=city_code_group, on="city_code",all.x = T)
master_data_test = merge(x=master_data_test,y=region_code_group, on="region_code",all.x = T)









# data engineering


master_data<- master_data[order(master_data[,c("week")]),]
master_data$Discount <- master_data$base_price-master_data$checkout_price
master_data$Ratio <- master_data$base_price / master_data$checkout_price
master_data$discount_percentage <-  master_data$Discount /master_data$base_price 
master_data$Discount_type <- as.factor(ifelse(((master_data$Discount <= -75) & (master_data$Discount > -125)),"High" ,  ifelse(((master_data$Discount <= -25) & (master_data$Discount >= -75)),"Medium",
                                                                                                                               ifelse(((master_data$Discount < 0) & (master_data$Discount >= -25)),"Low","No_discount"))))
master_data$Discount_availed <- as.factor(ifelse(master_data$Discount > 0 ,1,0))

master_data$ratio_city_by_center <- master_data$Total_Orders_city/master_data$Total_Orders_center

master_data$ratio_region_by_city <- master_data$Total_Orders_region/master_data$Total_Orders_city




master_data$id <- NULL
master_data$center_id <-  NULL#as.factor(master_data$center_id)
master_data$meal_id <-   NULL #as.factor(master_data$meal_id)
master_data$week <- NULL#as.factor(master_data$week)
master_data$emailer_for_promotion<- as.factor(master_data$emailer_for_promotion)
master_data$homepage_featured <- as.factor(master_data$homepage_featured)
master_data$city_code <-  NULL #as.factor(master_data$city_code)
master_data$region_code <- as.factor(master_data$region_code)


master_data$op_area_cat <- as.factor(ifelse(master_data$op_area <= 3, "Low",ifelse(master_data$op_area >= 4.5,"Medium","High")))

master_data$Profit_margin <-  as.factor(ifelse(master_data$Discount >= 450, "Very_High",ifelse(((master_data$Discount < 450) & (master_data$Discount >= 250)),"High" ,  ifelse(((master_data$Discount >= 100) & (master_data$Discount < 250)),"Medium",
                                                                                                                                                                                 ifelse(((master_data$Discount > 0) & (master_data$Discount < 100)),"Low","Loss")))))





# master_data$Discount <- scale(master_data$Discount)
# master_data$base_price <- scale(master_data$base_price)
# master_data$checkout_price <- scale(master_data$checkout_price)
# master_data$Total_Orders_center <- scale(master_data$Total_Orders_center)
# master_data$Total_Orders_meal <- scale(master_data$Total_Orders_meal)



#test data

master_data_test <- master_data_test[order(master_data_test[,c("week")]),]
master_data_test$Discount <- master_data_test$base_price-master_data_test$checkout_price
master_data_test$Ratio <- master_data_test$base_price / master_data_test$checkout_price
master_data_test$discount_percentage <-  master_data_test$Discount/master_data_test$base_price 
master_data_test$Discount_type <- as.factor(ifelse(((master_data_test$Discount <= -75) & (master_data_test$Discount > -125)),"High" ,  ifelse(((master_data_test$Discount <= -25) & (master_data_test$Discount >= -75)),"Medium",
                                                                                                                                              ifelse(((master_data_test$Discount < 0) & (master_data_test$Discount >= -25)),"Low","No_discount"))))
master_data_test$Discount_availed <- as.factor(ifelse(master_data_test$Discount > 0 ,1,0))
master_data_test$ratio_city_by_center <- master_data_test$Total_Orders_city/master_data_test$Total_Orders_center
master_data_test$ratio_region_by_city <- master_data_test$Total_Orders_region/master_data_test$Total_Orders_city


master_data_test_copy <- master_data_test

master_data_test$id <- NULL
master_data_test$center_id <- NULL#as.factor(master_data_test$center_id)
master_data_test$meal_id <- NULL#as.factor(master_data_test$meal_id)
master_data_test$week <- NULL#as.factor(master_data_test$week)
master_data_test$emailer_for_promotion<- as.factor(master_data_test$emailer_for_promotion)
master_data_test$homepage_featured <- as.factor(master_data_test$homepage_featured)
master_data_test$city_code <- NULL#as.factor(master_data_test$city_code)
master_data_test$region_code <- as.factor(master_data_test$region_code)

master_data_test$op_area_cat <- as.factor(ifelse(master_data_test$op_area <= 3, "Low",ifelse(master_data_test$op_area >= 4.5,"Medium","High")))

master_data_test$Profit_margin <-  as.factor(ifelse(master_data_test$Discount >= 450, "Very_High",ifelse(((master_data_test$Discount < 450) & (master_data_test$Discount >= 250)),"High" ,  ifelse(((master_data_test$Discount >= 100) & (master_data_test$Discount < 250)),"Medium",
                                                                                                                                                                               ifelse(((master_data_test$Discount > 0) & (master_data_test$Discount < 100)),"Low","Loss")))))


# master_data_test$Discount <- scale(master_data_test$Discount)
# master_data_test$base_price <- scale(master_data_test$base_price)
# master_data_test$checkout_price <- scale(master_data_test$checkout_price)
# master_data_test$Total_Orders_center <- scale(master_data_test$Total_Orders_center)
# master_data_test$Total_Orders_meal <- scale(master_data_test$Total_Orders_meal)
# 


master_data$num_orders <- log(master_data$num_orders)


####################################################################################################


x_test<- model.matrix(~.+0 ,data = master_data_test)

x_train <- model.matrix(~.+0,data = master_data[,!names(master_data) %in% c("num_orders")])

total_train <- model.matrix(~.+0,data = master_data)

#convert factor to numeric 

y_train <- as.matrix(master_data[,names(master_data) %in% c("num_orders")])

############################## XGboost ############################################

param_xg <- list(booster = "gbtree",
                 objective = "reg:linear" ,    #  regression  
                 
                 eval_metric = "rmse",    # evaluation metric 
                 nthread = 8,   # number of threads to be used 
                 max_depth= 9,    # maximum depth of tree 
                 eta = 0.2,    # step size shrinkage 
                 alpha=0,
                 gamma = 0.1,    # minimum loss reduction 
                 subsample = 1,    # part of data instances to grow tree 
                 colsample_bytree = 1,  # subsample ratio of columns when constructing each tree 
                 min_child_weight = 1  # minimum sum of instance weight needed in a child
                 
)

xg_fit <- xgboost(params = param_xg,data=x_train,label = y_train,nrounds = 15)


result <- data.frame(predict(xg_fit,x_test))
colnames(result)<- "num_orders"


submission1<- data.frame(id= master_data_test_copy$id,num_orders=result$num_orders)

submission1$num_orders <- exp(submission1$num_orders)

submission2 <- merge(x=submission,y=submission1,by="id",all.x = T,sort = F)

submission2$num_orders.x <- NULL

colnames(submission2) <- c("id","num_orders")
write.csv(submission2,"C:/Users/ssharan/Desktop/pactgen/submission5.csv", row.names = F)




