#
#' ---
#' title: "Data wrangling with R -- nicar2016"
#' author: "Bill Alpert, Barron's, 1.212.416.2742, william.alpert@barrons.com"
#' date: "last changed February 29, 2016"
#' ---

# Here follows an example of the disclaimer we use when we publish replication files
# DISCLAIMER: Barron's is sharing these files as pieces of journalism, in an attempt to make our reporting more transparent and our research reproducible.  We wrote them with care, but Dow Jones provides them as is and makes no guarantees.

# Clean house from last session
rm(list=ls())

# I don't know NICAR2016's directory structure, so I comment out the next few lines.
# But notice how I try to write code that's independent of platform.

# set the working directory, for Windows or Mac
# os_name = Sys.info()[['sysname']]
# if(os_name == "Windows"){
#   setwd("C:/rule605")
# }else if(os_name =="Darwin"){  # OS X
#   setwd("~/rule605")
# }else{                         # Linux
#   stop("I'm a penguin.")
# }

# You can do set the working dir manually
getwd()
# setwd("<location of our datasets>")

# or, in RStudio, use the menu "Session > Set Working Directory > Choose Directory"


# Usually, preload any R package that'll be required by a script.
# We've already installed these packages for the class, so I comment-out some of the next section.

inst_pkgs = load_pkgs = c("devtools", "rio", "readr", "rvest", "xml2", "tidyr", "dplyr", "stringr", "magrittr")

# Check to see if the packages are already installed. "%in%" returns a logical vector if there's a match
# inst_pkgs = inst_pkgs[!(inst_pkgs %in% installed.packages()[, "Package"])]

# install any missing packages
# if(length(inst_pkgs)) install.packages(inst_pkgs)

# Dynamically load required pacakges
pkgs_loaded = lapply(load_pkgs, require, character.only = T)

# We'll use the EDAWR package's datasets to learn data wrangling with the tidyr and dplyr packages.
# Uncomment the following line if you use this script at home.
# devtools::install_github("rstudio/EDAWR")


# ------
# GETTING HELP
# ------

# A few ways to find help:
#
#   ?[functionName] e.g. ?read.table
#   browseVignettes(package = c("dplyr", "tidyr"))
#   Google and StackOverflow


# ------
# R SYNTAX
# ------

# Stylisticly, I've written this script too wide. Normally, strive to remain
# within 80 characters width (like this comment).
# But this script's comment-crazy.

# "character string"		# character strings take quotes

#  package::command     # call a package's command, even if package's not attached.

# "%>%"                 # the "pipeline" operator (from the magrittr or tidyr packages),
                        #   makes it easier to read your code from left to right,
                        #   instead of inside-out of nested parentheses.

                        # Instead of:
                        #   select(tb, child:elderly)
                        # you can write:
                        #   tb %>% select(child:elderly)



# HIGH PROPS AND CREDIT WHERE IT'S DUE:
# Most of the following examples derive from a January 2015 presentation
#   by RStudio's Garrett Grolemund,and his R package of data samples called EDAWR,
#   which is available from Garrett's github repository.

# And get Garrett's data wrangling cheat sheet from RStudio's website !
#    http://www.rstudio.com/resources/cheatsheets/

# I suggest you run this lesson in the free RStudio environment.

############
#
# Data Wrangling with R
#
############


# Aspire to use a script to make all changes to your raw data,
#   or at least by the time your project's done.

# Eschew point and click data changes, like in MS Excel.
#  They are hard to review and usually get lost.

# A script preserves the original,
#  and lets you and others check and replicate your workflow.

# ------
# Get the data
# ------

# "read.table()" is R's workhorse function for importing tabular data, like spreadsheets,
#  into a dataframe object.

# EXAMPLES
#
# read.table() or read.csv()
# df <- read.table("<FileName>.txt",			# If separator is tab
#                  header = FALSE)			  # It's more readable if you indent a formula's runover lines.
#
# df <- read.table("<FileName>.csv",			# If separator is a comma
#                  header = FALSE,
#                  sep = ",")
#
# df <- read.csv("<FileName>.csv",			  # equivalent
#                header = FALSE)

# We'll practice importing with data from the March 2, 2015 Barron's story, "The Little Guy Wins!",
# which tested Michael Lewis's claim, in "Flash Boys",
# that computerized traders are ripping off small investors.
#
# Our raw data today is one of Citadel Securities' required monthly reports under SEC Rule 605
# showing how well or poorly it performed as a computerized market-maker.
#
# The file "TCDRG201412.txt" is a 10 MB pipe-delineated text file with 102,992 rows and 26 columns.

# But first, let's make a list of the Form 605 fields that we want as our dataframe's 26 column names
# I went for variable names that weren't too indecipherable.

form605_fields <- c("participant", "market_center", "date",
                    "ticker", "order_type", "order_size",
                    "total_orders", "total_shrs", "cancelled_shrs",
                    "mc_exec_shrs", "away_exec_shrs", "shrs_0to9sec",
                    "shrs_10to29sec", "shrs_30to59sec", "shrs_60to299sec",
                    "shrs_5to30min", "avg_realzd_spread", "avg_effec_spread",
                    "px_improved_shrs", "px_improved_avg_amt", "px_improved_avg_secs",
                    "at_quote_shrs", "at_quote_avg_secs", "outside_quote_shrs",
                    "outside_quote_avg_amt", "outside_quote_avg_sec")


# Import the raw monthly data file into the dataframe object "form_605".
#
# Stylewise, I use lowercase for object names and underscore between words.
#
# Some of our arguments for read.table indicate:
#             that the raw file lacks column-name headers,
#             and that we want to fill-in blanks where the raw rows are of unequal length.
#             We use our previously-listed column names,
#             and declare each column's class.
#
# You don't always have to specify so many arguments. R has sensible defaults.
#
# BEWARE! A famous R gotcha is where read.table converts character strings to factor-levels by default.
# You can override this with the argument "stringsAsFactors = FALSE".

form_605 <- read.table(file = "TCDRG201412.txt",
                                header= FALSE,
                                sep = "|",
                                fill = TRUE,
                                col.names = form605_fields,
                                colClasses = c("character", "character", "character",
                                            "character", "factor", "factor",
                                            "numeric", "numeric","numeric",
                                            "numeric","numeric","numeric",
                                            "numeric","numeric","numeric",
                                            "numeric", "numeric", "numeric",
                                            "numeric", "numeric", "numeric",
                                            "numeric", "numeric", "integer",
                                            "numeric", "numeric"))


# ------
# load names of exchange listings and s&p500 and russell1000 constituents,as of December 1, 2014
# ------

sp500            <- read.table("sp500constituents.csv", header = FALSE)

russell1000      <- read.table("russell1000_constituents.csv", header = FALSE)

NYSE             <- read.table("tickers_NYSE.csv", header = FALSE)

NASDAQ           <- read.table("tickers_NASDAQ.csv", header = FALSE)

AMEX             <- read.table("tickers_AMEX.csv", header = FALSE)



# ------
# Add columns to form_605 denoting listings and S&P 500 or Russell1000 membership
# ------

# First, we create logical vectors indicating if a form_605 row has a match in its "ticker" column


in_sp500  <- form_605[,4] %in% sp500[,1]           # The "%in%" matching operator returns a logical vector.

in_r1000  <- form_605[,4] %in% russell1000[,1]     # %in% indicates T or F if the right matches the left

on_nyse   <- form_605[,4] %in% NYSE[,1]

on_nasdaq <- form_605[,4] %in% NASDAQ[,1]

on_amex   <- form_605[,4] %in% AMEX[,1]

# Bind these new vectors as columns to our dataframe. It'll then have 31 columns.

form_605 <- cbind(form_605, in_sp500, in_r1000, on_nyse, on_nasdaq, on_amex)

# Filter to include only the rows for 'market orders' and "marketable limit orders'
# We'll learn about dplyr and filter() later...

dplyr::filter(form_605, order_type == 11 | order_type ==  12)

# Filter to exclude rows where the market center executed no shares at all

dplyr::filter(form_605,  mc_exec_shrs != 0)

# Rename the levels of order_size and order_type from code numbers into meaningful labels.
# Note that we've filtered out from our calculations all order types,
#   except "mkt_ordr" and "mktble_lmt_ordr"

levels(form_605$order_size) <- c("100-499", "500-1999", "2000-4999", "5000+")

levels(form_605$order_type) <- c("mkt_ordr", "mktbl_lmt_ordr", "insd_qt_lmt_ordr", "at_qt_lmt_ordr", "nr_qt_lmt_ordr")

# Change the class of the market_center column from character to factor,
#   to see if there are more than one market centers in the Form 605

form_605[,"market_center"] <- as.factor(form_605[,"market_center"])

############
#
# EXAMINE YOUR DATA
#
############



# In RStudio, you can click on the li'l table icon where form_605 appears in the "Environment" window,
# or use the View() command [note the uppercase V].

# Or use the built-in R functions: head() and tail()

head(form_605)      # returns the first 6 rows by default
tail(form_605)      # the last 6 rows


# The dplyr package can coerce a dataframe into a "tbl" display, for easy viewing.

# library(dplyr)
as.tbl(form_605)

# Another view allowed by dplyr is glimpse()
glimpse(form_605)

# The R community is one of computing's most active in adding features.
# rio is a new R package for importing/exporting data that's Swiss-army versatile and fast.
# It supports these formats, among others: R, text, JSON, XML, Stata, SPSS, Excel, Google Sheets
# ?rio::import
# rio uses three simple functions: import(), export(), convert()
# export(form_605, "form_605.xlsx")     # try this at home, it takes a while to write 16 MB

# Of course, R has great graphics tools for exploring your data.
# Those tools will generally work best if you first tidy up data, as follows...


############
#
# TIDY DATA
#
############



# The idea comes from Hadley Wickham, the Mozart of today's R culture.

# Tidy Data =
#  One variable per column
#  One observation (across that and the other variables) per row, e.g. one patient's measures
#  One type of data per table/file
#  A common key variable in each of a project's tables, for linking.
#
# Why bother? It formats dataframes for intuitive use of R's vectorized operations.
# You'll be able to extract, manipulate and display while preserving observations.

# The antithetical UNtidy table uses a variable's levels as column names,
# e.g.,
# percentiles
# or dates
# or "low-grade", "medium-grade", "high-grade"
# or "female" and "male"
# or "republican" and "democrat"
# or "dalmatian", "welsh corgi", and "duck-tolling retriever".....BAD DOGS !

# Let's load some raw data examples that you can later find in the EDAWR package
#
# "storms" shows windspeeds for six hurricanes, collected by the National Hurrican Center.
storms <- read.table(file = "storms.csv", header = TRUE, sep = ",", stringsAsFactors = FALSE)

# "cases" is a li'l subset of World Health Org. counts of TB cases in the US, Germany and France.
cases <- read.table(file = "cases.csv", header = TRUE, sep = ",", stringsAsFactors = FALSE)

# "pollution" is a data subset of air particulate measures from the WHO Ambient Air Pollution Database.
pollution <- read.table(file = "pollution.csv", header = TRUE, sep = ",", stringsAsFactors = FALSE)

# See how they conform to the tidy data ideal

View(storms)    # Each column a variable, each row an observation. Looks tidy?

View(cases)     # Hmmm. How many variables are in this set ?
                # And what's with the "X" at the start of some column names ?
                # R doesn't like object names starting with digits, so it pre-pends the "X" during import.

#  Fix it.
names(cases) <- gsub("X", "", names(cases))                   # Using base R's pattern-matching functions

# back to our third data set
View(pollution) # Does the "amount" column contain one variable ?

# With a tidy data set like storms, we'll see it's easy to make new variables
dplyr::mutate(storms, wnd_prsr_ratio = wind / pressure)

# ------
# the tidyr package
# ------

# To reshape untidy data, you can use the tidyr package (a Hadley creation maintained by RStudio)
# tidyr manipulates data in terms of key:value pairs
# It has two main functions: gather() and spread()

# We'll use gather() on the cases dataset columns that aren't variables, i.e. the years
# ?gather
#
# gather() collapses multiple columns into key-value pairs
#   a key column that contains the former column names
#   a value column that contains the former column cells
#
# Usage: gather(dataframe, key, value, source columns,..)
#   dataframe  = source
#   key = name of the new key column (a character string)
#   value = name of the new value column (a character string)
#   source columns = names or numeric indexes of columns to collapse

gather(cases, "year", "n", 2:4)

# It's non-destructive of the source, so you assign the tidied data to a named object
cases_tdy <- gather(cases, "year", "n", 2:4)


# We'll use spread() on the pollution dataset column that tangles counts of the measures "large" and "small"
# ?spread
#
# spread() generates multiple columns from two columns:
#   each unique value in the key column becomes a column name
#   each value in the value column becomes a cell in the new columns
#
# Usage: spread(dataframe, key, value,...)
#   dataframe  = source to be reshaped
#   key = unquoted name of the column whose values will become the new column headings
#   value = unquoted name of the column whose values will populate the new column cells

spread(pollution, size, amount)

# You can go back and forth with gather() and spread()

# tidyr has a couple of other handy functions for data input:
#   unite() and separate()

# You could argue that our seemingly tidy dataset, storms, has hidden variables.
View(storms)

# separate() splits a column by a character string separator.
# ?separate()

# Usage: separate(data, col, into, sep = "[^[:alnum:]]+",...)
#   data = a data frame
#   col  = unquoted column name
#   into = names of the new variables to create, in a character vector
#   sep  = separator between columns. If character, interpreted as a regular expression.
#                                     If numeric, the position of the split, with 1 being string's far-left

storms2 <- separate(storms, date, c("year", "month", "day"), sep = "-")
View(storms2)

# unite() is the complement function of separate()
storms_again <- unite(storms2, "date", year, month, day, sep = "-")

# Recap: Here's a tidyr example from StackOverflow
grades <- tbl_df(read.table(header = TRUE, text = "
   ID   Test Year   Fall Spring Winter
                            1   1   2008    15      16      19
                            1   1   2009    12      13      27
                            1   2   2008    22      22      24
                            1   2   2009    10      14      20
                            2   1   2008    12      13      25
                            2   1   2009    16      14      21
                            2   2   2008    13      11      29
                            2   2   2009    23      20      26
                            3   1   2008    11      12      22
                            3   1   2009    13      11      27
                            3   2   2008    17      12      23
                            3   2   2009    14      9       31
                            "))

grades %>%
  gather(Semester, Score, Fall:Winter) %>%
  mutate(Test = paste0("Test", Test)) %>%
  spread(Test, Score) %>%
  arrange(ID, Year, Semester)



############
#
# TRANSFORMIMG DATA
#
############


# We transform data to get it to work with our particular software, of course,
# but also to wrest additional information from it.




# ------
# the dplyr package
# ------

# The base R software has many functions for manipulating data.
#   See, e.g. "Data Manipulation with R," (Springer, 2008) by Phil Spector

# But one of Hadley Wickham's most popular projects, dplyr, has useful functions for data wrangling

# How dplyr's functions help access information:
#   Extract existing variables.				              select()      # columns
#   Extract existing observations.				          filter()      # rows
#   Derive new variables (from existing variables)	mutate()      # new columns
#   Change the unit of analysis				              summarise()	  # note his NZ spelling. You can use a "z".




# ------
# select()
# ------

# select() extracts subsets of a dataframe's columns
# Usage: select( data frame, list of unquoted variable names)
#   list the variable names separated by commas, or : for a range
?dplyr::select

# Extract two columns from the storm data frame:
select(storms, storm, pressure)

# Drop a variable
select(storms, -storm)
select(storms, wind:date)

# Use ?select to see the documenation for helper function that work inside select()
#  e.g., contains()      to select columns whose name contains a character string
#        matches()       to select columns whose name matches a regular expression
#        starts_with()   to select columns whose name starts with a character string

# Illustrating with R.A. Fisher's famous "iris" data example from 1936.
# ...The data were horticulturalist Edgar Anderson's, really.

iris <- tbl_df(iris)                  # so it prints a little nicer
select(iris, starts_with("Petal"))
select(iris, matches(".t."))




# ------
# filter()
# ------

# filter() extracts subsets of a dataframe's rows
?dplyr::filter

# Extract rows that meet logical critera
filter(storms, wind >= 50)

filter(storms, wind >= 50,
       storm %in% c("Alberto", "Alex", "Allison"))

# filter() can use any of R's comparators or logical operators
?Comparison  # (note the uppercase "C")
# <      Less than
# >      Greater than
# ==     Equal to
# <=     Less than or equal to
# >=     Greater than or equal to
# !=     Not equal to
# %in%   Group membership
# is.na  Is NA
# !is.na Is not NA

?base::Logic  # (note the uppercase "L")
# &      boolean and
# |      boolean or
# xor    exactly or
# !      not
# any    any true
# all    all true

filter(iris, Sepal.Length > 7)



# ------
# distinct(), slice(), etc.
# ------

# Other useful dplyr functions to subset rows:

distinct(iris)              # Remove duplicate rows
slice(iris, 10:15)          # Select rows by position
top_n(storms, 2, date)      # Select and order the rows containing the top n values in a column




# ------
# mutate()
# ------

# mutate() Calculates a new column from existing column(s),
# so mutate() takes a vector of values and returns a vector of values.
# note: mutate() preserves the source columns. To drop them, see transmute()
?mutate


# Above, in the storms data, we made the new variable pressure/wind:
mutate(storms, ratio = pressure / wind)

# Gee, that's alot of digits in the new column, ratio.
# Instruct R to display no more than three digits (this only changes what you see, not the precision).
options(digits = 3)

# mutate() recognizes new names within the scope of the function:
mutate(storms, ratio = pressure / wind, inverse = ratio^-1)

transmute(iris, sepal= Sepal.Length + Sepal.Width)

# mutate() has helper functions that work as "window" functions,
#   taking and returning a vector of values.
#
# lead()      copy with values shifted by one position
# lag()       Copy with values lagged by one position
# cumsum()    cumulative sum down the new column
#   e.g.,
set.seed(666)
ten_numbahs <- as.data.frame(rnorm(10))
colnames(ten_numbahs) <- "numbahs"
mutate(ten_numbahs, cumsum(numbahs))


# I used mutate to make complicated, but important, variables for my story
form_605 <- dplyr::mutate(form_605,
  net_pi_numerator = 100 * ((px_improved_shrs * px_improved_avg_amt) + (at_quote_shrs * 0) -  (outside_quote_shrs * outside_quote_avg_amt))
)

# Create a column with the per-row share-weighted price-improvement, aka 'net_pi',
#   with the denominator being the row's market-center executed shares
form_605 <- dplyr::mutate(form_605,
  net_pi_mc_away = (net_pi_numerator / (mc_exec_shrs + away_exec_shrs))
)



# ------
# summarise()
# ------

# summarise() takes a vector input (e.g., a column), and yields a single value.
pollution %>% summarise(median = median(amount), variance = var(amount))
pollution %>% summarise(mean = mean(amount), sum = sum(amount), n = n())
?dplyr::summarise

# Like mutate(), summarise() has helper functions.
# But these helper functions are summary functions,
#   taking a vector and returning a single value.
#
# min(), max()       Minimum and maximum values
# mean()             Mean value
# median()           Median value
# sum()              Sum of values
# var, sd()          Variance and standard deviation of a vector
# first()            First value in a vector
# last()             Last value in a vector
# nth()              Nth value in a vector
# n()                The number of values in a vector
# n_distinct()       The number of distinct values in a vector

# My stock-trading story used summarise() to measure market-makers' performance.
# here, mean net_price improvement for all stocks, all months

net_pi_mc_away_mean <- dplyr::summarise(form_605,
                        net_pi_mc_away_mean = mean(net_pi_mc_away, na.rm = TRUE)
                        )





# ------
# arrange()
# ------

?dplyr::arrange

# arrange() sorts the rows of a dataframe, low to high 
arrange(storms, wind)

# high to low
arrange(storms, desc(wind))

# by wind, then date
arrange(storms, wind, date)



############
#
# THE PIPELINE OPERATOR
#
############

# An great idea, borrowed from UNIX.
# Because R often uses functions, combined operations often produce
#   nested parentheses that must be read in reverse-order.
# The pipeline operator, %>%, passes data along from one operation to the next,
#   more readably.
# It's available when you attach the magrittr or tidyr packages.
?magrittr
vignette("magrittr")

# Instead of:
select(storms, storm, pressure)

# Do the same thing with:
storms %>% select(storm, pressure)

# Instead of:
filter(storms, wind >= 50)

# Do:
storms %>% filter(wind >= 50)

# In combination:
storms %>%
  filter(wind >= 50) %>%
  select(storm, pressure)

storms %>%
  mutate(ratio = pressure / wind) %>%
  select(storm, ratio)



############
#
# GROUP_BY()
#
############

# You can change the unit of analysis, for any calculations, with dplyr's group_by()
?group_by
iris %>% group_by(Species)

pollution %>% group_by(city)

# Apply summary function by group
pollution %>% group_by(city) %>% summarise(mean = mean(amount))

pollution %>% group_by(size) %>% summarise(mean = mean(amount))

# Several summaries
pollution %>% group_by(city) %>%
  summarise(mean = mean(amount), sum = sum(amount), n = n())


# The inverse operation is ungroup()
pollution %>% ungroup()

# In my trading story
monthly <- dplyr::group_by(form_605, date)

size    <- dplyr::group_by(form_605, order_size)

stock   <- dplyr::group_by(form_605, ticker)

net_pi_mc_away_mean_monthly <- form_605 %>%
  group_by(date) %>%
  summarise(
    net_pi_mc_away_mean_monthly = mean(net_pi_mc_away, na.rm = TRUE)
  )

# For S&P500 member stocks
net_pi_mc_away_mean_sp500 <- form_605 %>%
  filter(in_sp500 == TRUE) %>%
  summarise(net_pi_mc_away_mean_sp500 = mean(net_pi_mc_away, na.rm = TRUE))

# For non-S&P500 member stocks
net_pi_mc_away_mean_notsp500 <- form_605 %>%
  filter(in_sp500 == FALSE) %>%
  summarise(net_pi_mc_away_mean_notsp500 = mean(net_pi_mc_away, na.rm = TRUE))

# compare
net_pi_mc_away_mean_sp500
net_pi_mc_away_mean_notsp500




############
#
# JOINING DATA SETS
#
############

# Start with two toy data sets, y and z

y <- read.table(file = "y.csv", header = FALSE, sep = ",", stringsAsFactors = FALSE)

z <- read.table(file = "z.csv", header = FALSE, sep = ",", stringsAsFactors = FALSE)

View(y)
View(z)

# ------
# binding with dplyr
# ------

# To bind dataframes columnwise, you can use base R's cbind() function,
# but dplyr offers the bind_cols() function
bind_cols(y, z)   # be aware, it matches rows by position.

# To bind them rowwise, you can use base R's rbind() function,
# but dplyr offers the bind_rows() function
bind_rows(y,z)

# The dplyr binding functions are more robust than the base R functions.


# ------
# set operations with dplyr
# ------

# union()       Rows that appear in either or both y and z
union(y, z)

# intersect()   Rows that appear in both y and z
intersect(y, z)

# setdiff()     Rows that appear in y but not z
setdiff(y, z)



# ------
# mutating joins
# ------

# To study dplyr's sql-like functions, load the songs and artists data sets
songs <- read.table(file = "songs.csv", header = TRUE, sep = ",", stringsAsFactors = FALSE)

artists <- read.table(file = "artists.csv", header = TRUE, sep = ",", stringsAsFactors = FALSE)

artists2 <- read.table(file = "artists2.csv", header = TRUE, sep = ",", stringsAsFactors = FALSE)

songs2 <- read.table(file = "songs2.csv", header = TRUE, sep = ",", stringsAsFactors = FALSE)

View(songs)
View(artists)
View(artists2)
View(songs2)



# left_join()
# ?left_join
# Usage: left_join(a, b, by = "column name")
#   Joins matching rows from b to a
left_join(songs, artists, by = "name")     # Note the "NA" blank cell
# multiple column matching
left_join(songs2, artists2, by = c("first", "last"))


# right_join()
?right_join
# Usage: right_join(a, b, by = "column name")
#   Joins matching rows from a to b
right_join(songs, artists, by = "name")    # Note the "NA" blank cell


# inner_join()
?inner_join
# Usage: inner_join(a, b, by = "column name")
#   Joins data, retains only rows in both sets
inner_join(songs, artists, by = "name")


# If there are multiple matches between a and b,
#  all combinations of the matches are returned.


# full_join()
?full_join
# Usage: full_join(a, b, by = "column name")
#   Joins data, retains all values, all rows
right_join(songs, artists, by = "name")    # Note the "NA" blank cell

# Where there are not matching values, returns NA for the one missing.




# ------
# filtering joins
# ------

# semi_join()
?semi_join
# Usage: semi_join(a, b, by = "column name")
#   Returns all rows from a where there are matching values in b,
#    keeping just columns from a.
#
#     A semi join differs from an inner join because
#     an inner join will return one row of a for each matching row of b,
#     where a semi join will never duplicate rows of a.
semi_join(songs, artists, by = "name")


# anti_join()
?anti_join
# Usage: anti_join(a, b, by "column name")
#   Returns all rows from a where there are not matching values in b,
#    keeping just columns from a.
anti_join(songs, artists, by = "name")


############
#
# PRACTICE
#
############

# Now, you're a rodeo wrangler of data !

# Practice what you've just learned with the nutrition data set,
#   from the USDA, showing calories, nutrients, food group for 8463 foods. 
nutrition <- read.table(file = "nutrition.csv", header = TRUE, sep = ",", stringsAsFactors = FALSE)


### THANK YOU ! ###

##end