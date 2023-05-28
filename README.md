# opie-2023-online-parenting-meta

## Headlines

* Interventions have a significant impact on anxiety, depression, and parent self-efficacy. There was also a marginal impact observed on parent-child interaction, but this did not reach the 0.05 significance level. Additionally, a sensitivity analysis demonstrated that results for self-efficacy and social support are significantly impacted by the presence of both inactive and active controls in the included data. Additional analysis of social support for only studies with inactive controls yielded a significant impact due to online UPPs.
    * For discussion possibly: Even though there was a clear lack of studies that assessed dyadic outcomes, such as parent-child interaction, we still observed results that approached significance and would expect additional study and data in this area to highlight some true benefits.
* Based on Egger's regression test, no outcomes demonstrated evidence of publication bias. 
* For the exp vs quasi sensitivity analysis, a significant difference was observed for parent satisfaction between studies with experimental and quasi-experimental designs. 
* For the active vs inactive control group sensitivity analysis, significant differencea were observed between the studies with each type of control for parent self-efficacy and social support. To estimate the impact of this on our overall results, the meta-analyses for these 2 outcomes were re-run using only studies with inactive controls. This yielded minor increases in the intervention vs control effect, resulting in social support becoming significant.
* A set time-binned group comparisons performed using t-tests (see below) did find some interesting significance. 


## Notes

* Positive Cohen's d are bad for anxiety, depression and stress, and good for the other outcomes.

# Aggregated (i.e., not outcome-specific) Moderator Analyses

## Follow-up periods (0-3 mos, 4-6 mos, 6-24 mos) 

### 0-3 months vs. 4-6 months: ns difference
```
Welch Two Sample t-test

t = 1.287, df = 51.633, p-value = 0.2038

95 percent confidence interval:
 -0.07869797  0.36003405
sample estimates:
mean of x mean of y
0.4697918 0.3291238
```

### 0-3 months vs. 6-24 months: sig difference
```
Welch Two Sample t-test

t = 5.1839, df = 78.65, p-value = 0.000001642

95 percent confidence interval:
 0.3411107 0.7663765
sample estimates:
  mean of x   mean of y
 0.46979185 -0.08395176
```

### 4-6 months vs. 6-24 months: sig difference
```
Welch Two Sample t-test

t = 3.6689, df = 42.959, p-value = 0.0006677

95 percent confidence interval:
 0.1860115 0.6401397
sample estimates:
  mean of x   mean of y
 0.32912381 -0.08395176
```

## Sex (Proportion Female)

```
RVE: Correlated Effects Model with Small-Sample Corrections 

Model: Cohen's d (sign adj.) ~ prop_female

Number of studies = 22
Number of outcomes = 133 (min = 1 , mean = 6.05 , median = 4.5 , max = 15 )
Rho = 0.8
I.sq = 94.58692
Tau.sq = 0.3587194

               Estimate StdErr t-value  dfs P(|t|>) 95% CI.L 95% CI.U Sig
1 X.Intercept.    0.974  0.473    2.06 2.88   0.136   -0.568    2.515
2  prop_female   -0.663  0.521   -1.27 3.60   0.279   -2.174    0.847
---
Signif. codes: < .01 *** < .05 ** < .10 *
---
```

Relevant p-value is 0.279 (not significant)

## Guidance (Fully vs Partially Self-Guided)

```
RVE: Correlated Effects Model with Small-Sample Corrections 

Model: Cohen's d (sign adj.) ~ guidance

Number of studies = 22
Number of outcomes = 133 (min = 1 , mean = 6.05 , median = 4.5 , max = 15 )
Rho = 0.8
I.sq = 94.88055
Tau.sq = 0.3978489

                      Estimate StdErr t-value   dfs P(|t|>) 95% CI.L 95% CI.U
1        X.Intercept.    0.668  0.228    2.93  8.89   0.017    0.151   1.1845
2 guidanceSelf.guided   -0.477  0.256   -1.86 19.00   0.078   -1.012   0.0588
  Sig
1  **
2   *
---
Signif. codes: < .01 *** < .05 ** < .10 *
---
```

Relevant p-value is 0.078 (not significant)
