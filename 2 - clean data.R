library(dplyr)
library(tidyr)
library(reshape2)

proper=function(x) paste0(toupper(substr(x, 1, 1)), tolower(substring(x, 2)))

#take only unique observations
results <- readRDS("1 - rawsearchresults.RDS")
dat <-  results$dat %>% distinct(link,attack, .keep_all = TRUE)
print(table(dat$journal))
dat$days_since_attack[dat$attack=="hanau"]<-ceiling(as.numeric(dat$date[dat$attack=="hanau"]-as.POSIXlt("2020-02-19 21:50"),unit="days"))
dat$days_since_attack[dat$attack=="berlin"]<-ceiling(as.numeric(dat$date[dat$attack=="berlin"]-as.POSIXlt("2016-12-19 20:00"),unit="days"))
dat$days_since_attack[dat$attack=="ansbach"]<-ceiling(as.numeric(dat$date[dat$attack=="ansbach"]-as.POSIXlt("2016-07-24 22:10"),unit="days"))
dat$days_since_attack[dat$attack=="würzburg"]<-ceiling(as.numeric(dat$date[dat$attack=="würzburg"]-as.POSIXlt("2016-07-18 21:15"),unit="days"))
dat$days_since_attack[dat$attack=="halle"]<-ceiling(as.numeric(dat$date[dat$attack=="halle"]-as.POSIXlt("2019-10-09 12:00"),unit="days"))

dat<-dat[order(dat$dat),]

#capitalize strings that are used as labels
dat$Zeitung<-proper(dat$journal)
dat$Anschlag<-proper(dat$attack)

#pepare the subset of columns that will be shown to users:
dat$Datum<-strftime(dat$date,"%d.%m.%Y")
dat$Titel<-apply(dat[,c("kicker","title")],1,paste,collapse=": ")
dat$Titel[which(str_length(dat$kicker)==0)]<-as.character(dat$title[which(str_length(dat$kicker)==0)])
dat$link<-as.character(dat$link)
dat$link[dat$journal=="bild"]<-paste0("http://bild.de/",dat$link[dat$journal=="bild"])
dat$Link <- paste0("<a href='",dat$link,"'>",dat$Titel,"</a> (",dat$author,")")
dat$Link2 <- paste0("<a href='",dat$link,"'>",dat$Titel,"</a>")
dat$Link[which(is.na(dat$author))] <- dat$Link2[which(is.na(dat$author))]
print(nrow(dat))

dat<-subset(dat,date>as.POSIXlt("2016-01-01 00:00:00")& (is.na(spiegel_rubrik)|spiegel_rubrik!="bento.de")) #bento articles seem to be counted twice now, because the search still lists them twice
print(nrow(dat))
saveRDS(list(dat=dat,date=results$date),"2 - cleanedsearchresults.RDS")


dat$weeksinceattack<-floor(dat$days_since_attack/7)
dat$daysinceattack<-floor(dat$days_since_attack)

days_since_hanau     <- ceiling(as.numeric(Sys.time()-as.POSIXlt("2020-02-19 21:50"),unit="days")) #H
days_since_berlin    <- ceiling(as.numeric(Sys.time()-as.POSIXlt("2016-12-19 20:00"),unit="days")) #B
days_since_ansbach   <- ceiling(as.numeric(Sys.time()-as.POSIXlt("2016-07-24 22:10"),unit="days")) #a
days_since_wuerzburg <- ceiling(as.numeric(Sys.time()-as.POSIXlt("2016-07-18 21:15"),unit="days")) #w
days_since_halle     <- ceiling(as.numeric(Sys.time()-as.POSIXlt("2019-10-09 12:00"),unit="days")) #w

#append expanded data
dat<-bind_rows(
  dat %>%
    mutate(count=1),
  dat %>% 
    expand(journal,attack,days_since_attack=-365:(4*365)) %>%
    mutate(count=0)
)


dat<-subset(dat, days_since_attack > -365 & (
  attack=="berlin" & days_since_attack <= days_since_berlin |
    attack=="hanau"  & days_since_attack <= days_since_hanau |
    #attack=="würzburg"  & days_since_attack <= days_since_wuerzburg |
    attack=="ansbach"  & days_since_attack <= days_since_ansbach |
    attack=="halle"  & days_since_attack <= days_since_halle 
))

data_weekly <- 
  dat %>%
  group_by(weeksinceattack=floor(days_since_attack/7),journal,attack) %>%
  summarize(count=sum(count))

first_year_weekly<-data_weekly %>% 
  subset(weeksinceattack>=0 & weeksinceattack<52) %>%
  mutate(anyarticle=count>0)

saveRDS(dat,"outputdata article-level.RDS")
saveRDS(data_weekly,"outputdata week-level.RDS")


