%MACRO FL(STAT_DT);

/*PROC SORT DATA=SSS.SINO_LOAN(WHERE=(SUBSTR(SORGCODE,1,1)='Q' AND SORGCODE^='Q10152900H0000'  AND SORGCODE^='Q10152900H0001'  AND DATEPART(DGETDATE)<=&STAT_DT.))  OUT=SINO_LOAN_N1;*/
/*	BY SORGCODE SACCOUNT DGETDATE;*/
/*RUN;*/
/**/
/*DATA SINO_LOAN_N2;*/
/*	SET SINO_LOAN_N1;*/
/*	BY SORGCODE SACCOUNT DGETDATE;*/
/*	IF LAST.SACCOUNT;*/
/*RUN;*/
/**/
/*DATA SINO_LOAN_N2;*/
/*	FORMAT OPEN_DT YYMMDD10.;*/
/*	INFORMAT OPEN_DT YYMMDD10.;*/
/*	SET SINO_LOAN_N2;*/
/*	OPEN_DT=DATEPART(DDATEOPENED);*/
/*	OPEN_DUR=INTCK('MONTH',OPEN_DT,&STAT_DT.);*/
/*	OPEN_DUR_CD=PUT(OPEN_DUR,OPEN_LEVEL.);*/
/*	IF OPEN_DUR=-3 THEN OPEN_DUR=0;*/
/*	IF SLOANTYPE='13' THEN SLOANTYPE='11';*/
/*	AMT_CD=PUT(ICREDITLIMIT,PAY_AMT_level.);*/
/*	PROV_CD=PUT(SUBSTR(SAREACODE,1,2),$PROV_LEVEL.);*/
/*	REPAY_CD=PUT(SMONTHDURATION,$REPAYDUR_level.);*/
/*RUN;*/

PROC FREQ DATA=SINO_LOAN_N3;
	TABLE SORGCODE;
RUN;

DATA WT1;
	SET SINO_LOAN_N3;
	SHORT_NM=PUT(SORGCODE,$SHORT_CD.);
RUN;
/*这是担保方式为其他的 附录表2*/
PROC SQL;
	CREATE TABLE FL2 AS 
	SELECT
		T1.SHORT_NM LABEL="机构简称"
		,T1.CNT AS CNT LABEL="担保类型为'其他'的业务数"
		,T2.CNT AS TOTAL LABEL="机构上传总业务数"
		,PUT(T1.CNT/T2.CNT,PERCENT8.2) AS PE LABEL="担保类型为'其他'的业务数占总业务数比"
	FROM (SELECT 
		SHORT_NM
		,COUNT(CASE WHEN SHORT_NM^='' THEN 1 ELSE 0 END) AS CNT
	FROM WT1(WHERE=(IGUARANTEEWAY=9))
	GROUP BY SHORT_NM) AS T1
	LEFT JOIN (
	SELECT 
		SHORT_NM
		,COUNT(CASE WHEN SHORT_NM^='' THEN 1 ELSE 0 END) AS CNT
	FROM WT1
	GROUP BY SHORT_NM) AS T2
	ON T1.SHORT_NM=T2.SHORT_NM
	ORDER BY CNT DESC
	;
QUIT;

/*这是贷款类型为其他 附录表1*/
PROC SQL;
	CREATE TABLE FL1 AS 
	SELECT
		T1.SHORT_NM LABEL="机构简称"
		,T1.CNT AS CNT LABEL="贷款类型为'其他'的业务数"
		,T2.CNT AS TOTAL LABEL="机构上传总业务数"
		,PUT(T1.CNT/T2.CNT,PERCENT8.2) AS PE LABEL="贷款类型为'其他'的业务数占总业务数比"
	FROM (SELECT 
		SHORT_NM
		,COUNT(CASE WHEN SHORT_NM^='' THEN 1 ELSE 0 END) AS CNT
	FROM WT1(WHERE=(SLOANTYPE='99'))
	GROUP BY SHORT_NM) AS T1
	LEFT JOIN (
	SELECT 
		SHORT_NM
		,COUNT(CASE WHEN SHORT_NM^='' THEN 1 ELSE 0 END) AS CNT
	FROM WT1
	GROUP BY SHORT_NM) AS T2
	ON T1.SHORT_NM=T2.SHORT_NM
	ORDER BY CNT DESC
	;
QUIT;

/*还款频率为不定期的 附录表9*/
PROC SQL;
	CREATE TABLE FL9 AS 
	SELECT
		T1.SHORT_NM LABEL="机构简称"
		,T1.CNT AS CNT LABEL="账期长度为'不定期'的业务数"
		,ROUND(T1.LOAN_AMT,2) LABEL="贷款金额（万元）"
		,ROUND(T1.LOAN_AMT/T1.CNT,2) AS AVG_AMT LABEL="平均每笔贷款金额（万元）"
		,T2.CNT AS TOTAL LABEL="机构报送总业务数"
		,PUT(T1.CNT/T2.CNT,PERCENT8.2) AS PE LABEL="账期长度为'不定期'的业务数占总业务数比例"
	FROM (SELECT 
		SHORT_NM
		,COUNT(CASE WHEN SHORT_NM^='' THEN 1 ELSE 0 END) AS CNT
		,SUM(ICREDITLIMIT)/10000 AS LOAN_AMT
	FROM WT1(WHERE=(REPAY_CD='8'))
	GROUP BY SHORT_NM) AS T1
	LEFT JOIN (
	SELECT 
		SHORT_NM
		,COUNT(CASE WHEN SHORT_NM^='' THEN 1 ELSE 0 END) AS CNT
	FROM WT1
	GROUP BY SHORT_NM) AS T2
	ON T1.SHORT_NM=T2.SHORT_NM
	ORDER BY CNT DESC
	;
QUIT;
/*FL08 还款频率为7一次性 附录表8*/
PROC SQL;
	CREATE TABLE FL8 AS 
	SELECT
		T1.SHORT_NM LABEL="机构简称"
		,T1.CNT AS CNT LABEL="账期长度为'一次性'的业务数"
		,ROUND(T1.LOAN_AMT,2) LABEL="贷款金额（万元）"
		,ROUND(T1.LOAN_AMT/T1.CNT,2) AS AVG_AMT LABEL="平均每笔贷款金额（万元）"
		,T2.CNT AS TOTAL LABEL="机构报送总业务数"
		,PUT(T1.CNT/T2.CNT,PERCENT8.2) AS PE  LABEL="账期长度为'一次性'的业务数占总业务数比例"
	FROM (SELECT 
		SHORT_NM
		,COUNT(CASE WHEN SHORT_NM^='' THEN 1 ELSE 0 END) AS CNT
		,SUM(ICREDITLIMIT)/10000 AS LOAN_AMT
	FROM WT1(WHERE=(REPAY_CD='7'))
	GROUP BY SHORT_NM) AS T1
	LEFT JOIN (
	SELECT 
		SHORT_NM
		,COUNT(CASE WHEN SHORT_NM^='' THEN 1 ELSE 0 END) AS CNT
	FROM WT1
	GROUP BY SHORT_NM) AS T2
	ON T1.SHORT_NM=T2.SHORT_NM
	ORDER BY CNT DESC
	;
QUIT;

/*FL10 还款频率为9 others 附录表10*/
PROC SQL;
	CREATE TABLE FL10 AS 
	SELECT
		T1.SHORT_NM LABEL="机构简称"
		,T1.CNT AS CNT LABEL="账期长度为'其他'的业务数"
		,ROUND(T1.LOAN_AMT,2) LABEL="贷款金额（万元）"
		,ROUND(T1.LOAN_AMT/T1.CNT,2) AS AVG_AMT LABEL="平均每笔贷款金额（万元）"
		,T2.CNT AS TOTAL LABEL="机构报送总业务数"
		,PUT(T1.CNT/T2.CNT,PERCENT8.2) AS PE LABEL="账期长度为'其他'的业务数占总业务数比例"
	FROM (SELECT 
		SHORT_NM
		,COUNT(CASE WHEN SHORT_NM^='' THEN 1 ELSE 0 END) AS CNT
		,SUM(ICREDITLIMIT)/10000 AS LOAN_AMT
	FROM WT1(WHERE=(REPAY_CD='9'))
	GROUP BY SHORT_NM) AS T1
	LEFT JOIN (
	SELECT 
		SHORT_NM
		,COUNT(CASE WHEN SHORT_NM^='' THEN 1 ELSE 0 END) AS CNT
	FROM WT1
	GROUP BY SHORT_NM) AS T2
	ON T1.SHORT_NM=T2.SHORT_NM
	ORDER BY CNT DESC
	;
QUIT;

PROC SQL;
	CREATE TABLE WTG AS SELECT
		 A.SORGCODE
		 ,A.SCERTNO
		 ,B.imarriage
		 ,B.iedulevel
		 ,DATEPART(B.dbirthday) AS BIRTH FORMAT=YYMMDD10. INFORMAT=YYMMDD10.
	FROM SINO_PERSON_CERT1 AS A
	LEFT JOIN SINO_PERSON1 AS B ON  A.spin=B.spin;
QUIT;

DATA WT2;
	SET WTG;
	SHORT_NM=PUT(SORGCODE,$SHORT_CD.);
RUN;
/*FL04 这是学历为未知的 附录表4*/
PROC SQL;
	CREATE TABLE FL4 AS 
	SELECT
		T1.SHORT_NM LABEL="机构简称"
		,T1.CNT AS CNT LABEL="学历状况为'未知'的业务数"
		,T2.CNT AS TOTAL LABEL="机构报送总业务数"
		,PUT(T1.CNT/T2.CNT,PERCENT8.2) AS PE LABEL="学历状况为'未知'的业务数占总业务数比例"
	FROM (SELECT 
		SHORT_NM
		,COUNT(CASE WHEN SHORT_NM^='' THEN 1 ELSE 0 END) AS CNT
	FROM WT2(WHERE=(iedulevel=99))
	GROUP BY SHORT_NM) AS T1
	LEFT JOIN (
	SELECT 
		SHORT_NM
		,COUNT(CASE WHEN SHORT_NM^='' THEN 1 ELSE 0 END) AS CNT
	FROM WT2(WHERE=(iedulevel^=.))
	GROUP BY SHORT_NM) AS T2
	ON T1.SHORT_NM=T2.SHORT_NM
	ORDER BY CNT DESC
	;
QUIT;
/*FL03 这是婚姻状况未说明 附录表3*/
PROC SQL;
	CREATE TABLE FL3 AS 
	SELECT
		T1.SHORT_NM LABEL="机构简称"
		,T1.CNT AS CNT LABEL="婚姻状况为'未说明'的业务数"
		,T2.CNT AS TOTAL LABEL="机构报送总业务数"
		,PUT(T1.CNT/T2.CNT,PERCENT8.2) AS PE LABEL="婚姻状况为'未说明'的业务数占总业务数比例"
	FROM (SELECT 
		SHORT_NM
		,COUNT(CASE WHEN SHORT_NM^='' THEN 1 ELSE 0 END) AS CNT
	FROM WT2(WHERE=(IMARRIAGE=90))
	GROUP BY SHORT_NM) AS T1
	LEFT JOIN (
	SELECT 
		SHORT_NM
		,COUNT(CASE WHEN SHORT_NM^='' THEN 1 ELSE 0 END) AS CNT
	FROM WT2(WHERE=(IMARRIAGE^=.))
	GROUP BY SHORT_NM) AS T2
	ON T1.SHORT_NM=T2.SHORT_NM
	ORDER BY CNT DESC
	;
QUIT;

PROC SQL;
	CREATE TABLE CUST_SEX_0 AS SELECT
		A.SORGCODE
		,A.SCERTTYPE
		 ,A.SCERTNO
		 ,B.IGENDER
	FROM SINO_PERSON_CERT1 AS A
	LEFT JOIN SINO_PERSON1 AS B ON  A.spin=B.spin;
QUIT;

DATA CUST_SEX_1;
 	SET CUST_SEX_0;
	IF MOD(SUBSTR(SCERTNO,17,1),2)=1 THEN SEX=1;
	ELSE IF MOD(SUBSTR(SCERTNO,17,1),2)=0 THEN SEX =2;
	ELSE SEX=IGENDER;
	IF SEX=. THEN SEX=0;
	SHORT_NM=PUT(SORGCODE,$SHORT_CD.);
RUN;
DATA  CUST_SEX_2(KEEP=SHORT_NM DOC_TYPE SCERTNO);
	LENGTH SHORT_NM $30.
			DOC_TYPE $30.;
	SET CUST_SEX_1;
	IF SEX=0;
	DOC_TYPE=PUT(SCERTTYPE,$DOC_TYPE.);
RUN;

PROC SORT DATA=CUST_SEX_2;
	BY SHORT_NM;
RUN;
/*证件类型 附录表6*/
DATA FL6;
	SET CUST_SEX_2;
	LABEL
	SHORT_NM="机构简称"
	DOC_TYPE="证件类型"
	SCERTNO="证件号码"
	;
RUN;
/*性别为未知 附录表5*/
PROC SQL;
	CREATE TABLE FL5 AS 
	SELECT
		T1.SHORT_NM LABEL="机构简称"
		,T1.CNT AS CNT LABEL="性别为'未知'的业务数"
		,T2.CNT AS TOTAL LABEL="机构报送总业务数"
		,PUT(T1.CNT/T2.CNT,PERCENT8.2) AS PE LABEL="性别为'未知'的业务数占总业务数比例"
	FROM (SELECT 
		SHORT_NM
		,COUNT(DISTINCT SCERTNO) AS CNT
	FROM CUST_SEX_1(WHERE=(SEX=0))
	GROUP BY SHORT_NM) AS T1
	LEFT JOIN (
	SELECT 
		SHORT_NM
		,COUNT(DISTINCT SCERTNO) AS CNT
	FROM CUST_SEX_1
	GROUP BY SHORT_NM) AS T2
	ON T1.SHORT_NM=T2.SHORT_NM
	ORDER BY CNT DESC
	;
QUIT;

PROC SQL;
	CREATE TABLE CUST_BIRTH_0 AS SELECT
		 A.SORGCODE
		 ,A.SCERTNO
		 ,DATEPART(B.dbirthday) AS BIRTH FORMAT=YYMMDD10. INFORMAT=YYMMDD10.
	FROM SINO_PERSON_CERT1 AS A
	LEFT JOIN SINO_PERSON1 AS B ON  A.spin=B.spin;
QUIT;

DATA CUST_BIRTH_1;
	SET CUST_BIRTH_0;
	IF LENGTH(SCERTNO)=18 THEN BIRTH_DT=MDY(SUBSTR(SCERTNO,11,2),SUBSTR(SCERTNO,13,2),SUBSTR(SCERTNO,7,4));
	IF BIRTH_DT=. THEN BIRTH_DT=BIRTH;
	AGE= intck('year',BIRTH_DT,&STAT_DT.);
	AGE_CD=PUT(AGE,age_level.);
RUN;


DATA WT3;
	SET CUST_BIRTH_1;
	SHORT_NM=PUT(SORGCODE,$SHORT_CD.);
RUN;
/*年龄 附录表7*/
PROC SQL;
	CREATE TABLE FL7 AS 
	SELECT
		T1.SHORT_NM LABEL="机构简称"
		,T1.CNT AS CNT LABEL="年龄为'缺失'的业务数"
		,T2.CNT AS TOTAL LABEL="机构报送总业务数"
		,PUT(T1.CNT/T2.CNT,PERCENT8.2) AS PE LABEL="年龄为'缺失'的业务数占总业务数比例"
	FROM (SELECT 
		SHORT_NM
		,COUNT(DISTINCT SCERTNO) AS CNT
	FROM WT3(WHERE=(AGE_CD='缺失'))
	GROUP BY SHORT_NM) AS T1
	LEFT JOIN (
	SELECT 
		SHORT_NM
		,COUNT(DISTINCT SCERTNO) AS CNT
	FROM WT3
	GROUP BY SHORT_NM) AS T2
	ON T1.SHORT_NM=T2.SHORT_NM
	ORDER BY CNT DESC
	;
QUIT;

/*FL1-8统一生成序号*/
/*%macro xuhao;*/
/*do i=1 to 8 by 1;*/
/*DATA FL&i.;*/
/*	retain id;*/
/*	SET FL&i.;*/
/*	id=_n_;*/
/*	label*/
/*	id="序号";*/
/*run;*/
/*output;*/
/*end;*/
/*%mend;*/
/*%xuhao;*/

/*导出到xls文件 李楠 2015.02.06*/
LIBNAME MYXLS EXCEL &OUTPATH_F01.;
DATA MYXLS."FL01贷款类型为其他的比率"n(dblabel=YES);
	SET FL1;
RUN;
DATA MYXLS."FL02担保方式为其他的比率"n(dblabel=YES);
	SET FL2;
RUN;
DATA MYXLS."FL03婚姻状况未说明的比率"n(dblabel=YES);
	SET FL3;
RUN;
DATA MYXLS."FL04学历信息未知的比率"n(dblabel=YES);
	SET FL4;
RUN;
DATA MYXLS."FL05性别为未知的比率"n(dblabel=YES);
	SET FL5;
RUN;
DATA MYXLS."FL06证件类型存在问题的比率"n(dblabel=YES);
	SET FL6;
RUN;
DATA MYXLS."FL07年龄为缺失的比率"n(dblabel=YES);
	SET FL7;
RUN;
DATA MYXLS."FL08账期长度为一次性"n(dblabel=YES);
	SET FL8;
RUN;
DATA MYXLS."FL09账期长度为不定期"n(dblabel=YES);
	SET FL9;
RUN;
DATA MYXLS."FL10账期长度为其他"n(dblabel=YES);
	SET FL10;
RUN;
LIBNAME MYXLS CLEAR;
%MEND;
