@echo off
set cur_dir=%~dps0
call %cur_dir%\..\env.bat
set path=%path%;C:\Python27
echo png8 started
echo png8 is running, please wait...

copy /Y "%cur_dir%\png8.py" "%build_assets%"
copy /Y "%cur_dir%\pngnqi.exe" "%build_assets%"
python "%build_assets%\png8.py"
xcopy /Y /E "%build_assets%\out" "%build_assets%"

echo png8 finished, see log.txt and *.log for result

if %to_pause% == 1 (
    pause
)