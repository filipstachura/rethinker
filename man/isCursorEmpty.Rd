% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/cursor.R
\name{isCursorEmpty}
\alias{isCursorEmpty}
\title{Check if cursor is empty}
\usage{
isCursorEmpty(cursor)
}
\arguments{
\item{cursor}{Cursor to check; a result of \code{r()$...$run(...)}.}
}
\value{
\code{TRUE} if cursor has no more data to return.
}
\description{
Check whether a given cursor is fully drained and will output no more datum.
The function never blocks; also verifies that the underlying connection is useful.
}
\note{
It is possible that \code{\link{cursorNext}} will return \code{NULL} just after \code{isCursorEmpty} returns \code{FALSE}.
Changefeeds cursors (made with \code{r()$...$changes()$...}) will never become empty (provided that connection won't become broken).
}
\author{
Miron B. Kursa
}
