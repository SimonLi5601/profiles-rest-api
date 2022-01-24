#!/usr/bin/env bash

set -e

# TODO: Set to URL of git repo.
PROJECT_GIT_URL='https://github.com/SimonLi5601/profiles-rest-api.git'

PROJECT_BASE_PATH='/usr/local/apps/profiles-rest-api'

echo "Installing dependencies..."
#yum update -y
yum install -y python3-dev python3-venv sqlite python-pip supervisor nginx git gcc epel-release clang

# Create project directory
mkdir -p $PROJECT_BASE_PATH
git clone $PROJECT_GIT_URL $PROJECT_BASE_PATH

# Create virtual environment
mkdir -p $PROJECT_BASE_PATH/env
python3 -m venv $PROJECT_BASE_PATH/env

# Install python packages
$PROJECT_BASE_PATH/env/bin/pip install -r $PROJECT_BASE_PATH/requirements.txt
$PROJECT_BASE_PATH/env/bin/pip install uwsgi==2.0.18

# Run migrations and collectstatic
cd $PROJECT_BASE_PATH
$PROJECT_BASE_PATH/env/bin/python manage.py migrate
$PROJECT_BASE_PATH/env/bin/python manage.py collectstatic --noinput

# Configure supervisor
cp $PROJECT_BASE_PATH/deploy/profiles_systemd /etc/systemd/system/profiles_systemd
systemctl reload daemon
systemctl restart profiles_api

# Configure nginx
cp $PROJECT_BASE_PATH/deploy/nginx_profiles_api.conf /etc/nginx/conf.d/profiles_api.conf
rm /etc/nginx/conf.d/default
systemctl restart nginx.service

echo "DONE! :)"
