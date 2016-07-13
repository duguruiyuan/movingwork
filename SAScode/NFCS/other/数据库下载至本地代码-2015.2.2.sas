/*参数配置，仅需将8月全量替换成其他即可，但前提是先在“E：\数据”文件夹中新建一个相同名字的文件夹*/
%LET DATAPATH=D:\work\creditriskcard\data\DB160530001;
LIBNAME SSS "&DATAPATH.";
/*连接Oracle数据库*/
options compress=yes mprint mlogic noxwait;
libname mylib oracle user=datauser password=zlxdh7jf path=nfcs;
Libname crm1 odbc user=uperpcrm password=uperpcrm datasrc=crm;
/*数据提取与复制到本地*/
/*DATA	monitor_mview_all_refresh	;SET	MYLIB.monitor_mview_all_refresh	;RUN;		*/
/*DATA	mv_sino_loan	;SET	MYLIB.mv_sino_loan	;RUN;		*/
/*DATA	mv_sino_loan_APPLY	;SET	MYLIB.mv_sino_loan_APPLY	;RUN;		*/
/*DATA	mv_sino_loan_COMPACT	;SET	MYLIB.mv_sino_loan_COMPACT	;RUN;		*/
/*DATA	mv_sino_loan_GUARANTEE	;SET	MYLIB.mv_sino_loan_GUARANTEE	;RUN;		*/
/*DATA	mv_sino_loan_INVESTOR	;SET	MYLIB.mv_sino_loan_INVESTOR	;RUN;		*/
/*DATA	mv_sino_loan_SPEC_TRADE	;SET	MYLIB.mv_sino_loan_SPEC_TRADE	;RUN;		*/
/*DATA	mv_sino_PERSON	;SET	MYLIB.mv_sino_PERSON	;RUN;		*/
/*DATA	mv_sino_PERSON_ADDRESS	;SET	MYLIB.mv_sino_PERSON_ADDRESS	;RUN;		*/
/*DATA	mv_sino_PERSON_CERTIFICATION	;SET	MYLIB.mv_sino_PERSON_CERTIFICATION	;RUN;		*/
/*DATA	mv_sino_PERSON_EMPLOYMENT	;SET	MYLIB.mv_sino_PERSON_EMPLOYMENT	;RUN;		*/
data sss.sino_area;set mylib.sino_area;run;						
data sss.SINO_CREDIT_ORGPLATE;set mylib.SINO_CREDIT_ORGPLATE;run;						
data sss.SINO_CREDIT_PLATE;set mylib.SINO_CREDIT_PLATE;run;						
data sss.SINO_CREDIT_PLATESECTION;set mylib.SINO_CREDIT_PLATESECTION;run;						
data sss.sino_credit_record;set mylib.sino_credit_record;run;						
data sss.SINO_CREDIT_SECTION;set mylib.SINO_CREDIT_SECTION;run;						
data sss.sino_dictinfo;set mylib.sino_dictinfo;run;						
data sss.sino_dicttypeinfo;set mylib.sino_dicttypeinfo;run;						
data sss.sino_function;set mylib.sino_function;run;						
data sss.sino_loan;set mylib.sino_loan;run;						
data sss.sino_loan_apply;set mylib.sino_loan_apply;run;						
data sss.sino_loan_apply_BAK;set mylib.sino_loan_apply_BAK;run;						
data sss.sino_loan_compact;set mylib.sino_loan_compact;run;						
data sss.sino_loan_GUARANTEE;set mylib.sino_loan_GUARANTEE;run;						
data sss.sino_loan_IDUPDATE;set mylib.sino_loan_IDUPDATE;run;						
data sss.sino_loan_investor;set mylib.sino_loan_investor;run;						
data sss.sino_loan_spec_trade;set mylib.sino_loan_spec_trade;run;						
data sss.sino_log;set mylib.sino_log;run;						
data sss.sino_modify_reason;set mylib.sino_modify_reason;run;						
data sss.sino_msg;set mylib.sino_msg;run;						
data sss.sino_msg_column;set mylib.sino_msg_column;run;						
data sss.sino_msg_ERROR;set mylib.sino_msg_ERROR;run;						
data sss.sino_msg_feedback;set mylib.sino_msg_feedback;run;						
data sss.sino_msg_section;set mylib.sino_msg_section;run;						
data sss.sino_msg_type;set mylib.sino_msg_type;run;						
data sss.sino_org;set mylib.sino_org;run;						
data sss.sino_org_relation;set mylib.sino_org_relation;run;						
data sss.sino_P2P_modify_reason;set mylib.sino_P2P_modify_reason;run;						
data sss.sino_person;set mylib.sino_person;run;						
data sss.sino_person_address;set mylib.sino_person_address;run;						
data sss.sino_person_address_his;set mylib.sino_person_address_his;run;						
data sss.sino_person_certification;set mylib.sino_person_certification;run;						
data sss.sino_person_employment;set mylib.sino_person_employment;run;						
data sss.sino_person_employment_his;set mylib.sino_person_employment_his;run;						
data sss.sino_person_his;set mylib.sino_person_his;run;						
data sss.sino_person_loan_collect;set mylib.sino_person_loan_collect;run;						
data sss.sino_person_wait_collect;set mylib.sino_person_wait_collect;run;						
data sss.sino_sysconfig;set mylib.sino_sysconfig;run;						
data sss.sino_task;set mylib.sino_task;run;						
data sss.sino_taskdetail;set mylib.sino_taskdetail;run;						
data sss.sino_usergroupfunction;set mylib.sino_usergroupfunction;run;						
data sss.vsino_usergroupinfo;set mylib.sino_usergroupinfo;run;						
data sss.sino_userinfo;set mylib.sino_userinfo;run;						
data sss.Cias_org_query;set mylib.Cias_org_query;run;
data sss.Cias_cis_query;set mylib.Cias_cis_query;run;
data sss.t_contract_order;set crm1.t_contract_order;run;
/*PROC COPY IN=WORK OUT=SSS;*/
/*RUN;*/
