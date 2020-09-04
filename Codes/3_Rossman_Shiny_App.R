library(shiny)
library(dplyr)
library(stringr)
library(dplyr)
library(lubridate)
library(ggplot2)
library(ggthemes) 

setwd("C:/Sapna/Graham/Time Series/Project/Data files")
train_trans_data <- read.csv("Weekly_Sales_data_v2.csv")

data_arima<- read.csv("Actual_Predicted_trans_AutoArima.csv")
data_autoarima<- read.csv("Actual_Predicted_trans_Arima.csv")
data_tslm<- read.csv("Actual_Predicted_trans_TSLM.csv")
data_prophet<- read.csv("Actual_Predicted_trans_prophet.csv")
data_nmf<- read.csv("Actual_Predicted_trans_NMF.csv") # Negative Matrix Factorization
data_hts_mo<- read.csv("Actual_Predicted_trans_HTS_mo_arima.csv")
data_hts_fdtp<- read.csv("Actual_Predicted_trans_HTS_fdtp.csv")
data_hts_com_arima<- read.csv("Actual_Predicted_trans_HTS_combo_arima.csv")
data_ica<- read.csv("Actual_Predicted_trans_ICA.csv")

table((train_trans_data$Type))

head(data_nmf)
head(data_hts_mo)
head(data_hts_fdtp)
head(data_hts_mo)
head(data_hts_com_arima)

class(train_trans_data$Date)

train_trans_data_v1 <- train_trans_data%>%
  mutate(Date=mdy(Date))
head(train_trans_data_v1$Date)
class(train_trans_data_v1$Date)

train_trans_data_v2 = train_trans_data_v1 %>%
  filter(Date >= as.Date("2015-01-01"))

#head(train_trans_data_v2$Type)

data<-rbind(data_arima,data_autoarima,data_tslm,data_prophet,data_nmf,data_hts_mo,data_hts_fdtp,data_hts_com_arima,data_ica)

data$Week1_error <- ((data$WeekAct.2015.07.05 - data$WeekPred.2015.07.05)/data$WeekAct.2015.07.05)*100
data$Week2_error <- ((data$WeekAct.2015.07.12 - data$WeekPred.2015.07.12)/data$WeekAct.2015.07.12)*100
data$Week3_error <- ((data$WeekAct.2015.07.19 - data$WeekPred.2015.07.19)/data$WeekAct.2015.07.19)*100
data$Week4_error <- ((data$WeekAct.2015.07.26 - data$WeekPred.2015.07.26)/data$WeekAct.2015.07.26)*100

colnames(data) <- c("ObsNo","Act Week-131","Act Week-132","Act Week-133","Act Week-134","Pred Week-131","Pred Week-132","Pred Week-133","Pred Week-134",
                    "Store ID","Model Type","Error-1","Error-2","Error-3","Error-4")

data_v1<-data %>%
  select("Store ID","Model Type","Act Week-131","Act Week-132","Act Week-133","Act Week-134","Pred Week-131","Pred Week-132","Pred Week-133","Pred Week-134",
         "Error-1","Error-2","Error-3","Error-4")
head(data_v1)
tail(data_v1)

data_v1$`Act Week-131`<-prettyNum(round(data_v1$`Act Week-131`,0),big.mark = ",")
data_v1$`Act Week-132`<-prettyNum(round(data_v1$`Act Week-132`,0),big.mark = ",")
data_v1$`Act Week-133`<-prettyNum(round(data_v1$`Act Week-133`,0),big.mark = ",")
data_v1$`Act Week-134`<-prettyNum(round(data_v1$`Act Week-134`,0),big.mark = ",")
data_v1$`Pred Week-131`<-prettyNum(round(data_v1$`Pred Week-131`,0),big.mark = ",")
data_v1$`Pred Week-132`<-prettyNum(round(data_v1$`Pred Week-132`,0),big.mark = ",")
data_v1$`Pred Week-133`<-prettyNum(round(data_v1$`Pred Week-133`,0),big.mark = ",")
data_v1$`Pred Week-134`<-prettyNum(round(data_v1$`Pred Week-134`,0),big.mark = ",")


data_v1$Total_Error <- ((abs(data_v1$`Error-1`)+abs(data_v1$`Error-2`)+abs(data_v1$`Error-3`)+abs(data_v1$`Error-4`))/4)
tail(data_v1)

names(train_trans_data_v2) <- str_replace(names(train_trans_data_v2),"X","")
names(data_v1) <- c("Store ID","Model Type","Act: Week-131","Act: Week-132" ,"Act: Week-133" ,"Act: Week-134" ,"Pred: Week-131",
                    "Pred: Week-132",
                    "Pred: Week-133" ,"Pred: Week-134", "% Error: Week-131" ,"% Error: Week-132" ,"% Error: Week-133"  ,"% Error: Week-134" 
                    , "Total Error")
head(data_v1)

#Winner Model Analysis
# data_ordered <- data_v1[order(data_v1$`Store ID`,data_v1$`Model Type`,data_v1$Total_Error),]
# head(data_ordered,9)
# 
# myvars <- c("Store ID","Model Type","Total_Error")
# data_ordered_v2 <- data_ordered[myvars]
# head(data_ordered_v2)
# colnames(data_ordered_v2) <- c("Store_ID","Model_Type","Total_Error")
# 
# library(sqldf)
# miny <- sqldf("select Store_ID, min(Total_Error) as error from data_ordered_v2 group by Store_ID")
# head(miny)
# 
# final_data <-sqldf("select a.*,b.Model_Type from miny a join data_ordered_v2  b on a.Store_ID=b.Store_ID and Total_Error=error")
# head(final_data)
# 
# write.csv(final_data, "Model_Table_Min_Error_v1.csv")
# 
# inf_dat <- final_data[which(final_data$error=='Inf')]

####################################################################################################################################
############################################## APP DESIGN ##########################################################################
####################################################################################################################################
bw<-train_trans_data_v2
ui <- fluidPage(
  
  titlePanel("Rossmann Drug Company - Store-wise Sales Forecasting"),
  sidebarPanel(
    
    selectInput(inputId ='Store ID',
                label   ='Select a Store to print the table:',
                data_v1$`Store ID`,
                selected = data_v1$`Store ID`),
    
    selectInput(inputId  = 'Feature',
                label    = 'Select a Store to plot the forecast:',
                c(colnames(bw)),
                selected=colnames(bw)[2])
    ,
  width='50px'
  #,
  #img(src="C:/Sapna/Graham/Time Series/Project/Data files/Rossmann.jpg",height=50,width=50)
  ),
  
  mainPanel(
    tableOutput('table'),
    plotOutput('graph')
    
  )
)
server <- function(input, output){
  output$table <- renderTable({
    data_v2 <- data_v1 %>%
      filter(`Store ID` == input$`Store ID`) %>% 
      arrange((`Total Error`))
    
  },
  
  options = list(autoWidth = TRUE,
                 columnDefs = list(list(width = '500px', targets = "_all")))
  )
  
  output$value <- renderPrint(columname())
  columname  <- reactive({input$Feature})
  
  output$graph <- renderPlot({
    ggplot(bw, aes(bw$Date,group=Type, colour = Type))+ 
      geom_line(aes_string(y=bw[, input$Feature]),size=2)+
      labs(x = 'Year: 2015', y = 'Weekly Total Sales (Pounds)')+
      ggtitle("Rossmann Weekly Sales Forecast") +
      theme_bw() +
      scale_colour_manual(name = "Type", 
                          values = c("black", "green3", "red", "blue","cyan","gold","maroon","yellowgreen","coral","hotpink1"))
  })
}
shinyApp(ui =ui, server =server)

