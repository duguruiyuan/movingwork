

%MACRO AREA_ANALYSIS(STAT_DT);


/*T-1���ۺ����ݴ���*/

PROC SQL;
	CREATE TABLE LOANAREA_N AS SELECT
		A1.ORGAREA LABEL="ʡ��"
		,COUNT(DISTINCT SORGCODE) AS ORG_CNT_N LABEL="���»�������"
		,SUM(CASE WHEN SACCOUNT^="" THEN 1 ELSE 0 END) AS LOAN_CNT_N LABEL="���´���ҵ����"
		,round(SUM(ICREDITLIMIT)/10000,0.01) AS LOAN_AMT_N LABEL="���´�����"
		,round(SUM(IBALANCE)/10000,0.01) AS LOAN_BAL_N LABEL="���´�������" 
		,COUNT(DISTINCT SPIN) AS CUST_CNT_N  LABEL="���´���ͻ���"
		,SUM(CASE WHEN IAMOUNTPASTDUE^=0 THEN 1 ELSE 0 END) AS OWE_CNT_N LABEL="���������˻���"
		,round(SUM(IAMOUNTPASTDUE)/10000,0.01) AS OWE_AMT_N  LABEL="���������ܶ�"
		,COALESCE(A2.NEW_CUST_CNT_N,0)  AS NEW_CUST_CNT_N LABEL="�����¿��ͻ���"
		,0 as prop_n label='���¸�ʡ��ռ��'
	FROM LOAN_N AS A1
		LEFT JOIN (
			SELECT
				ORGAREA
				,COUNT(DISTINCT SPIN) AS NEW_CUST_CNT_N
			FROM LOAN_N(WHERE=(IINFOINDICATOR=2)) 
			GROUP BY ORGAREA) AS A2
		ON A1.ORGAREA =A2.ORGAREA 
	GROUP BY A1.ORGAREA
	;
QUIT;
proc sort data=loanarea_n;
 by orgarea;
run;

proc means data=apply_n sum noprint;
 class orgarea;
 var imoney;
 output out=apply_sum_n(drop=_type_ rename=(_freq_=apply_cnt_n)) sum(imoney)=apply_amt_n;
run;
proc sort data=apply_sum_n;
 by orgarea;
run;

proc means data=spec_n sum noprint;
 class orgarea;
 var ioccursum;
 output out=spec_sum_n(drop=_type_ rename=(_freq_=spec_cnt_n)) sum(ioccursum)=spec_amt_n;
run;
proc sort data=apply_sum_n;
 by orgarea;
run;

proc freq data=spec_n noprint;
 tables orgarea/out=lz_account_n(drop=percent rename=(count=lz_account_n));
run;
proc sort data=spec_n out=spec_lz_n nodupkey;
 by orgarea scertno;
run;
proc freq data=spec_lz_n noprint;
 tables orgarea/out=lz_cust_n(drop=percent rename=(count=lz_cust_n));
run;

/*T-2���ۺ����ݴ���*/
PROC SQL;
	CREATE TABLE LOANAREA_O AS SELECT
		A1.ORGAREA LABEL="ʡ��"
		,COUNT(DISTINCT SORGCODE) AS ORG_CNT_O LABEL="���»�������"
		,SUM(CASE WHEN SACCOUNT^="" THEN 1 ELSE 0 END) AS LOAN_CNT_O LABEL="���´���ҵ����"
		,SUM(ICREDITLIMIT)/10000 AS LOAN_AMT_O LABEL="���´�����"
		,SUM(IBALANCE)/10000 AS LOAN_BAL_O LABEL="���´�������" 
		,COUNT(DISTINCT SCERTNO) AS CUST_CNT_O  LABEL="���´���ͻ���"
		,SUM(CASE WHEN IAMOUNTPASTDUE^=0 THEN 1 ELSE 0 END) AS OWE_CNT_O LABEL="���������˻���"
		,SUM(IAMOUNTPASTDUE)/10000 AS OWE_AMT_O  LABEL="���������ܶ�"
		,COALESCE(A2.NEW_CUST_CNT_O,0)  AS NEW_CUST_CNT_O LABEL="�����¿��ͻ���"
		,0 as prop_o label='���¸�ʡ��ռ��'
	FROM LOAN_O AS A1
		LEFT JOIN (
			SELECT
				ORGAREA
				,COUNT(DISTINCT SCERTNO) AS NEW_CUST_CNT_O 
			FROM LOAN_O(WHERE=(IINFOINDICATOR=2)) 
			GROUP BY ORGAREA) AS A2
		ON A1.ORGAREA =A2.ORGAREA 
	GROUP BY A1.ORGAREA
	;
QUIT;
proc sort data=loanarea_o;
 by orgarea;
run;

proc means data=apply_o sum noprint;
 class orgarea;
 var imoney;
 output out=apply_sum_o(drop=_type_ rename=(_freq_=apply_cnt_o)) sum(imoney)=apply_amt_o;
run;
proc sort data=apply_sum_o;
 by orgarea;
run;

proc means data=spec_o sum noprint;
 class orgarea;
 var ioccursum;
 output out=spec_sum_o(drop=_type_ rename=(_freq_=spec_cnt_o)) sum(ioccursum)=spec_amt_o;
run;
proc sort data=apply_sum_o;
 by orgarea;
run;

proc freq data=spec_o noprint;
 tables orgarea/out=lz_account_o(drop=percent rename=(count=lz_account_o));
run;
proc sort data=spec_o out=spec_lz_o nodupkey;
 by orgarea scertno;
run;
proc freq data=spec_lz_o noprint;
 tables orgarea/out=lz_cust_o(drop=percent rename=(count=lz_cust_o));
run;

/*�ۺ����ݴ���*/

data loanarea_sum;
 merge loanarea_n loanarea_o;
 by orgarea;
run;
proc means data=loanarea_sum sum noprint;
 class orgarea;
 var  ORG_CNT_N LOAN_CNT_N LOAN_AMT_N LOAN_BAL_N CUST_CNT_N OWE_CNT_N OWE_AMT_N NEW_CUST_CNT_N prop_n
      ORG_CNT_O LOAN_CNT_O LOAN_AMT_O LOAN_BAL_O CUST_CNT_O OWE_CNT_O OWE_AMT_O NEW_CUST_CNT_O prop_o;
 output out=loan_sum(drop=_type_ _freq_ where=(orgarea eq '')) 
        sum(ORG_CNT_N LOAN_CNT_N LOAN_AMT_N LOAN_BAL_N CUST_CNT_N OWE_CNT_N OWE_AMT_N NEW_CUST_CNT_N prop_n
            ORG_CNT_O LOAN_CNT_O LOAN_AMT_O LOAN_BAL_O CUST_CNT_O OWE_CNT_O OWE_AMT_O NEW_CUST_CNT_O prop_o
          )=org_CNT_N LOAN_CNT_N LOAN_AMT_N LOAN_BAL_N CUST_CNT_N OWE_CNT_N OWE_AMT_N NEW_CUST_CNT_N prop_n
            org_CNT_O LOAN_CNT_O LOAN_AMT_O LOAN_BAL_O CUST_CNT_O OWE_CNT_O OWE_AMT_O NEW_CUST_CNT_O prop_o;
run;


data apply_orgarea_sum;
 merge apply_sum_n apply_sum_o;
 by orgarea;
 if orgarea eq '' then orgarea='�ϼ�';
 apply_amt_n=apply_amt_n/10000;
 apply_amt_o=apply_amt_o/10000;
run;

data spec_orgarea_sum;
 merge spec_sum_n spec_sum_o;
 by orgarea;
 if orgarea eq '' then orgarea='�ϼ�';
 spec_amt_n=spec_amt_n/10000;
 spec_amt_o=spec_amt_o/10000;
run;

data lz;
 merge lz_account_n lz_cust_n lz_account_o lz_cust_o;
 by orgarea;
run;
proc means data=lz sum noprint;
 class orgarea;
 var lz_account_n lz_account_o lz_cust_n lz_cust_o;
 output out=lz_sum(drop=_type_ _freq_ where=(orgarea eq '')) 
        sum(lz_account_n lz_account_o lz_cust_n lz_cust_o)=lz_account_n lz_account_o lz_cust_n lz_cust_o;
run;


/*1.	D01��ͬʡ�з�������ҵ��Ļ����ֲ������*/
proc sort data=loanarea_sum;
 by descending org_cnt_n;
run;
data d01(keep=orgarea org_cnt_n prop_n org_cnt_o prop_o orgadd_r);
 if _n_ eq 1 then set loan_sum(keep=orgarea org_cnt_n org_cnt_o rename=(org_cnt_n=cnt_n org_cnt_o=cnt_o));
 set loanarea_sum loan_sum;
 if orgarea eq '' then orgarea='�ϼ�';
 prop_n=org_cnt_n/cnt_n;
 prop_o=org_cnt_o/cnt_o;
 orgadd_r=org_cnt_n/org_cnt_o-1;
 label orgadd_r='���л�����������������';
 format prop_n percent8.2 prop_o percent8.2 orgadd_r percent8.2;
run;
/*2.	D02��ͬʡ�еĴ����˻���������ֲ������*/
proc sort data=loanarea_sum;
 by descending loan_cnt_n;
run;
data d02(keep=orgarea loan_cnt_n loan_amt_n prop_cnt prop_amt orgadd_cnt orgadd_amt per_n per_o);
 format orgarea $8. loan_cnt_n 8. prop_cnt percentn8.2 orgadd_cnt percentn8.2 loan_amt_n 8. prop_amt percentn8.2 orgadd_amt percentn8.2 per_n 8.2 per_o 8.2;
 if _n_ eq 1 then set loan_sum(keep=orgarea loan_cnt_n loan_cnt_o loan_amt_n loan_amt_o rename=(loan_cnt_n=cnt_n loan_amt_n=amt_n));
 set loanarea_sum loan_sum;
 if orgarea eq '' then orgarea='�ϼ�';
 prop_cnt=loan_cnt_n/cnt_n;
 prop_amt=loan_amt_n/amt_n;
 orgadd_cnt=loan_cnt_n/loan_cnt_o-1;
 orgadd_amt=loan_amt_n/loan_amt_o-1;
 per_n=loan_amt_n/loan_cnt_n;
 per_o=loan_amt_o/loan_cnt_o;
 label prop_cnt='���д����˻���ռ��'
       prop_amt='���д�����ռ��'
       orgadd_cnt='���д����˻�������������'
       orgadd_amt='���д������������'
       per_n='�����˻�ƽ��������'
       per_o='�����˻�ƽ��������';
run;


/*3.	D03��ͬʡ�еĴ���ͻ����ֲ������*/
proc sort data=loanarea_sum;
 by descending cust_cnt_n;
run;
data d03(keep=orgarea cust_cnt_n cust_cnt_o prop_n prop_o per_n per_o add);
 if _n_ eq 1 then set loan_sum(keep=orgarea cust_cnt_n cust_cnt_o rename=(cust_cnt_n=cust_n cust_cnt_o=cust_o));
 set loanarea_sum loan_sum;
 if orgarea eq '' then orgarea='�ϼ�';
 prop_n=cust_cnt_n/cust_n;
 prop_o=cust_cnt_o/cust_o;
 per_n=loan_cnt_n/cust_cnt_n;
 per_o=loan_cnt_o/cust_cnt_o;
 add=cust_cnt_n/cust_cnt_o-1;
 label prop_n='���¸�ʡ��ռ��'
       prop_o='���¸�ʡ��ռ��'
       per_n='����ÿ�ͻ�ƽ���˻���'
       per_o='����ÿ�ͻ�ƽ���˻���'
       add='����������';
 format prop_n percentn8.2 prop_o percentn8.2 add percentn8.2 per_n 8.2 per_o 8.2;
run;

/*4.	D04��ͬʡ�еĴ��������˻������ڽ��ֲ������*/
proc sort data=loanarea_sum;
 by descending owe_cnt_n;
run;
data d04(keep=orgarea owe_cnt_n loan_cnt_n owe_amt_n loan_amt_n prop_cnt prop_amt per_owe per_loan);
 format orgarea $8. owe_cnt_n 8. loan_cnt_n 8. prop_cnt percent8.2 owe_amt_n 8. loan_amt_n 8. prop_amt percent8.2 per_owe 8.2 per_loan 8.2;
 set loanarea_sum loan_sum;
 prop_cnt=owe_cnt_n/loan_cnt_n;
 prop_amt=owe_amt_n/loan_amt_n;
 per_owe=owe_amt_n/owe_cnt_n;
 per_loan=loan_amt_n/loan_cnt_n;
 if orgarea eq '' then orgarea='�ϼ�';
 label prop_cnt='�����˻���ռ���˻�������'
       prop_amt='���ڽ��ռ���������'
	   per_owe='�����˻�ƽ�����ڽ��'
	   per_loan='�����˻�ƽ��������';
run;

/*5.	D05��ͬʡ�еĴ����¿��ͻ����ֲ������*/
/*PROC SQL;*/
/*	CREATE TABLE D05 AS SELECT*/
/*		A1.ORGAREA*/
/*		,A1.NEW_CUST_CNT AS NEW_CNT_N LABEL="���е����ۼ��¿��ͻ���"*/
/*		,PUT(A1.NEW_CUST_CNT/A1.CUST_CNT,PERCENTN8.2) AS NEWCNT_R_N LABEL="�����¿��ͻ���ռ�ܿͻ�������"*/
/*		,COALESCE(A2.NEW_CUST_CNT,0) AS NEW_CNT_O LABEL="���������ۼ��¿��ͻ���"*/
/*		,PUT(A2.NEW_CUST_CNT/A2.CUST_CNT,PERCENTN8.2) AS NEWCNT_R_O LABEL="�����¿��ͻ���ռ�ܿͻ�������"*/
/*		,PUT(A1.NEW_CUST_CNT/A2.NEW_CUST_CNT-1,PERCENTN8.2) AS NEWCNTADD_R LABEL="�����¿��ͻ�������������"*/
/*	FROM LOANAREA_N AS A1*/
/*	LEFT JOIN LOANAREA_O AS A2*/
/*	ON A1.ORGAREA =A2.ORGAREA */
/*	ORDER BY NEW_CNT_N DESC;*/
/*	DELETE FROM D05 WHERE NEW_CNT_N=0;*/
/*QUIT;*/

/*6.	D06��ͬʡ�еĴ�����������������ֲ������*/


proc sort data=apply_orgarea_sum(where=(orgarea ne '�ϼ�')) out=apl_area_sum;
 by descending apply_cnt_n;
run;
data d06(drop=cnt_n amt_n apply_cnt_o apply_amt_o);
 format orgarea $8. 
        apply_cnt_n 8. 
        prop_cnt percentn8.2 
        add_cnt percentn8.2 
        apply_amt_n 8.2 
        prop_amt percentn8.2 
        add_amt percentn8.2 
        per_n 8.2 
        per_o 8.2;
 label orgarea='ʡ��' 
       apply_cnt_n='�����ۼƴ���������' 
       prop_cnt='����������ռ��' 
       add_cnt='��������������������' 
       apply_amt_n='�����ۼƴ���������' 
       prop_amt='����������ռ��' 
       add_amt='�����������������'
	   per_n='�����˻�ƽ��������'
	   per_o='�����˻�ƽ��������';
 if _n_ eq 1 then set apply_orgarea_sum(keep=orgarea apply_cnt_n apply_amt_n rename=(apply_cnt_n=cnt_n apply_amt_n=amt_n) 
                                        where=(orgarea='�ϼ�'));
 set apl_area_sum apply_orgarea_sum(where=(orgarea eq '�ϼ�'));
 prop_cnt=apply_cnt_n/cnt_n;
 prop_amt=apply_amt_n/amt_n;
 add_cnt=apply_cnt_n/apply_cnt_o-1;
 add_amt=apply_amt_n/apply_amt_o-1;
 per_n=apply_amt_n/apply_cnt_n;
 per_o=apply_amt_o/apply_cnt_o;
run;

/*7.	D07��ͬʡ�е����⽻��ҵ���������⽻�׽��ֲ������*/
proc sort data=spec_orgarea_sum(where=(orgarea ne '�ϼ�')) out=spec_area_sum;
 by descending spec_cnt_n;
run;
data d07(drop=cnt_n amt_n spec_cnt_o spec_amt_o);
 format orgarea $8. 
        spec_cnt_n 8. 
        prop_cnt percentn8.2 
        add_cnt percentn8.2 
        spec_amt_n 8.2 
        prop_amt percentn8.2 
        add_amt percentn8.2 
        per_n 8.2 
        per_o 8.2;
 label orgarea='ʡ��' 
       spec_cnt_n='�����ۼ����⽻��ҵ����' 
       prop_cnt='���⽻����ռ��' 
       add_cnt='���⽻�׻���������' 
       spec_amt_n='�����ۼ����⽻�׽��' 
       prop_amt='���⽻�׽��ռ��' 
       add_amt='���⽻�׽���������'
	   per_n='�����˻�ƽ�����⽻�׽��'
	   per_o='�����˻�ƽ�����⽻�׽��';
 if _n_ eq 1 then set spec_orgarea_sum(keep=orgarea spec_cnt_n spec_amt_n rename=(spec_cnt_n=cnt_n spec_amt_n=amt_n) 
                                        where=(orgarea='�ϼ�'));
 set spec_area_sum spec_orgarea_sum(where=(orgarea eq '�ϼ�'));
 prop_cnt=spec_cnt_n/cnt_n;
 prop_amt=spec_amt_n/amt_n;
 add_cnt=spec_cnt_n/spec_cnt_o-1;
 add_amt=spec_amt_n/spec_amt_o-1;
 per_n=spec_amt_n/spec_cnt_n;
 per_o=spec_amt_o/spec_cnt_o;
run;

/*8.	D08��ͬʡ�е����⽻�׿ͻ����ֲ������*/
proc sort data=lz;
 by descending lz_cust_n;
run;
data d08(drop=lz_account_n lz_account_o);
 format orgarea $8. lz_cust_n 8. per_n 8.2 lz_cust_o 8. per_o 8.2 add_r percentn8.2;
 set lz lz_sum;
 if orgarea eq '' then orgarea='�ϼ�';
 per_n=lz_account_n/lz_cust_n;
 per_o=lz_account_n/lz_cust_o;
 add_r=lz_cust_n/lz_cust_o-1;
 label orgarea='ʡ��'
       lz_cust_n='���е����ۼ����⽻�׿ͻ���'
       lz_cust_o='���������ۼ����⽻�׿ͻ���'
	   per_n='���е���ƽ���ͻ�������'
	   per_o='��������ƽ���ͻ�������'
	   add_r='�������⽻�׻���������';
run;

PROC SQL;
	DROP TABLE  LOANAREA_N,apply_sum_n,spec_sum_n,lz_account_n,spec_lz_n,lz_cust_n
               ,LOANAREA_O,apply_sum_o,spec_sum_o,lz_account_o,spec_lz_o,lz_cust_o
               ,loanarea_sum,loan_sum,apply_orgarea_sum,spec_orgarea_sum,lz,lz_sum;
QUIT;


/*������ݵ���*/


%MEND AREA_ANALYSIS;

