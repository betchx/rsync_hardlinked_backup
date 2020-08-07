@echo off 

rem ===========================================================================
rem dup-to-hard-link.rb を使って，
rem 位置を移動したファイルをハードリンクに置き換える．

rem オプション
set OPT=--min-size=1kB
rem    -n, --min-size=size              処理対象とする最小のファイルサイズ
rem    -v, --verbose                    途中経過を表示
rem    -q, --quiet                      経過表示を抑制


rem このバッチファイルのディレクトリにバックアップされている．
cd /d %~dp0


rem 直近とその直前のバックアップのディレクトリ名を取得
rem ループで上書きされることを利用
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

