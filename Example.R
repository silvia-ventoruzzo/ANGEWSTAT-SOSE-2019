library(tidyverse)
library(topicmodels)
library(tidytext)

# DocumentTermMatrix -> find out how it works
data("AssociatedPress")
AssociatedPress

# Apply LDA, k is the number of topics for the model
ap_lda <- topicmodels::LDA(AssociatedPress, k = 2, control = list(seed = 1234))
ap_lda

# Extract the per-topic-per-word probabilities, called β (“beta”), from the model
ap_topics <- tidytext::tidy(ap_lda, matrix = "beta")
ap_topics
# For each combination topic-term, the model computes the probability of that term being generated from that topic

# Find top 10 terms that are most common within each topic
ap_top_terms <- ap_topics %>%
  group_by(topic) %>%
  dplyr::top_n(10, beta) %>%
  ungroup() %>%
  arrange(topic, -beta)

# Plot 10 most common terms within each topic
ap_top_terms %>%
  mutate(term  = reorder(term, beta),
         topic = paste("topic", topic, sep = " ")) %>%
  ggplot(aes(term, beta, fill = factor(topic))) +
  geom_col(show.legend = FALSE) +
  facet_wrap(~ topic, scales = "free") +
  coord_flip()

# Calculate the greatest difference in beta between topic 1 and topic 2 (using log2(beta2/beta1))
beta_spread <- ap_topics %>%
  mutate(topic = paste0("topic", topic)) %>%
  spread(topic, beta) %>%
  filter(topic1 > .001 | topic2 > .001) %>%
  mutate(log_ratio = log2(topic2 / topic1))

# Examine the per-document-per-topic probabilities, called γ (“gamma”)
ap_documents <- tidytext::tidy(ap_lda, matrix = "gamma")
ap_documents

rm(list = ls())

## EXAMPLE
titles <- c("Twenty Thousand Leagues under the Sea", "The War of the Worlds",
            "Pride and Prejudice", "Great Expectations")
library(gutenbergr)
books <- gutenbergr::gutenberg_works(title %in% titles) %>%
  gutenberg_download(meta_fields = "title")

# First of all, divide books into chapters
by_chapter <- books %>%
  group_by(title) %>%
  mutate(chapter = cumsum(str_detect(text, regex("^chapter ", ignore_case = TRUE)))) %>%
  ungroup() %>%
  filter(chapter > 0) %>%
  unite(document, title, chapter)
# Here: each chapter is one document

# Split chapter (document) into words
by_chapter_word <- by_chapter %>%
  unnest_tokens(word, text)

# find document-word counts after eliminating stop words
word_counts <- by_chapter_word %>%
  anti_join(stop_words, by = "word") %>%
  count(document, word, sort = TRUE) %>%
  ungroup()
# We have now a one-term-per-document-per-row format, which is how we want the data
# However, we need a DocumentTermMatrix for the topicmodels package

# Transform dataframe into DocumentTermMatrix
chapters_dtm <- word_counts %>%
  tidytext::cast_dtm(document, word, n)
chapters_dtm

# We look for 4 topics because in this example topic = book
# In other cases one might need to try different values of k
chapters_lda <- LDA(chapters_dtm, k = 4, control = list(seed = 1234))

# Examine now per-topic-per-word probabilities = beta (here: topic = book)
chapter_topics <- tidy(chapters_lda, matrix = "beta")

# Top 5 terms within each topic
top_terms <- chapter_topics %>%
  group_by(topic) %>%
  top_n(5, beta) %>%
  ungroup() %>%
  arrange(topic, -beta)
top_terms %>%
  mutate(term  = reorder(term, beta),
         topic = paste0("topic", topic)) %>%
  ggplot(aes(term, beta, fill = factor(topic))) +
  geom_col(show.legend = FALSE) +
  facet_wrap(~ topic, scales = "free") +
  coord_flip()

# NOTE: in line with LDA being a “fuzzy clustering” method, there can be words in common between multiple topics

# Examine per-document-per-topic probabilities = lambda (here: document = chapter)
chapters_gamma <- tidy(chapters_lda, matrix = "gamma")
chapters_gamma

# Expectation: chapters within a book would be found to be mostly (or entirely), generated from the corresponding topic


# Boxplot of values of gamma according to the 4 topics for the different books
# Values of boxplot coming from the different chapters
chapters_gamma <- chapters_gamma %>%
  separate(document, c("title", "chapter"), sep = "_", convert = TRUE)
chapters_gamma %>%
  mutate(title = reorder(title, gamma * topic)) %>%
  ggplot(aes(factor(topic), gamma)) +
  geom_boxplot() +
  facet_wrap(~ title)

# All books excep for "Great Expectations" were identified by (mostly) one topic
# We therefore need to analyze which topic was most associated with each chapter of this book
chapter_classifications <- chapters_gamma %>%
  group_by(title, chapter) %>%
  top_n(1, gamma) %>%
  ungroup()
chapter_classifications

# To see which were the most misidentified chapters, we look at the most common topic among the chapters of each book
book_topics <- chapter_classifications %>%
  count(title, topic) %>%
  group_by(title) %>%
  top_n(1, n) %>%
  ungroup() %>%
  transmute(consensus = title, topic)
chapter_classifications %>%
  inner_join(book_topics, by = "topic") %>%
  filter(title != consensus)

# GAMMA: One step of the LDA algorithm is assigning each word in each document to a topic.
# The more words in a document are assigned to that topic, generally,
# the more weight (gamma) will go on that document-topic classification.

# Find which words in each document were assigned to which topic
assignments <- tidytext::augment(chapters_lda, data = chapters_dtm)
assignments
# count = appearances of term in the document
# .topic (only variable created by augment) = to which topic the word was assigned

# Now we can find out which words were incorrectly classified
assignments <- assignments %>%
  separate(document, c("title", "chapter"), sep = "_", convert = TRUE) %>%
  inner_join(book_topics, by = c(".topic" = "topic"))

# Confusion matrix to displayed misclassified words
assignments %>%
  count(title, consensus, wt = count) %>%
  group_by(title) %>%
  mutate(percent = n / sum(n)) %>%
  ggplot(aes(consensus, title, fill = percent)) +
  geom_tile() +
  scale_fill_gradient2(high = "red", label = scales::percent_format()) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 90, hjust = 1),
        panel.grid = element_blank()) +
  labs(x = "Book words were assigned to",
       y = "Book words came from",
       fill = "% of assignments")
# As already seen, mostly words from "Great Expectations" were missclassified

# Find out exactly which words were wrongly classified
wrong_words <- assignments %>%
  filter(title != consensus)
wrong_words %>%
  count(title, consensus, term, wt = count) %>%
  ungroup() %>%
  arrange(desc(n))
# Some of these words, such as "love", were misclassified because they appear more often in "Pride and Prejudice"
# To see this one can analyze the counts

# Some words however don't appear in the book they are assigned to (example = "flopson")
word_counts %>%
  filter(word == "flopson")

# NOTE: The LDA algorithm is stochastic, and it can accidentally land on a topic that spans multiple books.