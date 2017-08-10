

rm(list = ls())                         # Remove all
setwd("D:/onedrive/IFLS/IFLS1/")        # Working Directory
rawdata <- "D:/onedrive/IFLS/tariff/"   # Rawdata Directory

library(rio)
library(matlab)
library(stringdist)


mymatch <- function(a,b) {
      for (i in 1:length(b)) stringdist
}
      
produk6d <- import("D:/onedrive/IFLS/tariff/produk6d.dta")
j1g <- import("j1g_tk19a.dta")


mscore <- list()
for (i in 1:6) {
      mscore[[i]] <- stringdistmatrix(produk6d[,2], j1g[,i+2], method="jaccard", q=2)
      names(mscore[[i]]) <- list(produk6d[,2], j1g[,i+2])
}
