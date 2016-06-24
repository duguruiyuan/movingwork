%macro getds(lib=,ds=,out=,where=,date=);
	proc contents 
		data=&lib..&ds. 
		out=vartab(keep=name)
		noprint;
	run;
	proc sql noprint;
		select count(*) into :varexist from vartab(where=(name eq 'ISTATE'));
	quit;
	%if &lib. eq %str() %then %let lib=work;
	%put &where.;
	%if &varexist. ge 1 %then %do;
		%let vare=%str(istate eq 0);
	%end;
	%else %let vare=%str(1=1);
	%if &where. eq %str() %then %do;
		%let where=%str(where=(&vare.));
	%end;
	%else %let where=%str((where=(&where. and &vare.)));
	%put &where.;
	%if &out. eq %str() %then %do;
		%let out=&ds.;
	%end;
	%put &out.;
	data &out.;
/*		if _n_ eq 1 then do;*/
/*			if 0 then set toporg;*/
/*			declare hash top(dataset:'toporg');*/
/*			top.definekey('sorgcode');*/
/*			top.definedata('stoporgcode');*/
/*			top.definedone();*/
/*		end;*/
		set &lib..&ds.&where.;
/*		rc=top.find(key:sorgcode);*/
/*		if not rc;*/
		%if &date. ne %str() %then %do;
			dmonth=put(datepart(&date.),yymmn6.);
		%end;
	run;
	proc sql noprint;
		drop table vartab;
	quit;
%mend getds;
%getds(lib=nfcs,ds=sino_loan,out=sino_loan,where=sorgcode eq 'Q10155800H8X00',date=ddateopened);
%getds(lib=nfcs,ds=sino_loan_apply,out=sino_loan_apply,where=sorgcode eq 'Q10155800H8X00',date=ddate);

proc sort
	data=sino_loan(where=(datepart(dgetdate) lt mdy(6,1,2016)))
	out=sino_loan_1;
	by sorgcode saccount dbillingdate dgetdate;
run;
data loan;
	set sino_loan_1;
	by sorgcode saccount dbillingdate dgetdate;
	if last.saccount;
run;
proc freq
	data=loan noprint;
	tables dmonth /out=out_loan;
run;
proc sort
	data=sino_loan_apply(where=(datepart(dgetdate) lt mdy(6,1,2016)))
	out=sino_loan_apply_1;
	by sorgcode SAPPLYCODE DDATE dgetdate;
run;
data apply;
	set sino_loan_apply_1;
	by sorgcode SAPPLYCODE DDATE dgetdate;
	if last.SAPPLYCODE;
run;
proc freq
	data=apply noprint;
	tables dmonth /out=out_apply;
run;
