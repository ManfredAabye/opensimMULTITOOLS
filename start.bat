@echo off

echo _____________________________________________________________________________________________________________________
echo opensimMULTITOOL Starter - Starte OpenSimulator...
echo _____________________________________________________________________________________________________________________

set "binDir=opensimsource\bin"
set "mariaDir=opensimsource\OpenSim-MariaDB-Micro-Database\DATABASE\bin"

:: Prüfen, ob OpenSim-MariaDB-Micro-Database existiert und starten
if exist "opensimsource\OpenSim-MariaDB-Micro-Database\DATABASE\bin\mariastart.bat" (
    echo mariastart.bat gefunden. Starte Database...
    pushd "%mariaDir%"
    start "" mariastart.bat
    popd
) else (
    echo mariastart.bat nicht gefunden.
)

:: Warten, um sicherzustellen, dass der Server bereit ist
timeout /t 5 > nul

:: Prüfen, ob MoneyServer.dll existiert und starten
if exist "%binDir%\MoneyServer.dll" (
    echo MoneyServer.dll gefunden. Starte MoneyServer...
    pushd "%binDir%"
    start "" dotnet MoneyServer.dll
    popd
) else (
    echo MoneyServer.dll nicht gefunden.
)

:: Prüfen, ob OpenSim.dll existiert und starten
if exist "%binDir%\OpenSim.dll" (
    echo OpenSim.dll gefunden. Starte OpenSim...
    pushd "%binDir%"
    start "" dotnet OpenSim.dll
    popd
) else (
    echo OpenSim.dll nicht gefunden.
)

echo Alle Aufgaben abgeschlossen.