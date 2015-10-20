@echo off
set cur_dir=%~dps0
set path=%path%;C:\Python27
echo ConfigurationDataGenerator Started
python "%cur_dir%ConfigurationDataGenerator.py" > log.txt
echo ConfigurationDataGenerator Finished
pause