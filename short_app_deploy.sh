#!/usr/bin/env bash
set -e

git clone hhttps://github.com/hanrikos/app_deploy_script.git /tmp/deploy

sudo chmod +x /tmp/deploy/app_deploy_script/app_deploy.sh
exec /tmp/deploy/app_deploy_script/app_deploy.sh&
