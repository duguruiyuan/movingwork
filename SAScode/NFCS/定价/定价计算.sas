Libname crm1 odbc user=uperpcrm password=uperpcrm datasrc=crm;
libname nfcs oracle user=datauser password=zlxdh7jf path=nfcs;
%include 'C:\work\code\GitHub\movingwork\SAScode\NFCS\定价\准确性.sas';
/*libname nfcs "&root_path.\L0";*/
/*options mprint=no;*/
/*定义批次*/
proc format;
	invalue pc
		'第一批'=1
		'第二批'=2
		'第三批'=3
		'第四批'=4
		'第五批'=5
		'第六批'=6
		'第七批'=7
		'第八批'=8
		'第九批'=9
		'第十批'=10
		'第十一批'=11
		'第十二批'=12
		'第十三批'=13
		'第十四批'=14
		'第十五批'=15
		'第十六批'=16
		'第十七批'=17
		'第十八批'=18
		'第十九批'=19
		'第二十批'=20
		'第二十一批'=21
		'第二十二批'=22
		'第二十三批'=23
		'第二十四批'=24
		'第二十五批'=25
		'第二十六批'=26
		'第二十七批'=27
		'第二十八批'=28
		'第二十九批'=29
		'第三十批'=30
;
run;
/*提取机构信息*/
data org_crm;
	set crm1.T_contract_order(
		keep=sub_account_id EXECUTE_START_DATE CONTRACT_ORDER_SUBJECT CUSTOMER_NAME EXTEND2
		rename=(sub_account_id=person CUSTOMER_NAME=sorgname EXTEND2=shortname));
run;
data org;
	set nfcs.sino_org;
run;
proc sort data=org;
	by sorgname;
run;
proc sort data=org_crm;
	by sorgname;
run;
data org_sum(keep=sorgname sorgcode person CONTRACT_ORDER_SUBJECT shortname);
	merge org org_crm(in=ina);
	by sorgname;
	if ina;
run;
/*报送量*/
%let bdate=mdy(5,1,2015);
%let edate=mdy(5,1,2016);
%macro upload(ds=);
	data &ds.;
		set nfcs.&ds.(
			keep=sorgcode dgetdate istate
			where=(
				&bdate. le datepart(dgetdate) le &edate.
				and istate eq 0
			)
		);
	run;
	proc freq data=&ds. noprint;
		tables sorgcode /out=sum_&ds.(drop=percent rename=(count=&ds.));
	run;
	proc sort data=sum_&ds.;
		by sorgcode;
	run;
%mend upload;
%upload(ds=sino_loan);
%upload(ds=sino_loan_apply);
%upload(ds=sino_person);
%upload(ds=sino_loan_spec_trade);
data sino_org;
	set nfcs.sino_org(keep=sorgcode stoporgcode rename=(sorgcode=sorgcode));
run;
/*信用报告查询量*/
data sino_credit_record;
	if _n_ eq 1 then do;
		if 0 then set sino_org;
		declare hash org(dataset:"sino_org");
		org.definekey("sorgcode");
		org.definedata("stoporgcode");
		org.definedone();
	end;
	set nfcs.sino_credit_record(keep=sorgcode drequesttime IREQUESTTYPE SPLATENAME where=(SPLATENAME eq '网络金融版个人信用报告' and &bdate. le datepart(drequesttime) le &edate.));
	rc=org.find(key:sorgcode);
	if not rc;
	sorgcode=stoporgcode;
	dmonth=intck('month',datepart(drequesttime),today());
	drop stoporgcode rc;
run;
proc sort data=sino_credit_record;
	by sorgcode descending drequesttime;
run;
data sum_sino_credit_record;
	set sino_credit_record;
	by sorgcode descending drequesttime;
	retain dmonth3;
	retain dmonth6;
	retain dmonth12;
	retain dmonth24;
	retain dmonthall;
	retain dmonthget3;
	retain dmonthget6;
	retain dmonthget12;
	retain dmonthget24;
	retain dmonthgetall;
	if first.sorgcode then do;
		dmonth3=0;
		dmonth6=0;
		dmonth12=0;
		dmonth24=0;
		dmonthall=0;
		dmonthget3=0;
		dmonthget6=0;
		dmonthget12=0;
		dmonthget24=0;
		dmonthgetall=0;
	end;
	dmonthall+1;
	if dmonth le 3 then dmonth3=dmonthall;
	if dmonth le 6 then dmonth6=dmonthall;
	if dmonth le 12 then dmonth12=dmonthall;
	if dmonth le 24 then dmonth24=dmonthall;
	if IREQUESTTYPE in(0 1 2 6) then do;
		dmonthgetall+1;
		if dmonth le 3 then dmonthget3=dmonthgetall;
		if dmonth le 6 then dmonthget6=dmonthgetall;
		if dmonth le 12 then dmonthget12=dmonthgetall;
		if dmonth le 24 then dmonthget24=dmonthgetall;
	end;
	if last.sorgcode;
run;
proc sort data=sum_sino_credit_record;
	by sorgcode;
run;
data sino_msg;
	set nfcs.sino_msg;
	month=intck('month',datepart(duploadtime),today());
	yymm=put(datepart(duploadtime),yymmn6.);
run;
proc sort data=sino_msg nodupkey;
	by sorgcode yymm;
run;
data firsttime(keep= sorgcode duploadtime yymm);
	set sino_msg;
	by sorgcode yymm;
	if first.sorgcode;
run;
%macro a;
	proc sort data=sino_msg;
		by  sorgcode month;
	run;
	data msg_transa(keep=sorgcode n);
		set sino_msg(keep=sorgcode month duploadtime);
		by sorgcode month;
/*		%do i=1 %to 36;*/
/*			retain 	%sysfunc(cats(m,%sysfunc(putn(%sysfunc(compress(%sysfunc(intnx(month,'01jun13'd,&i.,e)))),yymmn6.))));*/
/*	*/
/*			if first.sorgcode then %sysfunc(cats(m,%sysfunc(putn(%sysfunc(compress(%sysfunc(intnx(month,'01jun13'd,&i.,e)))),yymmn6.))))=0;*/
/*			if month eq "%sysfunc(putn(%sysfunc(intnx(month,'01jun13'd,&i.,e)),yymmn6.))" then do;*/
/*				%sysfunc(cats(m,%sysfunc(putn(%sysfunc(compress(%sysfunc(intnx(month,'01jun13'd,&i.,e)))),yymmn6.))))=1;*/
/*			end;*/
/*		%end;*/
		retain n;
		lmon=lag(month);
		if first.sorgcode then do;
			lmon=month;
			n=1;
		end;
		d=month-lmon;
		if d gt 3 then do;
			n=1;
		end;
		else n=n+d;
		if last.sorgcode;
	run;
%mend a;
%a;
proc sort data=error;
	by sorgcode;
run;
proc sort data=org_sum;
	by sorgcode;
run;
data org_all;
	merge org_sum firsttime msg_transa sum_sino_credit_record sum_sino_loan sum_sino_loan_apply sum_sino_loan_spec_trade sum_sino_person error;
	by sorgcode;
	upload=sum(0.4*sino_loan,0.2*sino_loan_apply,0.2*sino_loan_spec_trade,0.4*sino_person);
	if sorgcode ne '';
/*	if sorgname ne '';*/
	if n ne .;
	pc=input(CONTRACT_ORDER_SUBJECT,pc.);

run;
proc means data=org_all noprint;
	var upload;
	output out=sumupload(keep=sumup)
			sum(upload)=sumup;
run;
proc sort data=org_all;
	by sorgcode pc;
run;
data org_all;
	if _n_ eq 1 then set sumupload;
	set org_all;
	by sorgcode pc;
	if first.sorgcode;
	perc=upload/sumup;
	format perc percentn8.4;
	drop sumup person shortname CONTRACT_ORDER_SUBJECT duploadtime;
	array x _numeric_;
	do over x;
		if x eq . then x=0;
	end;
	label
		yymm='首次上报时间'
		n='距今最近连续上报月数（3个月）'
		dmonth3='最近3个月查询量'
		dmonth6='最近6个月查询量'
		dmonth12='最近12个月查询量'
		dmonth24='最近24个月查询量'
		dmonthall='查询量'
		dmonthget3='最近3个月查得量'
		dmonthget6='最近6个月查得量'
		dmonthget12='最近12个月查得量'
		dmonthget24='最近24个月查得量'
		dmonthgetall='查得量'
		sino_loan='上报业务量'
		sino_loan_apply='上报申请量'
		sino_loan_spec_trade='上报特殊交易量'
		sino_person='上报基本信息量'
		upload='综合上报量'
		pc='批次'
		perc='综合上报量占比'
	;
run;
/*%macro freq(ds=,var=);*/
/*	proc freq data=&ds.;*/
/*		tables &var.;*/
/*		title "&ds. &var.";*/
/*	run;*/
/*%mend freq;*/
/*%freq(ds=org_all,var=n);*/
/*%freq(ds=org_all,var=perc);*/
/*%freq(ds=org_all,var=month);*/
/*%freq(ds=org_all,var=sino_credit_record);*/
/*%freq(ds=org_all,var=pc);*/
