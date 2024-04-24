#!/bin/bash

### CHECK TO SEE IF resticron_config.sh EXISTS, GENERATE, EMAIL, AND EXIT IF NOT

#only works if you navigate to the correct folder before running
if [ ! -f "resticron_config.sh" ]; then
  echo "#!/bin/bash" > resticron_config.sh
  echo "" >> resticron_config.sh
  echo "#Notes: repository must already be set up, and restic must be able to back up to it without user interaction. Note this will require -p for the password" >> resticron_config.sh
  echo "" >> resticron_config.sh
  echo "email=root  #default: root, or change to either email address or user" >> resticron_config.sh
  echo "send_email_start=\"yes\"  # can be \"yes\" or \"no\"" >> resticron_config.sh
  echo "send_email_error=\"yes\"  # can be \"yes\" or \"no\"" >> resticron_config.sh
  echo "send_email_success=\"yes\"  # can be \"yes\" or \"no\"" >> resticron_config.sh
  echo "" >> resticron_config.sh
  echo "log_file=\"resticron.log\"  #default: resticron.log" >> resticron_config.sh
  echo "" >> resticron_config.sh
  echo "restic_backup_command_1=\"\" #insert full restic backup command here in quotes, don't forget to escape any quotes in the command."  >> resticron_config.sh
  echo "restic_backup_command_2=\"\"" >> resticron_config.sh
  echo "restic_prune_command=\"\"" >> resticron_config.sh
  echo "restic_check_command=\"\"" >> resticron_config.sh
  echo "" >> resticron_config.sh
  echo "#restic does not automatically report progress to log, set value for reporting frequency, 1 / length of time in seconds, so 1 is every second, 0.016666 is once per minute." >> resticron_config.sh
  echo "restic_progress_reporting=0.016666   # default: 0.016666" >> resticron_config.sh
  echo "" >> resticron_config.sh
  echo "#indicate if you would like the log cleared at the beginning of each backup" >> resticron_config.sh
  echo "restic_log_clear=\"\"  # can be \"yes\" or \"no\"" >> resticron_config.sh
  echo "resticron_config.sh was not found. A template file was created, please insert the values for all variables and run again." | tee >(mail -s "resticron Setup Necessary" root)
  exit 0
fi

# load variables from resticron_config.sh, assumes resticron.sh and resticron_config.sh are in the same location
. ./resticron_config.sh
export RESTIC_PROGRESS_FPS="$restic_progress_reporting"

### CHECK TO SEE IF ANOTHER INSTANCE IS RUNNING, CLOSE AND SEND EMAIL IF THERE IS

# Count the number of instances of this script running excluding the current instance
# Note: this line will only work if you are running this script as sudo and don't change the process name
num_instances=$(pgrep -cxf "sudo /bin/bash resticron.sh")

# If there's more than one instance running, send error email and exit
if [ "$num_instances" -gt 1 ]; then
      # following line both prints to terminal and sends email
    echo "An instance of resticron was already running when this script was started. If this is unexpected, check that an existing instance has not hung while processing." | tee >(mail -s "resticron ERROR" $email)
    exit 1
fi

#clear log file if restic_log_clear is set to "yes"
if [ $restic_log_clear == "yes" ]; then echo "" > "$log_file"; fi

# send stdout+stderr to log file
exec > >(tee -a "$log_file") 2>&1

### RUN BACKUP 1

#log backup start
echo "$(date "+%Y.%m.%d %H:%M:%S") restic_backup_command_1 started"
if [ $send_email_start == "yes" ]; then mail -s "Restic Backup Command 1 Started" "$email" < "$log_file"; fi


$restic_backup_command_1

  #if exit on error code, send email, else, send success
  if [ "$?" -ne 0 ]; then
    echo "$(date "+%Y.%m.%d %H:%M:%S") restic_backup_command_1 exited with an error code"
    if [ $send_email_error == "yes" ]; then mail -s "Restic Backup Command 1 ERROR" "$email" < "$log_file"; fi
    exit 1
  else
    echo "$(date "+%Y.%m.%d %H:%M:%S") restic_backup_command_1 completed successfully"
    if [ $send_email_success == "yes" ]; then mail -s "Restic Backup Command 1 Success" "$email" < "$log_file"; fi
    exit 0
  fi

### FUTURE LOCATION FOR RUN BACKUP 2

### FUTURE LOCATION FOR PRUNE COMMAND

### FUTURE LOCATION FOR CHECK COMMAND
