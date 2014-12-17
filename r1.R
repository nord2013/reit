# 今回はローカルのxlsファイルから読み込みます。
# gdataパッケージでURLから直接ロードをしようとしましたが、環境設定に時間がかかり今回はパスしました。
# データの提供元は下記のURLとなります。
#   https://www.reit.com/sites/default/files/returns/MonthlyHistoricalReturns.xls
# ファイルは c:/src/reitに置きます。
library(xlsx);
setwd("C:/Maka/src/reit")
reit_historical <- read.xlsx("MonthlyHistoricalReturns.xls", sheetName="Index Data")


# reitの値段を取得します。
#   all reit = morgage reit + equiety reit
#     morgage reit : 一般人が住宅ローンを借りるときに利用する資金に投資される。
#     equity reit  : 会社が不動産やビルを取得して、その投資から得られる利益を目的とする。
require(xts)
reit_historical.dates = as.Date(as.numeric(as.character(reit_historical[9:NROW(reit_historical),1])), origin = "1899-12-30")
date_w <-  paste(substr(reit_historical.dates,1,8),"01", sep="")
reit_historical.dates <- as.Date(date_w)

reit_index <- reit_historical[, c(3,24)]
colnames(reit_index) <- c("AllREITs","EquityREITs")
reit_index <- reit_index[9:NROW(reit_index),]
reit_index <- xts(reit_index, order.by = reit_historical.dates )


# S&Pインデックスを取得します。
#   Reitが投資対象として魅力的であるかは別の投資対象との値段の比較でわかります。
#   今回は アメリカの代表的な株価指数であるS&Pと比較します。
#

# Rでは基本的な株式指標をquantmodパッケージのgetsymbols()で簡単に取得できます。
# quantmodを利用すると定量的な金融分析を簡単に行うことができます。ただしquantmod自体は新しいモデルを提供していません。
# さまざまなデータを取得するためのインタフェースや、チャートツールとの連携に重点を置いています。
#     http://www.r-bloggers.com/shortcuts-for-quantmod/
#
require(quantmod)

getSymbols("SP500",src="FRED")
SP500 <- to.monthly(SP500)[,4]
#get 1st of month to align when we merge
index(SP500) <- as.Date(index(SP500)) 


# REITとSP500のデータをマージします。
#   Performance AnalysisではS&Pと比較をしたいためにデータをマージします。
#   この時もともとのPriceの大きさが違うので、相対的な変化率に直してます。
#
#merge REIT and S&p
reit_sp500 <- na.omit(merge(reit_index,SP500))
reit_sp500 <- ROC(reit_sp500,n=1,type="discrete")
#最初の行は NAになってしまうために0にしておきます。
reit_sp500[1,] <- 0 





# Chart
#
#
require(PerformanceAnalytics)
charts.PerformanceSummary(reit_sp500["2000::",],
                         colorset =c("steelblue4","steelblue2","gray50"),
                         main="REITS and the S&P 500 Since 2000") 

