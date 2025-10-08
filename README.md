# Zabbix Templates: Hardware Monitor

## Description

Two Zabbix templates are included. One for Linux, the other for Windows. And allows you to monitor hardware sensors like temperature, power (and more for Windows).

### Windows

Download official Libre Hardware Monitor from https://github.com/LibreHardwareMonitor/LibreHardwareMonitor\
Unzip the file, start it, and setup the web interface on the Libre Hardware Monitor, and don't forget allow it in Windows firewall. Don't forget to start at boot.\

#### How it works
 
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

### Linux

Use the included script monitor.sh. And update script variables as needed.\
Add this script to run in a cronjob. You will need correct permissions to be able to read all sensors.

#### How it works

 - Master Item

 A trapper item (linuxsensor.trapper) receives JSON-formatted sensor data periodically sent from the external script (monitor.sh) running on the Linux host.

 - Power Sensor Discovery

 A dependent discovery rule (linuxsensor.power) parses the JSON and filters for RAPL-type sensors (energy consumption via Intel RAPL), creating low-level discovery (LLD) macros {#SENSOR} and {#TYPE}.

 - Temperature Sensor Discovery

 A dependent discovery rule (linuxsensor.temperature) parses the same JSON and filters for hwmon or thermal-type sensors (hardware monitoring and thermal zones), using the same LLD macros {#SENSOR} and {#TYPE}.

 - Item Prototypes

 For each discovered power sensor, a dependent item is auto-generated:

    {#SENSOR} watts
    
    It extracts the energy value using JSONPath, applies a multiplier of 1.0×10−61.0×10−6 to convert microjoules, and computes the change per second to derive power in watts (W).

 For each discovered temperature sensor, a dependent item is auto-generated:
    
    {#SENSOR} temperature (º{$TEMPSCALE})
    
    It extracts the temperature value using JSONPath and applies a multiplier of 0.001 to convert millidegrees to degrees.

    User Macros

    {$TEMPSCALE} defines the temperature unit (C or F).

## Requirements

Zabbix 7.4.0+
