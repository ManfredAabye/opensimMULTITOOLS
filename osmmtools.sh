#!/bin/bash

# opensimMULTITOOLS-Mini 0.01

CONFIG_FILE_PATH=$(pwd)
CONFIG_FILE_NAME="Gridconfig.cfg"
CONFIG_FILE="$CONFIG_FILE_PATH/$CONFIG_FILE_NAME"

function osmmconfig() {
    # Check if the file exists, otherwise create
    if [ ! -f "$CONFIG_FILE" ]; then
        cat <<EOL > "$CONFIG_FILE"
Robust="$CONFIG_FILE_PATH/robust/bin"
MoneyServer="$CONFIG_FILE_PATH/robust/bin"
Simulator1="$CONFIG_FILE_PATH/sim1/bin"
Simulator2="$CONFIG_FILE_PATH/sim2/bin"
Simulator3="$CONFIG_FILE_PATH/sim3/bin"
Simulator4="$CONFIG_FILE_PATH/sim4/bin"
Simulator5="$CONFIG_FILE_PATH/sim5/bin"
Simulator6="$CONFIG_FILE_PATH/sim6/bin"
Simulator7="$CONFIG_FILE_PATH/sim7/bin"
Simulator8="$CONFIG_FILE_PATH/sim8/bin"
Simulator9="$CONFIG_FILE_PATH/sim9/bin"
EOL
    fi    
}

# Check if the configuration file exists
if [ -f "$CONFIG_FILE" ]; then
    # shellcheck disable=SC1090
    source "$CONFIG_FILE"
else
    osmmconfig
    # shellcheck disable=SC1090
    source "$CONFIG_FILE"
fi

# Constants
filerobust="Robust.dll"
filemoneyserver="MoneyServer.dll"
fileopensim="OpenSim.dll"

function ifrunning()
{
    if screen -ls | grep -q "Robust"; then
        if screen -ls | grep -q "MoneyServer"; then
            if screen -ls | grep -q "Simulator"; then
                stop_opensimulator
            else
                start_opensimulator
            fi
        else
            start_opensimulator
        fi
    else
        start_opensimulator
    fi
}

KOMMANDO=$1

function start_opensimulator() {
    # Check and start Robust if directory and file exist
    if [ -n "$Robust" ] && [ -f "${Robust}/${filerobust}" ]; then
        if ! screen -ls | grep -q "Robust"; then
            cd "${Robust}" || echo ""
            screen -fa -S Robust -d -U -m dotnet ${filerobust}
            echo "Starting Robust"
            sleep 10
            cd "$CONFIG_FILE_PATH" || exit
        fi
    fi

    # Check and start MoneyServer if directory and file exist
    if [ -n "$MoneyServer" ] && [ -f "${MoneyServer}/${filemoneyserver}" ]; then
        if ! screen -ls | grep -q "MoneyServer"; then
            cd "${MoneyServer}" || echo ""
            screen -fa -S MoneyServer -d -U -m dotnet "${MoneyServer}/${filemoneyserver}"
            echo "Starting MoneyServer"
            sleep 10
            cd "$CONFIG_FILE_PATH" || exit
        fi
    fi

    # Check and start Simulators if directories and files exist
    for i in {1..9}; do
        sim_var="Simulator${i}"
        sim_path="${!sim_var}"

        if [ -n "$sim_path" ] && [ -f "${sim_path}/${fileopensim}" ]; then
            if ! screen -ls | grep -q "Simulator${i}"; then
                cd "${sim_path}" || echo ""
                screen -fa -S "Simulator${i}" -d -U -m dotnet "${sim_path}/${fileopensim}"
                echo "Starting Simulator${i}"
                sleep 5
                cd "$CONFIG_FILE_PATH" || exit
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

function check_screens() {
    # Check if the Robust folder exists and if the screen is not running, start it.
    if [ -d "${Robust}" ]; then
        screenRO=$(screen -ls | grep -w "Robust")        
        if [ -z "$screenRO" ]; then
            start_opensimulator
        fi
    fi

    # Check if the MoneyServer folder exists and if the screen is not running, start it.
    if [ -d "${MoneyServer}" ]; then
        screenMoneyServer=$(screen -ls | grep -w "MoneyServer")        
        if [ -z "$screenMoneyServer" ]; then
            start_opensimulator
        fi
    fi

    # Check if the Simulator folder exists and if the screen is not running, start it.
    for i in {1..9}; do
        sim_var="Simulator${i}"
        sim_path="${!sim_var}"

        if [ -d "${sim_path}" ]; then
            screenSim1=$(screen -ls | grep -w "Simulator${i}")            
            if [ -z "$screenSim1" ]; then
                start_opensimulator
            fi
        fi
    done
}

case $KOMMANDO in
    start) start_opensimulator ;;
    stop) stop_opensimulator ;;
    restart) stop_opensimulator; sleep 10; echo""; start_opensimulator ;;
    check_screens) check_screens ;;
    *) ifrunning ;;
esac

screen -ls
