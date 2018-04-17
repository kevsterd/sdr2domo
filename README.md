# Sdr2Domo

## Overview

A Docker container to allow a RTL_433 based Software Defined Radio (SDR) to collect filtered output and import direct to Domomticz using its JSON API.

The RTL_433 devices are cheap, $10 USB DVB-T tuners that are amazing and very flexible.  The RTL_433 git project does all the heavy lifting managing protocols.

This was originally built to use on Raspberry Pi 2/3 but should work on all devices assuming the USB ports are exposed as /dev/bus/usb.  A probe is run to find the RTL_433 device on startup, i'm guessing by the USB PCID.

I have three sensors I am interested in.  I use the Watchman Sonic Oil Tank monitor to monitor a Heating Oil Tank, along with two huge (1200 litre) water tanks I use for the garden.  I found the sensors work fine for water as well as Kerosene as they have similar qualities. They send out a serial number, temp in C and a depth (how far from the sensor the fluid level is)

The tank sensor is seen by the SDR and is decoded and output as JSON.

`{"time" : "2018-04-17 20:48:51", "model" : "Oil Watchman", "id" : 134285721, "flags" : 128, "maybetemp" : 21, "temperature_C" : 13.333, "binding_countdown" : 0, "depth" : 73}`

I use some maths in the Domoticz scripts (included) to work out volume based on height in tank and then display percentage in tank and a quantity in litres.   Its not 100% correct but close enough for me.   Some man maths was involved to get these correct.

Obviously I'm interested in when the oil tank is low (so I can order more) and when the water tank is low (needs filling) otherwise crops dont get watered.

You can use generic virtual sensors in Domotics to take in the values.   The LUA scripts run against these and populate the displayed devices/sensors labeled accordingly.

## Using

Currently I haven't published this to the Docker registry so its all manual for now.   I'm still learning Docker, Markdown, Git and Travis CI :)

The three key files for the Docker container are:

|   File   |                   Use                                |
|----------|------------------------------------------------------|
|Dockerfile|Used to define the container OS, modules and structure|
|sdr_2_domo.sh|Script called by the continer when ran|
|sdr_2_domo.env|A set of runtime parameters used to define access into Domotics, device ID's and Virtual ID's|

## Tips for Docker

>Stop and remove any existing containers

`docker stop sdr2domo`

`docker container rm sdr2domo -f`

>Assuming you cloned to ~/sdrdomo then you build from outside of it.  This will take a while but watch and learn

`docker build sdr2domo --tag sdr2domo`

>Once complete look for the image

`docker image ls`

>The `docker image ls` shows you any container images.   I would delete any un-named ones as they are spare/old

`docker image rm 2d118521788f`

`docker image ls`

>Run the new container !
>At the moment its run at the highest privilege as USB ports are odd with Docker.   I don't currently know of a way round this

`docker run --name sdr2domo --restart always -d --privileged -v /dev/bus/usb:/dev/bus/usb --env-file sdr2domo/sdr_2_domo.env sdr2domo`

>Check its running

`docker ps`

>Look at the logs.  More is exposed if you enable to `set -x`

`docker container logs sdr2domo --follow`

>Or you can open a bash shell within and poke away....

`docker exec --it sdrdomo bash`
