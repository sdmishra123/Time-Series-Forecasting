suppressWarnings(library(forecast))
suppressWarnings(library(tseries))
suppressWarnings(library(dplyr))
suppressWarnings(library(readr))
suppressWarnings(library(lubridate))
suppressWarnings(library(sqldf))
suppressWarnings(library(tidyr))
suppressWarnings(library(astsa, quietly=TRUE, warn.conflicts=FALSE))
suppressWarnings(library(ggplot2))
suppressWarnings(library(knitr))
suppressWarnings(library(printr))
# suppressWarnings(library(plyr))
suppressWarnings(library(dplyr))
suppressWarnings(library(lubridate))
suppressWarnings(library(gridExtra))
suppressWarnings(library(reshape2))
suppressWarnings(library(TTR))
suppressWarnings(library(seastests))
suppressWarnings(library(readxl))
suppressWarnings(library(sqldf))
suppressWarnings(library(forecast))
suppressWarnings(library(ggplot2))
# suppressWarnings(library(plyr))
suppressWarnings(library(reshape))
suppressWarnings(library(tseries))
suppressWarnings(library(TSPred))
detach(package:plyr)
library(imputeTS)

set.seed(104281)

setwd("C:/Sapna/Graham/Time Series/Project/Data files")
train <- read_excel("C:/Sapna/Graham/Time Series/Project/Data files/train.xlsx",sheet='train')
test <- read_csv("C:/Sapna/Graham/Time Series/Project/Data files/test.csv")
store_not_under_rennov <- read_csv("C:/Sapna/Graham/Time Series/Project/Data files/store_not_under_rennov.csv")

store_master <- read_csv("C:/Sapna/Graham/Time Series/Project/Data files/store.csv")

train$new_date <- as.Date(train$Date, format="%d/%m/%Y")

table(train$Year)
head(train)

train_new = train %>%
  #filter(new_date >= as.Date("2013-01-06") & new_date <= as.Date("2015-06-30"))
  filter(new_date >= as.Date("2013-01-06"))

# test_new = train %>%
#   filter(new_date >= as.Date("2015-07-01"))

head(train_new)
tail(train_new)
#head(test_new)
#tail(test_new)

#data_freq<-data.frame(table(train_new$Year,train_new$Store)) #if you see this is a non-uniform time series data. #There are 180 stores which underwent rennovation for the year

#data_freq_v1<- data_freq %>%
  #mutate(flag=if_else(Freq<365,'Y','N'))
 
# store_not_under_rennov<-data_freq_v1[which(data_freq_v1$flag=="Y"),]
# store_not_under_rennov<-store_not_under_rennov[which(store_not_under_rennov$Var2!=988),]
# head(store_not_under_rennov)
# names(store_not_under_rennov)<-c('Year','Store','Freq','Flag')
# head(store_not_under_rennov)
# head(train_new)
# 
# write.csv(store_not_under_rennov,"store_not_under_rennov.csv")

train_2013_2014<-subset(train_new,!(Store %in% store_not_under_rennov$Store))
#test_2015<-subset(test_new,!(Store %in% store_not_under_rennov$Store))

#test_uni_stores  <- data.frame(table(unique(test_2015$Store))) #935 Stores
train_uni_stores <- data.frame(table(unique(train_2013_2014$Store))) #935 Stores

head(train_2013_2014)

# library(plyr)
train_2013_2014_v1 <- train_2013_2014[c(1,4,8)]
head(train_2013_2014_v1)

# library(xts)
# data <- as.xts(train_2013_2014_v1$Sales,order.by=c(as.Date(train_2013_2014_v1$Date),train_2013_2014_v1$Store))
# weekly <- data.frame(apply.weekly(data,sum))
# 
# weekly$Date<-row.names(weekly)
# 
# names(weekly)<-c("Sales","Store")

train_2013_2014_v1$week <- floor_date(as.Date(train_2013_2014_v1$Date, "%m/%d/%Y"), unit="week")
head(train_2013_2014_v1)


train_2013_2014_v2<-train_2013_2014_v1 %>% 
  group_by(Store,week) %>%
  summarise(Total_Sales = sum(Sales)) %>%
  select(week,Store,Total_Sales) 

names(train_2013_2014_v2) <- c("Date","Store","Weekly_Sales")  
head(train_2013_2014_v2)

train_2013_2014_v2$Weekly_Sales <- ifelse(train_2013_2014_v2$Weekly_Sales==0,NA,train_2013_2014_v2$Weekly_Sales)

# store_25 <- train_2013_2014_v2[which(train_2013_2014_v2$Store==353),]
# #head(store_25$Store)
# Store_25_ts <- ts(store_25$Weekly_Sales,frequency = 52)
# statsNA(Store_25_ts)
# plotNA.distribution(Store_25_ts)
# store_25_imp <- na.interpolation(Store_25_ts,option = "linear")
# plotNA.imputations(Store_25_ts,store_25_imp)

write.csv(train_2013_2014_v1,"cleansed_train_data.csv")



