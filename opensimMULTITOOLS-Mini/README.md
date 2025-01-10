# OpenSimulator Management Scripts

Dieses Repository enthält mehrere Bash-Skripte zur Verwaltung, Installation und Konfiguration von OpenSimulator.

## Übersicht der Skripte

### osmbuilder.sh noch nicht ganz fertig, nur zur Sicherung hier.
Dieses Skript dient zur Automatisierung des Build-Prozesses von OpenSimulator. Verfügbare Befehle:

- **autobuild** – Führt den gesamten automatisierten Build-Prozess aus.
- **warnings** – Zeigt Warnungen an, die während des Builds auftreten können.
- **clone_opensim** – Klont das OpenSimulator-Repository.
- **copy_opensim0930** – Kopiert eine spezielle Version (0.9.30) von OpenSimulator.
- **clone_moneyserver** – Klont das Repository für den MoneyServer.
- **prebuild_opensim** – Bereitet den Build-Prozess von OpenSimulator vor.
- **clone_examplescripts** – Klont Beispielskripte.
- **build_opensim** – Baut OpenSimulator.
- **del_opensim** – Löscht eine bestehende OpenSimulator-Installation.

### osminstaller.sh noch nicht ganz fertig, nur zur Sicherung hier.
Dieses Skript hilft bei der Installation und Konfiguration von OpenSimulator. Verfügbare Befehle:

- **osconfiginstall** – Installiert die grundlegende OpenSimulator-Konfiguration.
- **osmmcopy** – Kopiert Konfigurationsdateien.
- **osmmconfig** – Erstellt und bearbeitet Konfigurationsdateien.
- **del_opensim** – Entfernt eine bestehende OpenSimulator-Installation.
- **warnings** – Zeigt Installationswarnungen an.
- **server_install** – Installiert die notwendigen Serverdienste.
- **uninstall_mysql** – Deinstalliert MySQL.
- **config_rename** – Benennt Konfigurationsdateien um.
- **configuration_opengrid** – Konfiguriert OpenSimulator für ein offenes Grid.
- **configuration_closedgrid** – Konfiguriert OpenSimulator für ein geschlossenes Grid.
- **configuration_openmoneygrid** – Konfiguriert OpenSimulator für ein offenes Grid mit MoneyServer.
- **configuration_closedmoneygrid** – Konfiguriert OpenSimulator für ein geschlossenes Grid mit MoneyServer.
- **configuration_simulatoropen** – Konfiguriert einen offenen Simulator.
- **configuration_simulatorclose** – Konfiguriert einen geschlossenen Simulator.

### osmtool.sh
Dieses Skript enthält verschiedene Verwaltungsbefehle für OpenSimulator. Verfügbare Befehle:

- **start** – Startet OpenSimulator.
- **stop** – Stoppt OpenSimulator.
- **restart** – Startet OpenSimulator neu.
- **cachedel** – Löscht den Cache.
- **clean_restart** – Führt einen Neustart mit Cache-Löschung durch.
- **ifrunning** – Prüft, ob OpenSimulator läuft.
- **check_screens** – Prüft, ob OpenSimulator läuft und startet fehlende Teile neu.
- **logdel** – Löscht Log-Dateien.
- **help** – Zeigt eine Hilfsübersicht an.

- crontab -e

     # Restart in case of failure.
     */05 * * * * bash /opt/osmmtools.sh check_screens

## Nutzung
Führe die Skripte mit folgendem Befehl aus:

```bash
bash skriptname.sh befehl
```

Beispiel:
```bash
bash osmtool.sh start
```
Dies startet OpenSimulator.

Weitere Details zu den Befehlen erhältst du mit:
```bash
bash osmtool.sh help
```

## Lizenz
Dieses Projekt steht unter einer Open-Source-Lizenz.

