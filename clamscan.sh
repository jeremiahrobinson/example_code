#!/bin/sh
#Runs malware scan and mails output to support.  Runs weekly via crontab. 
dest_email="support@DOMAIN"
host_name=$( /bin/hostname )

/usr/local/bin/freshclam
/usr/local/bin/clamscan -r -i / | mail -s "clamscan.sh output $host_name" $dest_email
