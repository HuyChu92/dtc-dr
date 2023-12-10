@echo off
echo Running CMD commands...
echo.

REM Your CMD commands go here
call env\scripts\activate.bat 
cd digitaltwins
python manage.py runserver

REM Open Chrome with the specified URL
start chrome http://127.0.0.1:8000/

echo.
echo CMD commands executed.
pause
