#! /bin/bash
echo "This script will remove and rebuild OpenVAS on an Alienvault / OSSIM server."
echo "This should be an end all solution for the various connectivity issues."
echo "If this errors out at any point *stop running any later steps!*"

echo "=================================================================="
read  -n 1 -p "Continuing will reinstall openvas. Ctrl C to exit."

pkill -9 openvasmd
pkill -9 openvassd 

# Remove the OpenVAS packages
apt-get remove openvas-scanner
apt-get remove openvas-manager
apt-get remove alienvault-openvas 
apt-get remove alienvault-openvas8-feed
apt-get remove alienvault-redis-server-openvas
# Wipe out any leftover configuration.
rm -rf /var/lib/openvas/*

# Reinstall apps.
apt-get install openvas-scanner
apt-get install openvas-manager
apt-get install alienvault-openvas 
apt-get install alienvault-openvas8-feed
apt-get install alienvault-redis-server-openvas

#echo "The scanner_address and scanner_port lines in /etc/init.d/openvas-manager are broken. Stop now and comment them out."
#echo "=================================================================="
#read  -n 1 -p "Pause here until you have edited the file above"

#[ "$SCANNER_ADDRESS" ] && DAEMONOPTS="$DAEMONOPTS --scanner-host=$SCANNER_ADDRESS"
#[ "$SCANNER_PORT" ]    && DAEMONOPTS="$DAEMONOPTS --scanner-port=$SCANNER_PORT"
# Update from sport and shost


# set scanner ip in /etc/default/openvas-manager

echo "=================================================================="
read  -n 1 -p "Sync the latest plugins."
# Get the latest plugins
openvas-nvt-sync

echo "=================================================================="
read  -n 1 -p "Make server and client certificates."
# Create an OpenVAS server certificate.
openvas-mkcert -q -f
# Create a client certificate. 
openvas-mkcert-client -n -i

echo "=================================================================="
read  -n 1 -p "Start Services."
# Start the OpenVAS services.
service openvas-manager restart
service openvas-scanner restart
service redis-server restart

echo "=================================================================="
read  -n 1 -p "Rebuild database."
# Rebuild the database. 
openvasmd --rebuild --verbose

echo "=================================================================="
read  -n 1 -p "Rebuild users. Note this assumes the default ossim / ossim id and password."
openvasmd --create-user ossim
openvasmd --user=ossim --new-password=ossim
openvasmd --user=ossim --role=Admin

echo "=================================================================="
read  -n 1 -p "Connect to OpenVAS to verify connectivity."
/usr/bin/omp -h 127.0.0.1 -p 9390 -u ossim -w ossim --get-omp-version

mkdir -p /var/lib/openvas/gnupg

# Use the "update custom" arguments here - without them this script breaks any third party profiles created.
#echo "=================================================================="
#read  -n 1 -p "Rebuild the profiles with the updated plugin information"
#rm /usr/share/ossim/www/vulnmeter/tmp/tmp.xml
# Don't use this script - it breaks things...
#perl /usr/share/ossim/scripts/vulnmeter/updateplugins.pl  
#perl /usr/share/ossim/scripts/vulnmeter/updateplugins.pl update custom


#echo "=================================================================="
#read  -n 1 -p "Run an alienvault-update to pick up the changes"
#alienvault-update


#/usr/bin/omp -h 127.0.0.1 -p 9390 -u ossim -w ossim -iX "<GET_NVTS/>"
#    <get_nvts_response status="503" status_text="Service temporarily down"></get_nvts_response>

/usr/bin/omp -h 127.0.0.1 -p 9390 -u ossim -w ossim -iX "<GET_NVTS details='1'/>"

# The client uses the get_preferences command to get preference information. If the command sent by the client was valid, the manager will reply with a list of preferences to the client. If the manager cannot access a list of available NVTs at present, it will reply with the 503 response.

#perl /usr/share/ossim/scripts/vulnmeter/updateplugins.pl update wget
#perl /usr/share/ossim/scripts/vulnmeter/updateplugins.pl migrate






echo "=================================================================="
read  -n 1 -p "Run an alienvault-reconfig to pick up the changes"
alienvault-reconfig




#echo "=================================================================="
#echo "If your scan jobs in OSSIM / Alienvault are still hanging up check "
#echo "/var/log/openvassd.messages for references to /tmp/redis.sock. if they are there "
#echo "edit the file /etc/openvas/openvassd.conf (creating it if needed)"
#echo "and add the following line. "
#echo "kb_location=/var/run/redis/redis-server-openvas.sock"

