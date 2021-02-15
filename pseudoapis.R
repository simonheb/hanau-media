library(jsonlite)
library(httr)
library(rvest)

szsearch<-function(query,from="15.01.2015",to="21.02.2021") {
  urlnow<-paste0("https://www.sueddeutsche.de/news/teasers?from=0&size=1000&search=",gsub(" ","+AND+",query),"&sort=date&all%5B%5D=dep&all%5B%5D=time&typ%5B%5D=article&sys%5B%5D=sz&catsz%5B%5D=alles&endDate=",to,"&startDate=",from,collapse="")
  resp<-GET(urlnow)
  jsonRespText<-fromJSON(content(resp,as="text") , simplifyDataFrame = TRUE)
  if(jsonRespText$countTotalItems>1000) {
    print("This query yielded over 1k, something might be odd")
    browser()
  }
  if(jsonRespText$countTotalItems==0) {
    print("This query yielded 0, something might be odd")
    browser()
  }
  resultsHTML<-jsonRespText$listitems %>% read_html
  results_list<-resultsHTML %>% html_nodes("div.entrylist__entry")
  results_df<-results_list %>% map_df(~data.frame( link=.x%>%html_node("a") %>%html_attr("href"),
                      kicker=.x%>%html_nodes("strong.entrylist__overline") %>% html_text %>% trimws,
                      date=.x%>%html_nodes("time.entrylist__time") %>% html_text%>% trimws %>% as.POSIXlt(format="%d:%M:%Y | %H:%m"),
                      title=.x%>%html_nodes("em.entrylist__title") %>% html_text %>% trimws,
                      teaser=.x%>%html_nodes("p.entrylist__detail") %>% html_text %>% trimws,
                      author=paste0(.x%>%html_nodes("span.entrylist__author") %>% html_text %>% trimws,"")))
  return(results_df)
}



fazsearch<-function(query,from="11.11.2016",to="18.02.2021",pages=-1) {
  if(pages!=-1) {
    cat(".")
    urlnow=pages[1]
    pages=pages[-1]
  } else { #if this function was called without pages
    cat("searching faz.net for: ",query,"\n")
    urlnow<-paste0("https://www.faz.net/suche/?query=",gsub(" ","+",query),"&type=content&ct=article&author=&from=",(from),"&to=",(to),collapse="")
  }
  
  search<-html_session(urlnow)
  results<-search %>% html_nodes("ul.lst-Teaser li article div.tsr-Base_TextWrapper div div.teaserInner") %>% 
    map_df(~data.frame( link=.x%>%html_node("a") %>%html_attr("href"),
                                  kicker=.x%>%html_nodes("span.tsr-Base_HeadlineEmphasisText") %>% html_text %>% trimws,
                                  date=.x%>%html_nodes("time.tsr-Base_ContentMetaTime") %>% html_attr("datetime")%>%as.POSIXlt(format="%Y-%M-%dT%H:%m:%S"),
                                  title=.x%>%html_nodes("span.tsr-Base_HeadlineText") %>% html_text %>% trimws,
                                  teaser=.x%>%html_nodes("div.tsr-Base_Content") %>% html_text %>% trimws,
                                  author=paste0(.x%>%html_nodes("li.tsr-Base_ContentMetaItem-author") %>% html_text %>% trimws,"")))
  if (length(pages)==0) #no more remaining pages
    return(results)
  if (pages==-1) {#if this function was called without pages
    lastpage<-search %>% html_node("ul.nvg-Paginator li.nvg-Paginator_Item-to-last-page a") %>% html_attr("href")
    if(is.na(lastpage)) #there's just one page
      return(results)
    else {
      pagelinkstructure <- stringr::str_match(lastpage,"^(https://www.faz.net/suche/s)(\\d+)(\\.html.*)$")
      pages<-gsub(" ","+",apply(cbind(pagelinkstructure[2],2:pagelinkstructure[3],pagelinkstructure[4]),1,paste0,collapse=""))
    }
    cat("found results distributed across ",length(pages)," additional pages. Iterating:")
  }
  return(rbind(results,
               fazsearch(query=query,from=from,to=to,pages=pages)
               ))

}


