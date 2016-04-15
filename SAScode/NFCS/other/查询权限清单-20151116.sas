libname nfcs oracle user=datauser password=zlxdh7jf path=nfcs;
%INCLUDE "E:\�ּ���\code\000_FORMAT.sas";
/*%include "E:\�ּ���\������.sas";*/
%FORMAT;

proc sql;
	create table chaxun_liang as select
		T1.STOPORGCODE label = "��������"
/*		,PUT(sorgcode,$SHORT_CD.) AS SHORT_NM label = "�������"*/
		,T2.sorgname
		,sum(T1.ISEARCHLIMIT) as ISEARCHLIMIT label = "��ѯ�����ƣ������¼�������"
	from nfcs.sino_org(WHERE=(SUBSTR(SORGCODE,1,1)='Q' AND SORGCODE not in ('Q10152900H0000' 'Q10152900H0001'))) as T1
	left join nfcs.sino_org as T2 on
	T1.STOPORGCODE = T2.sorgcode
	group by T1.STOPORGCODE
;
quit;

data chaxun_liang;
	set chaxun_liang;
	if STOPORGCODE = lag(STOPORGCODE) then delete;
rename 
STOPORGCODE = sorgcode
;
run;


proc sql;
	create table chaxun_type as select
		sorgcode
		,PUT(sorgcode,$SHORT_CD.) AS SHORT_NM label = "�������"
		,(case when sum(IPLATE) = 4 then "������ڰ�" when sum(IPLATE) = 3 then "���⽻�װ�" end) as cx_type label = "��ѯȨ������"
/*		,(case when sum(IPLATE) = 3 then "��" else "" end) as cx_spec label = "���⽻��"*/
	from nfcs.Sino_credit_orgplate(where = (IPLATE^=2 and ISTATE =1 and SUBSTR(SORGCODE,1,1)='Q' AND SORGCODE not in ('Q10152900H0000' 'Q10152900H0001')))
	group by SHORT_NM
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

libname xls excel "E:\�ּ���\��ʱ\��ѯȨ���嵥.xlsx";
data xls.sheet1(dblabel = yes);
set chaxun_list;
run;
libname xls clear;
