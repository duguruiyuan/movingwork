%macro outdata;
/*�������*/
/*�������*/
x "&includepath.\�����������ģ��.xls";
filename ex dde "excel|&includepath.\[�����������ģ��.xls]D01�����ֲ������!r2c1:r200c10";
data _null_;
 set d01;
 file ex;
 put orgarea org_cnt_n prop_n org_cnt_o prop_o orgadd_r;
run;

filename ex dde "excel|&includepath.\[�����������ģ��.xls]D02�����˻��ֲ������!r2c1:r200c10";
data _null_;
 set d02;
 file ex;
 put orgarea loan_cnt_n  prop_cnt orgadd_cnt loan_amt_n  prop_amt orgadd_amt per_n per_o;
run;

filename ex dde "excel|&includepath.\[�����������ģ��.xls]D03����ͻ��ֲ������!r2c1:r200c10";
data _null_;
 set d03;
 file ex;
 put orgarea -- add;
run;

filename ex dde "excel|&includepath.\[�����������ģ��.xls]D04�����˻��ֲ������!r2c1:r200c10";
data _null_;
 set d04;
 file ex;
 put orgarea owe_cnt_n loan_cnt_n prop_cnt owe_amt_n loan_amt_n prop_amt per_owe per_loan;
run;

filename ex dde "excel|&includepath.\[�����������ģ��.xls]D06��������ֲ������!r2c1:r200c10";
data _null_;
 set d06;
 file ex;
 put orgarea apply_cnt_n prop_cnt add_cnt apply_amt_n prop_amt add_amt per_n per_o;
run;

filename ex dde "excel|&includepath.\[�����������ģ��.xls]D07���⽻�׷ֲ������!r2c1:r200c10";
data _null_;
 set d07;
 file ex;
 put orgarea spec_cnt_n prop_cnt add_cnt spec_amt_n prop_amt add_amt per_n per_o;
run;

filename ex dde "excel|&includepath.\[�����������ģ��.xls]D08���⽻�׿ͻ��ֲ������!r2c1:r200c10";
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

/*һ��ҵ��*/
x "&includepath.\һ��ҵ�����ģ��.xls";
filename ex dde "excel|&includepath.\[һ��ҵ�����ģ��.xls]B01���մ�����ֶ�ͳ��!r2c1:r200c10";
data _null_;
 set b01;
 file ex;
 put amt_cd -- per_o;
run;

filename ex dde "excel|&includepath.\[һ��ҵ�����ģ��.xls]B02���մ�������ͳ��!r2c1:r200c10";
data _null_;
 set b02;
 file ex;
 put sloantype -- per_o;
run;

filename ex dde "excel|&includepath.\[һ��ҵ�����ģ��.xls]B03���յ�����ʽͳ��!r2c1:r200c10";
data _null_;
 set b03;
 file ex;
 put igway -- per_o;
run;

filename ex dde "excel|&includepath.\[һ��ҵ�����ģ��.xls]B04���ջ�������ͳ��!r2c1:r200c10";
data _null_;
 set b04;
 file ex;
 put repay_cd -- per_o;
run;

filename ex dde "excel|&includepath.\[һ��ҵ�����ģ��.xls]B06�������ҵ������������ֲ������!r2c1:r400c10" LRECL=32767;
data _null_;
 set b06;
 file ex;
 put short_nm i prov;
run;

filename ex dde "excel|&includepath.\[һ��ҵ�����ģ��.xls]B07ҵ�����ػ����ֲ������!r2c1:r400c10" LRECL=32767;
data _null_;
 set b07;
 file ex;
 put prov_cd i name;
run;

filename ex dde "excel|&includepath.\[һ��ҵ�����ģ��.xls]B08�����ڳ��ȴ������ͽ��滧����!r2c1:r200c15";
data _null_;
 set b08;
 file ex;
 put sloantype -- all;
run;

filename ex dde "excel|&includepath.\[һ��ҵ�����ģ��.xls]B09�����ڳ��ȴ������ͽ������!r2c1:r200c15";
data _null_;
 set b09;
 file ex;
 put sloantype -- all;
run;

filename ex dde "excel|&includepath.\[һ��ҵ�����ģ��.xls]B10����������ҵ����ʡ�������ֲ�!r2c1:r200c10";
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

/*���ڷ���*/
x "&includepath.\�������ڷ���ģ��.xls";
filename ex dde "excel|&includepath.\[�������ڷ���ģ��.xls]O01���������!r2c1:r200c10";
data _null_;
 set o01;
 file ex;
 put sloantype -- per_o;
run;

filename ex dde "excel|&includepath.\[�������ڷ���ģ��.xls]O02������!r2c1:r200c10";
data _null_;
 set o02;
 file ex;
 put sloantype -- add;
run;

filename ex dde "excel|&includepath.\[�������ڷ���ģ��.xls]O03����31_60��!r2c1:r200c10";
data _null_;
 set o03;
 file ex;
 put sloantype -- per_o;
run;

filename ex dde "excel|&includepath.\[�������ڷ���ģ��.xls]O04����61_90��!r2c1:r200c10";
data _null_;
 set o04;
 file ex;
 put sloantype -- per_o;
run;

filename ex dde "excel|&includepath.\[�������ڷ���ģ��.xls]O05����91_180��!r2c1:r400c10";
data _null_;
 set o05;
 file ex;
 put sloantype -- per_o;
run;

filename ex dde "excel|&includepath.\[�������ڷ���ģ��.xls]O06����180������!r2c1:r400c10";
data _null_;
 set o06;
 file ex;
 put sloantype -- per_o;
run;

filename ex dde "excel|&includepath.\[�������ڷ���ģ��.xls]O07������!r2c1:r200c10";
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

/*�ͻ�����*/
x "&includepath.\����ͻ�����ģ��.xls";
filename ex dde "excel|&includepath.\[����ͻ�����ģ��.xls]C01�ͻ��Ƿ���ҵ��ֲ������!r2c1:r200c10";
data _null_;
 set c01;
 file ex;
 put inflag -- prop_o;
run;

filename ex dde "excel|&includepath.\[����ͻ�����ģ��.xls]C02�ͻ��Ա�״���ֲ������!r2c1:r200c10";
data _null_;
 set c02;
 file ex;
 put genderflag -- prop_o;
run;

filename ex dde "excel|&includepath.\[����ͻ�����ģ��.xls]C03�ͻ�����״���ֲ������!r2c1:r200c10";
data _null_;
 set c03;
 file ex;
 put age_cd -- prop_all;
run;

filename ex dde "excel|&includepath.\[����ͻ�����ģ��.xls]C04�ͻ�����״���ֲ������!r2c1:r200c10";
data _null_;
 set c04;
 file ex;
 put marflag -- prop_all;
run;

filename ex dde "excel|&includepath.\[����ͻ�����ģ��.xls]C05�ͻ�ѧ��״���ֲ������!r2c1:r400c10";
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
