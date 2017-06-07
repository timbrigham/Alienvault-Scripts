This is an updated version of the script from https://stujordan.wordpress.com/2015/06/29/keeping-ossim-db-tables-in-check/ 
It is parameterized for easily adding additional tables that need attention and includes the idm_data table, which wasn't in the original. 

To use this find the OSSIM ID and password from your config file (/etc/ossim/ossim_setup.conf)
 grep -A 3 database /etc/ossim/ossim_setup.conf

Either edit your crontab or drop into cron.daily. 