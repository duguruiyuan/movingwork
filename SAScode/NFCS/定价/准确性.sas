%include "C:\work\code\GitHub\movingwork\SAScode\CONFIG.sas";
proc sort data = nfcs.sino_loan(drop = sloantype sloancompactcode scurrency iclass5stat iinfoindicator skeepcolumn ipersonid smsgfilename ilineno stoporgcode ipbcstate WHERE=(SUBSTR(sorgcode,1,1)='Q' 
and istate = 0 AND sorgcode not in ('Q10152900H0000','Q10152900H0001'))) out = sino_loan;
by iloanid dbillingdate descending dgetdate;
run;
/*%AddLabel(sino_loan);*/
data sino_loan;
informat zhangqi yymmn6.;
format zhangqi yymmn6.;
 set sino_loan;
 error_flag = 0;
 zhangqi = intnx('month',datepart(dbillingdate),0,'b');
/*label*/
/*	&label.*/
;
run;
proc sort data = sino_loan;
	by iloanid zhangqi descending dgetdate;
run;
data sino_loan;
	set sino_loan;
	if iloanid = lag(iloanid) and zhangqi = lag(zhangqi) then delete;
run;
/*Rule 2*/
/*---2、贷款逾期，帐户状态却为正常*/
/*错误*/
data sino_loan;
 set sino_loan;
	if icurtermspastdue > 0 and iaccountstat = 1 then error_flag = 1;
run;


/*Rule 4*/
/*---8、贷款未到期，本月应还款金额大于本月实际还款金额，但"账户状态"正常*/
/*错误*/
data sino_loan;
 set sino_loan;
if iaccountstat = 1 and ddateclosed ^= dbillingdate and ischeduledamount > iACTUALPAYAMOUNT then error_flag = 1;
run;

/*Rule 5*/
/*9、T+1开户时，"结算应还款日期"和"最近一次还款日期"应该等于"开户日期" （非T+1不适用）（T+1开户月--若不需还款和没发生还款，开户日上报一次）*/
/*错误*/
/*需要更新*/
data sino_loan;
 set sino_loan;
if sPaystat24month = '///////////////////////*' and (dbillingdate ^= ddateopened or drecentpaydate ^= ddateopened) then error_flag = 1;
run; 


 

/*Rule 9*/
/*15、贷款结清时，实际应还款金额不应为0*/
/*错误*/
data sino_loan;
 set sino_loan;
if substr(sPaystat24month,24,1) = 'C' and iaccountstat = 3 and iactualpayamount = 0 then error_flag = 1;
run;

/*Rule 10*/
/*16、在"本月应还款金额"为0，且"本月实际还款金额"大于0的情况下，24月还款状态不应为星号*/
/*错误*/
data sino_loan;
 set sino_loan;
if ischeduledamount = 0 and iactualpayamount > 0 and substr(sPaystat24month,24, 1) = '*' then error_flag = 1;
run;

/*Rule 11*/
/*18、上月正常还款，当月逾期未还款时，当前逾期总额应该等于""本月应还款金额""与"实际还款金额"之差*/
/*错误*/
data sino_loan;
 set sino_loan;
if substr(sPaystat24month, 23, 2) = 'N1' and (ischeduledamount - iactualpayamount > iamountpastdue + 1 or ischeduledamount - iactualpayamount < iamountpastdue - 1) 
then error_flag = 1;
run;

/*Rule 12*/
/*19、按月还款除开户外,"本月应还款金额"不应该为0(特殊情况除外)*/
/*错误*/
data sino_loan;
 set sino_loan;
 if sPaystat24month ^= '///////////////////////*' and sTermsfreq = '03' and ischeduledamount=0 
	and intnx('month',datepart(dbillingdate),0,'end') ^= intnx('month',datepart(ddateopened),0,'end') then error_flag = 1;
run;

/*Rule 13*/
/*20、按月还款到期后，"结算应还款日期"不等于月底*/
/*错误*/
data sino_loan;
 set sino_loan;
 if sTermsfreq = '03' and datepart(dbillingdate) ^= intnx('month',datepart(dbillingdate),0,'end') and iaccountstat ^= 3 
	and intnx('month',datepart(dbillingdate),0,'end') > intnx('month',datepart(ddateclosed),0,'end') then error_flag = 1;
run;

/*Rule 14*/
/*22、到期后，"累计逾期期数"、"当前逾期期数"、"最高逾期期数"不应该继续累计*/
/*错误*/
/*需要更新*/
proc sql;
create table rule_14 as select
iloanid
,iid
,ddateclosed    ,
dbillingdate    ,
drecentpaydate   ,  
iamountpastdue   ,
icurtermspastdue ,
itermspastdue ,
imaxtermspastdue ,
iaccountstat  ,
sPaystat24month
  from nfcs.sino_loan(where = (iaccountstat = 2 and intnx('month',datepart(ddateclosed),0,'end') <= intnx('month',datepart(dbillingdate),0,'end')))
   order by iloanid,dbillingdate
;
quit;
data rule_14;
	set rule_14;
	if iloanid = lag(iloanid) and dbillingdate > lag(dbillingdate) and icurtermspastdue <= lag(icurtermspastdue) and itermspastdue <= lag(itermspastdue) and imaxtermspastdue <= lag(imaxtermspastdue) then delete;
run;
proc sql;
	create table rule_14_t as select
		iloanid
		,count(iloanid) as cnt
		from rule_14
		group by iloanid
		having calculated cnt > 1
	;
quit;
proc sql;
	create table rule_14 as select
		*
		from rule_14 as a
		where iloanid in (select iloanid from rule_14_t)
   order by iloanid,dbillingdate
	;
quit;
proc sql;
	update sino_loan
	set error_flag = 1
	where iid in (select iid from rule_14)
;
quit;

/*Rule 15*/
/*23、24月还款状态最后为1时，31-60未归还本金应该为0*/
/*错误*/
data sino_loan;
 set sino_loan;
 if substr(sPaystat24month,24,1) = '1' and iamountpastdue30 ^= 0 then error_flag = 1;
run;


 /*Rule 17*/
/*27、"实际还款金额"大于等于"本月应还款金额"时，24个月还款状态取值不准确*/
/*错误*/
data sino_loan;
 set sino_loan;
 if  iactualpayamount >= ischeduledamount
   and substr(sPaystat24month, 23, 1) in ('*','#','/','N')
   and substr(sPaystat24month, 24, 1) not in ('*','#','/','N','C')
then error_flag = 1;
run;

 /*Rule 18*/
/*29、按月还款账户，上个月逾期本月账户正常的情况下，"实际还款金额"应该大于"本月应还款金额"*/
/*错误*/
data sino_loan;
 set sino_loan;
 if  substr(sPaystat24month,24,1)='N' and substr(sPaystat24month,23,1) not in ('*','#','/','N') and iactualpayamount<=ischeduledamount and dbillingdate <= ddateclosed
then error_flag = 1;
run;

/*Rule 19*/
/*33、按月还款到期之后,当前逾期总额不应该小于余额*/
/*错误*/
data sino_loan;
 set sino_loan;
 if sTermsfreq = '03' and dbillingdate > ddateclosed and (iamountpastdue < ibalance)
then error_flag = 1;
run;



/*Rule 22*/
/*40、正常结清的贷款，"本月应还款金额"应该等于"实际还款金额"*/
/*错误*/
data sino_loan;
 set sino_loan;
 if substr(sPaystat24month,23,1) in ('*','#','/','N') and iaccountstat = 3 and ischeduledamount ^= iactualpayamount  and  ddateclosed = dbillingdate
then error_flag = 1;
run;
proc sort data=sino_loan;
	by sorgcode;
run;
data error(keep=sorgcode errorp);
	set sino_loan(keep=sorgcode error_flag);
	by sorgcode;
	retain errorN;
	retain allN;
	if first.sorgcode then do;
		errorN=0;
		allN=0;
	end;
	errorN+error_flag;
	allN+1;
	errorp=1-errorN/allN;
	format errorp percentn8.2;
	label
		sorgcode='机构号'
		errorp='准确率'
	;
	if last.sorgcode;
run;
/*补充校验规则*/




/*Rule 25*/
/*及时性*/
/*未入库的贷款业务清单*/
/*错误*/
/*proc sort data = nfcs.sino_loan(keep = sorgcode iloanid dbillingdate IACCOUNTSTAT where = (SUBSTR(sorgcode,1,1)='Q' AND sorgcode not in ('Q10152900H0000','Q10152900H0001'))) out= loan_all;*/
/*by iloanid descending dbillingdate;*/
/*run;*/
/*data loan_all;*/
/*	set loan_all;*/
/*	if iloanid = lag(iloanid) then delete;*/
/*	if IACCOUNTSTAT not in (1,2) then delete;*/
/*run;*/
/*proc sql;*/
/*	create table loan_in as select*/
/*		T1.iloanid*/
/*		,T1.sorgcode*/
/*		,(case when T2.iloanid is null then 0 else 1 end) as jishixing_label*/
/*	from loan_all as T1*/
/*	left join sino_loan as T2*/
/*	on T1.iloanid = T2.iloanid*/
/*;*/
/*quit;*/
/**/
/*proc sql;*/
/*	create table _loan_m_sta_ as select*/
/*		t2.shortname label = "机构简称"*/
/*		,t2.person*/
/*		,T1.sorgcode label = "机构代码"*/
/*		,count(t1.iloanid) as total label = "应入库业务总量"*/
/*		,sum(t1.jishixing_label) as in_nfcs label = "已入库业务总量"*/
/*		,round(calculated in_nfcs/calculated total,0.0001) as in_per label = "及时率" format = percent8.2 informat = percent8.2*/
/*	from loan_in as t1*/
/*	left join config as T2*/
/*	on T1.sorgcode = T2.sorgcode*/
/*	group by shortname*/
/*	order by total desc*/
/*;*/
/*quit;*/
/*data _loan_m_sta_;*/
/*	set _loan_m_sta_;*/
/*	if sorgcode = lag(sorgcode) then delete;*/
/*run;*/
/*输出*/
proc sql;
	create table zqx_org as select
	T2.shortname label = "机构简称"
	,T2.person
/*	,sum(1,- sum(doubt_flag)/count(*)) as doubt_per label = "各机构准确率-怀疑" format = percent8.2 informat = percent8.2 */
	,count(T1.sorgcode) as record_cnt label = "贷款业务记录条数"
	,sum(t1.error_flag) as record_cnt_error label = "触发错误类规则记录条数"
	,1 - calculated record_cnt_error/calculated record_cnt as error_per label = "准确率" format = percent8.2 informat = percent8.2
	,T2.total
	,t2.in_nfcs
	,T2.in_per
	from sino_loan as T1
	left join _loan_m_sta_ as T2
	on T1.sorgcode = T2.sorgcode
	group by T1.sorgcode
;
quit;
data zqx_org;
	set zqx_org;
	if shortname = lag(shortname) then delete;
run;
proc sort data = zqx_org;
by desending record_cnt;
run;
/**/
/*/*ods listing off;*/*/
/* ods tagsets.excelxp file = "&outfile.库中逻辑校验情况表_&currmonth..xls" style = printer*/
/*      options(sheet_name="库中逻辑校验情况表" embedded_titles='yes' embedded_footnotes='yes' sheet_interval="bygroup" frozen_headers='yes' frozen_rowheaders='1' autofit_height='yes');*/
/*proc report data = zqx_org NOWINDOWS headline headskip*/
/*          style(header)={background=lightgray foreground=black font_weight=bold};*/
/*title "库中逻辑校验情况表";*/
/*	columns _all_;*/
/*	define person /display '专管员';*/
/*	define shortname/ display width=5;*/
/*	define record_cnt_error/ display '触发错误类规则/记录条数';*/
/*	define in_per/display center;*/
/*	define error_per/display center;*/
/*	compute after;*/
/* 	if in_per >= 0.9 and error_per >= 0.99 then */
/* 		call define(_row_,'style','style={background=lightyellow fontweight=bold}');*/
/* 	endcomp;*/
/*footnote '【准确率】仅考虑类型为【错误】的规则';*/
/*run;*/
/*ods tagsets.excelxp close;*/
/*  ods listing;*/
/**/
/**/
