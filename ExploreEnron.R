### Libraries

setwd("E:/SSJ/Sujit/IntrotoML/")
#library(formattable) # output is easier to read an well formatted
library(stringr) # String manipulation, Regex
library(plyr)
library(ggplot2)
library(tm)
library(SnowballC)
library(RColorBrewer)
library(wordcloud)


### read emails.csv


enron <- read.csv("E:/SSJ/Sujit/IntrotoML/emails.csv", stringsAsFactors = FALSE)


###  locate the blank line "\n\n"


breaks <- str_locate(enron$message, "\n\n")



### Extract headers and bodies


headers <- str_sub(enron$message, end = breaks[,1] - 1)
bodies <- str_sub(enron$message, start = breaks[,2] + 1)






### Splitting the email header



parseHeader <- function(header){
  MessageID <- str_sub(str_extract(header, "^Message-ID:.*"), start = 12)
  Date <- str_sub(str_extract(header,"Date:.*"), start = 7)
  From <- str_sub(str_extract(header,"From:.*"), start = 7)
  To <- str_sub(str_extract(header,"To:.*"), start = 5)
  Subject <- str_sub(str_extract(header,"Subject:.*"), start = 10)
  #X-cc <- str_sub(str_extract(header,"X\\-cc:.*"), start = 7)
  #X-bcc <- str_sub(str_extract(header,"X\\-bcc:.*"), start = 8)
  
  headerParsed <- data.frame(MessageID, Date, From, To, Subject, 
                             stringsAsFactors = FALSE)
  return(headerParsed)
}





headerParsed <- parseHeader(headers)



### Conversion of dates


## UTC time
datesTest <- strptime(headerParsed$Date, format = "%a, %d %b %Y %H:%M:%S %z")
## localtime
datesLocal <- strptime(headerParsed$Date, format = "%a, %d %b %Y %H:%M:%S")



### Copy dates 


headerParsed$Date <- datesTest
headerParsed$DateLocal <- datesLocal
# remove dates Test
rm(datesTest)
rm(datesLocal)




### File column


## split 
fileSplit <- str_split(enron$file, "/")
fileSplit <-rbind.fill(lapply(fileSplit, function(X) data.frame(t(X))))

### Creating one dataset


enron <- data.frame(fileSplit, headerParsed, bodies, stringsAsFactors = FALSE)
colnames(enron)[1] <- "User"




### Cleaning up 



rm(headerParsed)
rm(bodies)
rm(headers)
rm(breaks)
rm(fileSplit)

# garbage collection
gc()




## Some Top 20s 

### Mail writers


head(sort(table(enron$From), decreasing = TRUE), n=20)




### Mail recipients

head(sort(table(enron$To), decreasing = TRUE), n=20)




### User


head(sort(table(enron$User), decreasing = TRUE), 20)




## Weekdays and Hour of day



# extract weekday
enron$Weekday <- weekdays(enron$DateLocal)
# extract Hour of day
enron$Hour <- enron$DateLocal$hour



## Weekdays Analysis



WeekdayCounts <- as.data.frame(table(enron$Weekday))
str(WeekdayCounts)
WeekdayCounts$Var1 <- factor(WeekdayCounts$Var1, ordered=TRUE, 
                             levels=c( "Monday", "Tuesday", "Wednesday", "Thursday", "Friday","Saturday", "Sunday"))
DayHourCounts <- as.data.frame(table(enron$Weekday, enron$Hour))
str(DayHourCounts)
DayHourCounts$Hour <- as.numeric(as.character(DayHourCounts$Var2))
DayHourCounts$Var1 <- factor(WeekdayCounts$Var1, ordered=TRUE, 
                             levels=c( "Monday", "Tuesday", "Wednesday", "Thursday", "Friday","Saturday", "Sunday"))







### Plot number of emails per Weekday


ggplot(WeekdayCounts, aes(x=Var1, y=Freq)) + geom_line(aes(group=1))  



### Plot number of emails per Hour per Day

ggplot(DayHourCounts, aes(x=Hour, y=Freq)) + 
  geom_line(aes(group=Var1, color=Var1), size=1)




### Heatmap: emails per Hour per Day



ggplot(DayHourCounts, aes(x = Hour, y = Var1)) + 
  geom_tile(aes(fill = Freq)) + 
  scale_fill_gradient(name="Total emails", low = "lightgrey", high = "darkblue") + 
  theme(axis.title.y = element_blank())




## Making a Wordcloud of email bodies


#### Create a corpus using the bodies variable


corpus <- Corpus(VectorSource(enron$bodies[1:100000]))


#### Convert corpus to lowercase 

corpus <- tm_map(corpus,tolower)
corpus <- tm_map(corpus, PlainTextDocument)



#### Remove punctuation from  corpus

corpus <- tm_map(corpus, removePunctuation)


#### Remove all English-language stopwords


corpus <- tm_map(corpus, removeWords, stopwords("english"))

#### Remove some more words

corpus <- tm_map(corpus, removeWords, c("just", "will", "thanks","please", "can", "let", "said", "say", "per"))


#### Stem document 

corpus <- tm_map(corpus, stemDocument)



# Stop Here. Error correction must be done. Progress will be done in Major Project.
#### Build a document-term matrix out of the corpus

bodiesDTM <- TermDocumentMatrix(corpus)

#### remove Sparse Terms


sparseDTM <- removeSparseTerms(bodiesDTM, 0.99)
sparseDTM
# some cleaning due to memory intensive operations following
rm(corpus)
rm(bodiesDTM)
gc() 


#### Convert the document-term matrix to a data frame called allBodies
allBodies <- as.data.frame(as.matrix(sparse))


#### Building wordcloud


par(bg = "gray27") # setting background color to a dark grey
pal <- brewer.pal(7,"Dark2") # Choosing a color palette

# Wordcloud 
wordcloud(colnames(allBodies), colSums(allBodies), scale = c(2.5,0.25), max.words = 150, colors = pal)


## TODO
# 1. deleting some unimportant mails, like private conversation about vacation or amazon.com mails ...
# 2. Creating a network and graph: Person1 $\overrightarrow{writes mail to}$ Person2 $\overrightarrow{receives from}$ Person3 and so on
