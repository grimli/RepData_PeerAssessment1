# Reproducible Research: Peer Assessment 1

The following libraries will be used in the analysis 


```r
library(plyr)
library(ggplot2)
library(chron)
```

* **plyr**: will be used to manipulate datas
* **ggplot2**: will be used for some of the plot
* **chron**: will be used to discriminate between weekdays and weekends

I will suppose that the required project has been cloned in the home 
directory of a linux machine; otherwise the proper working directory should be inserted below


```r
setwd("~/RepData_PeerAssessment1")
```

## Loading and preprocessing the data
The data are contained in a compressed file; I have to uncompress it and to load it. I will specify the NA string too.


```r
unzip("activity.zip")

activity <- read.csv2("activity.csv", sep = ",", na.strings = "NA")
```

I add a column with a properly formatted date. It will be used in some of the plots. 

```r
activity <- transform(activity, formatted_data = strptime(date, "%Y-%m-%d"))
```

## What is mean total number of steps taken per day?
The project requirements specify to ignore the missing values. This can be done in more then one way.

As can be seen with the following commands, when there are missing values the full day is missing:


```r
activity <- transform(activity, contatore=1)
missing_values <- subset(activity, is.na(steps))
ddply(missing_values, .(date), summarize, tot_missing = sum(contatore))
```

```
##         date tot_missing
## 1 2012-10-01         288
## 2 2012-10-08         288
## 3 2012-11-01         288
## 4 2012-11-04         288
## 5 2012-11-09         288
## 6 2012-11-10         288
## 7 2012-11-14         288
## 8 2012-11-30         288
```

Similarly it can be verified that every day there is the proper number of samples 


```r
num_samples <- ddply(activity, .(date), summarize, num_samples = sum(contatore))
num_samples[num_samples$num_samples != 288, ]
```

```
## [1] date        num_samples
## <0 rows> (or 0-length row.names)
```

I calculate then the mean and the median total number of steps for each day ignoring the days with missing values


```r
not_missing_values <- subset(activity, !is.na(steps))
total_steps <- ddply(not_missing_values, .(date), summarise, totSteps = sum(steps))
mean = mean(total_steps$totSteps)
median = median(total_steps$totSteps)
cbind(mean,median)
```

```
##          mean median
## [1,] 10766.19  10765
```

## What is the average daily activity pattern?
I calculate the mean value of each interval across all days

```r
mean_time_series <- ddply(not_missing_values, .(interval), summarise, steps = mean(steps))
```

The time series can be plotted

```r
with(mean_time_series, plot(x = interval, y=steps, type = "l") )
```

![](PA1_template_files/figure-html/unnamed-chunk-9-1.png) 

and the interval with the max mean number of steps is easaly calculated

```r
subset(mean_time_series,steps == max(steps))
```

```
##     interval    steps
## 104      835 206.1698
```

## Imputing missing values

I have  shown in the preliminary analysis, that there are only full days of missing values. I report below the steps to get this result


```r
activity<- transform(activity, contatore=1)
missing_values <- subset(activity, is.na(steps))
ddply(missing_values, .(date), summarize, tot_missing = sum(contatore))
```

```
##         date tot_missing
## 1 2012-10-01         288
## 2 2012-10-08         288
## 3 2012-11-01         288
## 4 2012-11-04         288
## 5 2012-11-09         288
## 6 2012-11-10         288
## 7 2012-11-14         288
## 8 2012-11-30         288
```

Moreover the total number of missing values can be calculated in a similar way


```r
ddply(missing_values, .(), summarize, tot_missing = sum(contatore))
```

```
##    .id tot_missing
## 1 <NA>        2304
```

There are only full days of missing values. I will substitute the missing values with the mean values calculated over the orther days. 

These values have been previously calculated and recorded in the data frame **mean_time_series**. I'll put the new dataset in the dataframe **new_dataset**.  


```r
imputing_values <- cbind(mean_time_series[,"steps"], missing_values[,c("date", "interval", "formatted_data","contatore")])
colnames(imputing_values) <- c("steps", "date", "interval", "formatted_data", "contatore")
new_dataset <- rbind(not_missing_values,imputing_values)
```

To plot the histogram of the total number of steps across the days I have to calculate these values on the new data set too


```r
imputing_total_steps <- ddply(new_dataset, .(date), summarise, totSteps = sum(steps))
imputing_total_steps <- transform(imputing_total_steps, formatted_date = strptime(date, "%Y-%m-%d"))
ggplot(data = imputing_total_steps, aes(x = formatted_date))+geom_bar(aes(y=totSteps),stat ="identity")+ylab("Number of steps")+xlab("date")
```

![](PA1_template_files/figure-html/unnamed-chunk-14-1.png) 

Finally I have to calculate mean and median values for the new dataset


```r
new_mean =mean(imputing_total_steps$totSteps)
new_median =median(imputing_total_steps$totSteps)
results <- rbind(cbind(new_mean,new_median),cbind(mean,median))
colnames(results) <- c("mean","median")
rownames(results) <- c("new","orig")
results
```

```
##          mean   median
## new  10766.19 10766.19
## orig 10766.19 10765.00
```

In this table the **new** row contains the values just calculated and the **orig** row the values calculated on the original dataset.

The **mean** values is unchanged, as expected, and the variation in the **median** value is negligible

## Are there differences in activity patterns between weekdays and weekends?

First of all I have to update the dataset adding the requested information. This can be done with the function **is.weekend** form the *chron* library. To get clearer labels I'll insert it in a factor function

```r
new_dataset <- transform( new_dataset, working_week = factor(is.weekend(formatted_data), levels=c(TRUE, FALSE), labels=c('weekend', 'weekday')) )
```
 
The column working_week contains now a proper label to summarize data in the requested way

```r
working_week_total <- ddply(new_dataset, .(working_week,interval), summarise, totSteps = sum(steps))
```

This data can be then plotted

```r
ggplot(data = working_week_total, aes(x=interval, y=totSteps))+geom_line()+facet_grid(working_week~.)+ylab("Number of Steps")+xlab("Interval")
```

![](PA1_template_files/figure-html/unnamed-chunk-18-1.png) 

