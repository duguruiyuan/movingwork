@echo on
 echo. date > mydate
 date 2016-1-1
 start sas.exe E:\林佳宁\code\数据质量\模拟环境数据质量检查规则-部分-V1.2.sas
 dir mydate | find "mydate" | date
 del mydate
 at 22:00 shutdown -s -t 0 
 exit
@echo off