#!/bin/bash

### CHECK TO SEE IF resticron_config.sh EXISTS, GENERATE AND EXIT IF NOT

if [ ! -f "resticron_config.sh" ]; then
  echo "#!/bin/bash" > resticron_config.sh
  echo "" >> resticron_config.sh
  echo "email=root  #default: root, or change to either email address or user" >> resticron_config.sh
  echo "resticron_config.sh was not found, so the file was created, please insert the values for all variables and run again." | tee >(mail -s "resticron ERROR" root)
  exit 0
fi

### CHECK TO SEE IF ANOTHER INSTANCE IS RUNNING, CLOSE AND SEND EMAIL IF THERE IS

# Get the process ID (PID) of the current script
current_pid=$$

# Count the number of instances of this script running excluding the current instance (current_pid) from the count
num_instances=$(pgrep -cx "$(basename "$0")")

# If there's more than one instance running (including the current one), exit
if [ "$num_instances" -gt 1 ]; then
      # following line both prints to terminal and sends email
    echo "An instance of resticron was already running when this script was started. If this is unexpected, check that an existing instance has not hung while processing." | tee >(mail -s "resticron ERROR" $email)
    exit 1
fi

### MAIN BODY OF CODE
