@echo off
set path=%path%;C:\Python27
echo ConfigurationDataGenerator Started
python ConfigurationDataGenerator.py > log.txt
echo ConfigurationDataGenerator Finished
pause