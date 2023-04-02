library(plyr)
library(grid)
library(forestploter)

# Read provided sample example data
reg_table <- read.csv(paste("data/reg_table.csv", sep = "")) %>%
    group_split(outcome)
for (reg_outcome in reg_table) {
    outcome_name <- reg_outcome$outcome[1]
    data <- read.csv(paste("data/", outcome_name, ".csv", sep = "")) %>%
        mutate(
            ci.lb = yi - sqrt(vi) * 1.96,
            ci.ub = yi + sqrt(vi) * 1.96,
            post_intervention_months = as.character(post_intervention_months),
            N = as.character(N),
            is_summary = FALSE,
        ) %>%
        arrange(-yi)
    reg_outcome <- data.frame(
        study = "Total",
        yi = reg_outcome$b.r,
        ci.lb = reg_outcome$CI.L,
        ci.ub = reg_outcome$CI.U,
        is_summary = TRUE,
        subsample = paste(rep(" ", 15), collapse = " ")
    )
    data <- rbind.fill(data, reg_outcome)

    data <- data %>%
        dplyr::rename(
            `Study (Year)` = study,
            `Subsample` = subsample,
            `FU (mo.)` = post_intervention_months,
        )

    # Keep needed columns
    data <- data[, c(1, 4, 5, 8, 6, 9, 10, 11)]
    data$Subsample <- coalesce(data$Subsample, "")
    data$`FU (mo.)` <- coalesce(data$`FU (mo.)`, "")
    data$N <- coalesce(data$N, "")

    # Add blank column for the forest plot to display CI.
    # Adjust the column width with space.
    data$` ` <- paste(rep(" ", 30), collapse = " ")

    # # Create confidence interval column to display
    data$`Cohen's d [95% CI]` <- ifelse(
        is.na(data$yi),
        "",
        sprintf("%.2f [%.2f, %.2f]", data$yi, data$ci.lb, data$ci.ub)
    )

    p <- forestploter::forest(
        data[, c(1:4, 9:10)],
        est = data$yi,
        lower = data$ci.lb,
        upper = data$ci.ub,
        ci_column = 5,
        ref_line = 0,
        xlim = c(-5, 5),
        ticks_at = c(-4, -2, -0, 2, 4),
        is_summary = data$is_summary,
        theme = forest_theme(summary_fill = "black", summary_col = "black", ci_Theight = 0.2),
    )

    p <- edit_plot(p, row = nrow(data), gp = gpar(fontface = "bold"))
    p <- edit_plot(p, col = c(3:4, 6), which = "text", hjust = unit(1, "npc"), x = unit(0.9, "npc"))
    p <- edit_plot(
        p,
        col = c(3:4, 6),
        part = "header",
        which = "text",
        hjust = unit(1, "npc"),
        x = unit(0.9, "npc")
    )

    # Print plot
    png(
        paste("figures/", outcome_name, ".png", sep = ""),
        res = 600,
        width = 10,
        height = (nrow(data) + 2) / 3,
        units = "in",
    )
    plot(p)
    dev.off()
}
