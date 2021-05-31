*Program written by Jalaluddin Qureshi (Team 19) for Assignment 3, Question 1;

libname project '/global/home/gbc_jqureshi/My_Folder_JQ/Assignment_3';

proc import datafile = '/global/home/gbc_jqureshi/My_Folder_JQ/Assignment_3/LOAN_PORTFOLIO.csv' 
	out = project.loan_profile
 	dbms = CSV;
run;

* missing rows with a . are categorized as "Missing Value";
proc format;
*for numeric data type;
value dot
. = 'Missing Value';

*for character data type;
value $blank 
' ' = 'Blank value';
run;

* / missing also tally those field where the values are missing or blank;
title "Freq. Distribution of Categorical Datatype";
proc freq data=project.loan_profile;
	TABLES BranchID ProductID 'Actual Application Grade'n 'Actual Good Bad'n 
	Gender LiteracyLevel Occupation MaritalStatus PurposeCode DonorID 
	LoanSeries CreditOfficerID SectorID / missing;
	format Gender $blank. Occupation $blank. MaritalStatus $blank. 
	PurposeCode dot. DonorID dot. SectorID dot.;
run;
title;

title 'Descriptive Statistics about Numeric Datatype';
proc means data=project.loan_profile;
	var 'Application Score'n ArrearsDays 'Disbursement Amount'n InstallmentAmt 
	ActualBalance ArrearsPer ArrearsAmount;
run;
title;

title 'Univariate Detailed Analysis of Numeric Datatype';
proc univariate data=project.loan_profile;
	var 'Application Score'n ArrearsDays 'Disbursement Amount'n InstallmentAmt 
	ActualBalance ArrearsPer ArrearsAmount;
run;
title;
