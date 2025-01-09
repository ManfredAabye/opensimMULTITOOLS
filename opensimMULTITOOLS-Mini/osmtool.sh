#!/bin/bash

# opensimMULTITOOLS-Mini 0.02

HOME_PATH=$(pwd)
CONFIG_FILE_NAME="Gridconfig.cfg"
CONFIG_FILE="$HOME_PATH/$CONFIG_FILE_NAME"
LOGDEL=true

function osmmconfig() {
    # Benutzer nach dem Pfad für Robust fragen
    echo "Geben Sie den Pfad für Robust ein [Standard: $HOME_PATH/robust/bin]: " 
    read -r ROBUST_PATH
    ROBUST_PATH=${ROBUST_PATH:-$HOME_PATH/robust/bin}
    
    # Benutzer nach dem Pfad für MoneyServer fragen
    echo "Geben Sie den Pfad für MoneyServer ein [Standard: $HOME_PATH/robust/bin]: " 
    read -r MONEY_PATH
    MONEY_PATH=${MONEY_PATH:-$HOME_PATH/robust/bin}

    # Anzahl der Simulatoren abfragen
    echo "Wie viele Simulatoren sollen konfiguriert werden? " 
    read -r SIM_COUNT
    
    # Datei erstellen oder überschreiben
    echo "Robust=""\"$ROBUST_PATH\"" > "$CONFIG_FILE"
    echo "MoneyServer=""\"$MONEY_PATH\"" >> "$CONFIG_FILE"
    
    # Simulatorenpfade hinzufügen
    for ((i=1; i<=SIM_COUNT; i++)); do
        echo "Simulator$i=\"$HOME_PATH/sim$i/bin\"" >> "$CONFIG_FILE"
    done
    
    echo "Konfiguration gespeichert in $CONFIG_FILE"
}
# Check if the configuration file exists
if [ -f "$CONFIG_FILE" ]; then
    # shellcheck disable=SC1090
    source "$CONFIG_FILE"
else    
    osmmconfig && warnings
    # shellcheck disable=SC1090
    source "$CONFIG_FILE"
fi
# Commands
KOMMANDO=$1

# Constants
filerobust="Robust.dll"
filemoneyserver="MoneyServer.dll"
fileopensim="OpenSim.dll"

function opensimconfig() {
    ulimit -s 1048576
}

function start_opensimulator() { 
    opensimconfig
    # Check and start Robust if directory and file exist
    if [ -n "$Robust" ] && [ -f "${Robust}/${filerobust}" ]; then
        if ! screen -ls | grep -q "Robust"; then
            cd "${Robust}" || echo ""
            if $LOGDEL && [ -f "$Robust"/Robust.log ]; then
                rm "$Robust"/Robust.log 2>/dev/null
            fi
            screen -fa -S Robust -d -U -m dotnet ${filerobust}
            echo "Starting Robust"
            sleep 10
            cd "$HOME_PATH" || exit
        fi
    fi
    # Check and start MoneyServer if directory and file exist
    if [ -n "$MoneyServer" ] && [ -f "${MoneyServer}/${filemoneyserver}" ]; then
        if ! screen -ls | grep -q "MoneyServer"; then
            cd "${MoneyServer}" || echo ""

            if $LOGDEL && [ -f "$MoneyServer"/MoneyServer.log ]; then
                rm "$MoneyServer"/MoneyServer.log 2>/dev/null
            fi
            screen -fa -S MoneyServer -d -U -m dotnet "${MoneyServer}/${filemoneyserver}"
            echo "Starting MoneyServer"
            sleep 10
            cd "$HOME_PATH" || exit
        fi
    fi
    # Check and start Simulators if directories and files exist
    for i in {1..99}; do
        sim_var="Simulator${i}"
        sim_path="${!sim_var}"

        if [ -n "$sim_path" ] && [ -f "${sim_path}/${fileopensim}" ]; then
            if ! screen -ls | grep -q "Simulator${i}"; then
                cd "${sim_path}" || echo ""

                if $LOGDEL && [ -f "$sim_path"/OpenSim.log ]; then
                    rm "$sim_path"/OpenSim.log 2>/dev/null
                fi
                screen -fa -S "Simulator${i}" -d -U -m dotnet "${sim_path}/${fileopensim}"
                echo "Starting Simulator${i}"                
                sleep 5
                cd "$HOME_PATH" || exit
            fi
        fi
    done
}

function stop_opensimulator() {
    # Shutdown Simulators from 9 to 1
    for ((i=9; i>=1; i--)); do
        sim_var="Simulator${i}"
        if screen -ls | grep -q "Simulator${i}"; then
            echo "Stopping Simulator${i}"
            screen -S "Simulator${i}" -p 0 -X eval "stuff 'shutdown'^M"
            sleep 5
        fi
    done
    # Shutdown MoneyServer
    if screen -ls | grep -q "MoneyServer"; then
        echo "Stopping MoneyServer"
        screen -S "MoneyServer" -p 0 -X eval "stuff 'shutdown'^M"
        sleep 5
    fi
    # Shutdown Robust
    if screen -ls | grep -q "Robust"; then
        echo "Stopping Robust"
        screen -S Robust -p 0 -X eval "stuff 'shutdown'^M"
        sleep 5
    fi
}

function ifrunning()
{
    # Check and start Robust if directory and file exist
    if [ -n "$Robust" ] && [ -f "${Robust}/${filerobust}" ]; then
        if ! screen -ls | grep -q "Robust"; then
            cd "${Robust}" || echo ""
            if $LOGDEL && [ -f "$Robust"/Robust.log ]; then
            rm "$Robust"/Robust.log 2>/dev/null
            fi
            screen -fa -S Robust -d -U -m dotnet ${filerobust}
            echo "Starting Robust"
            sleep 10
            cd "$HOME_PATH" || exit
        fi
    fi
    
    # Check and start MoneyServer if directory and file exist
    if [ -n "$MoneyServer" ] && [ -f "${MoneyServer}/${filemoneyserver}" ]; then
        if ! screen -ls | grep -q "MoneyServer"; then
            cd "${MoneyServer}" || echo ""
            if $LOGDEL && [ -f "$MoneyServer"/MoneyServer.log ]; then
            rm "$MoneyServer"/MoneyServer.log 2>/dev/null
            fi
            screen -fa -S MoneyServer -d -U -m dotnet "${MoneyServer}/${filemoneyserver}"
            echo "Starting MoneyServer"
            sleep 10
            cd "$HOME_PATH" || exit
        fi
    fi

    # Check and start Simulators 1..9 if directories and files exist
    for i in {1..99}; do
        sim_var="Simulator${i}"
        sim_path="${!sim_var}"
        if [ -n "$sim_path" ] && [ -f "${sim_path}/${fileopensim}" ]; then
            if ! screen -ls | grep -q "Simulator${i}"; then
                cd "${sim_path}" || echo ""
                if $LOGDEL && [ -f "$sim_path"/OpenSim.log ]; then
                rm "$sim_path"/OpenSim.log 2>/dev/null
                fi
                screen -fa -S "Simulator${i}" -d -U -m dotnet "${sim_path}/${fileopensim}"
                echo "Starting Simulator${i}"                
                sleep 5
                cd "$HOME_PATH" || exit
            fi
        fi
    done
}

function cachedel() {
    # todo: cache delete
    if [ -d "$Robust"/assetcache ]; then
        rm -r "$Robust"/assetcache 2>/dev/null
    fi

    # todo: cache delete
    for i in {1..99}; do
        sim_var="Simulator${i}"
        sim_path="${!sim_var}"
        if [ -n "$sim_path" ] && [ -f "${sim_path}/${fileopensim}" ]; then
            if ! screen -ls | grep -q "Simulator${i}"; then
                cd "${sim_path}" || echo ""
                # todo: cache delete
                rm -r "$sim_path"/assetcache 2>/dev/null
                cd "$HOME_PATH" || exit
            fi
        fi
    done
}

function logdel() {
    # todo: log delete bin/*.log
    if [ -d "$Robust" ]; then
        rm "$Robust"/Robust.log 2>/dev/null
    fi

    if [ -d "$MoneyServer" ]; then
        rm "$MoneyServer"/MoneyServer.log 2>/dev/null
    fi

    for i in {1..99}; do
        sim_var="Simulator${i}"
        sim_path="${!sim_var}"
        if [ -n "$sim_path" ] && [ -f "${sim_path}/${fileopensim}" ]; then
            cd "${sim_path}" || echo ""
            rm "$sim_path"/OpenSim.log 2>/dev/null
            cd "$HOME_PATH" || exit
        fi
    done
}

function help() {
    echo "opensimMULTITOOLS-Mini 0.01"
    echo "Usage: $0 start|stop|restart|cachedel|clean_restart|ifrunning"
    exit
}

case $KOMMANDO in
    start) start_opensimulator ;;
    stop) stop_opensimulator ;;
    restart) stop_opensimulator; sleep 10; echo""; start_opensimulator ;;
    cachedel) cachedel ;;
    clean_restart) stop_opensimulator; sleep 10; cachedel; start_opensimulator ;;
    ifrunning) ifrunning ;;
    logdel) logdel ;;
    help) help ;;
    *) exit ;;
esac

screen -ls
