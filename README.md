# opensimMULTITOOLS
Bash and Batch Tools for OpenSimulator 

## opensimMULTITOOLS-Mini 0.03

Unpack your OpenSimulator and rename it, for example sim1. 

Then copy all required configurations from *.ini.example to *.ini. 

Now start osmmtools.sh with "bash osmmtools.sh start".

     start - start opensimulator.
     stop - stop opensimulator.
     restart - stop opensimulator and start opensimulator.
     check_screens - Restart in case of failure.

crontab -e

     # Restart in case of failure.
     */05 * * * * bash /opt/osmmtools.sh check_screens

## Windows
Start the batch file and press Enter for everything until it is finished.

The selection is only for people who know what they are doing.

System requirements for creating OpenSimulator:

DOTNET 8.0.x https://dotnet.microsoft.com/en-us/download/dotnet/8.0

Visual Studio 22 Community https://visualstudio.microsoft.com/de/vs/community/

Git https://git-scm.com/downloads/win

Start the OpenSimulator with "dotnet OpenSim.dll".

In the OpenSim console, type "create user" and enter the name "opensim" "avatar" a password 123, or whatever you want.

In the console, type "load oar terrain.oar" to get a finished land.

Start Firestorm Viewer and select create new grid in the OpenSim settings, paste the address http://127.0.0.1:9000" and have fun.

## Linux
Ubuntu is one of the most popular Linux distributions and has good compatibility with other Linux versions, 

especially those based on Debian. 

Ubuntu Server 

18.04(DOTNET 6) 20.04 22.04(DOTNET 8) (It is already prepared for version 24.04(DOTNET 8), which will come with version 24.04.1 in September.) 

OpenSimulator 0.9.3.0 + 0.9.3.1Dev

## OpenSimulator auto- start stop restart

### List crontabs:
     crontab -l

### Edit crontabs:
     crontab -e
```
# Minute Hour Day Month Year Command
#
# Restart at 5 AM, and on the 1st of each month, restart the entire server.
#
# Restart server on the first of each month to clear cache data debris.
45 4 1 * * bash /opt/osmtool.sh reboot
# Restart the grid every morning at 5 AM.
0 5 * * * bash /opt/osmtool.sh autorestart
# If Robust or the Welcome region fails, restart the grid.
*/30 * * * * bash /opt/osmtool.sh check_screens
```
### Save crontabs
     ctrl O
     Enter
### Exit editor
     ctrl X

## TODO
Automatic configuration is missing.
