
setwd("E:/SSJ/Sujit/IntrotoML/enron_mail_20150507/")
#Always run this script in the folder where maildir folder of the enron dataset exists
#Enron Email Dataset: https://www.cs.cmu.edu/~./enron/

#Load specialised libraries
library(stringr) #String manipulation
library(igraph, warn.conflicts=F) #Network analysis

#E-mail corpus consists of nested folders per user with e-mails as text files

#Create list of all available e-mails
emails <- list.files("maildir/", full.names=T, recursive=T)
length(emails)

#Filter by inbox only
emails <- emails[grep("/inbox", emails)]
length(emails)

#Create list of sender and receiver (inbox owner)
inboxes <- data.frame(
  from=apply(as.data.frame(emails), 1, function(x){readLines(x, warn=F)[3]}),
  to=emails, 
  stringsAsFactors=F
)

#Keep only enron.com and strip all but username
inboxes <- inboxes[grepl("@enron.com", inboxes$from),]
inboxes$from <- str_sub(inboxes$from, 7, nchar(inboxes$from)-10)
to <- str_split(inboxes$to, "/")
inboxes$to <- sapply(to, "[", 3)

#Create username list
users <- data.frame(user=paste0("maildir/", unique(inboxes$to)))

#Remove those without sent mails
sent <- apply(users, 1, function(x){sum(grepl("sent", dir(x)))})
users <- subset(users, !sent==0) 

#Replace username with e-mail name
users$mailname <- NA
for (i in 1:nrow(users)){
  sentmail <- dir(paste0(users$user[i], "/sent_items/"))
  name <- readLines(paste0(users$user[i], "/sent_items/", sentmail[1]), warn=F)[3]
  name <- str_sub(name, 7, nchar(name)-10)
  users$mailname[i] <- name
}
users$user <- str_sub(users$user, 9)
inboxes <- merge(inboxes, by.x="to", users, by.y="user")
inboxes <- data.frame(from=inboxes$from, to=inboxes$mailname)

inboxes$from <- as.character(inboxes$from)
inboxes$to <- as.character(inboxes$to)

#Only e-mails between inbox users
inboxes <- inboxes[inboxes$from %in% inboxes$to,]

#Remove no.address
inboxes <- subset(inboxes, from!="no.address" & to!="no.address")

#Remove mail to self
inboxes<- subset(inboxes, inboxes$from!=inboxes$to)

#Define network
g <- graph_from_edgelist(as.matrix(inboxes), directed=F)
coms <- spinglass.community(g)

#Plot network
par(mar=c(0,0,2,0))
plot(coms, g, 
     vertex.label=NA, 
     layout=layout.fruchterman.reingold,
     vertex.size=3,
     main="Enron e-mail network snapshot"
)

#Analyse network
degree(g)[order(degree(g), decreasing = T)]

