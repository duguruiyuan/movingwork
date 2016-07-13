libname nfcs oracle user=datauser password=zlxdh7jf path=nfcs;
%INCLUDE "D:\work\code\config.sas";
/*%include "E:\�ּ���\������.sas";*/
%FORMAT;
%let xls='D:\work\other\��ѯȨ���嵥';
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
		,PUT(sorgcode,$SHORT_CD.) AS SHORT_NM label = "�������"
		,(case when sum(IPLATE) = 4 then "������ڰ�" when sum(IPLATE) = 3 then "���⽻�װ�" end) as cx_type label = "��ѯȨ������"
/*		,(case when sum(IPLATE) = 3 then "��" else "" end) as cx_spec label = "���⽻��"*/
	from nfcs.Sino_credit_orgplate(where = (IPLATE^=2 and ISTATE =1 and SUBSTR(SORGCODE,1,1)='Q' AND SORGCODE not in ('Q10152900H0000' 'Q10152900H0001')))
	group by sorgcode
;
quit;

proc sql;
	create table chaxun_list as select
		T1.*
		,(case when T2.cx_type = "" then  "δ��ͨȨ��" else T2.cx_type end) as cx_type label = "��ѯȨ������"
		from chaxun_liang as T1
		left join chaxun_type as T2
		on T1.sorgcode = T2.sorgcode
	;
quit;

data chaxun_list;
	set chaxun_list;
		if sorgcode = lag(sorgcode) then delete;
	if cx_type = "" then cx_type = "δ��ͨȨ��";
run;

proc export
	data=chaxun_list
	outfile=&xls.
	dbms=xlsx
	replace
	label
	;
run;
libname xls excel "D:\work\other\��ѯȨ���嵥.xlsx";
data xls.sheet1(dblabel = yes);
set chaxun_list;
run;
libname xls clear;
