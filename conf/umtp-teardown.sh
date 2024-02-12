#!/bin/sh

DIR=$1
[ -z "${DIR}" ] && exit -1

MODE=$(grep "^usb_functionfs_mode" /etc/umtprd/umtprd.conf | tr -s " " | cut -d " " -f 2)

if [ "$MODE" == "0x0" ]
then
    umount /dev/gadget
else
    echo > ${DIR}/cfg/usb_gadget/g1/UDC
    umount /tmp/umtprd/cfg
    umount /dev/ffs-mtp
    rm -rf /tmp/umtprd
fi
