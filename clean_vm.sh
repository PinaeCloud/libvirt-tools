#!/bin/bash -e
# This code should (try to) follow Google's Shell Style Guide
# (https://google-styleguide.googlecode.com/svn/trunk/shell.xml)
# Author: Huiyugeng

VM_BASE=/opt/vm

VM_NAME=$1
CLEAN_IMAGES=$2

VM_PATH=$VM_BASE/$VM_NAME

PKG_LIST=("virsh")

for PKG in ${PKG_LIST[@]}; do
    which $PKG > /dev/null
    if [ $? == 0 ]; then
        echo "$PKG already installed"
    else
        echo "$PKG not install"
        exit 1
    fi
done

virsh domstate $VM_NAME > /dev/null
if [ $? == 0 ]; then
    STATE=$(virsh domstate $VM_NAME)
    if [ "$STATE" = "running" ] || [ "$STATE" = "paused" ]; then
        virsh destroy $VM_NAME
        if [ $? == 0 ]; then
            echo "$VM_NAME destroy successful"
        else
            echo "$VM_NAME destroy fail"
            exit 1
        fi
    fi

    virsh undefine $VM_NAME
    if [ $? == 0 ]; then
        echo "$VM_NAME undefine successful"
    else
        echo "$VM_NAME undefine fail"
        exit 1
    fi
fi



if [ "$CLEAN_IMAGES" = "--with-images" ]; then
    rm -rf $VM_PATH
    if [ ! -d $VM_PATH ]; then
        echo "$VM_NAME images remove successful"
    else
        echo "$VM_NAME images remove fail"
    fi
fi
