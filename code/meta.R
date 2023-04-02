library(dplyr)
library(metafor)
library(readxl)
library(robumeta)
library(forestploter)
library(gridExtra)

options(warn = -1)

data <- read_excel(
    "data/data_extraction_te_20230205.xlsx",
    sheet = "Study Statistics",
)
data$N <- data$nint + data$ncon
data <- escalc(
    data = data,
    measure = "SMD",
    m1i = mint_diff,
    sd1i = sdint_diff,
    n1i = nint,
    m2i = mcon_diff,
    sd2i = sdcon_diff,
    n2i = ncon,
)

data <- data %>% filter(study != "Sawyer (2017)")

# When Cohen's d cannot be calculated, fall back to reported values
data$yi <- coalesce(data$yi, data$precalc_d)
data$vi <- coalesce(data$vi, data$precalc_v)

data_outcomes <- data %>%
    # filter(post_intervention_months <= 6) %>%
    select(
        "study",
        "sample_id",
        "outcome",
        "subsample",
        "post_intervention_months",
        "yi",
        "vi",
        "N",
    ) %>%
    # mutate(post_3m=post_intervention_months >= 3) %>%
    group_split(outcome)

reg_table <- data.frame()
for (data_outcome in data_outcomes)
{
    outcome_name <- data_outcome[["outcome"]][1]
    cat("\n\n\n\n", outcome_name, "\n\n", sep = "")
    print(data_outcome, n = 50)
    write.csv(
        data_outcome,
        file = paste("data/", outcome_name, ".csv", sep = ""),
        row.names = FALSE,
    )
    result <- robu(
        formula = yi ~ 1,
        data = data_outcome,
        var.eff.size = vi,
        studynum = study,
        rho = 0.8,
        small = TRUE,
    )
    result$reg_table$outcome <- outcome_name
    reg_table <- rbind(reg_table, result$reg_table)
    print(result)
}

write.csv(
    reg_table,
    file = "data/reg_table.csv",
    row.names = FALSE,
)

png(
    "figures/results.png",
    res = 600,
    width = 12,
    height = 5,
    units = "in",
)
grid.table(reg_table)
dev.off()
