# s.NBAYES.R
# ::rtemis::
# 2017 E.D. Gennatas lambdamd.org

#' Naive Bayes Classifier [C]
#'
#' Train a Naive Bayes Classifier using \code{e1071::naiveBayes}
#'
#' The \code{laplace} argument only affects categorical predictors
#'
#' @inheritParams s.GLM
#' @param laplace Float (>0): Laplace smoothing. Default = 0 (no smoothing). This only affects
#' categorical features
#' @return \link{rtMod} object
#' @author E.D. Gennatas
#' @family Supervised Learning
#' @export

s.NBAYES <- function(x, y = NULL,
                     x.test = NULL, y.test = NULL,
                     laplace = 0,
                     x.name = NULL,
                     y.name = NULL,
                     print.plot = TRUE,
                     plot.fitted = NULL,
                     plot.predicted = NULL,
                     plot.theme = getOption("rt.fit.theme", "lightgrid"),
                     question = NULL,
                     rtclass = NULL,
                     verbose = TRUE,
                     outdir = NULL,
                     save.mod = ifelse(!is.null(outdir), TRUE, FALSE), ...) {

  # Intro ====
  if (missing(x)) {
    print(args(s.NBAYES))
    invisible(9)
  }
  if (!is.null(outdir)) outdir <- normalizePath(outdir, mustWork = FALSE)
  logFile <- if (!is.null(outdir)) {
    paste0(outdir, "/", sys.calls()[[1]][[1]], ".", format(Sys.time(), "%Y%m%d.%H%M%S"), ".log")
  } else {
    NULL
  }
  start.time <- intro(verbose = verbose, logFile = logFile)
  mod.name <- "NBAYES"

  # Dependencies ====
  if (!depCheck("e1071", verbose = FALSE)) {
    cat("\n"); stop("Please install dependencies and try again")
  }

  # Arguments ====
  if (is.null(x.name)) x.name <- getName(x, "x")
  if (is.null(y.name)) y.name <- getName(y, "y")
  if (!verbose) print.plot <- FALSE
  verbose <- verbose | !is.null(logFile)
  if (!is.null(outdir)) outdir <- paste0(normalizePath(outdir, mustWork = FALSE), "/")

  # Data ====
  dt <- dataPrepare(x, y, x.test, y.test)
  x <- dt$x
  y <- dt$y
  x.test <- dt$x.test
  y.test <- dt$y.test
  xnames <- dt$xnames
  type <- dt$type
  checkType(type, "Classification", mod.name)
  if (verbose) dataSummary(x, y, x.test, y.test, type)
  if (print.plot) {
    if (is.null(plot.fitted)) plot.fitted <- if (is.null(y.test)) TRUE else FALSE
    if (is.null(plot.predicted)) plot.predicted <- if (!is.null(y.test)) TRUE else FALSE
  } else {
    plot.fitted <- plot.predicted <- FALSE
  }
  if (save.mod & is.null(outdir)) outdir <- paste0("./s.", mod.name)

  # NBAYES ====
  if (verbose) msg("Training Naive Bayes Classifier...", newline.pre = TRUE)
  mod <- e1071::naiveBayes(x, y,
                           laplace = laplace, ...)

  # Fitted ====
  fitted.prob <- predict(mod, x, type = "raw")
  fitted <- predict(mod, x, type = "class")
  error.train <- modError(y, fitted,
                          fitted.prob,
                          type = "Classification")
  if (verbose) errorSummary(error.train, mod.name)

  # Predicted ====
  predicted.prob <- predicted <- error.test <- NULL
  if (!is.null(x.test)) {
    predicted.prob <- predict(mod, x, type = "raw")
    predicted <- predict(mod, x.test, type = "class")
    if (!is.null(y.test)) {
      error.test <- modError(y.test, predicted,
                             predicted.prob,
                             type = "Classification")
      if (verbose) errorSummary(error.test, mod.name)
    }
  }

  # Outro====
  rt <- rtModSet(rtclass = "rtMod",
                 mod = mod,
                 mod.name = mod.name,
                 type = type,
                 parameters = list(laplace = laplace),
                 call = call,
                 y.train = y,
                 y.test = y.test,
                 x.name = x.name,
                 y.name = y.name,
                 xnames = xnames,
                 fitted = fitted,
                 fitted.prob = fitted.prob,
                 se.fit = NULL,
                 error.train = error.train,
                 predicted = predicted,
                 predicted.prob = predicted.prob,
                 se.prediction = NULL,
                 error.test = error.test,
                 varimp = numeric(),
                 question = question,
                 extra = NULL)

  rtMod.out(rt,
            print.plot,
            plot.fitted,
            plot.predicted,
            y.test,
            mod.name,
            outdir,
            save.mod,
            verbose,
            plot.theme)

  outro(start.time, verbose = verbose, sinkOff = ifelse(is.null(logFile), FALSE, TRUE))
  rt

} # rtemis::s.NBAYES
