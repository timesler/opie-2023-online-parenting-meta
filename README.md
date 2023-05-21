# opie-2023-online-parenting-meta

## Headlines

* Interventions have a significant impact on depression, parent self-efficacy, and social support. There was also a marginal impact observed on parent-child interaction, but this did not reach the 0.05 significance level.
    * For discussion possibly: Even though there was a clear lack of studies, that assessed dyadic outcomes, such as parent-child interaction, we still observed results that approached significance and would expect additional study and data in this area to highlight some true benefits.
* In terms of publication bias, only depression showed bias via an Egger's regression test. In addition, several other outcomes (anxiety, parent self-efficacy, and parent-child interaction) appear to show bias in their funnel plots under visual inspection, although this is of course subjective and was not corroborated by statistical tests.
* For the exp vs quasi sensitivity analysis, no outcomes showed significant sensitivity. I.e., there was not observed different between the measured impact of interventions from experiment and quasi-experimental studies.
* For the active vs inactive control group sensitivity analysis, significant difference were observed between the studies with each type of control for parent self-efficacy and social support. To estimate the impact of this on our overall results, the meta-analyses for these 2 outcomes were re-run using only studies with inactive controls. This yielded minor increases in the intervention vs control effect, however there was no change to significance as both outcomes were already significant without removal of active controls.
* ~~A meta-regression to examine how effects are sustained over time post-intervention yielded no significant change to intervention effects over time.~~ A set time-binned group comparisons performed using t-tests (see below) did find some interesting significance. 


## Notes

* Positive Cohen's d are bad for anxiety, depression and stress, and good for the other outcomes.

# Aggregated (i.e., not outcome-specific) Moderator Analyses

## Follow-up periods (0-3 mos, 4-6 mos, 6-24 mos) 

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

## Sex (Proportion Female)

```
RVE: Correlated Effects Model with Small-Sample Corrections 

Model: Cohen's d (sign adj.) ~ prop_female

Number of studies = 22
Number of outcomes = 133 (min = 1 , mean = 6.05 , median = 4.5 , max = 15 )
Rho = 0.8
I.sq = 97.03289
Tau.sq = 0.7114448

               Estimate StdErr t-value  dfs P(|t|>) 95% CI.L 95% CI.U Sig
1 X.Intercept.    0.853  0.528   1.615 2.70   0.214   -0.936     2.64
2  prop_female   -0.119  0.641  -0.185 3.39   0.864   -2.031     1.79
---
Signif. codes: < .01 *** < .05 ** < .10 *
---
```

## Guidance (Fully vs Partially Self-Guided)

```
RVE: Correlated Effects Model with Small-Sample Corrections 

Model: Cohen's d (sign adj.) ~ guidance

Number of studies = 22
Number of outcomes = 133 (min = 1 , mean = 6.05 , median = 4.5 , max = 15 )
Rho = 0.8
I.sq = 97.11806
Tau.sq = 0.7688304

                      Estimate StdErr t-value   dfs P(|t|>) 95% CI.L 95% CI.U
1        X.Intercept.    1.029  0.254    4.06  8.95 0.00289    0.455    1.604
2 guidanceSelf.guided   -0.503  0.406   -1.24 19.14 0.23066   -1.353    0.347
  Sig
1 ***
2
---
Signif. codes: < .01 *** < .05 ** < .10 *
---
```
