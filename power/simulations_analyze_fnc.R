## Analyze a simulated data set as output from the simulate_dprime() function.


# Function to analyze a single data set:

analyze_simulation <- function(df) {

  # A few convenience functions
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
  # function to catch convergence issues
  converge <- function (fm) {
    message <- summary(fm)$optinfo$conv$lme4$messages
    if( is.null(message) ) { "" } else { message }
  }

  # factor coding
  df$condition <- contrast_cond(df$condition)
  df$language <- contrast_lang(df$language)

  # model fitting
  fm <- lmer(d ~ 1 + condition * language + (1 | participant), data = df)
  fm_conv <- converge(fm)

  fm_L1 <- lmer(
  	d ~ 1 + condition + (1 | participant),
  	data = df[df$language == "L1",]
  	)
  fm_L1_conv <- converge(fm_L1)

  fm_L2 <- lmer(
  	d ~ 1 + condition + (1 | participant),
  	data = df[df$language == "L2",]
  	)
  fm_L2_conv <- converge(fm_L2)

  # # Sanity check
  # print(coef(summary(fm)))
  # print(coef(summary(fm_L1)))
  # print(coef(summary(fm_L2)))

  # extract relevant output
  out <- data.frame(
  	beta_L1_true = unique(df$ES_L1_true),
  	model = rep(c("L1-L2", "L1-L2", "L1", "L2"), each = 3),
  	coef  = rep(c("congr", "lang_congr", "congr_L1", "congr_L2"), each = 3),
  	param = c("beta", "SE", "t"),
  	value = c(
  	  coef(summary(fm))[2,],
      coef(summary(fm))[4,],
      coef(summary(fm_L1))[2,],
      coef(summary(fm_L2))[2,]
  	  ),
  	# capture convergence issues
  	convergence = c(
  	  rep(fm_conv, 6),
  	  rep(fm_L1_conv, 3),
  	  rep(fm_L2_conv, 3)
  	  ),
  	stringsAsFactors = FALSE
  	)

  out
}

# Function to analyze many data sets, called with pmap
sim_many <- function(rseed, sim_id, ...) {
  set.seed(rseed)
  df <- simulate_dprime(...)
  result <- analyze_simulation(df)
  result$sim_id <- sim_id
  result
}
