#' @export
fringe<- function(data, ctypes=NULL,cformats=NULL,
                 cdescriptions=NULL,
                   name = NULL, description = NULL,recordName = NULL){
  if(isFringe(data)){
    warning("data is already a Fringe")
    return(data)
  }
  # if(nrow(data) >0)
  #rownames(data) <- NULL
  fringe <- Fringe$new(data,
                    ctypes=ctypes,
                    cformats=cformats,
                    cdescriptions = cdescriptions,
                    name = name %||% deparse(substitute(data)),
                    description = description,
                    recordName = recordName)
  fringe
}

#' @export
fringeske<- function(ctypes=NULL,cformats=NULL,cnames = NULL,
               name = NULL, description = NULL,
               validators = NULL, sampleData = NULL, useCnames = TRUE){
  if(!is.null(sampleData))
    name <- name %||% deparse(substitute(sampleData))
  fringeske <- FringeSke$new(
                 ctypes=ctypes,
                 cformats=cformats,
                 cnames=cnames,
                 name = name,
                 description = description,
                 validators = validators,
                 sampleData = sampleData,
                 useCnames = useCnames)
  fringeske
}


#' @export
isFringe <- function(d){
  "Fringe" %in% class(d)
}

#' @export
sameFringes <- function(f1,f2){
  all(
    identical(getCnames(f1),getCnames(f2)),
    identical(getCtypes(f1),getCtypes(f2)),
    identical(getCformats(f1),getCformats(f2)),
    identical(f1$d,f2$d)
  )
}

#' @export
getDatafringe <- function(fringe, withNames = TRUE){
  if(!isFringe(fringe)) stop('class is not Fringe')
  if(withNames) return(fringe$data)
  else return(fringe$d)
}

#' @export
getCnames <- function(fringe){
  if(isFringe(fringe))
    return(unlist(Map(function(i){i$name},fringe$fields)))
  if(is.data.frame(fringe))
    return(names(fringe))
  stop("Not a fringed dataframe")
}

#' @export
getCdescriptions <- function(fringe){
  if(!isFringe(fringe)) stop('class is not Fringe')
  unlist(Map(function(i){i$cdescription},fringe$fields))
}

#' @export
getCtypes <- function(fringe, cols = NULL){
  if(!isFringe(fringe))
    fringe <- fringe(fringe)
  cols <- cols %||% getCnames(fringe)
  l <- Map(function(i){i[["ctype"]]},fringe$fields)
  names(l) <- Map(function(i){i[["name"]]},fringe$fields)
  out <- l[cols]
  unname(unlist(out))
}

#' @export
getCformats <- function(fringe){
  if(!isFringe(fringe))
    fringe <- fringe(fringe)
  fringe$getCformats()
}


#' @export
getCaCnames <- function(fringe, n = 4){
  d <- getDatafringe(fringe)
  nvals <- sapply(d,function(c)length(unique(c)))
  names(nvals[nvals <= n])
}

#' @export
getFtype <- function(fringe){
  if(!isFringe(fringe))
    fringe <- fringe(fringe)
  fringe$ftype
}




#' @export
fringeHasFringeSkeleton <- function(fringe,fringeSke){
  # Check ctypes and cnames
  cfringe <- getCnames(fringe)
  names(cfringe) <- getCtypes(fringe)
  cske <- fringeSke$cnames
  names(cske) <- fringeSke$ctypes
  ctypesCnamesCheck <- identical(cfringe,cske)

  # Check validators
  validators <- fringeSke$validators
  if(paste(validators,collapse="") != ""){
    validatorsTmp <- lapply(validators,function(v){strsplit(v,":",fixed=TRUE)[[1]]})
    validatorCheck <- lapply(validatorsTmp,function(v){
      cols <- strsplit(v[-1],"|",fixed=TRUE)[[1]]
      type <- v[1]
      colValidate(fringe,type = type,cols = cols)
    })
    validatorCheck <- all(unlist(validatorCheck))
  } else{
    validatorCheck <- TRUE
  }
  # Return validations
  ctypesCnamesCheck && validatorCheck
}


#' @export
validValidators <- function(validators){
  #validators <- c("fringeColVal_greaterThan0:fdsafs","fringeColVal_unique:fdsafds")
  if(length(validators) == 1 && validators == "") return(TRUE)
  v <- strsplit(validators,":")
  v <- Map(function(i){i[[1]]},v)
  fringevalf <- paste0("fringeVal_",fringeValidateFuns())
  colvalf <- paste0("fringeColVal_",fringeColValidateFuns())
  all(v %in% c(fringevalf,colvalf))
}

#' @export
selectColumns <- function(fringe,fields){
  if(!all(fields %in% getColumnNames(fringe))) stop("Columns not in this fringe")
  fringe(fringe$data[fields],name = fringe$name, description = fringe$description)
}

#' @export
selectFringeCols <- function(fringeIn,cols){
  if(!class(fringeIn)[1] %in% c("Fringe","data.frame"))
    stop("fringe must be either a Fringe of a data.frame")
  if(!isFringe(fringeIn)) fringe <- fringe(fringeIn)
  else fringe <- fringeIn
  if(class(cols) %in% c("numeric","integer"))
    cols <- getCnames(fringe)[cols]
  if(! all(cols %in% getCnames(fringe)))
    stop("cols not in fringe")
  d <- getDatafringe(fringe)
  out <- d[cols]
  if(isFringe(fringeIn)) return(fringe(out))
  out
}

#' @export
setCnames <- function(t,cnames, idx = NULL){
  if(!isFringe(t))
    stop("fringe must be a Fringe")
  t$setCnames(cnames,idx = idx)
  t
}

#' @export
setCdescriptions <- function(t,cdescriptions, idx = NULL){
  if(!isFringe(t))
    stop("fringe must be a Fringe")
  t$setCdescriptions(cdescriptions,idx = idx)
  t
}

