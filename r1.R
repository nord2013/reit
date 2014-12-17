# ����̓��[�J����xls�t�@�C������ǂݍ��݂܂��B
# gdata�p�b�P�[�W��URL���璼�ڃ��[�h�����悤�Ƃ��܂������A���ݒ�Ɏ��Ԃ������荡��̓p�X���܂����B
# �f�[�^�̒񋟌��͉��L��URL�ƂȂ�܂��B
#   https://www.reit.com/sites/default/files/returns/MonthlyHistoricalReturns.xls
# �t�@�C���� c:/src/reit�ɒu���܂��B
library(xlsx);
setwd("C:/src/reit")
reit_historical <- read.xlsx("MonthlyHistoricalReturns.xls", sheetName="Index Data")


# reit�̒l�i���擾���܂��B
#   all reit = morgage reit + equiety reit
#     morgage reit : ��ʐl���Z��[�����؂��Ƃ��ɗ��p���鎑���ɓ��������B
#     equity reit  : ��Ђ��s���Y��r�����擾���āA���̓������瓾���闘�v��ړI�Ƃ���B
require(xts)
reit_historical.dates = as.Date(as.numeric(as.character(reit_historical[9:NROW(reit_historical),1])), origin = "1899-12-30")
date_w <-  paste(substr(reit_historical.dates,1,8),"01", sep="")
reit_historical.dates <- as.Date(date_w)

reit_index <- reit_historical[, c(3,24)]
colnames(reit_index) <- c("AllREITs","EquityREITs")
reit_index <- reit_index[9:NROW(reit_index),]
reit_index <- xts(reit_index, order.by = reit_historical.dates )


# S&P�C���f�b�N�X���擾���܂��B
#   Reit�������ΏۂƂ��Ė��͓I�ł��邩�͕ʂ̓����ΏۂƂ̒l�i�̔�r�ł킩��܂��B
#   ����� �A�����J�̑�\�I�Ȋ����w���ł���S&P�Ɣ�r���܂��B
#

# R�ł͊�{�I�Ȋ����w�W��quantmod�p�b�P�[�W��getsymbols()�ŊȒP�Ɏ擾�ł��܂��B
# quantmod�𗘗p����ƒ�ʓI�ȋ��Z���͂��ȒP�ɍs�����Ƃ��ł��܂��B������quantmod���̂͐V�������f����񋟂��Ă��܂���B
# ���܂��܂ȃf�[�^���擾���邽�߂̃C���^�t�F�[�X��A�`���[�g�c�[���Ƃ̘A�g�ɏd�_��u���Ă��܂��B
#     http://www.r-bloggers.com/shortcuts-for-quantmod/
#
require(quantmod)

getSymbols("SP500",src="FRED")
SP500 <- to.monthly(SP500)[,4]
#get 1st of month to align when we merge
index(SP500) <- as.Date(index(SP500)) 

getSymbols("NIKKEI225",src="FRED")
NIKKEI225 <- to.monthly(NIKKEI225)[,4]
#get 1st of month to align when we merge
index(N225) <- as.Date(index(N225)) 



# REIT��SP500�̃f�[�^���}�[�W���܂��B
#   Performance Analysis�ł�S&P�Ɣ�r�����������߂Ƀf�[�^���}�[�W���܂��B
#   ���̎����Ƃ��Ƃ�Price�̑傫�����Ⴄ�̂ŁA���ΓI�ȕω����ɒ����Ă܂��B
#
#merge REIT and S&p
reit_sp500 <- na.omit(merge(reit_index,SP500))
reit_sp500 <- ROC(reit_sp500,n=1,type="discrete")
#�ŏ��̍s�� NA�ɂȂ��Ă��܂����߂�0�ɂ��Ă����܂��B
reitSp500[1,] <- 0 





# Chart
#
#
require(PerformanceAnalytics)
layout(matrix(c(1,2),nrow=1))
charts.PerformanceSummary(reit_sp500["2000::",],
                         colorset =c("steelblue4","steelblue2","gray50"),
                         main="REITS and the S&P 500 Since 2000") 

close.screen(all=T)