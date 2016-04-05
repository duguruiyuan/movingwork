
%MACRO LOAN_ANALYSIS(STAT_DT);


%LET LAST_DT=INTNX('MONTH',&STAT_DT,-1,'END');
/*STEP2 ������ϴ����ȡ���¼���������*/
/*T-1��*/
/*data sino_loan_n;*/
/* set SSS.SINO_LOAN(WHERE=(SUBSTR(SORGCODE,1,1)='Q' AND */
/*                          SORGCODE not in ('Q10152900H0000' 'Q10152900H0001') AND */
/*                          DATEPART(DGETDATE)<=&STAT_DT.));*/
/*run;*/
/*PROC SORT DATA=sino_loan(where=(DATEPART(DGETDATE)<=&STAT_DT.)) OUT=SINO_LOAN_N1;*/
/*	BY SORGCODE SACCOUNT DGETDATE;*/
/*RUN;*/
/**/
/*DATA SINO_LOAN_N;*/
/*	SET SINO_LOAN_N1;*/
/*	BY SORGCODE SACCOUNT DGETDATE;*/
/*	IF LAST.SACCOUNT;*/
/*RUN;*/

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
/*REPAY_CDΪ�м��ֶΣ��������ɻ������޵Ļ���*/
/*	IF REPAY_CD ='0' THEN REPAY_CD = '1';*/
/*RUN;*/

/*T-2��*/
/*data sino_loan_o;*/
/* set SSS.SINO_LOAN(WHERE=(SUBSTR(SORGCODE,1,1)='Q' AND */
/*                          SORGCODE not in ('Q10152900H0000' 'Q10152900H0001') AND */
/*                          DATEPART(DGETDATE)<=&LAST_DT.));*/
/*run;*/

/*PROC SORT DATA=sino_loan(where=(DATEPART(DGETDATE)<=&LAST_DT.)) OUT=SINO_LOAN_O1;*/
/*	BY SORGCODE SACCOUNT DGETDATE;*/
/*RUN;*/
/**/
/*DATA SINO_LOAN_O;*/
/*	SET SINO_LOAN_O1;*/
/*	BY SORGCODE SACCOUNT DGETDATE;*/
/*	IF LAST.SACCOUNT;*/
/*RUN;*/

/*DATA SINO_LOAN_O2;*/
/*	FORMAT OPEN_DT YYMMDD10.;*/
/*	INFORMAT OPEN_DT YYMMDD10.;*/
/*	SET SINO_LOAN_O2;*/
/*	OPEN_DT=DATEPART(DDATEOPENED);*/
/*	OPEN_DUR=INTCK('MONTH',OPEN_DT,&STAT_DT.);*/
/*	OPEN_DUR_CD=PUT(OPEN_DUR,OPEN_LEVEL.);*/
/*	IF OPEN_DUR=-3 THEN OPEN_DUR=0;*/
/*	IF SLOANTYPE='13' THEN SLOANTYPE='11';*/
/*	IF SMONTHDURATION='0' THEN SMONTHDURATION='1';*/
/*	AMT_CD=PUT(ICREDITLIMIT,PAY_AMT_level.);*/
/*	PROV_CD=PUT(SUBSTR(SAREACODE,1,2),$PROV_LEVEL.);*/
/*	REPAY_CD=PUT(SMONTHDURATION,$REPAYDUR_level.);*/
/*	IF REPAY_CD ='0' THEN REPAY_CD = '1';*/
/*RUN;*/






proc means data=loan_n sum noprint;
 class sloantype amt_cd IGUARANTEEWAY REPAY_CD PROV_CD;
 var ICREDITLIMIT;
 output out=b_sum_n(drop= _type_ rename=(_freq_=cnt_n)) sum(ICREDITLIMIT)=loan_amt_n;
run;
proc sort data=b_sum_n;
 by sloantype amt_cd IGUARANTEEWAY REPAY_CD PROV_CD;
run;
proc means data=loan_o sum noprint;
 class sloantype amt_cd IGUARANTEEWAY REPAY_CD PROV_CD;
 var ICREDITLIMIT;
 output out=b_sum_o(drop= _type_ rename=(_freq_=cnt_o)) sum(ICREDITLIMIT)=loan_amt_o;
run;
proc sort data=b_sum_o;
 by sloantype amt_cd IGUARANTEEWAY REPAY_CD PROV_CD;
run;
data b_sum;
 merge b_sum_n b_sum_o;
 by sloantype amt_cd IGUARANTEEWAY REPAY_CD PROV_CD;
run;
/*STEP3 ���ݷ���*/

/*1.���մ�����ֶ�ͳ��*/


data B01(drop= sloantype IGUARANTEEWAY REPAY_CD PROV_CD cnt_o loan_amt_o cnt amt);
 format amt_cd $PAY_AMT_CD. 
        cnt_n 8. 
        prop_cnt percentn8.2 
        add_cnt percentn8.2 
        loan_amt_n 8. 
        prop_amt percentn8.2 
        add_amt percentn8.2 
        per_n 8.2 per_o 8.2;
 label amt_cd='�������'
       cnt_n='�����ۼ��˻���'
       prop_cnt='�����˻���ռ��' 
       add_cnt='�˻�����������' 
       loan_amt_n='�����ۼƴ�����'
       prop_amt='������ռ��'
       add_amt='����������'
       per_n='����ƽ��������'
       per_o='����ƽ��������';
 if _n_ eq 1 then set b_sum(where=(sloantype eq '' and amt_cd eq '' and IGUARANTEEWAY eq . and REPAY_CD eq '' and PROV_CD eq '')
                            rename=(cnt_n=cnt loan_amt_n=amt));
 set b_sum(where=(sloantype eq '' and amt_cd ne '' and IGUARANTEEWAY eq . and REPAY_CD eq '' and PROV_CD eq ''))
     b_sum(where=(sloantype eq '' and amt_cd eq '' and IGUARANTEEWAY eq . and REPAY_CD eq '' and PROV_CD eq ''));
 if amt_cd eq '' then amt_cd='�ϼ�';
 add_cnt=cnt_n/cnt_o-1;
 add_amt=loan_amt_n/loan_amt_o-1;
 prop_cnt=cnt_n/cnt;
 prop_amt=loan_amt_n/amt;
 loan_amt_n=loan_amt_n/10000;
 loan_amt_o=loan_amt_o/10000;
 per_n=loan_amt_n/cnt_n;
 per_o=loan_amt_o/cnt_o;
run;

/*2.���մ�������ͳ��*/
/*ά���ˣ���� ά��ʱ�䣺2014.02.04 */
data B02(drop= amt_cd IGUARANTEEWAY REPAY_CD PROV_CD cnt_o loan_amt_o amt cnt);
 format sloantype $LOAN_LEVEL. 
        cnt_n 8. 
        prop_cnt percentn8.2 
        add_cnt percentn8.2 
        loan_amt_n 8. 
        prop_amt percentn8.2 
        add_amt percentn8.2 
        per_n 8.2 per_o 8.2;
 label sloantype='��������'
       cnt_n='�����ۼ��˻���'
       prop_cnt='�����˻���ռ��' 
       add_cnt='�˻�����������' 
       loan_amt_n='�����ۼƴ�����'
       prop_amt='������ռ��'
       add_amt='����������'
       per_n='����ƽ��������'
       per_o='����ƽ��������';
 if _n_ eq 1 then set b_sum(where=(amt_cd eq '' and sloantype eq '' and IGUARANTEEWAY eq . and REPAY_CD eq '' and PROV_CD eq '')
                            rename=(cnt_n=cnt loan_amt_n=amt));
 set b_sum(where=(amt_cd eq '' and sloantype ne '' and IGUARANTEEWAY eq . and REPAY_CD eq '' and PROV_CD eq ''))
     b_sum(where=(amt_cd eq '' and sloantype eq '' and IGUARANTEEWAY eq . and REPAY_CD eq '' and PROV_CD eq ''));
 if sloantype eq '' then sloantype='�ϼ�';
 add_cnt=cnt_n/cnt_o-1;
 add_amt=loan_amt_n/loan_amt_o-1;
 prop_cnt=cnt_n/cnt;
 prop_amt=loan_amt_n/amt;
 loan_amt_n=loan_amt_n/10000;
 loan_amt_o=loan_amt_o/10000;
 per_n=loan_amt_n/cnt_n;
 per_o=loan_amt_o/cnt_o;
run;

/*3.���յ�����ʽͳ��*/

data B03(drop= amt_cd sloantype REPAY_CD PROV_CD cnt_o loan_amt_o amt cnt iguaranteeway);
 format igway $24.
        IGUARANTEEWAY GUAR_LEVEL. 
        cnt_n 8. 
        prop_cnt percentn8.2 
        add_cnt percentn8.2 
        loan_amt_n 8. 
        prop_amt percentn8.2 
        add_amt percentn8.2 
        per_n 8.2 per_o 8.2;
 label igway='������ʽ'
       cnt_n='�����ۼ��˻���'
       prop_cnt='�����˻���ռ��' 
       add_cnt='�˻�����������' 
       loan_amt_n='�����ۼƴ�����'
       prop_amt='������ռ��'
       add_amt='����������'
       per_n='����ƽ��������'
       per_o='����ƽ��������';
 if _n_ eq 1 then set b_sum(where=(amt_cd eq '' and sloantype eq '' and IGUARANTEEWAY eq . and REPAY_CD eq '' and PROV_CD eq '')
                            rename=(cnt_n=cnt loan_amt_n=amt));
 set b_sum(where=(amt_cd eq '' and sloantype eq '' and IGUARANTEEWAY ne . and REPAY_CD eq '' and PROV_CD eq ''))
     b_sum(where=(amt_cd eq '' and sloantype eq '' and IGUARANTEEWAY eq . and REPAY_CD eq '' and PROV_CD eq ''));
 igway=put(iguaranteeway,guar_level.);
 if substr(igway,22,1) eq '.' then igway='�ϼ�';
 add_cnt=cnt_n/cnt_o-1;
 add_amt=loan_amt_n/loan_amt_o-1;
 prop_cnt=cnt_n/cnt;
 prop_amt=loan_amt_n/amt;
 loan_amt_n=loan_amt_n/10000;
 loan_amt_o=loan_amt_o/10000;
 per_n=loan_amt_n/cnt_n;
 per_o=loan_amt_o/cnt_o;
run;


/*4.���ջ�������ͳ��*/
data B04(drop= amt_cd IGUARANTEEWAY sloantype PROV_CD cnt_o loan_amt_o amt cnt);
 format REPAY_CD $REPAYDUR_CD. 
        cnt_n 8. 
        prop_cnt percentn8.2 
        add_cnt percentn8.2 
        loan_amt_n 8. 
        prop_amt percentn8.2 
        add_amt percentn8.2 
        per_n 8.2 per_o 8.2;
 label REPAY_CD='��������'
       cnt_n='�����ۼ��˻���'
       prop_cnt='�����˻���ռ��' 
       add_cnt='�˻�����������' 
       loan_amt_n='�����ۼƴ�����'
       prop_amt='������ռ��'
       add_amt='����������'
       per_n='����ƽ��������'
       per_o='����ƽ��������';
 if _n_ eq 1 then set b_sum(where=(amt_cd eq '' and sloantype eq '' and IGUARANTEEWAY eq . and REPAY_CD eq '' and PROV_CD eq '')
                            rename=(cnt_n=cnt loan_amt_n=amt));
 set b_sum(where=(amt_cd eq '' and sloantype eq '' and IGUARANTEEWAY eq . and REPAY_CD ne '' and PROV_CD eq ''))
     b_sum(where=(amt_cd eq '' and sloantype eq '' and IGUARANTEEWAY eq . and REPAY_CD eq '' and PROV_CD eq ''));
 if REPAY_CD eq '' then REPAY_CD='�ϼ�';
 add_cnt=cnt_n/cnt_o-1;
 add_amt=loan_amt_n/loan_amt_o-1;
 prop_cnt=cnt_n/cnt;
 prop_amt=loan_amt_n/amt;
 loan_amt_n=loan_amt_n/10000;
 loan_amt_o=loan_amt_o/10000;
 per_n=loan_amt_n/cnt_n;
 per_o=loan_amt_o/cnt_o;
 if REPAY_CD not in('120' '90');
run;


/*5.���մ������ͳ��*/
data B05/**/;
 format PROV_CD $8. 
        cnt_n 8. 
        prop_cnt percentn8.2 
        add_cnt percentn8.2 
        loan_amt_n 8. 
        prop_amt percentn8.2 
        add_amt percentn8.2 
        per_n 8.2 per_o 8.2;
 label PROV_CD='ʡ��'
       cnt_n='�����ۼ��˻���'
       prop_cnt='�����˻���ռ��' 
       add_cnt='�˻�����������' 
       loan_amt_n='�����ۼƴ�����'
       prop_amt='������ռ��'
       add_amt='����������'
       per_n='����ƽ��������'
       per_o='����ƽ��������';
 set b_sum(where=(amt_cd eq '' and sloantype eq '' and IGUARANTEEWAY eq . and REPAY_CD eq '' and PROV_CD ne ''));
run;
proc sort data=B05;
 by descending cnt_n ;
run;
data B05(drop= amt_cd IGUARANTEEWAY sloantype REPAY_CD cnt_o loan_amt_o amt cnt);
 if _n_ eq 1 then set b_sum(where=(amt_cd eq '' and sloantype eq '' and IGUARANTEEWAY eq . and REPAY_CD eq '' and PROV_CD eq '')
                            rename=(cnt_n=cnt loan_amt_n=amt));
 set B05
     b_sum(where=(amt_cd eq '' and sloantype eq '' and IGUARANTEEWAY eq . and REPAY_CD eq '' and PROV_CD eq ''));
 if PROV_CD eq '' then PROV_CD='�ϼ�';
 add_cnt=cnt_n/cnt_o-1;
 add_amt=loan_amt_n/loan_amt_o-1;
 prop_cnt=cnt_n/cnt;
 prop_amt=loan_amt_n/amt;
 loan_amt_n=loan_amt_n/10000;
 loan_amt_o=loan_amt_o/10000;
 per_n=loan_amt_n/cnt_n;
 per_o=loan_amt_o/cnt_o;
run;

	
/*6.	B06�������ҵ������������ֲ������*/
/*�������ݣ���VBA���ɵı���ʹ��SASʵ�� �����ˣ���� 2015-02-28*/
proc sort data=loan_n out=loan_g(keep=short_nm prov_cd) nodupkey;
 by short_nm prov_cd;
run;
data B06(drop=prov_cd);
 format short_nm $20. i 2. prov $1000.;
 label short_nm='������' i='ʡ������' prov='ʡ��';
 retain prov;
 retain i;
 set loan_g;
 by short_nm prov_cd;
 if first.short_nm then do;
  i=0;
  prov='';
 end;
 prov=catx(',',prov,prov_cd);
 i=i+1;
 if last.short_nm then do;
  output;
 end;
run;
proc sort data=B06;
 by descending i;
run;


/*B07ҵ�����ػ����ֲ������ �����ˣ���� 2015-02-11*/
proc sort data=loan_n out=loan_p(keep=short_nm prov_cd) nodupkey;
 by prov_cd short_nm;
run;
data B07(drop=short_nm);
 format prov_cd $20. i 2. name $5000.;
 label prov_cd='ʡ��' i='��������' name='����';
 retain name;
 retain i;
 set loan_p;
 by prov_cd short_nm;
 if first.prov_cd then do;
  i=0;
  name='';
 end;
 name=catx(',',name,short_nm);
 i=i+1;
 if last.prov_cd then do;
  output;
 end;
run;
proc sort data=B07;
 by descending i;
run;

/*8/B08.�����ڳ��ȡ��������ͽ���ֲ�*/
proc means data=loan_n noprint;
 class SLOANTYPE REPAY_CD;
 var ICREDITLIMIT;
 output out=xtab1 sum(ICREDITLIMIT)=ICREDITLIMIT;
run;
proc sort data=xtab1;
 by SLOANTYPE REPAY_CD;
run;
/*����*/
proc transpose data=xtab1 out=xtab_cnt1(drop=_name_);
 by SLOANTYPE;
 id REPAY_CD;
 var _freq_;
run;
data B08(drop=_90 _120);
 format SLOANTYPE $LOAN_LEVEL.
        _901 20.
        _902 21.
        _903 22.
        _941 23.
        _942 24.
        _951 25.
        _952 26.
        _996 27.
        _997 28.
        _998 29.
        _999 30.
        all 20.
 ;
 label SLOANTYPE='��������'
       _901='0-3����'
       _902='3-6����'
       _903='6-12����'
       _941='12-24����'
       _942='24-36����'
       _951='36-48����'
       _952='48-60����'
       _996='60��������'
       _997='һ����'
       _998='������'
       _999='����'
        all='�ϼ�'
        ;
 set xtab_cnt1(where=(SLOANTYPE ne ''))
     xtab_cnt1(where=(SLOANTYPE eq ''));
 if SLOANTYPE eq '' then SLOANTYPE='�ϼ�';
 all=sum(of _:);
 array numr _numeric_;
 do over numr;
  if numr eq . then numr=0;
 end;
run;
/*���*/
proc transpose data=xtab1 out=xtab_amt1(drop=_name_ _label_);
 by SLOANTYPE;
 id REPAY_CD;
 var ICREDITLIMIT;
run;
data B09(drop=_90 _120);
 format SLOANTYPE $LOAN_LEVEL.
        _901 20.
        _902 21.
        _903 22.
        _941 23.
        _942 24.
        _951 25.
        _952 26.
        _996 27.
        _997 28.
        _998 29.
        _999 30.
        all 20.
 ;
 label SLOANTYPE='��������'
       _901='0-3����'
       _902='3-6����'
       _903='6-12����'
       _941='12-24����'
       _942='24-36����'
       _951='36-48����'
       _952='48-60����'
       _996='60��������'
       _997='һ����'
       _998='������'
       _999='����'
        all='�ϼ�'
        ;
 set xtab_amt1(where=(SLOANTYPE ne ''))
     xtab_amt1(where=(SLOANTYPE eq ''));
 if SLOANTYPE eq '' then SLOANTYPE='�ϼ�';
 all=sum(of _:);
 array numr _numeric_;
 do over numr;
  if numr eq . then numr=0;
  numr=numr/10000;
 end;
run;



/*B10. ����������ҵ����ʡ�������ֲ�*/
/*T-1��*/
data provsummary_n;
 format prov_level $20. iflag $20.;
 set B06;
 prov_level=put(i,PROV_CNT_LEVEL.);
run;
proc means data=provsummary_n noprint;
 class prov_level;
 output out=B10_n(rename=(_freq_=cnt_n) drop= i _type_) sum(i)=i;
run;

/*T-2��*/
proc sort data=loan_o out=loan_go(keep=short_nm prov_cd) nodupkey;
 by short_nm prov_cd;
run;
data B06_o(drop=prov_cd);
 format short_nm $20. i 2. prov $1000.;
 label short_nm='������' i='ʡ������' prov='ʡ��';
 retain prov;
 retain i;
 set loan_go;
 by short_nm prov_cd;
 if first.short_nm then do;
  i=0;
  prov='';
 end;
 prov=catx(' ',prov,prov_cd);
 i=i+1;
 if last.short_nm then do;
  output;
 end;
run;
proc sort data=B06_o;
 by descending i;
run;

data provsummary_o;
 format prov_level $20. iflag $20.;
 set B06_o;
 prov_level=put(i,PROV_CNT_LEVEL.);
run;
proc means data=provsummary_o noprint;
 class prov_level;
 output out=B10_o(rename=(_freq_=cnt_o) drop= i _type_) sum(i)=i;
run;

/*�ۺ����ݴ���*/
data B10_s;
 merge B10_n B10_o;
 by prov_level;
run;
data B10(drop=prov_level);
 format prov $20. cnt_n 4. cnt_o 4. add percentn8.2;
 set B10_s(where=(prov_level ne ''))
     B10_s(where=(prov_level eq ''));
 prov=put(prov_level,$PROV_CNT.);
 if prov eq '' then prov='�ϼ�';
 add=cnt_n/cnt_o-1;
run;

/*ɾ��*/
proc sql;
 drop table b_sum_n,b_sum_o,b_sum,loan_g,loan_p,provsummary_n,B10_n,loan_go,B06_o,provsummary_o,B10_o,B10_s
            ,xtab1,xtab_cnt1,xtab_amt1;
quit;



%MEND;
