library(plyr)
library(dplyr)
library(grid)
library(forestploter)

# Read provided sample example data
data <- data.frame()
outcomes <- c(
    "Anxiety",
    "Depression",
    "Parent satisfaction",
    "Parent self-efficacy",
    "Parent-child interaction",
    "Parental confidence",
    "Social support",
    "Stress"
)
reg_table <- read.csv(paste("data/reg_table.csv", sep = "")) %>%
    group_split(outcome)
for (reg_outcome in reg_table) {
    data_outcome_header <- data.frame(study = reg_outcome$outcome[1])
    data_outcome <- read.csv(paste("data/", outcome, ".csv", sep = "")) %>%
        mutate(
            study = paste("  ", study),
            ci.lb = yi - sqrt(vi) * 1.96,
            ci.ub = yi + sqrt(vi) * 1.96,
        )
    reg_outcome <- data.frame(
        study = "Total",
        yi = reg_outcome$b.r,
        ci.lb = reg_outcome$CI.L,
        ci.ub = reg_outcome$CI.U
    )
    data <- rbind.fill(data, data_outcome_header, data_outcome, reg_outcome)
}
data <- data %>%
    rename(
        `Study (Year)` = study,
        `Subsample` = subsample,
        `Follow-up Interval` = post_intervention_months,
    )


# Keep needed columns
# dt <- dt[,1:6]
data <- data[, c(1, 4, 5, 6, 8, 9)]
data$Subsample <- coalesce(data$Subsample, "")

# Add blank column for the forest plot to display CI.
# Adjust the column width with space.
data$` ` <- paste(rep(" ", 20), collapse = " ")

# # Create confidence interval column to display
data$`Cohen's d (95% CI)` <- ifelse(
    is.na(data$yi),
    "",
    sprintf("%.2f (%.2f to %.2f)", data$yi, data$ci.lb, data$ci.ub)
)

p <- forestploter::forest(
    data[, c(1:3, 7:8)],
    est = data$yi,
    lower = data$ci.lb,
    upper = data$ci.ub,
    ci_column = 4,
    ref_line = 0,
    xlim = c(-3, 3),
    ticks_at = c(-2, -1, 0, 1, 2),
    # footnote = "This is the demo data. Please feel free to change\nanything you want."
)

# Print plot
png("rplot.png", res = 300, width = 12, height = 50, units = "in")
plot(p)
dev.off()
# plot(p)
