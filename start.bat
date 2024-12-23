@echo off
:: Verzeichnis definieren
set "binDir=opensimsource\bin"

:: Prüfen, ob MoneyServer.dll existiert und starten
if exist "%binDir%\MoneyServer.dll" (
    echo MoneyServer.dll gefunden. Starte MoneyServer...
    pushd "%binDir%"
    dotnet MoneyServer.dll
    popd
) else (
    echo MoneyServer.dll nicht gefunden.
)

:: Prüfen, ob OpenSim.dll existiert und starten
if exist "%binDir%\OpenSim.dll" (
    echo OpenSim.dll gefunden. Starte OpenSim...
    pushd "%binDir%"
    dotnet OpenSim.dll
    popd
) else (
    echo OpenSim.dll nicht gefunden.
)

:: Skript abgeschlossen
echo Alle Aufgaben abgeschlossen.
