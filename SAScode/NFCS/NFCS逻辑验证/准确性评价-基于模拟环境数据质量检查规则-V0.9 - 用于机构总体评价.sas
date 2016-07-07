%include "C:\work\code\GitHub\movingwork\SAScode\config.sas";
libname nfcs "C:\work\creditriskcard\data\DB160415001";
libname nfcs "C:\work\creditriskcard\data\DB160201001\L0";
data orgfile;
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


proc sql noprint;
	select cats("'",sorgcode,"'") into :orgcode separated by ' ' from orgfile;
quit;

%let orgfilter = and sorgcode in (&orgcode.);
data _null_;
	if %sysfunc(length(&orgfilter.)) = 0 then orgfilter = " ";
run;
%let timefilter = %str(and dgetdate >= &begin. and &firstday. > datepart(dbillingdate) >= &begin.);
%let NoteAddr = %unquote(%str(E:\�ּ���\code\��������\�����������ϵͳ������˵��-V1.7.docx));
data sino_loan_all;
	set nfcs.sino_loan(
/*		drop = sloantype sloancompactcode scurrency iclass5stat iinfoindicator skeepcolumn ipersonid ilineno stoporgcode ipbcstate */
		WHERE=(SUBSTR(sorgcode,1,1)='Q' 
			and istate = 0 
			AND sorgcode not in ('Q10152900H0000','Q10152900H0001')
		)
	);
run;
proc sort data = sino_loan_all(where=(1=1 &timefilter.)) out=sino_loan;
by iloanid dbillingdate descending dgetdate;
run;
/*%AddLabel(sino_loan);*/
data sino_loan;
informat zhangqi yymmn6.;
format zhangqi yymmn6.;
 set sino_loan;
 error_flag = 0;
 doubt_flag = 0;
 zhangqi = intnx('month',datepart(dbillingdate),0,'b');
/*label*/
/*	&label.*/
 	label
		sorgcode='��������'
		smsgfilename='������'
		saccount='ҵ���'
		scertno='֤����'
		dgetdate='��������'
		ddateopened='��������'
		ddateclosed='��������'
		sTermsfreq = "����Ƶ��"
		dbillingdate= "����Ӧ��������"
		drecentpaydate = "���һ��ʵ�ʻ�������"
		ischeduledamount = "����Ӧ������"
		iactualpayamount = "����ʵ�ʻ�����"
		iaccountstat = "�˻�״̬"
		sPaystat24month = "��ʮ���»���״̬"
	;
run;
proc sort data = sino_loan;
	by iloanid zhangqi descending dgetdate;
run;
data sino_loan;
	set sino_loan;
	if iloanid = lag(iloanid) and zhangqi = lag(zhangqi) then delete;
run;
/*Rule 1*/
/*1������ʱ���ϱ�"����Ӧ��������"�Ƿ�ȡ�����գ���һ�������������������������һ�λ����ͬһ�죩*/
/*����*/
data sino_loan rule_1(
				keep=sorgcode
					smsgfilename
					saccount
					scertno
					dgetdate
					ddateopened 
					ddateclosed 
					sTermsfreq 
					dbillingdate 
					drecentpaydate 
					ischeduledamount 
					iactualpayamount 
					iaccountstat
					sPaystat24month);
 set sino_loan;
  if dbillingdate ^= drecentpaydate and iaccountstat not in (1,2) then do;
		doubt_flag = 1;
	end;
	output sino_loan;
	if dbillingdate ne drecentpaydate and iaccountstat not in(1,2) &orgfilter. then do;
		output rule_1;
		end;
run;
/*Rule 2*/
/*---2���������ڣ��ʻ�״̬ȴΪ����*/
/*����*/
data sino_loan rule_2(
				keep=sorgcode
					smsgfilename
					saccount
					scertno
					dgetdate
					ddateopened 
					ddateclosed 
					dbillingdate 
					icurtermspastdue
					iaccountstat
					sPaystat24month);
	set sino_loan;
	if icurtermspastdue > 0 and iaccountstat = 1 then do;
		error_flag = 1;
	end;
	output sino_loan;
	if icurtermspastdue > 0 and iaccountstat = 1 &orgfilter. then do;
		output rule_2;
	end;
run;

/*Rule 3*/
/*5���ڷǿ������µ�����£����һ��ʵ�ʻ������ڴ��ڵ���Ӧ�������ڣ���ʵ�ʻ�����Ϊ0 */
/*��ȷ��һ�����һ��ʵ�ʻ�������ȡֵ���⣩(�����ã������ڵı���)*/
/*����*/
data sino_loan rule_3(
	keep=sorgcode
		smsgfilename
		saccount
		scertno
		dgetdate
		ddateopened 
		ddateclosed 
		sTermsfreq
		dbillingdate
		drecentpaydate
		ischeduledamount
		iactualpayamount 
		iaccountstat
		sPaystat24month);
	set sino_loan;
	if dbillingdate <= drecentpaydate and iactualpayamount = 0 and drecentpaydate ^= ddateopened and sPaystat24month ^= '///////////////////////*' then do;
		doubt_flag = 1;
	end;
	output sino_loan;
	if dbillingdate <= drecentpaydate and iactualpayamount = 0 and drecentpaydate ^= ddateopened and sPaystat24month ^= '///////////////////////*' &orgfilter. then do;
		output rule_3;
	end;
run;

/*Rule 4*/
/*---8������δ���ڣ�����Ӧ��������ڱ���ʵ�ʻ������"�˻�״̬"����*/
/*����*/
data sino_loan rule_4(
	keep=sorgcode
		smsgfilename
		saccount
		scertno 
		dgetdate
		ddateopened
		ddateclosed
    	dbillingdate
    	drecentpaydate
    	ischeduledamount
    	iactualpayamount 
    	iaccountstat
    	sPaystat24month
	 );
	set sino_loan;
	if iaccountstat = 1 and ddateclosed ^= dbillingdate and ischeduledamount > iACTUALPAYAMOUNT then do;
		error_flag = 1;
	end;
	output sino_loan;
	if iaccountstat = 1 and ddateclosed ^= dbillingdate and ischeduledamount > iACTUALPAYAMOUNT &orgfilter. then do;
		output rule_4;
	end;
run;

/*Rule 5*/
/*9��T+1����ʱ��"����Ӧ��������"��"���һ�λ�������"Ӧ�õ���"��������" ����T+1�����ã���T+1������--�����軹���û��������������ϱ�һ�Σ�*/
/*����*/
/*��Ҫ����*/
data sino_loan rule_5(
	keep=sorgcode
		smsgfilename
		saccount
		scertno 
		dgetdate
		ddateopened
		ddateclosed
		sTermsfreq
		dbillingdate
		drecentpaydate
		ischeduledamount
		iactualpayamount
		sPaystat24month
	);
	set sino_loan;
	if sPaystat24month = '///////////////////////*' and (dbillingdate ^= ddateopened or drecentpaydate ^= ddateopened) then do;
		error_flag = 1;
	end;
	output sino_loan;
	if sPaystat24month = '///////////////////////*' and (dbillingdate ^= ddateopened or drecentpaydate ^= ddateopened) &orgfilter. then do;
		output rule_5;
	end;
run; 

/*Rule 6*/
/*10��24�»���״̬���һλ��Nʱ����"����Ӧ������"����"ʵ�ʻ�����"*/
/*����*/
data sino_loan rule_6(
	keep=sorgcode
		smsgfilename
		saccount
		scertno 
		dgetdate
		ddateopened
		ddateclosed
		sTermsfreq
		dbillingdate
		drecentpaydate
		ischeduledamount
		iactualpayamount
		sPaystat24month
	);
	set sino_loan;
	if substr(sPaystat24month,24,1) = 'N' and ischeduledamount > iactualpayamount then do;
		doubt_flag = 1;
	end;
	output sino_loan;
	if substr(sPaystat24month,24,1) = 'N' and ischeduledamount > iactualpayamount &orgfilter. then do;
		output rule_6;
	end;
run; 

/*Rule 7*/
/*11���ǰ��»���������ºͽ������⣬"����Ӧ��������"��Ӧ��ȡÿ�����һ��*/
/*����*/
data sino_loan rule_7(
	keep=sorgcode
		smsgfilename
		saccount
		scertno 
		dgetdate
		ddateopened
		ddateclosed
		sTermsfreq
		dbillingdate
		drecentpaydate
		ischeduledamount
		iactualpayamount 
		iaccountstat
		sPaystat24month
	);
	set sino_loan;
	if substr(sPaystat24month,1,23) ^= '///////////////////////' and sTermsfreq ^= '03' and iaccountstat ^= 3 and datepart(dbillingdate) ^= intnx('month',datepart(dbillingdate),0,'end') then do;
		doubt_flag = 1;
	end;
	output sino_loan;
	if substr(sPaystat24month,1,23) ^= '///////////////////////' and sTermsfreq ^= '03' and iaccountstat ^= 3 and datepart(dbillingdate) ^= intnx('month',datepart(dbillingdate),0,'end') &orgfilter. then do;
		output rule_7;
	end;
run;
 
/*Rule 8*/
/*14��"ʵ�ʻ�����"����""����Ӧ������""����δ�������⽻�׶�*/
/*����*/
data spec;
	set nfcs.sino_loan_spec_trade(where=(speculiartradetype in ('4','5','9')));
run;
proc sort data=spec nodupkey;
	by iloanid;
run;
data sino_loan rule_8(
	keep=sorgcode
		smsgfilename
		saccount
		scertno 
		dgetdate
		ddateopened
		ddateclosed
		sTermsfreq
		dbillingdate
		drecentpaydate
		ischeduledamount
		iactualpayamount
		sPaystat24month
	);
	if _n_ eq 1 then do;
		if 0 then set spec(keep=iloanid);
		declare hash spec(dataset: 'spec');
		spec.definekey('iloanid');
		spec.definedone();
	end;
	set sino_loan;
	rc=spec.find(key:iloanid);
	if iActualpayamount > ischeduledamount 
		and dbillingdate < ddateclosed 
		and intnx('month',datepart(dbillingdate),0,'b') ^= intnx('month',datepart(ddateclosed),0,'b')
		and substr(sPaystat24month,23,1) in ('*','#','/','N') 
		and rc ne 0
	then do;
		doubt_flag=1;
	end;
	output sino_loan;
	if iActualpayamount > ischeduledamount 
		and dbillingdate < ddateclosed 
		and intnx('month',datepart(dbillingdate),0,'b') ^= intnx('month',datepart(ddateclosed),0,'b')
		and substr(sPaystat24month,23,1) in ('*','#','/','N') 
		and rc ne 0
		&orgfilter.
	then do;
		output rule_8;
	end;
run;

/*Rule 9*/
/*15���������ʱ��ʵ��Ӧ�����ӦΪ0*/
/*����*/
data sino_loan rule_9(
	keep=sorgcode
		smsgfilename
		saccount
		scertno 
		dgetdate
		ddateopened
		ddateclosed
		sTermsfreq
		dbillingdate
		drecentpaydate
		ischeduledamount
		iactualpayamount
		sPaystat24month
	);
	set sino_loan;
	if substr(sPaystat24month,24,1) = 'C' and iaccountstat = 3 and iactualpayamount = 0 then do;
		error_flag = 1;
	end;
	output sino_loan;
	if substr(sPaystat24month,24,1) = 'C' and iaccountstat = 3 and iactualpayamount = 0 &orgfilter. then do;
		output rule_9;
	end;
run;

/*Rule 10*/
/*16����"����Ӧ������"Ϊ0����"����ʵ�ʻ�����"����0������£�24�»���״̬��ӦΪ�Ǻ�*/
/*����*/
data sino_loan rule_10(
	keep=sorgcode
		smsgfilename
		saccount
		scertno 
		dgetdate
		ddateopened
		ddateclosed
		sTermsfreq
		dbillingdate
		drecentpaydate
		ischeduledamount
		iactualpayamount
		sPaystat24month
	);
	set sino_loan;
	if ischeduledamount = 0 and iactualpayamount > 0 and substr(sPaystat24month,24, 1) = '*' then do;
		error_flag = 1;
	end;
	output sino_loan;
	if ischeduledamount = 0 and iactualpayamount > 0 and substr(sPaystat24month,24, 1) = '*' &orgfilter. then do;
		output rule_10;
	end;
run;

/*Rule 11*/
/*18���������������������δ����ʱ����ǰ�����ܶ�Ӧ�õ���""����Ӧ������""��"ʵ�ʻ�����"֮��*/
/*����*/
data sino_loan rule_11(
	keep=sorgcode
		smsgfilename
		saccount
		scertno 
		dgetdate
		ddateopened
		ddateclosed
		sTermsfreq
		dbillingdate
		drecentpaydate
		ischeduledamount
		iactualpayamount
		iamountpastdue
		sPaystat24month
	);
	set sino_loan;
	if substr(sPaystat24month, 23, 2) = 'N1'
		and (ischeduledamount - iactualpayamount > iamountpastdue + 1
			or ischeduledamount - iactualpayamount < iamountpastdue - 1)
	then do;
		error_flag = 1;
	end;
	output sino_loan;
	if substr(sPaystat24month, 23, 2) = 'N1'
		and (ischeduledamount - iactualpayamount > iamountpastdue + 1 
			or ischeduledamount - iactualpayamount < iamountpastdue - 1)
		&orgfilter. 
	then do;
		output rule_11;
	end;
run;

/*Rule 12*/
/*19�����»����������,"����Ӧ������"��Ӧ��Ϊ0(�����������)*/
/*����*/
data sino_loan rule_12(
	keep=sorgcode
		smsgfilename
		saccount
		scertno 
		dgetdate
		ddateopened
		ddateclosed
		sTermsfreq
		dbillingdate
		drecentpaydate
		ischeduledamount
		iactualpayamount
		sPaystat24month
	);
	set sino_loan;
	if sPaystat24month ^= '///////////////////////*'
		and sTermsfreq = '03' and ischeduledamount=0 
		and intnx('month',datepart(dbillingdate),0,'end') ^= intnx('month',datepart(ddateopened),0,'end')
	then do;
		error_flag = 1;
	end;
	output sino_loan;
	if sPaystat24month ^= '///////////////////////*'
		and sTermsfreq = '03' and ischeduledamount=0 
		and intnx('month',datepart(dbillingdate),0,'end') ^= intnx('month',datepart(ddateopened),0,'end')
		&orgfilter.
	then do;
		output rule_12;
	end;
run;

/*Rule 13*/
/*20�����»���ں�"����Ӧ��������"�������µ�*/
/*����*/
data sino_loan rule_13(
	keep=sorgcode
		smsgfilename
		saccount
		scertno 
		dgetdate
		ddateopened
		ddateclosed
		sTermsfreq
		dbillingdate
		drecentpaydate
		ischeduledamount
		iactualpayamount
		sPaystat24month
	);
	set sino_loan;
	if sTermsfreq = '03'
		and datepart(dbillingdate) ^= intnx('month',datepart(dbillingdate),0,'end')
		and iaccountstat ^= 3 
		and intnx('month',datepart(dbillingdate),0,'end') > intnx('month',datepart(ddateclosed),0,'end')
	then do;
		error_flag = 1;
	end;
	output sino_loan;
	if sTermsfreq = '03'
		and datepart(dbillingdate) ^= intnx('month',datepart(dbillingdate),0,'end')
		and iaccountstat ^= 3 
		and intnx('month',datepart(dbillingdate),0,'end') > intnx('month',datepart(ddateclosed),0,'end')
		&orgfilter.
	then do;
		output rule_13;
	end;
run;

/*Rule 14*/
/*22�����ں�"�ۼ���������"��"��ǰ��������"��"�����������"��Ӧ�ü����ۼ�*/
/*����*/
/*��Ҫ����*/
data rule_14_org;
	retain n 0;
	set sino_loan(where=(
		iaccountstat = 2
		and intnx('month',datepart(ddateclosed),0,'end') <= intnx('month',datepart(dbillingdate),0,'end')
	));
	liloanid=lag(iloanid);
	ldbillingdate=lag(dbillingdate);
	licurtermspastdue=lag(icurtermspastdue);
	litermspastdue=lag(itermspastdue);
	limaxtermspastdue=lag(imaxtermspastdue);
	if iloanid=liloanid then do;
		if dbillingdate gt ldbillingdate then do;
			if icurtermspastdue le licurtermspastdue then do;
				if itermspastdue le litermspastdue then do;
					if imaxtermspastdue le limaxtermspastdue then do;
						delete;
					end;
					else n+1;
				end;
				else n+1;
			end;
			else n+1;
		end;
		else n+1;
	end;
	else n=0;
	if n gt 0;
run;
data sino_loan rule_14(
	keep=sorgcode
		smsgfilename
		saccount
		scertno 
		dgetdate
		ddateopened
		ddateclosed
		sTermsfreq
		dbillingdate
		drecentpaydate
		ischeduledamount
		iactualpayamount
		iamountpastdue
		icurtermspastdue
		itermspastdue
		imaxtermspastdue
		iaccountstat
		sPaystat24month
		iloanid
	);
	if _n_ eq 1 then do;
		if 0 then set rule_14_org(keep=iloanid);
		declare hash org(dataset :'rule_14_org');
		org.definekey('iloanid');
		org.definedone();
	end;
	set sino_loan;
	rc=org.find();
	if not rc then do;
		error_flag=1;
		output rule_14;
	end;
	output sino_loan;
run;

/*Rule 15*/
/*23��24�»���״̬���Ϊ1ʱ��31-60δ�黹����Ӧ��Ϊ0*/
/*����*/
data sino_loan rule_15(
	keep=sorgcode
		smsgfilename
		saccount
		scertno 
		dgetdate
		ddateopened
		ddateclosed
		sTermsfreq
		dbillingdate
		drecentpaydate
		iamountpastdue30
		sPaystat24month
	);
	set sino_loan;
	if substr(sPaystat24month,24,1) = '1'
		and iamountpastdue30 ^= 0 
	then do;
		error_flag = 1;
	end;
	output sino_loan;
	if substr(sPaystat24month,24,1) = '1'
		and iamountpastdue30 ^= 0
		&orgfilter.
	then do;
		output rule_15;
	end;
run;

 /*Rule 16*/
/*26������ʱ,"����Ӧ��������"�����������һ��ʵ�ʻ�������*/
/*����*/
data sino_loan rule_16(
	keep=sorgcode
		smsgfilename
		saccount
		scertno 
		dgetdate
		ddateopened
		ddateclosed
		sTermsfreq
		dbillingdate
		drecentpaydate
		ischeduledamount
		iactualpayamount
		sPaystat24month
	);
	set sino_loan;
	if  drecentpaydate ^= dbillingdate
		and iaccountstat = 3
	then do;
		doubt_flag = 1;
	end;
	output sino_loan;
	if  drecentpaydate ^= dbillingdate
		and iaccountstat = 3
		&orgfilter.
	then do;
		output rule_16;
	end;
run;

 /*Rule 17*/
/*27��"ʵ�ʻ�����"���ڵ���"����Ӧ������"ʱ��24���»���״̬ȡֵ��׼ȷ*/
/*����*/
data sino_loan rule_17(
	keep=sorgcode
		smsgfilename
		saccount
		scertno 
		dgetdate
		ddateopened
		ddateclosed
		sTermsfreq
		dbillingdate
		drecentpaydate
		ischeduledamount
		iactualpayamount
		sPaystat24month
	);
	set sino_loan;
	if  iactualpayamount >= ischeduledamount
		and substr(sPaystat24month, 23, 1) in ('*','#','/','N')
		and substr(sPaystat24month, 24, 1) not in ('*','#','/','N','C')
	then do;
		error_flag = 1;
	end;
	output sino_loan;
	if  iactualpayamount >= ischeduledamount
		and substr(sPaystat24month, 23, 1) in ('*','#','/','N')
		and substr(sPaystat24month, 24, 1) not in ('*','#','/','N','C')
	then do;
		output rule_17;
	end;
run;

 /*Rule 18*/
/*29�����»����˻����ϸ������ڱ����˻�����������£�"ʵ�ʻ�����"Ӧ�ô���"����Ӧ������"*/
/*����*/
data sino_loan rule_18(
	keep=sorgcode
		smsgfilename
		saccount
		scertno 
		dgetdate
		ddateopened
		ddateclosed
		sTermsfreq
		dbillingdate
		drecentpaydate
		ischeduledamount
		iactualpayamount
		sPaystat24month
	);
	set sino_loan;
	if  substr(sPaystat24month,24,1)='N'
		and substr(sPaystat24month,23,1) not in ('*','#','/','N')
		and iactualpayamount<=ischeduledamount
		and dbillingdate <= ddateclosed
	then do;
		error_flag = 1;
	end;
	output sino_loan;
	if  substr(sPaystat24month,24,1)='N'
		and substr(sPaystat24month,23,1) not in ('*','#','/','N')
		and iactualpayamount<=ischeduledamount
		and dbillingdate <= ddateclosed
		&orgfilter
	then do;
		output rule_18;
	end;
run;

/*Rule 19*/
/*33�����»����֮��,��ǰ�����ܶӦ��С�����*/
/*����*/
data sino_loan rule_19(
	keep=sorgcode
		smsgfilename
		saccount
		scertno 
		dgetdate
		ddateopened
		ddateclosed
		sTermsfreq
		dbillingdate
		ibalance
		iamountpastdue
		iamountpastdue30
		iamountpastdue60
		iamountpastdue90
		iamountpastdue180
		sPaystat24month
	);
	set sino_loan;
	if sTermsfreq = '03'
		and dbillingdate > ddateclosed
		and (iamountpastdue < ibalance)
	then do;
		error_flag = 1;
	end;
	output sino_loan;
	if sTermsfreq = '03'
		and dbillingdate > ddateclosed
		and (iamountpastdue < ibalance)
	then do;
		output rule_19;
	end;
run;

/*Rule 20*/
/*34��"����Ƶ��"Ϊ�̶���"��ǰ��������"��"�ۼ���������"��Ӧ�ô��ڻ�������*/
/*����*/
data sino_loan rule_20(
	keep=sorgcode
		smsgfilename
		saccount
		scertno 
		dgetdate
		ddateopened
		ddateclosed
		sTermsfreq
		dbillingdate
		drecentpaydate
		smonthduration
		icurtermspastdue
		itermspastdue
		imaxtermspastdue
	);
	set sino_loan;
	if sTermsfreq not in ('07', '08', '99')
		and input(smonthduration,4.) < itermspastdue
	then do;
		doubt_flag = 1;
	end;
	output sino_loan;
	if sTermsfreq not in ('07', '08', '99')
		and input(smonthduration,4.) < itermspastdue
		&orgfilter.
	then do;
		output rule_20;
	end;
run;

/*Rule 21*/
/*37��������ʽΪ����Ȼ�˱�֤��δ�ϱ�������*/
/*����*/
data guarantee;
	set nfcs.sino_loan_guarantee(keep=iloanid);
run;
proc sort data=guarantee nodupkey;
	by iloanid;
run;
data sino_loan rule_21(
	keep=sorgcode
		smsgfilename
		saccount
		scertno 
		dgetdate
		ddateopened
		ddateclosed
		iguaranteeway
	);
	if _n_ eq 1 then do;
		if 0 then set guarantee(keep=iloanid);
		declare hash guar(dataset:'guarantee');
		guar.definekey('iloanid');
		guar.definedone();
	end;
	set sino_loan;
	rc=guar.find(key:iloanid);
	if iguaranteeway in (3, 5, 7) then do;
		if rc eq 0 then do;
			doubt_flag=1;
		end;
	end;
	output sino_loan;
	if iguaranteeway in (3, 5, 7) &orgfilter. then do;
		if rc eq 0 then do;
			output rule_21;
		end;
	end;
run;
/*Rule 22*/
/*39���ǿ����£����һ��"ʵ�ʻ�������"��Ӧ������"����Ӧ��������"*/
/*����*/

data sino_loan rule_22(
	keep=sorgcode
		smsgfilename
		saccount
		scertno 
		dgetdate
		ddateopened
		ddateclosed
		sTermsfreq
		dbillingdate
		drecentpaydate
		sPaystat24month
	);
	set sino_loan;
	if dbillingdate>ddateopened
		and drecentpaydate>dbillingdate
	then do;
		doubt_flag = 1;
	end;
	output sino_loan;
	if dbillingdate>ddateopened
		and drecentpaydate>dbillingdate
		&orgfilter.
	then do;
		output rule_22;
	end;
run;

/*Rule 23*/
/*40����������Ĵ��"����Ӧ������"Ӧ�õ���"ʵ�ʻ�����"*/
/*����*/
data sino_loan rule_23(
	keep=sorgcode
		smsgfilename
		saccount
		scertno 
		dgetdate
		ddateopened
		ddateclosed
		sTermsfreq
		dbillingdate
		ischeduledamount
		iactualpayamount
		iaccountstat
		sPaystat24month
	);
	set sino_loan;
	if substr(sPaystat24month,23,1) in ('*','#','/','N')
		and iaccountstat = 3
		and ischeduledamount ^= iactualpayamount
		and  ddateclosed = dbillingdate
	then do;
		error_flag = 1;
	end;
	output sino_loan;
	if substr(sPaystat24month,23,1) in ('*','#','/','N')
		and iaccountstat = 3
		and ischeduledamount ^= iactualpayamount
		and  ddateclosed = dbillingdate
		&orgfilter.
	then do;
		output rule_23;
	end;
run;
 /*Rule 24*/
/*48�������ص�Ӧ�õ����м�*/
/* ����*/
data sino_loan rule_24(
	keep=sorgcode
		smsgfilename
		saccount
		scertno 
		dgetdate
		ddateopened
		ddateclosed
		dbillingdate
 		sareacode
	);
	set sino_loan;
	if substr(sareacode, 3, 4) eq '0000' then do;
		doubet_flag=1;
	end;
	output sino_loan;
	if substr(sareacode, 3, 4) eq '0000' &orgfilter. then do;
		output rule_24;
	end;
run;

/*����У�����*/
/*Rule 25*/
/*��ʱ��*/
/*δ���Ĵ���ҵ���嵥*/
/*����*/
/*data loan_all;*/
/*	set sino_loan_all(*/
/*		keep = scertno SORGCODE saccount dgetdate DDATEOPENED DDATECLOSED DBILLINGDATE iaccountstat */
/*		where=(sorgcode like 'Q%' */
/*			and datepart(DBILLINGDATE) < today() */
/*		)*/
/*	);*/
/*	omonth=intnx('month',datepart(DDATEOPENED),0,'b');*/
/*	cmonth=intnx('month',datepart(DDATECLOSED),0,'b');*/
/*	dmonth=intnx('month',datepart(DBILLINGDATE),0,'b');*/
/*	format omonth yymmn6. cmonth yymmn6. dmonth yymmn6.;*/
/*run;*/
proc sort data=sino_loan_all(keep=sorgcode iloanid saccount scertno ddateopened ddateclosed dbillingdate iaccountstat dgetdate) out=loan_all;
	by iloanid dbillingdate dgetdate;
run;
data loan_all;
	set loan_all;
	by iloanid dbillingdate dgetdate;
	if last.iloanid;
	if iaccountstat in(1 2);
	omonth=intnx('month',datepart(ddateopened),0,'b');
	cmonth=intnx('month',datepart(ddateclosed),0,'b');
	keep sorgcode iloanid scertno omonth cmonth saccount;
run;
data dmonth;
	set loan_all;
	dmonth=&begin.;
	i=0;
	do while(dmonth lt &firstday_one.);
		dmonth=intnx('month',&begin.,i,'b');
		i+1;
		output;
	end;
	format dmonth yymmn6.;
	drop i;
run;
data rr rule_25;
	if _n_ eq 1 then do;
		if 0 then set sino_loan(keep=zhangqi iloanid);
		declare hash d(dataset:'sino_loan');
		d.definekey('zhangqi','iloanid');
		d.definedone();
	end;
	set dmonth;
	rc=d.find(key:dmonth,key:iloanid);
	if omonth le dmonth le cmonth;
	if rc &orgfilter. then output rule_25;
	output rr;
run;

/*���㼰ʱ��*/

proc sort data=rr;
	by iloanid rc;
run;
data rr_num;
	set rr;
	by iloanid rc;
	if first.iloanid;
run;
proc sort data=rr_num;
	by sorgcode iloanid;
run;
data jishi;
	set rr_num;
	by sorgcode iloanid;
	retain get;
	retain all;
	if first.sorgcode then do;
		get=0;
		all=0;
	end;
	all+1;
	if not rc then do;
		get+1;
	end;
	if last.sorgcode;
	in_per=get/all;
run;
/*����׼ȷ��*/
proc means data=sino_loan noprint;
	class sorgcode;
	var error_flag;
	output out=zhunque
		sum(error_flag)=err_num;
run;
data zhunque;
	set zhunque;
	if sorgcode ne '';
	drop _type_;
	error_per=1-err_num/_freq_;
run;
data zqx_org;
	merge zhunque jishi;
	by sorgcode;
	keep sorgcode err_num _freq_ get all error_per in_per;
	label
		err_num='��������������¼����'
		_freq_='����ҵ���¼����'
		get='�����ҵ����'
		all='Ӧ���ҵ����'
		error_per='׼ȷ��'
		in_per='��ʱ��'
	;
run;
proc sort data = zqx_org;
by desending _freq_;
run;

/*Rule 26*/
/*��ͬ�����ʹ��ͬһ����ҵ��ŵ�����*/
/*����*/
PROC SORT DATA=SINO_LOAN(KEEP=iloanid ddateopened scertno)  OUT=rule_26_t;
BY iloanid scertno;
RUN;
data rule_26_t;
	set rule_26_t;
	liloanid = lag(iloanid);
	lddateopened = lag(ddateopened);
	lscertno= lag(scertno);
	if iloanid = liloanid and ddateopened = lddateopened and scertno ^= lscertno;
run;
data sino_loan rule_26(
	keep=sorgcode
		smsgfilename
		dgetdate
		SACCOUNT
		sname
		scerttype
		scertno
		ddateopened
		dbillingdate
		icreditlimit
		ibalance
	);
	if _n_ eq 1 then do;
		if 0 then set rule_26_t(keep=iloanid);
		declare hash idonly(dataset:'rule_26_t');
		idonly.definekey('iloanid');
		idonly.definedone();
	end;
	set sino_loan;
	rc=idonly.find(key:iloanid);
	if not rc then do;
		doubt_flag=1;
	end;
	output sino_loan;
	if not rc &orgfilter. then do;
		output rule_26;
	end;
run;

/*Rule 27*/
/*ͬһ����ҵ��Ĳ�ͬ����ʹ�ò�ͬҵ��ŵ�����*/
/*����*/
PROC SORT DATA=SINO_LOAN(KEEP= iid sorgcode scertno SACCOUNT ddateopened dbillingdate icreditlimit ibalance)  OUT=rule_27_t;
BY SORGCODE scertno SACCOUNT;
RUN;
data rule_27_t;
	set rule_27_t;
	lsorgcode= lag(sorgcode);
	lscertno = lag(scertno);
	lSACCOUNT = lag(saccount);
	lICREDITLIMIT = lag(ICREDITLIMIT);
	lddateopened = lag(ddateopened);
	if sorgcode= lsorgcode and scertno = lscertno and SACCOUNT ^= lSACCOUNT and ICREDITLIMIT = lICREDITLIMIT and ddateopened = lddateopened;
run;
data sino_loan rule_27(
	keep=sorgcode
		smsgfilename
		SACCOUNT
		sname
		scerttype
		scertno
		ddateopened
		dbillingdate
		icreditlimit
		ibalance
	);
	if _n_ eq 1 then do;
		if 0 then set rule_27_t(keep=sorgcode scertno);
		declare hash iidonly(dataset:'rule_27_t');
		iidonly.definekey('sorgcode','scertno');
		iidonly.definedone();
	end;
	set sino_loan;
	rc=iidonly.find(key:sorgcode,key:scertno);
	if not rc then do;
		doubt_flag=1;
	end;
	output sino_loan;
	if not rc &orgfilter. then do;
		output rule_27;
	end;
run;
/*Rule 28*/
/*ÿ�ڻ�����*����/���Ŷ�������ʱ���߼���ϵ�������⣨�껯��������Ӧ�ô���6%-60%�ĺ���Χ�ڣ�*/
/*����*/
proc sort data = &lib..sino_loan(keep = sorgcode saccount dgetdate dbillingdate SMONTHDURATION icreditlimit ITREATYPAYAMOUNT STREATYPAYDUE WHERE=(SUBSTR(sorgcode,1,1)='Q' AND sorgcode not in ('Q10152900H0000','Q10152900H0001'))) out = rule_28_t nodupkey;
by sorgcode saccount dbillingdate;
run;
data rule_28_t;
	set rule_28_t(where = (1=1 &timefilter. &orgfilter.));
	if sorgcode =lag(sorgcode) and saccount = lag(saccount) then delete;
run;

data rule_28;
	format interest percent8.2;
	informat interest percent8.2;
	format interest_year_single percent8.2;
	informat interest_year_single percent8.2;
	format STREATYPAYDUE_num 2.;
	format ITREATYPAYAMOUNT_num best12.;
set rule_28_t;
	if STREATYPAYDUE in ('U' 'X') or ITREATYPAYAMOUNT = 'U' then delete;
	if STREATYPAYDUE = 'O' then STREATYPAYDUE_num = 1;
	STREATYPAYDUE_num = input(STREATYPAYDUE,2.);
	ITREATYPAYAMOUNT_NUM = INPUT(ITREATYPAYAMOUNT,BEST12.);
	interest = round((ITREATYPAYAMOUNT * STREATYPAYDUE / ICREDITLIMIT - 1),0.0001);
	MONTHDURATION = input(SMONTHDURATION,4.);
/*	if interest <= 0 then delete;*/
	interest_year_single = round(interest * 12 /MONTHDURATION,0.0001);
	if 0.06 <= interest_year_single <=0.6 then delete;
	label
	dgetdate = ��������
	saccount = ҵ���
	interest_year_single = �껯������(�ٷֱ�)
	STREATYPAYDUE_num = Э����������_����
	ITREATYPAYAMOUNT_num = Э���ڻ����_����
	ICREDITLIMIT = ���Ŷ��
	SMONTHDURATION = ��������
	STREATYPAYDUE = Э����������
	ITREATYPAYAMOUNT = Э���ڻ����
	dbillingdate = ����/Ӧ��������
	;
run;

data rule_28;
retain sorgcode saccount;
	set rule_28(drop = interest_year_single interest STREATYPAYDUE_num ITREATYPAYAMOUNT_num MONTHDURATION);
run;

/*Rule 29*/
/*����ҵ��ġ�����/Ӧ�������ڡ���Ӧ���ڱ����ϴ�ʱ��*/
/*����*/
proc sql;
    create table rule_29_temp as select
    T1.sorgcode label = "��������"
    ,T1.saccount label = "ҵ���",
	datepart(dgetdate) as dgetdate label = "��������" format = yymmdd10.,
	datepart(ddateopened) as ddateopened label = "��������" format = yymmdd10. informat = yymmdd10.,
	datepart(ddateclosed) as ddateclosed label = "��������" format = yymmdd10. informat = yymmdd10.
    ,T1.dbillingdate  label = "����Ӧ��������"
    ,T2.duploadtime label = "�����ϴ�ʱ��"
    from sino_loan(where = (1=1 &timefilter. &orgfilter.)) as T1
    left join nfcs.sino_msg as T2
    on T1.SMSGFILENAME = T2.SMSGFILENAME and T1.dbillingdate > T2.duploadtime and T2.duploadtime is not null
;
quit;

proc sql;
	create table rule_29 as select
	T1.sorgcode label = "��������"
	,T1.saccount label = "ҵ���",
	datepart(dgetdate) as dgetdate label = "��������" format = yymmdd10.,
datepart(ddateopened) as ddateopened label = "��������" format = yymmdd10. informat = yymmdd10.,
datepart(ddateclosed) as ddateclosed label = "��������" format = yymmdd10. informat = yymmdd10.
	,T1.dbillingdate  label = "����Ӧ��������"
	,T2.duploadtime label = "�����ϴ�ʱ��"
	from sino_loan as T1
	left join nfcs.sino_msg as T2
	on T1.SMSGFILENAME = T2.SMSGFILENAME 
	where T2.duploadtime is not null and datepart(T1.dbillingdate) > datepart(duploadtime)
	order by sorgcode,saccount,dbillingdate
;
quit;

/*Rule 30*/
/*���������Ӧ����һ������ķ�Χ�ڣ�����1990�꣬���ڱ����ϴ�ʱ��*/
/*����*/
proc sql;
	create table rule_30 as select
	T1.sorgcode label = "��������"
	,T1.saccount label = "ҵ���",
	datepart(dgetdate) as dgetdate label = "��������" format = yymmdd10.,
	datepart(ddateopened) as ddateopened label = "��������" format = yymmdd10. informat = yymmdd10.,
	datepart(ddateclosed) as ddateclosed label = "��������" format = yymmdd10. informat = yymmdd10.
	,T1.dbillingdate  label = "����Ӧ��������"
	,T2.duploadtime label = "���ļ���ʱ��"
	from sino_loan(where = (1=1 &timefilter. &orgfilter.)) as T1
	left join nfcs.sino_msg as T2
	on T1.SMSGFILENAME = T2.SMSGFILENAME 
	where T2.duploadtime is not null and datepart(T1.ddateopened) > datepart(duploadtime) or datepart(T1.ddateopened) < mdy(1,1,1990)
	order by sorgcode,saccount,dbillingdate
;
quit; 

/*Rule 31*/
/*���˻�����Ϣ�еģ����������ڡ�Ӧ���ں���ķ�Χ�ڣ�����1935�꣬����2005��*/
/*����*/
proc sql;
	create table rule_31 as select
	T1.sorgcode label = "��������"
	,T1.sname label = '����'
	,T1.scerttype label = '֤������'
	,T1.scertno label = '֤������'
	,T1.spin
	,T2.dbirthday label = '��������'
	from nfcs.sino_person_certification as T1
	left join nfcs.sino_person as T2
	on T1.spin = T2.spin and T1.sorgcode = T2.sorgcode
	where T2.dbirthday <= mdy(1,1,1935) or T2.dbirthday > mdy(1,1,2005)
;
quit;
data rule_31;
	set rule_31;
	if spin = lag(spin) then delete;
drop
spin
;
run;

/*Rule 32*/
/*���˻�����Ϣ�еģ����������ڡ�Ӧ�ú����֤�������������Ϣ����һ��*/
/*����*/
PROC SQL;
	CREATE TABLE rule_32 AS SELECT
	T1.sorgcode label = '��������'
	,T1.sname label = '����'
	,T1.scerttype label = '֤������'
	,T1.scertno label = '֤������'
	,T2.dbirthday label = "��������"
	FROM nfcs.sino_person_certification(where = (SUBSTR(SORGCODE,1,1)='Q' AND SORGCODE not in ('Q10152900H0000' 'Q10152900H0001'))) AS T1
	left JOIN nfcs.sino_person AS T2
	ON T1.spin = T2.spin and T1.sorgcode = T2.sorgcode
	where length(SCERTNO)=18 and MDY(input(SUBSTR(SCERTNO,11,2),2.),input(SUBSTR(SCERTNO,13,2),2.),input(SUBSTR(SCERTNO,7,4),4.)) ^= DATEPART(dbirthday) and scerttype ='0' and DBIRTHDAY is not null
	order by scertno
;
QUIT;
data rule_32;
	set rule_32;
	if scertno = lag(scertno) then delete;
run;

*Rule 33
/*����*/
У��24�»���״̬����ȷ��
;

data rule_33_t;
	set sino_loan(keep = iid SPAYSTAT24MONTH );
	SPAYSTAT_flag = 0;
	array SPAYSTAT{*} $1. X1-X24;
	do i =1 to 24;
	SPAYSTAT{i} = substr(SPAYSTAT24MONTH,i,1);
	end;
/*24�»���״̬������λ�����*/
	do j =2 to 24;
	if 1 <= input(SPAYSTAT{j-1},1.) <=7 and input(SPAYSTAT{j},1.) not in ('C' 'G') 
	and input(SPAYSTAT{j},1.) - input(SPAYSTAT{j-1},1.) > 1 then SPAYSTAT_flag = 1;
	else if SPAYSTAT{j-1} in ('N' '*' '/') and input(SPAYSTAT{j},1.) > 2 then SPAYSTAT_flag = 1;
	end;
drop
i
j
X1-X24
;
run; 

proc sql;
	create table rule_33 as select
 	   a.sorgcode label = "��������",
	  	smsgfilename label = "��������",
       a.saccount label = "ҵ���",
	   	   scertno label = '֤������' format = $18., 
datepart(dgetdate) as dgetdate label = "��������" format = yymmdd10.,
datepart(ddateopened) as ddateopened label = "��������" format = yymmdd10. informat = yymmdd10.,
datepart(ddateclosed) as ddateclosed label = "��������" format = yymmdd10. informat = yymmdd10.,
       a.sTermsfreq label = "����Ƶ��",
       a.dbillingdate label = "����Ӧ��������",
       a.ischeduledamount label = "����Ӧ������",
       a.iactualpayamount label = "����ʵ�ʻ�����",
	   a.iaccountstat   label = "�˻�״̬",
       a.sPaystat24month "��ʮ�ĸ��»���״̬"
	   from sino_loan(where = (1=1 &timefilter.)) as A
	   left join rule_33_t as B
	   on A.iid = B.iid
	   where B.SPAYSTAT_flag = 1
	;
quit;

/*���*/
proc sql;
	create table zqx_org as select
	T2.shortname label = "�������"
	,T2.person
/*	,sum(1,- sum(doubt_flag)/count(*)) as doubt_per label = "������׼ȷ��-����" format = percent8.2 informat = percent8.2 */
	,count(T1.sorgcode) as record_cnt label = "����ҵ���¼����"
	,sum(t1.error_flag) as record_cnt_error label = "��������������¼����"
	,1 - calculated record_cnt_error/calculated record_cnt as error_per label = "׼ȷ��" format = percent8.2 informat = percent8.2
	,T2.total
	,t2.in_nfcs
	,T2.in_per
	from sino_loan as T1
	left join _loan_m_sta_ as T2
	on T1.sorgcode = T2.sorgcode
	group by T1.sorgcode
;
quit;
data zqx_org;
	set zqx_org;
	if sorgcode = lag(sorgcode) then delete;
run;
proc sort data = zqx_org;
by desending record_cnt;
run;
%chkfile(&outfile.);

/*ods listing off;*/
 ods tagsets.excelxp file = "&outfile.�����߼�У�������_&currmonth..xls" style = printer
      options(sheet_name="�����߼�У�������" embedded_titles='yes' embedded_footnotes='yes' sheet_interval="bygroup" frozen_headers='yes' frozen_rowheaders='1' autofit_height='yes');
proc report data = zqx_org NOWINDOWS headline headskip
          style(header)={background=lightgray foreground=black font_weight=bold};
title "�����߼�У�������";
	columns _all_;
	define person /display 'ר��Ա';
	define shortname/ display width=5;
	define record_cnt_error/ display '�������������/��¼����';
	define in_per/display center;
	define error_per/display center;
	compute after;
 	if in_per >= 0.9 and error_per >= 0.99 then 
 		call define(_row_,'style','style={background=lightyellow fontweight=bold}');
 	endcomp;
footnote '��׼ȷ�ʡ�����������Ϊ�����󡿵Ĺ���';
run;
ods tagsets.excelxp close;
  ods listing;


