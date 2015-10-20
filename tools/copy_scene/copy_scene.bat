set cur_dir=%~dps0
cd "%cur_dir%"
FOR /f "delims=" %%s IN ('dir "%cur_dir%trunk\Scene" /a:d /b') do copy /Y "%cur_dir%trunk\Scene\%%s\Config.xml" "%cur_dir%branch\pf\Scene\%%s"
cd "%cur_dir%branch/pf/Scene"
call start.bat
pause
