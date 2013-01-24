#!/bin/bash

EMAIL="me@mymail.com"

EMAILMESSAGE="/tmp/processReport.txt"

addrs=($(echo $EMAIL | tr ";" "\n"))

for i in ${addrs[@]}; do

    `ssmtp "$i" < "$EMAILMESSAGE"`

done
