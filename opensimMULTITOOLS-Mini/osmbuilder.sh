#!/bin/bash
# opensimMULTITOOLS-Builder 0.03
echo "opensimMULTITOOLS-Builder 0.03"

HOME_PATH=$(pwd)
echo Pfad: "$HOME_PATH" # Debug
KOMMANDO=$1

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

function clone_opensim_develope() {
    # Fresh OpenSim version
    if [ ! -d "opensim" ]; then
        git clone https://github.com/opensim/opensim.git opensim
    fi
    return 0
}

function clone_opensim_stable_source() {
    # Stable OpenSim version  
    wget http://opensimulator.org/dist/opensim-0.9.3.0-source.zip 
    unzip opensim-0.9.3.0-source.zip
    mv opensim-0.9.3.0-source opensim
    rm opensim-0.9.3.0-source.zip
    return 0
}
function clone_opensim_stable_binary() {
    # Stable OpenSim version
    wget http://opensimulator.org/dist/opensim-0.9.3.0.zip
    unzip opensim-0.9.3.0.zip
    mv opensim-0.9.3.0 opensim
    rm opensim-0.9.3.0.zip
    return 0
}

function clone_moneyserver() {
    if [ -d "opensimcurrencyserver" ]; then
        echo "Directory 'opensimcurrencyserver' already exists."
        cp -r "$HOME_PATH"/opensimcurrencyserver/bin "$HOME_PATH"/opensim/bin
	    cp -r "$HOME_PATH"/opensimcurrencyserver/addon-modules "$HOME_PATH"/opensim/addon-modules
        exit 1
    fi
	
    git clone https://github.com/ManfredAabye/opensimcurrencyserver-dotnet.git opensimcurrencyserver

    cp -r "$HOME_PATH"/opensimcurrencyserver/bin "$HOME_PATH"/opensim
	cp -r "$HOME_PATH"/opensimcurrencyserver/addon-modules "$HOME_PATH"/opensim

	return 0
}

function clone_webRTC_janus() {
    if [ ! -d "os-webrtc-janus" ]; then
        echo "Repository 'os-webrtc-janus' wird heruntergeladen..."
        git https://github.com/Misterblue/os-webrtc-janus.git os-webrtc-janus
    else
        echo "Das Repository 'os-webrtc-janus' ist bereits vorhanden."
    fi

	cp -r "$HOME_PATH"/os-webrtc-janus/ "$HOME_PATH"/opensim/addon-modules/os-webrtc-janus
    cp -r "$HOME_PATH"/os-webrtc-janus/WebRTC-Sandbox/OpenSim "$HOME_PATH"/opensim/OpenSim
    cp -r "$HOME_PATH"/os-webrtc-janus/WebRTC-Sandbox/bin "$HOME_PATH"/opensim/bin

    return 0
}

function clone_examplescripts() {
    if [ -d "opensim-ossl-example-scripts" ]; then
        echo "Directory 'opensim-ossl-example-scripts' already exists."
        cp -r "$HOME_PATH"/opensim-ossl-example-scripts/ScriptsAssetSet "$HOME_PATH"/opensim/bin/assets
	    cp -r "$HOME_PATH"/opensim-ossl-example-scripts/inventory "$HOME_PATH"/opensim/bin
        cp -r "$HOME_PATH"/opensim-ossl-example-scripts/inventory/ScriptsLibrary "$HOME_PATH"/opensim/bin/inventory/SettingsLibrary
        exit 1
    fi

	git clone https://github.com/ManfredAabye/opensim-ossl-example-scripts.git opensim-ossl-example-scripts

    cp -r "$HOME_PATH"/opensim-ossl-example-scripts/assets "$HOME_PATH"/opensim/bin/assets
	cp -r "$HOME_PATH"/opensim-ossl-example-scripts/inventory "$HOME_PATH"/opensim/bin/inventory

    return 0
}

function clone_assets() {
    # Bento Assets
    cd "$HOME_PATH"/opensim/bin/Library || exit
    wget https://github.com/ManfredAabye/Roth2/blob/master/Artifacts/IAR/Roth2-v1.iar
    wget https://github.com/ManfredAabye/Roth2/blob/master/Artifacts/IAR/Roth2-v2.iar
    wget https://github.com/ManfredAabye/Ruth2/blob/master/Artifacts/IAR/Ruth2-v3.iar
    wget https://github.com/ManfredAabye/Ruth2/blob/master/Artifacts/IAR/Ruth2-v4.iar
    cd "$HOME_PATH" || exit
    return 0
}

function prebuild_opensim() {
    cd "$HOME_PATH"/opensim || exit
    cp bin/System.Drawing.Common.dll.linux bin/System.Drawing.Common.dll
    dotnet bin/prebuild.dll /target vs2022 /targetframework net8_0 /excludedir = "obj | bin" /file prebuild.xml
    cd "$HOME_PATH" || exit
    return 0
}

function build_opensim() {
    cd "$HOME_PATH"/opensim || exit
    dotnet build -c Release OpenSim.sln
    cd "$HOME_PATH" || exit
    return 0
}

function del_opensim() {
    rm -rf "$HOME_PATH"/opensim   

    exit
}

function del_all() {
    read -rp "Warning: All files and folders will be deleted! Do you want to continue? (y/n)" warning

    if [ "$warning" != "y" ]; then
        exit
    fi
    rm -rf "$HOME_PATH"/opensim
    rm -rf "$HOME_PATH"/opensimcurrencyserver
    rm -rf "$HOME_PATH"/opensim-ossl-example-scripts
    rm -rf "$HOME_PATH"/robust

    for i in {1..99}; do
         rm -rf "$HOME_PATH"/sim"${i}" 2>/dev/null
    done

    exit
}

function autobuild_develope() {
    clone_opensim_develope
    clone_moneyserver
    clone_assets
    clone_examplescripts
    clone_webRTC_janus

    prebuild_opensim
    build_opensim

    exit
}

function autobuild_stable_source() {
    clone_opensim_stable_source
    clone_moneyserver
    clone_assets
    clone_examplescripts

    prebuild_opensim
    build_opensim

    exit
}

function autobuild_stable_binary() {
    clone_opensim_stable_binary
    clone_assets
    clone_examplescripts
    exit
}

function help() {
    echo "opensimMULTITOOLS-Builder 0.01"
    echo "Usage: $0 
        autobuild_develope
        autobuild_stable_binary
        autobuild_stable_source
        build_opensim
        clone_assets
        clone_examplescripts
        clone_moneyserver
        clone_opensim_develope
        clone_opensim_stable
        del_all
        del_opensim
        prebuild_opensim
        warnings"
    exit
}

# bash osmbuilder.sh autobuild
# bash osmbuilder.sh del_opensim

case $KOMMANDO in
    autobuild_develope) autobuild_develope ;;
    autobuild_stable_binary) autobuild_stable_binary ;;
    autobuild_stable_source) autobuild_stable_source ;;
    build_opensim) build_opensim ;;
    clone_assets) clone_assets ;;
    clone_examplescripts) clone_examplescripts ;;
    clone_moneyserver) clone_moneyserver ;;
    clone_opensim_develope) clone_opensim_develope ;;
    clone_opensim_stable) clone_opensim_stable ;;
    clone_webRTC_janus) clone_webRTC_janus ;;
    del_all) del_all ;;
    del_opensim) del_opensim ;;
    prebuild_opensim) prebuild_opensim ;;
    warnings) warnings ;;
    *) help ;;
esac

# Test: Erstelle eine stabile binary-opensim Version die direkt startbar ist.
# Test: Erstelle eine stabile stable-opensim Version die direkt startbar ist.
# Test: Erstelle ein Grid mit einer Region.
# Test: Erstelle ein HyperGrid mit einer Region.
# Test: Erstelle ein Standalone OpenSimulator mit einer Region.
# Test: Erstelle ein Standalone OpenSimulator mit einer Region und Geld.
