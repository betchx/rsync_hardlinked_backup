@echo off 

rem ===========================================================================
rem MSYSのrsync.exeを使って履歴付き増分バックアップを取る
rem 参考：  https://hackers-high.com/linux/rsync-backup-part2/
rem 
rem チャンと動作させるためには，文字コードをSJISで，改行はCRLFで保存する必要がある．
rem 
rem MSYSをインストールしただけではrsyncはインストールされないので，あらかじめ
rem   pacman -S rsync
rem として，パッケージをインストールしておく必要がある．
rem 
rem このbatファイルは，バックアップを取る外付けHDD等に保存しておき，
rem バックアップしたい時にダブルクリックして実行する使い方を想定している．

rem 特徴
rem   同日に複数回実行した場合に対応できる様にした（つもり）


rem 設定セクション ============================================================

rem バックアップ対象フォルダ，ファイル
rem msys形式のフルパスでスペース区切り 最後にスラッシュはつけないほうが良い．
rem パスにスペースが含まれる場合はクォートする
set TARGETS=/C


rem 除外設定
set EXCLUDE=--exclude-from=%~pd0exclude.txt

set INCLUDE=--include-from=%~pd0include.txt

rem rsync.exeへのパス．通常はMSYSインストールディレクトリの usr\bin
set RSYNCPATH=c:\msys64\usr\bin

rem 設定終わり ================================================================


rem rsync.exeのチェック
if exist %RSYNCPATH%\rsync.exe goto :DoBackup

echo rsync.exeが %RSYNCPATH% に見つかりません．
echo batファイル中の「RSYNCPATH」の設定を確認してください．
echo なお，MSYS2の場合，デフォルトではrsyncはインストールされません．
echo スタートメニューからmsys2のコンソールを開いて
echo pacman -S rsync
echo として，rsyncをインストールしてください．

pause
goto :EOF

:DoBackup
rem このバッチファイルのディレクトリにバックアップを取る．
cd /d %~dp0

rem バックアップ先の親ディレクトリをmsys形式のパスで取得
set PTH=%~p0
set DI=%~d0
set BASEDIR=/%DI::=%%PTH:\=/%

rem 日付を習得
set DD=%DATE:/=-%

rem バックアップ先
set DEST=%BASEDIR%backup_%DD%

rem 直近とその直前のバックアップのディレクトリ名を取得
rem ループで上書きされることを利用
set PREVIOUS=
set LATESTBKUP=
for /F "usebackq" %%I in (`dir /AD /B /ON backup_*`) do (
set PREVIOUS=%LATESTBKUP%
set LATESTBKUP=%%I
)

rem rsyncのパスを設定
set PATH=%RSYNCPATH%;%PATH%

rem ログファイル名
set LOGFILE=%~pd0\DriveUsed.log

rem オプション
set OPT=-avh --log-file=%BASEDIR%logs/rsync_%DD%.log --no-links %EXCLUDE% %INCLUDE%

rem ログフォルダがない場合は作成する．
if not exist logs mkdir logs

rem 実行前のディスク容量の保存
echo ======================================================>> %LOGFILE%
echo Started at %DATE% %TIME% >> %LOGFILE%
fsutil volume diskFree %DI% >> %LOGFILE%
df  -hBM   .  >> %LOGFILE%

rem 初回実行の確認
if "%LATESTBKUP%" == "" goto :FIRST

rem 当日再実行の確認
if "%LATESTBKUP%" == "backup_%DD%" goto :MULTI_RUN

rem 増分バックアップ
echo %LATESTBKUP%からの差分バックアップ
rsync %OPT% --link-dest="%BASEDIR%%LATESTBKUP%" %TARGETS% %DEST%
goto :LAST


:MULTI_RUN
rem 同日に複数回起動した場合の処理

rem すでにファイルがあるので，updateオプションを追加．
set OPT=%OPT% --update

rem もう一つ前が空なら初回起動扱い
if "%PREVIOUS%" == "" goto :FIRST

rem 同日に複数回起動なので，前回と同じ構成で実行
echo %PREVIOUS%からの差分バックアップ
rsync %OPT% --link-dest="%BASEDIR%%PREVIOUS%" %TARGETS% %DEST%
goto :LAST


:FIRST
echo 初回バックアップ
rsync %OPT% %TARGETS% %DEST%


:LAST
rem 実行後のディスク容量の保存
echo ------------------------------------------------------>> %LOGFILE%
echo Finished at %DATE% %TIME% >> %LOGFILE%
fsutil volume diskFree %DI% >> %LOGFILE%
df  -hBM   .  >> %LOGFILE%


