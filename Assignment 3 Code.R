## Assignment 3 - Hospital Compare Data

setwd("D:/Online Learning/Data Specialization/R Programming/Assignment 3")
hospital <- read.csv("hospital-data.csv", colClasses = "character")

## Plot the 30-day mortality rates for heart attack

outcome<- read.csv("outcome-of-care-measures.csv", colClasses = "character")
head(outcome)
ncol(outcome)
names(outcome)
outcome[,11] <- as.numeric(outcome[,11])
hist(outcome[,11])

## Finding the best hospital in a state

best <- function(state, outcome){
  
  ## Read outcome data
  data <- read.csv("outcome-of-care-measures.csv", colClasses = "character")
  dat   <- as.data.frame(cbind(data[, 2],  # Hospital.Name
                               data[, 7],   # State
                               data[, 11],  # Hospital.30.Day.Death..Mortality..Rates.from.Heart.Attack
                               data[, 17],  # Hospital.30.Day.Death..Mortality..Rates.from.Heart.Failure
                               data[, 23]), # Hospital.30.Day.Death..Mortality..Rates.from.Pneumonia
                         stringsAsFactors = FALSE)
  colnames(dat) <- c("hospital", "state", "heart attack", "heart failure", "pneumonia")
  
  ## Check that state and outcome are valid
  if(!state %in% dat[, "state"]){
    stop('invalid state')
    
    ## Return hospital name in that state with lowest 30-day death
  } else if(!outcome %in% c("heart attack", "heart failure", "pneumonia")){
    stop('invalid outcome')
  } else {
    st <- which(dat[, "state"] == state)
    df <- dat[st, ]   
    out <- as.numeric(df[, eval(outcome)])
    min_out <- min(out, na.rm = TRUE) 
    result  <- df[, "hospital"][which(out == min_out)]
    output  <- result[order(result)]
  }
  return(output)
}

## Testing Function
best(TX, Heart Attack) 
## should return CYPRESS FAIRBANKS MEDICAL CENTER
best("MD", "heart attack") 
$# should return JOHNS HOPKINS HOSPITAL, THE
  
  
  
  ## Ranking Hospitals by Outcome in a State
  
  rankhospital <- function(state, outcome, rank = "best"){
    
    ## Read outcome data
    data <- read.csv("outcome-of-care-measures.csv", colClasses = "character")
    dat   <- as.data.frame(cbind(data[, 2],  # Hospital.Name
                                 data[, 7],      # State
                                 data[, 11],     # Hospital.30.Day.Death..Mortality..Rates.from.Heart.Attack
                                 data[, 17],     # Hospital.30.Day.Death..Mortality..Rates.from.Heart.Failure
                                 data[, 23]),    # Hospital.30.Day.Death..Mortality..Rates.from.Pneumonia
                           stringsAsFactors = FALSE)
    colnames(dat) <- c("hospital", "state", "heart attack", "heart failure", "pneumonia")
    
    ## Check that state and outcome are valid
    if (!state %in% dat[, "state"]) {
      stop('invalid state')
    } else if (!outcome %in% c("heart attack", "heart failure", "pneumonia")){
      stop('invalid outcome')
      
      ## Return hospital name in that state with the given rank
    } else if (is.numeric(rank)) {
      st <- which(dat[, "state"] == state)
      df <- dat[st, ] # dataframe for state
      df[, eval(outcome)] <- as.numeric(df[, eval(outcome)])
      df <- df[order(df[, eval(outcome)], df[, "hospital"]), ]
      output <- df[, "hospital"][rank]
    } else if (!is.numeric(rank)){
      if (rank == "best") {
        output <- best(state, outcome)
      } else if (rank == "worst") {
        st <- which(dat[, "state"] == state)
        df <- dat[st, ]    
        df[, eval(outcome)] <- as.numeric(df[, eval(outcome)])
        df <- df[order(df[, eval(outcome)], df[, "hospital"], decreasing = TRUE), ]
        output <- df[, "hospital"][1]
      } else {
        stop('invalid rank')
      }
    }
    return(output)
  }


## Testing
rankhospital("TX", "heart failure", 4) 
## should return DETAR HOSPITAL NAVARRO
rankhospital("MD", "heart attack", "worst") 
## should return HARFORD MEMORIAL HOSPITAL


## Ranking Hospitals in All State

rankall <- function(outcome, num = "best"){
  
  ## Read outcome data
  data <- read.csv("outcome-of-care-measures.csv", colClasses = "character")
  dat <- as.data.frame(cbind(data[, 2],    # Hospital.Name
                             data[, 7],      # State
                             data[, 11],     # Hospital.30.Day.Death..Mortality..Rates.from.Heart.Attack
                             data[, 17],     # Hospital.30.Day.Death..Mortality..Rates.from.Heart.Failure
                             data[, 23]),    # Hospital.30.Day.Death..Mortality..Rates.from.Pneumonia
                       stringsAsFactors = FALSE)
  colnames(dat) <- c("hospital", "state", "heart attack", "heart failure", "pneumonia")
  dat[, eval(outcome)] <- as.numeric(dat[, eval(outcome)])
  
  ## Check that state and outcome are valid
  if (!outcome %in% c("heart attack", "heart failure", "pneumonia")){
    stop('invalid outcome')
    
    ## For each state, find the hospital of the given rank
  } else if (is.numeric(num)) {
    by_state <- with(dat, split(dat, state))
    ordered  <- list()
    for (i in seq_along(by_state)){
      by_state[[i]] <- by_state[[i]][order(by_state[[i]][, eval(outcome)], by_state[[i]][, "hospital"]), ]
      ordered[[i]]  <- c(by_state[[i]][num, "hospital"], by_state[[i]][, "state"][1])
    }
    
    ## Return a data frame with the hospital name and the abbreviated state name
    result <- do.call(rbind, ordered)
    output <- as.data.frame(result, row.names = result[, 2], stringsAsFactors = FALSE)
    names(output) <- c("hospital", "state")
  } else if (!is.numeric(num)) {
    if (num == "best") {
      by_state <- with(dat, split(dat, state))
      ordered  <- list()
      for (i in seq_along(by_state)){
        by_state[[i]] <- by_state[[i]][order(by_state[[i]][, eval(outcome)], by_state[[i]][, "hospital"]), ]
        ordered[[i]]  <- c(by_state[[i]][1, c("hospital", "state")])
      }
      result <- do.call(rbind, ordered)
      output <- as.data.frame(result, stringsAsFactors = FALSE)
      rownames(output) <- output[, 2]
    } else if (num == "worst") {
      by_state <- with(dat, split(dat, state))
      ordered  <- list()
      for (i in seq_along(by_state)){
        by_state[[i]] <- by_state[[i]][order(by_state[[i]][, eval(outcome)], 
                                             by_state[[i]][, "hospital"], decreasing = TRUE), ]
        ordered[[i]]  <- c(by_state[[i]][1, c("hospital", "state")])
      }
      result <- do.call(rbind, ordered)
      output <- as.data.frame(result, stringsAsFactors = FALSE)
      rownames(output) <- output[, 2]
    } else {
      stop('invalid num')
    }
  }
  return(output)
}


## Testing 
rankall(TX","heart failure",20)
rankall("MD", "pneumonia")