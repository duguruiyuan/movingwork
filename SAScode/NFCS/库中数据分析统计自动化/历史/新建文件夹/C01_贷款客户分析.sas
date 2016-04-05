/*�ͻ����ָ�����*/
/*���ά�ȴ���ȸ��� �����ˣ���� ʱ�䣺2015-03-25 �Ѳ���*/
%MACRO CUST_ANALYSIS(STAT_DT);

%LET LAST_DT=INTNX('MONTH',&STAT_DT.,-1,'END');




/*T-1��*/
/*ȡ�д���ҵ�����*/
proc sort data=loan_n(keep=sname scerttype scertno) out=cust_loan_n1 nodupkey;
 by sname scerttype scertno;
run;
/*ȡ��Ա��֤��Ϣ*/
proc sort data=sino_person_cert_n(keep=sname scerttype scertno spin)
          out=cert_n1;
 by sname scerttype scertno;
run;
/*�ϲ��д���ҵ����˺���Ա��֤*/
data cust_loan_n2;
 merge cert_n1(in=ina) cust_loan_n1(in=inb);
 by sname scerttype scertno;
 certin=ina;
 loanin=inb;
 if ina;
run;
/*ȡ��Ա��Ϣ�����spin����*/
proc sort data=sino_person_n(keep=spin dbirthday IMARRIAGE IEDULEVEL IEDUDEGREE IGENDER)
          out=person_n nodupkey;
 by spin;
run;
/*�ϲ���Ա��Ϣ���д���ҵ����˼���Ա��֤*/
proc sort data=cust_loan_n2;
 by spin;
run;
data cust_loan_n;
 merge cust_loan_n2(in=ina) person_n(in=inb);
 by spin;
 personin=inb;
 if ina;
 if mod(substr(scertno,17,1),2) eq 1 then igender=1;
 else if mod(substr(scertno,17,1),2) eq 0 then igender=2;
 else igender=9;
 if length(scertno) eq 18 then dbirthday=mdy(substr(scertno,11,2),substr(scertno,13,2),substr(scertno,7,4));
 age_cd=put(intck('year',dbirthday,&STAT_DT.),age_level.);
 if imarriage eq . then imarriage=90;
 if iedulevel eq . then iedulevel=99;
run;

proc means data=cust_loan_n noprint;
 class loanin igender age_cd imarriage iedulevel;
 var loanin;
 output out=cust_n(drop=_type_ rename=(_freq_=cnt_n))
        sum(loanin)=loannum_n;
run;





/*T-2��*/
/*ȡ�д���ҵ�����*/
proc sort data=loan_o(keep=sname scerttype scertno) out=cust_loan_o1 nodupkey;
 by sname scerttype scertno;
run;
/*ȡ��Ա��֤��Ϣ*/
proc sort data=sino_person_cert_o(keep=sname scerttype scertno spin)
          out=cert_o1;
 by sname scerttype scertno;
run;
/*�ϲ��д���ҵ����˺���Ա��֤*/
data cust_loan_o2;
 merge cert_o1(in=ina) cust_loan_o1(in=inb);
 by sname scerttype scertno;
 certin=ina;
 loanin=inb;
 if ina;
run;
/*ȡ��Ա��Ϣ�����spin����*/
proc sort data=sino_person_o(keep=spin dbirthday IMARRIAGE IEDULEVEL IEDUDEGREE IGENDER)
          out=person_o;
 by spin;
run;
/*�ϲ���Ա��Ϣ���д���ҵ����˼���Ա��֤*/
proc sort data=cust_loan_o2;
 by spin;
run;
data cust_loan_o;
 merge cust_loan_o2(in=ina) person_o(in=inb);
 by spin;
 personin=inb;
 if ina;
 if mod(substr(scertno,17,1),2) eq 1 then igender=1;
 else if mod(substr(scertno,17,1),2) eq 0 then igender=2;
 else igender=9;
 if length(scertno) eq 18 then dbirthday=mdy(substr(scertno,11,2),substr(scertno,13,2),substr(scertno,7,4));
 age_cd=put(intck('year',dbirthday,&STAT_DT.),age_level.);
 if imarriage eq . then imarriage=90;
 if iedulevel eq . then iedulevel=99;
run;

proc means data=cust_loan_o noprint;
 class loanin igender age_cd imarriage iedulevel;
 var loanin;
 output out=cust_o(drop=_type_ rename=(_freq_=cnt_o))
        sum(loanin)=loannum_o;
run;

/*�ۺϴ���*/
proc sort data= cust_n;
 by loanin igender age_cd imarriage iedulevel;
run;
proc sort data=cust_o;
 by loanin igender age_cd imarriage iedulevel;
run;
data cust;
 merge cust_n cust_o;
 by loanin igender age_cd imarriage iedulevel;
run;


/*	1.	C01�ͻ��Ƿ���ҵ��ֲ������	*/
data C01(keep=inflag cnt_n prop_n prop_o);
 format
  inflag $8.
  cnt_n 10.
  prop_n percentn8.2
  prop_o percentn8.2
  ;
 label
  inflag='ҵ��״̬'
  cnt_n='���¿ͻ�����'
  prop_n='����ռ��'
  prop_o='����ռ��'
  ;
 if _n_ eq 1 then set cust(where=(loanin eq .
                                  and igender eq .
                                  and age_cd eq ''
                                  and imarriage eq .
                                  and iedulevel eq .)
                           rename=(cnt_n=sum_n cnt_o=sum_o));
 set cust;
 if igender eq .;
 if age_cd eq '';
 if imarriage eq .;
 if iedulevel eq .;
 set cust(where=(loanin ne .
                 and igender eq .
                 and age_cd eq ''
                 and imarriage eq .
                 and iedulevel eq .))
     cust(where=(loanin eq .
                 and igender eq .
                 and age_cd eq ''
                 and imarriage eq .
                 and iedulevel eq .));
 if loanin eq 1 then inflag='�ѷ���';
 else if loanin eq 0 then inflag='δ����';
 else inflag='�ϼ�';
  prop_n=cnt_n/sum_n;
  prop_o=cnt_o/sum_o;
run;
/*	2.	C02�ͻ��Ա�״���ֲ������*/
data C02(keep=genderflag cnt_n prop_n prop_o);
 format
  genderflag $8.
  cnt_n 10.
  prop_n percentn8.2
  prop_o percentn8.2
  ;
 label
  genderflag='�Ա�'
  cnt_n='���¿ͻ�����'
  prop_n='����ռ��'
  prop_o='����ռ��'
  ;
 if _n_ eq 1 then set cust(where=(loanin eq .
                                  and igender eq .
                                  and age_cd eq ''
                                  and imarriage eq .
                                  and iedulevel eq .)
                           rename=(cnt_n=sum_n cnt_o=sum_o));
 set cust;
 if loanin eq .;
 if age_cd eq '';
 if imarriage eq .;
 if iedulevel eq .;
 set cust(where=(loanin eq .
                 and igender ne .
                 and age_cd eq ''
                 and imarriage eq .
                 and iedulevel eq .))
     cust(where=(loanin eq .
                 and igender eq .
                 and age_cd eq ''
                 and imarriage eq .
                 and iedulevel eq .));
 if igender eq 1 then genderflag='��';
 else if igender eq 2 then genderflag='Ů';
 else if igender eq 9 then genderflag='����';
 else genderflag='�ϼ�';
  prop_n=cnt_n/sum_n;
  prop_o=cnt_o/sum_o;
run;

/*3.	C03�ͻ�����״���ֲ������*/
data C03(keep=age_cd loannum_n prop_loan prop_all cnt_n);
 format
  age_cd $10.
  loannum_n 10.
  prop_loan percentn8.2
  cnt_n 10.
  prop_all percentn8.2
  ;
 label
  age_cd='����ֲ�'
  loannum_n='����ҵ��Ŀͻ���'
  prop_loan='����ҵ�������οͻ�ռ��'
  cnt_n='�ܿͻ���'
  prop_all='�ܿͻ��������ռ��'
  ;
 if _n_ eq 1 then set cust(where=(loanin eq .
                                  and igender eq .
                                  and age_cd eq ''
                                  and imarriage eq .
                                  and iedulevel eq .)
                           rename=(cnt_n=sum_n loannum_n=sumloan_n));
 set cust;
 if loanin eq .;
 if igender eq .;
 if imarriage eq .;
 if iedulevel eq .;
 set cust(where=(loanin eq .
                 and igender eq .
                 and age_cd ne ''
                 and imarriage eq .
                 and iedulevel eq .))
     cust(where=(loanin eq .
                 and igender eq .
                 and age_cd eq ''
                 and imarriage eq .
                 and iedulevel eq .));
 prop_loan=loannum_n/sumloan_n;
 prop_all=cnt_n/sum_n;
 if age_cd eq '' then age_cd='�ϼ�';
run;

/*4.	C04�ͻ�����״���ֲ������*/
data C04(keep=marflag loannum_n prop_loan prop_all cnt_n);
 format
  marflag $10.
  loannum_n 10.
  prop_loan percentn8.2
  cnt_n 10.
  prop_all percentn8.2
  ;
 label
  marflag='����״��'
  loannum_n='����ҵ��Ŀͻ���'
  prop_loan='����ҵ�������οͻ�ռ��'
  cnt_n='�ܿͻ���'
  prop_all='�ܿͻ��������ռ��'
  ;
 if _n_ eq 1 then set cust(where=(loanin eq .
                                  and igender eq .
                                  and age_cd eq ''
                                  and imarriage eq .
                                  and iedulevel eq .)
                           rename=(cnt_n=sum_n loannum_n=sumloan_n));
 set cust;
 if loanin eq .;
 if igender eq .;
 if age_cd eq '';
 if iedulevel eq .;
 set cust(where=(loanin eq .
                 and igender eq .
                 and age_cd eq ''
                 and imarriage ne .
                 and iedulevel eq .))
     cust(where=(loanin eq .
                 and igender eq .
                 and age_cd eq ''
                 and imarriage eq .
                 and iedulevel eq .));
 prop_loan=loannum_n/sumloan_n;
 prop_all=cnt_n/sum_n;
 if imarriage ne . then marflag=put(imarriage,MARRIAGE_TYPE.); 
 if marflag eq '' then marflag='�ϼ�';
run;


/*5.	C05�ͻ�ѧ��״���ֲ������*/
data C05(keep=eduflag loannum_n prop_loan prop_all cnt_n);
 format
  eduflag $10.
  loannum_n 10.
  prop_loan percentn8.2
  cnt_n 10.
  prop_all percentn8.2
  ;
 label
  eduflag='ѧ�����'
  loannum_n='����ҵ��Ŀͻ���'
  prop_loan='����ҵ�������οͻ�ռ��'
  cnt_n='�ܿͻ���'
  prop_all='�ܿͻ��������ռ��'
  ;
 if _n_ eq 1 then set cust(where=(loanin eq .
                                  and igender eq .
                                  and age_cd eq ''
                                  and imarriage eq .
                                  and iedulevel eq .)
                           rename=(cnt_n=sum_n loannum_n=sumloan_n));
 set cust;
 if loanin eq .;
 if igender eq .;
 if age_cd eq '';
 if imarriage eq .;
 set cust(where=(loanin eq .
                 and igender eq .
                 and age_cd eq ''
                 and imarriage eq .
                 and iedulevel ne .))
     cust(where=(loanin eq .
                 and igender eq .
                 and age_cd eq ''
                 and imarriage eq .
                 and iedulevel eq .));
 prop_loan=loannum_n/sumloan_n;
 prop_all=cnt_n/sum_n;
 if iedulevel ne . then eduflag=put(iedulevel,EDU_TYPE.); 
 if eduflag eq '' then eduflag='�ϼ�';
run;



/*%MEND CUST_ANALYSIS;*/
/*��� 2015-02-05*/
%MEND;
