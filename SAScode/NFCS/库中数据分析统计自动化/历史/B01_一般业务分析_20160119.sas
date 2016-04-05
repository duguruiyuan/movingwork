
%MACRO LOAN_ANALYSIS(STAT_DT);


%LET LAST_DT=INTNX('MONTH',&STAT_DT,-1,'END');
/*STEP2 数据清洗，获取本月及上月数据*/
/*T-1月*/
data sino_loan_n;
 set SSS.SINO_LOAN(WHERE=(SUBSTR(SORGCODE,1,1)='Q' AND 
                          SORGCODE not in ('Q10152900H0000' 'Q10152900H0001') AND 
                          DATEPART(DGETDATE)<=&STAT_DT.));
run;
PROC SORT DATA=sino_loan_n  OUT=SINO_LOAN_N1;
	BY SORGCODE SACCOUNT DGETDATE;
RUN;

DATA SINO_LOAN_N2;
	SET SINO_LOAN_N1;
	BY SORGCODE SACCOUNT DGETDATE;
	IF LAST.SACCOUNT;
RUN;

DATA SINO_LOAN_N2;
	FORMAT OPEN_DT YYMMDD10.;
	INFORMAT OPEN_DT YYMMDD10.;
	SET SINO_LOAN_N2;
	OPEN_DT=DATEPART(DDATEOPENED);
	OPEN_DUR=INTCK('MONTH',OPEN_DT,&STAT_DT.);
	OPEN_DUR_CD=PUT(OPEN_DUR,OPEN_LEVEL.);
	IF OPEN_DUR=-3 THEN OPEN_DUR=0;
	IF SLOANTYPE='13' THEN SLOANTYPE='11';
	AMT_CD=PUT(ICREDITLIMIT,PAY_AMT_level.);
	PROV_CD=PUT(SUBSTR(SAREACODE,1,2),$PROV_LEVEL.);
	REPAY_CD=PUT(SMONTHDURATION,$REPAYDUR_level.);
/*REPAY_CD为中间字段，用于生成还款期限的划分*/
	IF REPAY_CD ='0' THEN REPAY_CD = '1';
RUN;

/*T-2月*/
data sino_loan_o;
 set SSS.SINO_LOAN(WHERE=(SUBSTR(SORGCODE,1,1)='Q' AND 
                          SORGCODE not in ('Q10152900H0000' 'Q10152900H0001') AND 
                          DATEPART(DGETDATE)<=&LAST_DT.));
run;
PROC SORT DATA=sino_loan_o OUT=SINO_LOAN_O1;
	BY SORGCODE SACCOUNT DGETDATE;
RUN;

DATA SINO_LOAN_O2;
	SET SINO_LOAN_O1;
	BY SORGCODE SACCOUNT DGETDATE;
	IF LAST.SACCOUNT;
RUN;

DATA SINO_LOAN_O2;
	FORMAT OPEN_DT YYMMDD10.;
	INFORMAT OPEN_DT YYMMDD10.;
	SET SINO_LOAN_O2;
	OPEN_DT=DATEPART(DDATEOPENED);
	OPEN_DUR=INTCK('MONTH',OPEN_DT,&STAT_DT.);
	OPEN_DUR_CD=PUT(OPEN_DUR,OPEN_LEVEL.);
	IF OPEN_DUR=-3 THEN OPEN_DUR=0;
	IF SLOANTYPE='13' THEN SLOANTYPE='11';
	IF SMONTHDURATION='0' THEN SMONTHDURATION='1';
	AMT_CD=PUT(ICREDITLIMIT,PAY_AMT_level.);
	PROV_CD=PUT(SUBSTR(SAREACODE,1,2),$PROV_LEVEL.);
	REPAY_CD=PUT(SMONTHDURATION,$REPAYDUR_level.);
	IF REPAY_CD ='0' THEN REPAY_CD = '1';
RUN;

/*STEP3 数据分析*/

/*1.按照贷款金额分段统计*/

PROC SQL;
	CREATE TABLE B01 AS SELECT 
		T1.AMT_CD LABEL="贷款金额分段"
		,T1.LOAN_CNT AS N_CNT LABEL="库中当月累计账户数"
/*		,T2.LOAN_CNT AS O_CNT LABEL="库中上月累计账户数"*/
		,PUT(T1.LOAN_CNT/SUM(T1.LOAN_CNT),PERCENTN8.2) AS PER_ACC_NOW LABEL="贷款账户数占比"
		,PUT((T1.LOAN_CNT-T2.LOAN_CNT)/T2.LOAN_CNT,PERCENTN8.2) AS NADD_CNTP LABEL="库中账户数环比增长率"
		,ROUND(T1.LOAN_AMT/10000,1) AS N_AMT FORMAT=COMMA12. INFORMAT=COMMA12. LABEL="库中当月累计贷款金额"
/*		,ROUND(T2.LOAN_AMT/10000,0.01) AS O_AMT FORMAT=BEST12.2 INFORMAT=BEST12.2 LABEL="库中上月累计贷款金额"*/
		,PUT(T1.LOAN_AMT/SUM(T1.LOAN_AMT),PERCENTN8.2) AS PER_AMT_NOW LABEL="贷款金额占比"
		,PUT((T1.LOAN_AMT-T2.LOAN_AMT)/T2.LOAN_AMT,PERCENTN8.2) AS NADD_AMTP LABEL="库中贷款金额环比增长率"
		,ROUND((T1.LOAN_AMT/T1.LOAN_CNT)/10000,0.01) AS NAVG FORMAT=BEST12.2 INFORMAT=BEST12.2 LABEL="当月平均贷款金额"
		,ROUND((T2.LOAN_AMT/T2.LOAN_CNT)/10000,0.01) AS OAVG FORMAT=BEST12.2 INFORMAT=BEST12.2 LABEL="上月平均贷款金额"
	FROM (
		SELECT
			AMT_CD
			 ,SUM(CASE WHEN SACCOUNT^=''  THEN 1 ELSE 0 END) AS LOAN_CNT
		 	,SUM(ICREDITLIMIT) AS LOAN_AMT
		FROM SINO_LOAN_N2
		GROUP BY AMT_CD) AS T1
	LEFT JOIN ( 
		SELECT
			AMT_CD
			 ,SUM(CASE WHEN SACCOUNT^=''  THEN 1 ELSE 0 END) AS LOAN_CNT
		 	,SUM(ICREDITLIMIT) AS LOAN_AMT
		FROM SINO_LOAN_O2
		GROUP BY AMT_CD) AS T2
	ON T1.AMT_CD=T2.AMT_CD
	;
QUIT;

DATA B01;
	LENGTH AMT_ID $50.;
	SET B01;
	AMT_ID=PUT(AMT_CD,$PAY_AMT_CD.);
	LABEL AMT_ID="贷款金额";
	DROP AMT_CD;
RUN;

/*2.按照贷款类型统计*/
/*维护人：李楠 维护时间：2014.02.04 */
PROC SQL;
	CREATE TABLE B02 AS SELECT 
		T1.SLOANTYPE LABEL="贷款类型"
		,T1.LOAN_CNT AS N_CNT LABEL="库中当月累计账户数"
/*		,T2.LOAN_CNT AS O_CNT LABEL="库中上月累计账户数"*/
		,PUT(T1.LOAN_CNT/SUM(T1.LOAN_CNT),PERCENTN8.2) AS PER_ACC_NOW LABEL="贷款账户数占比"
		,PUT((T1.LOAN_CNT-T2.LOAN_CNT)/T2.LOAN_CNT,PERCENTN8.2) AS NADD_CNTP LABEL="库中账户数环比增长率"
/*		,ROUND(T1.LOAN_AMT/10000,0.01) AS N_AMT FORMAT=BEST12.2 INFORMAT=BEST12.2 LABEL="库中当月累计贷款金额"*/
		,ROUND(T1.LOAN_AMT/10000,1) AS N_AMT FORMAT=COMMA12. INFORMAT=COMMA12. LABEL="库中当月累计贷款金额"
/*		,ROUND(T2.LOAN_AMT/10000,0.01) AS O_AMT FORMAT=BEST12.2 INFORMAT=BEST12.2 LABEL="库中上月累计贷款金额"*/
		,PUT(T1.LOAN_AMT/SUM(T1.LOAN_AMT),PERCENTN8.2) AS PER_AMT_NOW LABEL="贷款金额占比"
		,PUT((T1.LOAN_AMT-T2.LOAN_AMT)/T2.LOAN_AMT,PERCENTN8.2) AS NADD_AMTP LABEL="库中贷款金额环比增长率"
		,ROUND((T1.LOAN_AMT/T1.LOAN_CNT)/10000,0.01) AS NAVG FORMAT=BEST12.2 INFORMAT=BEST12.2 LABEL="当月平均贷款金额"
		,ROUND((T2.LOAN_AMT/T2.LOAN_CNT)/10000,0.01) AS OAVG FORMAT=BEST12.2 INFORMAT=BEST12.2 LABEL="上月平均贷款金额"
	FROM (
		SELECT
			SLOANTYPE
			 ,SUM(CASE WHEN SACCOUNT^=''  THEN 1 ELSE 0 END) AS LOAN_CNT
		 	,SUM(ICREDITLIMIT) AS LOAN_AMT
		FROM SINO_LOAN_N2
		GROUP BY SLOANTYPE) AS T1
	LEFT JOIN ( 
		SELECT
			SLOANTYPE
			 ,SUM(CASE WHEN SACCOUNT^=''  THEN 1 ELSE 0 END) AS LOAN_CNT
		 	,SUM(ICREDITLIMIT) AS LOAN_AMT
		FROM SINO_LOAN_O2
		GROUP BY SLOANTYPE) AS T2
	ON T1.SLOANTYPE=T2.SLOANTYPE;
QUIT;
DATA B02;
	LENGTH LOAN_CD $50.;
	SET B02;
	LOAN_CD=PUT(SLOANTYPE,$LOAN_LEVEL.);
	LABEL LOAN_CD="贷款类型";
	DROP SLOANTYPE;
RUN;

/*3.按照担保方式统计*/

PROC SQL;			
	CREATE TABLE B03 AS SELECT 		
		T1.IGUARANTEEWAY LABEL="贷款类型"	
		,T1.LOAN_CNT AS N_CNT LABEL="库中当月累计账户数"	
/*		,T2.LOAN_CNT AS O_CNT LABEL="库中上月累计账户数"	*/
		,PUT(T1.LOAN_CNT/SUM(T1.LOAN_CNT),PERCENTN8.2) AS PER_ACC_NOW LABEL="贷款账户数占比"
		,PUT((T1.LOAN_CNT-T2.LOAN_CNT)/T2.LOAN_CNT,PERCENTN8.2) AS NADD_CNTP LABEL="库中账户数环比增长率"
		,ROUND(T1.LOAN_AMT/10000,1) AS N_AMT FORMAT=COMMA12. INFORMAT=COMMA12. LABEL="库中当月累计贷款金额"	
/*		,ROUND(T2.LOAN_AMT/10000,0.01) AS O_AMT FORMAT=BEST12.2 INFORMAT=BEST12.2 LABEL="库中上月累计贷款金额"	*/
		,PUT(T1.LOAN_AMT/SUM(T1.LOAN_AMT),PERCENTN8.2) AS PER_AMT_NOW LABEL="贷款金额占比"
		,PUT((T1.LOAN_AMT-T2.LOAN_AMT)/T2.LOAN_AMT,PERCENTN8.2) AS NADD_AMTP LABEL="库中贷款金额环比增长率"
		,ROUND((T1.LOAN_AMT/T1.LOAN_CNT)/10000,0.01) AS NAVG FORMAT=BEST12.2 INFORMAT=BEST12.2 LABEL="当月平均贷款金额"	
		,ROUND((T2.LOAN_AMT/T2.LOAN_CNT)/10000,0.01) AS OAVG FORMAT=BEST12.2 INFORMAT=BEST12.2 LABEL="上月平均贷款金额"	
	FROM (		
		SELECT	
			IGUARANTEEWAY
			 ,SUM(CASE WHEN SACCOUNT^=''  THEN 1 ELSE 0 END) AS LOAN_CNT
		 	,SUM(ICREDITLIMIT) AS LOAN_AMT
		FROM SINO_LOAN_N2	
		GROUP BY IGUARANTEEWAY) AS T1	
	LEFT JOIN ( 		
		SELECT	
			IGUARANTEEWAY
			 ,SUM(CASE WHEN SACCOUNT^=''  THEN 1 ELSE 0 END) AS LOAN_CNT
		 	,SUM(ICREDITLIMIT) AS LOAN_AMT
		FROM SINO_LOAN_O2	
		GROUP BY IGUARANTEEWAY) AS T2	
	ON T1.IGUARANTEEWAY=T2.IGUARANTEEWAY;		
QUIT;	
DATA B03;
	LENGTH GUAR_CD $50.;
	SET B03;
	GUAR_CD=PUT(IGUARANTEEWAY,GUAR_LEVEL.);
	LABEL GUAR_CD="担保方式";
	DROP IGUARANTEEWAY;
RUN;

/*4.按照还款年限统计*/

PROC SQL;			
	CREATE TABLE B04 AS SELECT 		
		T1.REPAY_CD LABEL="贷款类型"	
		,T1.LOAN_CNT AS N_CNT LABEL="库中当月累计账户数"	
/*		,T2.LOAN_CNT AS O_CNT LABEL="库中上月累计账户数"	*/
		,PUT(T1.LOAN_CNT/SUM(T1.LOAN_CNT),PERCENTN8.2) AS PER_ACC_NOW LABEL="贷款账户数占比"
		,PUT((T1.LOAN_CNT-T2.LOAN_CNT)/T2.LOAN_CNT,PERCENTN8.2) AS NADD_CNTP LABEL="库中账户数环比增长率"
		,ROUND(T1.LOAN_AMT/10000,1) AS N_AMT FORMAT=COMMA12. INFORMAT=COMMA12. LABEL="库中当月累计贷款金额"	
/*		,ROUND(T2.LOAN_AMT/10000,0.01) AS O_AMT FORMAT=BEST12.2 INFORMAT=BEST12.2 LABEL="库中上月累计贷款金额"	*/
		,PUT(T1.LOAN_AMT/SUM(T1.LOAN_AMT),PERCENTN8.2) AS PER_AMT_NOW LABEL="贷款金额占比"
		,PUT((T1.LOAN_AMT-T2.LOAN_AMT)/T2.LOAN_AMT,PERCENTN8.2) AS NADD_AMTP LABEL="库中贷款金额环比增长率"
		,ROUND((T1.LOAN_AMT/T1.LOAN_CNT)/10000,0.01) AS NAVG FORMAT=BEST12.2 INFORMAT=BEST12.2 LABEL="当月平均贷款金额"	
		,ROUND((T2.LOAN_AMT/T2.LOAN_CNT)/10000,0.01) AS OAVG FORMAT=BEST12.2 INFORMAT=BEST12.2 LABEL="上月平均贷款金额"	
	FROM (		
		SELECT	
			REPAY_CD
			 ,SUM(CASE WHEN SACCOUNT^=''  THEN 1 ELSE 0 END) AS LOAN_CNT
		 	,SUM(ICREDITLIMIT) AS LOAN_AMT
		FROM SINO_LOAN_N2	
		GROUP BY REPAY_CD) AS T1	
	LEFT JOIN ( 		
		SELECT	
			REPAY_CD
			 ,SUM(CASE WHEN SACCOUNT^=''  THEN 1 ELSE 0 END) AS LOAN_CNT
		 	,SUM(ICREDITLIMIT) AS LOAN_AMT
		FROM SINO_LOAN_O2	
		GROUP BY REPAY_CD) AS T2	
	ON T1.REPAY_CD=T2.REPAY_CD;		
QUIT;			
DATA B04;
	LENGTH REPAY_ID $50.;
	SET B04;
	REPAY_ID=PUT(REPAY_CD,$REPAYDUR_CD.);
	LABEL REPAY_ID="还款年限";
	DROP REPAY_CD;
RUN;	

/*5.按照贷款发生地统计*/

PROC SQL;			
	CREATE TABLE B05 AS SELECT 		
		T1.PROV_CD LABEL="省市"	
		,T1.LOAN_CNT AS N_CNT LABEL="库中当月累计账户数"	
/*		,COALESCE(T2.LOAN_CNT,0) AS O_CNT LABEL="库中上月累计账户数"	*/
		,PUT(T1.LOAN_CNT/SUM(T1.LOAN_CNT),PERCENTN8.2) AS PER_ACC_NOW LABEL="贷款账户数占比"
		,PUT((T1.LOAN_CNT-T2.LOAN_CNT)/T2.LOAN_CNT,PERCENTN8.2) AS NADD_CNTP LABEL="库中账户数环比增长率"
		,ROUND(T1.LOAN_AMT/10000,1) AS N_AMT FORMAT=COMMA12. INFORMAT=COMMA12. LABEL="库中当月累计贷款金额"	
/*		,COALESCE(ROUND(T2.LOAN_AMT/10000,0.01),0) AS O_AMT FORMAT=BEST12.2 INFORMAT=BEST12.2 LABEL="库中上月累计贷款金额"	*/
		,PUT(T1.LOAN_AMT/SUM(T1.LOAN_AMT),PERCENTN8.2) AS PER_AMT_NOW LABEL="贷款金额占比"
		,PUT((T1.LOAN_AMT-T2.LOAN_AMT)/T2.LOAN_AMT,PERCENTN8.2) AS NADD_AMTP LABEL="库中贷款金额环比增长率"
		,ROUND((T1.LOAN_AMT/T1.LOAN_CNT)/10000,0.01) AS NAVG FORMAT=BEST12.2 INFORMAT=BEST12.2 LABEL="当月平均贷款金额"	
		,ROUND((T2.LOAN_AMT/T2.LOAN_CNT)/10000,0.01) AS OAVG FORMAT=BEST12.2 INFORMAT=BEST12.2 LABEL="上月平均贷款金额"	
	FROM (		
		SELECT	
			PROV_CD
			 ,SUM(CASE WHEN SACCOUNT^=''  THEN 1 ELSE 0 END) AS LOAN_CNT
		 	,SUM(ICREDITLIMIT) AS LOAN_AMT
		FROM SINO_LOAN_N2	
		GROUP BY PROV_CD) AS T1	
	LEFT JOIN ( 		
		SELECT	
			PROV_CD
			 ,SUM(CASE WHEN SACCOUNT^=''  THEN 1 ELSE 0 END) AS LOAN_CNT
		 	,SUM(ICREDITLIMIT) AS LOAN_AMT
		FROM SINO_LOAN_O2	
		GROUP BY PROV_CD) AS T2	
	ON T1.PROV_CD=T2.PROV_CD
	ORDER BY  N_CNT DESC;
QUIT;					
	
/*6.	B06贷款机构业务发生地域情况分布情况表*/
/*更新内容：将VBA生成的报表使用SAS实现 更新人：李楠 2015-02-28*/
DATA SINO_LOAN_G;
	LENGTH SHORT_NM $30.;
	SET  SINO_LOAN_N2;
	SHORT_NM=PUT(SORGCODE,$SHORT_CD.);
RUN;

PROC SQL;
	CREATE TABLE SINO_LOAN_G1 AS SELECT
		SHORT_NM
		,PROV_CD
		,SUM(CASE WHEN SHORT_NM^="" THEN 1 ELSE 0 END) AS LOAN_CNT
	FROM SINO_LOAN_G
	GROUP BY SHORT_NM, PROV_CD
	ORDER BY SHORT_NM,LOAN_CNT DESC;
QUIT;
proc sort data= SINO_LOAN_G1;
by SHORT_NM PROV_CD;
run;

DATA B06;
	retain SHORT_NM PROV_CD;
	SET SINO_LOAN_G1(KEEP=SHORT_NM PROV_CD);
	by SHORT_NM;
RUN;
/*proc sort data=B06;*/
/*by SHORT_NM PROV_CD;*/
/*run;*/
/*DATA B06;*/
/*	set B06; */
/*	retain Prov_count 0;*/
/*	if first.SHORT_NM then Prov_count=1;*/
/*	else Prov_count=Prov_count+1;*/
/*RUN;*/
/*proc sort data=B06;*/
/*by SHORT_NM;*/
/*run;*/

/*DATA B06;*/
/*	set B06;*/
/*	length Prov_all $2000.;*/
/*	retain Prov_all;*/
/*	if first.SHORT_NM then Prov_all=PROV_CD;*/
/*	else Prov_all=catx(' ',Prov_all,PROV_CD);*/
/*run;*/
/*DATA B06;*/
/*	set B06;*/
/*	if last.SHORT_NM;*/
/*run;*/


/*B07业务发生地机构分布情况表 更新人：李楠 2015-02-11*/
DATA B07(KEEP=PROV_CD SHORT_NM);
	retain PROV_CD SHORT_NM;
	SET SINO_LOAN_G1;
RUN;
proc sort data=B07;
by PROV_CD SHORT_NM;
run;
/*Proc transpose data=B07 out=B07 PREFIX=shortname;*/
/*	var SHORT_NM;*/
/*	by PROV_CD;*/
/*run;*/


/*8/B08.按账期长度、贷款类型交叉分布*/
DATA Sino_loan_n3;
	SET Sino_loan_n2;
	loan_amt=round(ICREDITLIMIT/10000,1);
	LOAN_CD=PUT(SLOANTYPE,$LOAN_LEVEL.);
	REPAY_ID=PUT(REPAY_CD,$REPAYDUR_CD.);
RUN;
/*制作报表 B8 B9*/
PROC TABULATE DATA=Sino_loan_n3;
	CLASS REPAY_ID;
	CLASS LOAN_CD;
	VAR loan_amt;
	TABLE LOAN_CD="",REPAY_ID="" * loan_amt;
RUN;

PROC TABULATE DATA=Sino_loan_n3;
	CLASS REPAY_ID;
	CLASS LOAN_CD;
	TABLE LOAN_CD="",REPAY_ID="" ;
RUN;

/*B10. 机构数量按业务发生省市数量分布*/
/*PROC SUMMARY DATA=B06(KEEP=SHORT_NM PROV_CD);*/
/*CLASS SHORT_NM;*/
/*VAR PROV_CD;*/
/*OUTPUT OUT=B10;*/
/*RUN;*/
/*T-1月*/
PROC SQL;
	CREATE TABLE B10_TEMP1 AS SELECT
		SHORT_NM
		,COUNT(PROV_CD) AS PROV_CNT
	FROM B06
	GROUP BY SHORT_NM
	ORDER BY calculated PROV_CNT
;
QUIT;

PROC SQL;
	CREATE TABLE B10_TEMP1 AS SELECT
		PUT(PROV_CNT,PROV_CNT_LEVEL.) as PROV_CNT_LEVEL LABEL="业务发生省市数量分段"
		,COUNT(SHORT_NM) AS ORG_CNT LABEL="当月机构数量"
	FROM B10_TEMP1
	GROUP BY PROV_CNT_LEVEL;
QUIT;

/*T-2月*/
DATA SINO_LOAN_T2_G;
	LENGTH SHORT_NM $30.;
	SET SINO_LOAN_O2;
	SHORT_NM=PUT(SORGCODE,$SHORT_CD.);
RUN;

/*PROC SQL;*/
/*	CREATE TABLE SINO_LOAN_T2_G1 AS SELECT*/
/*		SHORT_NM*/
/*		,PROV_CD*/
/*		,SUM(CASE WHEN SHORT_NM^="" THEN 1 ELSE 0 END) AS LOAN_CNT*/
/*	FROM SINO_LOAN_T2_G*/
/*	GROUP BY SHORT_NM, PROV_CD*/
/*	ORDER BY SHORT_NM,LOAN_CNT DESC;*/
/*QUIT;*/
/*proc sort data= SINO_LOAN_T2_G1;*/
/*	by SHORT_NM PROV_CD;*/
/*run;*/

PROC SQL;
	CREATE TABLE B10_TEMP2 AS SELECT
		SHORT_NM
		,COUNT(DISTINCT PROV_CD) AS PROV_CNT
	FROM SINO_LOAN_T2_G(KEEP = SHORT_NM PROV_CD)
	GROUP BY SHORT_NM
	ORDER BY calculated PROV_CNT
;
QUIT;
PROC SQL;
	CREATE TABLE B10_TEMP2 AS SELECT
		PUT(PROV_CNT,PROV_CNT_LEVEL.) AS PROV_CNT_LEVEL LABEL="业务发生省市数量分段"
		,COUNT(SHORT_NM) AS ORG_CNT_T2 LABEL="上月机构数量"
	FROM B10_TEMP2
	GROUP BY PROV_CNT_LEVEL
;
QUIT;
DATA B10;
	retain PROV_CNT;
	MERGE B10_TEMP1(IN=X) B10_TEMP2(IN=Y);
	BY PROV_CNT_LEVEL;
	PROV_CNT = put(PROV_CNT_LEVEL,$PROV_CNT.);
	PER_CNT=PUT((ORG_CNT-ORG_CNT_T2)/ORG_CNT_T2,PERCENT8.2);
	IF X=Y=1;
	DROP
	PROV_CNT_LEVEL
	;
	LABEL
	PROV_CNT = 业务发生省市数量分段
	PER_CNT = 机构数量环比增长率
	;
RUN;
/*PROC SQL;*/
/*	CREATE TABLE B10 AS SELECT*/
/*		T1.PROV_CNT_LEVEL*/
/*		,T1.ORG_CNT*/
/*		,T2.ORG_CNT_T2*/
/*		,PUT(T1.ORG_CNT/T2.ORG_CNT_T2-1,PERCENT8.2) AS PER_CNT LABEL="机构数量环比增长率"*/
/*	FROM B10_TEMP1 AS T1*/
/*	LEFT JOIN B10_TEMP2 AS T2 ON T1.PROV_CNT_LEVEL=T2.PROV_CNT_LEVEL;*/
/*QUIT; */


/*PROC SQL;*/
/*	DROP TABLE Sino_loan_n1 ,Sino_loan_n2  , Sino_loan_o1,SINO_LOAN_G,SINO_LOAN_G1;*/
/*QUIT;*/

LIBNAME MYXLS EXCEL &OUTPATH_B01.;
DATA MYXLS."B01按贷款按金额分段"n(dblabel=YES);
	SET B01;
RUN;
DATA MYXLS."B02按贷款类型"n(dblabel=YES);
	SET B02;
RUN;
DATA MYXLS."B03按担保方式"n(dblabel=YES);
	SET B03;
RUN;
DATA MYXLS."B04按还款年限"n(dblabel=YES);
	SET B04;
RUN;
DATA MYXLS."B05按贷款发生地点"n(dblabel=YES);
	SET B05;
RUN;
DATA MYXLS."B06机构业务发生地"n(dblabel=YES);
	SET B06;
RUN;
DATA MYXLS."B07业务发生地机构"n(dblabel=YES);
	SET B07;
RUN;
DATA MYXLS."B10机构数量按业务地"n(dblabel=YES);
	SET B10;
RUN;
LIBNAME MYXLS CLEAR;

/*将B08、B09输出*/
/*ods  tagsets.excelxp  file= &OUTPATH_B01. options(sheet_name="B08");*/
/*ODS RESULTS OFF;*/
/*ODS LISTING CLOSE;*/
/*ODS OUTPUT TABLE#1=B09;*/
/*PROC TABULATE DATA=Sino_loan_n3;*/
/*	CLASS REPAY_ID;*/
/*	CLASS LOAN_CD;*/
/*	VAR loan_amt;*/
/*	TABLE LOAN_CD="",REPAY_ID="" * loan_amt;*/
/*RUN;*/
/*ods  tagsets.excelxp options(sheet_name="B09");*/
/*PROC TABULATE DATA=Sino_loan_n3;*/
/*	CLASS REPAY_ID;*/
/*	CLASS LOAN_CD;*/
/*	TABLE LOAN_CD="",REPAY_ID="" ;*/
/*RUN;*/
/*ods tagsets.excelxp close;*/

%MEND;
