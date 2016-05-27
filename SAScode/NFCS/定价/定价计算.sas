Libname crm1 odbc user=uperpcrm password=uperpcrm datasrc=crm;
libname nfcs oracle user=datauser password=zlxdh7jf path=nfcs;
%include 'C:\work\code\GitHub\movingwork\SAScode\NFCS\����\׼ȷ��.sas';
/*libname nfcs "&root_path.\L0";*/
/*options mprint=no;*/
/*��������*/
proc format;
	invalue pc
		'��һ��'=1
		'�ڶ���'=2
		'������'=3
		'������'=4
		'������'=5
		'������'=6
		'������'=7
		'�ڰ���'=8
		'�ھ���'=9
		'��ʮ��'=10
		'��ʮһ��'=11
		'��ʮ����'=12
		'��ʮ����'=13
		'��ʮ����'=14
		'��ʮ����'=15
		'��ʮ����'=16
		'��ʮ����'=17
		'��ʮ����'=18
		'��ʮ����'=19
		'�ڶ�ʮ��'=20
		'�ڶ�ʮһ��'=21
		'�ڶ�ʮ����'=22
		'�ڶ�ʮ����'=23
		'�ڶ�ʮ����'=24
		'�ڶ�ʮ����'=25
		'�ڶ�ʮ����'=26
		'�ڶ�ʮ����'=27
		'�ڶ�ʮ����'=28
		'�ڶ�ʮ����'=29
		'����ʮ��'=30
;
run;
/*��ȡ������Ϣ*/
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
/*������*/
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
/*���ñ����ѯ��*/
data sino_credit_record;
	if _n_ eq 1 then do;
		if 0 then set sino_org;
		declare hash org(dataset:"sino_org");
		org.definekey("sorgcode");
		org.definedata("stoporgcode");
		org.definedone();
	end;
	set nfcs.sino_credit_record(keep=sorgcode drequesttime IREQUESTTYPE SPLATENAME where=(SPLATENAME eq '������ڰ�������ñ���' and &bdate. le datepart(drequesttime) le &edate.));
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
		yymm='�״��ϱ�ʱ��'
		n='�����������ϱ�������3���£�'
		dmonth3='���3���²�ѯ��'
		dmonth6='���6���²�ѯ��'
		dmonth12='���12���²�ѯ��'
		dmonth24='���24���²�ѯ��'
		dmonthall='��ѯ��'
		dmonthget3='���3���²����'
		dmonthget6='���6���²����'
		dmonthget12='���12���²����'
		dmonthget24='���24���²����'
		dmonthgetall='�����'
		sino_loan='�ϱ�ҵ����'
		sino_loan_apply='�ϱ�������'
		sino_loan_spec_trade='�ϱ����⽻����'
		sino_person='�ϱ�������Ϣ��'
		upload='�ۺ��ϱ���'
		pc='����'
		perc='�ۺ��ϱ���ռ��'
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
