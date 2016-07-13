%let begindate=mdy(4,1,2016);
%let enddate=mdy(4,30,2016);
%let begintime=hms(00,00,00);
%let endtime=hms(24,00,00);
data cias;
	set nfcs.cias_org_query(
		where=(
			sorgcode eq 'Q10152900HD900' 
			and &begindate. le datepart(DCREATETIME) le &enddate.
			and SCOUNTSTATE eq '1'
/*			and &begintime. le timepart(DCREATETIME) le &endtime.*/
		)
	);
run;
proc sort data=cias;
	by DCREATETIME;
run;
data cias_cis;
	set nfcs.cias_cis_query(
		where=( 
			&begindate. le datepart(DCREATETIME) le &enddate.
			and &begintime. le timepart(DCREATETIME) le &endtime.
		)
	);
run;
proc sort data=cias;
	by sname scertno DCREATETIME;
run;
data cias_only(keep=sname scertno DCREATETIME);
	retain n;
	set cias;
	by sname scertno DCREATETIME;
	if first.scertno then n=0;
	n+1;
	if last.scertno;
	if n gt 1;
run;
data cias_more;
	merge cias(in=inb) cias_only(in=ina);
	by sname scertno;
	if ina;
run;
proc sort data=cias_more;
	by sname scertno DCREATETIME;
run;
data cias_more_more;
	retain n;
	set cias_more;
	by sname scertno DCREATETIME;
	if first.DCREATETIME then n=0;
	n+1;
	if last.scertno;
	if n gt 1;
run;
proc sort data=cias_more out=cias_more_only nodupkey;
	by sname scertno DCREATETIME;
run;
data cias_cis;
	set nfcs.cias_cis_query;
run;
/*proc sort data=cias_more;*/
/*	by sname scertno DCREATETIME;*/
/*run;*/
/*data cias_more;*/
/*	set cias_more;*/
/*	by sname scertno DCREATETIME;*/
/*	ltime=lag(dcreatetime);*/
/*	if first.scertno then ltime=dcreatetime;*/
/*	dd=dcreatetime-ltime;*/
/*run;*/
/*proc sort data=cias_more;*/
/*	by sname scertno descending DCREATETIME;*/
/*run;*/
/*data cias_more;*/
/*	set cias_more;*/
/*	by sname scertno descending DCREATETIME;*/
/*	ltime=lag(dcreatetime);*/
/*	if first.scertno then ltime=dcreatetime;*/
/*	dd1=dcreatetime-ltime;*/
/*run;*/
