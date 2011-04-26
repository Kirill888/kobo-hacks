#!/bin/sh

#How often to query BT device
SLEEP_TIME=30

# getty command
#   busybox shipped with kobo does not have getty command
#   so we need our own
#   No need to login in just run shell straight away
GETTY="/bin2/busybox getty -n 38400 /dev/rfcomm0 -l /bin/sh"
# if you want login prompt use this
#GETTY="/bin2/busybox getty 38400 /dev/rfcomm0"

if [ $# -lt 1 ] ; then
  echo "Need BT address"
  exit 1
fi

#bluetooth address to connect to
PC_BT_ADDR=$1

#####################################
# Some functions we need
#####################################

#This function tries upto 10 times to establish connection
# To your PC via bluetooth
rfcomm_loop () {
  cc=0
  while ! rfcomm connect 0 ${PC_BT_ADDR} 1 > /dev/null 2>&1 ; do
    cc=$(( $cc + 1 ))
    if [[ $cc -gt 10 ]]; then
       echo "Too many failed attempts, aborting"
       return 1
    fi
    echo "retrying in 3 seconds"
    sleep 3
  done

  return $?
}

tty_loop () {
 #While we still have rfcomm0
 #  start getty sevice on it
 while rfcomm show rfcomm0 > /dev/null 2>&1 ; do
  $GETTY
 done

 return 0
}

######################################
#  Script starts here
######################################

#Wait for user to enable bluetooth
cc=0
while ! hciconfig hci0 > /dev/null 2>&1 ; do
  cc=$(( $cc + 1 ))
  if [[ $cc -gt 100 ]] ; then
    echo "User didn't enable bluetooth, giving up"
    exit 1
  fi
  echo "waiting for bluetooth..."
  sleep $SLEEP_TIME
done

echo "Have hci0"
hciconfig -a hci0

#Launch rfcomm
sleep 2
echo "Attempting to connect to:" ${PC_BT_ADDR}
rfcomm_loop > /dev/null 2>&1 &

sleep 5
cc=0
#Wait for rfcomm to come up
while ! rfcomm show rfcomm0 > /dev/null 2>&1 ; do 
  cc=$(( $cc + 1 ))
  if [[ $cc -gt 20 ]] ; then
    echo "Failed to get rfcomm0 connection"
    exit 1
  fi
  echo "Waiting for rfcomm0 connection"
  sleep 5
done

echo "Have rfcomm0"
rfcomm show rfcomm0

echo "Launching tty loop"
tty_loop




