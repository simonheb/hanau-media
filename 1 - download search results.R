source('~/hanau-media/pseudo apis.R')
                                
suffix<-c("attentat","terror","anschlag")
prefix_hanau<-c("hanau","kesselstadt","tobias rathjen")
prefix_berlin<-c("breitscheidplatz","berliner weihnachtsmarkt","anis amri")

#benchmarks<-c("hollywood schauspielerin","gangster rapper","programmieren","iphone android","vegetarier")

#combine to queries
queries_hanau<-apply(expand.grid(prefix_hanau,suffix),1,paste0,collapse=" ")
queries_berlin<-apply(expand.grid(prefix_berlin,suffix),1,paste0,collapse=" ")

#search and create data frames of results
results_berlin_bild<-do.call(dplyr::bind_rows,lapply(queries_berlin,bildsearch))
results_berlin_spiegel<-do.call(dplyr::bind_rows,lapply(queries_berlin,spiegelsearch))
results_berlin_faz<-do.call(dplyr::bind_rows,lapply(queries_berlin,fazsearch))
results_berlin_sz<-do.call(dplyr::bind_rows,lapply(queries_berlin,szsearch))
results_berlin<-bind_rows(results_berlin_bild,
                      results_berlin_sz,
                      results_berlin_faz,
                      results_berlin_spiegel)
results_berlin$attack<-"berlin"


results_hanau_bild<-do.call(dplyr::bind_rows,lapply(queries_hanau,bildsearch))
results_hanau_spiegel<-do.call(dplyr::bind_rows,lapply(queries_hanau,spiegelsearch))
results_hanau_faz<-do.call(dplyr::bind_rows,lapply(queries_hanau,fazsearch))
results_hanau_sz<-do.call(dplyr::bind_rows,lapply(gsub("tobias rathjen",'"tobias.r."',queries_hanau),szsearch)) #sz refuses to write out rathjen 
results_hanau<-bind_rows(results_hanau_bild,
                      results_hanau_sz,
                      results_hanau_faz,
                      results_hanau_spiegel)
results_hanau$attack<-"hanau"

results<-rbind(results_hanau,results_berlin)

print("maybe merge the data with older, stored data, otherwise at some point we will be loosing data")
saveRDS(list(dat=results,date=Sys.Date()),"1 - rawsearchresults.RDS")

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
