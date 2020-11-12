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

#dontrunthisever
# ids = ""
# brf$colls = ""
# coll = filter(coll,!is.na(LNAME))
# for (i in 1:dim(brf)[1]) {
#   for (j in 1:dim(coll)[1]) {
#     if (grepl(coll$LNAME[j],brf$specimen_voucher[i])) {
#       ids = paste(ids,coll$`@ID`[j],sep="|")
#     }
#   }
#   brf$colls = ids
#   ids = ""
#   if (i%%200==0) {
#     print(i)
#   }
# }

swd()
coll = read_tsv("../source files/COLLECTORS.TXT",
                quote="",
                col_types = cols(.default = "c"))

nope = c("E035",
         "MIGUELS")

coll = filter(coll,!is.na(LNAME))
coll = filter(coll,!`@ID`%in%nope)
brf$colls = ""
for (i in 1:dim(coll)[1]) {
  nam = filter(brf,grepl(coll$LNAME[i],specimen_voucher))
  if (dim(nam)[1]>0) {
    brf$colls[brf$accession%in%nam$accession] = paste(brf$colls[brf$accession%in%nam$accession],
                                                      coll$`@ID`[i],
                                                      sep="|")
  }
}
#still need to add ids and other name info from the table

write_tsv(brf,"brpos-collids.txt",na="")
