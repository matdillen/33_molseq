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
