library(jsonlite)
library(httr)
library(rvest)
library(dplyr)
library(xml2)
library(purrr)
library(stringr)


szsearch<-function(query,from="01.01.2016",to="21.02.2021") {
  cat("searching sz.de for:",query)
  urlnow<-paste0("https://www.sueddeutsche.de/news/teasers?from=0&size=1000&search=",gsub(" ","+AND+",query),"&sort=date&all%5B%5D=dep&all%5B%5D=time&typ%5B%5D=article&sys%5B%5D=sz&catsz%5B%5D=alles&endDate=",to,"&startDate=",from,collapse="")
  resp<-GET(urlnow)
  jsonRespText<-fromJSON(content(resp,as="text") , simplifyDataFrame = TRUE)
  if(jsonRespText$countTotalItems>1000) {
    print("This query yielded over 1k, something might be odd")
    browser()
  }
  if(jsonRespText$countTotalItems==0) {
    print("This query yielded 0, something might be odd")
    return(NULL)
  }
  resultsHTML<-jsonRespText$listitems %>% read_html
  results_list<-resultsHTML %>% html_nodes("div.entrylist__entry")
  results_df<-results_list %>% map_df(~data.frame( link=.x%>%html_node("a") %>%html_attr("href"),
                      kicker=.x%>%html_nodes("strong.entrylist__overline") %>% html_text %>% str_squish,
                      date=.x%>%html_nodes("time.entrylist__time") %>% html_text%>% str_squish %>% as.POSIXlt(format="%d.%m.%Y | %H:%M"),
                      time=.x%>%html_nodes("time.entrylist__time") %>% html_text%>% str_squish %>% as.POSIXlt(format="%H:%M"), #todays articles are shown only with a time
                      title=.x%>%html_nodes("em.entrylist__title") %>% html_text %>% str_squish,
                      teaser=.x%>%html_nodes("p.entrylist__detail") %>% html_text %>% str_squish,
                      author=paste0(.x%>%html_nodes("span.entrylist__author") %>% html_text %>% str_squish,"")))
  results_df$date[is.na(results_df$date)]<-results_df$time[is.na(results_df$date)]  
  if(any(is.na(results_df$date)))
    browser()
  results_df$query<-query
  results_df$journal<-"sz"
  
  return(results_df)
}



fazsearch<-function(query,from="01.01.2016",to="18.02.2021",pages=-1) {
  if(any(pages!=-1)) {
    cat(".")
    urlnow=pages[1]
    pages=pages[-1]
  } else { #if this function was called without pages
    cat("searching faz.net for: ",query,"\n")
    urlnow<-paste0("https://www.faz.net/suche/?query=",gsub(" ","+",query),"&type=content&ct=article&author=&from=",(from),"&to=",(to),collapse="")
  }
  search<-html_session(urlnow)
  results_raw<-search %>% html_nodes("ul.lst-Teaser li article div.tsr-Base_TextWrapper div div.teaserInner")
  if (length(results_raw)==0) {
    return(NULL)
  }
  results<-results_raw %>% 
    map_df(~data.frame( link=.x%>%html_node("a") %>%html_attr("href"),
                                  kicker=.x%>%html_nodes("span.tsr-Base_HeadlineEmphasisText") %>% html_text %>% str_squish,
                                  date=.x%>%html_nodes("time.tsr-Base_ContentMetaTime") %>% html_attr("datetime")%>%as.POSIXlt(format="%Y-%m-%dT%H:%M:%S"),
                                  title=.x%>%html_nodes("span.tsr-Base_HeadlineText") %>% html_text %>% str_squish,
                                  teaser=.x%>%html_nodes("div.tsr-Base_Content") %>% html_text %>% str_squish,
                                  author=paste0(.x%>%html_nodes("li.tsr-Base_ContentMetaItem-author") %>% html_text %>% str_squish,"")))
  if(mean(c(0,is.na(results$date)))>0.05)
    browser()
  results$query<-query
  results$journal<-"faz"
  
  if (length(pages)==0) {#no more remaining pages
    cat("\n")
    return(results)
  }
  if (any(pages==-1)) {#if this function was called without pages
    lastpage<-search %>% html_node("ul.nvg-Paginator li.nvg-Paginator_Item-to-last-page a") %>% html_attr("href")
    if(is.na(lastpage)) {#there's just one page 
      cat("\n")
      return(results)
    }
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





bildsearch<-function(query) {
  cat("searching bild.de for: ",query,"... ")
  url<-paste0("https://www.bild.de/suche.bild.html?type=article&query=",gsub("\\s","+",query),"&resultsStart=0&resultsPerPage=1000",collapse="")
  #bild does some serious rate-limitting, so let's sleep a bit so that we don't  scare them
  Sys.sleep(180)
  search <-   tryCatch(#had do do this to find rate limits
    {
      html_session(url)               ## create session content s15
    }
    ,
    error=function(cond) {
      message(paste("issue with:", url))
      message("Here's the original error message:")
      message(cond)
      a<-NULL
      browser()
      return(a)
    },
    warning=function(cond) {
      message(paste("issue with:", url))
      message("Here's the original error message:")
      message(cond)
      a<-NULL
      browser()
      return(a)
    },
    finally={
    }
  )    
  results <-   tryCatch(#had do do this to find rate limits
    {
      search %>% html_nodes("section.query") %>% html_nodes(xpath="//ol/li") 
    },
    
    error=function(cond) {
      message(paste("issue with:", url))
      message("Here's the original error message:")
      message(cond)
      a<-NULL
      browser()
      return(a)
    },
    warning=function(cond) {
      message(paste("issue with:", url))
      message("Here's the original error message:")
      message(cond)
      a<-NULL
      browser()
      return(a)
    },
    finally={
    }
  )  
  if (length(results)==0) {
    return(NULL)
  }
  extracted_data<-lapply(results,function(x) data.frame(
    "kicker"=x %>% html_node("a")   %>% html_attr("data-tb-kicker"),
    "title"=x %>% html_node("a")   %>% html_attr("data-tb-title"),
    "teaser"=paste0("",x %>% html_nodes("div") %>% html_nodes("p") %>% html_text %>% str_squish),
    "link"=x %>% html_node("a") %>% html_attr("href"),
    "date"=as.POSIXct(x %>% html_node("a") %>% html_node(xpath="ul/li/time") %>% html_attr("datetime"),format="%Y-%m-%d")))
  extracted_dataframe<-do.call(rbind, extracted_data)
  if(mean(c(0,is.na(extracted_dataframe$date)))>0.05)
    browser()
  extracted_dataframe$query<-query
  extracted_dataframe$journal<-"bild"
  cat("returning ",nrow(extracted_dataframe)," articles I found\n")
  return(extracted_dataframe)
}

spiegelsearch<-function(query,max=100,from="20160101",to="20210213",page=0) {
  if (max!=100) {print("I think spon ignores anything thats not 100")}
  url<-paste0("https://joda.spiegel.de/joda/spon/search?s=",gsub(" ","%20",query),"&p=SPOX,SPPL&f=dokumenttext&page=",page,"&max=",max,"&from=",from,"&to=",to,"&plus=0",collapse="")
  search<-read_xml(url)
  hits<-search %>% xml_find_first("hitsTotal") %>% xml_text
  if (page==0) {
    cat("searching spiegel.de for: ",query,"\n")
    print(hits)
  }
  if (as.numeric(hits)>1000) {
    print("found more than 1000 that's a bad query")
    browser()
  }
  results<-search %>% xml_find_all("//dokument")
  extracted_data<-lapply(results,function(x) data.frame(
    "kicker" = paste0("",x %>% xml_find_all(".//oberzeile") %>% xml_text),
    "title" = x %>% xml_find_all(".//ueberschrift") %>% xml_text,
    "teaser" = paste0("",x %>% xml_find_all(".//teaserText") %>% xml_text),
    "link" = x %>% xml_find_all(".//dokAnzeigeUrl") %>% xml_text,
    "date" = as.POSIXct(x %>% xml_find_all(".//erscheinungsdatum") %>% xml_text,format="%d.%m.%Y"),
    "spiegel_id" = paste(x %>% xml_find_all(".//id") %>% xml_text,collapse=","),
    "authors" = paste(x %>% xml_find_all(".//autoren") %>% xml_find_all(".//name") %>% xml_text(),collapse=", "),
    "spiegel_kuerzel" = x %>% xml_find_all(".//quelle") %>%xml_find_all(".//kuerzel") %>% xml_text,
    "spiegel_rubrik" = x %>% xml_find_all(".//rubrik") %>% xml_text,
    "spiegel_channel" = x %>% xml_find_all(".//channel") %>% xml_text
  ))
  extracted_dataframe<-do.call(rbind, extracted_data)
  extracted_dataframe$query<-query
  extracted_dataframe$journal<-"spiegel"
  if(any(is.na(extracted_dataframe$date)))
    browser()
  if (as.numeric(hits)>(page+1)*max) {
    return(rbind(extracted_dataframe,
                 spiegelsearch(query=query,max=max,from=from,to=to,page=page+1)))
  }
  return(extracted_dataframe)
}
