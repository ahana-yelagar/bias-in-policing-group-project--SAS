proc import out = police 
datafile = "/home/u63559049/Project 1/nc_durham_2020_04_01.csv"
dbms = csv replace;
guessingrows = max;
run;

proc contents data = police;
run;

/**** Data Cleaning ****/
data police;
set police;
where year(date) = 2014 or year(date) = 2015;
run;

/*** Clean Time ***/
/*Make "NA" = "00:00:00"*/
data police;
set police;
time_na = time;

if time in ("NA")
	then time_na = "00:00:00";
run;

/*Convert to a numeric time format*/
data police;
set police;
time_numeric = input(time_na, time8.);
format time_numeric time8.;
run;

/*Check to see if the time column is in the correct format now - */
proc contents data = police;
run;

/*
Divide into categories as shown - 
- 00:00:01 < x <= 04:00:00 = Late Night
- 04:00:00 < x <= 08:00:00 = Early Morning
- 08:00:00 < x <= 12:00:00 = Morning
- 12:00:00 < x <= 16:00:00 = Afternoon
- 16:00:00 < x <= 20:00:00 = Evening
- 20:00:00 < x < 00:00:00 = Night
- N/a values (00:00:00) = x = Other
*/
data police;
set police;
if '00:00:01't <= time_numeric <= '04:00:00't then time_cat = 'Late Night';
else if '04:00:01't <= time_numeric <= '08:00:00't then time_cat = 'Early Morning';
else if '08:00:01't <= time_numeric <= '12:00:00't then time_cat = 'Morning';
else if '12:00:01't <= time_numeric <= '16:00:00't then time_cat = 'Afternoon';
else if '16:00:01't <= time_numeric <= '20:00:00't then time_cat = 'Evening';
else if '20:00:01't <= time_numeric <= '23:59:59't then time_cat = 'Night';
else time_cat = 'Other';
run;

/***Clean Date***/
/*Convert date into day numbers only*/
data police;
set police;
day_num = date;
day_num = day(date);
run;

/*Create new column to specify whether the event is in the first three weeks or the last week of the month*/
data police;
set police;
if day_num < "21" then time_of_month = "first3" ;
else time_of_month = "last1";
run;

proc freq data = police;
tables time_of_month;
run;

/* Make a column for days of the week by using the date column */
data police;
set police;
weekday = weekday(date);
Run;

/*** Clean Age ***/
/* Age has an NA entry and is not numeric */
data police;
set police;
if subject_age = "NA" then DELETE;
run;

/*Check to see if the NA is gone. It is*/
proc freq data = police;
tables subject_age;
run;


/*Convert the age column to numeric*/
data police;
set police;
age_numeric = input(subject_age, 8.);
run;

/*Check the type for the age column*/
proc contents data = police;
run;


/****Data Analysis****/
/***Check for complete separation***/
/*Check categorical variables*/
proc freq data = police;
tables reason_for_stop*citation_issued;
run;

proc freq data = police;
tables subject_sex*citation_issued;
run;

proc freq data = police;
tables subject_race*citation_issued;
run;

proc freq data = police;
tables time_of_month*citation_issued;
run;

proc freq data = police;
tables Weekday*citation_issued;
run;

proc freq data = police;
tables time_cat*citation_issued;
Run;
/*Check numeric X*/

proc sgplot data = police;
scatter x = age_numeric y = citation_issued;
run;

/***Create GLM***/
proc logistic data = police;
class time_cat weekday time_of_month subject_sex reason_for_stop subject_race / param = reference;
model citation_issued(event = 'TRUE') = age_numeric subject_race time_cat weekday time_of_month subject_sex reason_for_stop subject_race/ clparm = both ;
run;

/***Interpretive statements ***/
/*95% confidence interval for the odds that gender is a significant predictor for getting a citation */
/*We are 95% confident that the odds of receiving a citation change by a factor between & for a person identifying as female over a person who identifies as male when only considering sex as a factor.*/

/*95% confidence interval for the odds that race is a significant predictor of getting a ticket*/
/**CI For Race Hispanic
We are 95% confident that the odds of receiving a citation change
by a factor between 1.978 and 2.285 for a person identifying as hispanic
over a person identifying as white. In other words we are 95% sure
that the odds almost double.
.**/
/***Hypothesis statements ***/
/*
Hypothesis Test For subject_race Variable
H0: BAsian/PacificIslander=BBlack=BHispanic=BOther=BUnknown=0
HA: At least 1 B!=0
Test Statistic: w=539.5991
Null Distribution: X^2(5)
P-value: <.0001
Conclusion: Because the p-value .0001 is less than any alpha, we 
reject H0. There is evidence to claim that race is a significant 
predictor of getting a citation.

CI for subject_race Black.
We are 95% confident that the odds of receiving a citation change
by a factor between 1.978 and 2.285 for a person identifying as hispanic
over a person identifying as white. In other words we are 95% sure
that the odds almost double.
*/

/***Interpretive statements ***/
/*95% confidence interval for the odds that gender is a significant predictor for getting a citation */
/*We are 95% confident that the odds of receiving a citation change by a factor between & for a person identifying as female over a person who identifies as male when only considering sex as a factor.*/

/*95% confidence interval for the odds that race is a significant predictor of getting a ticket*/
/**CI For Race Hispanic
We are 95% confident that the odds of receiving a citation change
by a factor between 1.978 and 2.285 for a person identifying as hispanic
over a person identifying as white. In other words we are 95% sure
that the odds almost double.
.**/

