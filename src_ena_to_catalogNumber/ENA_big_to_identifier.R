# library(microbenchmark)
library(tidyverse)
library(data.table)
gbif_export<-fread(file.path("../33_molseq","data","0107125-200613084148143.csv"),encoding = "UTF-8")
ENA_big<-fread("6M_ENA_specimen_vouchers.csv",select=c("specimen_voucher","accession"),na.strings = "")
ENA_big_all<-fread("6M_ENA_specimen_vouchers.csv",na.strings = "")

# create visualistation of available data ---------------------------------

ENA_big_all[sample(.N, 100000)] %>%
  select(-c(
    "accession",
    "description",
    "scientific_name",
    # "specimen_voucher",
    "tax_id"
  )) %>% 
  mutate_all(list(~na_if(.,""))) %>%
  visdat::vis_dat(warn_large_data = F)


# closer look at the date field, because vis_guess does not do Date types, but
# handles numbers better

ENA_big_all[sample(.N, 100000)] %>%
  select(c("collection_date"
    )) %>% mutate_all(list(~na_if(.,""))) %>% 
visdat::vis_guess(palette = "cb_safe")

ENA_date<-ENA_big_all[sample(.N,100000)][,.("collection_date")]

# extract and match specimen vouchers -------------------------------------



extract_number <- function(input_string) {
  
    paste0(unlist(str_extract_all(str_extract(input_string,"([0-9]+(?>-)?[0-9]+)"),"[0-9]+")),collapse = "")
  
}

library(stringi)
extract_number <- function(input_string) {
  
  # paste0(unlist(str_extract_all(str_extract(input_string,"([0-9]+(?>-)?[0-9]+)"),"[0-9]+")),collapse = "")
  # paste0(
    stri_trim_left(
    stri_extract_first(
      stri_extract(input_string, regex = "([0-9]+(?>-)?[0-9]+)"),
      regex = "[0-9]+"
    ),pattern="[^0]")
    # , collapse = "")
  
}

# microbenchmark(extract_number,times = 100)



system.time(ENA_big[1:10000,digit:=map_chr(specimen_voucher,extract_number)])

ENA_big[,digit:=map_chr(specimen_voucher,extract_number)]
gbif_export[,digit:=map_chr(catalogNumber,extract_number)]

gbif_export[ENA_big]


glimpse(gbif_export)

# setkey(gbif_export,"changed catalog number integers")

# gbif_export[1:400,catalogNumber] %>% str_extract("[0-9]+") %>% as.double() %>% format(scientific=F) %>% trimws()

# splitsen op spaties, elke chunk met cijfers erin, haal te veel letters en
# haakjes eruit, en die strings enkel de cijfers, en vergelijken met wat er op
# GBIF staat in catalgoNumber, occurenceID, recordNumber (enkel de cijfers)
