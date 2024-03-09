# Zabbix Template: Hardware Monitor

## Description

This template allows you to monitor hardware sensors like temperature, power, load and more, on a Windows machine.
It is needed to download official Open Hardware Monitor https://openhardwaremonitor.org/ or the branch I use https://github.com/hexagon-oss/openhardwaremonitor
Setup the web interface on the Open Hardware Monitor, and don't forget allow it in Windows firewall.

The current items in Zabbix will get a Json, and use LLD for the power and temperature sensors. You can create your own LLD to expand your needs.
Change the item prototypes for temperatures, and adjust the "Units" for Celsius (default) or Fahrenheit.

Tested in:
Zabbix 7.0.0alpha9
ASUS TUF GAMING X670E-PLUS WIFI
Nvidia RTX 4070Ti
Ryzen 7600x
Windows 10

Please report issues or contribute on GitHub: https://github.com/zingaya/zbx_processes_monitor

## Author

Leonardo Savoini

## Macros used

|Name|Description|Default|Type|
|----|-----------|-------|----|
|{$OPENHARDWAREMONITOR.URL}|The URL of the machine.|`http://HOST:8086/data.json`|Text macro|

## Template links

There are no template links in this template.

## Discovery rules

|Name|Description|Type|Key and additional info|
|----|-----------|----|-----------------------|
|Sensors temperatures|Discovery of sensors that have temperatures.|`DEPENDENT_ITEM (get.ohm.raw)`|get.ohm.sensors[temperature]|
|Sensors powers|Discovery of sensors that have powers.|`DEPENDENT_ITEM (get.ohm.raw)`|get.ohm.sensors[powers]|

## Items

|Name|Description|Type|Key and additional info|
|----|-----------|----|-----------------------|
|Get OpenHardwareMonitor raw data|Collects raw data from Open Hardware Monitor.|`HTTP_AGENT`|get.ohm.raw|

## Triggers

There are no triggers in this template.

## Items prototype

|Name|Description|Type|Key and additional info|
|----|-----------|----|-----------------------|
|{#COMPONENTNAME} ({#SENSORDATA} - Temperatures)|Get temperature|`DEPENDENT_ITEM (get.ohm.raw)`|get.ohm[{#NODEID},{#COMPONENTNAME},Temperatures]|
|{#COMPONENTNAME} ({#SENSORDATA} - Powers)|Get power consumption|`DEPENDENT_ITEM (get.ohm.raw)`|get.ohm[{#NODEID},{#COMPONENTNAME},Powers]|

## Triggers prototype

There are no triggers template in this template.
 
## LLD Overrides

There are no overrides in this template.
