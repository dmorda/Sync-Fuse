Sync Fuse
=========

Version: v1.0	

This script uses rsync to backup a specified directory to another host over a mounted SSHFS file system. Before first use, you should modify the user-configurable variables to suit your needs.

Requirements
============

This script requires a linux-based operating system with SSHFS and rsync installed.

Configuration Parameters
========================

 # File system location of your ssh configuration file used to connect to the remote ssh server.
 FUSE_MOUNT_CONFIG="/home/your_user/.ssh/remote_backup_ssh_config"
 
 # Remote host you are going to sync your files to via SSHFS
 REMOTE_HOST="remote.host.com"
 
 # Location of source files you wish to sync remotely
 SOURCE_DIR="/location/of/backup_directory/"
 
 # Directory used to mount the remote file system. Leave the trailing slash.
 FUSE_DIR="/home/your_user/fuse_remote/"
 
 # Directory within the $FUSE_DIR, if any, where the backups should be stored
 DEST_DIR="backup"
 
 # Subject line for the email
 SUBJECT="Automated Offsite Sync for My Host"
 
 # Email address you want logs to be sent to
 TO_ADDRESS="your.email@yourdomain.com"
 
 # From address you want messages to appear from
 FROM_ADDRESS="no-reply@yourdomain.com"
 
 # Date format you want used in certain parts of the log file
 DATE=`date +%Y-%m-%d_%Hh%Mm`
 
 # Logfile directory where logs are stored after running backup
 LOGDIR="/home/your_user/backup_logs/"

Support & Feedback
==================

Send email to [Damon Morda](mailto:damon.morda@brandedclever.com).

Author
======

This script is maintained by [Damon Morda](mailto:damon.morda@brandedclever.com) at [Branded Clever](http://www.brandedclever.com/).