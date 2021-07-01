#!/usr/bin/env bash
set -e

yum install git -y
git clone hhttps://github.com/hanrikos/app_deploy_script.git /tmp/deploy

sudo chmod +x /tmp/deploy/app_deploy_script/elk_all_in_one.sh
exec /tmp/deploy/app_deploy_script/elk_all_in_one.sh &
