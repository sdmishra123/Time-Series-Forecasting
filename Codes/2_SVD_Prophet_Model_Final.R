########### PROPHET MODEL ################
library(forecast)
library(ggplot2)
library(plyr)
library(dplyr)
library(reshape)
library(tseries)
library(TSPred)
detach(package:plyr)
library(tseries)
library(prophet)
library(lubridate)
library(stringr)

setwd("C:/Sapna/Graham/Time Series/Project/Data files")

######################## Cleaned Loops for all the Departments

#Reading the Raw Data
raw.train <- function(){
  # Loads the training data with correct classes
  train_raw<- read.csv('cleansed_train_data.csv')
  
  train<-train_raw%>% 
    group_by(Store,week) %>%
    summarise(Total_Sales = sum(Sales)) %>%
    select(week,Store,Total_Sales) 
  
  names(train) <- c("Date","Store","Weekly_Sales")  
  return(train)
}

# Transposing the data to create a matrix of date by stores for each department
train_tr <- function(raw.train){
  tr.data <- raw.train
  # Transpose to create a matrix of dates x stores with values populated as weekly sales
  train.processed <- cast(tr.data,Date ~ Store)
  return(train.processed)
}

# Calculating the SVD
preprocess.svd <- function(train,nu.arg = nrow(train),nv.arg = ncol(train)){
  # Filling in missing values with 0 for the SVD function to work
  train[is.na(train)] <- 0
  z <- svd(train[, 2:ncol(train)], nu=nu.arg, nv=nv.arg-1)
  return(z)
}

forecast.reduced.arima <- function(reduced.train){
  
  proph_df <-data.frame(train.processed$Date,reduced.train)
  names(proph_df) <-c("Date","y1","y2","y3")
  
  proph_df <- proph_df%>%
    mutate(ds=ymd(Date))
  
  y1_data <- data.frame(proph_df$Date,proph_df$y1)
  y2_data <- data.frame(proph_df$Date,proph_df$y2)
  y3_data <- data.frame(proph_df$Date,proph_df$y3)
  
  y1_data <- y1_data%>%
    mutate(proph_df.Date=ymd(proph_df.Date))
  names(y1_data) <-c("ds","y")
  
  y2_data <- y2_data%>%
    mutate(proph_df.Date=ymd(proph_df.Date))
  names(y2_data) <-c("ds","y")
  
  y3_data <- y3_data%>%
    mutate(proph_df.Date=ymd(proph_df.Date))
  names(y3_data) <-c("ds","y")

  c1.forecast<-prophet(y1_data,weekly.seasonality="TRUE",seasonality.mode="multiplicative",seasonality.prior.scale=15)
  c1.future  <- make_future_dataframe(c1.forecast,freq ='week',periods = 4)
  c1.pred <- predict(c1.forecast, c1.future)
  c1.new  <- c1.pred$yhat
  
  c2.forecast<-prophet(y2_data,weekly.seasonality="TRUE",seasonality.mode="multiplicative",seasonality.prior.scale=15)
  c2.future <- make_future_dataframe(c2.forecast,freq ='week',periods = 4)
  c2.pred <- predict(c2.forecast, c2.future)
  c2.new <- c2.pred$yhat
  
  
  c3.forecast<-prophet(y3_data,weekly.seasonality="TRUE",seasonality.mode="multiplicative",seasonality.prior.scale=15)
  c3.future <- make_future_dataframe(c3.forecast,freq ='week',periods = 4)
  c3.pred <- predict(c2.forecast, c3.future)
  c3.new <- c3.pred$yhat
  
  # Re-Creating the forecasted u dot product s
  reduced.train.forecast <- as.matrix(cbind(c1.new[1:130],c2.new[1:130],c3.new[1:130]))
  reduced.train.pred     <- as.matrix(cbind(c1.new[131:134],c2.new[131:134],c3.new[131:134]))
  return(list(reduced.train.forecast,reduced.train.pred))
  
}

# Using the 3 components to create the reduced train data to forecast and return the forecasted train and test data
dept.forecast.arima <- function(train.processed){
  
  svd.result <- preprocess.svd(train.processed)
  S <- diag(svd.result$d,nrow = nrow(train.processed),ncol = ncol(train.processed)-1)
  us <- svd.result$u%*%S
  usvt <- us%*%t(svd.result$v)
  
  # Considering only the first 3 components since they explain 99% of variance
  reduced.train <- us[,1:3]
  
  # Running a arima forecast on the 3 columns of the u dot s
  arima.list <- forecast.reduced.arima(reduced.train)
  
  # THe Training data forecast from the model. A matrix of 3 columns - Fitted Values
  reduced.train.forecast <- as.matrix(arima.list[[1]])
  
  # The forecasted test data for 4 future weeks
  reduced.train.pred <- as.matrix(arima.list[[2]])
  
  # Recosntructing back the forecasted matrix of weeks by stores - For Train Data 
  us.forecast   <- as.matrix(cbind(reduced.train.forecast,us[,4:ncol(us)])) #Combined Fitted and the U values
  dept.forecast <- us.forecast%*%t(svd.result$v) #Reconstructed values
  
  ### Prediction
  # Recosntructing back the forecasted matrix of weeks by stores - For Test Data
  us.predict <- as.matrix(cbind(reduced.train.pred,us[127:130,4:ncol(us)])) #Combine Forecasted and the U values
  dept.pred  <- us.predict%*%t(svd.result$v) #Reconstructed values
  
  return(list(dept.forecast,dept.pred))
}


# Reading the Raw Data
train.data <- raw.train()

## ARIMA
# Preprocessing the data
train.tran      <- train_tr(train.data)
train.processed <- train.tran[1:130,]
test            <- train.tran[131:134,]


# Training for Dept 1 Sales
dept.1.list     <- dept.forecast.arima(train.processed)
dept.1.forecast <- dept.1.list[[1]]
dept.1.pred     <- dept.1.list[[2]]

#write.csv(dept.1.pred,"Forecasted.csv")

## SMAPE For Train Data
c(train_smape=sMAPE(as.vector(as.matrix(train.processed[,2:ncol(train.processed)])),as.vector(as.matrix(dept.1.forecast))),
  ## SMAPE for Test Data
  test_smape=sMAPE(as.vector(as.matrix(test[,2:ncol(train.processed)])),as.vector(as.matrix(dept.1.pred))))

RMSE.error <- function(train.forecast,train.processed){
  rmse <- sqrt(sum((train.forecast-train.processed)^2)/nrow(train.forecast))
  return(rmse)
  
}

RMSE.error(dept.1.forecast,train.processed[,2:ncol(train.processed)])
RMSE.error(dept.1.pred,test[,2:ncol(train.processed)])


################################# Data Prep for Shiny App #######################################################################

dept.1.pred_mat<-as.matrix(dept.1.pred)

colnames(dept.1.pred_mat)<-colnames(train.tran[,-1])
rownames(dept.1.pred_mat)<-c("131","132","133","134")

test_v1<-cbind(Type=c("Actual","Actual","Actual","Actual"),test)

dept.1.pred_mat_v1 <- cbind(Type=c("Predicted","Predicted","Predicted","Predicted"),
                            Date=c("2015-07-05" ,"2015-07-12" ,"2015-07-19", "2015-07-26"),
                            dept.1.pred_mat)

Actual_Predicted <- data.frame(rbind(test_v1,dept.1.pred_mat_v1))
colnames(Actual_Predicted)
Actual_Predicted_trans <-data.frame(t(Actual_Predicted))
Actual_Predicted_trans_v1<-Actual_Predicted_trans[3:nrow(Actual_Predicted_trans),]

Actual_Predicted_trans_v1$Stores <-rownames(Actual_Predicted_trans_v1)
Actual_Predicted_trans_v1$Stores <- str_sub(Actual_Predicted_trans_v1$Stores,2,length(Actual_Predicted_trans_v1$Stores))


names(Actual_Predicted_trans_v1) <- c("WeekAct:2015-07-05","WeekAct:2015-07-12" ,"WeekAct:2015-07-19", "WeekAct:2015-07-26",
                                      "WeekPred:2015-07-05","WeekPred:2015-07-12" ,"WeekPred:2015-07-19", "WeekPred:2015-07-26","Stores")


head(Actual_Predicted_trans_v1)
Actual_Predicted_trans_v1$Type <- "Prophet" 

write.csv(Actual_Predicted_trans_v1,"Actual_Predicted_trans_Prophet.csv")







