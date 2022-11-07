#!/bin/bash

if [ ! -d "/opt/freerdp/data/captures" ]; then
  mkdir -p /opt/freerdp/data/captures
fi

if [ ! -f "/opt/freerdp/cert/server.crt" ] && [ ! -f "/opt/freerdp/server.key" ]; then
  openssl req -x509 -newkey rsa:2048 -nodes -keyout /opt/freerdp/server.key -out /opt/freerdp/server.crt -days 3650 -subj "/C=CN/ST=Beijing/L=Beijing/O=JumpServer/OU=Dev/CN=dev" > /dev/null 2>&1
fi

if [ -n "${HOST_IP}" ]; then
  sed -i "s@Host = CustomHost@Host = ${HOST_IP}@g" /opt/freerdp/config.ini
fi

freerdp-proxy /opt/freerdp/config.ini
