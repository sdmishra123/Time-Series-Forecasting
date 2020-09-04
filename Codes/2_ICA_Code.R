datapath <- "~/Desktop/TimeSeries/Project"
data <- read.csv(paste(datapath,"Analytical_Base_Table.csv",sep="/"),header=T)
data<-data[2:4]
head(data)
dim(data)
typeof(data$Store)

#setting the n value to be used in loops later

n<-unique(data$Store)
length(n)

#exploration of different stores
a <- data$Weekly_Sales
d <- subset(data,data$Store==12)
head(d)


tail(data)



library(dplyr)
library(data.table)
library(tseries)
library(forecast)
library(ica)




#933, 216, 206, 471 #top revenue stores

#constructing all the entire store transpose:

train_mainq<- data.frame(rnorm(130))
test_mainq<-data.frame(rnorm(4))
length(n)
for (i in 1:length(n)){
  d <- subset(data,data$Store==n[i])
  d <- d$Weekly_Sales
  n1 <- d[1:130]
  n2<- d[131:134]
  train_mainq<-cbind(train_mainq,n1)
  test_mainq<-cbind(test_mainq,n2)
}

head(train_mainq)
dim(train_mainq)
train_mainq$rnorm.130.<-NULL
test_mainq$rnorm.4.<-NULL
dim(train_mainq)
colnames(train_mainq)

#renaming columns

dim(train_mainq)
colnames(train_mainq)<-paste("Store", n, sep = "")
colnames(test_mainq)<-paste("Store", n, sep = "")
train_mainq[935]
train_mainq[1]


#running ica on the entire data


model1<- icafast(train_mainq,nc=3,alg='def',fun='logcosh',alpha=1)
model1


#getting the components
components<- model1$S
components
model1$vafs

#we have a total of more than 85% variation explained by the three components

#running arima on the component : exploring components

com1<- ts(components[,1],frequency = 52)
modela<- auto.arima(com1,seasonal = T)
modela
acf(components[,1])
adf.test(components[,1])

kpss.test(components[,1])#not stationary

#arima on components
modelb<- auto.arima(components[,2],seasonal = T)
modelc<- auto.arima(components[,3],seasonal = T)

#forecasting the components
forecast1 <- forecast(modela,4)
forecast2<-forecast(modelb,4)
forecast3<-forecast(modelc,4)

#making the forecast for all the 935 stores by reconstruction

#Step 1: Combine compent forecast into a matrix

forecast_mix<- as.matrix(cbind(summary(forecast1)[,1],summary(forecast2)[,1],summary(forecast3)[,1]))
forecast_mix

#Step 2: Building Reconstruction Architechture for reconstructing components to get back the store values
?icafast

#M = estimated mixing matrix (935 x 5)
#S= Source of the series (130 x 5 )
# usual series of stores = S x M (130 x 5)

#Mixing Matrix
M<- model1$M
M<-abs(M)

#trasposing the matrix
M_final<-t(M)
dim(M_final)

#checks
dim(M)
dim(forecast_mix)
dim(model1$S)
dim(components)
length(modela$fitted)
a<-t(M)
dim(a)

#matrix multiplication:
final_Forecast <- abs(forecast_mix) %*% M_final
dim(final_Forecast)
dim(final_Forecast)
dim(test_mainq)

#dataframe
#for forecasted values
df_fore<- as.data.frame(final_Forecast)
dim(df_fore)
colnames(df_fore)<-paste("Store", n, sep = "")


#taking the absolute of the values

install.packages('TSPred')
library(TSPred)
test_mainq[,1]
df_fore[935]


#getting smape for all the stores

sMape <- list()
for (i in 1:935){
  sMape<- append(sMape,sMAPE(test_mainq[,i],df_fore[,i]))
}

#main_data frame build
dim(df_fore)
which.max(sMape)
new_test<- t(test_mainq)
new_test
new_forecast<-t(df_fore)
new_forecast<- round(new_forecast,0)
SMAPE<- c(sMape)
C<- c(rep('ICA',times=935))
C
df_final<- cbind(new_test,new_forecast,C,SMAPE)
colnames(df_final)
colnames(df_final)<- c('Actual_W131','Actual_W132','Actual_W133','Actual_W134','Predicted_W131','Predicted_W132','Predicted_W133','Predicted_W134','Model','SMAPE')
df_final[216,]
dim(df_final)
library(openxlsx)
install.packages('openxlsx')
write.xlsx(df_final,file='~/Desktop/TimeSeries/Project/FinalFile.xlsx')
write.table(df_final,file='~/Desktop/TimeSeries/Project/Final
          _pred_table')


Stores <-c(paste("Store", n, sep = ""))
Stores
df_final<- cbind(Stores,df_final)
dim(df_final)

#Test smape


length(n)
dim(new_forecast)
f<-as.vector(t(new_test))
t<-as.vector(t(new_forecast))
overall_test_smape<- sMAPE(f,t)
overall_test_smape

#Train smape
train_mainq[1]
dim(train_mainq)
new_train<-t(train_mainq)


new_test

for (i in 1:length(n)){
  d <- subset(data,data$Store==n[i])
  d <- d$Weekly_Sales
  n1 <- d[1:130]
  n2<- d[131:134]
  train<-rbind(train,n1)
  test<-rbind(test,n2)
}
head(train)
head(test)
length(test)
train<-train[-1,]
test<-test[-1,]
new_fitted<-t(final_fitted)
y<-as.vector(t(new_train))
z<-as.vector(t(new_fitted))
sMAPE(y,z)


#sMape for train


modela
acf(components[,1])
adf.test(components[,1])

kpss.test(components[,1])#not stationary

#arima
modelb<- auto.arima(components[,2],seasonal = T)
modelc<- auto.arima(components[,3],seasonal = T)
components[,3]
#forecasting the components
fitted1<- c(modela$fitted)
fitted2<- c(modelb$fitted)
fitted3<- c(modelc$fitted)
length(fitted1)

train_fit<- cbind(fitted1,fitted2,fitted3)
dim(train_fit)
M<- model1$M
M<-abs(M)
#trasposing the matrix
M_final<-t(M)
dim(M_final)

dim(M)
dim(forecast_mix)
dim(model1$S)
dim(components)
length(modela$fitted)
a<-t(M)
dim(a)
#matrix multiplication:
final_fitted <- abs(train_fit) %*% M_final
dim(final_fitted)
dim(final_Forecast)
dim(test_mainq)

#dataframe
#for forecasted values
df_fore<- as.data.frame(final_Forecast)
dim(df_fore)
colnames(df_fore)<-paste("Store", n, sep = "")



