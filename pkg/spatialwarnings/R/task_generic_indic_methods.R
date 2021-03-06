# TODO: summary methods for single and list
# 
# This file contains common methods (plot/print/summary/as.data.frame) used for 
#   generic indicators objects (without significance assessment). 
# 





# Plot methods
# --------------------------------------------------



# NOTE: we do not document the args as they are already included by another
#   function in the generic_sews doc file
#  
#' @rdname generic_sews
#' 
#' @param x A \code{generic_sews} object (as provided by the 
#'   \code{generic_sews} function). 
#' 
#' @param along A vector providing values over which the indicator trend 
#'   will be plotted. If \code{NULL} then the values are plotted sequentially 
#'   in their original order. 
#' 
#' @details Note that the produced plot is adjusted depending on whether 
#'   \code{along} is numeric or not. 
#' 
#' 
#' @method plot generic_sews
#' @export
plot.generic_sews <- function(x, along = NULL, ...) { 
  if ( 'generic_sews_single' %in% class(x) ) { 
    stop('I cannot plot a trend with only one value !')
  }
  
  new_data <- as.data.frame(x)
  plot.generic_sews_test(new_data, along, display_null = FALSE)
}





# Print and Summary methods
# --------------------------------------------------

# This function works for both list and single object
#'@export
summary.generic_sews <- function(object, ...) { 
  
  cat('Generic Spatial Early-Warnings\n') 
  cat('\n')
  
  display_size_info(object)
  cat('\n')
  
  # Format output table
  output <- as.data.frame(object)
  output <- reshape2::dcast(output,  replicate ~ indicator, value.var = 'value')
  names(output) <- c('Mat. #', 'Mean', 'Moran\'s I', 'Skewness', 'Variance')
  
  print.data.frame(output, row.names = FALSE, digits = DIGITS)
  cat('\n')
  cat('Use as.data.frame() to retrieve values in a convenient form\n')
}

# Print is currently identical to summary()
#'@export
print.generic_sews <- function(x, ...) { 
  summary.generic_sews(x, ...)
}



# As data.frame methods
# --------------------------------------------------

#'@export
as.data.frame.generic_sews_list <- function(x, ...) { 
  
  df <- plyr::ldply(x, function(x) { as.data.frame(x[['results']]) })
  df[ ,'replicate'] <- seq.int(length(x))
  
  # Extract and reorder the data.frame
  df <- df[ ,c('replicate', 'mean', 'moran', 'skewness', 'variance')]
  tidyr::gather_(df, 'indicator', 'value', 
                 c('mean', 'moran', 'skewness', 'variance'), 
                 factor_key = TRUE)
}

#'@export
as.data.frame.generic_sews_single <- function(x, ...) { 
  as.data.frame.generic_sews_list(list(x))
}

