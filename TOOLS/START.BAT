@ECHO OFF

rem ******************************************
rem * Plik wsadowy dla programu "Plan Zaj©†" *
rem ******************************************

rem Uruchomienie demontstracji
INTRO.EXE

rem Instalacja polskich czcionek
PL.EXE 0 >NUL

rem Uruchomienie gˆ¢wnego programu
PLAN_P.EXE

rem Usuni©cie polskich czcionek
PL.EXE /U >NUL
