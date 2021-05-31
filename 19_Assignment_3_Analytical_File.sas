*Program written by Jalaluddin Qureshi (Team 19) for Assignment 3, Question 2;

libname project '/global/home/gbc_jqureshi/My_Folder_JQ/Assignment_3';

* proc format is used so that data elements are clearly labelled and identified
* redundant fields are removed and merged, so that the total number of values in
* a categorical datatype is minimized for easier analysis;
proc format;
	value $sex 'M'='Male' 'F'='Female' 'G'='Group' ' '='Group';
	
	value branch 2='Mandala' 3='Kawale' 4='Mzuzu' 5='Blantrye' 6='Salima' 7='Mchinji';
	
	value $ProductID 'LN01'='Group Business Loan'
					'LN02'='Individual Business Loan'
					'LN03'='Loan to purchase Shares'
					'LN04'='Emergency Loan'
					'LN05'='Farming Loan'
					'LN06'='Woman Loan'
					'LN08'='Payroll Secured Loan';
					
	value $ApplicationGrade 'A'='Best Quality' 
					'B'='Good Quality' 
					'C'='Average Quality'  
					'D'='Poor Quality';
					
	value Internal 1='Good account' 0='Bad account'; 
	
	* N and O are merged. C, PT, T, and U are merged, and so on.
	The total number of categories is minimized from 11 to 5;
	value $education 'X'='Not Specified'
					 'D'='Not Specified'
					 'H'='Not Specified'
					 'N'='No Formal Education'
					 'O'='No Formal Education'
					 'P'='Primary'
					 'E'='Primary'
					 'C'='Tertiary'
					 'PT'='Tertiary'
					 'T'='Tertiary'
					 'U'='Tertiary'
					 'S'='Secondary';
	
	*Now I have reduced the number of categories from 11 to  7;
	value $profession 'PR'='Employee'
					  'E' ='Employee'
					  'PRO'='Civil Servants'
					  'B'='Business-person'
					  'T'='Business-person'
					  'M'='Business-person'
					  'C'='Civil Servants'
					  'F'='Farmer'
					  'N'='Unemployed'
					  ' '='Other'
					  'O'='Other'
					  'U'='Other';
					 
	value $marital 'D'='Divorced'
				   'G'='Group'
				   'M'='Married'
				   'S'='Single'
				   'P'='Not Specified'
			       'U'='Not Specified'
			       ' '='Not Specified'
				   'W'='Widow/er'
				   'WI'='Widow/er';
				   
	value purpose 1='For Business'
				  5='For Business'
				  11='For Business'
				  4='Bills Payment'
				  6='Bills Payment'
				  8='Bills Payment'
				  9='Bills Payment'
				  12='Bills Payment'
				  2='Real Estate'
				  3='Real Estate'
				  7='Real Estate'
				  10='Real Estate'
				  .='Other'
				  13='Other';
run;

*File name where the data is output is clean data;
data project.loans_clean; 

	* Chaning the length of different variables i) to save memory, and 
	ii) increase length where needed, e.g. for ProductID.;
	length AccountID 8 Branch 8 ProductID $25 'Application Score'n 3
			ArrearsDays 5 'Actual Application Grade'n $10 LiteracyLevel $20;
			
	*Some of the variables are being renamed to give them a more meaningful name;
	set project.loan_profile (rename= (BranchID=Branch
									'Actual Good Bad'n=Internal_Indicator
									PurposeCode=Purpose)); *The input file;
									
	* Either no information about the variable is available or a "bad loan" is 
	* independent of the variable. Hence these variables are dropped.;
	DROP AccountID CreditOfficerID SectorID DonorID LoanSeries;
	
	*for balance and amount values the variable is formatted to currency;
	format  
	Internal_Indicator Internal.
	'Actual Application Grade'n $ApplicationGrade. 
	ProductID $ProductID. 
	Gender $sex. 
	Branch branch.
	LiteracyLevel $education.
	Occupation $Profession.
	MaritalStatus $marital.
	Purpose purpose.
	DonorID 3.
	LoanSeries 2.
	'Disbursement Amount'n Dollar8.
	ActualBalance Dollar8.
	ArrearsAmount Dollar8.
	InstallmentAmt Dollar8.
	;
	
	/* ******************************* */
	/* Removing Extreme Outliers       */
	/* ******************************* */
	
	if 'Disbursement Amount'n >310000 then delete;
	
	else if InstallmentAmt >49170 then delete;
	
	else if ActualBalance >172104 then delete;
	
	else if ArrearsAmount >464179 then delete;
	
	else if ArrearsDays >1248 then delete;
	
	/* ******************************* */
	/* New variables asked in Question */
	/* ******************************* */
	
	/*July 31, 2012 is subtracted from DisbursedOn date which gives time diff in seconds.
	It is then divided by 86400 (24hr/day * 60mins/hr * 60sec/min) */
	'Days on File'n= (input('31JUL12:00:00:00'dt,DTDate.) - DisbursedOn)/86400;

	if 'Application Score'n >40 then 'Credit Grade'n="A";
	else if 'Application Score'n >30 =<40 then 'Credit Grade'n="B";
	else if 'Application Score'n >20 =<30 then 'Credit Grade'n="C";
	else if 'Application Score'n =<20 then 'Credit Grade'n="D";
	
	/* ******************************* */
	/* Five new variables defined 	   */
	/* ******************************* */
	
	format RatioPendingAmount 6.2 RatioInstallment 6.2 Arrears_Delay_Amount 6.2
			RatioArrearsday 6.2 ArrearsDayRank $11.;
	
	* Variable#1 ;
	RatioPendingAmount=(ArrearsAmount/'Disbursement Amount'n)*100;
	
	* Variable#2 ;
	RatioInstallment=(InstallmentAmt/ 'Disbursement Amount'n)*100;
	
	* Variable#3 ;
	Arrears_Delay_Amount = (ActualBalance/'Disbursement Amount'n) * (ArrearsDays/365) *100;
	
	* Variable#4 ;
	RatioArrearsDay = (ArrearsDays/'Days on File'n)*100;
	
	* Variable#5 ;
	If ArrearsDays lt 35 then ArrearsDayRank='Low Risk';
	Else if ArrearsDays ge 35 and ArrearsDays lt 338 then ArrearsDayRank='Medium Risk';
	Else if ArrearsDays ge 338 then ArrearsDayRank='High Risk';
	
run;

proc export
	data=  project.loans_clean
	dbms= csv
	outfile= '/global/home/gbc_jqureshi/My_Folder_JQ/Assignment_3/19_Assignment_3_Part_2_Analytical_File.csv'
	replace;
run;