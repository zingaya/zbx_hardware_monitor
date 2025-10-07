# Zabbix Template: Hardware Monitor

## Description

This template allows you to monitor hardware sensors like temperature, power, load and more, on a Windows machine.\
Download official Libre Hardware Monitor from https://github.com/LibreHardwareMonitor/LibreHardwareMonitor\
Setup the web interface on the Libre Hardware Monitor, and don't forget allow it in Windows firewall. Don't forget to start at boot.\
![imagen](http://gitea-01.local:3000/zingaya/zbx_hardware_monitor/assets/19838800/d5656400-cfd5-46f6-b1a3-1455af0f8414)

Tested in:\
Zabbix 7.4.2\
ASUS TUF GAMING X670E-PLUS WIFI\
Nvidia RTX 4070Ti\
Ryzen 7600x\
Windows 10

Please report issues or contribute on GitHub: https://github.com/zingaya/zbx_hardware_monitor

## How it works
 - Master Item

 An HTTP agent item (lhm.get.json) periodically queries the LibreHardwareMonitor JSON endpoint ({$LIBREHARDWAREMONITOR.URL}) to fetch raw sensor data from the Windows host.

 - Component Discovery

 A dependent discovery rule (lhm.discover.components) parses the JSON and filters for key hardware components (CPU, GPU, RAM, motherboard, etc.), creating low-level discovery (LLD) macros {#ID}, {#COMPONENTNAME}, and {#COMPONENTTYPE}.

 - Nested Sensor Discovery

 Leveraging Zabbix’s latest nested LLD feature, a second discovery rule (lhm.discover.component.sensors[{#COMPONENTNAME}]) runs within each component context. It filters for Temperature and Power sensors, using AND conditions on {#SENSORTYPE} and {#SENSORID} to select only those sensor types.

 - Item Prototypes

 For each discovered sensor, two dependent items are auto-generated:

    Power item in watts (W)

    Temperature item in degrees (ºC or ºF, per {$TEMPTYPE})
    Both use JSONPath to extract the value, string replacement to normalize decimal separators, and regex to isolate the numeric value.

 User Macros

    {$LIBREHARDWAREMONITOR.URL} specifies the JSON data URL provided by LibreHardwareMonitor.

    {$TEMPTYPE} defines the temperature unit (C or F).
