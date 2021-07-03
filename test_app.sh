#!/usr/bin/env bash

echo $pass | sudo -S ls /root

sudo sed -i "/127.0.0.1/ s/.*/0.0.0.0\tlocalhost/g" /etc/hosts

runAsRoot="
printf \"\nhey there\n\"
printf \"\nhello world, I am root\n\" >> \"/home/parallels/rootWasHere.txt\"
"
exec su root -c "$runAsRoot"
