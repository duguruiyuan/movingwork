libname nfcs oracle user=datauser password=zlxdh7jf path=nfcs;
%INCLUDE "D:\work\code\config.sas";
/*%include "E:\林佳宁\基础宏.sas";*/
%FORMAT;
%let xls='D:\work\other\查询权限清单';
data chaxun_liang;
	set nfcs.sino_org(
		WHERE=(	SUBSTR(SORGCODE,1,1)='Q' 
			AND SORGCODE not in ('Q10152900H0000' 'Q10152900H0001') 
			and slevel eq '1'
			and missing(sparent)
		)
	);
	keep sorgcode sorgname isearchlimit;
run;


proc sql;
	create table chaxun_type as select
		sorgcode
		,PUT(sorgcode,$SHORT_CD.) AS SHORT_NM label = "机构简称"
		,(case when sum(IPLATE) = 4 then "网络金融版" when sum(IPLATE) = 3 then "特殊交易版" end) as cx_type label = "查询权限类型"
/*		,(case when sum(IPLATE) = 3 then "√" else "" end) as cx_spec label = "特殊交易"*/
	from nfcs.Sino_credit_orgplate(where = (IPLATE^=2 and ISTATE =1 and SUBSTR(SORGCODE,1,1)='Q' AND SORGCODE not in ('Q10152900H0000' 'Q10152900H0001')))
	group by sorgcode
;
quit;

proc sql;
	create table chaxun_list as select
		T1.*
		,(case when T2.cx_type = "" then  "未开通权限" else T2.cx_type end) as cx_type label = "查询权限类型"
		from chaxun_liang as T1
		left join chaxun_type as T2
		on T1.sorgcode = T2.sorgcode
	;
quit;

data chaxun_list;
	set chaxun_list;
		if sorgcode = lag(sorgcode) then delete;
	if cx_type = "" then cx_type = "未开通权限";
run;

proc export
	data=chaxun_list
	outfile=&xls.
	dbms=xlsx
	replace
	label
	;
run;
libname xls excel "D:\work\other\查询权限清单.xlsx";
data xls.sheet1(dblabel = yes);
set chaxun_list;
run;
libname xls clear;
