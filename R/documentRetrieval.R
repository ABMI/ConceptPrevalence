# Copyright 2020 Observational Health Data Sciences and Informatics
#
# This file is part of ConceptPrevalence
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# These codes were written only to inform the code used. Never use the term referral code unless it is for maintenance purpose.

# ############################
# # install packages
# ############################
# if(!require("readtext"))
#   install.packages("readtext")
# library(readtext)
#
# if(!require("tm"))
#   install.packages("tm")
# library(tm)
#
# if(!require("stringr"))
#   install.packages("stringr")
# library(stringr)
#
# if(!require("qdap"))
#   install.packages("qdap")
# library(qdap)
#
# if(!require("slam"))
#   install.packages("slam")
# library(slam)
#
# if(!require("readr"))
#   install.packages("readr")
# library(readr)
#
# ############################
# # load target data
# ############################
# # source_to_concept_map <- readr::read_csv("measurement_guideline/source_to_concept_map.csv")
# # View(source_to_concept_map)
#
# urlfile <- 'https://raw.githubusercontent.com/ohdsi-korea/OmopVocabularyKorea/master/measurement_guideline/source_to_concept_map.csv'
# df_standard <- read.csv(url(urlfile))
#
# N.docs <- length(df_standard$source_code_description)
#
# ############################
# # preprocess data
# ############################
# docs <- df_standard$source_code_description
# docs <- gsub(';.+', '', docs)
#
# queries_list <- Corpus(VectorSource(docs))
# queries_list <-tm_map(queries_list, removeWords, stopwords('en'))
# queries_list <-tm_map(queries_list, removeNumbers)
# queries_list <-tm_map(queries_list, removePunctuation)
# queries_list <-tm_map(queries_list, stripWhitespace)
# queries_list <- colnames(as.matrix(DocumentTermMatrix(queries_list)))
#
# # queries_list <- docs
# N.query = length(queries_list)
#
# # convert to new data foramt
# corpus <- VectorSource(c(docs, queries_list))
# # corpus$names <- names(corpus)
# # corpus$Names <- c(names(docs), names(queries_list))
#
# # convert to corpus form
# corpus_preproc <- Corpus(corpus)
#
# # preprocess corpus for text mining process
# corpus_preproc <- tm_map(corpus_preproc, stripWhitespace)
# # corpus_preproc <- tm_map(corpus_preproc, removePunctuation)
# corpus_preproc <- tm_map(corpus_preproc, tolower)
#
# tdm <- TermDocumentMatrix(corpus_preproc, control = list(weighting = function(x) weightTfIdf(x, normalize = FALSE)))
# tdm_mat <- as.matrix(tdm)
#
# colnames(tdm_mat) <- c(docs, queries_list)
#
# tfidf_mat <- scale(tdm_mat, center=F, scale=sqrt(colSums(tdm_mat^2)))
#
# query.vectors <- tfidf_mat[, (N.docs + 1):(N.docs + N.query)]
# tfidf_mat <- tfidf_mat[, 1:N.docs]
#
# # doc.scores <- t(query.vectors) %*% tfidf_mat
# doc.scores <- t(query.vectors) %*% tfidf_mat
# colnames(doc.scores) <- df_standard$source_code
#
# # query need to be inserted
# # query <- 'cholesterol'
#
# results.df <- data.frame(querylist = queries_list, doc.scores, stringsAsFactors = F)

# function for retrieval
showTopresults <- function(query, n=20){

  x = results.df[which(results.df$querylist == query),]
  yy =  data.frame(t(x),rownames(t(x)),row.names = NULL)[-1,]
  names(yy) = c("score","docs")
  yy$score = as.numeric(as.character(yy$score))
  yyy = yy[order(yy$score,decreasing = T),]

  #return(yyy[which(yyy$score > 0),][1:n,])
  #idx <- rownames(showTopresults(query = 'pressure'))

  idx <- rownames(yyy[which(yyy$score > 0),][1:n,])
  idx <- stringr::str_detect(idx, "^NA", negate = TRUE)
  return(df_standard[c(idx),])

}

# Example of function
# showTopresults(query = 'pressure', n=5)
