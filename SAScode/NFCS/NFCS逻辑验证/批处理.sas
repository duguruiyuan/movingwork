%include 'E:\林佳宁\code\config.sas';
libname my 'E:\林佳宁\code\数据质量';
data my.file;
	input sorgcode $28.;
	cards;
Q10152900H9800
Q10151000H8800
Q10152900H1D00
Q10152900HT400
Q10153300HDW00
Q10152900HFJ00
Q10152900H2Z00
Q10152900H1W00
Q10152900H8500
Q10152900H0900
Q10151000H3000
Q10152900HN500
Q10152900HAZ00
Q10152900H1200
Q10152900H1W00
Q10153900H7T00
Q10152900HC000
Q10151000H0G00
Q10155800HZ200
Q10152900H9C00
Q10155800H2P00
Q10152900HAL00
Q10152900HN300
Q10155800H5400
Q10152900H3500
Q10155800HCV00
Q10155800HS000
Q10152900H1400
Q10151000H0Y00
Q10152900HD900
Q10155800H3200
Q10152900H0900
Q10152900HU700
Q10151000H2800
Q10152900H7C00
Q10155800H6800
Q10151000HV200
;
run;
/*data sino_loan1;*/
/*	if _n_ eq 1 then do;*/
/*		declare hash org(dataset: "my.file");*/
/*		org.definekey("sorgcode");*/
/*		org.definedone();*/
/*	end;*/
/*	set nfcs.sino_loan;*/
/*	rc=org.find();*/
/*	if not rc;*/
/*run;*/
/*data sino_loan;*/
/*	set nfcs.sino_loan(where=(sorgcode in('Q10152900H9800'*/
/*/*'Q10151000H8800'*/*/
/*/*'Q10152900H1D00'*/*/
/*/*'Q10152900HT400'*/*/
/*/*'Q10153300HDW00'*/*/
/*/*'Q10152900HFJ00'*/*/
/*/*'Q10152900H2Z00'*/*/
/*/*'Q10152900H1W00'*/*/
/*/*'Q10152900H8500'*/*/
/*/*'Q10152900H0900'*/*/
/*/*'Q10151000H3000'*/*/
/*/*'Q10152900HN500'*/*/
/*/*'Q10152900HAZ00'*/*/
/*/*'Q10152900H1200'*/*/
/*/*'Q10152900H1W00'*/*/
/*/*'Q10153900H7T00'*/*/
/*/*'Q10152900HC000'*/*/
/*/*'Q10151000H0G00'*/*/
/*/*'Q10155800HZ200'*/*/
/*/*'Q10152900H9C00'*/*/
/*/*'Q10155800H2P00'*/*/
/*/*'Q10152900HAL00'*/*/
/*/*'Q10152900HN300'*/*/
/*/*'Q10155800H5400'*/*/
/*/*'Q10152900H3500'*/*/
/*/*'Q10155800HCV00'*/*/
/*/*'Q10155800HS000'*/*/
/*/*'Q10152900H1400'*/*/
/*/*'Q10151000H0Y00'*/*/
/*/*'Q10152900HD900'*/*/
/*/*'Q10155800H3200'*/*/
/*/*'Q10152900H0900'*/*/
/*/*'Q10152900HU700'*/*/
/*/*'Q10151000H2800'*/*/
/*/*'Q10152900H7C00'*/*/
/*/*'Q10155800H6800'*/*/
/*/*'Q10151000HV200'*/*/
/*	)));*/
/*run;
proc sql noprint;
	select cats("'",sorgcode,"'") into :orgcode separated by ' ' from my.file;
quit;
%put &orgcode.;
data my.sino_loan;
	set nfcs.sino_loan(where=(sorgcode in(&orgcode.)));
run;
/*%macro test;*/
/*	data my.b;*/
/*		set a;*/
/*		z=x+y;*/
/*	run;*/
/*	libname my clear;*/
/*%mend test;*/
/*%test;*/
