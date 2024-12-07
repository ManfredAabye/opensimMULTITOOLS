@echo off

echo _______________________________________________________________________________________________________________________
echo Willkommen beim OpenSim Windows Tool!
echo _______________________________________________________________________________________________________________________
set /p setupChoice="Moechten Sie das Setup starten? (J/N): "
if /i "%setupChoice%" NEQ "J" (
    echo Setup abgebrochen.
    exit /b
)

echo _______________________________________________________________________________________________________________________
echo Starte die OpenSim Setup...
echo _______________________________________________________________________________________________________________________
echo Ueberpruefen, ob das opensimsource-Verzeichnis existiert
echo _______________________________________________________________________________________________________________________

if not exist "opensimsource" (
    echo Lade OpenSim herunter...
    git clone https://github.com/opensim/opensim.git opensimsource
) else (    
    echo Verzeichnis "opensimsource" existiert bereits, benennen sie es um, oder löschen sie es.
    exit /b
)

echo _______________________________________________________________________________________________________________________
echo Money Repository
echo _______________________________________________________________________________________________________________________
set /p moneyChoice="Moechten Sie das Money Repository herunterladen? (J/N): "
if /i "%moneyChoice%"=="J" (
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
) else (
    echo Money Repository uebersprungen.
)

echo _______________________________________________________________________________________________________________________
echo diva-distribution
echo _______________________________________________________________________________________________________________________
set /p divaChoice="Moechten Sie diva-distribution herunterladen? (J/N): "
if /i "%divaChoice%"=="J" (
    echo _______________________________________________________________________________________________________________________
    echo Diva Wifi Repository in ein Unterverzeichnis von opensimsource klonen
echo _______________________________________________________________________________________________________________________

    if not exist "opensimsource\diva-distribution" (
        echo Lade diva-distribution herunter...
        git clone https://github.com/ManfredAabye/diva-distribution.git opensimsource\diva-distribution
        git clone https://github.com/ManfredAabye/d2.git opensimsource\diva-distribution
    ) else (
        echo diva-distribution bereits vorhanden, ueberspringe den Download...
    )

    echo _______________________________________________________________________________________________________________________
    echo Kopiere Dateien von diva-distribution nach opensimsource...
    echo _______________________________________________________________________________________________________________________

    xcopy /s /y "opensimsource\diva-distribution\addon-modules\00Data\*.*" "opensimsource\addon-modules\00Data\"
    xcopy /s /y "opensimsource\diva-distribution\addon-modules\00DivaInterfaces\*.*" "opensimsource\addon-modules\00DivaInterfaces\"
    xcopy /s /y "opensimsource\diva-distribution\addon-modules\01DivaUtils\*.*" "opensimsource\addon-modules\01DivaUtils\"
    xcopy /s /y "opensimsource\diva-distribution\addon-modules\1DivaOpenSimServices\*.*" "opensimsource\addon-modules\1DivaOpenSimServices\"
    xcopy /s /y "opensimsource\diva-distribution\addon-modules\20WifiScriptEngine\*.*" "opensimsource\addon-modules\20WifiScriptEngine\"
    xcopy /s /y "opensimsource\diva-distribution\addon-modules\21Wifi\*.*" "opensimsource\addon-modules\21Wifi\"
) else (
    echo diva-distribution uebersprungen.
)

echo _______________________________________________________________________________________________________________________
echo Wechsle in das Verzeichnis opensimsource...
echo _______________________________________________________________________________________________________________________

cd opensimsource

echo _______________________________________________________________________________________________________________________
echo example Endungen entfernen
echo _______________________________________________________________________________________________________________________
set /p divaChoice="Moechten Sie .example Endungen in allen Dateien entfernen? (J/N): "
if /i "%divaChoice%"=="J" (
for /r %%f in (*.example) do (
    set "newname=%%~dpnf"
    >nul 2>&1 ren "%%f" "%%~nf"
)
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
