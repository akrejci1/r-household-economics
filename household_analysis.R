library(readxl)
library(lmtest)
library(sandwich)
library(car)
library(tseries)
library(mfx)


rm(list = ls())
cat("\014")

data <- read_excel("kk2003.xlsx")


# 1: The role of work and time for housework
data$h_total <- data$hm + data$hf
summary(data$h_total)
sd(data$h_total)

model1 <- lm(h_total ~ mjob + fjob + hown + nrych + nli + 
               mage + fage + med + fed + fs + nrcrs, 
             data = data)

summary(model1)

jarque.bera.test(residuals(model1))
bptest(model1)
coeftest(model1, vcov = vcovHC(model1, type = "HC3"))
vif(model1)
resettest(model1)

coef_robust <- coeftest(model1, vcov = vcovHC(model1, type = "HC3"))
coef_robust

linearHypothesis(model1, "mjob = fjob", vcov = vcovHC(model1, type = "HC3"))
linearHypothesis(model1, "mage = fage", vcov = vcovHC(model1, type = "HC3"))

# 2: Modified model

#New dataset
data2 <- data[data$nli > 0 & data$h_total > 0, ]
data2$log_h_total <- log(data2$h_total)
data2$log_nli <- log(data2$nli)

#Model2
model2 <- lm(log_h_total ~ mjob + fjob + hown + nrych + log_nli + 
               mage + fage + med + fed + fs + nrcrs, 
             data = data2)

summary(model2)

#Diagnostics
bptest(model2)
vif(model2)
resettest(model2)

coef_robust2 <- coeftest(model2, vcov = vcovHC(model2, type = "HC3"))
coef_robust2

#Elasticity Model2
elasticity_model2 <- coef(model2)["log_nli"]
elasticity_model2

#Elasticity Model1 original dataset
beta_nli <- coef(model1)["nli"]
mean_nli <- mean(data$nli, na.rm = TRUE)
mean_h   <- mean(data$h_total, na.rm = TRUE)

elasticity_model1  <- beta_nli * (mean_nli / mean_h)
elasticity_model1

#Elasticity Model1 new dataset
model1_sub <- lm(h_total ~ mjob + fjob + hown + nrych + nli + 
                   mage + fage + med + fed + fs + nrcrs, data = data2)

summary(model1_sub)

beta_nli_sub <- coef(model1_sub)["nli"]
elasticity_model1_sub <- beta_nli_sub * (mean(data2$nli) / mean(data2$h_total))
elasticity_model1_sub

# 3: Hypothesis testing

#Model 3
model3 <- lm(h_total ~ mjob + fjob + hown + nrych + fs, 
                     data = data)

summary(model3)
coef_robust3 <- coeftest(model3, vcov = vcovHC(model3, type = "HC3"))
coef_robust3

bptest(model3)
resettest(model3)

#Theory 2 data
data$nli_hown <- data$nli * data$hown

#Theory 3 data
mean_med <- mean(data$med)
mean_fed <- mean(data$fed)

data$high_edu <- ifelse(data$med > mean_med & data$fed > mean_fed, 1, 0)

data$nli_high_edu <- data$nli * data$high_edu
data$nli_hown_high_edu <- data$nli * data$hown * data$high_edu

#Model3_full
model3_full <- lm(h_total ~ mjob + fjob + hown + nrych + fs + 
                    nli + 
                    nli_hown + 
                    high_edu + 
                    nli_high_edu + 
                    nli_hown_high_edu,
                  data = data)

summary(model3_full)
coef_robust3_full <- coeftest(model3_full, vcov = vcovHC(model3_full, type = "HC3"))
coef_robust3_full

#Diagnostics 
bptest(model3_full)
resettest(model3_full)

# 4: Net hourly wage for men

#Data preparation
data$edu_cat <- ifelse(data$med <= 8, 1,
                       ifelse(data$med <= 12, 2, 3))

data$edu_secondary <- ifelse(data$med >= 9 & data$med <= 12, 1, 0)
data$edu_tertiary <- ifelse(data$med >= 13, 1, 0)

#Model 4a
model4a <- lm(wm ~ edu_cat + mage, data = data)
summary(model4a)
coeftest(model4a, vcov = vcovHC(model4a, type = "HC3"))

#Model 4b dummies
model4b <- lm(wm ~ edu_secondary + edu_tertiary + mage, data = data)
summary(model4b)
coeftest(model4b, vcov = vcovHC(model4b, type = "HC3"))

#Diagnostics
bptest(model4a)
bptest(model4b)
resettest(model4a)
resettest(model4b)


model4_null <- lm(wm ~ mage, data = data)
anova(model4_null, model4b)

linearHypothesis(model4b, "edu_secondary = edu_tertiary",
                 vcov = vcovHC(model4b, type = "HC3"))

model4a_int <- lm(wm ~ edu_cat * mage, data = data)
summary(model4a_int)
coeftest(model4a_int, vcov = vcovHC(model4a_int, type = "HC3"))

model4b_int <- lm(wm ~ edu_secondary * mage + edu_tertiary * mage, 
                  data = data)
summary(model4b_int)
coeftest(model4b_int, vcov = vcovHC(model4b_int, type = "HC3"))

linearHypothesis(model4b_int, 
                 c("edu_secondary:mage = 0", "mage:edu_tertiary = 0"), 
                 vcov = vcovHC(model4b_int, type = "HC3"))

resettest(model4a_int)
resettest(model4b_int)

#5 

# Data restructurization
data_male <- data.frame(
  w = data$wm, age = data$mage, edu = data$med, job = data$mjob,
  female = 0, hown = data$hown, nrych = data$nrych, nli = data$nli, fs = data$fs
)

data_female <- data.frame(
  w = data$wf, age = data$fage, edu = data$fed, job = data$fjob,
  female = 1, hown = data$hown, nrych = data$nrych, nli = data$nli, fs = data$fs
)

data_pooled <- rbind(data_male, data_female)

# Centering education
data_pooled$edu_centered <- data_pooled$edu - mean(data_pooled$edu)
data_pooled$edu_centered_sq <- data_pooled$edu_centered^2

# Model 5
model5 <- lm(w ~ female + age + female:age + 
               edu_centered + edu_centered_sq + 
               job + hown + nrych + nli + fs,
             data = data_pooled)

# Diagnostics
bptest(model5)
resettest(model5)
vif(model5)

# Results
summary(model5)
coeftest(model5, vcov = vcovHC(model5, type = "HC3"))
linearHypothesis(model5, c("female=0", "female:age=0"), vcov = vcovHC(model5, type = "HC3"))

# 6 What influences home ownership?
data_pooled$age_sq <- data_pooled$age^2

# Linear model
lpm_full <- lm(hown ~ age + age_sq + edu + job + nrych + nli + fs + female, data = data_pooled)
lpm_final <- step(lpm_full, trace = 0)

# Results
coeftest(lpm_final, vcov = vcovHC(lpm_final, type = "HC3"))
summary(lpm_final)

#Diagnostics
bptest(lpm_final)
resettest(lpm_final)
vif(lpm_final)

#Logit Model
logit_full <- glm(hown ~ age + age_sq + edu + job + nrych + nli + fs + female, 
                  family = binomial(link = "logit"), data = data_pooled)
logit_final <- step(logit_full, trace = 0)

#Results logit
coeftest(logit_final, vcov = vcovHC(logit_final, type = "HC3"))


#Quality of logit model
1 - (logit_final$deviance / logit_final$null.deviance)

#Accuracy
mean((fitted(logit_final) > 0.5) == data_pooled$hown)

#AME and Standard Errors
logitmfx(formula(logit_final), data = data_pooled)
