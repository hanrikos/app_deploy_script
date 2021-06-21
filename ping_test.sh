#!/bin/sh

while ! ping -c1 $1 &>/dev/null
        do echo "Ping Fail - `date`"
done
echo "Host Found - `date`"
