#!/bin/bash

# Build an Android kernel that is actually UEFI disguised as the Kernel
cat ./BootShim/BootShim.bin "./Build/q2qPkg/${_TARGET_BUILD_MODE}_CLANGDWARF/FV/Q2Q_UEFI.fd" > "./Build/q2qPkg/${_TARGET_BUILD_MODE}_CLANGDWARF/FV/Q2Q_UEFI.fd-bootshim"||exit 1
gzip -c < "./Build/q2qPkg/${_TARGET_BUILD_MODE}_CLANGDWARF/FV/Q2Q_UEFI.fd-bootshim" > "./Build/q2qPkg/${_TARGET_BUILD_MODE}_CLANGDWARF/FV/Q2Q_UEFI.fd-bootshim.gz"||exit 1
cat "./Build/q2qPkg/${_TARGET_BUILD_MODE}_CLANGDWARF/FV/Q2Q_UEFI.fd-bootshim.gz" ./ImageResources/DTBs/q2q.dtb > ./ImageResources/bootpayload.bin||exit 1

# Create bootable Android boot.img
python3 ./ImageResources/mkbootimg.py \
  --kernel ./ImageResources/bootpayload.bin \
  --ramdisk ./ImageResources/ramdisk \
  --kernel_offset 0x00000000 \
  --ramdisk_offset 0x00000000 \
  --tags_offset 0x00000000 \
  --os_version 13.0.0 \
  --os_patch_level "$(date '+%Y-%m')" \
  --header_version 1 \
  -o boot.img \
  ||_error "\nFailed to create Android Boot Image!\n"

# Compress Boot Image in a tar File for Odin/heimdall Flash
tar -c boot.img -f Mu-q2q.tar||exit 1
mv boot.img Mu-q2q.img||exit 1
