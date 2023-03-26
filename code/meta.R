library(dplyr)
library(metafor)
library(readxl)
library(robumeta)

data <- read_excel("data/data_extraction_te_20230205.xlsx", sheet = "Study Statistics")
data <- escalc(
  data=data,
  measure="SMD",
  m1i=mint_diff,
  sd1i=sdint_diff,
  n1i=nint,
  m2i=mcon_diff,
  sd2i=sdcon_diff,
  n2i=ncon,
)

data <- data %>% filter(study != "Sawyer (2017)")

# When Cohen's d cannot be calculated from raw values, fall back to reported values
data$yi <- coalesce(data$yi, data$precalc_d)
data$vi <- coalesce(data$vi, data$precalc_v)

data_outcomes <- data %>%
  # filter(post_intervention_months <= 6) %>%
  select("study", "sample_id", "outcome", "subsample", "post_intervention_months", "yi", "vi") %>%
  # mutate(post_3m=post_intervention_months >= 3) %>%
  group_split(outcome)

for (data_outcome in data_outcomes)
{
  
  cat("\n\n\n\n", data_outcome[["outcome"]][1], "\n\n", sep="")
  print(data_outcome, n=50)
  result <- robu(
    formula=yi ~ 1,
    data=data_outcome,
    var.eff.size=vi,
    studynum=study,
    rho=0.8,
    small=TRUE,
  )
  print(result)
}