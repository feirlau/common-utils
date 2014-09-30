@echo off
set path=%path%;C:\Python27
echo png2swf Started
python png2swf.py > log.txt
echo png2swf finished, see log.txt for result
pause