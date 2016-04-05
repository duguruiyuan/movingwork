/*客户相关指标分析*/
/*表格维度大幅度更新 更新人：李楠 时间：2015-03-25 已测试*/
%MACRO CUST_ANALYSIS(STAT_DT);

%LET LAST_DT=INTNX('MONTH',&STAT_DT.,-1,'END');




/*T-1月*/
/*取有贷款业务的人*/
proc sort data=loan_n(keep=sname scerttype scertno) out=cust_loan_n1 nodupkey;
 by sname scerttype scertno;
run;
/*取人员认证信息*/
proc sort data=sino_person_cert_n(keep=sname scerttype scertno spin)
          out=cert_n1;
 by sname scerttype scertno;
run;
/*合并有贷款业务的人和人员认证*/
data cust_loan_n2;
 merge cert_n1(in=ina) cust_loan_n1(in=inb);
 by sname scerttype scertno;
 certin=ina;
 loanin=inb;
 if ina;
run;
/*取人员信息表根据spin排序*/
proc sort data=sino_person_n(keep=spin dbirthday IMARRIAGE IEDULEVEL IEDUDEGREE IGENDER)
          out=person_n nodupkey;
 by spin;
run;
/*合并人员信息和有贷款业务的人及人员认证*/
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





/*T-2月*/
/*取有贷款业务的人*/
proc sort data=loan_o(keep=sname scerttype scertno) out=cust_loan_o1 nodupkey;
 by sname scerttype scertno;
run;
/*取人员认证信息*/
proc sort data=sino_person_cert_o(keep=sname scerttype scertno spin)
          out=cert_o1;
 by sname scerttype scertno;
run;
/*合并有贷款业务的人和人员认证*/
data cust_loan_o2;
 merge cert_o1(in=ina) cust_loan_o1(in=inb);
 by sname scerttype scertno;
 certin=ina;
 loanin=inb;
 if ina;
run;
/*取人员信息表根据spin排序*/
proc sort data=sino_person_o(keep=spin dbirthday IMARRIAGE IEDULEVEL IEDUDEGREE IGENDER)
          out=person_o;
 by spin;
run;
/*合并人员信息和有贷款业务的人及人员认证*/
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

/*综合处理*/
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


/*	1.	C01客户是否发生业务分布情况表	*/
data C01(keep=inflag cnt_n prop_n prop_o);
 format
  inflag $8.
  cnt_n 10.
  prop_n percentn8.2
  prop_o percentn8.2
  ;
 label
  inflag='业务状态'
  cnt_n='当月客户总数'
  prop_n='当月占比'
  prop_o='上月占比'
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
 if loanin eq 1 then inflag='已发生';
 else if loanin eq 0 then inflag='未发生';
 else inflag='合计';
  prop_n=cnt_n/sum_n;
  prop_o=cnt_o/sum_o;
run;
/*	2.	C02客户性别状况分布情况表*/
data C02(keep=genderflag cnt_n prop_n prop_o);
 format
  genderflag $8.
  cnt_n 10.
  prop_n percentn8.2
  prop_o percentn8.2
  ;
 label
  genderflag='性别'
  cnt_n='当月客户总数'
  prop_n='当月占比'
  prop_o='上月占比'
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
 if igender eq 1 then genderflag='男';
 else if igender eq 2 then genderflag='女';
 else if igender eq 9 then genderflag='其他';
 else genderflag='合计';
  prop_n=cnt_n/sum_n;
  prop_o=cnt_o/sum_o;
run;

/*3.	C03客户年龄状况分布情况表*/
data C03(keep=age_cd loannum_n prop_loan prop_all cnt_n);
 format
  age_cd $10.
  loannum_n 10.
  prop_loan percentn8.2
  cnt_n 10.
  prop_all percentn8.2
  ;
 label
  age_cd='年龄分布'
  loannum_n='发生业务的客户数'
  prop_loan='发生业务各年龄段客户占比'
  cnt_n='总客户数'
  prop_all='总客户各年龄段占比'
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
 if age_cd eq '' then age_cd='合计';
run;

/*4.	C04客户婚姻状况分布情况表*/
data C04(keep=marflag loannum_n prop_loan prop_all cnt_n);
 format
  marflag $10.
  loannum_n 10.
  prop_loan percentn8.2
  cnt_n 10.
  prop_all percentn8.2
  ;
 label
  marflag='婚姻状况'
  loannum_n='发生业务的客户数'
  prop_loan='发生业务各年龄段客户占比'
  cnt_n='总客户数'
  prop_all='总客户各年龄段占比'
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
 if marflag eq '' then marflag='合计';
run;


/*5.	C05客户学历状况分布情况表*/
data C05(keep=eduflag loannum_n prop_loan prop_all cnt_n);
 format
  eduflag $10.
  loannum_n 10.
  prop_loan percentn8.2
  cnt_n 10.
  prop_all percentn8.2
  ;
 label
  eduflag='学历情况'
  loannum_n='发生业务的客户数'
  prop_loan='发生业务各年龄段客户占比'
  cnt_n='总客户数'
  prop_all='总客户各年龄段占比'
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
 if eduflag eq '' then eduflag='合计';
run;



/*%MEND CUST_ANALYSIS;*/
/*李楠 2015-02-05*/
%MEND;
