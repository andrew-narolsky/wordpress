#!/bin/bash

sudo apt -y update
sudo apt -y install ca-certificates wget

wget https://dl.influxdata.com/telegraf/releases/telegraf_1.13.4-1_amd64.deb
sudo dpkg -i telegraf_1.13.4-1_amd64.deb

service telegraf stop

cp /etc/telegraf/telegraf.conf /etc/telegraf/telegraf.conf.bak; cat /dev/null > /etc/telegraf/telegraf.conf

{
echo '[global_tags]'
echo '  nametag = "PHP"'
echo '[agent]'
echo '  interval = "10s"'
echo '  round_interval = true'
echo '  metric_batch_size = 1000'
echo '  metric_buffer_limit = 10000'
echo '  collection_jitter = "0s"'
echo '  flush_interval = "10s"'
echo '  flush_jitter = "0s"'
echo '  precision = ""'
echo '  hostname = ""'
echo '  omit_hostname = false'
echo '[[outputs.influxdb]]'
echo '   urls = ["http://influx.darkempire.uk:80"]'
echo '   database = "telegraf"'
echo '   skip_database_creation = true'
echo '   username = "telegraf"'
echo '   password = "^n+a{Lqa"'
echo '   user_agent = "telegraf"'
echo '[[inputs.cpu]]'
echo '  percpu = true'
echo '  totalcpu = true'
echo '  collect_cpu_time = false'
echo '  report_active = false'
echo '[[inputs.disk]]'
echo '  ignore_fs = ["tmpfs", "devtmpfs", "devfs", "iso9660", "overlay", "aufs", "squashfs"]'
echo '[[inputs.diskio]]'
echo '[[inputs.kernel]]'
echo '[[inputs.mem]]'
echo '[[inputs.processes]]'
echo '[[inputs.swap]]'
echo '[[inputs.system]]'
echo ' [[inputs.docker]]'
echo '   endpoint = "unix:///var/run/docker.sock"'
echo '#   gather_services = true'
echo '   perdevice = true'
echo ' [[inputs.net]]'
echo '    interfaces = ["eth0"]'
echo ' [[inputs.netstat]]'
} >> /etc/telegraf/telegraf.conf

#service telegraf restart