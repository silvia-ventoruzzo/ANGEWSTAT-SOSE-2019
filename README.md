# Application of LDA topic model to song lyrics

This repository contains the files for the project "Application of LDA topic model to song lyrics" for the seminar Advanced Statistical Modelling at the Free University Berlin in the Summer Term 2019.

## Description

In trying to understand the large collection of texts that are present nowadays, one would like to divide them into groups in order to separately comprehend their message ([[5]](#5)). Topic modelling serves this purpose, being an unsupervised classification method which searches for natural groups of words in the documents, called topics ([[5]](#5)). A specific topic modelling algorithm is called *Latent Dirichlet Allocation (LDA)*, which "treats each document as a mixture of topics, and each topic as a mixture of words" ([[5]](#5)). 

In this project LDA was applied to a corpus of 200 song texts from multiple artists of different music genres to search for the underlying topics and to analyze if there are various topics within genres or artists.

The seminar paper can be read [here](https://github.com/silvia-ventoruzzo/ANGEWSTAT-SOSE-2019/blob/master/Silvia_Ventoruzzo_Paper.pdf) and the presentation poster found [here](https://github.com/silvia-ventoruzzo/ANGEWSTAT-SOSE-2019/blob/master/Silvia_Ventoruzzo_Poster.pdf).

## Data
The data was downloaded from two sources in Kaggle: [(1)](https://www.kaggle.com/mousehead/songlyrics) and [(2)](https://www.kaggle.com/gyani95/380000-lyrics-from-metrolyrics).

## Content

The project is divided into the following parts:
1. Creation of corpus:
   - Tokenization
   - Pre-processing (lowercasing, stemming, removal of stopwords)
   - Transformation into the Document-Term-Matrix representation
2. Exploratory Data Analysis:
   - General analysis by genre (e.g. total and distinct words per song, most common words)
   - Sentiment analysis using the _afinn_ lexicon from the `sentiments` dataset from the `R` package `tidytext`
4. Estimation of number of topics:
   - Optimization of following metrics: Perplexity ([[2]](#2)), CaoJuan2009 ([[3]](#3)), Arun2010 ([[1]](#1)), Deveaud2014 ([[4]](#4))
5. LDA results' analysis:
   - Per-topic-per-word probability
   - Per-document-per-topic probability


## References
<a id="1">[1]</a> Arun, R., Suresh, V., Madhavan, C. V., & Murthy, M. N. (2010, June). On finding the natural number of topics with latent dirichlet allocation: Some observations. In Pacific-Asia conference on knowledge discovery and data mining (pp. 391-402). Springer, Berlin, Heidelberg.

<a id="2">[2]</a> Blei, D. M., Ng, A. Y., & Jordan, M. I. (2003). Latent dirichlet allocation. the Journal of machine Learning research, 3, 993-1022.

<a id="3">[3]</a> Cao, J., Xia, T., Li, J., Zhang, Y., & Tang, S. (2009). A density-based method for adaptive LDA model selection. Neurocomputing, 72(7-9), 1775-1781.

<a id="4">[4]</a> Deveaud, R., SanJuan, E., & Bellot, P. (2014). Accurate and effective latent concept modeling for ad hoc information retrieval. Document numérique, 17(1), 61-84.

<a id="5">[5]</a> Silge, J., & Robinson, D. (2017). Text mining with R: A tidy approach. O’Reilly Media, Inc.
