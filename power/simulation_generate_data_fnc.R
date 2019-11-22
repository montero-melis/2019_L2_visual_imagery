# Function to simulate data for the power analysis of L2 visual imagery study.
# It is called/sourced from a separate script.

library("mvtnorm")
library("tidyverse")

# The function generates normally distributed data from the generative model
# we will assume for our study. Note that we model d' scores directly, rather
# than trial-level data.
# Parameters that go into this function will be taken from our re-analysis of
# data from similar designs (e.g., Lupyan and Ward, 2013).

simulate_dprime <- function (
  Nsubj,    # Number of participants
  b0,       # intercept
  b_L1,     # congruency effect in the L1
  b0_SE,    # SEM for interecept
  b_L1_SE,  # SEM for L1 congruency effect
  uncertainty_critical_beta = TRUE,  # model the uncertainty (SEM) for critical b_L1?
  L2_effect,     # proportion of the effect in the L1, e.g. 0.5 for half the ES in L1
  rand_subj_sd,  # random variability by subject (interecept only) in SD
  resid_error,   # residual error
  print_each_step = FALSE   # print output at each step to unveil inner workings
  ) {

  myprint <- function(x) {
    if (print_each_step) {
      cat("\n"); print(paste("This is:", deparse(substitute(x)))); cat("\n")
      print(x)
      }
    }

  # 1) create design matrix X for experiment
  # The factors are crossed (2x2 design)
  myfactors <- data.frame(
    condition = factor(rep(c("congruent", "incongruent"), each = 2)),
    language  = factor(c("L1", "L2"))
    )
  # We use a coding scheme that makes matrix calculation easy
  contrasts(myfactors$condition) <- contr.sum(2)
  contrasts(myfactors$language)  <- contr.treatment(2)
  # Generate model matrix for the 2x2 factorial design
  X <- model.matrix(~ 1 + condition * language, myfactors)
  # sensible column names for clarity when looking at this in the future
  colnames(X)[2:4] <- c("congr_incongr_L1", "L2", "congr_incongr_L1:L2")
  myprint(X)
  # Remove attributes to avoid warnings with left_join() later on:
  attr(myfactors$condition, "contrasts") <- NULL
  attr(myfactors$language, "contrasts") <- NULL
  myprint(myfactors)

  # 2) Create data frame that will contain the simulated data
  n_obs <- Nsubj * nrow(myfactors)  # total number of observations (or #rows)
  data <- tidyr::expand(myfactors, condition, language, participant = 1 : Nsubj) %>%
    select(participant, language, condition) %>%
    arrange(participant, language, condition)
  myprint(data)

  # 3) Fixed effects in this simulation
  # 3a) Sample fixef for current simulation from estimates and SEMs
  b0 <- rnorm(1, b0, b0_SE)
  if (uncertainty_critical_beta) {
    b_L1 <- rnorm(1, b_L1, b_L1_SE)
  }
  # 3b) Now add the fixef estimates for the design with L2 condition
  # Amount by which we need to correct the L2 effect wrt L1 effect, e.g. if the
  # L2 effect is 0.75 that in the L1, we need to subtract 0.25 of the L1 effect
  # in the L2 condition (this is what the following line does):
  L2_correction <- - (1 - L2_effect) * b_L1
  # Put it all together. The zero refers to the main effect of L2:
  fixef <- c(b0, b_L1, 0, L2_correction)
  # To clarify (and consistent with the model matrix X above):
  names(fixef) <- c("Intercept", "congr_incongr_L1", "L2", "congr_incongr_L1:L2")
  myprint(fixef)
  # 3c) Save fixed effects as df for output
  fixef_df <- tibble(coef = names(fixef), betas = fixef)
  myprint(fixef_df)
  # 3c) Join fixed effects with data
  fixef_cell_means <- X %*% fixef  # fixed effects in each experimental cell
  myprint(fixef_cell_means)
  fixef_cell_means_df <- myfactors %>% add_column(fixef = as.vector(fixef_cell_means))
  myprint(fixef_cell_means_df)
  data <- left_join(data, fixef_cell_means_df)
  myprint(data)

  # 4) By-subject adjustments (normal with mean zero and SD from random effects)
  # 4a) Each matrix row gives subject adjustments for betas of the 4 predictors in X
  subj_adjust <- rnorm(
    n = Nsubj,
    mean = 0,
    sd = rand_subj_sd
    )
  myprint(subj_adjust)
  # 4b) Save as df for output
  subj_adj_df <- tibble(
    participant = 1 : Nsubj,
    subj_adjust = subj_adjust
    )
  myprint(subj_adj_df)
  # 4c) Join with data:
  data <- left_join(data, subj_adj_df)
  myprint(data)

  # 5) Add residual error to each observation
  data$resid <- rnorm(n = nrow(data), sd = resid_error)
  myprint(data)

  # 6) compute the DV = d'
  data <- data %>% mutate(d = fixef + subj_adjust + resid)

  # Add also information about effect size of critical effect
  data$ES_L1 <- b_L1
  data$ES_L2_prop_L1 <- L2_effect

  data
}
