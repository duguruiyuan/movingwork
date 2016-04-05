
%MACRO OVERDUE_ANALYSIS(STAT_DT);
/*T-1�������������������*/
PROC SQL;
	CREATE TABLE LOAN_OVERDUE_N AS SELECT
		SLOANTYPE 
		,SUM(ICREDITLIMIT)/10000 AS LOAN_TOTAL
		,SUM(CASE WHEN SACCOUNT^=''  THEN 1 ELSE 0 END) AS LOAN_CNT
		,SUM(IAMOUNTPASTDUE)/10000 AS DUE_TOTAL
		,SUM(CASE WHEN IAMOUNTPASTDUE>0 THEN 1 ELSE 0 END) AS DUE_TOTAL_CNT
		,SUM(IAMOUNTPASTDUE30)/10000 AS DUE_30
		,SUM(CASE WHEN IAMOUNTPASTDUE30>0 THEN 1 ELSE 0 END) AS DUE_30_CNT
		,SUM(IAMOUNTPASTDUE60)/10000 AS DUE_60
		,SUM(CASE WHEN IAMOUNTPASTDUE60>0 THEN 1 ELSE 0 END) AS DUE_60_CNT
		,SUM(IAMOUNTPASTDUE90)/10000 AS DUE_90
		,SUM(CASE WHEN IAMOUNTPASTDUE90>0 THEN 1 ELSE 0 END) AS DUE_90_CNT
		,SUM(IAMOUNTPASTDUE180)/10000 AS DUE_180
		,SUM(CASE WHEN IAMOUNTPASTDUE180>0 THEN 1 ELSE 0 END) AS DUE_180_CNT
	FROM loan_n
	GROUP BY SLOANTYPE;
QUIT;

proc means data=LOAN_OVERDUE_N noprint;
 class SLOANTYPE;
 var LOAN_TOTAL LOAN_CNT DUE_TOTAL DUE_TOTAL_CNT DUE_30 DUE_30_CNT DUE_60 DUE_60_CNT DUE_90 DUE_90_CNT DUE_180 DUE_180_CNT;
 output out=LOAN_OVERDUE_N
        sum(LOAN_TOTAL LOAN_CNT DUE_TOTAL DUE_TOTAL_CNT DUE_30 DUE_30_CNT DUE_60 DUE_60_CNT DUE_90 DUE_90_CNT DUE_180 DUE_180_CNT)
		   =LOAN_TOT_n LOAN_C_n DUE_TOT_n DUE_TOTAL_C_n D_30_n D_30_CNT_n D_60_n D_60_CNT_n D_90_n D_90_CNT_n D_180_n D_180_CNT_n;
run;
/*T-2�������������������*/
PROC SQL;
	CREATE TABLE LOAN_OVERDUE_O AS SELECT
		SLOANTYPE 
		,SUM(ICREDITLIMIT)/10000 AS LOAN_TOTAL
		,SUM(CASE WHEN SACCOUNT ^= '' THEN 1 ELSE 0 END) AS LOAN_CNT
		,SUM(IAMOUNTPASTDUE)/10000 AS DUE_TOTAL
		,SUM(CASE WHEN IAMOUNTPASTDUE>0 THEN 1 ELSE 0 END) AS DUE_TOTAL_CNT
		,SUM(IAMOUNTPASTDUE30)/10000 AS DUE_30
		,SUM(CASE WHEN IAMOUNTPASTDUE30>0 THEN 1 ELSE 0 END) AS DUE_30_CNT
		,SUM(IAMOUNTPASTDUE60)/10000 AS DUE_60
		,SUM(CASE WHEN IAMOUNTPASTDUE60>0 THEN 1 ELSE 0 END) AS DUE_60_CNT
		,SUM(IAMOUNTPASTDUE90)/10000 AS DUE_90
		,SUM(CASE WHEN IAMOUNTPASTDUE90>0 THEN 1 ELSE 0 END) AS DUE_90_CNT
		,SUM(IAMOUNTPASTDUE180)/10000 AS DUE_180
		,SUM(CASE WHEN IAMOUNTPASTDUE180>0 THEN 1 ELSE 0 END) AS DUE_180_CNT
	FROM loan_O
	GROUP BY SLOANTYPE;
QUIT;

proc means data=LOAN_OVERDUE_o noprint;
 class SLOANTYPE;
 var LOAN_TOTAL LOAN_CNT DUE_TOTAL DUE_TOTAL_CNT DUE_30 DUE_30_CNT DUE_60 DUE_60_CNT DUE_90 DUE_90_CNT DUE_180 DUE_180_CNT;
 output out=LOAN_OVERDUE_o
        sum(LOAN_TOTAL LOAN_CNT DUE_TOTAL DUE_TOTAL_CNT DUE_30 DUE_30_CNT DUE_60 DUE_60_CNT DUE_90 DUE_90_CNT DUE_180 DUE_180_CNT)
		   =LOAN_TOT_o LOAN_C_o DUE_TOT_o DUE_TOTAL_C_o D_30_o D_30_CNT_o D_60_o D_60_CNT_o D_90_o D_90_CNT_o D_180_o D_180_CNT_o;
run;

/*�ۺϴ���*/
data loan_overdue(drop=_freq_ _type_);
 merge LOAN_OVERDUE_N LOAN_OVERDUE_o;
 by SLOANTYPE;
run;
/*O01���������*/
data O01(drop=due_amt due_cnt DUE_TOTAL_C_o DUE_TOT_o);
 format
  sloantype $LOAN_LEVEL.
  DUE_TOTAL_C_n 8.
  prop_cnt percentn8.2
  add_cnt percentn8.2
  DUE_TOT_n 8.2
  prop_amt percentn8.2
  add_amt percentn8.2
  per_n 8.2
  per_o 8.2
 ;
 label
  sloantype='��������'
  DUE_TOTAL_C_n='���е��������˻���'
  prop_cnt='���������˻���ռ��'
  add_cnt='���������˻�������������'
  DUE_TOT_n='�������ڽ��'
  prop_amt='�������ڽ��ռ��'
  add_amt='���ڽ���������'
  per_n='����ƽ�����ڽ��'
  per_o='����ƽ�����ڽ��'
 ;
 if _n_ eq 1 then set loan_overdue(where=(sloantype eq '') 
                                   keep=sloantype due_total_c_n due_tot_n 
                                   rename=(due_total_c_n=due_cnt due_tot_n=due_amt));
 set loan_overdue(where=(sloantype ne '') keep=sloantype DUE_TOT_n DUE_TOTAL_C_n DUE_TOT_o DUE_TOTAL_C_o)
     loan_overdue(where=(sloantype eq '') keep=sloantype DUE_TOT_n DUE_TOTAL_C_n DUE_TOT_o DUE_TOTAL_C_o);
 
 prop_cnt=DUE_TOTAL_C_n/due_cnt;
 prop_amt=DUE_TOT_n/due_amt;
 add_cnt=DUE_TOTAL_C_n/DUE_TOTAL_C_o-1;
 add_amt=DUE_TOT_n/DUE_TOT_o-1;
 per_n=DUE_TOT_n/DUE_TOTAL_C_n;
 per_o=DUE_TOT_o/DUE_TOTAL_C_o;
 if sloantype eq '' then sloantype='�ϼ�';
run;



/*O02������*/
data O02(drop=DUE_TOT_n DUE_TOT_o LOAN_TOT_n LOAN_TOT_o);
 format
  sloantype $LOAN_LEVEL.
  due_n percentn8.2
  due_o percentn8.2
  add percentn8.2
 ;
 label
  sloantype='��������'
  due_n='���е���������'
  due_o='��������������'
  add='�����ʵĻ��ȱ仯��'
 ;
 set loan_overdue(where=(sloantype ne '') keep=sloantype DUE_TOT_n DUE_TOT_o LOAN_TOT_n LOAN_TOT_o)
     loan_overdue(where=(sloantype eq '') keep=sloantype DUE_TOT_n DUE_TOT_o LOAN_TOT_n LOAN_TOT_o);
 due_n=DUE_TOT_n/LOAN_TOT_n;
 due_o=DUE_TOT_o/LOAN_TOT_o;
 add=due_n/due_o-1;
 if sloantype eq '' then sloantype='�ϼ�';
run;


/*O03����31_60��*/
data O03(drop=due_amt due_cnt d_30_cnt_o d_30_o);
 format
  sloantype $LOAN_LEVEL.
  d_30_cnt_n 8.
  prop_cnt percentn8.2
  add_cnt percentn8.2
  d_30_n 8.2
  prop_amt percentn8.2
  add_amt percentn8.2
  per_n 8.2
  per_o 8.2
 ;
 label
  sloantype='��������'
  d_30_cnt_n='����30-60�������˻���'
  prop_cnt='���������˻���ռ��'
  add_cnt='���������˻�������������'
  d_30_n='����30-60�����ڽ��'
  prop_amt='���ڽ��ռ��'
  add_amt='���ڽ���������'
  per_n='����ƽ�����ڽ��'
  per_o='����ƽ�����ڽ��'
 ;
 if _n_ eq 1 then set loan_overdue(where=(sloantype eq '') 
                                   keep=sloantype d_30_cnt_n d_30_n 
                                   rename=(d_30_cnt_n=due_cnt d_30_n=due_amt));
 set loan_overdue(where=(sloantype ne '') keep=sloantype d_30_n d_30_cnt_n d_30_o d_30_cnt_o)
     loan_overdue(where=(sloantype eq '') keep=sloantype d_30_n d_30_cnt_n d_30_o d_30_cnt_o);
 
 prop_cnt=d_30_cnt_n/due_cnt;
 prop_amt=d_30_n/due_amt;
 add_cnt=d_30_cnt_n/d_30_cnt_o-1;
 add_amt=d_30_n/d_30_o-1;
 per_n=d_30_n/d_30_cnt_n;
 per_o=d_30_o/d_30_cnt_o;
 if sloantype eq '' then sloantype='�ϼ�';
run;

/*O04����61_90��*/
data O04(drop=due_amt due_cnt d_60_cnt_o d_60_o);
 format
  sloantype $LOAN_LEVEL.
  d_60_cnt_n 8.
  prop_cnt percentn8.2
  add_cnt percentn8.2
  d_60_n 8.2
  prop_amt percentn8.2
  add_amt percentn8.2
  per_n 8.2
  per_o 8.2
 ;
 label
  sloantype='��������'
  d_60_cnt_n='����60-90�������˻���'
  prop_cnt='���������˻���ռ��'
  add_cnt='���������˻�������������'
  d_60_n='����60-90�����ڽ��'
  prop_amt='���ڽ��ռ��'
  add_amt='���ڽ���������'
  per_n='����ƽ�����ڽ��'
  per_o='����ƽ�����ڽ��'
 ;
 if _n_ eq 1 then set loan_overdue(where=(sloantype eq '') 
                                   keep=sloantype d_60_cnt_n d_60_n 
                                   rename=(d_60_cnt_n=due_cnt d_60_n=due_amt));
 set loan_overdue(where=(sloantype ne '') keep=sloantype d_60_n d_60_cnt_n d_60_o d_60_cnt_o)
     loan_overdue(where=(sloantype eq '') keep=sloantype d_60_n d_60_cnt_n d_60_o d_60_cnt_o);
 
 prop_cnt=d_60_cnt_n/due_cnt;
 prop_amt=d_60_n/due_amt;
 add_cnt=d_60_cnt_n/d_60_cnt_o-1;
 add_amt=d_60_n/d_60_o-1;
 per_n=d_60_n/d_60_cnt_n;
 per_o=d_60_o/d_60_cnt_o;
 if sloantype eq '' then sloantype='�ϼ�';
run;

/*O05����91_180��*/
data O05(drop=due_amt due_cnt d_90_cnt_o d_90_o);
 format
  sloantype $LOAN_LEVEL.
  d_90_cnt_n 8.
  prop_cnt percentn8.2
  add_cnt percentn8.2
  d_90_n 8.2
  prop_amt percentn8.2
  add_amt percentn8.2
  per_n 8.2
  per_o 8.2
 ;
 label
  sloantype='��������'
  d_90_cnt_n='����90-180�������˻���'
  prop_cnt='���������˻���ռ��'
  add_cnt='���������˻�������������'
  d_90_n='����90-180�����ڽ��'
  prop_amt='���ڽ��ռ��'
  add_amt='���ڽ���������'
  per_n='����ƽ�����ڽ��'
  per_o='����ƽ�����ڽ��'
 ;
 if _n_ eq 1 then set loan_overdue(where=(sloantype eq '') 
                                   keep=sloantype d_90_cnt_n d_90_n 
                                   rename=(d_90_cnt_n=due_cnt d_90_n=due_amt));
 set loan_overdue(where=(sloantype ne '') keep=sloantype d_90_n d_90_cnt_n d_90_o d_90_cnt_o)
     loan_overdue(where=(sloantype eq '') keep=sloantype d_90_n d_90_cnt_n d_90_o d_90_cnt_o);
 
 prop_cnt=d_90_cnt_n/due_cnt;
 prop_amt=d_90_n/due_amt;
 add_cnt=d_90_cnt_n/d_90_cnt_o-1;
 add_amt=d_90_n/d_90_o-1;
 per_n=d_90_n/d_90_cnt_n;
 per_o=d_90_o/d_90_cnt_o;
 if sloantype eq '' then sloantype='�ϼ�';
run;

/*O06����180������*/
data O06(drop=due_amt due_cnt d_180_cnt_o d_180_o);
 format
  sloantype $LOAN_LEVEL.
  d_180_cnt_n 8.
  prop_cnt percentn8.2
  add_cnt percentn8.2
  d_180_n 8.2
  prop_amt percentn8.2
  add_amt percentn8.2
  per_n 8.2
  per_o 8.2
 ;
 label
  sloantype='��������'
  d_180_cnt_n='����180�����������˻���'
  prop_cnt='���������˻���ռ��'
  add_cnt='���������˻�������������'
  d_180_n='����180���������ڽ��'
  prop_amt='���ڽ��ռ��'
  add_amt='���ڽ���������'
  per_n='����ƽ�����ڽ��'
  per_o='����ƽ�����ڽ��'
 ;
 if _n_ eq 1 then set loan_overdue(where=(sloantype eq '') 
                                   keep=sloantype d_180_cnt_n d_180_n 
                                   rename=(d_180_cnt_n=due_cnt d_180_n=due_amt));
 set loan_overdue(where=(sloantype ne '') keep=sloantype d_180_n d_180_cnt_n d_180_o d_180_cnt_o)
     loan_overdue(where=(sloantype eq '') keep=sloantype d_180_n d_180_cnt_n d_180_o d_180_cnt_o);
 
 prop_cnt=d_180_cnt_n/due_cnt;
 prop_amt=d_180_n/due_amt;
 add_cnt=d_180_cnt_n/d_180_cnt_o-1;
 add_amt=d_180_n/d_180_o-1;
 per_n=d_180_n/d_180_cnt_n;
 per_o=d_180_o/d_180_cnt_o;
 if sloantype eq '' then sloantype='�ϼ�';
run;



 
/*����ʱ��������� ADD BY TIANYANQIN 2014.12.05
�����ڽ������������Ҫ�Լ�����������
���㷨��Щ�ظ�������*/
/*����O07������*/
PROC SQL NOPRINT;
	CREATE TABLE O07_MONEY AS SELECT
		OPEN_DUR_CD,
		SUM(ICREDITLIMIT) AS ALL,
		SUM(iamountpastdue) AS DUE_ALL,
		SUM(iamountpastdue) - SUM(Iamountpastdue30) - SUM(Iamountpastdue60) - SUM(Iamountpastdue90) - SUM(Iamountpastdue180) AS DUE_1_30,
		SUM(Iamountpastdue30) AS DUE_31_60,
		SUM(Iamountpastdue60) AS DUE_61_90,
		SUM(Iamountpastdue90) AS DUE_91_180,
		SUM(Iamountpastdue180) AS DUE_180_
	FROM loan_n
	GROUP BY OPEN_DUR_CD
    order by OPEN_DUR_CD desc
    ;
QUIT;

DATA O07;
	SET O07_MONEY;
		OVERDUE_ALL=PUT(DUE_ALL/ALL,percent8.2);
		OVERDUE_1_30=PUT(DUE_1_30/ALL,percent8.2);
		OVERDUE_31_60=PUT(DUE_31_60/ALL,percent8.2);
		OVERDUE_61_90=PUT(DUE_61_90/ALL,percent8.2);
		OVERDUE_91_180=PUT(DUE_91_180/ALL,percent8.2);
		OVERDUE_180_=PUT(DUE_180_/ALL,percent8.2);
		DROP ALL DUE_ALL  DUE_1_30 DUE_31_60 DUE_61_90 DUE_91_180  DUE_180_;
	LABEL
	OPEN_DUR_CD="����ҵ���ڼ�"
		OVERDUE_ALL="������"
OVERDUE_1_30="1-30��������"
OVERDUE_31_60="31-60��������"
OVERDUE_61_90="61-90��������"
OVERDUE_91_180="91_180��������"
OVERDUE_180_="180������������"
;
run;

/*�����˻��������漰���ظ�����*/
/*PROC SQL NOPRINT;*/
/*	CREATE TABLE O07_BUSS AS SELECT*/
/*		OPEN_DUR_CD*/
/*		,SUM(CASE WHEN ICREDITLIMIT^=0  THEN 1 ELSE 0 END) AS ALL*/
/*		,SUM(CASE WHEN Iamountpastdue180^=0   THEN 1 ELSE 0 END) AS DUE_180_*/
/*		,SUM(CASE WHEN Iamountpastdue180=0 AND Iamountpastdue90^=0  THEN 1 ELSE 0 END ) AS DUE_91_180*/
/*		,SUM(CASE WHEN Iamountpastdue180=0 AND Iamountpastdue90=0 AND Iamountpastdue60^=0   THEN 1 ELSE 0 END) AS DUE_61_90*/
/*		,SUM(CASE WHEN Iamountpastdue180=0 AND Iamountpastdue90=0 AND Iamountpastdue60=0 AND  Iamountpastdue30^=0  THEN 1 ELSE 0 END) AS DUE_31_60*/
/*		,SUM(CASE WHEN Iamountpastdue180=0 AND Iamountpastdue90=0 AND Iamountpastdue60=0 AND  Iamountpastdue30=0 AND iamountpastdue^=0  THEN 1 ELSE 0 END) AS DUE_30*/
/*	FROM Sino_loan_n3*/
/*	GROUP BY OPEN_DUR_CD;*/
/*QUIT;*/

/*
%LET LAST_DT=INTNX('MONTH',&STAT_DT,-1,'END');
*/
/*STEP2 ������ϴ����ȡ���¼���������*/
/*
PROC SORT DATA=SSS.SINO_LOAN(WHERE=(SUBSTR(SORGCODE,1,1)='Q' AND SORGCODE^='Q10152900H0000' AND DATEPART(DGETDATE)<=&STAT_DT.))  OUT=SINO_LOAN_N1;
	BY SORGCODE SACCOUNT DGETDATE;
RUN;
SUM(CASE WHEN SACCOUNT^=''  THEN 1 ELSE 0 END) AS LOAN_CNT

*/

/*����м���O07 ��� 2015-02-05*/

%MEND;
