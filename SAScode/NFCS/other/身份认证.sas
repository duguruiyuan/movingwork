libname nfcs oracle user=datauser password=zlxdh7jf path=nfcs;
data cias_org;
	set nfcs.cias_org_query;
run;
proc sort
	data=cias_org;
	by sorgcode sname scertno dcreatetime;
run;
data order_cias;
	set cias_org;
	by sorgcode sname scertno dcreatetime;
	ld=lag(dcreatetime);
	dtime=dcreatetime-ld;
	if first.scertno then dtime=0;
	dmonth=put(datepart(dcreatetime),yymmn6.);
	if 86400 ge dtime ge 15 then _F_dt=1;
run;
data repeat_person;
	set order_cias;
	if _F_dt eq 1;
run;
proc sort
	data=repeat_person
	nodupkey;
	by sname scertno;
run;
proc freq
	data=repeat_person
	noprint;
	tables sorgcode*dmonth /out=out_person;
run;
proc freq
	data=order_cias(where=(scountstate eq '1'))
	noprint;
	tables sorgcode*dmonth /out=out_cias;
run;
proc freq
	data=order_cias
	noprint;
	tables sorgcode*dmonth*_F_dt /out=out_repeat;
run;
proc sql noprint;
	select distinct cats("'",sorgcode,"'") into :org separated by ' ' from cias_org;
quit;
data sorg;
	set nfcs.sino_org(where=(sorgcode in (&org.)));
run;
data out_cias;
	if _n_ eq 1 then do;
		if 0 then set sorg(keep=sorgcode sorgname);
		declare hash o(dataset:'sorg');
		o.definekey('sorgcode');
		o.definedata('sorgname');
		o.definedone();
	end;
	set out_cias;
	rc=o.find(key:sorgcode);
run;
data out_repeat;
	if _n_ eq 1 then do;
		if 0 then set sorg(keep=sorgcode sorgname);
		declare hash o(dataset:'sorg');
		o.definekey('sorgcode');
		o.definedata('sorgname');
		o.definedone();
	end;
	set out_repeat;
	rc=o.find(key:sorgcode);
run;
data out_person;
	if _n_ eq 1 then do;
		if 0 then set sorg(keep=sorgcode sorgname);
		declare hash o(dataset:'sorg');
		o.definekey('sorgcode');
		o.definedata('sorgname');
		o.definedone();
	end;
	set out_person;
	rc=o.find(key:sorgcode);
run;
