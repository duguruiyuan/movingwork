%macro freq1(ds=,key=,var=);
	proc freq
		data=&ds. noprint;
		tables stoporgcode*dmonth 
			/out=sum(
				drop=percent
			)
		;
	run;
	proc sort
		data=sum;
		by stoporgcode dmonth;
	run;
	data sum_&ds.;
		if _n_ eq 1 then do;
			do i=1 to n;
				set sum nobs=n;
				by stoporgcode dmonth;
				retain all 0;
				if first.stoporgcode then all=0;
				all=all+count;
				if last.stoporgcode then do;
					count=all;
					dmonth='合计';
					output;
				end;
			end;
			drop all i;
		end;
/*		set sum;*/
		rename count=&ds.;
/*		output;*/
	run;
	proc sort
		data=sum_&ds.;
		by stoporgcode dmonth;
	run;
	%if &key. ne %str() %then %do;
		proc sort
			data=&ds.;
			by stoporgcode &key. &var.;
		run;
		data &key._&ds.;
			set &ds.;
			by stoporgcode &key. &var.;
			if first.&key.;
		run;
		proc freq
			data=&key._&ds. noprint;
			tables stoporgcode*dmonth 
				/out=sum_&key.(
					drop=percent
				)
			;
		run;
		proc sort
			data=sum_&key.;
			by stoporgcode dmonth;
		run;
		data sum_&key._&ds.;
			if _n_ eq 1 then do;
				do i=1 to n;
					set sum_&key. nobs=n;
					by stoporgcode dmonth;
					retain all 0;
					if first.stoporgcode then all=0;
					all=all+count;
					if last.stoporgcode then do;
						dmonth='合计';
						count=all;
						output;
					end;
				end;
				drop all i;
			end;
/*			set sum_&key.;*/
		rename count=&ds._&key.;
/*		output;*/
		run;
		proc sort
			data=sum_&key._&ds.;
			by stoporgcode dmonth;
		run;
	%end;

%mend freq1;
%macro freq(ds=,rvar=,cvars=,out=,percent=);
	%local cvarsoption byoption;
	%let cvarsoption=%sysfunc(tranwrd(%sysfunc(strip(&cvars.)),%str( ),%str(*)));
	%let byoption=%str();
	%if &out. eq %str() %then %let out=sum_&ds.;
	%if &rvar. ne %str() %then %do;
		%let byoption=by &rvar.;
		%createindex(ds=&ds.,vars=&rvar.);
	%end;
	proc freq
		data=&ds.
		noprint;
		tables &cvarsoption. /out=&out.;
		&byoption.;
	run;
	%if &rvar. ne %str() %then %do;
		%createindex(ds=&out.,vars=&rvar.);
		proc transpose
			data=&out.
			out=t_&out.(drop=_name_ _label_)
			prefix=&cvars.;
			by &rvar.;
			%if &percent. eq 1 %then %do;
				var percent;
			%end;
			%else %do;
				var count;
			%end;
			id &cvars.;
		run;
	%end;
%mend freq;
