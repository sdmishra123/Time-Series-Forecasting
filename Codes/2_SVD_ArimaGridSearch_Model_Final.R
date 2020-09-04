########### ARIMA MODEL ################


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

# Reading the Raw Data
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

# Using Arima to do a univariate ts forecast on the reduced train data
forecast.reduced.arima <- function(reduced.train){
  
  c1 <- ts(reduced.train[,1],frequency = 52)
  auto.arima(c1,stepwise = F,approximation = F,seasonal=TRUE)
  adf.test(c1)
  kpss.test(c1)
  nsdiffs(c1)
  ndiffs(c1)
  Box.test(c1,type='Ljung')
  acf(c1)
  pacf(c1)
  
  p1 = 2
  q1 = 0
  d1=0
  aic.grid = c()
  bic.grid = c()
  
  ##COnsidering the auto.arima orders as the initial points for the grid search
  p.val = c()
  #d.val = c()
  q.val = c()
  
  for (i in 0:5){
    for (j in 0:5){
      aic.grid = append(aic.grid, Arima(c1,order = c(p1+i,0,q1+j) )$aicc)
      bic.grid = append(bic.grid,Arima(c1,order = c(p1+i,0,q1+j))$bic)
      p.val    = append(p.val,p1+i)
      #d.val    = append(d.val,d1+j)
      q.val    = append(q.val,q1+j)
    }
  }
  
  p.val[which.min(aic.grid)]
  #d.val[which.min(aic.grid)]
  q.val[which.min(aic.grid)]
  
  min(aic.grid)
  
  c1 <- ts(reduced.train[,1],frequency = 52)
  Arima(c1,order=c(2,0,0),lambda=lambda) #Best orders as per the grid search
  Arima(c1,order=c(2,0,3)) #AIC increases
  #Final order for c1 (2,0,0)
  lambda <- BoxCox.lambda(c1)
  c1.forecast <- Arima(c1,order=c(2,0,0),lambda=lambda)
  c1.new <- c1.forecast$fitted
  c1.pred <- forecast(c1.forecast,h = 4)
  
  c2 <- ts(reduced.train[,2],frequency = 52)
  
  auto.arima(c2,stepwise = F,approximation = F,seasonal=TRUE)
  adf.test(c2) #Not stationary
  kpss.test(c2) #Says it's stationary
  nsdiffs(c2)
  ndiffs(c2)
  Box.test(c2,type='Ljung')
  acf(c2)
  acf(diff(c2))
  pacf(c2)
  
  #COnsidering the auto.arima orders as the initial points for the grid search
  p1 = 2
  d1=1
  q1 = 2
  
  aic.grid = c()
  bic.grid = c()
  
  p.val = c()
  #d.val = c()
  q.val = c()
  
  for (i in 0:5){
    #for (j in 0:5){
    for (k in 0:5){
      aic.grid = append(aic.grid,Arima(c2,order = c(p1+i,1,q1+k),method="ML")$aicc)
      bic.grid = append(bic.grid,Arima(c2,order = c(p1+i,1,q1+k),method="ML")$bic)
      p.val    = append(p.val,p1+i)
      #d.val    = append(d.val,d1+j)
      q.val    = append(q.val,q1+k)
    }
    #}
  }
  
  p.val[which.min(aic.grid)]
  #d.val[which.min(aic.grid)]
  q.val[which.min(aic.grid)]
  min(aic.grid)
  
  Arima(c2,order=c(2,1,2)) #Best orders as per the grid search
  Arima(c2,order=c(2,1,4)) #AIC increases
  
  lambda <- BoxCox.lambda(c2)
  c2.forecast <- Arima(c2,order=c(2,1,2),lambda=lambda)
  c2.new <- c2.forecast$fitted
  c2.pred <- forecast(c2.forecast,h = 4)
  
  c3 <- ts(reduced.train[,3],frequency = 52)
  auto.arima(c3,stepwise = F,approximation = F)
  adf.test(c3) #Not stationary
  kpss.test(c3) #Says it's stationary
  nsdiffs(c3)
  ndiffs(c3)
  Box.test(c3,type='Ljung')
  acf(c3)
  acf(diff(c3))
  pacf(c3)
  
  #COnsidering the auto.arima orders as the initial points for the grid search
  p1 =1
  d1=1
  q1 =2
  
  aic.grid = c()
  bic.grid = c()
  
  p.val = c()
  d.val = c()
  q.val = c()
  #seas <- seasonaldummy(c3)
  for (i in 0:5){
    #for (j in 0:1){
    for (k in 0:5){
      aic.grid = append(aic.grid,Arima(c3,order = c(p1+i,1,q1+k))$aicc)
      bic.grid = append(bic.grid,Arima(c3,order = c(p1+i,1,q1+k))$bic)
      p.val    = append(p.val,p1+i)
      #d.val    = append(d.val,d1+j)
      q.val    = append(q.val,q1+k)
    }
    #}
  }
  
  aic.grid
  p.val[which.min(aic.grid)]
  #d.val[which.min(aic.grid)]
  q.val[which.min(aic.grid)]
  min(aic.grid)
  
  Arima(c3,order=c(1,1,2)) #Best orders as per the grid search
  Arima(c3,order=c(1,1,4)) #AIC increases
  lambda <- BoxCox.lambda(c3)
  c3.forecast <- Arima(c3,order=c(1,1,2),lambda=lambda)
  c3.new <- c3.forecast$fitted
  c3.pred <- forecast(c3.forecast,h = 4)
  
  # Re-Creating the forecasted u dot product s
  reduced.train.forecast <- as.matrix(cbind(c1.new,c2.new,c3.new))
  
  reduced.train.pred <- as.matrix(cbind(summary(c1.pred)[,1],summary(c2.pred)[,1],summary(c3.pred)[,1]))
  return(list(reduced.train.forecast,reduced.train.pred))
  
}

# Using the 3 components to create the reduced train data to forecast and return the forecasted train and test data
dept.forecast.arima <- function(train.processed){
  
  svd.result <- preprocess.svd(train.processed)
  S <- diag(svd.result$d,nrow = nrow(train.processed),ncol = ncol(train.processed)-1)
  us <- svd.result$u%*%S
  usvt <- us%*%t(svd.result$v)
  
  #write.csv(us,"us.value.csv")
  
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

#write.csv(train.data,"Analytical_Base_Table.csv")

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
Actual_Predicted_trans_v1$Type <- "Arima" 

write.csv(Actual_Predicted_trans_v1,"Actual_Predicted_trans_Arima.csv")







