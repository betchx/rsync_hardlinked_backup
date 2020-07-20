@echo off 

rem ===========================================================================
rem MSYS��rsync.exe���g���ė���t�������o�b�N�A�b�v�����
rem �Q�l�F  https://hackers-high.com/linux/rsync-backup-part2/
rem 
rem �`�����Ɠ��삳���邽�߂ɂ́C�����R�[�h��SJIS�ŁC���s��CRLF�ŕۑ�����K�v������D
rem 
rem MSYS���C���X�g�[�����������ł�rsync�̓C���X�g�[������Ȃ��̂ŁC���炩����
rem   pacman -S rsync
rem �Ƃ��āC�p�b�P�[�W���C���X�g�[�����Ă����K�v������D
rem 
rem ����bat�t�@�C���́C�o�b�N�A�b�v�����O�t��HDD���ɕۑ����Ă����C
rem �o�b�N�A�b�v���������Ƀ_�u���N���b�N���Ď��s����g������z�肵�Ă���D

rem ����
rem   �����ɕ�������s�����ꍇ�ɑΉ��ł���l�ɂ����i����j


rem �ݒ�Z�N�V���� ============================================================

rem �o�b�N�A�b�v�Ώۃt�H���_�C�t�@�C�����L�������t�@�C�����w��D
rem msys�`���̃t���p�X�ŉ��s��؂�
rem �Ō�ɃX���b�V���͂��Ȃ��ق����ǂ��D
rem �p�X�ɃX�y�[�X���܂܂��ꍇ�̓N�H�[�g����K�v�����邩������Ȃ��D
set TARGETLIST=%~dp0targets.txt

rem ���O�ݒ蓙�̋L�����ꂽ�t�@�C�����w�肷��D
set EXCLUDE=--exclude-from=%~pd0exclude.txt
set INCLUDE=--include-from=%~pd0include.txt

rem rsync.exe�ւ̃p�X�D�ʏ��MSYS�C���X�g�[���f�B���N�g���� usr\bin
set RSYNCPATH=c:\msys64\usr\bin

rem �ݒ�I��� ================================================================


set TARGETS=
setlocal EnableDelayedExpansion
for /F "eol=#"  %%I in (%TARGETLIST%) do set TARGETS=!TARGETS! %%I
setlocal DisableDelayedExpansion

echo Backup from:%TARGETS%
if "%TARGETS%"=="" (
  echo Add backup target folders into %TARGETLIST%.
  goto :EOF
)


rem rsync.exe�̃`�F�b�N
if exist %RSYNCPATH%\rsync.exe goto :DoBackup

echo rsync.exe�� %RSYNCPATH% �Ɍ�����܂���D
echo bat�t�@�C�����́uRSYNCPATH�v�̐ݒ���m�F���Ă��������D
echo �Ȃ��CMSYS2�̏ꍇ�C�f�t�H���g�ł�rsync�̓C���X�g�[������܂���D
echo �X�^�[�g���j���[����msys2�̃R���\�[�����J����
echo pacman -S rsync
echo �Ƃ��āCrsync���C���X�g�[�����Ă��������D

pause
goto :EOF

:DoBackup
rem ���̃o�b�`�t�@�C���̃f�B���N�g���Ƀo�b�N�A�b�v�����D
cd /d %~dp0

rem �o�b�N�A�b�v��̐e�f�B���N�g����msys�`���̃p�X�Ŏ擾
set PTH=%~p0
set DI=%~d0
set BASEDIR=/%DI::=%%PTH:\=/%

rem ���t���K��
set DD=%DATE:/=-%

rem �o�b�N�A�b�v��
set DEST=%BASEDIR%backup_%DD%

rem ���߂Ƃ��̒��O�̃o�b�N�A�b�v�̃f�B���N�g�������擾
rem ���[�v�ŏ㏑������邱�Ƃ𗘗p
set PREVIOUS=
set LATESTBKUP=
for /F "usebackq" %%I in (`dir /AD /B /ON backup_*`) do (
set PREVIOUS=%LATESTBKUP%
set LATESTBKUP=%%I
)

rem rsync�̃p�X��ݒ�
set PATH=%RSYNCPATH%;%PATH%

rem ���O�t�@�C����
set LOGFILE=%~pd0\DriveUsed.log

rem �I�v�V����
rem a: arghive �A�[�J�C�u���[�h�i�u-rlptgoD -no-H -no-A -no-X�v�����j �Z�ċA�C�V�������N�C�p�[�~�b�V�����C���ԁC�O���[�v�C���L�ҁC�f�o�C�X �~�n�[�h�����N�CACL, �g������
rem v: verbose �o�ߕ\��
rem h: human readable �l���ǂ݂₷���\��
rem c: checksum �X�V�����ƃT�C�Y�ł͂Ȃ��C�`�F�b�N�T���Ŕ�r����D
set OPT=-avhc  --log-file=%BASEDIR%logs/rsync_%DD%.log --no-links %EXCLUDE% %INCLUDE%

rem ���O�t�H���_���Ȃ��ꍇ�͍쐬����D
if not exist logs mkdir logs

rem ���s�O�̃f�B�X�N�e�ʂ̕ۑ�
echo ======================================================>> %LOGFILE%
echo Started at %DATE% %TIME% >> %LOGFILE%
fsutil volume diskFree %DI% >> %LOGFILE%
df  -hBM   .  >> %LOGFILE%

rem ������s�̊m�F
if "%LATESTBKUP%" == "" goto :FIRST

rem �����Ď��s�̊m�F
if "%LATESTBKUP%" == "backup_%DD%" goto :MULTI_RUN

rem �����o�b�N�A�b�v
echo %LATESTBKUP%����̍����o�b�N�A�b�v
rsync %OPT% --link-dest="%BASEDIR%%LATESTBKUP%" %TARGETS% %DEST%
goto :LAST


:MULTI_RUN
rem �����ɕ�����N�������ꍇ�̏���

rem ���łɃt�@�C��������̂ŁCupdate�I�v�V������ǉ��D
set OPT=%OPT% --update

rem ������O����Ȃ珉��N������
if "%PREVIOUS%" == "" goto :FIRST

rem �����ɕ�����N���Ȃ̂ŁC�O��Ɠ����\���Ŏ��s
echo %PREVIOUS%����̍����o�b�N�A�b�v
rsync %OPT% --link-dest="%BASEDIR%%PREVIOUS%" %TARGETS% %DEST%
goto :LAST


:FIRST
echo ����o�b�N�A�b�v
rsync %OPT% %TARGETS% %DEST%


:LAST
rem ���s��̃f�B�X�N�e�ʂ̕ۑ�
echo ------------------------------------------------------>> %LOGFILE%
echo Finished at %DATE% %TIME% >> %LOGFILE%
fsutil volume diskFree %DI% >> %LOGFILE%
df  -hBM   .  >> %LOGFILE%


