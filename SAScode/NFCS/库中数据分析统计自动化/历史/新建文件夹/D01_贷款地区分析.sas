

%MACRO AREA_ANALYSIS(STAT_DT);


/*T-1月综合数据处理*/

PROC SQL;
	CREATE TABLE LOANAREA_N AS SELECT
		A1.ORGAREA LABEL="省市"
		,COUNT(DISTINCT SORGCODE) AS ORG_CNT_N LABEL="当月机构数量"
		,SUM(CASE WHEN SACCOUNT^="" THEN 1 ELSE 0 END) AS LOAN_CNT_N LABEL="当月贷款业务数"
		,round(SUM(ICREDITLIMIT)/10000,0.01) AS LOAN_AMT_N LABEL="当月贷款金额"
		,round(SUM(IBALANCE)/10000,0.01) AS LOAN_BAL_N LABEL="当月贷款本金余额" 
		,COUNT(DISTINCT SPIN) AS CUST_CNT_N  LABEL="当月贷款客户数"
		,SUM(CASE WHEN IAMOUNTPASTDUE^=0 THEN 1 ELSE 0 END) AS OWE_CNT_N LABEL="当月逾期账户数"
		,round(SUM(IAMOUNTPASTDUE)/10000,0.01) AS OWE_AMT_N  LABEL="当月逾期总额"
		,COALESCE(A2.NEW_CUST_CNT_N,0)  AS NEW_CUST_CNT_N LABEL="当月新开客户数"
		,0 as prop_n label='当月各省市占比'
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

/*T-2月综合数据处理*/
PROC SQL;
	CREATE TABLE LOANAREA_O AS SELECT
		A1.ORGAREA LABEL="省市"
		,COUNT(DISTINCT SORGCODE) AS ORG_CNT_O LABEL="上月机构数量"
		,SUM(CASE WHEN SACCOUNT^="" THEN 1 ELSE 0 END) AS LOAN_CNT_O LABEL="上月贷款业务数"
		,SUM(ICREDITLIMIT)/10000 AS LOAN_AMT_O LABEL="上月贷款金额"
		,SUM(IBALANCE)/10000 AS LOAN_BAL_O LABEL="上月贷款本金余额" 
		,COUNT(DISTINCT SCERTNO) AS CUST_CNT_O  LABEL="上月贷款客户数"
		,SUM(CASE WHEN IAMOUNTPASTDUE^=0 THEN 1 ELSE 0 END) AS OWE_CNT_O LABEL="上月逾期账户数"
		,SUM(IAMOUNTPASTDUE)/10000 AS OWE_AMT_O  LABEL="上月逾期总额"
		,COALESCE(A2.NEW_CUST_CNT_O,0)  AS NEW_CUST_CNT_O LABEL="上月新开客户数"
		,0 as prop_o label='上月各省市占比'
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

/*综合数据处理*/

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
 if orgarea eq '' then orgarea='合计';
 apply_amt_n=apply_amt_n/10000;
 apply_amt_o=apply_amt_o/10000;
run;

data spec_orgarea_sum;
 merge spec_sum_n spec_sum_o;
 by orgarea;
 if orgarea eq '' then orgarea='合计';
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


/*1.	D01不同省市发生贷款业务的机构分布情况表*/
proc sort data=loanarea_sum;
 by descending org_cnt_n;
run;
data d01(keep=orgarea org_cnt_n prop_n org_cnt_o prop_o orgadd_r);
 if _n_ eq 1 then set loan_sum(keep=orgarea org_cnt_n org_cnt_o rename=(org_cnt_n=cnt_n org_cnt_o=cnt_o));
 set loanarea_sum loan_sum;
 if orgarea eq '' then orgarea='合计';
 prop_n=org_cnt_n/cnt_n;
 prop_o=org_cnt_o/cnt_o;
 orgadd_r=org_cnt_n/org_cnt_o-1;
 label orgadd_r='库中机构数量环比增长率';
 format prop_n percent8.2 prop_o percent8.2 orgadd_r percent8.2;
run;
/*2.	D02不同省市的贷款账户及贷款金额分布情况表*/
proc sort data=loanarea_sum;
 by descending loan_cnt_n;
run;
data d02(keep=orgarea loan_cnt_n loan_amt_n prop_cnt prop_amt orgadd_cnt orgadd_amt per_n per_o);
 format orgarea $8. loan_cnt_n 8. prop_cnt percentn8.2 orgadd_cnt percentn8.2 loan_amt_n 8. prop_amt percentn8.2 orgadd_amt percentn8.2 per_n 8.2 per_o 8.2;
 if _n_ eq 1 then set loan_sum(keep=orgarea loan_cnt_n loan_cnt_o loan_amt_n loan_amt_o rename=(loan_cnt_n=cnt_n loan_amt_n=amt_n));
 set loanarea_sum loan_sum;
 if orgarea eq '' then orgarea='合计';
 prop_cnt=loan_cnt_n/cnt_n;
 prop_amt=loan_amt_n/amt_n;
 orgadd_cnt=loan_cnt_n/loan_cnt_o-1;
 orgadd_amt=loan_amt_n/loan_amt_o-1;
 per_n=loan_amt_n/loan_cnt_n;
 per_o=loan_amt_o/loan_cnt_o;
 label prop_cnt='库中贷款账户数占比'
       prop_amt='库中贷款金额占比'
       orgadd_cnt='库中贷款账户数环比增长率'
       orgadd_amt='库中贷款金额环比增长率'
       per_n='当月账户平均贷款金额'
       per_o='上月账户平均贷款金额';
run;


/*3.	D03不同省市的贷款客户数分布情况表*/
proc sort data=loanarea_sum;
 by descending cust_cnt_n;
run;
data d03(keep=orgarea cust_cnt_n cust_cnt_o prop_n prop_o per_n per_o add);
 if _n_ eq 1 then set loan_sum(keep=orgarea cust_cnt_n cust_cnt_o rename=(cust_cnt_n=cust_n cust_cnt_o=cust_o));
 set loanarea_sum loan_sum;
 if orgarea eq '' then orgarea='合计';
 prop_n=cust_cnt_n/cust_n;
 prop_o=cust_cnt_o/cust_o;
 per_n=loan_cnt_n/cust_cnt_n;
 per_o=loan_cnt_o/cust_cnt_o;
 add=cust_cnt_n/cust_cnt_o-1;
 label prop_n='当月各省市占比'
       prop_o='上月各省市占比'
       per_n='当月每客户平均账户数'
       per_o='上月每客户平均账户数'
       add='环比增长率';
 format prop_n percentn8.2 prop_o percentn8.2 add percentn8.2 per_n 8.2 per_o 8.2;
run;

/*4.	D04不同省市的贷款逾期账户及逾期金额分布情况表*/
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
 if orgarea eq '' then orgarea='合计';
 label prop_cnt='逾期账户数占总账户数比例'
       prop_amt='逾期金额占贷款金额比例'
	   per_owe='当月账户平均逾期金额'
	   per_loan='当月账户平均贷款金额';
run;

/*5.	D05不同省市的贷款新开客户数分布情况表*/
/*PROC SQL;*/
/*	CREATE TABLE D05 AS SELECT*/
/*		A1.ORGAREA*/
/*		,A1.NEW_CUST_CNT AS NEW_CNT_N LABEL="库中当月累计新开客户数"*/
/*		,PUT(A1.NEW_CUST_CNT/A1.CUST_CNT,PERCENTN8.2) AS NEWCNT_R_N LABEL="当月新开客户数占总客户数比例"*/
/*		,COALESCE(A2.NEW_CUST_CNT,0) AS NEW_CNT_O LABEL="库中上月累计新开客户数"*/
/*		,PUT(A2.NEW_CUST_CNT/A2.CUST_CNT,PERCENTN8.2) AS NEWCNT_R_O LABEL="上月新开客户数占总客户数比例"*/
/*		,PUT(A1.NEW_CUST_CNT/A2.NEW_CUST_CNT-1,PERCENTN8.2) AS NEWCNTADD_R LABEL="库中新开客户数环比增长率"*/
/*	FROM LOANAREA_N AS A1*/
/*	LEFT JOIN LOANAREA_O AS A2*/
/*	ON A1.ORGAREA =A2.ORGAREA */
/*	ORDER BY NEW_CNT_N DESC;*/
/*	DELETE FROM D05 WHERE NEW_CNT_N=0;*/
/*QUIT;*/

/*6.	D06不同省市的贷款申请数及申请金额分布情况表*/


proc sort data=apply_orgarea_sum(where=(orgarea ne '合计')) out=apl_area_sum;
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
 label orgarea='省市' 
       apply_cnt_n='当月累计贷款申请数' 
       prop_cnt='贷款申请数占比' 
       add_cnt='贷款申请数环比增长率' 
       apply_amt_n='当月累计贷款申请金额' 
       prop_amt='贷款申请金额占比' 
       add_amt='贷款申请金额环比增长率'
	   per_n='当月账户平均申请金额'
	   per_o='上月账户平均申请金额';
 if _n_ eq 1 then set apply_orgarea_sum(keep=orgarea apply_cnt_n apply_amt_n rename=(apply_cnt_n=cnt_n apply_amt_n=amt_n) 
                                        where=(orgarea='合计'));
 set apl_area_sum apply_orgarea_sum(where=(orgarea eq '合计'));
 prop_cnt=apply_cnt_n/cnt_n;
 prop_amt=apply_amt_n/amt_n;
 add_cnt=apply_cnt_n/apply_cnt_o-1;
 add_amt=apply_amt_n/apply_amt_o-1;
 per_n=apply_amt_n/apply_cnt_n;
 per_o=apply_amt_o/apply_cnt_o;
run;

/*7.	D07不同省市的特殊交易业务数及特殊交易金额分布情况表*/
proc sort data=spec_orgarea_sum(where=(orgarea ne '合计')) out=spec_area_sum;
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
 label orgarea='省市' 
       spec_cnt_n='当月累计特殊交易业务数' 
       prop_cnt='特殊交易数占比' 
       add_cnt='特殊交易环比增长率' 
       spec_amt_n='当月累计特殊交易金额' 
       prop_amt='特殊交易金额占比' 
       add_amt='特殊交易金额环比增长率'
	   per_n='当月账户平均特殊交易金额'
	   per_o='上月账户平均特殊交易金额';
 if _n_ eq 1 then set spec_orgarea_sum(keep=orgarea spec_cnt_n spec_amt_n rename=(spec_cnt_n=cnt_n spec_amt_n=amt_n) 
                                        where=(orgarea='合计'));
 set spec_area_sum spec_orgarea_sum(where=(orgarea eq '合计'));
 prop_cnt=spec_cnt_n/cnt_n;
 prop_amt=spec_amt_n/amt_n;
 add_cnt=spec_cnt_n/spec_cnt_o-1;
 add_amt=spec_amt_n/spec_amt_o-1;
 per_n=spec_amt_n/spec_cnt_n;
 per_o=spec_amt_o/spec_cnt_o;
run;

/*8.	D08不同省市的特殊交易客户数分布情况表*/
proc sort data=lz;
 by descending lz_cust_n;
run;
data d08(drop=lz_account_n lz_account_o);
 format orgarea $8. lz_cust_n 8. per_n 8.2 lz_cust_o 8. per_o 8.2 add_r percentn8.2;
 set lz lz_sum;
 if orgarea eq '' then orgarea='合计';
 per_n=lz_account_n/lz_cust_n;
 per_o=lz_account_n/lz_cust_o;
 add_r=lz_cust_n/lz_cust_o-1;
 label orgarea='省市'
       lz_cust_n='库中当月累计特殊交易客户数'
       lz_cust_o='库中上月累计特殊交易客户数'
	   per_n='库中当月平均客户赖账数'
	   per_o='库中上月平均客户赖账数'
	   add_r='库中特殊交易环比增长率';
run;

PROC SQL;
	DROP TABLE  LOANAREA_N,apply_sum_n,spec_sum_n,lz_account_n,spec_lz_n,lz_cust_n
               ,LOANAREA_O,apply_sum_o,spec_sum_o,lz_account_o,spec_lz_o,lz_cust_o
               ,loanarea_sum,loan_sum,apply_orgarea_sum,spec_orgarea_sum,lz,lz_sum;
QUIT;


/*结果数据导出*/


%MEND AREA_ANALYSIS;

