libname nfcs oracle user=datauser password=zlxdh7jf path=nfcs;
%INCLUDE "D:\work\code\config.sas";
/*%include "E:\林佳宁\基础宏.sas";*/;
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
proc sort
	data=nfcs.Sino_credit_orgplate(where = (IPLATE^=2 and ISTATE =1 and SUBSTR(SORGCODE,1,1)='Q' AND SORGCODE not in ('Q10152900H0000' 'Q10152900H0001')))
	out=chaxun_type;
	by SORGCODE descending IPLATE;
run;
data chaxun_type;
	set chaxun_type;
	format cx_type $10.;
	by SORGCODE descending IPLATE;
	retain cx_type;
	if first.sorgcode then cx_type='';
	if IPLATE eq 3 then cx_type='特殊交易版';
	if IPLATE eq 1 then do;
		if cx_type eq '特殊交易版' then cx_type='网络金融版';
	end;
	if last.sorgcode;
run;
proc sort
	data=chaxun_type;
	by sorgcode;
run;
proc sort
	data=chaxun_liang;
	by sorgcode;
run;
data chaxun_list;
	merge chaxun_liang chaxun_type;
	by sorgcode;
	if cx_type eq '' then cx_type='未开通权限';
	SHORT_NM=PUT(sorgcode,$SHORT_CD.);
	keep sorgcode cx_type sorgname isearchlimit SHORT_NM;
	label
		sorgcode='机构号'
		cx_type='查询类型'
		sorgname='机构名称'
		isearchlimit='查询量'
		short_nm='简称'
	;
run;
proc export
	data=chaxun_list
	outfile='D:\work\other\查询权.xlsx'
	dbms=excel
	replace
	;
run;
