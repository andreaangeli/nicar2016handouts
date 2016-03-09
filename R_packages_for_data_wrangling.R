#
#' ---
#' title: "R packages for Data wrangling with R -- nicar2016"
#' author: "Bill Alpert, Barron's, 1.212.416.2742, william.alpert@barrons.com"
#' date: "last changed February 29, 2016"
#' ---

inst_pkgs = load_pkgs = c("devtools", "rio", "readr", "rvest", "xml2", "tidyr",
"dplyr", "stringr", "magrittr")

# Check to see if the packages are already installed. "%in%" returns a logical vector if there's a match
inst_pkgs = inst_pkgs[!(inst_pkgs %in% installed.packages()[, "Package"])]

# install any missing packages
if(length(inst_pkgs)) install.packages(inst_pkgs)

##end
