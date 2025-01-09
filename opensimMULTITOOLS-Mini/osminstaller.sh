#!/bin/bash

HOME_PATH=$(pwd)
CONFIG_FILE_NAME="Gridconfig.cfg"
CONFIG_FILE="$HOME_PATH/$CONFIG_FILE_NAME"

# opensimMULTITOOLS-Installer 0.01

KOMMANDO=$1

# region helper
function dummy() {
    # Das hat keine Funktion es ist nur ein Platzhalter.
    Robust=""
}

function osmmconfig() {
    echo "Wie viele Simulator-Verzeichnisse möchten Sie anlegen? (1-99)" 
    read -r sim_count

    # Prüfen, ob die Eingabe eine gültige Zahl ist
    if ! [[ "$sim_count" =~ ^[0-9]+$ ]] || [ "$sim_count" -lt 1 ]; then
        echo "Ungültige Eingabe. Bitte eine Zahl größer als 0 eingeben."
        return 1
    fi

    # Konfigurationsdatei erstellen
    {
        echo "Robust=\"$HOME_PATH/robust/bin\""
        echo "MoneyServer=\"$HOME_PATH/robust/bin\""

        for ((i=1; i<=sim_count; i++)); do
            echo "Simulator$i=\"$HOME_PATH/sim$i/bin\""
        done
    } > "$CONFIG_FILE"

    echo "Konfigurationsdatei wurde mit $sim_count Simulator-Verzeichnissen erstellt."
}

function osmmcopy() {
    # Lade die Konfigurationsdatei
    if [ -f "$CONFIG_FILE" ]; then
        # shellcheck disable=SC1090
        source "$CONFIG_FILE"
    else
        echo "Konfigurationsdatei nicht gefunden!"
        exit 1
    fi

    # Kopiere Hauptverzeichnisse Robust und MoneyServer
    for var in Robust MoneyServer; do
        if [[ -n "${!var}" ]]; then
            dir_to_copy="$(dirname "${!var}")"  # Nur eine Ebene hochgehen
            if [[ ! -d "$dir_to_copy" ]]; then
                mkdir -p "$dir_to_copy"
            fi
            if [[ -d "$dir_to_copy" ]]; then
                echo "Copy: $dir_to_copy"
                cp -r "$HOME_PATH/opensim/bin/." "$dir_to_copy/bin"
            fi
        fi
    done

    # Kopiere die Simulatoren-Verzeichnisse (sim1, sim2, ..., sim99)
    for i in {1..99}; do
        sim_var="Simulator${i}"
        if [[ -n "${!sim_var}" ]]; then
            dir_to_copy="$(dirname "${!sim_var}")"  # Nur eine Ebene hochgehen
            if [[ ! -d "$dir_to_copy" ]]; then
                mkdir -p "$dir_to_copy"
            fi
            if [[ -d "$dir_to_copy" ]]; then
                echo "Copy: $dir_to_copy"
                cp -r "$HOME_PATH/opensim/bin/." "$dir_to_copy/bin"
            fi
        fi
    done
}

# Prüfen, ob die Konfigurationsdatei existiert, sonst erstellen
if [ -f "$CONFIG_FILE" ]; then
# shellcheck disable=SC1090
    source "$CONFIG_FILE"
else
    # Konfigurationsdatei erstellen.
    osmmconfig
    # Kopieren von Robust, MoneyServer und Simulatoren.
    if [ -f "$CONFIG_FILE" ]; then
        osmmcopy
    fi
fi

function del_opensim() {
    # Lade die Konfigurationsdatei
    if [ -f "$CONFIG_FILE" ]; then
    # shellcheck disable=SC1090
        source "$CONFIG_FILE"
    else
        echo "Konfigurationsdatei nicht gefunden!"
        exit 1
    fi
    # Lösche Hauptverzeichnisse Robust und MoneyServer
    for var in Robust MoneyServer; do
        if [[ -n "${!var}" ]]; then
            dir_to_delete="$(dirname "${!var}")"  # Nur das übergeordnete Verzeichnis
            if [[ -d "$dir_to_delete" ]]; then
                echo "Lösche: $dir_to_delete"
                rm -r "$dir_to_delete"
            fi
        fi
    done
    # Lösche die Simulatoren-Verzeichnisse (sim1, sim2, ..., sim99)
    for i in {1..99}; do
        sim_var="Simulator${i}"
        if [[ -n "${!sim_var}" ]]; then
            dir_to_delete="$(dirname "${!sim_var}")"  # Nur das Hauptverzeichnis von simX
            if [[ -d "$dir_to_delete" ]]; then
                echo "Lösche: $dir_to_delete"
                rm -r "$dir_to_delete"
            fi
        fi
    done
}

function warnings() {
    local myerror=0

    packages=("apache2" "libapache2-mod-php" "php" "php-mysql" "sqlite3" "mariadb-server" "dotnet-sdk-8.0" "aspnetcore-runtime-8.0" "screen" "apt-utils" "libgdiplus" "libc6-dev" "graphicsmagick" "imagemagick")

    for package in "${packages[@]}"; do
        if ! dpkg -l | grep -q "^ii  $package"; then
            echo "$package is not installed. Please install $package and try again."
            echo "Example: sudo apt-get install -y $package"
            myerror=1
        else
            echo "     $package is installed."
        fi
    done

    if [ $myerror -eq 1 ]; then
        echo "Installing missing packages..."
        sudo apt-get install -y "${packages[@]}"
        echo "Please try again."
        exit 1
    fi
    exit
}

function server_install() {
    echo "Installing LAMP with MariaDB"
    sudo apt-get install -y apache2 libapache2-mod-php php php-mysql sqlite3 mariadb-server dotnet-sdk-8.0 aspnetcore-runtime-8.0 screen apt-utils libgdiplus libc6-dev graphicsmagick imagemagick
    exit
}

function uninstall_mysql() {
    #! Uninstall mysql if it doesn't work.
    sudo apt-get -y remove --purge mysql*
    sudo apt-get -y purge mysql*
    sudo apt-get -y autoremove
    sudo apt-get -y autoclean
    sudo apt-get -y remove dbconfig-mysql
    exit
}

function help() {
    echo "opensimMULTITOOLS-Installer 0.01"
    echo "Usage: $0 osmmconfig|warnings|server_install|uninstall_mysql"
    exit
}
# endregion

function osconfiginstall() {
    echo "Was möchten Sie installieren?"
    echo "1) Ein offenes Grid"
    echo "2) Ein geschlossenes Grid"
    echo "3) Ein offenes Grid mit Geld"
    echo "4) Ein geschlossenes Grid mit Geld"
    echo "5) Einen offenen Standalone OpenSimulator"
    echo "6) Einen geschlossenen Standalone OpenSimulator"
    read -rp "Bitte wählen Sie eine Option (1-6): " choice

    case $choice in
        1) configuration_opengrid ;;
        2) configuration_closedgrid ;;
        3) configuration_openmoneygrid ;;
        4) configuration_closedmoneygrid ;;
        5) configuration_simulatoropen ;;
        6) configuration_simulatorclose ;;
        *) echo "Ungültige Auswahl."; exit ;;
    esac
}

# Grids Konfigurieren.
# region Grid
function configuration_opengrid() {
    cd "$Robust" || exit
    # Auswahl: Offenes Grid -> Robust.HG.ini.example in Robust.ini kopieren
    cp Robust.HG.ini.example Robust.ini

    # Benutzer nach der IP-Adresse fragen (Standard: 127.0.0.1)
    read -rp "Welche IP-Adresse wollen Sie nutzen? (Standard: 127.0.0.1) " IPadress
    IPadress=${IPadress:-127.0.0.1}

    # Benutzer nach den notwendigen Daten fragen
    read -rp "Datenbankname (Standard: opensim): " DATABASE
    DATABASE=${DATABASE:-opensim}

    read -rp "Datenbankbenutzername (Standard: opensim): " USERNAME
    USERNAME=${USERNAME:-opensim}

    read -rp "Datenbankpasswort: " PASSWORD
    PASSWORD=${PASSWORD:-""} # Falls leer, bleibt es leer

    read -rp "Standardregion (Standard: DefaultRegion): " DEFAULTREGION
    DEFAULTREGION=${DEFAULTREGION:-DefaultRegion}

    read -rp "Gridname (Standard: the lost continent of hippo): " GRIDNAME
    GRIDNAME=${GRIDNAME:-"the lost continent of hippo"}

    read -rp "Grid-Kürzel (Standard: hippogrid): " HIPPOGRID
    HIPPOGRID=${HIPPOGRID:-hippogrid}

    # Konfiguration der Robust.ini mit den eingegebenen Werten
    sed -i "s/BaseHostname = \"127.0.0.1\"/BaseHostname = \"$IPadress\"/g" Robust.ini
    sed -i "s@; HomeURI = \"\${Const|BaseURL}:\${Const|PublicPort}\"@HomeURI = \"\${Const|BaseURL}:\${Const|PublicPort}\"@g" Robust.ini
    sed -i "s@; GatekeeperURI = \"\${Const|BaseURL}:\${Const|PublicPort}\"@GatekeeperURI = \"\${Const|BaseURL}:\${Const|PublicPort}\"@g" Robust.ini
    sed -i "s@ConnectionString = \"Data Source=localhost;Database=opensim;User ID=opensim;Password=\*\*\*\*\*;Old Guids=true;SslMode=None;\"@ConnectionString = \"Data Source=localhost;Database=$DATABASE;User ID=$USERNAME;Password=$PASSWORD;Old Guids=true;SslMode=None;\"@g" Robust.ini
    sed -i "s@; Region_Welcome_Area = \"DefaultRegion, DefaultHGRegion\"@Region_$DEFAULTREGION = \"DefaultRegion, DefaultHGRegion\"@g" Robust.ini
    sed -i "s/gridname = \"the lost continent of hippo\"/gridname = \"$GRIDNAME\"/g" Robust.ini
    sed -i "s/gridnick = \"hippogrid\"/gridnick = \"$HIPPOGRID\"/g" Robust.ini

    echo "Konfiguration abgeschlossen. Die Datei Robust.ini wurde aktualisiert."

    # todo: Die konfiguration der OpenSim.ini fehlt hier.

    # Beenden des Skripts
    cd "$HOME_PATH" || exit    
    exit
}

function configuration_closedgrid() {
    cd "$Robust" || exit
    # Auswahl: Offenes Grid -> Robust.ini.example in Robust.ini kopieren
    cp Robust.ini.example Robust.ini

    # Benutzer nach der IP-Adresse fragen (Standard: 127.0.0.1)
    read -rp "Welche IP-Adresse wollen Sie nutzen? (Standard: 127.0.0.1) " IPadress
    IPadress=${IPadress:-127.0.0.1}
    
    # Benutzer nach den notwendigen Daten fragen
    read -rp "Datenbankname (Standard: opensim): " DATABASE
    DATABASE=${DATABASE:-opensim}

    read -rp "Datenbankbenutzername (Standard: opensim): " USERNAME
    USERNAME=${USERNAME:-opensim}

    read -rp "Datenbankpasswort: " PASSWORD
    PASSWORD=${PASSWORD:-""} # Falls leer, bleibt es leer

    read -rp "Standardregion (Standard: DefaultRegion): " DEFAULTREGION
    DEFAULTREGION=${DEFAULTREGION:-DefaultRegion}

    read -rp "Gridname (Standard: the lost continent of hippo): " GRIDNAME
    GRIDNAME=${GRIDNAME:-"the lost continent of hippo"}

    read -rp "Grid-Kürzel (Standard: hippogrid): " HIPPOGRID
    HIPPOGRID=${HIPPOGRID:-hippogrid}

    # Robust.ini mit den eingegebenen Werten konfigurieren
    sed -i "s/BaseHostname = \"127.0.0.1\"/BaseHostname = \"$IPadress\"/g" Robust.ini
    sed -i "s/ConnectionString = \"Data Source=localhost;Database=opensim;User ID=opensim;Password=*****;Old Guids=true;SslMode=None;\"/ConnectionString = \"Data Source=localhost;Database=$DATABASE;User ID=$USERNAME;Password=$PASSWORD;Old Guids=true;SslMode=None;\"/g" Robust.ini
    sed -i "s@; Region_Welcome_Area = \"DefaultRegion, DefaultHGRegion\"@Region_$DEFAULTREGION = \"DefaultRegion, DefaultHGRegion\"@g" Robust.ini
    sed -i "s/gridname = \"the lost continent of hippo\"/gridname = \"$GRIDNAME\"/g" Robust.ini
    sed -i "s/gridnick = \"hippogrid\"/gridnick = \"$HIPPOGRID\"/g" Robust.ini

    echo "Konfiguration abgeschlossen. Die Datei Robust.ini wurde aktualisiert."

    # todo: Die konfiguration der OpenSim.ini fehlt hier.

    # Beenden des Skripts
    cd "$HOME_PATH" || exit    
    exit
}

function configuration_openmoneygrid() {
    cd "$Robust" || exit
    # Auswahl: Offenes Grid -> Robust.HG.ini.example in Robust.ini kopieren
    cp Robust.HG.ini.example Robust.ini

    # Benutzer nach der IP-Adresse fragen (Standard: 127.0.0.1)
    read -rp "Welche IP-Adresse wollen Sie nutzen? (Standard: 127.0.0.1) " IPadress
    IPadress=${IPadress:-127.0.0.1}

    # Benutzer nach den notwendigen Daten fragen
    read -rp "Datenbankname (Standard: opensim): " DATABASE
    DATABASE=${DATABASE:-opensim}

    read -rp "Datenbankbenutzername (Standard: opensim): " USERNAME
    USERNAME=${USERNAME:-opensim}

    read -rp "Datenbankpasswort: " PASSWORD
    PASSWORD=${PASSWORD:-""} # Falls leer, bleibt es leer

    read -rp "Standardregion (Standard: DefaultRegion): " DEFAULTREGION
    DEFAULTREGION=${DEFAULTREGION:-DefaultRegion}

    read -rp "Gridname (Standard: the lost continent of hippo): " GRIDNAME
    GRIDNAME=${GRIDNAME:-"the lost continent of hippo"}

    read -rp "Grid-Kürzel (Standard: hippogrid): " HIPPOGRID
    HIPPOGRID=${HIPPOGRID:-hippogrid}

    # Robust.ini mit den eingegebenen Werten konfigurieren
    sed -i "s/BaseHostname = \"127.0.0.1\"/BaseHostname = \"$IPadress\"/g" Robust.ini
    sed -i "s@; HomeURI = \"\${Const|BaseURL}:\${Const|PublicPort}\"@HomeURI = \"\${Const|BaseURL}:\${Const|PublicPort}\"@g" Robust.ini
    sed -i "s@; GatekeeperURI = \"\${Const|BaseURL}:\${Const|PublicPort}\"@GatekeeperURI = \"\${Const|BaseURL}:\${Const|PublicPort}\"@g" Robust.ini
    sed -i "s/ConnectionString = \"Data Source=localhost;Database=opensim;User ID=opensim;Password=*****;Old Guids=true;SslMode=None;\"/ConnectionString = \"Data Source=localhost;Database=$DATABASE;User ID=$USERNAME;Password=$PASSWORD;Old Guids=true;SslMode=None;\"/g" Robust.ini
    sed -i "s@; Region_Welcome_Area = \"DefaultRegion, DefaultHGRegion\"@Region_$DEFAULTREGION = \"DefaultRegion, DefaultHGRegion\"@g" Robust.ini
    sed -i "s/gridname = \"the lost continent of hippo\"/gridname = \"$GRIDNAME\"/g" Robust.ini
    sed -i "s/gridnick = \"hippogrid\"/gridnick = \"$HIPPOGRID\"/g" Robust.ini

    echo "Konfiguration abgeschlossen. Die Datei Robust.ini wurde aktualisiert."

    # todo: Die konfiguration der OpenSim.ini fehlt hier.

    # Beenden des Skripts
    cd "$HOME_PATH" || exit    
    exit
}

function configuration_closedmoneygrid() {
    cd "$Robust" || exit
    # Auswahl: Offenes Grid -> Robust.ini.example in Robust.ini kopieren
    cp Robust.ini.example Robust.ini

    # Benutzer nach der IP-Adresse fragen (Standard: 127.0.0.1)
    read -rp "Welche IP-Adresse wollen Sie nutzen? (Standard: 127.0.0.1) " IPadress
    IPadress=${IPadress:-127.0.0.1}

    # Auswahl: geschlossenes Grid mit MoneyServer
    # Robust.ini.example und MoneyServer.ini.example ändern und die Robust.ini.example in Robust.ini sowie MoneyServer.ini.example in MoneyServer.ini kopieren
    cp Robust.ini.example Robust.ini
    cp MoneyServer.ini.example MoneyServer.ini

    # Benutzer nach den notwendigen Daten fragen
    read -rp "Datenbankname (Standard: opensim): " DATABASE
    DATABASE=${DATABASE:-opensim}

    read -rp "Datenbankbenutzername (Standard: opensim): " USERNAME
    USERNAME=${USERNAME:-opensim}

    read -rp "Datenbankpasswort: " PASSWORD
    PASSWORD=${PASSWORD:-""} # Falls leer, bleibt es leer

    read -rp "Standardregion (Standard: DefaultRegion): " DEFAULTREGION
    DEFAULTREGION=${DEFAULTREGION:-DefaultRegion}

    read -rp "Gridname (Standard: the lost continent of hippo): " GRIDNAME
    GRIDNAME=${GRIDNAME:-"the lost continent of hippo"}

    read -rp "Grid-Kürzel (Standard: hippogrid): " HIPPOGRID
    HIPPOGRID=${HIPPOGRID:-hippogrid}

    # Robust.ini mit den eingegebenen Werten konfigurieren
    sed -i "s/BaseHostname = \"127.0.0.1\"/BaseHostname = \"$IPadress\"/g" Robust.ini
    sed -i "s/ConnectionString = \"Data Source=localhost;Database=opensim;User ID=opensim;Password=*****;Old Guids=true;SslMode=None;\"/ConnectionString = \"Data Source=localhost;Database=$DATABASE;User ID=$USERNAME;Password=$PASSWORD;Old Guids=true;SslMode=None;\"/g" Robust.ini
    sed -i "s@; Region_Welcome_Area = \"DefaultRegion, DefaultHGRegion\"@Region_$DEFAULTREGION = \"DefaultRegion, DefaultHGRegion\"@g" Robust.ini
    sed -i "s/gridname = \"the lost continent of hippo\"/gridname = \"$GRIDNAME\"/g" Robust.ini
    sed -i "s/gridnick = \"hippogrid\"/gridnick = \"$HIPPOGRID\"/g" Robust.ini

    # MoneyServer.ini mit den eingegebenen Werten konfigurieren
    sed -i "s/BaseHostname = \"127.0.0.1\"/BaseHostname = \"$IPadress\"/g" MoneyServer.ini
    sed -i "s/ConnectionString = \"Data Source=localhost;Database=opensim;User ID=opensim;Password=*****;Old Guids=true;SslMode=None;\"/ConnectionString = \"Data Source=localhost;Database=$DATABASE;User ID=$USERNAME;Password=$PASSWORD;Old Guids=true;SslMode=None;\"/g" MoneyServer.ini

    echo "Konfiguration abgeschlossen. Die Dateien Robust.ini und MoneyServer.ini wurden aktualisiert."

    # todo: Die konfiguration der OpenSim.ini fehlt hier.

    # Beenden des Skripts
    cd "$HOME_PATH" || exit    
    exit
}
# endregion

# Simulatoren konfigurieren.
# region Simulatoren
function architectur() {

    ARCHITECTURE=$1
    SIMULATOR=$2
    CONFIG_FILE="$SIMULATOR/OpenSim.ini"

    case $ARCHITECTURE in
        Standalone)
            sed -i "s/^Include-Architecture = \"config-include\/Standalone.ini\"/Include-Architecture = \"config-include\/Standalone.ini\"/g" "$CONFIG_FILE"
            sed -i "s/^Include-Architecture = \"config-include\/StandaloneHypergrid.ini\"/; Include-Architecture = \"config-include\/StandaloneHypergrid.ini\"/g" "$CONFIG_FILE"
            sed -i "s/^Include-Architecture = \"config-include\/Grid.ini\"/; Include-Architecture = \"config-include\/Grid.ini\"/g" "$CONFIG_FILE"
            sed -i "s/^Include-Architecture = \"config-include\/GridHypergrid.ini\"/; Include-Architecture = \"config-include\/GridHypergrid.ini\"/g" "$CONFIG_FILE"
            ;;
        StandaloneHypergrid)
            sed -i "s/^Include-Architecture = \"config-include\/Standalone.ini\"/; Include-Architecture = \"config-include\/Standalone.ini\"/g" "$CONFIG_FILE"
            sed -i "s/^Include-Architecture = \"config-include\/StandaloneHypergrid.ini\"/Include-Architecture = \"config-include\/StandaloneHypergrid.ini\"/g" "$CONFIG_FILE"
            sed -i "s/^Include-Architecture = \"config-include\/Grid.ini\"/; Include-Architecture = \"config-include\/Grid.ini\"/g" "$CONFIG_FILE"
            sed -i "s/^Include-Architecture = \"config-include\/GridHypergrid.ini\"/; Include-Architecture = \"config-include\/GridHypergrid.ini\"/g" "$CONFIG_FILE"
            ;;
        Grid)
            sed -i "s/^Include-Architecture = \"config-include\/Standalone.ini\"/; Include-Architecture = \"config-include\/Standalone.ini\"/g" "$CONFIG_FILE"
            sed -i "s/^Include-Architecture = \"config-include\/StandaloneHypergrid.ini\"/; Include-Architecture = \"config-include\/StandaloneHypergrid.ini\"/g" "$CONFIG_FILE"
            sed -i "s/^Include-Architecture = \"config-include\/Grid.ini\"/Include-Architecture = \"config-include\/Grid.ini\"/g" "$CONFIG_FILE"
            sed -i "s/^Include-Architecture = \"config-include\/GridHypergrid.ini\"/; Include-Architecture = \"config-include\/GridHypergrid.ini\"/g" "$CONFIG_FILE"
            ;;
        GridHypergrid)
            sed -i "s/^Include-Architecture = \"config-include\/Standalone.ini\"/; Include-Architecture = \"config-include\/Standalone.ini\"/g" "$CONFIG_FILE"
            sed -i "s/^Include-Architecture = \"config-include\/StandaloneHypergrid.ini\"/; Include-Architecture = \"config-include\/StandaloneHypergrid.ini\"/g" "$CONFIG_FILE"
            sed -i "s/^Include-Architecture = \"config-include\/Grid.ini\"/; Include-Architecture = \"config-include\/Grid.ini\"/g" "$CONFIG_FILE"
            sed -i "s/^Include-Architecture = \"config-include\/GridHypergrid.ini\"/Include-Architecture = \"config-include\/GridHypergrid.ini\"/g" $"$CONFIG_FILE"
            ;;
        *)
            echo "Ungültige Architektur: $ARCHITECTURE"
            exit 1
            ;;
    esac
}

function configuration_simulatoropen() {

    # Benutzer nach der IP-Adresse fragen (Standard: 127.0.0.1)
    read -rp "Welche IP-Adresse wollen Sie nutzen? (Standard: 127.0.0.1) " IPadress
    IPadress=${IPadress:-127.0.0.1}

    # Prüfen, ob die Konfigurationsdatei existiert
    if [ ! -f "$CONFIG_FILE" ]; then
        echo "Fehler: Konfigurationsdatei $CONFIG_FILE existiert nicht!"
        exit 1
    fi

    # Simulatoren aus der Konfigurationsdatei auslesen
    while IFS="=" read -r key value; do
        case "$key" in
            Simulator*)
                sim_path=$(echo "$value" | tr -d '"')

                # Prüfen, ob der Simulator-Ordner existiert
                if [ -d "$sim_path" ]; then
                    echo "Konfiguriere $key unter $sim_path ..."

                    # Prüfen, ob OpenSim.ini.example existiert
                    if [ -f "$sim_path/OpenSim.ini.example" ]; then
                        cp "$sim_path/OpenSim.ini.example" "$sim_path/OpenSim.ini"
                    else
                        echo "Warnung: $sim_path/OpenSim.ini.example nicht gefunden!"
                    fi

                    # Weitere Konfigurationsdateien kopieren
                    for cfg in osslEnable.ini FlotsamCache.ini StandaloneCommon.ini GridCommon.ini; do
                        if [ -f "$sim_path/config-include/${cfg}.example" ]; then
                            cp "$sim_path/config-include/${cfg}.example" "$sim_path/config-include/$cfg"
                        fi
                    done

                    # BaseHostname anpassen
                    sed -i "s/BaseHostname = \"127.0.0.1\"/BaseHostname = \"$IPadress\"/g" "$sim_path/OpenSim.ini"

                    # Portnummer berechnen (sim1=9010, sim2=9020, ...)
                    sim_number="${key//Simulator/}"
                    port=$((9000 + sim_number * 10))
                    sed -i "s/PublicPort = \"9000\"/PublicPort = \"$port\"/g" "$sim_path/OpenSim.ini"

                    # Physik und Meshing aktivieren
                    sed -i "s/; meshing = Meshmerizer/meshing = Meshmerizer/g" "$sim_path/OpenSim.ini"
                    sed -i "s/; physics = BulletSim/physics = BulletSim/g" "$sim_path/OpenSim.ini"
                    sed -i "s/; DefaultScriptEngine = \"YEngine\"/DefaultScriptEngine = \"YEngine\"/g" "$sim_path/OpenSim.ini"
                    sed -i "s/; InitialTerrain = \"pinhead-island\"/InitialTerrain = \"flat\"/g" "$sim_path/OpenSim.ini"

                    # Architektur setzen (Standalone, Grid, etc.)
                    architectur "Standalone" "$sim_path"

                else
                    echo "Warnung: Verzeichnis $sim_path existiert nicht!"
                fi
            ;;
        esac
    done < "$CONFIG_FILE"

    echo "Konfiguration abgeschlossen."
}

function configuration_simulatorGridopen() {
# region Grid
    # Benutzer nach der IP-Adresse fragen (Standard: 127.0.0.1)
    read -rp "Welche IP-Adresse wollen Sie nutzen? (Standard: 127.0.0.1) " IPadress
    IPadress=${IPadress:-127.0.0.1}

    # Prüfen, ob die Konfigurationsdatei existiert
    if [ ! -f "$CONFIG_FILE" ]; then
        echo "Fehler: Konfigurationsdatei $CONFIG_FILE existiert nicht!"
        exit 1
    fi

    # Simulatoren aus der Konfigurationsdatei auslesen
    while IFS="=" read -r key value; do
        case "$key" in
            Simulator*)
                sim_path=$(echo "$value" | tr -d '"')

                # Prüfen, ob der Simulator-Ordner existiert
                if [ -d "$sim_path" ]; then
                    echo "Konfiguriere $key unter $sim_path ..."

                    # Prüfen, ob OpenSim.ini.example existiert
                    if [ -f "$sim_path/OpenSim.ini.example" ]; then
                        cp "$sim_path/OpenSim.ini.example" "$sim_path/OpenSim.ini"
                    else
                        echo "Warnung: $sim_path/OpenSim.ini.example nicht gefunden!"
                    fi

                    # Weitere Konfigurationsdateien kopieren
                    for cfg in osslEnable.ini FlotsamCache.ini StandaloneCommon.ini GridCommon.ini; do
                        if [ -f "$sim_path/config-include/${cfg}.example" ]; then
                            cp "$sim_path/config-include/${cfg}.example" "$sim_path/config-include/$cfg"
                        fi
                    done

                    # BaseHostname anpassen
                    sed -i "s/BaseHostname = \"127.0.0.1\"/BaseHostname = \"$IPadress\"/g" "$sim_path/OpenSim.ini"

                    # Portnummer berechnen (sim1=9010, sim2=9020, ...)
                    sim_number="${key//Simulator/}"
                    port=$((9000 + sim_number * 10))
                    sed -i "s/PublicPort = \"9000\"/PublicPort = \"$port\"/g" "$sim_path/OpenSim.ini"

                    # Physik und Meshing aktivieren
                    sed -i "s/; meshing = Meshmerizer/meshing = Meshmerizer/g" "$sim_path/OpenSim.ini"
                    sed -i "s/; physics = BulletSim/physics = BulletSim/g" "$sim_path/OpenSim.ini"
                    sed -i "s/; DefaultScriptEngine = \"YEngine\"/DefaultScriptEngine = \"YEngine\"/g" "$sim_path/OpenSim.ini"
                    sed -i "s/; InitialTerrain = \"pinhead-island\"/InitialTerrain = \"flat\"/g" "$sim_path/OpenSim.ini"

                    # Architektur setzen (Standalone, Grid, etc.)
                    architectur "Grid" "$sim_path"

                else
                    echo "Warnung: Verzeichnis $sim_path existiert nicht!"
                fi
            ;;
        esac
    done < "$CONFIG_FILE"

    echo "Konfiguration abgeschlossen."
}

function configuration_simulatorGridHypergridopen() {
    # Benutzer nach der IP-Adresse fragen (Standard: 127.0.0.1)
    read -rp "Welche IP-Adresse wollen Sie nutzen? (Standard: 127.0.0.1) " IPadress
    IPadress=${IPadress:-127.0.0.1}

    # Prüfen, ob die Konfigurationsdatei existiert
    if [ ! -f "$CONFIG_FILE" ]; then
        echo "Fehler: Konfigurationsdatei $CONFIG_FILE existiert nicht!"
        exit 1
    fi

    # Simulatoren aus der Konfigurationsdatei auslesen
    while IFS="=" read -r key value; do
        case "$key" in
            Simulator*)
                sim_path=$(echo "$value" | tr -d '"')

                # Prüfen, ob der Simulator-Ordner existiert
                if [ -d "$sim_path" ]; then
                    echo "Konfiguriere $key unter $sim_path ..."

                    # Prüfen, ob OpenSim.ini.example existiert
                    if [ -f "$sim_path/OpenSim.ini.example" ]; then
                        cp "$sim_path/OpenSim.ini.example" "$sim_path/OpenSim.ini"
                    else
                        echo "Warnung: $sim_path/OpenSim.ini.example nicht gefunden!"
                    fi

                    # Weitere Konfigurationsdateien kopieren
                    for cfg in osslEnable.ini FlotsamCache.ini StandaloneCommon.ini GridCommon.ini; do
                        if [ -f "$sim_path/config-include/${cfg}.example" ]; then
                            cp "$sim_path/config-include/${cfg}.example" "$sim_path/config-include/$cfg"
                        fi
                    done

                    # BaseHostname anpassen
                    sed -i "s/BaseHostname = \"127.0.0.1\"/BaseHostname = \"$IPadress\"/g" "$sim_path/OpenSim.ini"

                    # Portnummer berechnen (sim1=9010, sim2=9020, ...)
                    sim_number="${key//Simulator/}"
                    port=$((9000 + sim_number * 10))
                    sed -i "s/PublicPort = \"9000\"/PublicPort = \"$port\"/g" "$sim_path/OpenSim.ini"

                    # Physik und Meshing aktivieren
                    sed -i "s/; meshing = Meshmerizer/meshing = Meshmerizer/g" "$sim_path/OpenSim.ini"
                    sed -i "s/; physics = BulletSim/physics = BulletSim/g" "$sim_path/OpenSim.ini"
                    sed -i "s/; DefaultScriptEngine = \"YEngine\"/DefaultScriptEngine = \"YEngine\"/g" "$sim_path/OpenSim.ini"
                    sed -i "s/; InitialTerrain = \"pinhead-island\"/InitialTerrain = \"flat\"/g" "$sim_path/OpenSim.ini"

                    # Architektur setzen (Standalone, Grid, etc.)
                    architectur "GridHypergrid" "$sim_path"

                else
                    echo "Warnung: Verzeichnis $sim_path existiert nicht!"
                fi
            ;;
        esac
    done < "$CONFIG_FILE"

    echo "Konfiguration abgeschlossen."
}

function configuration_simulatorclose() {
    # Benutzer nach der IP-Adresse fragen (Standard: 127.0.0.1)
    read -rp "Welche IP-Adresse wollen Sie nutzen? (Standard: 127.0.0.1) " IPadress
    IPadress=${IPadress:-127.0.0.1}

    # Prüfen, ob die Konfigurationsdatei existiert
    if [ ! -f "$CONFIG_FILE" ]; then
        echo "Fehler: Konfigurationsdatei $CONFIG_FILE existiert nicht!"
        exit 1
    fi

    # Simulatoren aus der Konfigurationsdatei auslesen
    while IFS="=" read -r key value; do
        case "$key" in
            Simulator*)
                sim_path=$(echo "$value" | tr -d '"')

                # Prüfen, ob der Simulator-Ordner existiert
                if [ -d "$sim_path" ]; then
                    echo "Konfiguriere $key unter $sim_path ..."

                    # Prüfen, ob OpenSim.ini.example existiert
                    if [ -f "$sim_path/OpenSim.ini.example" ]; then
                        cp "$sim_path/OpenSim.ini.example" "$sim_path/OpenSim.ini"
                    else
                        echo "Warnung: $sim_path/OpenSim.ini.example nicht gefunden!"
                    fi

                    # Weitere Konfigurationsdateien kopieren
                    for cfg in osslEnable.ini FlotsamCache.ini StandaloneCommon.ini GridCommon.ini; do
                        if [ -f "$sim_path/config-include/${cfg}.example" ]; then
                            cp "$sim_path/config-include/${cfg}.example" "$sim_path/config-include/$cfg"
                        fi
                    done

                    # BaseHostname anpassen
                    sed -i "s/BaseHostname = \"127.0.0.1\"/BaseHostname = \"$IPadress\"/g" "$sim_path/OpenSim.ini"

                    # Portnummer berechnen (sim1=9010, sim2=9020, ...)
                    sim_number="${key//Simulator/}"
                    port=$((9000 + sim_number * 10))
                    sed -i "s/PublicPort = \"9000\"/PublicPort = \"$port\"/g" "$sim_path/OpenSim.ini"

                    # Physik und Meshing aktivieren
                    sed -i "s/; meshing = Meshmerizer/meshing = Meshmerizer/g" "$sim_path/OpenSim.ini"
                    sed -i "s/; physics = BulletSim/physics = BulletSim/g" "$sim_path/OpenSim.ini"
                    sed -i "s/; DefaultScriptEngine = \"YEngine\"/DefaultScriptEngine = \"YEngine\"/g" "$sim_path/OpenSim.ini"
                    sed -i "s/; InitialTerrain = \"pinhead-island\"/InitialTerrain = \"flat\"/g" "$sim_path/OpenSim.ini"

                    # Architektur setzen (Standalone, Grid, etc.)
                    architectur "Standalone" "$sim_path"

                else
                    echo "Warnung: Verzeichnis $sim_path existiert nicht!"
                fi
            ;;
        esac
    done < "$CONFIG_FILE"

    echo "Konfiguration abgeschlossen."
}

function configuration_simulatorGridclose() {
    # Benutzer nach der IP-Adresse fragen (Standard: 127.0.0.1)
    read -rp "Welche IP-Adresse wollen Sie nutzen? (Standard: 127.0.0.1) " IPadress
    IPadress=${IPadress:-127.0.0.1}

    # Prüfen, ob die Konfigurationsdatei existiert
    if [ ! -f "$CONFIG_FILE" ]; then
        echo "Fehler: Konfigurationsdatei $CONFIG_FILE existiert nicht!"
        exit 1
    fi

    # Simulatoren aus der Konfigurationsdatei auslesen
    while IFS="=" read -r key value; do
        case "$key" in
            Simulator*)
                sim_path=$(echo "$value" | tr -d '"')

                # Prüfen, ob der Simulator-Ordner existiert
                if [ -d "$sim_path" ]; then
                    echo "Konfiguriere $key unter $sim_path ..."

                    # Prüfen, ob OpenSim.ini.example existiert
                    if [ -f "$sim_path/OpenSim.ini.example" ]; then
                        cp "$sim_path/OpenSim.ini.example" "$sim_path/OpenSim.ini"
                    else
                        echo "Warnung: $sim_path/OpenSim.ini.example nicht gefunden!"
                    fi

                    # Weitere Konfigurationsdateien kopieren
                    for cfg in osslEnable.ini FlotsamCache.ini StandaloneCommon.ini GridCommon.ini; do
                        if [ -f "$sim_path/config-include/${cfg}.example" ]; then
                            cp "$sim_path/config-include/${cfg}.example" "$sim_path/config-include/$cfg"
                        fi
                    done

                    # BaseHostname anpassen
                    sed -i "s/BaseHostname = \"127.0.0.1\"/BaseHostname = \"$IPadress\"/g" "$sim_path/OpenSim.ini"

                    # Portnummer berechnen (sim1=9010, sim2=9020, ...)
                    sim_number="${key//Simulator/}"
                    port=$((9000 + sim_number * 10))
                    sed -i "s/PublicPort = \"9000\"/PublicPort = \"$port\"/g" "$sim_path/OpenSim.ini"

                    # Physik und Meshing aktivieren
                    sed -i "s/; meshing = Meshmerizer/meshing = Meshmerizer/g" "$sim_path/OpenSim.ini"
                    sed -i "s/; physics = BulletSim/physics = BulletSim/g" "$sim_path/OpenSim.ini"
                    sed -i "s/; DefaultScriptEngine = \"YEngine\"/DefaultScriptEngine = \"YEngine\"/g" "$sim_path/OpenSim.ini"
                    sed -i "s/; InitialTerrain = \"pinhead-island\"/InitialTerrain = \"flat\"/g" "$sim_path/OpenSim.ini"

                    # Architektur setzen (Standalone, Grid, etc.)
                    architectur "Grid" "$sim_path"

                else
                    echo "Warnung: Verzeichnis $sim_path existiert nicht!"
                fi
            ;;
        esac
    done < "$CONFIG_FILE"

    echo "Konfiguration abgeschlossen."
}

function configuration_simulatorGridHypergridclose() {
    # Benutzer nach der IP-Adresse fragen (Standard: 127.0.0.1)
    read -rp "Welche IP-Adresse wollen Sie nutzen? (Standard: 127.0.0.1) " IPadress
    IPadress=${IPadress:-127.0.0.1}

    # Prüfen, ob die Konfigurationsdatei existiert
    if [ ! -f "$CONFIG_FILE" ]; then
        echo "Fehler: Konfigurationsdatei $CONFIG_FILE existiert nicht!"
        exit 1
    fi

    # Simulatoren aus der Konfigurationsdatei auslesen
    while IFS="=" read -r key value; do
        case "$key" in
            Simulator*)
                sim_path=$(echo "$value" | tr -d '"')

                # Prüfen, ob der Simulator-Ordner existiert
                if [ -d "$sim_path" ]; then
                    echo "Konfiguriere $key unter $sim_path ..."

                    # Prüfen, ob OpenSim.ini.example existiert
                    if [ -f "$sim_path/OpenSim.ini.example" ]; then
                        cp "$sim_path/OpenSim.ini.example" "$sim_path/OpenSim.ini"
                    else
                        echo "Warnung: $sim_path/OpenSim.ini.example nicht gefunden!"
                    fi

                    # Weitere Konfigurationsdateien kopieren
                    for cfg in osslEnable.ini FlotsamCache.ini StandaloneCommon.ini GridCommon.ini; do
                        if [ -f "$sim_path/config-include/${cfg}.example" ]; then
                            cp "$sim_path/config-include/${cfg}.example" "$sim_path/config-include/$cfg"
                        fi
                    done

                    # BaseHostname anpassen
                    sed -i "s/BaseHostname = \"127.0.0.1\"/BaseHostname = \"$IPadress\"/g" "$sim_path/OpenSim.ini"

                    # Portnummer berechnen (sim1=9010, sim2=9020, ...)
                    sim_number="${key//Simulator/}"
                    port=$((9000 + sim_number * 10))
                    sed -i "s/PublicPort = \"9000\"/PublicPort = \"$port\"/g" "$sim_path/OpenSim.ini"

                    # Physik und Meshing aktivieren
                    sed -i "s/; meshing = Meshmerizer/meshing = Meshmerizer/g" "$sim_path/OpenSim.ini"
                    sed -i "s/; physics = BulletSim/physics = BulletSim/g" "$sim_path/OpenSim.ini"
                    sed -i "s/; DefaultScriptEngine = \"YEngine\"/DefaultScriptEngine = \"YEngine\"/g" "$sim_path/OpenSim.ini"
                    sed -i "s/; InitialTerrain = \"pinhead-island\"/InitialTerrain = \"flat\"/g" "$sim_path/OpenSim.ini"

                    # Architektur setzen (Standalone, Grid, etc.)
                    architectur "GridHypergrid" "$sim_path"

                else
                    echo "Warnung: Verzeichnis $sim_path existiert nicht!"
                fi
            ;;
        esac
    done < "$CONFIG_FILE"

    echo "Konfiguration abgeschlossen."
}
# endregion
function config_rename() {
    # Copy all files with the name *.ini.example to *.ini
    for file in *.ini.example; do
        if [ -f "$file" ]; then
            cp "$file" "${file%.example}"
            echo "Copied $file to ${file%.example}"
        fi
    done
}
# endregion

# bash osminstaller.sh osmmconfig
# bash osminstaller.sh server_install
# bash osminstaller.sh config_rename
# bash osminstaller.sh osconfiginstall
# bash osminstaller.sh del_opensim

case $KOMMANDO in
    osconfiginstall) osconfiginstall ;;
    osmmcopy) osmmcopy ;;
    osmmconfig) osmmconfig ;;
    del_opensim) del_opensim ;;
    warnings) warnings ;;
    server_install) server_install ;;
    uninstall_mysql) uninstall_mysql ;;
    config_rename) config_rename ;;
    configuration_opengrid) configuration_opengrid ;;
    configuration_closedgrid) configuration_closedgrid ;;
    configuration_openmoneygrid) configuration_openmoneygrid ;;
    configuration_closedmoneygrid) configuration_closedmoneygrid ;;
    configuration_simulatoropen) configuration_simulatoropen ;;
    configuration_simulatorclose) configuration_simulatorclose ;;
    *) help ;;
esac
