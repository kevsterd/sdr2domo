#
# Docker file to create an image that contains enough software to listen to events on the 433,92 Mhz band,
# filter these and publish them to a MQTT broker.
#
# The script resides in a volume and should be modified to meet your needs
#
# The example script filters information from weather stations and publishes the information to topics that
# Domoticz listens on.
#
# Special attention is required to allow the container to access the USB device that is plugged into the host.
# The container needs priviliged access to /dev/bus/usb on the host.
# 
# docker run --name rtl_433 -d -e MQTT_HOST=<mqtt-broker.example.com>   --privileged -v /dev/bus/usb:/dev/bus/usb  <image>

FROM resin/rpi-raspbian:wheezy-20180109
MAINTAINER Kevin Iddles

LABEL Description="This image is to monitor a SDR device on 433mgz and push specific events to Domoticz" \
Vendor="YDC" \
Version="1.0"

#
# First install software packages needed to compile rtl_433 and to publish MQTT events
#
RUN apt-get update && apt-get install -y \
	rtl-sdr \
	librtlsdr-dev \
	librtlsdr0 \
	git \
	automake \
	libtool \
	cmake \
	mosquitto-clients \
	jq
	
#
# Pull RTL_433 source code from GIT, compile it and install it
#
RUN git clone https://github.com/merbanan/rtl_433.git \
	&& cd rtl_433/ \
	&& mkdir build \
	&& cd build \
	&& cmake ../ \
	&& make \
	&& make install 

#
# Define an environment variable
# 
# Use this variable when creating a container to specify the Domoticz host
ENV DOMO_HOST="128.65.99.150"
ENV DOMO_PORT="8080"
ENV DOMO_USER="ydc-api"
ENV DOMO_PASS="L3qohS9Cq9zRMc2XaLqY"

#Sensor detail
#Number of sensors
ENV sensorCount="3"
#Sensor1
ENV sensor1Serial="136870492"
ENV sensor1Name="Oil_Tank"
ENV sensor1TempIdx="244"
ENV sensor1DepthIdx="245"
#Sensor2
ENV sensor2Serial="134285721"
ENV sensor2Name="Garage_Water"
ENV sensor2TempIdx="285"
ENV sensor2DepthIdx="286"
#Sensor3
ENV sensor3Serial="140752056"
ENV sensor3Name="Polytunnel_Water"
ENV sensor3TempIdx="289"
ENV sensor3DepthIdx="290"

#
# When running a container this script will be executed
#
ENTRYPOINT ["/scripts/sdr_to_domo.sh"]

#
# Copy my script and make it executable
#
COPY sdr_to_domo.sh /scripts/sdr_to_domo.sh
RUN chmod +x /scripts/sdr_to_domo.sh

#
# The script is in a volume. This makes changes persistent and allows you modify it.
#
VOLUME ["/scripts"]