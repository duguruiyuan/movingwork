data sino_dictinfo;
	set nfcs.sino_dictinfo;
run;
data sino_dicttypeinfo;
	set nfcs.sino_dicttypeinfo;
run;
data sino_org;
	set nfcs.sino_org(where=(sorgcode like 'Q%' and SORGCODE^='Q10152900H0000' AND SORGCODE^='Q10152900H0001'));
run;
proc sort data=sino_org;
	by stoporgcode;
run;
data shortname;
	set crm1.T_contract_order(keep=SUB_ACCOUNT_ID CONTRACT_ORDER_SUBJECT CUSTOMER_NAME EXTEND1 EXTEND2);
	select (SUB_ACCOUNT_ID);
		when ('djw') person='∂≈ø°Á‚';
		when ('gwq') person='πÀŒƒ«ø';
		when ('zm')  person='÷‹√Ù';
		when ('llx') person='¿Ó¡¡œ£';
		when ('xjq') person='–ÏÁÏÁ˜' ;
		when ('zkb') person='÷Ïø≠≤©' ;
		otherwise person='Œ¥÷∏∂®';
	end;
run;
data sino_area;
	set nfcs.sino_area;
run;
data soc;
	if _n_ eq 1 then do;
		if 0 then set shortname(keep=CONTRACT_ORDER_SUBJECT CUSTOMER_NAME EXTEND1 EXTEND2 person);
		declare hash short(dataset:'shortname');
		short.definekey('CUSTOMER_NAME');
		short.definedata('CONTRACT_ORDER_SUBJECT','EXTEND1','EXTEND2','person');
		short.definedone();
		if 0 then set sino_area(keep=SAREACODE SPROVINCENAME);
		declare hash area(dataset: 'sino_area');
		area.definekey('SAREACODE');
		area.definedata('SPROVINCENAME');
		area.definedone();
	end;
	set sino_org;
	rc=short.find(key:SORGNAME);
	rc1=area.find(key:SAREACODE);
	drop rc rc1 CUSTOMER_NAME;
	rename extend2=shortname;
run;
proc sql;
	create table config as select
T1.*
from soc as T1
left join (select distinct sorgcode from nfcs.sino_msg) as T2
on T1.sorgcode = T2.sorgcode
where T2.sorgcode is not null
order by person
;
quit;
data SHORT_NM;
	fmtname='$SHORT_NM';
	set soc(keep=SORGNAME shortname rename=(sorgname=start shortname=label));
run;
proc format library=work cntlin=short_nm;
run;
data SHORT_CD;
	fmtname='$SHORT_CD';
	set soc(keep=sorgcode shortname rename=(sorgcode=start shortname=label));
run;
proc format library=work cntlin=short_cd;
run;
data ORGAREA_CD;
	fmtname='$ORGAREA_CD';
	set soc(keep=sorgcode SPROVINCENAME rename=(sorgcode=start SPROVINCENAME=label));
run;
proc format library=work cntlin=ORGAREA_CD;
run;
