#!/bin/bash

if [[ ! -d "/config/exec.d/" ]]; then
  mkdir -p /config/exec.d
  cp /examples/* /config/exec.d/
fi

if [[ ! -f "/config/clients.conf" ]]; then
  echo "# don't delete this file" > /config/clients.conf
fi

if [[ ! -f "/config/huntgroups" ]]; then
  echo "# don't delete this file" > /config/huntgroups
fi


if [[ ! -f "/config/users" ]]; then
  echo "# don't delete this file" > /config/users
fi


echo "$CRON_SCHEDULE    root    run-parts /config/exec.d >> /var/log/script.log" > /etc/cron.d/script

touch /var/log/script.log

# start executables
echo "$(date +"%a %b %d %T %Y") : starting cron..."
cron

freeradius -C
if [[ $? -ne 0 ]]; then 
  echo "$(date +"%a %b %d %T %Y") : freeradius config check failed!!"
  exit 1
else 
  echo "$(date +"%a %b %d %T %Y") : freeradius config check passed..."
  echo "$(date +"%a %b %d %T %Y") : starting freeradius..."
  freeradius
fi


# log to stdout
tail -f /var/log/freeradius/radius.log &
tail -f /var/log/script.log


