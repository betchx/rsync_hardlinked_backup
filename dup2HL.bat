@echo off 

rem ===========================================================================
rem dup-to-hard-link.rb ���g���āC
rem �ʒu���ړ������t�@�C�����n�[�h�����N�ɒu��������D

rem �I�v�V����
set OPT=--min-size=1kB
rem    -n, --min-size=size              �����ΏۂƂ���ŏ��̃t�@�C���T�C�Y
rem    -v, --verbose                    �r���o�߂�\��
rem    -q, --quiet                      �o�ߕ\����}��


rem ���̃o�b�`�t�@�C���̃f�B���N�g���Ƀo�b�N�A�b�v����Ă���D
cd /d %~dp0


rem ���߂Ƃ��̒��O�̃o�b�N�A�b�v�̃f�B���N�g�������擾
rem ���[�v�ŏ㏑������邱�Ƃ𗘗p
setlocal EnableDelayedExpansion
set PREVIOUS=
set LATESTBKUP=
for /F "usebackq" %%I in (`dir /AD /B /ON *_20??-??-??`) do (
set PREVIOUS=!LATESTBKUP!
set LATESTBKUP=%%I
)
setlocal DisableDelayedExpansion

ruby ./dup-to-hard-link.rb %OPT% %PREVIOUS% %LATESTBKUP%

pause

