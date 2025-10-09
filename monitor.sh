#!/bin/sh

# Zabbix server configuration
ZBX_URL="http://zabbix-server/api_jsonrpc.php"  # Replace with your Zabbix frontend API URL
HOST=$(hostname)  # Replace if you are using a different host name in Zabbix
AUTH_TOKEN="mytoken"  # Replace with your authentication token

# Initialize the JSON output as an array
json_output="["

# Gather energy values for each core (rapl)
for energy_file in /sys/class/powercap/intel-rapl*/energy_uj /sys/class/powercap/intel-rapl*/intel-rapl*/*/energy_uj; do
    [ -f "$energy_file" ] || continue  # Skip non-files (e.g., if glob doesn't match)
    core_name=$(basename "$(dirname "$energy_file")")
    energy_value=$(cat "$energy_file")
    json_output="${json_output}{\"type\":\"rapl\",\"sensor\":\"$core_name\",\"value\":\"$energy_value\"},"
done

# Gather thermal zones
for tz in /sys/class/thermal/thermal_zone*; do
    [ -d "$tz" ] || continue
    ttype=$(cat "$tz/type")
    tval=$(cat "$tz/temp")
    json_output="${json_output}{\"type\":\"thermal\",\"sensor\":\"thermal_zone_$ttype\",\"value\":\"$tval\"},"
done

# Gather hwmon sensor labels and values
for hw in /sys/class/hwmon/hwmon*; do
    [ -d "$hw" ] || continue
    name=$(cat "$hw/name" 2>/dev/null || echo "$hw")
    for input in "$hw"/temp*_input; do
        [ -f "$input" ] || continue
        lbl="${input%_input}_label"
        if [ -f "$lbl" ]; then
            label=$(cat "$lbl")
        else
            label=$(basename "$input")
        fi
        val=$(cat "$input")
        json_output="${json_output}{\"type\":\"hwmon\",\"sensor\":\"$name:$label\",\"value\":\"$val\"},"
    done
done

# Remove trailing comma (manual check)
if [ -n "$json_output" ]; then
    json_output="${json_output%,}"
fi

# Close the JSON array
json_output="${json_output}]"

# Output result (uncomment echo for debug)
# echo "$json_output"

# Escape the JSON output for Zabbix (POSIX sed)
escaped_json_output=$(echo "$json_output" | sed 's/"/\\"/g')

# Construct the final Zabbix JSON payload using printf for safety
zabbix_json=$(printf '{
  "jsonrpc": "2.0",
  "method": "history.push",
  "params": [
    {
      "host": "%s",
      "key": "linuxsensor.trapper",
      "value": "%s"
    }
  ],
  "id": 1
}' "$HOST" "$escaped_json_output")

# Debug zabbix_json
# echo $zabbix_json

# Send the JSON to Zabbix (curl is assumed available)
curl -s -X POST "$ZBX_URL" \
     -H 'Content-Type: application/json' \
     -d "$zabbix_json" \
     --header "Authorization: Bearer $AUTH_TOKEN"
