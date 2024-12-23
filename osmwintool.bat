@echo off
echo _______________________________________________________________________________________________________________________
echo OpenSim Windows Tool Version 23122024 V9
echo Systemvorraussetzung zum erstellen vom OpenSimulator:
echo DOTNET 8.0.x https://dotnet.microsoft.com/en-us/download/dotnet/8.0
echo Visual Tudio 22 Community https://visualstudio.microsoft.com/de/vs/community/
echo Git https://git-scm.com/downloads/win
echo _______________________________________________________________________________________________________________________
set /p setupChoice="Moechten Sie das Setup starten? ([J]/N): "

:: Standardwert "J" setzen, wenn keine Eingabe gemacht wurde
if "%setupChoice%"=="" set setupChoice=J

if /i "%setupChoice%" NEQ "J" (
    echo Setup abgebrochen.
    exit /b
)

echo _______________________________________________________________________________________________________________________
echo Starte die OpenSim Setup...
echo _______________________________________________________________________________________________________________________
echo Ueberpruefen, ob das opensimsource Verzeichnis existiert
echo _______________________________________________________________________________________________________________________

if not exist "opensimsource" (
    echo opensimsource Verzeichnis existiert nicht, lade OpenSim herunter...
    git clone https://github.com/opensim/opensim.git opensimsource
) else (
    echo opensimsource uebersprungen.
)

echo _______________________________________________________________________________________________________________________
echo Money Repository
echo _______________________________________________________________________________________________________________________
set /p moneyChoice="Moechten Sie das Money Repository herunterladen? ([N]/J): "

:: Standardwert "N" setzen, wenn keine Eingabe gemacht wurde
if "%moneyChoice%"=="" set moneyChoice=N

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
echo PayPal Repository
echo _______________________________________________________________________________________________________________________
    set /p paypalChoice="Moechten Sie das PayPal Repository herunterladen? ([N]/J): "

    :: Standardwert "N" setzen, wenn keine Eingabe gemacht wurde
    if "%paypalChoice%"=="" set paypalChoice=N

    if /i "%paypalChoice%"=="J" (
        git clone https://github.com/AdamFrisby/DTL-PayPal.git DTL-PayPal
    ) else (
        echo Money Repository uebersprungen.
    )

@REM echo _______________________________________________________________________________________________________________________
@REM echo webrtc Repository
@REM echo _______________________________________________________________________________________________________________________
@REM set /p webrtcChoice="Moechten Sie os-webrtc-janus herunterladen? (J/N): "
@REM if /i "%webrtcChoice%"=="J" 
@REM (
@REM     echo _______________________________________________________________________________________________________________________
@REM     echo os-webrtc-janus Repository in ein Unterverzeichnis von opensimsource klonen
@REM     echo _______________________________________________________________________________________________________________________

@REM     if not exist "opensimsource\addon-modules\os-webrtc-janus" (
@REM         echo Lade os-webrtc-janus herunter...
@REM         cd opensimsource\addon-modules
@REM         git clone https://github.com/Misterblue/os-webrtc-janus.git os-webrtc-janus     
@REM     ) else (
@REM         echo os-webrtc-janus bereits vorhanden, ueberspringe den Download...
@REM     )
@REM )

:: Inventar herunterladen
echo _______________________________________________________________________________________________________________________
echo Inventar Repository
echo _______________________________________________________________________________________________________________________
set /p InventarChoice="Moechten Sie das Inventar Repository herunterladen? ([J]/N): "

:: Standardwert "J" setzen, wenn keine Eingabe gemacht wurde
if "%InventarChoice%"=="" set InventarChoice=J

if /i "%InventarChoice%"=="J" (

    :: Skripte herunterladen
    if not exist "opensimsource\opensim-ossl-example-scripts" (
    echo Lade Skripte herunter...
    cd opensimsource
    git clone https://github.com/ManfredAabye/opensim-ossl-example-scripts.git opensim-ossl-example-scripts
    cd ..
    ) else (
        echo opensim-ossl-example-scripts bereits vorhanden, ueberspringe den Download...
    )
    xcopy /s /y "opensimsource\opensim-ossl-example-scripts\ScriptsAssetSet\*.*" "opensimsource\bin\assets\ScriptsLibrary\"
    xcopy /s /y "opensimsource\opensim-ossl-example-scripts\inventory\ScriptsLibrary\*.*" "opensimsource\bin\inventory\ScriptsLibrary\"

    :: Inventar Ruth2
    if not exist "opensimsource\Ruth2" (
    echo Lade Ruth2 herunter...
    cd opensimsource
    git clone https://github.com/ManfredAabye/Ruth2.git Ruth2
    cd ..
    ) else (
        echo Ruth2 bereits vorhanden, ueberspringe den Download...
    )
    xcopy /s /y "opensimsource\Ruth2\Artifacts\IAR\*.iar" "opensimsource\bin\Library"

    :: Inventar Roth2
    if not exist "opensimsource\Roth2" (
    echo Lade Roth2 herunter...
    cd opensimsource
    git clone https://github.com/ManfredAabye/Roth2.git Roth2
    cd ..
    ) else (
        echo Roth2 bereits vorhanden, ueberspringe den Download...
    )
    xcopy /s /y "opensimsource\Roth2\Artifacts\IAR\*.iar" "opensimsource\bin\Library"
    ) else (
        echo Inventar Repository uebersprungen.
)

echo _______________________________________________________________________________________________________________________
echo diva-distribution-master
echo _______________________________________________________________________________________________________________________
set /p divaChoice="Moechten Sie diva-distribution-master herunterladen? ([N]/J): "

:: Standardwert "N" setzen, wenn keine Eingabe gemacht wurde
if "%divaChoice%"=="" set divaChoice=N

if /i "%divaChoice%"=="J" (
    echo _______________________________________________________________________________________________________________________
    echo Diva Wifi Repository in ein Unterverzeichnis von opensimsource klonen
    echo _______________________________________________________________________________________________________________________

    if not exist "opensimsource\diva-distribution-master" (
        echo Lade diva-distribution-master herunter...
        cd opensimsource
        git clone https://github.com/ManfredAabye/diva-distribution.git diva-distribution-master
        git clone https://github.com/ManfredAabye/d2.git d2-master
        cd ..
    ) else (
        echo diva-distribution-master bereits vorhanden, ueberspringe den Download...
    )

    echo _______________________________________________________________________________________________________________________
    echo Kopiere Dateien von diva-distribution-master nach opensimsource...
    echo _______________________________________________________________________________________________________________________

    xcopy /s /y "opensimsource\diva-distribution-master\addon-modules\00Data\*.*" "opensimsource\addon-modules\00Data\"
    xcopy /s /y "opensimsource\diva-distribution-master\addon-modules\00DivaInterfaces\*.*" "opensimsource\addon-modules\00DivaInterfaces\"
    xcopy /s /y "opensimsource\diva-distribution-master\addon-modules\01DivaUtils\*.*" "opensimsource\addon-modules\01DivaUtils\"
    xcopy /s /y "opensimsource\diva-distribution-master\addon-modules\1DivaOpenSimServices\*.*" "opensimsource\addon-modules\1DivaOpenSimServices\"
    xcopy /s /y "opensimsource\diva-distribution-master\addon-modules\20WifiScriptEngine\*.*" "opensimsource\addon-modules\20WifiScriptEngine\"
    xcopy /s /y "opensimsource\diva-distribution-master\addon-modules\21Wifi\*.*" "opensimsource\addon-modules\21Wifi\"
) else (
    echo diva-distribution-master uebersprungen.
)

echo _______________________________________________________________________________________________________________________
echo Wechsle in das Verzeichnis opensimsource...
echo _______________________________________________________________________________________________________________________

cd opensimsource

echo _______________________________________________________________________________________________________________________
echo example Endungen entfernen
echo _______________________________________________________________________________________________________________________
set /p exampleChoice="Moechten Sie .example Endungen in allen Dateien entfernen? ([J]/N): "

:: Standardwert "J" setzen, wenn keine Eingabe gemacht wurde
if "%exampleChoice%"=="" set exampleChoice=J

if /i "%exampleChoice%"=="J" (
for /r %%f in (*.example) do (
    set "newname=%%~dpnf"
    >nul 2>&1 ren "%%f" "%%~nf")
)

echo _______________________________________________________________________________________________________________________
echo Test Region erstellen
echo _______________________________________________________________________________________________________________________
set /p RegionChoice="Moechten Sie eine Test Region erstellen? ([J]/N): "

:: Standardwert "J" setzen, wenn keine Eingabe gemacht wurde
if "%RegionChoice%"=="" set RegionChoice=J

if /i "%RegionChoice%"=="J" (
:: Zielpfad zur Datei
cd opensimsource
git clone https://github.com/ManfredAabye/OpenSim-Terrain.git OpenSim-Terrain
cd ..
xcopy /s /y "opensimsource\OpenSim-Terrain\*.raw" "opensimsource\bin"
xcopy /s /y "opensimsource\OpenSim-Terrain\*.png" "opensimsource\bin"
xcopy /s /y "opensimsource\OpenSim-Terrain\*.oar" "opensimsource\bin"
xcopy /s /y "opensimsource\OpenSim-Terrain\*.ini" "opensimsource\bin\Regions"


:: Erfolgsmeldung ausgeben
echo Die Datei Regionsdaten wurden aktualisiert.
)

echo _______________________________________________________________________________________________________________________
echo Kopiere System.Drawing.Common.dll.win in bin...
echo _______________________________________________________________________________________________________________________
cd opensimsource
copy bin\System.Drawing.Common.dll.win bin\System.Drawing.Common.dll
cd ..
echo _______________________________________________________________________________________________________________________
echo Erstelle die Prebuild Dateien...
echo _______________________________________________________________________________________________________________________
:: Voher cleanen sonst doppelte eintragungen von dotnet 8.0
:: Wenn die Datei OpenSim.sln vorhanden ist kann ein clean nicht schaden oder?
cd opensimsource
if exist "OpenSim.sln" (
dotnet bin\prebuild.dll /file prebuild.xml /clean
)

dotnet bin\prebuild.dll /target vs2022 /targetframework net8_0 /excludedir = "obj | bin" /file prebuild.xml

echo _______________________________________________________________________________________________________________________
echo Erstelle die compile.bat...
echo _______________________________________________________________________________________________________________________

@echo Creating compile.bat
@echo dotnet build --configuration Release OpenSim.sln > compile.bat

echo _______________________________________________________________________________________________________________________
set /p compileChoice="Moechten Sie den OpenSimulator jetzt kompilieren? ([J]/N): "

:: Standardwert "J" setzen, wenn keine Eingabe gemacht wurde
if "%compileChoice%"=="" set compileChoice=J

echo _______________________________________________________________________________________________________________________
if /i "%compileChoice%"=="J" (
    echo Starte die Kompilierung von OpenSimulator...
    dotnet build --configuration Release OpenSim.sln
) else (
    echo Kompilierung uebersprungen.
)
cd ..

echo _______________________________________________________________________________________________________________________
set /p DivaChoice="Diva distribution erstellen? ([N]/J): "

:: Standardwert "N" setzen, wenn keine Eingabe gemacht wurde
if "%DivaChoice%"=="" set DivaChoice=N

echo _______________________________________________________________________________________________________________________
if /i "%DivaChoice%"=="J" (

    mkdir diva-distribution\bin
    xcopy /s /y "bin\*.*" "diva-distribution\bin\"

    @REM cd diva-distribution
    @REM xcopy /s /y "opensimsource\diva-distribution-master\README.*
    @REM xcopy /s /y "opensimsource\diva-distribution-master\CONTRIBUTORS.txt
    @REM xcopy /s /y "opensimsource\diva-distribution-master\LICENSE.txt
    @REM xcopy /s /y "opensimsource\diva-distribution-master\ThirdPartyLicenses
    @REM xcopy /s /y "opensimsource\diva-distribution-master\bin\* bin


@REM diva-distribution Verzeichnis anlegen
@REM OpenSim hineincopieren
@REM /bin/mautil.exe starten

@REM kopieren von Dateien
@REM cp "$1"/README.* .
@REM cp "$1"/CONTRIBUTORS.txt .
@REM cp "$1"/LICENSE.txt .
@REM cp -r "$1"/ThirdPartyLicenses .
@REM cp -r "$1"/bin/* bin
) else (
    echo Diva distribution uebersprungen.
)
echo _______________________________________________________________________________________________________________________
echo Zurueck ins Hauptverzeichnis...
cd ..

echo _______________________________________________________________________________________________________________________
echo Setup abgeschlossen.
echo _______________________________________________________________________________________________________________________
echo Sie benoetigen noch einen OpenSim faehigen Viewer den bekommen sie hier: "https://wiki.firestormviewer.org/downloads"
echo Starten sie nun den OpenSimulator mit dem Befehl "dotnet opensim.dll" dieser befindet sich im Verzeichnis opensimsource/bin
echo Im folgenden Fenster geben sie "create user" ein und erstellen einen neuen User mit dem Namen "opensim avatar".
echo Wenn das Land unterwasser ist, geben sie ein: "terrain fill 20.5" dann ist ihr Land 50cm ueber der Wassergrenze.
echo Wenn sie ein forgefertigtes Land haben moechten dann geben sie in der Konsole "load oar terrain.oar" ein.
echo Starten sie ihren Firestorm Viewer und waehlen sie unter - Einstellungen - OpenSim - neues Grid hinzufuegen - aus 
echo und fuegen dort "http://127.0.0.1:9000" ein.

pause
