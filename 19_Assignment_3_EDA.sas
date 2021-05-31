*Program written by Jalaluddin Qureshi (Team 19) for Assignment 3, Question 3;

libname project '/global/home/gbc_jqureshi/My_Folder_JQ/Assignment_3';

*What Literacy Level occurs most frequently?;
proc freq data=project.loan_profile;
	TABLES LiteracyLevel;
run;

*Which Branch is largest in terms of the number of customers?;
*Which Branch disburses the largest average loan?;
title "Branch with respect to number of customer/ average loan";
proc means data=project.loan_profile mean;
	class BranchID;
	var 'Disbursement Amount'n;
run;
title;

*Which Customer AccountID has the largest number of days in Arrears?;
*The proc univarite is used to identify the max. value of ArrearsDay
*and then this value is used to write a SQL query to identify AccountID.;
proc univariate data=project.loan_profile;
	var ArrearsDays;
run;
proc sql;
select AccountID
from project.loan_profile
where ArrearsDays eq 1847;
quit;

*Which Gender Group (M for Males, and F for Females) has a higher proportion of “Bad” loans?;
data work.gender_profile;
	set project.loan_profile;
	if ArrearsAmount gt 0 and gender='M' then M_default+1;
	else if ArrearsAmount gt 0 and gender='F' then F_default+1;
run;

*PROC TABULATE;
proc tabulate data=project.loan_profile;
class ProductID;
var ArrearsAmount ArrearsDays;
table(ArrearsAmount ArrearsDays)*(N MEAN STD MIN MAX), ProductID ALL; run;

*PROC GCHART
title "Determing the Gender and Marital Status of applicant with highest mean arrear amount";
proc gchart data=project.loans_clean;
	block gender/ sumvar=ArrearsAmount
	type=mean
	group=maritalstatus
	subgroup=Occupation;
run;
title;

*PROC GPLOT Defining the interval of the y and x axis when plotting the correlation plot.;
axis1 order=(0 to 20000); 
axis2 order=(0 to 20000);
title "Correlation analysis between ArrearsAmount and ActualBalance";
proc gplot data=project.loans_clean;
   plot ArrearsAmount *ActualBalance / haxis=axis1 vaxis=axis2;
run;
title;

*PROC SQL;
title "Details of people who have defaulted large amount for a long time period.";
proc sql;
select *
from project.loans_clean
where ArrearsAmount gt 1000 and ArrearsDays gt 1000;
quit;

*PROC UNIVARIATE;
*This shows that ArrearsDay has exponential distribution.;
proc univariate data=project.loans_clean noprint;
   histogram ArrearsDays;
run;

*PROC SORT;
*It shows that there are some bad loan account where the arrear amount is high
* and the arrear time has also been large, yet they are classified as Good account;
proc sort data=project.loans_clean out=work.sorted;
   by descending ArrearsAmount;
run;
proc print data=sorted(obs=50);
   var ArrearsAmount ArrearsDays 'Application Score'n Internal_Indicator;
   title  'Original Prediction';
run;

*PROC CONTENTS;
proc contents data=project.loans_clean;
   title  'The Contents of the GROUP Data Set';
run;

