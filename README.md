# Sdr2Domo
A Docker container to allow a RTL_433 based Software Defined Radio (SDR) to collect filtered output and import direct to Domomticz using the JSON API.

This was originally built to use on Raspberry Pi 2/3 but should work on all devices assuming the USB ports are exposed as /dev/usb


docker stop sdr2domo
docker container rm sdr2domo -f
docker build sdr2domo
docker image ls
docker tag 780be253d282 sdr2domo
docker image rm 2d118521788f
docker image ls
docker container ls
docker container rm sdr2domo -f
docker run --name sdr2domo -d --privileged -v /dev/bus/usb:/dev/bus/usb --env-file sdr2domo/sdr_2_domo.env sdr2domo
docker ps
docker container logs sdr2domo --follow