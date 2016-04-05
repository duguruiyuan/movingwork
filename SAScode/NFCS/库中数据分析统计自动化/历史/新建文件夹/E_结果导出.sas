%macro outdata;
/*结果导出*/
/*贷款地区*/
x "&includepath.\贷款地区分析模板.xls";
filename ex dde "excel|&includepath.\[贷款地区分析模板.xls]D01机构分布情况表!r2c1:r200c10";
data _null_;
 set d01;
 file ex;
 put orgarea org_cnt_n prop_n org_cnt_o prop_o orgadd_r;
run;

filename ex dde "excel|&includepath.\[贷款地区分析模板.xls]D02贷款账户分布情况表!r2c1:r200c10";
data _null_;
 set d02;
 file ex;
 put orgarea loan_cnt_n  prop_cnt orgadd_cnt loan_amt_n  prop_amt orgadd_amt per_n per_o;
run;

filename ex dde "excel|&includepath.\[贷款地区分析模板.xls]D03贷款客户分布情况表!r2c1:r200c10";
data _null_;
 set d03;
 file ex;
 put orgarea -- add;
run;

filename ex dde "excel|&includepath.\[贷款地区分析模板.xls]D04逾期账户分布情况表!r2c1:r200c10";
data _null_;
 set d04;
 file ex;
 put orgarea owe_cnt_n loan_cnt_n prop_cnt owe_amt_n loan_amt_n prop_amt per_owe per_loan;
run;

filename ex dde "excel|&includepath.\[贷款地区分析模板.xls]D06贷款申请分布情况表!r2c1:r200c10";
data _null_;
 set d06;
 file ex;
 put orgarea apply_cnt_n prop_cnt add_cnt apply_amt_n prop_amt add_amt per_n per_o;
run;

filename ex dde "excel|&includepath.\[贷款地区分析模板.xls]D07特殊交易分布情况表!r2c1:r200c10";
data _null_;
 set d07;
 file ex;
 put orgarea spec_cnt_n prop_cnt add_cnt spec_amt_n prop_amt add_amt per_n per_o;
run;

filename ex dde "excel|&includepath.\[贷款地区分析模板.xls]D08特殊交易客户分布情况表!r2c1:r200c10";
data _null_;
 set d08;
 file ex;
 put orgarea lz_cust_n per_n lz_cust_o per_o add_r;
run;


filename ex dde 'excel|system';
data _null_;
 file ex;
 put '[run("format")]';
 put "[save.as("&OUTPATH_D01.")]";
 put '[quit]';
run;

filename ex clear;

/*一般业务*/
x "&includepath.\一般业务分析模板.xls";
filename ex dde "excel|&includepath.\[一般业务分析模板.xls]B01按照贷款金额分段统计!r2c1:r200c10";
data _null_;
 set b01;
 file ex;
 put amt_cd -- per_o;
run;

filename ex dde "excel|&includepath.\[一般业务分析模板.xls]B02按照贷款类型统计!r2c1:r200c10";
data _null_;
 set b02;
 file ex;
 put sloantype -- per_o;
run;

filename ex dde "excel|&includepath.\[一般业务分析模板.xls]B03按照担保方式统计!r2c1:r200c10";
data _null_;
 set b03;
 file ex;
 put igway -- per_o;
run;

filename ex dde "excel|&includepath.\[一般业务分析模板.xls]B04按照还款年限统计!r2c1:r200c10";
data _null_;
 set b04;
 file ex;
 put repay_cd -- per_o;
run;

filename ex dde "excel|&includepath.\[一般业务分析模板.xls]B06贷款机构业务发生地域情况分布情况表!r2c1:r400c10" LRECL=32767;
data _null_;
 set b06;
 file ex;
 put short_nm i prov;
run;

filename ex dde "excel|&includepath.\[一般业务分析模板.xls]B07业务发生地机构分布情况表!r2c1:r400c10" LRECL=32767;
data _null_;
 set b07;
 file ex;
 put prov_cd i name;
run;

filename ex dde "excel|&includepath.\[一般业务分析模板.xls]B08按账期长度贷款类型交叉户数表!r2c1:r200c15";
data _null_;
 set b08;
 file ex;
 put sloantype -- all;
run;

filename ex dde "excel|&includepath.\[一般业务分析模板.xls]B09按账期长度贷款类型交叉金额表!r2c1:r200c15";
data _null_;
 set b09;
 file ex;
 put sloantype -- all;
run;

filename ex dde "excel|&includepath.\[一般业务分析模板.xls]B10机构数量按业务发生省市数量分布!r2c1:r200c10";
data _null_;
 set b10;
 file ex;
 put prov -- add;
run;

filename ex dde 'excel|system';
data _null_;
 file ex;
 put '[run("format")]';
 put "[save.as("&OUTPATH_B01.")]";
 put '[quit]';
run;

filename ex clear;

/*逾期分析*/
x "&includepath.\贷款逾期分析模板.xls";
filename ex dde "excel|&includepath.\[贷款逾期分析模板.xls]O01逾期情况表!r2c1:r200c10";
data _null_;
 set o01;
 file ex;
 put sloantype -- per_o;
run;

filename ex dde "excel|&includepath.\[贷款逾期分析模板.xls]O02逾期率!r2c1:r200c10";
data _null_;
 set o02;
 file ex;
 put sloantype -- add;
run;

filename ex dde "excel|&includepath.\[贷款逾期分析模板.xls]O03逾期31_60天!r2c1:r200c10";
data _null_;
 set o03;
 file ex;
 put sloantype -- per_o;
run;

filename ex dde "excel|&includepath.\[贷款逾期分析模板.xls]O04逾期61_90天!r2c1:r200c10";
data _null_;
 set o04;
 file ex;
 put sloantype -- per_o;
run;

filename ex dde "excel|&includepath.\[贷款逾期分析模板.xls]O05逾期91_180天!r2c1:r400c10";
data _null_;
 set o05;
 file ex;
 put sloantype -- per_o;
run;

filename ex dde "excel|&includepath.\[贷款逾期分析模板.xls]O06逾期180天以上!r2c1:r400c10";
data _null_;
 set o06;
 file ex;
 put sloantype -- per_o;
run;

filename ex dde "excel|&includepath.\[贷款逾期分析模板.xls]O07逾期率!r2c1:r200c10";
data _null_;
 set o07;
 file ex;
 put open_dur_cd -- overdue_180_;
run;


filename ex dde 'excel|system';
data _null_;
 file ex;
 put '[run("format")]';
 put "[save.as("&OUTPATH_O01.")]";
 put '[quit]';
run;

filename ex clear;

/*客户分析*/
x "&includepath.\贷款客户分析模板.xls";
filename ex dde "excel|&includepath.\[贷款客户分析模板.xls]C01客户是否发生业务分布情况表!r2c1:r200c10";
data _null_;
 set c01;
 file ex;
 put inflag -- prop_o;
run;

filename ex dde "excel|&includepath.\[贷款客户分析模板.xls]C02客户性别状况分布情况表!r2c1:r200c10";
data _null_;
 set c02;
 file ex;
 put genderflag -- prop_o;
run;

filename ex dde "excel|&includepath.\[贷款客户分析模板.xls]C03客户年龄状况分布情况表!r2c1:r200c10";
data _null_;
 set c03;
 file ex;
 put age_cd -- prop_all;
run;

filename ex dde "excel|&includepath.\[贷款客户分析模板.xls]C04客户婚姻状况分布情况表!r2c1:r200c10";
data _null_;
 set c04;
 file ex;
 put marflag -- prop_all;
run;

filename ex dde "excel|&includepath.\[贷款客户分析模板.xls]C05客户学历状况分布情况表!r2c1:r400c10";
data _null_;
 set c05;
 file ex;
 put eduflag -- prop_all;
run;


filename ex dde 'excel|system';
data _null_;
 file ex;
 put '[run("format")]';
 put "[save.as("&OUTPATH_C01.")]";
 put '[quit]';
run;

filename ex clear;

%mend outdata;
