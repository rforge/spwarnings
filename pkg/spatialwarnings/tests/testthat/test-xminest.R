
context('Test that xmin estimations are correct')

# We do not test on CRAN because this requires compilation of external code. 
TEST_XMIN <- FALSE
GRAPHICAL <- FALSE # Plot some diagnostics. 


if ( TEST_XMIN ) { 
  # Change dir if running tests manually
  if ( file.exists('./tests/testthat') ) { 
    library(testthat)
    setwd('./tests/testthat') 
  }

  # Setup pli from Clauzet et al's
  for ( s in dir('./pli-R-v0.0.3-2007-07-25', 
                full.names = TRUE, pattern = '*.R') ) { 
    source(s)
  }
  
  # Compile auxiliary binaries
  system("cd ./pli-R-v0.0.3-2007-07-25/zeta-function/ && make")
  system("cd ./pli-R-v0.0.3-2007-07-25/exponential-integral/ && make")
  system("cd ./pli-R-v0.0.3-2007-07-25/ && \
            gcc discpowerexp.c -lm -o discpowerexp && \
            chmod +x discpowerexp")
  
  test_that("xmins estimation is correct", { 
    

    parms <- expand.grid(expo = 1.5, 
                         rate = c(0.001, 0.005, 0.01, 0.1, 0.2, 0.3, 0.5, 
                                      0.7, 1, 1.2, 1.3, 1.4, 1.5, 1.7, 1.8, 2))
    
    estim_xmin <- function(df) { 
      
      pldat <- round(rpowerexp(10000, 1, df[ ,'expo'], df[, 'rate']))
      
      est_xmin <- suppressWarnings( spatialwarnings:::xmin_estim(pldat) )
      
      # Create pl object and estimate its xmin
      pl_obj <- poweRlaw::displ$new(pldat)
      est_xmin_plpkg <- poweRlaw::estimate_xmin(pl_obj)[["xmin"]]
      cat(est_xmin_plpkg, ' -> ', est_xmin, " [", 
          length(unique(pldat)), "]", "\n", sep = "")
      
      if ( !is.na(est_xmin) && !is.na(est_xmin_plpkg) ) { 
        # Note: In some pathological cases (few unique patches), there can be 
        # a small difference in xmin. So we have an acceptable error here. 
        expect_true( abs(est_xmin - est_xmin_plpkg) <= 2 )
        
        # In this case, inspect the fit provided by the poweRlaw package
        if ( GRAPHICAL && est_xmin != est_xmin_plpkg ) { 
          
          plot(log10(cumpsd(pldat[pldat >= est_xmin])))
          our_fit <- pl_fit(pldat, xmin = est_xmin)
          xs <- unique(round(seq(min(pldat), max(pldat), length.out = 100)))
          lines(log10(xs), 
                log10(ppl(xs, our_fit$expo, xmin = est_xmin)))
          title("OUR FIT")
          
          plot(log10(cumpsd(pldat[pldat >= est_xmin_plpkg])))
          plpkg_expo <- poweRlaw::estimate_xmin(pl_obj)$pars
          xs <- unique(round(seq(min(pldat), max(pldat), length.out = 100)))
          lines(log10(xs), 
                log10(ppl(xs, plpkg_expo, xmin = est_xmin_plpkg)))
          title("PWL FIT")
          
        }
      }
      
      data.frame(df, est_xmin = est_xmin)
    }
    
    if ( require(plyr) ) { 
      xmin_ests <- ddply(parms, ~ expo + rate, estim_xmin)
    }
    
  })


  # Remove auxiliary binaries now that tests are done
  system("cd ./pli-R-v0.0.3-2007-07-25/zeta-function/ && rm zeta_func zeta_func.o")
  system("cd ./pli-R-v0.0.3-2007-07-25/exponential-integral/ && rm exp_int exp_int.o")
  system("cd ./pli-R-v0.0.3-2007-07-25/ && rm discpowerexp")

} else { 
  message('Skipping xmin estimation testing')
}
