@echo off



echo _______________________________________________________________________________________________________________________
echo Starte die OpenSim Setup...
echo _______________________________________________________________________________________________________________________
echo Ueberpruefen, ob das opensimsource-Verzeichnis existiert
echo _______________________________________________________________________________________________________________________

if not exist "opensimsource" (
    echo Lade OpenSim herunter...
    git clone https://github.com/opensim/opensim.git opensimsource
) else (
	echo Loesche altes Verzeichniss...
	rmdir /s opensimsource
    echo Lade OpenSim herunter...
    git clone https://github.com/opensim/opensim.git opensimsource
)

:: Upgrade
:: git pull
:: DotNet 6
:: git checkout dotnet6

echo _______________________________________________________________________________________________________________________
echo Money Repository in ein Unterverzeichnis von opensimsource klonen
echo _______________________________________________________________________________________________________________________

if not exist "opensimsource\opensimcurrencyserver" (
    echo Lade Money-Modul herunter...
    git clone https://github.com/ManfredAabye/opensimcurrencyserver-dotnet.git opensimsource\opensimcurrencyserver
) else (
    echo Money-Modul bereits vorhanden, ueberspringe den Download...
)

echo _______________________________________________________________________________________________________________________
echo Kopiere Dateien von opensimcurrencyserver nach opensimsource...
echo _______________________________________________________________________________________________________________________

xcopy /s /y "opensimsource\opensimcurrencyserver\addon-modules\*.*" "opensimsource\addon-modules\"
xcopy /s /y "opensimsource\opensimcurrencyserver\bin\*.*" "opensimsource\bin\"

echo _______________________________________________________________________________________________________________________
echo Wechsle in das Verzeichnis opensimsource...
echo _______________________________________________________________________________________________________________________

cd opensimsource

echo _______________________________________________________________________________________________________________________
echo Entferne .example Endungen in allen Dateien...
echo _______________________________________________________________________________________________________________________

for /r %%f in (*.example) do (
    set "newname=%%~dpnf"
    >nul 2>&1 ren "%%f" "%%~nf"
)

echo _______________________________________________________________________________________________________________________
echo Kopiere System.Drawing.Common.dll.win in bin...
echo _______________________________________________________________________________________________________________________

copy bin\System.Drawing.Common.dll.win bin\System.Drawing.Common.dll

echo _______________________________________________________________________________________________________________________
echo Erstelle die Prebuild Dateien...
echo _______________________________________________________________________________________________________________________

dotnet bin\prebuild.dll /target vs2022 /targetframework net8_0 /excludedir = "obj | bin" /file prebuild.xml

echo _______________________________________________________________________________________________________________________
echo Erstelle die compile.bat...
echo _______________________________________________________________________________________________________________________

@echo Creating compile.bat
@echo dotnet build --configuration Release OpenSim.sln > compile.bat

echo _______________________________________________________________________________________________________________________
set /p compileChoice="Moechten Sie den OpenSimulator jetzt kompilieren? (J/N): "
echo _______________________________________________________________________________________________________________________
if /i "%compileChoice%"=="J" (
    echo Starte die Kompilierung von OpenSimulator...
    dotnet build --configuration Release OpenSim.sln
) else (
    echo Kompilierung uebersprungen.
)

echo _______________________________________________________________________________________________________________________
echo Zurueck ins Hauptverzeichnis...
cd ..

echo _______________________________________________________________________________________________________________________

echo Setup abgeschlossen.
pause
