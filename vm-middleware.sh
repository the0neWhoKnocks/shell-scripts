#!/bin/bash

######################################################################
#                                                                    #
# [ Installation ]                                                   #
#                                                                    #
# I created a dir in my home dir called "sh" (for shell scripts).    #
# With that in mind, you can add the attached script in the sh dir,  #
# and add the below line to your .bashrc or .zshrc file.             #
#                                                                    #
# source ~/sh/vm-middleware.sh                                       #
#                                                                    #
######################################################################

[[ $- == *m* ]] && monitorEnabled=1 || monitorEnabled=0

##
# Checks a couple of the adapters for the non-NAT value
function getVMIP () {
  echo $(VBoxManage guestproperty enumerate "$1" | grep -E "Net/(0|1)/V4/IP, value: 192" | awk -F, '{split($2,_," "); print _[2]}')
}

##
# Starts the VM if it's not already running
function startVM () {
  # disable monitor mode
  if [ monitorEnabled ]; then
    set +m
  fi
  
  local vmName=""
  local headless=""
  local isRunning=$(VBoxManage list runningvms | grep "$VM_NAME")
  
  while [[ "$*" ]]; do
    case $1 in
      "-h"|"--headless")
        local headless=('--type' 'headless') # has to be Array so a var can be inserted in the command
        shift 1;
      ;;
      "-n"|"--name")
        local vmName="$2";
        shift 2;
      ;;
      *)
        shift 1;
      ;;
    esac
  done
  
  if [[ "$vmName" == "" ]]; then 
    echo "[ERROR] No VM name was provided."
    echo "        Example: \`startvm -h -n \"VM Name\"\`"
    echo;
    echo "Here's a list of VM's you can start:"
    echo;
    echo "-------------------------------------------"
    echo;
    
    VBoxManage list vms
    
    return 0
  fi
  
  # If VM isn't running boot it up
  if [[ "$isRunning" == "" ]]; then
    printf '%s\r' " Booting [ ]"
    VBoxManage startvm "$vmName" $headless > /dev/null # quiet the output
    ( msgProcess "Booting" ) &
    bootingVM $! "$vmName"
  else
    local VM_IP=$(getVMIP "$vmName")
    echo "'$vmName' is already running @ $VM_IP"
  fi
}
alias startvm="startVM"

##
# Stop the VM if it's not already stopped
function stopVM () {
  # disable monitor mode
  if [ monitorEnabled ]; then
    set +m
  fi
  
  local vmName=""
  local isRunning=$(VBoxManage list runningvms | grep "$VM_NAME")
  
  while [[ "$*" ]]; do
    case $1 in
      "-n"|"--name")
        local vmName="$2";
        shift 2;
      ;;
      *)
        shift 1;
      ;;
    esac
  done
  
  if [[ "$vmName" == "" ]]; then 
    echo "[ERROR] No VM name was provided."
    echo "        Example: \`stopvm -n \"VM Name\"\`"
    echo;
    echo "Here's a list of VM's you can stop:"
    echo;
    echo "-------------------------------------------"
    echo;
    
    VBoxManage list vms
    
    return 0
  fi
  
  if [[ "$isRunning" != "" ]]; then
    VBoxManage controlvm "$vmName" acpipowerbutton
    ( msgProcess "Stopping" ) &
    stoppingVM $! "$vmName"
  else
    local VM_IP=$(getVMIP "$vmName")
    echo "'$vmName' wasn't running"
  fi
}
alias stopvm="stopVM"

##
# Incrementally checks if the VM is up and running
function bootingVM () {
  local SUB_SHELL_PID=$1
  local VM_NAME=$2
  
  sleep 3
  local VM_IP=$(getVMIP "$VM_NAME")
  
  if [[ "$VM_IP" == "" ]]; then
    bootingVM $SUB_SHELL_PID "$VM_NAME"
    return 0
  fi
  
  kill $SUB_SHELL_PID # stop the loading message
  wait $SUB_SHELL_PID # wait til it's dead so monitor messages don't kick in
  echo "'$VM_NAME' is running @ $VM_IP"
  
  # enable monitor mode
  if [ monitorEnabled ]; then
    set -m
  fi
}

##
# Incrementally checks if the VM has stopped
function stoppingVM () {
  local SUB_SHELL_PID=$1
  local VM_NAME=$2
  
  sleep 2
  vmFound=$(VBoxManage list runningvms | grep "$VM_NAME")
  
  if [[ "$vmFound" != "" ]]; then
    stoppingVM $SUB_SHELL_PID "$VM_NAME"
    return 0
  fi
  
  kill $SUB_SHELL_PID # stop the loading message
  wait $SUB_SHELL_PID # wait til it's dead so monitor messages don't kick in
  echo "'$VM_NAME' has stopped."
  
  # enable monitor mode
  if [ monitorEnabled ]; then
    set -m
  fi
}

##
# Displays a message so the user knows things haven't hung
function msgProcess() {
  set +m # disables `monitor mode` in case it's enabled
  
  local -a marks=( '[/]     ' '[—] .   ' '[—] ..  ' '[\] ... ' '[|] ....' '[ ]     ' )
  [[ "$1" == "" ]] && local msg="Loading" || local msg="$1"
  
  # if file exists & value in file is false
  while true; do    
    printf '%s\r' " $msg ${marks[i++ % ${#marks[@]}]}"
    sleep 0.02
  done
}
