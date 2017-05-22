This is an Apache configuration file which will allow you to easily link to specific alarms in Alienvault, using the following syntax. 

http://yourserver.yourdomain.org:8080/BACKLOG_ID

To use copy to /etc/apache2/sites-available and link to /etc/apache2/sites-enabled. 

You will also need to edit /etc/ossim/firewall_include and add an allow rule for this port. It should look like the following. 
-I INPUT -p tcp --dport 8080 -j ACCEPT

Run alienvault-reconfig when complete. 


