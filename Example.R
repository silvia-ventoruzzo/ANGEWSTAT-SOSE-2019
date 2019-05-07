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
