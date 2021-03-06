#' @title Word frequencies 
#' @description The function \code{frequencytable()} generates a matrix of word frequencies 
#' by drama, act or scene and/or by character. The output of this function can be fed to stylo.
#' @param drama A \code{QDDrama}. May be covering multiple texts.
#' @param acceptedPOS A list of accepted pos tags. Words of all POS tags not in this list 
#' are filtered out. Specify NULL or an empty list to include all words.
#' @param byCharacter Logical. Whether the count is by character or by text.
#' @param segment Character vector. Whether the count is by drama (default), act or scene
#' @param column The column name we should use (should be either Token.surface or Token.lemma)
#' @param sep The separation symbol that goes between drama name and character (if applicable). 
#' Defaults to the pipe symbol.
#' @param normalize Whether to normalize values or not. If set to TRUE, the values are normalized by
#' row sums.
#' @param sortResult Logical. If true, the columns with the highest sum are ordered left (i.e., frequent words are visible first). If false, the columns are ordered alphabetically by column name.
#' @return Matrix of word frequencies in the format words X segments
#' @rdname frequencyTable
#' @seealso \code{stylo}
#' @importFrom stats xtabs ftable
#' @examples
#' data(rksp.0)
#' st <- frequencytable(rksp.0)
#' @export
frequencytable <- function(drama, 
                           acceptedPOS = postags$de$words,
                           column="Token.lemma", 
                           byCharacter=FALSE, 
                           sep="|", 
                           normalize=FALSE, 
                           sortResult=FALSE, 
                           segment=c("Drama", "Act", "Scene")) {
  stopifnot(inherits(drama, "QDDrama"))
  
  segment <- match.arg(segment)
  
  ft <- switch(segment,
               Drama=drama$text,
               Act=segment(drama$text, drama$segments),
               Scene=segment(drama$text, drama$segments))
  
  
  if (length(acceptedPOS) > 0)
    ft <- ft[as.character(ft$Token.pos) %in% acceptedPOS,]
  
  segment <- match.arg(segment)
  switch(segment,
         Drama = { 
           if (byCharacter == FALSE) { xt <- stats::xtabs(~drama + ft[,get(column)], data=ft) }
           else { xt <- stats::xtabs(~ paste(drama,Speaker.figure_id,sep=sep) + ~ft[,get(column)], data=ft) }
         },
         Act = {
           if (byCharacter == FALSE) { xt <- stats::xtabs(~ paste(drama,Number.Act,sep=sep) + ~ft[,get(column)], data=ft) }
           else { xt <- stats::xtabs(~ paste(drama,Number.Act,Speaker.figure_id,sep=sep) + ~ft[,get(column)], data=ft) }
         },
         Scene = {
           if (byCharacter == FALSE) { xt <- stats::xtabs(~ paste(drama,Number.Act,Number.Scene,sep=sep) + ~ft[,get(column)], data=ft) }
           else { xt <- stats::xtabs(~ paste(drama,Number.Act,Number.Scene,Speaker.figure_id,sep=sep) + ~ft[,get(column)], data=ft) }
         },
         stop("Please enter valid string-value for argument 'segment' (default = 'Drama', 'Act' or 'Scene').")
  )
  
  r <- as.matrix(stats::ftable(xt, row.vars = c(), col.vars = c()))
  
  if (normalize == TRUE) {
    r <- t(apply(r,1,function(x) { x / sum(x)}))
  } 
  
  if (sortResult == TRUE) {
    r <- r[,order(colSums(r),decreasing = TRUE),drop = FALSE]
  } else {
    r <- r[, order(colnames(r)) ,drop = FALSE]
  }
  
  class(r) <- append(class(r), switch(segment, 
                                      Drama = "QDByDrama",
                                      Act   = "QDByAct",
                                      Scene ="QDByScene"))
  
  r
}


#' Extract bigrams instead of words (currently not taking utterance boundaries into account)
#' @param t The text
#' @param acceptedPOS A list of accepted pos tags
#' @param names Whether to use character names or ids
#' @param byCharacter Wether the count is by character or by text
#' @param segment Whether the count is by drama (default), act or scene
#' @param column The column names we should use (should be either Token.surface or Token.lemma)
#' @return Matrix of bigram frequencies in the format bigrams X segments
#' @keywords internal
frequencytable2 <- function(t, acceptedPOS = postags$de$words, names=FALSE, column=c("Token.surface", "Token.surface"), byCharacter=FALSE, segment=c("Drama","Act","Scene")) {
  ft <- t
  if (length(acceptedPOS) > 0) {
    ft <- t[t$Token.pos %in% acceptedPOS,]
  }
  by <- match.arg(segment)
  switch(by,
         Drama = { 
           if (byCharacter == FALSE) { index <- paste(ft$drama) }
           else if (names == TRUE) { index <- paste(ft$drama, ft$Speaker.figure_surface) }
           else { index <- paste(ft$drama, ft$Speaker.figure_id) }
         },
         Act = {
           if (byCharacter == FALSE) { index <- paste(ft$drama, ft$Number.Act) }
           else if (names == TRUE) { index <- paste(ft$drama, ft$Number.Act, ft$Speaker.figure_surface) }
           else { index <- paste(ft$drama, ft$Number.Act, ft$Speaker.figure_id) }
         },
         Scene = {
           if (byCharacter == FALSE) { index <- paste(ft$drama, ft$Number.Act, ft$Number.Scene) }
           else if (names == TRUE) { index <- paste(ft$drama, ft$Number.Act, ft$Number.Scene, ft$Speaker.figure_surface) }
           else { index <- paste(ft$drama, ft$Number.Act, ft$Number.Scene, ft$Speaker.figure_id) }
         },
         stop("Please enter valid string-value for argument 'by' (default = 'Drama', 'Act' or 'Scene').")
  )
  
  r <- do.call(rbind, tapply(paste(ft[[column[1]]], ft[[column[2]]][-1]), index, function(x){prop.table(table(x))}))
  r[,order(colSums(r),decreasing=TRUE)]
  
}


# defunct, but new development
frequencytable3 <- function(drama,
                           acceptedPOS = postags$de$words,
                           column="Token.lemma", 
                           byCharacter=FALSE, 
                           sep="|", 
                           threshold=10,
                           normalize=FALSE, 
                           sortResult=FALSE, 
                           segment=c("Drama", "Act", "Scene")) {
  stopifnot(inherits(drama, "QDDrama"))
  
  segment <- match.arg(segment)
  
  ft <- switch(segment,
               Drama=drama$text,
               Act=segment(drama$text, drama$segments),
               Scene=segment(drama$text, drama$segments))
  
  
  if (length(acceptedPOS) > 0)
    ft <- ft[as.character(ft$Token.pos) %in% acceptedPOS,]
  
  segment <- match.arg(segment)
  
  fmla <- if(byCharacter == TRUE){
    switch(segment,
           Drama=("drama + Speaker.figure_id"),
           Act=("drama + Number.Act + Speaker.figure_id"),
           Scene=("drama + Number.Act + Number.Scene + Speaker.figure_id"))
  } else {
    switch(segment,
           Drama=("drama"),
           Act=("drama + Number.Act"),
           Scene=("drama + Number.Act + Number.Scene"))
  }
  
  metaCols <- if(byCharacter == TRUE)
  { switch(segment,
           Drama=2,
           Act=3,
           Scene=4)
  } else {
    switch(segment,
           Drama=1,
           Act=2,
           Scene=3)
  }
  
  xt <- stats::xtabs(as.formula(paste0("~", fmla, "+", column, collapse = "")), data=ft)
  
  
  xt <- as.data.table(as.data.frame(ftable(xt)))
  fmla.f <- as.formula(paste(fmla, "Token.lemma", sep = "~"))
  xt <- data.table::dcast(xt, fmla.f, value.var="Freq")
  
  if (normalize == TRUE) {
    xt[metaCols:ncol(xt),] <- t(apply(xt[metaCols:ncol(xt),],1,function(x) { xt / sum(xt)}))
  } 
  
  if (sortResult == TRUE) {
    xt <- xt[,order(colSums(xt),decreasing = TRUE)]
  }
  
  class(xt) <- append(class(xt), switch(segment, 
                                        Drama = "QDByDrama",
                                        Act   = "QDByAct",
                                        Scene ="QDByScene"))
  
  xt
}
