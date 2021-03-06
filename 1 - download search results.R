try({setwd('~/hanau-media/')})
try({setwd('D:/Dropbox/hanau-media')})
source('pseudo apis.R')
source('0 - config.R')

#combine to queries
queries_hanau<-apply(expand.grid(prefix_hanau,suffix),1,paste0,collapse=" ")
queries_berlin<-apply(expand.grid(prefix_berlin,suffix),1,paste0,collapse=" ")
queries_ansbach<-apply(expand.grid(prefix_ansbach,suffix),1,paste0,collapse=" ")
queries_würzburg<-apply(expand.grid(prefix_würzburg,suffix),1,paste0,collapse=" ")
queries_halle<-apply(expand.grid(prefix_halle,suffix),1,paste0,collapse=" ")

#search and create data frames of results
results_berlin_sz<-do.call(dplyr::bind_rows,lapply(queries_berlin,szsearch))
results_berlin_bild<-do.call(dplyr::bind_rows,lapply(queries_berlin,bildsearch))
results_berlin_spiegel<-do.call(dplyr::bind_rows,lapply(queries_berlin,spiegelsearch))
results_berlin_faz<-do.call(dplyr::bind_rows,lapply(queries_berlin,fazsearch))
results_berlin<-bind_rows(results_berlin_bild,
                      results_berlin_sz,
                      results_berlin_faz,
                      results_berlin_spiegel)
results_berlin$attack<-"berlin"


results_hanau_sz<-do.call(dplyr::bind_rows,lapply(gsub("tobias rathjen",'"tobias.r."',queries_hanau),szsearch)) #sz refuses to write out rathjen 
results_hanau_bild<-do.call(dplyr::bind_rows,lapply(queries_hanau,bildsearch))
results_hanau_spiegel<-do.call(dplyr::bind_rows,lapply(queries_hanau,spiegelsearch))
results_hanau_faz<-do.call(dplyr::bind_rows,lapply(gsub("tobias rathjen",'tobias.r',queries_hanau),fazsearch))
results_hanau<-bind_rows(results_hanau_bild,
                         results_hanau_sz,
                         results_hanau_faz,
                         results_hanau_spiegel)
results_hanau$attack<-"hanau"




results_ansbach_spiegel<-do.call(dplyr::bind_rows,lapply(queries_ansbach,spiegelsearch))
results_ansbach_sz<-do.call(dplyr::bind_rows,lapply(queries_ansbach,szsearch)) #sz refuses to write out rathjen 
results_ansbach_faz<-do.call(dplyr::bind_rows,lapply(queries_ansbach,fazsearch))
results_ansbach_bild<-do.call(dplyr::bind_rows,lapply(queries_ansbach,bildsearch))
results_ansbach<-bind_rows(results_ansbach_bild,
                         results_ansbach_sz,
                         results_ansbach_faz,
                         results_ansbach_spiegel)
results_ansbach$attack<-"ansbach"



results_würzburg_spiegel<-do.call(dplyr::bind_rows,lapply(queries_würzburg,spiegelsearch))
results_würzburg_faz<-do.call(dplyr::bind_rows,lapply(queries_würzburg,fazsearch))
results_würzburg_sz<-do.call(dplyr::bind_rows,lapply(queries_würzburg,szsearch)) #sz refuses to write out rathjen 
results_würzburg_bild<-do.call(dplyr::bind_rows,lapply(queries_würzburg,bildsearch))
results_würzburg<-bind_rows(results_würzburg_bild,
                            results_würzburg_sz,
                            results_würzburg_faz,
                            results_würzburg_spiegel)
results_würzburg$attack<-"würzburg"

results_halle_spiegel<-do.call(dplyr::bind_rows,lapply(queries_halle,spiegelsearch))
results_halle_faz<-do.call(dplyr::bind_rows,lapply(queries_halle,fazsearch))
results_halle_sz<-do.call(dplyr::bind_rows,lapply(queries_halle,szsearch)) #sz refuses to write out rathjen 
results_halle_bild<-do.call(dplyr::bind_rows,lapply(queries_halle,bildsearch))
results_halle<-bind_rows(results_halle_bild,
                            results_halle_sz,
                            results_halle_faz,
                            results_halle_spiegel)
results_halle$attack<-"halle"

results<-rbind(results_hanau,results_berlin,results_ansbach,results_würzburg)

print("maybe merge the data with older, stored data, otherwise at some point we will be loosing data")
saveRDS(list(dat=results,
             date=Sys.Date(),
             prefix_hanau,
             prefix_berlin,
             suffix
             ),"1 - rawsearchresults.RDS")

# 
# 
# library(ggplot2)
# 
# joint_data_bild<-
#   rbind(cbind(merge(timeline_b_bild,timelinebench_b_bild,by="days_since",all=T),Attack="Berlin"),
#         cbind(merge(timeline_h_bild,timelinebench_h_bild,by="days_since",all=T),Attack="Hanau"))
# gg_bild<-ggplot(joint_data_bild, aes(x=days_since/timeunit)) + 
#   geom_line(aes(y = articles/benchmark_articles,color=Attack)) + 
#   xlim(-5,53) + xlab("Weeks since attack") + ylab("Weekly number of articles in \"Bild\" on the topic") +
#   # annotate("text",label=
#   #            paste0("Articles on Hanau are identified as matching any of these search terms:\n",
#   #                   paste0(prefix_hanau,collapse=", "),
#   #                   "\ncombined and a suffix:\n",
#   #                   paste0(suffix,collapse=", "),
#   #                   "\non bild.de/suche.bild.html\n",
#   #                   "Artikels on Berlin are identified as through those terms:\n",
#   #                   paste0(prefix_berlin,collapse=", "),
#   #                   "\nwith the same suffixes"
#   #            ),15,350,hjust=0) +
#   theme_light()
# 
# 
# merge(time)
# 
# joint_data_spiegel<-
#   rbind(cbind(merge(timeline_b_spiegel,timelinebench_b_spiegel,by="days_since",all=T)),Attack="Berlin",
#         cbind(merge(timeline_h_spiegel,timelinebench_h_spiegel,by="days_since",all=T)),Attack="Hanau")
# gg_spiegel<-ggplot(joint_data_spiegel, aes(x=days_since/timeunit)) + 
#   geom_line(aes(y = articles,color=Attack)) + 
#   xlim(-5,53) + xlab("Weeks since attack") + ylab("Weekly number of articles in \"spiegel\" on the topic") +
#   # annotate("text",label=
#   #            paste0("Articles on Hanau are identified as matching any of these search terms:\n",
#   #                   paste0(prefix_hanau,collapse=", "),
#   #                   "\ncombined and a suffix:\n",
#   #                   paste0(suffix,collapse=", "),
#   #                   "\non spiegel.de/suche\n",
#   #                   "Artikels on Berlin are identified through these terms:\n",
#   #                   paste0(prefix_berlin,collapse=", "),
#   #                   "\nwith the same suffixes"
#   #            ),15,110,hjust=0) +
#   # annotate("text",label="Bento held a series of interviews with the victim's families. Bento\nwas disolved in Sept and interviews were merged into Spiegel's\narchives. This explains the peak in week 25",
#   #          38,30)+
#   theme_light()
# 
