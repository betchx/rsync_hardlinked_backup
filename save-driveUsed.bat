@echo off 

rem このバッチファイルのディレクトリにバックアップを取る．
cd /d %~dp0

rem ログファイル名
set LOGFILE=%~pd0\DriveUsed.log

rem rsync.exeへのパス．通常はMSYSインストールディレクトリの usr\bin
set RSYNCPATH=c:\msys64\usr\bin

rem rsyncのパスを設定
set PATH=%RSYNCPATH%;%PATH%

rem ディスク容量の保存
echo ======================================================>> %LOGFILE%
echo A snapshot was saved at %DATE% %TIME% >> %LOGFILE%
fsutil volume diskFree %~d0 >> %LOGFILE%
df  -hBM   .  >> %LOGFILE%

