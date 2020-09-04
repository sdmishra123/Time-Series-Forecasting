# Weekly Sales Forecasting for Rossmann Drug Company


# Overview:

Rossmann operates over 3,000 drug stores in 7 European countries. Currently, Rossmann store managers are tasked with predicting their weekly sales for up to four weeks in advance. Store sales are influenced by many factors, including promotions, competition, school and state holidays, seasonality, and locality. With thousands of individual managers predicting sales based on their unique circumstances, the accuracy of results can be quite varied.

# Problem statement:

How to provide an efficiently and accurately sales forecast for the next four weeks after acquisition date for each individual store?

You are provided with historical sales data for 1,115 Rossmann stores. The task is to forecast the weekly "Sales" of each stores.
Note that some stores in the dataset were temporarily closed for refurbishment.

# Files
train.csv - historical data including Sales<br/>
test.csv - historical data excluding Sales<br/>
store.csv - supplemental information about the stores<br/>

# Data fields
Most of the fields are self-explanatory. The following are descriptions for those that aren't.

1. Id - an Id that represents a (Store, Date) duple within the test set<br/>
2. Store - a unique Id for each store<br/>
3. Sales - the turnover for any given day (this is what you are predicting)<br/>
4. Customers - the number of customers on a given day<br/>
5. Open - an indicator for whether the store was open: 0 = closed, 1 = open<br/>
6. StateHoliday - indicates a state holiday. Normally all stores, with few exceptions, are closed on state holidays. Note that all schools are closed on public holidays and weekends. a = public holiday, b = Easter holiday, c = Christmas, 0 = None<br/>
7. SchoolHoliday - indicates if the (Store, Date) was affected by the closure of public schools<br/>
8. StoreType - differentiates between 4 different store models: a, b, c, d<br/>
9. Assortment - describes an assortment level: a = basic, b = extra, c = extended<br/>
10. CompetitionDistance - distance in meters to the nearest competitor store<br/>
11. CompetitionOpenSince[Month/Year] - gives the approximate year and month of the time the nearest competitor was opened<br/>
12. Promo - indicates whether a store is running a promo on that day<br/>
13. Promo2 - Promo2 is a continuing and consecutive promotion for some stores: 0 = store is not participating, 1 = store is participating<br/>
14. Promo2Since[Year/Week] - describes the year and calendar week when the store started participating in Promo2<br/>
15. PromoInterval - describes the consecutive intervals Promo2 is started, naming the months the promotion is started anew. E.g. "Feb,May,Aug,Nov" means each round starts in February, May, August, November of any given year for that store<br/>


# Data Properties: <br/>
Data was procured from Kaggle Website. <br/>
Daily Sales Data for 1115 Rossmann Stores:-  ~10.2MM records. <br/>

# Data Transformations & Exclusions: <br/>
180 stores were excluded from the analysis, as mentioned above some of the stores were closed for a breif period of time as they were undergoing rennovation so they were excluded from the analysis.<br/>
Daily sales data was aggregated to weekly sales data, as the stakeholders were keen to know their weekly sales forecast.<br/>
Final Forecasting Model was built for the 935 unique stores.<br/>
Final Dataset total row count - ~851K<br/>
Training Window: Jan 2013 - June 2015<br/>
Test Window: Forecast 4 weeks of Sales from  5th of July 2015 - 26th of July 2015<br/>

# Proposed Models: <br/>
We will evaluate dimensionality-reduction-based modelling and Hierarchical clustering approaches to forecast the next 4 weeks of each store: <br/>
I) Layer 1: Dimensionality Reduction Technique: Singular Value Decomposition (SVD)<br/>
Layer 2:<br/>
1.Auto Arima<br/>
2.TSLM<br/>
3.Prophet<br/>
4.Arima (Grid Search)<br/>

To reduce the 935 stores to a lower-dimensionality representation, we performed Singular Value Decomposition to then identify principal components to represent our data.<br/>
SVD decomposes a matrix A (dim nxd) into:<br/>
  matrix U with columns of left singular vectors (nxn)<br/>
  matrix V with columns of right singular vectors (dxd), and <br/>
  diagonal matrix S of the singular values of A (nxd) such that A = UᐧSᐧVT <br/>

  ![alt text](https://github.com/sdmishra123/Time-Series-Forecasting/blob/master/image.png)

II) Layer 1: Dimensionality Reduction Technique: Independent Component Analysis (ICA)<br/>
Layer 2:<br/>
1.Auto Arima<br/>

III) Layer 1: Non-Negative Matrix Factorization (NMF)<br/>
Layer 2:<br/>
1.Auto Arima<br/>

IV)Layer 1: Hierarchical (HTS)<br/>
Layer2:<br/>
Auto Arima<br/>
  1)Middle Out<br/>
  2)Top Down<br/>
  3)Optimal Combination<br/>
  4)Bottom-Up<br/>
  
  




