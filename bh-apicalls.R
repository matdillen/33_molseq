library(tidyverse)
library(jsonlite)
library(httr)
library(urltools)
library(rentrez)

#ena

base_url = "https://www.ebi.ac.uk/ena/portal/api/search?"

full_url = paste0(base_url, "result=sequence",
                  "&query=collection_date>=2015-01-01 AND collection_date<=2019-12-31",
                  #"&query=specimen_voucher=\"*meise*\"",
                  paste0("&fields=",
                         "accession,",
                         "country,",
                         "location,",
                         "description,",
                         "scientific_name,",
                         "bio_material,",
                         "culture_collection,",
                         "specimen_voucher,",
                         "sample_accession,",
                         "study_accession,",
                         "collected_by,",
                         "collection_date,",
                         "tax_id,",
                         "identified_by"),
                  "&limit=0&format=json")
querna <- function(url) {
  full_url <- URLencode(url)
  ena_r = GET(full_url)
  rcontent = content(ena_r,
                     as="text")
  rjson = fromJSON(rcontent,
                   flatten=T)
  return(rjson)
}

full_url <- URLencode(full_url)

ena_r = GET(full_url)

rcontent = content(ena_r,
                   as="text")

rjson = fromJSON(rcontent,
                 flatten=T)

#bigset = rjson

#see frequency of empty fields
#use this on bigset for an overview (otherwise not used)
stats = rjson[2,]
for (i in 1:dim(rjson)[2]) {
  var = colnames(rjson)[i]
  x = rjson %>%
    filter(.data[[var]]=="")
  stats[1,i] = dim(x)[1]
  stats[2,i] = round(100*dim(x)[1]/dim(rjson)[1],2)
}

full_url = paste0(base_url, "result=sequence",
                  #"&query=collection_date>=2015-01-01 AND collection_date<=2019-12-31",
                  "&query=specimen_voucher=\"*meise*\"",
                  paste0("&fields=",
                         "accession,",
                         "country,",
                         "location,",
                         "description,",
                         "scientific_name,",
                         "bio_material,",
                         "culture_collection,",
                         "specimen_voucher,",
                         "sample_accession,",
                         "study_accession,",
                         "collected_by,",
                         "collection_date,",
                         "tax_id,",
                         "identified_by"),
                  "&limit=0&format=json")

brmeise = querna(full_url)
write_tsv(brmeise,"data/brmeiseset.txt",na="")

full_url = paste0(base_url, "result=sequence",
                  "&query=specimen_voucher=\"*BR)*\"",
                  paste0("&fields=",
                         "accession,",
                         "country,",
                         "location,",
                         "description,",
                         "scientific_name,",
                         "bio_material,",
                         "culture_collection,",
                         "specimen_voucher,",
                         "sample_accession,",
                         "study_accession,",
                         "collected_by,",
                         "collection_date,",
                         "tax_id,",
                         "identified_by"),
                  "&limit=0&format=json")

brcard = querna(full_url)
write_tsv(brcard,"data/brcard.txt",na="")

full_url = paste0(base_url, "result=sequence",
                  "&query=specimen_voucher=\"*BR:*\"",
                  paste0("&fields=",
                         "accession,",
                         "country,",
                         "location,",
                         "description,",
                         "scientific_name,",
                         "bio_material,",
                         "culture_collection,",
                         "specimen_voucher,",
                         "sample_accession,",
                         "study_accession,",
                         "collected_by,",
                         "collection_date,",
                         "tax_id,",
                         "identified_by"),
                  "&limit=0&format=json")
brcolon = querna(full_url)
write_tsv(brcolon,"data/brcolonset.txt",na="")

full_url = paste0(base_url, "result=sequence",
                  "&query=specimen_voucher=\"*BR-*\"",
                  paste0("&fields=",
                         "accession,",
                         "country,",
                         "location,",
                         "description,",
                         "scientific_name,",
                         "bio_material,",
                         "culture_collection,",
                         "specimen_voucher,",
                         "sample_accession,",
                         "study_accession,",
                         "collected_by,",
                         "collection_date,",
                         "tax_id,",
                         "identified_by"),
                  "&limit=0&format=json")

brdash = querna(full_url)
write_tsv(brdash,"data/brdashset.txt",na="")

#don't run
#many genes give false positives
# full_url = paste0(base_url, "result=sequence",
#                   "&query=description=\"*BR)*\"",
#                   paste0("&fields=",
#                          "accession,",
#                          "country,",
#                          "location,",
#                          "description,",
#                          "scientific_name,",
#                          "bio_material,",
#                          "culture_collection,",
#                          "specimen_voucher,",
#                          "sample_accession,",
#                          "study_accession,",
#                          "collected_by,",
#                          "collection_date,",
#                          "tax_id,",
#                          "identified_by"),
#                   "&limit=0&format=json")

full_url = paste0(base_url, "result=sequence",
                  "&query=specimen_voucher=\"*BR0000*\"",
                  paste0("&fields=",
                         "accession,",
                         "country,",
                         "location,",
                         "description,",
                         "scientific_name,",
                         "bio_material,",
                         "culture_collection,",
                         "specimen_voucher,",
                         "sample_accession,",
                         "study_accession,",
                         "collected_by,",
                         "collection_date,",
                         "tax_id,",
                         "identified_by"),
                  "&limit=0&format=json")
br0 = querna(full_url)

#not run
#regex doesn't work
# full_url = paste0(base_url, "result=sequence",
#                   "&query=specimen_voucher=\"BR[0-9]{13}\"",
#                   paste0("&fields=",
#                          "accession,",
#                          "country,",
#                          "location,",
#                          "description,",
#                          "scientific_name,",
#                          "bio_material,",
#                          "culture_collection,",
#                          "specimen_voucher,",
#                          "sample_accession,",
#                          "study_accession,",
#                          "collected_by,",
#                          "collection_date,",
#                          "tax_id,",
#                          "identified_by"),
#                   "&limit=0&format=json")
#brre = querna(full_url)

#
#samples: very few
# full_url = paste0(base_url, "result=sample",
#                   "&query=specimen_voucher=\"*BR)*\"",
#                   paste0("&fields=",
#                          "accession,",
#                          "country,",
#                          "location,",
#                          "description,",
#                          "bio_material,",
#                          "culture_collection,",
#                          "specimen_voucher,",
#                          "sample_accession,",
#                          "collected_by,",
#                          "collection_date,",
#                          "identified_by"),
#                   "&limit=0&format=json")
# brs0 = querna(full_url)

#missing fields in some queries:

br = rbind(brmeise,brcard)
br = rbind(br,brcolon)
br = rbind(br,brdash)
br = rbind(br,br0)

br = filter(br,!duplicated(accession))

write_tsv(br,"data/brpossibles.txt",na="")

#genbank

gb_r = entrez_search(db="nuccore",
                  term="*BR)*[ALL]")

#only 20 res, need to page

entrez_db_searchable(db="nuccore")

gb_results = entrez_summary(db="nuccore",
                   id=gb_r$ids)