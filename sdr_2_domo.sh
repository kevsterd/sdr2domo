#!/bin/bash

# A script that will receive events from a RTL433 SDR
# and filter interesting values that are received.
#
# Filtered values are published to Domoticz API
# See also https://www.domoticz.com/wiki/Domoticz_API/JSON_URL's

# Author: Kevin Iddles
# Version: 1.0 - 2018-04-17 - Initial Version

# Remove hash on next line for debugging out to the docker container log
#set -x

#
# Start the listener and enter an endless loop
#
# Flags are -f set frequency, -R device type, -q quiet/supress non data mesg, -F format as JSON 
#
/usr/local/bin/rtl_433 -f 433900000 -R 43 -q -F json  |  while read line
do
	echo $line | \

# Remove hash from following line to record a raw log of events
   #tee -a /tmp/rtl433-raw.log

#Ideally this would use the count supplied as a param and loop, however this works for now
#
# Check output looking for serial number from sensor
	if [[ "$line" =~ "$sensor1Serial"  ]]
	then
		#Get relevant fields using jq
        	sensor1Depth=$(echo "$line" | jq '.depth')
	 		sensor1Temp=$(echo "$line" | jq '.temperature_C')
        	#Post out to Domo
 	    	curl -s -i -H "Accept: application/json" "http://$DOMO_USER:$DOMO_PASS@$DOMO_HOST:$DOMO_PORT/json.htm?type=command&param=udevice&idx=$sensor1TempIdx&svalue=$sensor1Temp"
	    	curl -s -i -H "Accept: application/json" "http://$DOMO_USER:$DOMO_PASS@$DOMO_HOST:$DOMO_PORT/json.htm?type=command&param=udevice&idx=$sensor1DepthIdx&svalue=$sensor1Depth"
	fi
#
# Check output looking for serial number from sensor
	if [[ "$line" =~ "$sensor2Serial"  ]]
	then
		#Get relevant fields using jq
        	sensor2Depth=$(echo "$line" | jq '.depth')
	 		sensor2Temp=$(echo "$line" | jq '.temperature_C')
        	#Post out to Domo
 	    	curl -s -i -H "Accept: application/json" "http://$DOMO_USER:$DOMO_PASS@$DOMO_HOST:$DOMO_PORT/json.htm?type=command&param=udevice&idx=$sensor2TempIdx&svalue=$sensor2Temp"
	    	curl -s -i -H "Accept: application/json" "http://$DOMO_USER:$DOMO_PASS@$DOMO_HOST:$DOMO_PORT/json.htm?type=command&param=udevice&idx=$sensor2DepthIdx&svalue=$sensor2Depth"
	fi
#
# Check output looking for serial number from sensor
	if [[ "$line" =~ "$sensor3Serial"  ]]
	then
		#Get relevant fields using jq
        	sensor3Depth=$(echo "$line" | jq '.depth')
	 		sensor3Temp=$(echo "$line" | jq '.temperature_C')
        	#Post out to Domo
 	    	curl -s -i -H "Accept: application/json" "http://$DOMO_USER:$DOMO_PASS@$DOMO_HOST:$DOMO_PORT/json.htm?type=command&param=udevice&idx=$sensor3TempIdx&svalue=$sensor3Temp"
	    	curl -s -i -H "Accept: application/json" "http://$DOMO_USER:$DOMO_PASS@$DOMO_HOST:$DOMO_PORT/json.htm?type=command&param=udevice&idx=$sensor3DepthIdx&svalue=$sensor3Depth"
	fi

done
