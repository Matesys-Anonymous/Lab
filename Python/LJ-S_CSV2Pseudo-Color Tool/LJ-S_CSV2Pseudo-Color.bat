@echo off
chcp 65001 > nul
set SCRIPT=%~dp0lj_s_pseudocolor.py
if "%~1"=="" (
  py "%SCRIPT%"
) else (
  py "%SCRIPT%" "%~1"
)
echo.
pause
