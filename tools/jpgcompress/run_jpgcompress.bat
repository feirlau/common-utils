@echo off
set path=%path%;C:\Python27
set cur_dir=%~dps0
echo jpgcompress started
echo jpgcompress is running, please wait...
python "%cur_dir%jpgcompress.py"
echo jpgcompress finished, see log.txt and *.log for result
pause