#!/bin/bash



if [[ $# -ne 3 && $1 == "-help" ]]
then
    echo "$0 [Test Site like www.example.com] [Test Packet Size] [No. of Ping Tests]"
    echo "$0 -help for help/usage"
    exit 0
fi

if [ $# -lt 3 ]
then
  echo "$0 : Insufficient Arguments"
  echo "$0 [Test Site like www.example.com] [Test Packet Size] [No. of Ping Tests for each packet size]"
  echo "Default $0 www.facebook.com 1472 10 is being used."
  PKT_SIZE=1472
  HOSTNAME="www.facebook.com"
  ITERATIONS=10
else
  PKT_SIZE=$2
  HOSTNAME="$1"
  ITERATIONS=$3
fi

recvd_pkt_count=`ping -M do -c $ITERATIONS -s $PKT_SIZE $HOSTNAME 2>/dev/null |grep 'packet loss'|cut -f 2 -d ","|cut -f 2 -d " "`

#count=`ping -M do -c 1 -s $PKT_SIZE $HOSTNAME | grep -c "Frag needed"`

while [ $recvd_pkt_count -lt $ITERATIONS ]; do
 echo "Tried $PKT_SIZE as MTU, but received $recvd_pkt_count out of $ITERATIONS packets. Trying a lower value of MTU..."
 #((PKT_SIZE--))
 PKT_SIZE=$((PKT_SIZE - ${ITERATIONS}))
 recvd_pkt_count=$((`ping -M do -c $ITERATIONS -s $PKT_SIZE $HOSTNAME 2>/dev/null |grep 'packet loss'|cut -f 2 -d ","|cut -f 2 -d " "`))
done

printf "Your Maximum MTU is [ $((PKT_SIZE + 28)) ] \n"