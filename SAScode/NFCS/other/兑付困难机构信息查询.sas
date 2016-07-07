%macro getds(lib=,ds=,out=,where=,date=);
	%if &lib. eq %str() %then %let lib=work;
	%put &where.;
	%if &where. eq %str() %then %do;
		%let where=%str();
	%end;
	%else %let where=%str((where=(&where.)));
	%if &out. eq %str() %then %do;
		%let out=&ds.;
	%end;
	%put &out.;
	data &out.;
		set &lib..&ds.&where.;
		%if &date ne %str() %then %do;
			dmonth=put(datepart(&date.),yymmn6.);
		%end;
	run;
%mend getds;

%macro freq(ds=,key=,var=);
	proc freq
		data=&ds. noprint;
		tables dmonth 
			/out=sum(
				drop=percent
			)
		;
	run;
	data sum_&ds.;
		if _n_ eq 1 then do;
			do i=1 to n;
				set sum nobs=n;
				retain all 0;
				all=all+count;
			end;
			dmonth='合计';
			count=all;
			drop all i;
			output;
		end;
		set sum;
		rename count=&ds.;
		output;
	run;
	proc sort
		data=sum_&ds.;
		by dmonth;
	run;
	%if &key. ne %str() %then %do;
		proc sort
			data=&ds.;
			by &key. &var.;
		run;
		data &key._&ds.;
			set &ds.;
			by &key. &var.;
			if first.&key.;
		run;
		proc freq
			data=&key._&ds. noprint;
			tables dmonth 
				/out=sum_&key.(
					drop=percent
				)
			;
		run;
		data sum_&key._&ds.;
			if _n_ eq 1 then do;
				do i=1 to n;
					set sum_&key. nobs=n;
					retain all 0;
					all=all+count;
				end;
				dmonth='合计';
				count=all;
				drop all i;
				output;
			end;
			set sum_&key.;
		rename count=&ds._&key.;
		output;
		run;
		proc sort
			data=sum_&key._&ds.;
			by dmonth;
		run;
	%end;

%mend freq;

%include 'C:\work\code\GitHub\movingwork\SAScode\config.sas';
options mprint;
%let o=Q10152900HO800;
%let filter=sorgcode eq "&o.";
%let filtermore=%str(sorgcode eq "&o." and irequesttype in%(0 1 2 6%));
%getds(lib=nfcs,ds=sino_org,where=&filter.);
%getds(lib=nfcs,ds=sino_loan,out=loan,where=&filter.,date=dgetdate);
%getds(lib=nfcs,ds=sino_loan_apply,out=apply,where=&filter.,date=dgetdate);
%getds(lib=nfcs,ds=sino_person,out=person,where=&filter.,date=dgetdate);
%getds(lib=nfcs,ds=sino_loan_spec_trade,out=spec,where=&filter.,date=dgetdate);
%getds(lib=nfcs,ds=sino_credit_record,out=record,where=&filter.,date=drequesttime);
%getds(lib=nfcs,ds=sino_credit_record,out=credit_get,where=&filtermore.,date=drequesttime);
proc sql noprint;
	select sorgname into :name from sino_org;
quit;
%let filter=%str(CUSTOMER_NAME eq "&name.");
%getds(lib=crm1,ds=t_contract_order,where=&filter.);
data org;
	merge 
		sino_org(keep=sorgcode sorgname) 
		t_contract_order(
			keep=CUSTOMER_NAME CONTRACT_ORDER_SUBJECT SUB_ACCOUNT_ID EXECUTE_START_DATE 
			rename=(CUSTOMER_NAME=sorgname)
		);
	by sorgname;
run;

%freq(ds=loan,key=saccount,var=dbillingdate dgetdate);
%freq(ds=loan,key=ipersonid,var=dbillingdate dgetdate);
%freq(ds=apply,key=ipersonid,var=dgetdate);
%freq(ds=spec,key=saccount,var=dgetdate);
%freq(ds=person,key=ipersonid,var=dgetdate);
%freq(ds=record);
%freq(ds=credit_get);
data sum;
	merge
		sum_loan
		sum_saccount_loan
		sum_ipersonid_loan
		sum_apply
		sum_ipersonid_apply
		sum_spec
		sum_saccount_spec
		sum_person
		sum_ipersonid_person
		sum_record
		sum_credit_get
	;
	by dmonth;
	label
		loan='业务记录'
		loan_saccount='账户数'
		loan_ipersonid='业务人数'
		apply='申请记录'
		apply_ipersonid='申请人数'
		spec='特殊交易记录'
		spec_saccount='特殊交易账户数'
		person='人员记录'
		person_ipersonid='上报人数'
		record='信用报告查询量'
		credit_get='信用报告查得量'
	;
run;
