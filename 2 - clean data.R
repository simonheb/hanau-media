proper=function(x) paste0(toupper(substr(x, 1, 1)), tolower(substring(x, 2)))

#take only unique observations
results <- readRDS("1 - rawsearchresults.RDS")
dat <-  results$dat %>% distinct(link, .keep_all = TRUE)
print(table(dat$journal))
dat$days_since_attack[dat$attack=="hanau"]<-round(as.numeric(dat$date[dat$attack=="hanau"]-as.POSIXlt("2020-02-19 21:50"),unit="days"),1)
dat$days_since_attack[dat$attack=="berlin"]<-round(as.numeric(dat$date[dat$attack=="berlin"]-as.POSIXlt("2016-12-19 20:00"),unit="days"),1)

dat<-dat[order(dat$dat),]

#capitalize strings that are used as labels
dat$Zeitung<-proper(dat$journal)
dat$Anschlag<-proper(dat$attack)

#pepare the subset of columns that will be shown to users:
dat$Datum<-strftime(dat$date,"%d.%m.%Y")
dat$Titel<-apply(dat[,c("kicker","title")],1,paste,collapse=": ")
dat$Link <- paste0("<a href='",dat$link,"'>",dat$Titel,"</a> (",dat$author,")")

saveRDS(list(dat=dat,date=results$date),"2 - cleanedsearchresults.RDS")
