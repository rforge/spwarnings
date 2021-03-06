% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/task_custom_spews.R,
%   R/task_custom_spews_indictest.R
\name{create_indicator}
\alias{create_indicator}
\alias{custom_indicator}
\alias{plot.custom_sews_list}
\alias{indictest.custom_sews}
\alias{plot.custom_sews_test}
\title{Custom Spatial Early-Warning signals}
\usage{
create_indicator(fun, fun.name = as.character(substitute(fun)))

custom_indicator(mat, fun, fun.name = as.character(substitute(fun)), ...)

\method{plot}{custom_sews_list}(x, along = NULL, ...)

\method{indictest}{custom_sews}(x, nperm = 999, ...)

\method{plot}{custom_sews_test}(x, along = NULL, what = "value",
  display_null = TRUE, ...)
}
\arguments{
\item{fun}{A function that takes a real-valued matrix as input and returns 
a single, numerical value.}

\item{fun.name}{The indicator name. Optional, used for plots and textual 
summaries, but mandatory if \code{fun} is an anonymous function.}

\item{mat}{A matrix or a list of matrices.}

\item{...}{Ignored}

\item{x}{A \code{custom_sews} object (as provided by the 
custom indicator function created by \code{create_indicator}).}

\item{along}{A vector providing values over which the indicator trend 
will be plotted. If \code{NULL} then the values are plotted sequentially 
in their original order.}

\item{nperm}{The number of replicates to use to compute use in the 
null distribution}

\item{what}{The trendline to be displayed. Defaults to the indicator's 
values ("value") but other metrics can be displayed. Correct values are 
"value", "pval" or "z_score".}

\item{display_null}{Chooses whether a grey ribbon should be added to reflect
the null distribution. Note that it can not be displayed when the trend 
line reflects something else than the indicator values (when \code{what} 
is not set to "value").}
}
\value{
\code{create_indicator} returns a function that can be used in the same way 
  than the other \code{*_sews} functions (e.g. \code{generic_sews})
}
\description{
Computation, significance assessment and display of trends 
  of a custom, user-defined indicator.
}
\details{
Spatial Early-warning signals (EWS) are metrics that are based on the 
  spatial structure of a system and measure the degradation of an ecological 
  system. The package \code{spatialwarnings} provides 
  generic indicators (\code{\link{generic_sews}}), spectrum-based 
  indicators (\code{\link{spectral_sews}}) and indicators based on patch 
  size distributions (\code{\link{patchdistr_sews}}). 
  
\code{create_indicator} extends the package to any arbitrary function. 
  It takes a function `fun` and returns another function that can be used 
  as an indicator similar to the \code{*_sews} function family. The 
  results of this function can be assessed for significance using 
  \code{indictest} and trends can be displayed using 
  \code{plot}, \code{summary}, etc. (see Examples). \code{custom_indicator} 
  does the same but without creating an intermediate indicator function. 

\code{fun} should be a function that takes as input a matrix and possibly
  more arguments, and return a single numeric value. Note that the matrix 
  is converted internally to numeric values, as a side effect of using 
  c++ code when assessing significance. When working with logical matrices 
  (e.g. when computing patch size distributions), the matrix has to be 
  explicitely converted to logical within function `fun`.
}
\examples{

# Use the maximum patch size as indicator of degradation
maxpatchsize <- function(mat) { 
  # Note that we explicitely convert mat here to logical as it can be 
  # transformed into numeric internally. 
  max(patchsizes(mat > 0))
}

# Create the indicator function
maxpatch_sews <- create_indicator(maxpatchsize)

# Then work with this function as if it were a function from the *_sews 
# family. 
mp_indic <- maxpatch_sews(forestgap)
summary(mp_indic)

\dontrun{ 
# Assess significance and display trends
options(mc.cores = 2)
mp_test <- indictest(mp_indic, nperm = 49)
plot(mp_test)
}



# Try spatial coefficient of variation as a spatial EWS. This function can 
# have arguments. 
spatial_cv <- function(mat, subsize) { 
  matc <- coarse_grain(mat, subsize)
  return( sd(matc) / mean(matc) )
}

# Create indicator function
cv_sews <- create_indicator(spatial_cv)

# Compute and display trends
cv_indic <- cv_sews(serengeti, subsize = 3)
plot(cv_indic, along = serengeti.rain)

# We can do the same work in one run using custom_indicator
cv_indic2 <- custom_indicator(serengeti, spatial_cv, subsize = 3)
plot(cv_indic2, along = serengeti.rain)

\dontrun{ 
indictest(cv_indic, nperm = 99)
}
}
