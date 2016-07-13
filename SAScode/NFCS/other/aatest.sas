options minoperator mprint;
Libname crm1 odbc user=uperpcrm password=uperpcrm datasrc=crm;
libname nfcs oracle user=datauser password=zlxdh7jf path=nfcs;
%include 'E:\林佳宁\code\000_FORMAT.sas';
%format;
%global
	loan_ind
	apply_ind
	person_ind
	certfication_ind
	employment_ind
	address_ind
	spec_ind
	record_ind
	outdss
;
%let org_ind=sorgcode;
%let loan_ind=sorgcode saccount dbillingdate dgetdate;
%let apply_ind=sorgcode sapplycode dgetdate;
%let person_ind=sorgcode spin dgetdate;
%let certfication_ind=sorgcode spin dgetdate;
%let employment_ind=sorgcode spin dgetdate;
%let address_ind=sorgcode spin dgetdate;
%let spec_ind=sorgcode spin dgetdate;
%let record_ind=sorgcode scertno drequesttime;
%let outdss=loan apply person certfication employment address spec record org;
%macro genFormat_Base32x;
	proc format;
  		invalue $base32x
			'00000'='0'
			'00001'='1'
			'00010'='2'
			'00011'='3'
			'00100'='4'
			'00101'='5'
			'00110'='6'
			'00111'='7'
			'01000'='8'
			'01001'='9'
			'01010'='A'
			'01011'='B'
			'01100'='C'
			'01101'='D'
			'01110'='E'
			'01111'='F'
			'10000'='G'
			'10001'='H'
			'10010'='J'
			'10011'='K'
			'10100'='L'
			'10101'='N'
			'10110'='P'
			'10111'='Q'
			'11000'='R'
			'11001'='S'
			'11010'='T'
			'11011'='U'
			'11100'='W'
			'11101'='X'
			'11110'='Y'
			'11111'='X';
	run;
%mend;
%genFormat_Base32x;
%macro binStrToBase32(binStr);
	%local l k p i start end b c base32;
	%let l=%length(&binStr);
	%let k=%sysfunc(ceil(%sysevalf(&l/5)));
	%let p=%eval(&k*5-&l);
	%if &p>0 %then %let binStr=&binStr.%sysfunc(repeat(0,&p));
	%let base32=%str();
	%do i=1 %to &k;
		%let start=%eval((&i-1)*5+1);
		%let b=%subStr(&binStr,&start,5);
		%let c=%sysfunc(inputc(&b,$base32x.));
		%let base32=&base32.&c;
	%end;
	&base32.
%mend;
%macro varscount(vars=,res=);
	%local ei i var;
	%let i=1;
	%let ei=1;
	%do %while(&ei.);
		%let var=%scan(&vars.,&i.,%str( ));
		%if &var. eq %str() %then %do;
			%let ei=0;
		%end;
		%else %do;
			%let i=%eval(&i.+1);
		%end;
	%end;
	%let &res.=%eval(&i.-1);
%mend varscount;
%macro createindex(lib=,ds=,index=,vars=);
	%local varsN indexexist createoption;
	%varscount(vars=&vars.,res=varsN);
	%let vars=%upcase(&vars.);
	%if &lib. eq %str() %then %let lib=work;
	%if &varsN gt 1 %then %do;
		%if &index. eq %str() %then %do;
			%let index=%unquote(I%binstrtobase32(%sysfunc(md5(&vars.),$binary128.)));
		%end;
		%let createoption=%str(&index.=(&vars.));
	%end;
	%else %do;
		%let createoption=&vars.;
	%end;
	proc contents
		data=&lib..&ds.
		out2=index_list
		noprint;
	run;
	data _null_;
		set index_list(
			where=(
				type eq 'Index'
				and Numvars eq &varsN.
			)
		);
		if index(Recreate,"&vars.") gt 0 then do;
			call symputx("indexexist",1);
			stop;
		end;
	run;
	%if &indexexist. ne 1 %then %do;
		proc datasets lib=&lib. noprint;
			modify &ds.;
			index create &createoption.;
		quit;
	%end;
	proc datasets noprint;
		delete index_list;
	quit;
%mend createindex;
%macro getds(inlib=,ds=,outlib=,out=,sorg=,where=,index=,org=,keep=);
	%local varexist vare topoption w1 w2 whereoptions;

/*	逻辑库默认work库*/
	%if &inlib. eq %str() %then %let inlib=work;
	%if &outlib. eq %str() %then %let outlib=work;
	%if &org. eq %str() %then %let org=org;
	
/*	取出ds的变量，为取istate变量*/
	proc contents 
		data=&inlib..&ds. 
		out=vartab(keep=name)
		noprint;
	run;
	proc sql noprint;
		select count(*) into :varexist from vartab(where=(name eq 'ISTATE'));
	quit;
	%if &ds. eq sino_credit_record %then %do;
		%if %str(&sorg.) ne %str() %then %do;
			%let topoption=%str((where=(sorgcode in(&sorg.) and istate ne -1)));
			%org2toporg(outlib=&outlib.,org=&org.,out=toporg,where=&topoption.);
			proc sql noprint;
				select cats("'",sorgcode,"'") into :sorg separated by ' ' from toporg;
			quit;
			proc datasets 
				lib=&outlib.
				noprint;
				delete toporg;
			quit;
		%end;
	%end;
	/*	判断istate是否存在，并准备加入where条件里*/
	%if &varexist. ge 1 %then %do;
		%let vare=
			%str(
				istate ne -1 
				and sorgcode like 'Q%' 
				and sorgcode not in ('Q10152900H0000' 'Q10152900H0001')
			);
	%end;
	%else %let vare=
		%str(
			sorgcode like 'Q%' 
			and sorgcode not in ('Q10152900H0000' 'Q10152900H0001')
		);
	%if %quote(&where.) ne %str() %then %do;
		%let w1=%str(and &where.);
	%end;
	%if %quote(&sorg.) ne %str() %then %do;
		%let w2=%str(and sorgcode in(&sorg.));
	%end;
	%let whereoptions=%str(where=(&vare.&w1.&w2.));
	%let keepoption=%str();
	%if %quote(&keep.) ne %str() %then %let keepoption=%str(keep=&keep.);

/*	输出表out默认同ds,同时创建索引，根据指定表创建指定索引*/
	%if &out. ne %str() %then %do;
		%if &out. in(%str(&outdss.)) %then %do;
			%if &index eq %str() %then %do;
				%let index=&&&out._ind;
			%end;
		%end;
	%end;
	%else %do;
		%let out=&ds.;
	%end;

/*	抽取对应表*/;
	data &outlib..&out.;
		set &inlib..&ds.(&whereoptions. &keepoption.);
		stoporgcode=put(sorgcode,$top_org.);
	run;
	%createindex(lib=&outlib.,ds=&out.,vars=&index.);
/*	删除无关表*/;
	proc datasets noprint;
		delete vartab;
	quit;
%mend getds;
%macro org2toporg(inlib=,outlib=,org=,out=,where=);
	%if &inlib. eq %str() %then %do;
		%let inlib=work;
	%end;
	%if &outlib. eq %str() %then %do;
		%let outlib=work;
	%end;
	%if &out. eq %str() %then %do;
		%let out=&org.;
	%end;
	data &outlib..temp;
		set &inlib..&org.&where.;
			if slevel eq '1';
			if SPARENT eq '';
	run;
	%createindex(lib=&outlib.,ds=temp,vars=stoporgcode);
	%createindex(lib=&inlib.,ds=&org.,vars=stoporgcode);
	data &outlib..&out.;
		merge 
			&inlib..&org.(keep=stoporgcode sorgcode in=ina) 
			&outlib..temp(keep=stoporgcode sorgname in=inb);
		by stoporgcode;
		if inb;
	run;
	%createindex(lib=&outlib.,ds=&out.,vars=sorgcode);
	proc datasets
		lib=&outlib.
		noprint;
		delete temp;
	quit;
%mend org2toporg;
