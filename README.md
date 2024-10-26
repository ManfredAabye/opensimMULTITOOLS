# opensimMULTITOOLS
Bash Tools for OpenSimulator 

Ubuntu is one of the most popular Linux distributions and has good compatibility with other Linux versions, 

especially those based on Debian. 

Ubuntu Server 

18.04 20.04 22.04 (It is already prepared for version 24.04, which will come with version 24.04.1 in September.) 

DOTNET 8 


## OpenSimulator auto- start restart

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
