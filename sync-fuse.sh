#!/bin/bash
#
# Sync Fuse v1.0
# Author: Damon Morda (damon.morda@brandedclever.com)
# Last Updated: February 15, 2011
#
# This script uses rsync to backup a specified directory to another host
# over a mounted SSHFS file system. Before first use, you should modify
# the user-configurable variables to suit your needs.
#
# Sample Usage:
#   ./sync-fuse.sh
#

###############################
# USER-CONFIGURABLE VARIABLES #
###############################

# Declare whether to use a custom sshd configuration or not
USE_CUSTOM_SSH_CONFIG=false

# Custom sshd configuration file used when connecting to remote host
FUSE_MOUNT_CONFIG="/home/your_user/.ssh/remote_backup_ssh_config"

# If not using a custom sshd configuration, provide username and password
USER="user-name"
PASSWORD="password"

# Specify an alternative port
PORT=22

# Remote host where you are going to sync your files to
REMOTE_HOST="remote.host.com"

# Location of source files you wish to sync remotely
SOURCE_DIR="/location/of/backups/"

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

#####################################
# DO NOT CHANGE ANYTHING BELOW HERE #
#####################################

FULL_BACKUP_PATH="${FUSE_DIR}${DEST_DIR}"

# Pattern used to search and determine if the file system is mounted 
PATTERN=`echo "${FUSE_DIR}" | sed -e "s/\/*$//" `

# Filename of logfile
LOG_FILE="remote-backup-sync-`date +%Y-%m-%d-%M`.txt"

# Combined log file variable
LOGFILE="${LOGDIR}${LOG_FILE}"

# Mounts remote file system using a certian sshd config
MOUNT_CMD_KEY="sshfs -F $FUSE_MOUNT_CONFIG ${REMOTE_HOST}: $FUSE_DIR"

# Mounts remote file system using username and password
MOUNT_CMD_PWD="`echo $PASSWORD | sshfs -p $PORT ${USER}@${REMOTE_HOST}: $FUSE_DIR -o password_stdin`"

# Unmounts remote file system
UNMOUNT_CMD="fusermount -u $FUSE_DIR"

# Synchronizes files to remote file system
RSYNC_CMD="rsync -rltDv --delete $SOURCE_DIR $FULL_BACKUP_PATH"

# Displays a header message
function display_header {

	echo "======================================================================" >> ${LOGFILE}
	echo "Automated Remote SSHFS Backup"					      				  >> ${LOGFILE}
	echo "======================================================================" >> ${LOGFILE}
	echo "Backup Start Time `date`" >> ${LOGFILE}
	echo "======================================================================" >> ${LOGFILE}
	echo >> ${LOGFILE}

}

# Displays a footer message
function display_footer {

	echo >> ${LOGFILE}
	echo "======================================================================" >> ${LOGFILE}
	echo "Automated Remote SSHFS Backup `date`" 				     			  >> ${LOGFILE}
	echo "======================================================================" >> ${LOGFILE}

}

# Sends an email with the logfile
function send_email {

	cat ${LOGFILE} | mail -a "From: $FROM_ADDRESS" -s "$SUBJECT - $DATE" $TO_ADDRESS

}

# Returns true if the remote file system is mounted and false otherwise.
function is_mounted {
	# Determine if the remote file system is mounted
	awk '{print $2}' /etc/mtab | egrep "^$PATTERN$"
	RETVAL=$?
	exit $RETVAL
}

# Determine if the remote file system is mounted. If not, then mount it.
function mount_remote_file_system {

	if [ ! `is_mounted` ]; then
		while [ ! `is_mounted` ]
		do
			echo "Mounting remote file system." >> ${LOGFILE}
			if [ `USE_CUSTOM_SSH_CONFIG` ]; then
				$MOUNT_CMD_KEY
			else
				$MOUNT_CMD_PWD
			fi
		done
		echo "Remote file system mounted." >> ${LOGFILE}
		#sleep 2
	fi

}

# Execute the rsync backup
function run_backup {

	if [ -d "$FULL_BACKUP_PATH" ]; then
		echo "Backup started.." >> ${LOGFILE}
		echo >> ${LOGFILE}
		$RSYNC_CMD >> ${LOGFILE}
		echo >> ${LOGFILE}
		echo "Backup ended." >> ${LOGFILE}
	fi

}

# Unmount the remote directory
function unmount_remote_file_system {

	if [ `is_mounted` ]; then
		echo "Unmounting remote file system." >> ${LOGFILE}
		$UNMOUNT_CMD
	fi

}

# Check if script is already running
function is_already_running {
	
	if pidof -x $(basename $0) > /dev/null; then
		for p in $(pidof -x $(basename $0)); do
			if [ $p -ne $$ ]; then
				echo "Script $0 is already running: exiting"
				exit
			fi
		done
	fi
	
}

# Runs any necessary checks
function initialize {
	
	# Test to make sure the script is not already running
	is_already_running
	
	# Creates a log file directory if one doesn't already exist
	if [ ! -d $LOGDIR ]; then
	        mkdir -p $LOGDIR
	fi
	
}

##########################
# BEGIN SCRIPT EXECUTION #
##########################

initialize
display_header
mount_remote_file_system
run_backup
unmount_remote_file_system
display_footer
send_email

exit 0
