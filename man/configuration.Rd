% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/configuration.R
\name{configuration}
\alias{configuration}
\alias{as.matrix.QDConfiguration}
\title{Character Configuration}
\usage{
configuration(
  d,
  segment = c("Act", "Scene"),
  mode = c("Active", "Passive"),
  onlyPresence = FALSE
)

\method{as.matrix}{QDConfiguration}(x, ...)
}
\arguments{
\item{d}{A \code{QDDrama} object}

\item{segment}{A character vector, either "Act" or "Scene". Partial matching allowed.}

\item{mode}{Character vector, should be either "Active" or "Passive".
Passive configurations express when characters are mentioned, active
ones when they speak themselves. Please note that extracting passive 
configuration only makes sense if some form of coreference resolution 
has taken place on the text, either manually or automatic. If not, 
only very basic references (first person pronouns and proper names) are 
represented, which usually gives a very wrong impression.}

\item{onlyPresence}{If TRUE, the function only records whether a character was present. If FALSE (which is the default), the function counts the number of tokens spoken (active) or referenced (passive).}

\item{x}{An object of class QDConfiguration}

\item{...}{All other arguments are passed to \code{as.matrix.data.frame}.}
}
\value{
Drama configuration matrix as a \code{QDConfiguration} object (of type \code{data.frame}).
}
\description{
The function \code{configuration(...)} Creates drama configuration matrix as a \code{QDConfiguration} object, which is also a data.frame. The S3 function \code{as.matrix()} can be used to extract a numeric or logical matrix containing the core.
}
\section{Active and Passive Configurations}{

By default, we generate active matrices that are based on 
the character speech. A character is present in a scene or 
act, if they make an utterance. 
Using the argument \code{mode}, we can also create passive
configuration matrices. They look very similar, but are based
on who's mentioned in a scene or an act.
}

\examples{
# Active configuration matrix
data(rksp.0)
cfg <- configuration(rksp.0)

# Passive configuration matrix
cfg <- configuration(rksp.0, mode="Passive")

}
\seealso{
\code{\link{characterNames}}
}
