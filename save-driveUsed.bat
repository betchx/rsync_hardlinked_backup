@echo off 

rem ���̃o�b�`�t�@�C���̃f�B���N�g���Ƀo�b�N�A�b�v�����D
cd /d %~dp0

rem ���O�t�@�C����
set LOGFILE=%~pd0\DriveUsed.log

rem rsync.exe�ւ̃p�X�D�ʏ��MSYS�C���X�g�[���f�B���N�g���� usr\bin
set RSYNCPATH=c:\msys64\usr\bin

rem rsync�̃p�X��ݒ�
set PATH=%RSYNCPATH%;%PATH%

rem �f�B�X�N�e�ʂ̕ۑ�
echo ======================================================>> %LOGFILE%
echo A snapshot was saved at %DATE% %TIME% >> %LOGFILE%
fsutil volume diskFree %~d0 >> %LOGFILE%
df  -hBM   .  >> %LOGFILE%

