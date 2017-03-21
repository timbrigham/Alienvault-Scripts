#! /bin/bash
echo "This script will remove and rebuild OpenVAS on an Alienvault / OSSIM server."
echo "This should be an end all solution for the various connectivity issues."
echo "If this errors out at any point *stop running any later steps!*"
echo ""
echo "=================================================================="
read  -n 1 -p "Continuing will reinstall openvas. Ctrl C to exit."

pkill -9 openvasmd
pkill -9 openvassd 

apt-get -y remove openvas-scanner
apt-get -y remove openvas-manager
apt-get -y remove alienvault-openvas 
apt-get -y remove alienvault-openvas8-feed
apt-get -y remove alienvault-redis-server-openvas
# Wipe out any leftover configuration. This notably includes tasks.db
rm -rf /var/lib/openvas/*

apt-get -y install openvas-scanner
apt-get -y install openvas-manager
apt-get -y install alienvault-openvas 
apt-get -y install alienvault-openvas8-feed
apt-get -y install alienvault-redis-server-openvas

echo ""
echo "=================================================================="
echo "Sync the latest plugins."
read  -n 1 -p "Continue"
# Get the latest plugins
openvas-nvt-sync

echo ""
echo "=================================================================="
echo "Make server and client certificates."
read  -n 1 -p "Continue"
openvas-mkcert -q -f
openvas-mkcert-client -n -i

echo ""
echo "=================================================================="
echo "Start Services."
read  -n 1 -p "Continue"
service openvas-manager restart
service openvas-scanner restart
service redis-server restart

echo ""
echo "=================================================================="
echo "Rebuild database."
openvasmd --rebuild --verbose --progress

echo ""
echo "=================================================================="
echo "Rebuild users. Note this assumes the default ossim / ossim id and password."
read  -n 1 -p "Continue"
openvasmd --create-user ossim
openvasmd --user=ossim --new-password=ossim
openvasmd --user=ossim --role=Admin

echo ""
echo "=================================================================="
echo "Connect to OpenVAS to verify a good install and credentials."
read  -n 1 -p "Continue"
/usr/bin/omp -h 127.0.0.1 -p 9390 -u ossim -w ossim --get-omp-version

echo ""
echo "=================================================================="
echo "Run a NVT get command like Alienvault does. Only get the families "
echo "since pulling all the plugins takes a long time"
read  -n 1 -p "Continue"
/usr/bin/omp -h 127.0.0.1 -p 9390 -u ossim -w ossim -iX "<get_nvt_families/>"

# This is a left over.. it clean up some logs. 
mkdir -p /var/lib/openvas/gnupg

echo ""
echo "=================================================================="
echo "Run an alienvault-reconfig to pick up the changes"
read  -n 1 -p "Continue"
alienvault-reconfig

