/*�������*/
proc import
	datafile='C:\work\other\100�һ���.xlsx'
	out=org(rename=(_col1=sorgname _col2=sorgcode _col3=extend))
	replace;
run;
proc sql noprint;
	select cats("'",sorgcode,"'") into :orgfilter separated by ' ' from org;
quit;
%put &orgfilter.;
libname nfcs oracle user=datauser password=zlxdh7jf path=nfcs;
/*��ȡ����*/
data sino_loan;
	set nfcs.sino_loan(
		where=(
			sorgcode in(&orgfilter.)
			and istate eq 0
		)
	);
run;
/*��ȡ���һ��ҵ������*/
proc sort
	data=sino_loan;
	by sorgcode sloancompactcode saccount dbillingdate dgetdate;
run;
/*���ñ�ʶ*/
data loan;
	set sino_loan;
	by sorgcode sloancompactcode saccount dbillingdate dgetdate;
	if last.saccount;
	flag_g=0;
	flag_y1=0;
	flag_pd=0;
	if iguaranteeway eq 2 then flag_g=1;
	if datepart(ddateopened) ge intnx('year',today(),-1,'s') then flag_y1=1;
	if IAMOUNTPASTDUE gt 0 then flag_pd=1;
run;
/*��������Ѻ��1�������������������ֲ����˻����������˻���*/
proc sort
	data=loan;
	by sorgcode sloancompactcode saccount dbillingdate dgetdate;
run;
data sum_loan;
	set loan;
	by sorgcode sloancompactcode saccount dbillingdate dgetdate;
	retain bal;
	retain bal_g;
	retain bal_y1;
	retain bal_pd;
	retain bal_pd30;
	retain bal_pd60;
	retain bal_pd90;
	retain bal_pd180;
	retain acc_num;
	retain acc_num_pd;
	if first.sorgcode then do;
		bal=0;
		bal_g=0;
		bal_y1=0;
		bal_pd=0;
		bal_pd30=0;
		bal_pd60=0;
		bal_pd90=0;
		bal_pd180=0;
		acc_num=0;
		acc_num_pd=0;
	end;
	bal+ibalance;
	bal_pd30+IAMOUNTPASTDUE30;
	bal_pd60+IAMOUNTPASTDUE60;
	bal_pd90+IAMOUNTPASTDUE90;
	bal_pd180+IAMOUNTPASTDUE180;
	acc_num+1;
	if flag_pd then do;
		acc_num_pd+1;
		bal_pd+ibalance;
	end;
	if flag_g then do;
		bal_g+ibalance;
	end;
	if flag_y1 then do;
		bal_y1+ibalance;
	end;
	keep
		sorgcode
		bal
		bal_g
		bal_y1
		bal_pd
		bal_pd30
		bal_pd60
		bal_pd90
		bal_pd180
		acc_num
		acc_num_pd
	;
	label
		sorgcode='������'
		bal='�������'
		bal_g='��Ѻ�������'
		bal_y1='1�������ڴ������'
		bal_pd='�����˻��������'
		bal_pd30='����31-60����'
		bal_pd60='����61-90����'
		bal_pd90='����91-180����'
		bal_pd180='����180�����Ͻ��'
		acc_num='�˻���'
		acc_num_pd='�����˻���'
	;
	if last.sorgcode;
run;
/*����ǰʮ���������*/
proc sort
	data=loan;
	by sorgcode ipersonid sloancompactcode saccount;
run;
data sum_person;
	set loan;
	by sorgcode ipersonid sloancompactcode saccount;
	retain p_bal;
	retain p_limit;
	if first.ipersonid then do;
		p_bal=0;
		p_limit=0;
	end;
	p_bal+ibalance;
	p_limit+icreditlimit;
	if last.ipersonid;
run;
proc sort
	data=sum_person;
	by sorgcode descending p_limit;
run;
data sum_p;
	set sum_person;
	by sorgcode descending p_limit;
	retain num_p;
	retain amt_p;
	retain limit_p;
	if first.sorgcode then do;
		num_p=0;
		amt_p=0;
		limit_p=0;
	end;
	num_p+1;
	amt_p+p_bal;
	limit_p+p_limit;
	if num_p eq 10;
	keep sorgcode amt_p limit_p;
	label
		amt_p='ǰʮ�����˵�ǰ���'
		limit_p='ǰʮ�����˽���'
	;
run;
/*���*/
data out;
	if _n_ eq 1 then do;
		if 0 then set sum_loan;
		declare hash sum(dataset:'sum_loan');
		sum.definekey('sorgcode');
		sum.definedata('bal','bal_g','bal_y1','bal_pd','bal_pd30','bal_pd60','bal_pd90','bal_pd180','acc_num','acc_num_pd');
		sum.definedone();
		if 0 then set sum_p;
		declare hash p(dataset:'sum_p');
		p.definekey('sorgcode');
		p.definedata('amt_p','limit_p');
		p.definedone();
	end;
	set org;
	rc=sum.find(key:sorgcode);
	if rc then do;
		bal=.;
		bal_g=.;
		bal_y1=.;
		bal_pd=.;
		bal_pd30=.;
		bal_pd60=.;
		bal_pd90=.;
		bal_pd180=.;
		acc_num=.;
		acc_num_pd=.;
	end;
	rc1=p.find(key:sorgcode);
	if rc then do;
		amt_p=.;
		limit_p=.;
	end;
run;
