#!/bin/sh

DIR=$1


MODE=$(grep "^usb_functionfs_mode" /etc/umtprd/umtprd.conf | tr -s " " | cut -d " " -f 2)

if [ "$MODE" == "0x0" ]
then
    # Gadget FS
    modprobe gadgetfs

    # Mount gadgetfs

    mountpoint -q /dev/gadget
    MOUNTED=$?
    if [ "$MOUNTED" != "0" ] ; then
        mkdir /dev/gadget
        mount -t gadgetfs gadgetfs /dev/gadget
    fi
else
    # Function FS
    UDC_MAX_POWER=${UDC_MAX_POWER:-500}

    [ -e ${DIR} ] && exit 0

    # FunctionFS uMTPrd startup example/test script
    # Must be launched from a writable/temporary folder.

    modprobe libcomposite

    mkdir -p ${DIR}
    cd ${DIR}

    mkdir cfg
    mount none cfg -t configfs

    mkdir cfg/usb_gadget/g1
    cd cfg/usb_gadget/g1

    mkdir configs/c.1

    mkdir functions/ffs.mtp
    # Uncomment / Change the follow line to enable another usb gadget function
    #mkdir functions/acm.usb0

    mkdir strings/0x409
    mkdir configs/c.1/strings/0x409

    grep "^usb_product_id" /etc/umtprd/umtprd.conf | tr -s " " | cut -d " " -f 2 > idProduct
    grep "^usb_vendor_id" /etc/umtprd/umtprd.conf | tr -s " " | cut -d " " -f 2 > idVendor
    grep "^serial" /etc/umtprd/umtprd.conf | sed "s/serial //g" | sed "s/\"//g" > strings/0x409/serialnumber
    grep "^manufacturer" /etc/umtprd/umtprd.conf | sed "s/manufacturer //g" | sed "s/\"//g" > strings/0x409/manufacturer
    grep "^product" /etc/umtprd/umtprd.conf | sed "s/product //g" | sed "s/\"//g" > strings/0x409/product

    echo "Conf 1" > configs/c.1/strings/0x409/configuration
    echo ${UDC_MAX_POWER} > configs/c.1/MaxPower

    ln -s functions/ffs.mtp configs/c.1
    # Uncomment / Change the follow line to enable another usb gadget function
    #ln -s functions/acm.usb0 configs/c.1

    mkdir /dev/ffs-mtp
    mount -t functionfs mtp /dev/ffs-mtp
fi
