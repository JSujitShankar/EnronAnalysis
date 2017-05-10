# Load the necessary packages. Read from CRAN what each package does.
library("tm")
library("SnowballC")
library("caTools")
library("rpart")
library("rpart.plot")
library("ROCR")



# Loading the data and having a look at it.
emails <- read.csv("E:/SSJ/Sujit/Enron/energy_bids.csv.gz", stringsAsFactors = FALSE)
str(emails)

#Lets look at a few examples to see what these particular emails consist of
strwrap(emails$email[1])

# What is its 'responsive' value?
emails$responsive[1]

# Email 2
strwrap(emails$email[2])

#Its responsive
emails$responsive[2]

# No of emails responsive to our query
table(emails$responsive)

# This part is a crux. Here we create a corpus. A corpus can be defined as meaningful set
# of text. In R they can be obtained from Sources such as vectoretc.

corpus <- Corpus(VectorSource(emails$email))

corpus

# Converting the text to lower case

corpus <- tm_map(corpus, tolower)
corpus
# corpus <- tm_map(corpus, PlainTextDocument)
corpus


# Remove punctuation
corpus <- tm_map(corpus, removePunctuation)
corpus
# No stop words are removed. The default english stop words list provided in the 'tm' package. 
corpus <- tm_map(corpus, removeWords, stopwords("english"))
corpus
# Our data set is now stemmed.
corpus <- tm_map(corpus, stemDocument)
corpus
strwrap(corpus[[1]])
# Now extract the word frequencies to be used for prediction
# tm package has the function, DocumentTermMatrix()
# corpus <- Corpus(VectorSource(corpus))
DTM <- DocumentTermMatrix(corpus)

DTM

# Let's remove the terms that are infrequent
sparse_DTM <- removeSparseTerms(DTM, 0.97)
sparse_DTM
# Creating a dataframe from the DTM
labeledTerms <- as.data.frame(as.matrix(sparse_DTM))

# Use make.names for easy R use.
colnames(labeledTerms) <- make.names(colnames(labeledTerms))

# Adding the responsive part
labeledTerms$responsive <- emails$responsive

str(labeledTerms)

# Splitting data to create training/testing sets
# Generate pseudo-random numbers with 144 as the starting point
set.seed(144)

# 70% of responsive variables are set to TRUE when dividing into training set
split <- sample.split(labeledTerms$responsive, SplitRatio = 0.7)

train <- subset(labeledTerms, split == TRUE)
test <- subset(labeledTerms, split == FALSE)

# Now lets build a CART Model. CART - Classification and regression Trees is a tool for predictive
# model. 

emailCART <- rpart(responsive ~ . , data = train, method = "class")

# Plots the model
prp(emailCART)

# We see at the very top is the word California.
# If californ appears at least twice in an email, we are going to take the right path and predict that a document is responsive.
# It is somewhat unsurprising that California shows up, because we know that Enron had a heavy involvement in the California energy markets.
# Further down the tree, we see a number of other terms that we could plausibly expect to be related to energy bids and energy scheduling, like system, demand, bid, and gas.
# Down at the bottom is jeff, which is perhaps a reference to Enron's CEO, Jeff Skillings, who ended up actually being jailed for his involvement in the fraud at the company.

#  Now that we have trained it. It is time to evaluate it on the test set.

predictCART <- predict(emailCART, newdata = test)
predictCART[1:10,]

# We need the predicted probability of the document being responsive and it would be convenient to
# handle it separately
predictCART.prob <- predictCART[ , 2]

# Here we create the confusion matrix from the test set.
cmat_CART<- table(test$responsive, predictCART.prob >= 0.5)
cmat_CART

# Then we calculate the accuracy (out of sample)
accu_CART <- (cmat_CART[1,1] + cmat_CART[2,2])/sum(cmat_CART)

# Comparing with the baseline model. The baseline model always predicts non-responsive(most common value
# of the dependant variable). In this case the average of the dependent variable.

cmat_baseline <- table(test$responsive)
cmat_baseline

accu_baseline <- max(cmat_baseline)/sum(cmat_baseline)
accu_baseline

# Comparing the baseline with our cart model; CART is just slightly better than the baseline
# There is ofcourse the error that the responsive document is not responsive or vice versa.
# So now, we might falsely assign the responsive values to the documents.
# Also since its a document retrieval applications, there are uneven costs for different errors.
# Manual review is done to check if predicted responsive documents are actually responsive.

# To correct it we see what the result is with respecy to false positive and false negative.
# False-positive : a non-responsive document labeled as responsive->manual removal has extra work.
# False-negative : a responsive document as non-responsive->we will miss the document entirely in the
# predictive coding process.

# Make false-negative costs higher.

# ROC Curve - to understand the performance of the model at different cutoffs.

predROCR <- prediction(predictCART.prob, test$responsive)
predROCR <- performance(predROCR, "tpr", "fpr")

# Plot it

plot(predROCR, colorize = TRUE, lwd = 4)
predROCR <- prediction(predictCART.prob, test$responsive)
# AUC
auc_CART <- as.numeric(performance(predROCR, "auc")@y.values)
auc_CART
