
require(plyr)
require(XML)
require(RCurl)
require(readxl)
require(visNetwork)


# We start with a list PubMed ids, for which we would like to have the citation graph
pmids <- c(27352932,
           26905656,
           26476447,
           26287479,
           25657812,
           25614065,
           24744766,
           24515834,
           24143806,
           24107223,
           23875292,
           23286457,
           22558767,
           21771915,
           20453027)

pmids_ch <- paste(pmids, collapse=",")


citegraph <- NULL
for(pmid in pmids){
    # Get more info with the pmid id
    tryCatch({
      
      # We build the URL to retrieve the citing pmids
      path <- paste("https://www.ncbi.nlm.nih.gov/pubmed?linkname=pubmed_pubmed_citedin&from_uid=",
                    pmid,
                    "&report=uilist&format=text&dispmax=200", sep="")
      f <- file(path)
      data <- readLines(f, warn = F)
      citing <-strsplit(xmlToList(xmlParse(data, asText = T))[1], "\n")[[1]]
      close(f)
      
      # Then we create a table containing ll these pmids
      if(length(citing) < 200){
        for(pm in citing){
          citegraph <- rbind(citegraph, data.frame(pmid=as.numeric(pmid), citing=as.numeric(pm)))
        }
      }
      
      message(paste0(pmid," done: ",length(citing)," citations"))
      
    }, warning = function(w) {
      message(w)
    }, error = function(e) {
      message(e)
    })
}


# We use visNetwork for the vizualisation of the network
# For that we need a nodes and edges tables. 

nodes <- data.frame(id=unique(c(citegraph$pmid, citegraph$citing)))
for(i in 1:nrow(nodes)){
  nodes$color[i] <- "lightblue"
  if(grepl(nodes$id[i], pmids_ch)){
    nodes$color[i] <- "red"
  }
}

edges <- data.frame(from = citegraph[,2], to = citegraph[,1])
visNetwork(nodes, edges, width = "100%")
