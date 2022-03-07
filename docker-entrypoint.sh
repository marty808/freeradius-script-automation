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


echo "$CRON_SCHEDULE    root    export LANG=$LANG; run-parts /config/exec.d >> /var/log/script.log" > /etc/cron.d/script

touch /var/log/script.log

# generate locale if changed
if [[ "$LANG" != "C.UTF8" ]]; then
  echo "$(date +"%a %b %d %T %Y") : generate locale..."
  locale-gen
fi

# start executables
echo "$(date +"%a %b %d %T %Y") : starting cron..."
cron

if $DEBUG; then
  freeradius -X
else
  freeradius -C
fi 

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


