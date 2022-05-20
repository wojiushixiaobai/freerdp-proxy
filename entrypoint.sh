#!/bin/bash

if [ -n "${LOG_LEVEL}" ]; then
  export WLOG_LEVEL=${LOG_LEVEL}
fi

# if [ ! -d "/opt/freerdp/cert" ]; then
#   mkdir -p /opt/freerdp/cert
# fi

# if [ ! -f "/opt/freerdp/cert/key.pem" ] && [ ! -f "/opt/freerdp/cert/cert.pem" ]; then
#   openssl req -x509 -newkey rsa:2048 -nodes -keyout /opt/freerdp/cert/key.pem -out /opt/freerdp/cert/cert.pem -days 3650 -subj "/C=CN/ST=Beijing/L=Beijing/O=JumpServer/OU=Dev/CN=dev" > /dev/null 2>&1
# fi

# if [ ! -f "/opt/freerdp/cert/rdp-private.key" ]; then
#   winpr-makecert -silent -path /opt/freerdp/cert -n rdp-private
# fi

if [ -n "${HOST_IP}" ]; then
  sed -i "s@Host = CustomHost@Host = ${HOST_IP}@g" /opt/freerdp/config.ini
fi

if [ -n "${CAPTURE}" ]; then
  sed -i "s@Enabled = FALSE@Enabled = TRUE@g" /opt/freerdp/config.ini
fi

freerdp-proxy /opt/freerdp/config.ini
