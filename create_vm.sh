#!/bin/bash -e
# This code should (try to) follow Google's Shell Style Guide
# (https://google-styleguide.googlecode.com/svn/trunk/shell.xml)
# Author: Huiyugeng

TEMPLATE_BASE=/opt/template
VM_BASE=/opt/vm

UBUNTU=ubuntu_14.04.3
CENTOS=centos_7.2
WINDOWS=windows_2008

VM_NAME=$1
OS_TYPE=$2
HOST_NAME=$3
VCPU=$4
MEM_SIZE=$5
DISK_SIZE=$6
IP_ADDRESS=$7
NETMASK=$8
GATEWAY=$9
DNS=${10}
MAC_ADDRESS=${11}

VM_PATH=$VM_BASE/$VM_NAME
VM_IMG_FILE=$VM_PATH/$VM_NAME.img
VM_CFG_FILE=$VM_PATH/$VM_NAME.xml

PKG_LIST=("qemu-img" "virsh" "virt-copy-in")

for PKG in ${PKG_LIST[@]}; do
    which $PKG > /dev/null
    if [ $? == 0 ]; then
        echo "$PKG already installed"
    else
        echo "$PKG not install"
        exit 1
    fi
done

if [ ! -d "$VM_PATH" ] ; then
    if ! mkdir -p "$VM_PATH" ; then
        log_failure_msg "can't create $VM_PATH"
        exit 1
    fi
fi

if  [  -d "$VM_PATH" ] ; then
    if [ $OS_TYPE = "NEW" ] ; then
        echo "qemu-img create -f qcow2 $VM_PATH/$VM_NAME.img "$DISK_SIZE"G"
    else
        case $2 in
        ubuntu)
            OS_TYPE=$UBUNTU
            ;;
        centos)
            OS_TYPE=$CENTOS
            ;;
        windows)
            OS_TYPE=$WINDOWS
            ;;
        *)
        log_failure_msg "can't create $VM_NAME"
        exit 1
            ;;
        esac
        qemu-img create -f qcow2 -o backing_file=$TEMPLATE_BASE/$OS_TYPE/$OS_TYPE.img,size="$DISK_SIZE"G $VM_IMG_FILE
        if [ $? == 0 ]; then
            echo "$VM_NAME create disk successful"
        else
            echo "$VM_NAME create disk fail"
            exit 1
        fi        
        cp $TEMPLATE_BASE/$OS_TYPE/$OS_TYPE.xml $VM_CFG_FILE

    fi
else
    log_failure_msg "can't find VM directory $VM_PATH"
    exit 1
fi

if [ -f "$VM_CFG_FILE" ] ; then
    sed -i 's/<name>.*<\/name>/<name>'$VM_NAME'<\/name>/g' $VM_CFG_FILE
    sed -i 's/<memory unit="MiB">.*<\/memory>/<memory unit="MiB">'$MEM_SIZE'<\/memory>/g' $VM_CFG_FILE
    sed -i 's/<currentMemory unit="MiB">.*<\/currentMemory>/<currentMemory unit="MiB">'$MEM_SIZE'<\/currentMemory>/g' $VM_CFG_FILE
    sed -i 's/<vcpu>.*<\/vcpu>/<vcpu>'$VCPU'<\/vcpu>/g' $VM_CFG_FILE
    sed -i 's/<source file=".*" \/>/<source file="'$(echo "$VM_IMG_FILE" | sed -e 's/\//\\\//g')'" \/>/g' $VM_CFG_FILE

    if  [ -n "$MAC_ADDRESS" ] ; then
        sed -i 's/<mac address=".*" \/>/<mac address="'$MAC_ADDRESS'" \/>/g' $VM_CFG_FILE
    else
        sed -i '/<mac address=".*" \/>/d' $VM_CFG_FILE
    fi
    

else
    log_failure_msg "can't find libvirt configurtion file $VM_CFG_FILE"
    exit 1
fi

virsh define $VM_CFG_FILE
if [ $? == 0 ]; then
    echo "$VM_NAME define successful"
else
    echo "$VM_NAME define fail"
    exit 1
fi

case $2 in
ubuntu)
    cp -R $TEMPLATE_BASE/$OS_TYPE/etc $VM_PATH/etc
    echo $HOST_NAME > $VM_PATH/etc/hostname

    INTERFACE_CFG=$VM_PATH/etc/network/interfaces
    if [ -n "$IP_ADDRESS" ] ; then
        sed -i 's/address.*/address\t'$IP_ADDRESS'/g' $INTERFACE_CFG
        sed -i 's/netmask.*/netmask\t'$NETMASK'/g' $INTERFACE_CFG
        sed -i 's/gateway.*/gateway\t'$GATEWAY'/g' $INTERFACE_CFG
    fi

    HOST_CFG=$VM_PATH/etc/hosts
    sed -i 's/127.0.0.1.*/127.0.0.1\tlocalhost,'$HOST_NAME'/g' $HOST_CFG
    sed -i 's/127.0.1.1.*/127.0.1.1\t'$HOST_NAME'/g' $HOST_CFG

    DNS_CFG=$VM_PATH/etc/resolvconf/resolv.conf.d/base
    if [ -z "$DNS" ] ; then
        DNS=8.8.8.8
    fi
    awk 'BEGIN{
            dns="'$DNS'";
            slen=split(dns,item,",");
            for(i=1;i<=slen;i++){
                print "nameserver",item[i];
            }
        }' > $DNS_CFG
        
    virt-copy-in -d $VM_NAME $VM_PATH/etc /
    if [ $? == 0 ]; then
        echo "$VM_NAME configue successful"
    else
        echo "$VM_NAME configue fail"
        exit 1
    fi
    ;;
centos)
    OS_TYPE=$CENTOS
    ;;
*)
    echo "can't configure $VM_NAME($OS_TYPE)"
    exit 0
    ;;
esac
