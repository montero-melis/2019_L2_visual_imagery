## Analyze a simulated data set as output from the simulate_dprime() function.

# Get the coding scheme right:
contrast_lang <- function(v) {
  myfactor <- factor(v, levels = c("L1", "L2"))
  contrasts(myfactor) <- contr.sum(2)
  colnames(contrasts(myfactor)) <- "L1_L2"
  myfactor
  }

contrast_cond <- function(v) {
  myfactor <- factor(v, levels = c("congruent", "incongruent"))
  contrasts(myfactor) <- contr.sum(2)
  colnames(contrasts(myfactor)) <- "congr_incongr"
  myfactor
  }

analyze_simulation <- function(df) {
  # factor coding
  df$condition <- contrast2(df$condition)
  df$language <- contrast2_lang(df$language)
  # model fitting
  fm <- lmer(d ~ 1 + condition * language + (1 | participant), data = df)
  fm_L1 <- lmer(
  	d ~ 1 + condition + (1 | participant),
  	data = df[df$language == "L1",]
  	)
  fm_L2 <- lmer(
  	d ~ 1 + condition + (1 | participant),
  	data = df[df$language == "L2",]
  	)

  # # Sanity check
  # print(coef(summary(fm)))
  # print(coef(summary(fm_L1)))
  # print(coef(summary(fm_L2)))
  
  # extract relevant output
  out <- data.frame(
  	model = rep(c("L1-L2", "L1-L2", "L1", "L2"), each = 3),
  	coef  = rep(c("congr", "lang_congr", "congr_L1", "congr_L2"), each = 3),
  	param = c("beta", "SE", "t"),
  	value = c(
  	  coef(summary(fm))[2,],
      coef(summary(fm))[4,],
      coef(summary(fm_L1))[2,],
      coef(summary(fm_L2))[2,]
  	  )
  	)
  out
}
