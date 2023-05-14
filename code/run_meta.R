library(dplyr)
library(metafor)
library(readxl)
library(robumeta)
library(forestploter)
library(gridExtra)
library(grid)
library(gtable)
library(PublicationBias)
library(ggplot2)
library(ggpmisc)

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

data <- data %>% filter(outcome != "Parental confidence")

# Summarize included studies
study_outcomes <- data %>%
    distinct(study, outcome) %>%
    group_by(study) %>%
    mutate(outcome = paste0(outcome, collapse = ", "))
study_fus <- data %>%
    distinct(study, post_intervention_months) %>%
    group_by(study) %>%
    mutate(post_intervention_months = paste0(post_intervention_months, collapse = ", "))
study_summary <- distinct(merge(study_outcomes, study_fus, by = "study"))

png(
    "figures/Study summaries.png",
    res = 600,
    width = 11,
    height = 8,
    units = "in",
)
theme <- ttheme_default(core = list(fg_params = list(hjust = 0, x = 0.01)))
table <- tableGrob(study_summary, theme = theme, rows = NULL)
grid.draw(table)
dev.off()

# When Cohen's d cannot be calculated, fall back to reported values
data <- data %>% mutate(
    yi = coalesce(yi, precalc_d),
    vi = coalesce(vi, precalc_v),
    `Cohen's d (sign adj.)` = case_when(
        outcome %in% c("Anxiety", "Depression", "Stress") ~ -yi,
        TRUE ~ yi,
    ),
    post_bins = case_when(
        post_intervention_months <= 3 ~ "<=3",
        post_intervention_months <= 6 ~ ">3,<=6",
        post_intervention_months > 6 ~ ">6,<=24",
    )
)


cat(
    "\n\n\n\n############################\n",
    "Comparing follow-up periods (0-3 mos, 4-6 mos, 7-24 mos)",
    "\n############################\n",
    sep = ""
)

tt <- t.test(
    x = (data %>% filter(post_bins == "<=3"))$`Cohen's d (sign adj.)`,
    y = (data %>% filter(post_bins == ">3,<=6"))$`Cohen's d (sign adj.)`
)
cat("\n0-3 months vs. 4-6 months:\n")
print(tt)
tt <- t.test(
    x = (data %>% filter(post_bins == "<=3"))$`Cohen's d (sign adj.)`,
    y = (data %>% filter(post_bins == ">6,<=24"))$`Cohen's d (sign adj.)`
)
cat("\n0-3 months vs. 7-24 months\n")
print(tt)
tt <- t.test(
    x = (data %>% filter(post_bins == ">3,<=6"))$`Cohen's d (sign adj.)`,
    y = (data %>% filter(post_bins == ">6,<=24"))$`Cohen's d (sign adj.)`
)
cat("\n4-6 months vs. 7-24 months\n")
print(tt)

result_time_all <- robu(
    formula = `Cohen's d (sign adj.)` ~ post_intervention_months,
    data = data,
    var.eff.size = vi,
    studynum = study,
    rho = 0.8,
    small = TRUE,
)
print(result_time_all)

g <- ggplot(
        data %>% rename(`Post-intervention assessment interval (mos.)` = post_intervention_months),
        aes(x = `Post-intervention assessment interval (mos.)`, y = `Cohen's d (sign adj.)`),
    ) +
    stat_poly_line() +
    stat_poly_eq(use_label(c("eq", "R2"))) +
    geom_point(aes(col = outcome))
ggsave(
    paste("figures/Time trend.png", sep = ""),
    plot = g,
    width = 10,
    height = 6,
)

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
        "design",
        "control",
    ) %>%
    group_split(outcome)

reg_table <- data.frame()
for (data_outcome in data_outcomes) {
    outcome_name <- data_outcome[["outcome"]][1]
    cat(
        "\n\n\n\n############################\n",
        toupper(outcome_name),
        "\n############################\n",
        sep = ""
    )
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

    # Run sensitivity analysis over study design
    study_design_stats <- data_outcome %>% group_by(design) %>% summarise(n = n())
    study_design_sens <- "N/A"
    if (min(study_design_stats$n) > 2 && nrow(study_design_stats) == 2) {
        result_metareg <- robu(
            formula = yi ~ design,
            data = data_outcome,
            var.eff.size = vi,
            studynum = study,
            rho = 0.8,
            small = TRUE,
        )
        study_design_sens <- paste(
            paste0("t=", round(result_metareg$reg_table$t[2], 3)),
            paste0("p=", round(result_metareg$reg_table$prob[2], 3)),
            paste0("df=", round(result_metareg$reg_table$dfs[2], 3)),
            sep = ", "
        )
    }

    # Run sensitivity analysis over control type (active/inactive)
    control_stats <- data_outcome %>% group_by(control) %>% summarise(n = n())
    control_sens <- "N/A"
    routine_care_effects <- "N/A"
    if (min(control_stats$n) > 2 && nrow(control_stats) == 2) {
        result_metareg <- robu(
            formula = yi ~ control,
            data = data_outcome,
            var.eff.size = vi,
            studynum = study,
            rho = 0.8,
            small = TRUE,
        )
        control_sens <- paste(
            paste0("t=", round(result_metareg$reg_table$t[2], 3)),
            paste0("p=", round(result_metareg$reg_table$prob[2], 3)),
            paste0("df=", round(result_metareg$reg_table$dfs[2], 3)),
            sep = ", "
        )

        if (result_metareg$reg_table$prob[2] < 0.05) {
            result_routine_care <- robu(
                formula = yi ~ 1,
                data = data_outcome %>% filter(control == "Routine care"),
                var.eff.size = vi,
                studynum = study,
                rho = 0.8,
                small = TRUE,
            )
            routine_care_effects <- paste(
                paste0("d=", round(result_routine_care$reg_table$`b.r`, 3)),
                paste0("p=", round(result_routine_care$reg_table$prob, 3)),
                sep = ", "
            )
        }
    }

    # Run metaregression using post intervention months as dependent variable
    over_time_stats <- data_outcome %>% group_by(post_intervention_months) %>% summarise(n = n())
    over_time_sens <- "N/A"
    if (nrow(over_time_stats) > 1) {
        result_metareg <- robu(
            formula = yi ~ post_intervention_months,
            data = data_outcome,
            var.eff.size = vi,
            studynum = study,
            rho = 0.8,
            small = TRUE,
        )
        print(result_metareg)
        over_time_sens <- paste(
            paste0("t=", round(result_metareg$reg_table$t[2], 3)),
            paste0("p=", round(result_metareg$reg_table$prob[2], 3)),
            paste0("df=", round(result_metareg$reg_table$dfs[2], 3)),
            sep = ", "
        )
    }

    result$reg_table$`s-value¹` <- ifelse(
        is.numeric(bias_result$stats$sval_ci),
        round(bias_result$stats$sval_ci, 3),
        "--"
    )
    result$reg_table$`Egger's prob` <- eggers$reg_table$prob[2]
    result$reg_table$`Exp/quasi sensitivity²` <- study_design_sens
    result$reg_table$`Control type sensitivity³` <- control_sens
    result$reg_table$`d,p-val (inact. con.)⁴` <- routine_care_effects
    result$reg_table$`Int. x time⁵` <- over_time_sens
    result$reg_table$outcome <- outcome_name

    reg_table <- rbind(reg_table, result$reg_table)
    cat("\n\n")
    print(result)

    png(
        paste("figures/", outcome_name, " funnel.png", sep = ""),
        res = 600,
        width = 4.5,
        height = 4,
        units = "in",
    )
    par(mar = c(3.55, 3.55, 1.1, 1.2), mgp = c(2.3, 1, 0))
    funnel(
        x = data_outcome$yi,
        vi = data_outcome$vi,
        xlab = "Cohen's d",
        slab = data_outcome$study,
        back = "white",
        level = c(90, 95),
        shade = c("gray65", "gray85"),
        # legend = ifelse(result$reg_table$b.r < 0, "topleft", TRUE),
    )
    legend(
        ifelse(result$reg_table$b.r < 0, "topleft", "topright"),
        c("0.10 < p < 1.00", "0.05 < p < 0.10", "0.00 < p < 0.05"),
        fill = c("gray65", "gray85", "white"),
        bty = "n",
    )
    # text(
    #     data_outcome$yi,
    #     sqrt(data_outcome$vi) - 0.008,
    #     data_outcome$study,
    #     cex = 0.6,
    #     col = "darkgray",
    # )
    dev.off()
}

reg_table <- reg_table %>% mutate(
        `Egger's sig` = case_when(
            `Egger's prob` < 0.01 ~ "***",
            `Egger's prob` < 0.05 ~ "**",
            `Egger's prob` < 0.1 ~ "*",
            TRUE ~ "",
        ),
    ) %>%
    mutate_if(is.numeric, ~round(., 3)) %>%
    select("outcome", everything()) %>%
    relocate(any_of(c("CI.L", "CI.U")), .after = `b.r`) %>%
    relocate(any_of(c("Egger's sig")), .after = `Egger's prob`)

write.csv(
    reg_table,
    file = "data/reg_table.csv",
    row.names = FALSE,
)

reg_table <- reg_table %>% rename(
        `Cohen's d` = `b.r`,
        `p-val` = prob,
        `95% CI (L)` = `CI.L`,
        `95% CI (U)` = `CI.U`,
    )

png(
    "figures/Results.png",
    res = 600,
    width = 21,
    height = 5,
    units = "in",
)
footnote <- textGrob(
    paste(
        "¹s-value is defined as the ratio by which significant studies would have be to more",
        "likely to be published than non-signficant studies to eliminate significance.",
        "\n²The sensitivity analysis for study design compared experimental and quasi-experimental",
        "studies. A significant impact due to study design is indicated by a p<0.05.\nSome",
        "outcomes included only experimental study designs, indicated by N/A.",
        "\n³The sensitivity analysis for control type compared active and inactive control",
        "studies.",
        "\n⁴For analyses that were sensitive to the inclusion of active controls, analyses were",
        "rerun with only inactivate control studies.",
        "\n⁵To assess how the effect of intervention in sustained over time, a metaregression was",
        "performed with post-intervention follow-up time as the dependent variable."
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
    t = nrow(table),
    l = 1,
    r = ncol(table),
)
grid.draw(table)
dev.off()
