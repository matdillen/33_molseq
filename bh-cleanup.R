#continue with result from bh-apicalls.R script
#or read the txt file with ENA sequences
brpossibles = br3

#filter meisenburg and different, longer BR acronyms
brf = brpossibles %>%
  filter(!grepl("Meisenburg",specimen_voucher),
         !grepl("[A-Z]BR",specimen_voucher))

#list space-separated chunks with numbers
#filter out the common BR indicator
#remove az of 3 or more (longer than BR)
#complication with Roman numerals, but these won't be used anyway
#we will only match collection/accession numbers by their numeric part
for (i in 1:dim(brf)[1]) {
  p = str_split(brf$specimen_voucher[i],
                pattern="\\s")[[1]]
  p = gsub("(BR)",
           "",
           p,
           fixed=T)
  
  nums = p[grep("[0-9]",
                p)]
  nums = gsub("[a-z|A-Z]{3,}",
              "",
              nums)
  brf$nums[i] = paste(nums,
                      collapse="|")
}

#extract the numeric part from the numeric-containing chunks
for (i in 1:dim(brf)[1]) {
  nums = strsplit(brf$nums[i],split="\\|")[[1]]
  nums = gsub("[^0-9]","",nums)
  brf$numbers[i] = paste(nums,collapse="|")
}

coll = read_tsv("meise-coll.txt",na="")

#Add person name info to the ENA results
#Match surnames from Meise's collector db to the specimen_voucher strings
#in the ena sequences
coll = read_tsv("data/meise-coll.txt",
                col_types = cols(.default = "c"))

brf$verbatimRecordedByID = ""
brf$recordedByLastName = ""
brf$recordedBy = ""
brf$recordedByID = ""

#no teams parsing
#false positives w homonyms and short last names
#needs optimizing for speed
for (i in 1:dim(coll)[1]) {
  nam = filter(brf,
               grepl(coll$recordedByLastName[i],
                     specimen_voucher)|
                 grepl(coll$recordedByLastName[i],
                       collected_by))
  if (dim(nam)[1]>0) {
    brf[brf$accession%in%nam$accession,
        c("verbatimRecordedByID",
          "recordedByLastName",
          "recordedBy",
          "recordedByID")] = t(sapply(seq(1,
                                          dim(nam)[1]), 
                                      function(x) 
                                        paste(brf[brf$accession%in%nam$accession[x],
                                                  c("verbatimRecordedByID",
                                                    "recordedByLastName",
                                                    "recordedBy",
                                                    "recordedByID")],
                                              tibble(coll[i,]),
                                              sep="|")))
  }
}

#remove leading pipes
brf$verbatimRecordedByID = gsub("^\\|",
                                "",
                                brf$verbatimRecordedByID)
brf$recordedByLastName = gsub("^\\|",
                              "",
                              brf$recordedByLastName)
brf$recordedBy = gsub("^\\|",
                      "",
                      brf$recordedBy)
brf$recordedByID = gsub("^\\|",
                        "",
                        brf$recordedByID)

#read GBIF dataset occurrence file
dwc = read_tsv("occurrence.txt",col_types = cols(.default = "c"))

#extract numeric part from recordNumber
dwc$num = gsub("[^0-9]","",dwc$recordNumber)

#list multiple recordedByIDs if multiple person records where found 
#in the collector database

brf2 = brf %>%
  separate_rows(numbers,sep="\\|")

##Obtain GBIF taxonIDs through Wikidata

#function to query wikidata
querki <- function(query,h="text/csv") {
  require(httr)
  response <- httr::GET(url = "https://query.wikidata.org/sparql", 
                        query = list(query = query),
                        httr::add_headers(Accept = h),
                        httr::user_agent("Matdillen"))
  return(httr::content(response,
                       type=h,
                       col_types = cols(.default = "c")))
}

#general query
query <- 'SELECT ?taxon ?taxonLabel ?ncbi_taxonID ?gbifid WHERE {
                  VALUES ?ncbi_taxonID {%s}
                  ?taxon wdt:P685 ?ncbi_taxonID.
                  OPTIONAL {?taxon wdt:P846 ?gbifid .}
                  SERVICE wikibase:label { bd:serviceParam wikibase:language "[AUTO_LANGUAGE],en". }
                }'

#list query results
for (i in seq(1,dim(tax)[1],30)) {
  subtax = paste0("\"",paste(tax$tax_id[i:(i+29)],collapse="\" \""),"\"")
  que = gsub("%s",
             subtax,query,fixed=T)
  if (i==1) {
    resu = querki(que)
  } else {
    resu = rbind(resu,querki(que))
  }
  print(i)
}

#join into ena sequence data
brf = left_join(brf,resu,by=c("tax_id"="ncbi_taxonID"))

#match for 3 criteria:

# - recordedByID on GBIF matches recordedByID connected to a surname recognized
# in the specimen_voucher string and present in Meise's collector db

# - numeric part of GBIF recordNumber matches a numeric chunk of the specimen
# voucher string in ENA

# - taxonKey of GBIF matches tax_id on ENA, 
# mapping between GBIF and NCBI done through Wikidata

brf$gbifbc = NA
for (i in 1:dim(brf)[1]) {
  nums = filter(brf2,accession==brf$accession[i])
  ids = strsplit(nums$recordedByID,split="\\|")[[1]]
  resu = filter(dwc,
                recordedByID%in%ids,
                num%in%nums$numbers,
                !is.na(recordedByID),
                !is.na(recordNumber),
                taxonKey%in%nums$gbifid)
  brf$gbifbc[i] = paste(resu$catalogNumber,collapse="|")
}

write_tsv(brf,"br-results.txt",na="")