suppressWarnings(library(forecast))
suppressWarnings(library(tseries))
suppressWarnings(library(dplyr))
suppressWarnings(library(readr))
suppressWarnings(library(tidyr))
suppressWarnings(library(ggplot2))
suppressWarnings(library(dplyr))
suppressWarnings(library(xts))
suppressWarnings(library(hts))
suppressWarnings(library(TSPred))
options(max.print=1000000)
setwd("C:/Users/wanyi/Desktop/TS/Group Project")
df = read.csv("Analytical_Base_Table.csv")
df$Date = as.Date(df$Date, "%m/%d/%Y")
colnames(df)
  
groupA_id = c(unique(df[df$StoreType == "a",]$Store))
groupB_id = c(unique(df[df$StoreType == "b",]$Store))
groupC_id = c(unique(df[df$StoreType == "c",]$Store))
groupD_id = c(unique(df[df$StoreType == "d",]$Store))
sum(groupA_id,groupB_id,groupC_id,groupD_id) #check

HTS_order = c(groupA_id,groupB_id,groupC_id,groupD_id)
HTS_order[3]

num_store = length((unique(df$Store)))
num_week = dim(df[df$Store == 1,])[1]
store_id = list(unique(df$Store))

template  = matrix(nrow= num_week,ncol=0)
for (i in HTS_order){
      store = c(subset(df, Store == i)$Weekly_Sales)
      template = cbind(template,store)
}


write.csv(as.data.frame(template),"C:/Users/wanyi/Desktop/TS/Group Project/james.csv")
hts_matrix = read.csv("james.csv",header = TRUE)
dim(hts_matrix)

hts_matrix_train = hts_matrix[1:130,2:936]
dim(hts_matrix_train)
hts_matrix_test  = hts_matrix[131:134,2:936]
dim(hts_matrix_test)

hts_matrix_test
dim(hts_matrix_test)
dim(hts_matrix_train)

hts_matrix_test[1]


#################################### building the hierarchical structure ######################################
structure = list(4,c(518,16,134,267)) # 2 layers

result = hts(y = ts(hts_matrix_train), nodes = structure)

aggts(result, 1, forecasts = TRUE)


#Level used for "middle-out" method (only used when method = "mo").
fcst_tdfp_arima = forecast(result, method ="tdfp", fmethod = "arima", h = 4, keep.fitted = TRUE)
View(fcst_tdfp_arima)
fitted_train = fcst_tdfp_arima$fitted

write.csv(fitted_train,"C:/Users/wanyi/Desktop/TS/Group Project/HTS results/fitted_train.csv")


############################################## Other models ####################################################
fcst_mo_arima_2 = forecast(result, method ="mo", fmethod = "arima", level = 2, h = 4)
fcst_bu_arima = forecast(result, method ="bu", fmethod = "arima", h = 4)
fcst_comb_arima = forecast(result, method ="comb", fmethod = "arima", h = 4)
#fcst_tdfp_ets = forecast(result, method ="tdfp", fmethod = "ets", h = 4) #same


write.csv(as.data.frame(fcst_tdfp_arima[1]),"C:/Users/wanyi/Desktop/TS/Group Project/HTS results/hts_tdfp_arima.csv")
write.csv(as.data.frame(fcst_mo_arima_2[1]),"C:/Users/wanyi/Desktop/TS/Group Project/HTS results/hts_mo_arima.csv")
write.csv(as.data.frame(fcst_bu_arima[1]),"C:/Users/wanyi/Desktop/TS/Group Project/HTS results/hts_bu_arima.csv")
write.csv(as.data.frame(fcst_comb_arima[1]),"C:/Users/wanyi/Desktop/TS/Group Project/HTS results/hts_comb_arima.csv")
write.csv(as.data.frame(HTS_order),"C:/Users/wanyi/Desktop/TS/Group Project/HTS results/hts_store_order.csv")
write.csv(as.data.frame(hts_matrix_test),"C:/Users/wanyi/Desktop/TS/Group Project/hts_test.csv")



######################################## Calculate test sMAPE ######################################################

final_result_tdfp = read.csv("hts_result(four models) - ordered - sMAPE.csv", head = FALSE)
actual     = final_result_tdfp[5:8,]
forecasted = final_result_tdfp[1:4,]

sMAPE(forecasted[[935]], actual[[935]])
forecasted[[1]]

smape = c()
for (i in 1:935){
  smape[i] <- sMAPE(forecasted[[i]], actual[[i]])
}
mean(smape)

# Calculate train sMAPE:

final_result_tdfp_fit_train = read.csv("C:/Users/wanyi/Desktop/TS/Group Project/HTS results/train_SMAPE.csv", head = FALSE)
actual_fit_train     = final_result_tdfp_fit_train[1:130,]
dim(actual_fit_train)
forecasted_fit_train = final_result_tdfp_fit_train[131:260,]
dim(actual_fit_train)

sampe_fit_train = c()
for (i in 1:935){
  sampe_fit_train[i] <- sMAPE(forecasted_fit_train[[i]], actual_fit_train[[i]])
}
mean(sampe_fit_train,na.rm=TRUE)


#################################### To verify the order of data is consistent with HTS #################################

### example 1 
setwd("C:/Users/wanyi/Desktop/TS/Group Project")
df = read.csv("book1.csv")

ma = ts(as.matrix(df))
structure = list(2,c(2,1)) # 2 layers

result = hts(y = ma, nodes = structure)
result
fct    = forecast(result, method = "mo", fmethod = "arima", level = 1, h = 10)
fct[1]
summary(result)
smatrix(result)
plot(result)

aggts(fct)
aggts

#### example 2 

nodes = list(2,c(3,2))
abc = ts(5+matrix(sort(rnorm(500)), ncol = 5, nrow = 100))
x = hts(abc, nodes)
summary(x)

foocst = forecast(x, method = "mo", fmethod = "arima", level = 1, h = 10)
foocst[1]

######################################  Clustering method ###################################################

setwd("C:/Users/wanyi/Desktop/TS/Group Project")
train <- read.csv("train_final_934.csv")
head(train)

train$date <- as.Date(train$Date, format="%d/%m/%Y")


fin_orders<-matrix(nrow=0,ncol=15)
fin_orders.names<-c('p', 'd', 'q', 'P', 'D', 'Q', 'Frequency','AIC',
                    'ME','RMSE','MAE','MPE','MAPE','MASE','ACF1') #'adf_pvalue','kpss_pvalue','box_lunj_pvalue'
store_id = length(unique(train$Store))
store_id


time_series_analysis <- function(data){
  for (i in 1:store_id) {
    dat<-data %>%
      filter(Store==i)
    
    #acf(dat$Sales)
    #pacf(dat$Sales)
    
    #### stationary test ####
    #adf_pvalue<-(adf.test(dat$Sales))$p.value
    #kpss_pvalue<-(kpss.test(dat$Sales))$p.value
    #box_lunj_pvalue<-(Box.test(dat$Sales,type = 'Ljung-Box'))$p.value
    
    #### stationary test with 1st differencing ####
    #adf_diff_pvalue<-(adf.test(diff(dat$Sales)))$p.value #one time difference
    #kpss_diff_pvalue<-(kpss.test(diff(dat$Sales)))$p.value
    #box_lunj_diff_pvalue<-(Box.test(dat$Sales,type = 'Ljung-Box'))$p.value
    
    dat_ts<-ts(dat$Sales, frequency=7) # frequency = 7 --> Weekly 
    
    a_arima<-auto.arima(dat_ts,seasonal=T,D=1)
    #print(a_arima)
    acc<-accuracy(a_arima)
    
    #plot(forecast(auto.arima(dat_ts,seasonal=T,D=1)))
    
    arima_orders<-c(arimaorder(a_arima),
                    #adf_pvalue=adf_pvalue,
                    #kpss_pvalue=kpss_pvalue,
                    #box_pvalue=box_lunj_pvalue,
                    #adf_diff_pvalue=adf_diff_pvalue,
                    #kpss_diff_pvalue=kpss_diff_pvalue,
                    #box_diff_pvalue=box_lunj_diff_pvalue,
                    aic=a_arima$aicc,
                    ME=acc[1],RMSE=acc[2],MAE=acc[3],
                    MPE=acc[4],MAPE=acc[5],
                    MASE=acc[6],ACF1=acc[7])
    
    fin_orders<-rbind(fin_orders,arima_orders)
  }
  return(fin_orders)
}

result = time_series_analysis(train)
write.csv(result,"performance_result.csv")






