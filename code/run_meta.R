library(dplyr)
library(metafor)
library(readxl)
library(robumeta)
library(forestploter)
library(gridExtra)
library(grid)
library(gtable)
library(PublicationBias)

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

data <- data %>% filter(study != "Sawyer (2017)", outcome != "Parental confidence")

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
    cat("\n\n\n\n", toupper(outcome_name), "\n", sep = "")
    # print(data_outcome, n = 50)
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

    data_outcome$sei <- sqrt(data_outcome$vi)
    eggers <- robu(
        formula = yi ~ sei,
        data = data_outcome,
        var.eff.size = vi,
        studynum = study,
        rho = 0.8,
        small = TRUE,
    )

    bias_result <- pubbias_svalue(
        yi = data_outcome$yi,
        vi = data_outcome$vi,
        cluster = data_outcome$study,
        model_type = "robust",
        favor_positive = result$reg_table$b.r > 0,
    )

    result$reg_table$`s-value*` <- ifelse(
        is.numeric(bias_result$stats$sval_ci),
        round(bias_result$stats$sval_ci, 3),
        "--"
    )
    result$reg_table$`Egger's prob` <- eggers$reg_table$prob[2]
    result$reg_table$outcome <- outcome_name
    reg_table <- rbind(reg_table, result$reg_table)
    cat("\n\n")
    print(result)
    
    png(
        paste("figures/", outcome_name, "_funnel.png", sep = ""),
        res = 600,
        width = 7,
        height = 7,
        units = "in",
    )
    funnel(
        x=data_outcome$yi,
        vi=data_outcome$vi,
        xlab="Cohen's d",
        slab=data_outcome$study,
        back="white",
        level=c(90, 95),
        shade=c("gray90", "gray95"),
        legend=ifelse(result$reg_table$b.r < 0, "topleft", TRUE),
    )
    text(
        data_outcome$yi,
        sqrt(data_outcome$vi) - 0.008,
        data_outcome$study,
        cex = 0.6,
        col = "darkgray",
    )
    dev.off()
}

reg_table <- reg_table %>% mutate(
        across(where(is.numeric), round, 3),
        `Egger's sig` = case_when(
            `Egger's prob` < 0.01 ~ "***",
            `Egger's prob` < 0.05 ~ "**",
            `Egger's prob` < 0.1 ~ "*",
            TRUE ~ "",
        ),
    ) %>%
    select("outcome", everything())

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
footnote <- textGrob(
    paste(
        "*s-value is defined as the ratio by which significant studies would have be to more",
        "likely to be published than non-signficant studies to eliminate significance."
    ),
    x = 0,
    hjust = 0,
    gp = gpar(fontface = "italic", fontsize = 10),
)
table <- tableGrob(reg_table, rows = NULL)
table <- gtable_add_rows(table, heights = c(0.3, 1.2) * grobHeight(footnote))
table <- gtable_add_grob(
    table,
    footnote,
    t=nrow(table),
    l=1,
    r=ncol(table),
)
grid.draw(table)
dev.off()