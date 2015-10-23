+#load requested library
library(plyr)

# move myself in the proper working directory
setwd("/home/bompiani/Dropbox/Reproducible Research/RepData_PeerAssessment1")

# Load file
unzip("activity.zip")
# define separator, na string in the csv file
activity <- read.csv2("activity.csv", sep = ",", na.strings = "NA")
activity <- transform(activity, formatted_data = strptime(date, "%Y-%m-%d"))

# What is mean total number of steps taken per day?
total_steps <- ddply(activity, .(date), summarise, totSteps = sum(steps, na.rm = TRUE))
## problema 1: in alcuni casi il valore è 0 perché i valori non sono contati
## problema 2: bisogna far scrivere nel report una tabellina con i valori calcolati
results <- ddply(total_steps, ., summarise, mean_steps = mean(totSteps), median_steps = median(total_steps))
summary(total_steps$totSteps)
activity[is.na(activity$steps),]
total_steps[total_steps$totSteps > 0,]
activity<- transform(activity, contatore=1)
missing_values <- subset(activity, is.na(steps))
ddply(missing_values, .(date), summarize, tot_missing = sum(contatore))

not_missing_values <- subset(activity, !is.na(steps))
# 