# Run these three functions to get a clean test of  code
dev.off() # Clear the graph window
cat('\014')  # Clear the console
rm(list=ls()) # Clear all user objects from the environment!!!

# Set working directory 
# Change to the folder containing your  data files
setwd("/Users/liije/Documents/Spring 2019/IST 687 Data Science")
library(kernlab)

csvToRead <- "spring19survey.csv"
surveyData <- read.csv(csvToRead, stringsAsFactors = FALSE)

# Airline Status, Types of Travel, Class of Flight Code
tapply(surveyData$Satisfaction_Num, surveyData$Airline.Status, mean, na.rm=TRUE)

tapply(surveyData$Satisfaction_Num, surveyData$Type.of.Travel, mean, na.rm=TRUE)

tapply(surveyData$Satisfaction_Num, surveyData$Class, mean, na.rm=TRUE)

# Pearson Correlation Coefficient Code
set.seed(8081)
str(surveyData)

Candidate.Variable <- c("Flights Per Year", "Loyalty", "Total Freq Flyer Accts", "Scheduled Dep Hour", "Departure Delay", "Arrival Delay", "Flight Time", "Price Sensitivity", "Shopping Amount", "Eating Amount")

Pearson.Correlation.Coefficient <- c(
  cor.test(surveyData$Flights.Per.Year, surveyData$Satisfaction)$estimate,
  cor.test(surveyData$Loyalty, surveyData$Satisfaction)$estimate,
  cor.test(surveyData$Total.Freq.Flyer.Accts, surveyData$Satisfaction)$estimate,
  cor.test(surveyData$Scheduled.Departure.Hour, surveyData$Satisfaction)$estimate,
  cor.test(surveyData$Departure.Delay.in.Minutes, surveyData$Satisfaction)$estimate,
  cor.test(surveyData$Arrival.Delay.in.Minutes, surveyData$Satisfaction)$estimate,
  cor.test(surveyData$Flight.time.in.minutes, surveyData$Satisfaction)$estimate,
  cor.test(surveyData$Price.Sensitivity, surveyData$Satisfaction)$estimate,
  cor.test(surveyData$Shopping.Amount.at.Airport, surveyData$Satisfaction)$estimate,
  cor.test(surveyData$Eating.and.Drinking.at.Airport, surveyData$Satisfaction)$estimate)

pearsonCorrelation <- data.frame(Candidate.Variable, Pearson.Correlation.Coefficient)

View(pearsonCorrelation)

# SVM Modeling Code (In R)
surveyData <- read.csv(csvToRead, stringsAsFactors = FALSE)

surveyData <- surveyData[!is.na(surveyData$Satisfaction), ]
surveyData <- surveyData[!is.na(surveyData$Departure.Delay.in.Minutes), ]
surveyData <- surveyData[!is.na(surveyData$Arrival.Delay.in.Minutes), ]
surveyData <- surveyData[!is.na(surveyData$Loyalty), ]
surveyData <- surveyData[!is.na(surveyData$Total.Freq.Flyer.Accts), ]

# Cut the survey Data into a twentieth of it's size.
cutPoint1_10 <- floor(dim(surveyData)[1]/10)
surveyData <- surveyData[1:cutPoint1_10,]

#Put customer satisfaction into buckets
vBuckets <- replicate(length(surveyData$Satisfaction), "happy")
vBuckets[surveyData$Satisfaction < 3] <- "notHappy"
surveyData$Satisfaction.Bucket <- as.factor(vBuckets)

# Split survey data into test and training data (two thirds is training, one third is test)
randIndex <- sample(1:dim(surveyData)[1])
cutPoint2_3 <- floor(2 * dim(surveyData)[1]/3)

trainData <- surveyData[randIndex[1:cutPoint2_3],]
testData <- surveyData[randIndex[(cutPoint2_3+1):dim(surveyData)[1]],]

# Arrival SVM Model
Arrival.Delay.in.Minutes.SvmOutput <- ksvm(Satisfaction.Bucket ~ Arrival.Delay.in.Minutes, data=trainData, kernel="rbfdot", kpar="automatic",C=5,cross=3, prob.model=TRUE)

# Look at model
Arrival.Delay.in.Minutes.SvmPred <- predict(Arrival.Delay.in.Minutes.SvmOutput, testData, type = "votes")
Arrival.Delay.in.Minutes.CompTable <-  data.frame(testData[,30],Arrival.Delay.in.Minutes.SvmPred[1,])
table(Arrival.Delay.in.Minutes.CompTable)
# (17+650)/(17+2506+6+650)
# (15+832)/(3379+15+832+12)
# (4+1340)/(4+5001+3+1350)

# Train Loyalty SVM Model
Loyalty.SvmOutput <- ksvm(Satisfaction.Bucket ~ Loyalty, data=trainData, kernel="rbfdot", kpar="automatic",C=5,cross=3, prob.model=TRUE)

# Look at model
Loyalty.SvmPred <- predict(Loyalty.SvmOutput, testData, type = "votes")
Loyalty.CompTable <-  data.frame(testData[,30],Loyalty.SvmPred[1,])
table(Loyalty.CompTable)
# (5005+1353)

# Train Loyalty &  Arrival SVM Model
Loyalty.Arrival.SvmOutput <- ksvm(Satisfaction.Bucket ~ Loyalty + Arrival.Delay.in.Minutes, data=trainData, kernel="rbfdot", kpar="automatic",C=5,cross=3, prob.model=TRUE)

# Look at model
Loyalty.Arrival.SvmPred <- predict(Loyalty.Arrival.SvmOutput, testData, type = "votes")
Loyalty.Arrival.CompTable <-  data.frame(testData[,30],Loyalty.Arrival.SvmPred[1,])
table(Loyalty.Arrival.CompTable)
# (55+1308)/(55+1308+45+4950)

# Train Departure.Delay & Total.Freq. SVM Model
Dept.Freq.SvmOutput <- ksvm(Satisfaction.Bucket ~ Departure.Delay.in.Minutes + Total.Freq.Flyer.Accts, data=trainData, kernel="rbfdot", kpar="automatic",C=5,cross=3, prob.model=TRUE)

# Look at model
Dept.Freq.SvmPred <- predict(Dept.Freq.SvmOutput, testData, type = "votes")
Dept.Freq.CompTable <-  data.frame(testData[,30], Dept.Freq.SvmPred[1,])
table(Dept.Freq.CompTable)
# (30+629)/(36+2488+26+629)
# (27+672)/(27+672+2462+18)
# ( 6 +1347)/(6+4999+6+1347)
# Train 4 variable SVM Model
fourVarSvmOutput <- ksvm(Satisfaction.Bucket ~ Loyalty + Arrival.Delay.in.Minutes + Departure.Delay.in.Minutes + Total.Freq.Flyer.Accts, data=trainData, kernel="rbfdot", kpar="automatic",C=5,cross=3, prob.model=TRUE)

# Look at model
fourVarSvmPred <- predict(fourVarSvmOutput, testData, type = "votes")
fourVarCompTable <-  data.frame(testData[,30],fourVarSvmPred[1,])
table(fourVarCompTable)

# Calculate error
(60+622)/(60+33+2464+622)
(49+654)/(49+2440+652+36)
(103+760)/(84+760+3291+103)

# Train 2 pred 2 UnPredict variable SVM Model
twoPredTwoUnpredictSvmOutput <- ksvm(Satisfaction.Bucket ~ Loyalty + Flights.Per.Year + Price.Sensitivity + Total.Freq.Flyer.Accts, data=trainData, kernel="rbfdot", kpar="automatic",C=5,cross=3, prob.model=TRUE)

# Look at model
twoPredTwoUnpredictSvmPred <- predict(twoPredTwoUnpredictSvmOutput, testData, type = "votes")
twoPredTwoUnpredictCompTable <-  data.frame(testData[,30],twoPredTwoUnpredictSvmPred[1,])
table(twoPredTwoUnpredictCompTable)
# Calculate error
(9+1317)/(9+1317+5025+7)


# Train 4 pred 2 UnPredict SVM Model
fourPredTwoUnpredictSvmOutput <- ksvm(Satisfaction.Bucket ~ Loyalty + Flights.Per.Year + Price.Sensitivity + Total.Freq.Flyer.Accts  + Arrival.Delay.in.Minutes + Departure.Delay.in.Minutes, data=trainData, kernel="rbfdot", kpar="automatic",C=5,cross=3, prob.model=TRUE)

# Look at model
fourPredTwoUnpredictSvmPred <- predict(fourPredTwoUnpredictSvmOutput, testData, type = "votes")
fourPredTwoUnpredictCompTable <-  data.frame(testData[,30],fourPredTwoUnpredictSvmPred[1,])
table(fourPredTwoUnpredictCompTable)
# Calculate error
(141+1187)/(141+4893+137+1187)

# Train 1 pred 1 UnPredict SVM Model
onePredOneUnPredictSvmOutput <- ksvm(Satisfaction.Bucket ~ Flights.Per.Year + Loyalty, data=trainData, kernel="rbfdot", kpar="automatic",C=5,cross=3, prob.model=TRUE)

# Look at model
onePredOneUnPredictSvmPred <- predict(onePredOneUnPredictSvmOutput, testData, type = "votes")
onePredOneUnPredictCompTable <-  data.frame(testData[,30],onePredOneUnPredictSvmPred[1,])
table(onePredOneUnPredictCompTable)
# Calculate error
(5+1323)/(5+1323+1+5029)
# Linear Model 2 Code

modelnew<-lm(projectdata$Satisfaction~projectdata$Price.Sensitivity+projectdata$Loyalty+projectdata$Departure.Delay.in.Minutes+projectdata$Arrival.Delay.in.Minutes+gold+platinum+silver,data = projectdata)
summary(modelnew)

# Satisfaction Data Discovery Code
# Set working directory 
# Change to the folder containing your  data files
surveyData <- read.csv(csvToRead, stringsAsFactors = FALSE)
satisfaction.vec <- surveyData[!is.na(surveyData$Satisfaction), ]
satisfaction.vec <- satisfaction.vec$Satisfaction
summary(satisfaction.vec)
quantile(satisfaction.vec, c(0.05, 0.95))


# Association Rule Code
dev.off() # Clear the graph window

cat('\014')  # Clear the console

rm(list=ls()) # Clear all user objects from the environment!!!

fdf <- read.csv('/Users/dahailiu/Desktop/spring19survey.csv')

### Define response variable
#### Association Rule Starts Here
## Prepare dataset
library(arules)
library(arulesViz)
fdf$low_sati <- ifelse(fdf$Satisfaction >2, '0' , '1')

fdf_clean_df <- subset(fdf, select = -c(Flight.date, Partner.Name,Orgin.City,Destination.City,Scheduled.Departure.Hour,Departure.Delay.in.Minutes,
                                        Arrival.Delay.in.Minutes,Flight.time.in.minutes, Satisfaction) )

fdft_trans <- as(data.frame(lapply(fdf_clean_df, as.factor), stringsAsFactors=T), "transactions")

size(head(fdft_trans, 3))

inspect(head(fdft_trans, 3))

## Explore data in Rules:
itemFrequencyPlot(fdft_trans, support = 0.2, topN = 20, type="absolute")

ruleset <- apriori(fdft_trans, parameter = list(support = 0.08, confidence = 0.3), appearance = list (default="lhs",rhs="low_sati=1"))

summary(ruleset)
inspect(head(ruleset,15))

rules_lift <- sort (ruleset, by="lift", decreasing=TRUE) # 'high-lift' rules.
inspect(head(rules_lift,20)) # show the support, lift and confidence for all rules

rules_confi <- sort (ruleset, by="confidence", decreasing=TRUE) # 'high-lift' rules.
inspect(head(rules_confi,20))


prop.table(table(fdf_clean_df$Type.of.Travel, fdf_clean_df$low_sati))

library(arulesViz)
plot(ruleset)
goodrules <- ruleset[quality(ruleset)$lif>3]
inspect(goodrules)

# SVM Code without Bucketing
surveyData <- read.csv(csvToRead, stringsAsFactors = FALSE)

surveyData <- surveyData[!is.na(surveyData$Satisfaction), ]
surveyData <- surveyData[!is.na(surveyData$Flights.Per.Year), ]
surveyData <- surveyData[!is.na(surveyData$Loyalty), ]
surveyData <- surveyData[!is.na(surveyData$Price.Sensitivity), ]
surveyData <- surveyData[!is.na(surveyData$Arrival.Delay.in.Minutes), ]

# Cut the survey Data down
cutPoint1_10 <- floor(dim(surveyData)[1]/15)
surveyData <- surveyData[1:cutPoint1_10,]

# Split survey data into test and training data (two thirds is training, one third is test)
randIndex <- sample(1:dim(surveyData)[1])
cutPoint2_3 <- floor(2 * dim(surveyData)[1]/3)

trainData <- surveyData[randIndex[1:cutPoint2_3],]
testData <- surveyData[randIndex[(cutPoint2_3+1):dim(surveyData)[1]],]

# Train four predictor model
FourModelSvmOutput <- ksvm(Satisfaction ~ Flights.Per.Year + Loyalty + Price.Sensitivity + Total.Freq.Flyer.Accts, data=trainData, kernel="rbfdot", kpar="automatic",C=1,cross=3, prob.model=TRUE)

FourModelSvmPred <- predict(FourModelSvmOutput, testData, type = "response")

sqrt(mean((testData$Satisfaction-FourModelSvmPred)^2))

#Satisfaction minus testData
# Train five predictor model
FiveModelSvmOutput <- ksvm(Satisfaction ~ Flights.Per.Year + Loyalty + Price.Sensitivity + Total.Freq.Flyer.Accts + Arrival.Delay.in.Minutes, data=trainData, kernel="rbfdot", kpar="automatic",C=1,cross=3, prob.model=TRUE)

FiveModelSvmPred <- predict(FiveModelSvmOutput, testData, type = "response")

sqrt(mean((testData$Satisfaction-FiveModelSvmPred)^2))

# Train six predictor model
SixModelSvmOutput <- ksvm(Satisfaction ~ Flights.Per.Year + Loyalty + Price.Sensitivity + Total.Freq.Flyer.Accts + Arrival.Delay.in.Minutes + Departure.Delay.in.Minutes, data=trainData, kernel="rbfdot", kpar="automatic",C=1,cross=3, prob.model=TRUE)

SixModelSvmPred <- predict(SixModelSvmOutput, testData, type = "response")

sqrt(mean((testData$Satisfaction-FiveModelSvmPred)^2))
