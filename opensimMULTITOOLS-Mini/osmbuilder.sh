#!/bin/bash
# opensimMULTITOOLS-Builder 0.01

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

function clone_opensim() {
    # Fresh OpenSim version
    if [ ! -d "opensim" ]; then
        git clone https://github.com/opensim/opensim.git opensim
    fi
    return 0
}

function copy_opensim0930() {
    # Stable OpenSim version
    wget http://opensimulator.org/dist/opensim-0.9.3.0.zip
    unzip opensim-0.9.3.0.zip
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

function clone_examplescripts() {
    if [ -d "opensim-ossl-example-scripts" ]; then
        echo "Directory 'opensim-ossl-example-scripts' already exists."
        cp -r "$HOME_PATH"/opensim-ossl-example-scripts/ScriptsAssetSet "$HOME_PATH"/opensim/bin/assets/ScriptsAssetSet
        #cp -r "$HOME_PATH"/opensim-ossl-example-scripts/assets "$HOME_PATH"/opensim/bin
	    cp -r "$HOME_PATH"/opensim-ossl-example-scripts/inventory "$HOME_PATH"/opensim/bin
        cp -r "$HOME_PATH"/opensim-ossl-example-scripts/inventory/ScriptsLibrary "$HOME_PATH"/opensim/bin/inventory/SettingsLibrary
        exit 1
    fi

	git clone https://github.com/ManfredAabye/opensim-ossl-example-scripts.git opensim-ossl-example-scripts

    cp -r "$HOME_PATH"/opensim-ossl-example-scripts/assets "$HOME_PATH"/opensim/bin/assets
	cp -r "$HOME_PATH"/opensim-ossl-example-scripts/inventory "$HOME_PATH"/opensim/bin/inventory

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
    rm -rf "$HOME_PATH"/opensimcurrencyserver
    rm -rf "$HOME_PATH"/opensim-ossl-example-scripts
    exit
}

function help() {
    echo "opensimMULTITOOLS-Builder 0.01"
    echo "Usage: $0 warnings|clone_opensim|prebuild_opensim|build_opensim|copy_opensim0930|clone_moneyserver|clone_examplescripts"
    exit
}

function autobuild() {
    clone_opensim
    clone_moneyserver
    clone_examplescripts

    prebuild_opensim
    build_opensim

    exit
}

# bash osmbuilder.sh autobuild
# bash osmbuilder.sh del_opensim

case $KOMMANDO in
    autobuild) autobuild ;;
    warnings) warnings ;;
    clone_opensim) clone_opensim ;;
    copy_opensim0930) copy_opensim0930 ;;
    clone_moneyserver) clone_moneyserver ;;
    prebuild_opensim) prebuild_opensim ;;
    clone_examplescripts) clone_examplescripts ;;
    build_opensim) build_opensim ;;
    del_opensim) del_opensim ;;
    *) help ;;
esac