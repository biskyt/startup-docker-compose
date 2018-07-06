#!/bin/bash

sudo cp startup-compose.sh /usr/local/bin/
sudo chmod a+rx /usr/local/bin/startup-compose.sh
sudo cp startup-compose-cronjob /etc/cron.d/
sudo chmod 644 /etc/cron.d/startup-compose-cronjob

echo "Installed, will run at reboot - edit /etc/cron.d/startup-compose-cronjob to change root"
