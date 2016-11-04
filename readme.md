
A couple of days ago, I was looking for a way to create a citation graph from list of DOIs using R. 

It turned out that, although packages exists to get basic citation information from Google Scholar (with [scholar](https://cran.r-project.org/package=scholar)), Scopus ([rscopus](https://cran.r-project.org/web/packages/rscopus)) or CrossRef ([rcrossref](https://cran.r-project.org/web/packages/rcrossref)), informations about citing article is pretty much closed. The only site that allowed it was  PubMed, with the drawback that it only analyse its own database.  Here is how I did it. 

First, we start with a list PubMed ids, for which we would like to have the citation graph. In this exemple, these are the id’s from my own papers. We also store a the id’s as a single string (to be re-used latter).

```
PMIDs <- c(27352932,
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

PMIDs_ch <- paste(PMIDs, collapse=",")

```

Then, for each PMID, we ask PubMed to return the prides of the citing article. This is simply done by building a [custom url](https://www.ncbi.nlm.nih.gov/books/NBK3862/), thanks to the NCBI API’s.

```
# We build the URL to retrieve the citing PMIDs
path <- paste("https://www.ncbi.nlm.nih.gov/pubmed?linkname=pubmed_pubmed_citedin&from_uid=",
                PMID,
                "&report=uilist&format=text&dispmax=200", sep="")
f <- file(path)
data <- readLines(f, warn = F)
data <- gsub("&lt;", "<", data)
data <- gsub("&gt;", ">", data)
citing <-strsplit(xmlToList(xmlParse(data, asText = T))[1], "\n")[[1]]
close(f)
```

Ones we have the citing PMIDs as a list, we create a new data frame containing with the source PMID, the citing PMIDs.

```
# Then we create a table containing all these PMIDs
if(length(citing) < 200){
for(pm in citing){
  citegraph <- rbind(citegraph, 
	  data.frame(PMID=as.numeric(PMID), 
							  citing=as.numeric(pm)))
}
}
```
   
   
Finally, we use [visNetwork](http://datastorm-open.github.io/visNetwork/) for the visualisation of the citation graph. We use a different colour for the source PMIDs and the citing PMIDs. 

```
# We use visNetwork for the vizualisation of the network
# For that we need a nodes and edges tables. 

nodes <- data.frame(id=unique(c(citegraph$PMID, citegraph$citing)))
for(i in 1:nrow(nodes)){
  nodes$color[i] <- "lightblue"
  if(grepl(nodes$id[i], PMIDs_ch)){
    nodes$color[i] <- "red"
  }
}

edges <- data.frame(from = citegraph[,2], to = citegraph[,1])
visNetwork(nodes, edges, width = "100%")
```

The complete code I used is [available here]()


