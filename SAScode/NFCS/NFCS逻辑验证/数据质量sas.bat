@echo on
 echo. date > mydate
 date 2016-1-1
 start sas.exe E:\�ּ���\code\��������\ģ�⻷����������������-����-V1.2.sas
 dir mydate | find "mydate" | date
 del mydate
 at 22:00 shutdown -s -t 0 
 exit
@echo off