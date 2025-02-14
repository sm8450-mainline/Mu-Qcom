#!/bin/bash

# Build an Android kernel that is actually UEFI disguised as the Kernel
cat ./BootShim/BootShim.bin "./Build/lisaPkg/${_TARGET_BUILD_MODE}_CLANGDWARF/FV/LISA_UEFI.fd" > "./Build/lisaPkg/${_TARGET_BUILD_MODE}_CLANGDWARF/FV/LISA_UEFI.fd-bootshim"||exit 1
gzip -c < "./Build/lisaPkg/${_TARGET_BUILD_MODE}_CLANGDWARF/FV/LISA_UEFI.fd-bootshim" > "./Build/lisaPkg/${_TARGET_BUILD_MODE}_CLANGDWARF/FV/LISA_UEFI.fd-bootshim.gz"||exit 1
cat "./Build/lisaPkg/${_TARGET_BUILD_MODE}_CLANGDWARF/FV/LISA_UEFI.fd-bootshim.gz" ./ImageResources/DTBs/lisa.dtb > ./ImageResources/bootpayload.bin||exit 1

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
  -o Mu-lisa.img \
  ||_error "\nFailed to create Android Boot Image!\n"
