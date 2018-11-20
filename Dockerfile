#
# Docker file to create an image that contains enough software to listen to events on the 433 Mhz band,
# filter them and publish direct to the Domoticz API
#
# Special attention is required to allow the container to access the USB device that is plugged into the host.
# The container needs priviliged access to /dev/bus/usb on the host.
# 

FROM multiarch/debian-debootstrap:armhf-jessie

LABEL Description="This image is to monitor a SDR device on 433mgz and push specific events to Domoticz" \
	Vendor="YDC" \
	Version="1.0"

RUN apt-get update && 
    apt-get install -y wget curl

RUN apt-get update && \
    apt-get install -y libusb-1.0-0-dev pkg-config ca-certificates git-core cmake build-essential --no-install-recommends && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /tmp

RUN echo 'blacklist dvb_usb_rtl28xxu' > /etc/modprobe.d/raspi-blacklist.conf && \
    git clone git://git.osmocom.org/rtl-sdr.git && \
    mkdir rtl-sdr/build && \
    cd rtl-sdr/build && \
    cmake ../ -DINSTALL_UDEV_RULES=ON -DDETACH_KERNEL_DRIVER=ON && \
    make && \
    make install && \
    ldconfig && \
    rm -rf /tmp/rtl-sdr

RUN git clone https://github.com/merbanan/rtl_433.git && \
    cd rtl_433 && \
    mkdir build && \
    cd build && \
    cmake ../ && \
    make && \
    make install && \
    cd / && \
    rm -rf /tmp/rtl_433

RUN apt-get update && \
    apt-get install -y jq && \
rm -rf /var/lib/apt/lists/* 

#
# NOTE: For simplicity all environment varibles are passed from the Docker run statement
# using the --env-file ./sdr_2_domo.env parameter
# 

#
# When running a container this script will be executed
#
ENTRYPOINT ["/scripts/sdr_2_domo.sh"]

#
# Copy in script and make it executable
#
COPY sdr_2_domo.sh /scripts/sdr_2_domo.sh
RUN chmod +x /scripts/sdr_2_domo.sh

#
# The script is in a volume. This makes changes persistent and allows you modify it.
#
VOLUME ["/scripts"]
