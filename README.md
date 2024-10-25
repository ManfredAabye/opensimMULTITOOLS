# opensimMULTITOOLS
Bash Tools for OpenSimulator 

Ubuntu is one of the most popular Linux distributions and has good compatibility with other Linux versions, 

especially those based on Debian. 

Ubuntu Server 

18.04 20.04 22.04 (It is already prepared for version 24.04, which will come with version 24.04.1 in September.) 

DOTNET 8 


## Crontab auto- start restart
crontab -l

     # Restart server on the first day of each month due to cache data clutter.
     45 4 1 * * bash /opt/osmtool.sh reboot
     # Restart the grid every morning at 5.
     0 5 * * * bash /opt/osmtool.sh autorestart
     # If Robust or the Welcome Region fails, restart the grid.
     */15 * * * * bash /opt/osmtool.sh check_screens

crontab -e

ctrl O

Enter

ctrl X

## TODO
Automatic configuration is missing.
