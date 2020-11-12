brpossibles = br3

#filter meisenburg and different, longer BR acronyms
brf = brpossibles %>%
  filter(!grepl("Meisenburg",specimen_voucher),
         !grepl("[A-Z]BR",specimen_voucher))

#list space-separated chunks with numbers
#filter out the common BR indicator
#remove az of 3 or more (longer than BR)
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


coll = read_tsv("data/meise-coll.txt",
                col_types = cols(.default = "c"))

brf$verbatimRecordedByID = ""
brf$recordedByLastName = ""
brf$recordedBy = ""
brf$recordedByID = ""

#no teams parsing
#false positives w homonyms and short last names
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


for (i in 1:dim(brf)[1]) {
  nums = strsplit(brf$nums[i],split="\\|")[[1]]
  nums = gsub("[^0-9]","",nums)
  brf$numbers[i] = paste(nums,collapse="|")
}

write_tsv(brf,"brpos-collids.txt",na="")

dwc = read_tsv("occurrence.txt",col_types = cols(.default = "c"))

brf2 = brf %>%
  separate_rows(numbers,sep="\\|")

