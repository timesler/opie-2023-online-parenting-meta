# opie-2023-online-parenting-meta

## Headlines

* Interventions have a significant impact on depression, parent self-efficacy, and social support. There was also a marginal impact observed on parent-child interaction, but this did not reach the 0.05 significance level.
    * For discussion possibly: Even though there was a clear lack of studies, that assessed dyadic outcomes, such as parent-child interaction, we still observed results that approached significance and would expect additional study and data in this area to highlight some true benefits.
* In terms of publication bias, only depression showed bias via an Egger's regression test. In addition, several other outcomes (anxiety, parent self-efficacy, and parent-child interaction) appear to show bias in their funnel plots under visual inspection, although this is of course subjective and was not corroborated by statistical tests.
* For the exp vs quasi sensitivity analysis, no outcomes showed significant sensitivity. I.e., there was not observed different between the measured impact of interventions from experiment and quasi-experimental studies.
* For the active vs inactive control group sensitivity analysis, significant difference were observed between the studies with each type of control for parent self-efficacy and social support. To estimate the impact of this on our overall results, the meta-analyses for these 2 outcomes were re-run using only studies with inactive controls. This yielded minor increases in the intervention vs control effect, however there was no change to significance as both outcomes were already significant without removal of active controls.
* A meta-regression to examine how effects are sustained over time post-intervention included post-intervention assessment interval yielded no significant change to intervention effects over time. 


## Notes

* Positive Cohen's d are bad for anxiety, depression and stress, and good for the other outcomes.

## Comparing follow-up periods (0-3 mos, 4-6 mos, 6-24 mos) 

### 0-3 months vs. 4-6 months: ns difference
```
Welch Two Sample t-test
t = -1.3005, df = 24.226, p-value = 0.2057

95 percent confidence interval:
    -1.1910181  0.2699693
sample estimates:
    mean of x   mean of y
    0.8718541   1.3323785
```

### 0-3 months vs. 6-24 months: sig difference
```
Welch Two Sample t-test
t = 3.3604, df = 63.951, p-value = 0.001316

95 percent confidence interval:
    0.2954842 1.1618684
sample estimates:
    mean of x   mean of y
    0.8718541   0.1431778
```

### 4-6 months vs. 6-24 months: sig difference
```
Welch Two Sample t-test
t = 3.2107, df = 27.829, p-value = 0.003329

95 percent confidence interval:
    0.4302972 1.9481043
sample estimates:
    mean of x   mean of y
    1.3323785   0.1431778
```