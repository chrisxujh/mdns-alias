#!/bin/bash

CONFIG_FILE=.mdns-aliases

if [ ! -f $CONFIG_FILE ]; then
	echo "Config file '$CONFIG_FILE' does not exist."
	exit 0
fi

if ! dpkg -s avahi-utils; then
	echo "Package 'avahi-utils' not installed"
	exit 1
fi

function _term {
  pkill -P $$
}

trap _term SIGTERM

INTERFACE=$(head -1 $CONFIG_FILE)

echo "Configuring interface '$INTERFACE'"

IP=$(ip addr show $INTERFACE | grep "inet\b" | awk '{print $2}' | cut -d/ -f1)

echo "Detected ip address of '$INTERFACE': $IP"

tail +2 $CONFIG_FILE | while read n; do
	echo "Publishing '$n'"
	avahi-publish -a $n -R $IP &
done

while true; do sleep 10000; done
