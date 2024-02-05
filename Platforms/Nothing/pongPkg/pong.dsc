## @file
#
#  Copyright (c) 2011-2015, ARM Limited. All rights reserved.
#  Copyright (c) 2014, Linaro Limited. All rights reserved.
#  Copyright (c) 2015 - 2016, Intel Corporation. All rights reserved.
#  Copyright (c) 2018, Bingxing Wang. All rights reserved.
#
#  SPDX-License-Identifier: BSD-2-Clause-Patent
#
##

################################################################################
#
# Defines Section - statements that will be processed to create a Makefile.
#
################################################################################
[Defines]
  PLATFORM_NAME                  = pong
  PLATFORM_GUID                  = ffb2bbdd-8d34-4cb1-af89-ee56df3c5a68
  PLATFORM_VERSION               = 0.1
  DSC_SPECIFICATION              = 0x00010005
  OUTPUT_DIRECTORY               = Build/pongPkg
  SUPPORTED_ARCHITECTURES        = AARCH64
  BUILD_TARGETS                  = RELEASE|DEBUG
  SKUID_IDENTIFIER               = DEFAULT
  FLASH_DEFINITION               = pongPkg/pong.fdf
  DISPLAY_USES_RGBA              = 0
  USE_DISPLAYDXE                 = 0
  AB_SLOT_SUPPORT                = 1

  # 0 = SM8450
  # 1 = SM8475
  SOC_TYPE                       = 1

[BuildOptions.common]
  *_*_*_CC_FLAGS = -DSOC_TYPE=$(SOC_TYPE)

[LibraryClasses.common]
  DeviceMemoryMapLib|pongPkg/Library/DeviceMemoryMapLib/DeviceMemoryMapLib.inf
  DeviceConfigurationMapLib|pongPkg/Library/DeviceConfigurationMapLib/DeviceConfigurationMapLib.inf

[PcdsFixedAtBuild.common]
  gArmTokenSpaceGuid.PcdSystemMemoryBase|0x80000000	# Starting address
  gArmTokenSpaceGuid.PcdSystemMemorySize|0x00C00000	# <RAM Size> GB Size

  gEfiMdeModulePkgTokenSpaceGuid.PcdFirmwareVendor|L"JIaxyga" # Device Maintainer

  gArmTokenSpaceGuid.PcdCpuVectorBaseAddress|0xA7600000

  gEmbeddedTokenSpaceGuid.PcdPrePiStackBase|0xA760D000
  gEmbeddedTokenSpaceGuid.PcdPrePiStackSize|0x00040000           # 256K stack

  # SmBios
  gQcomPkgTokenSpaceGuid.PcdSmbiosSystemVendor|"Nothing"
  gQcomPkgTokenSpaceGuid.PcdSmbiosSystemModel|"Phone 2"
  gQcomPkgTokenSpaceGuid.PcdSmbiosSystemRetailModel|"pong"
  gQcomPkgTokenSpaceGuid.PcdSmbiosSystemRetailSku|"Phone 2_pong"
  gQcomPkgTokenSpaceGuid.PcdSmbiosBoardModel|"Phone 2"

  # Simple FrameBuffer
  gQcomPkgTokenSpaceGuid.PcdMipiFrameBufferWidth|1080
  gQcomPkgTokenSpaceGuid.PcdMipiFrameBufferHeight|2412
  gQcomPkgTokenSpaceGuid.PcdMipiFrameBufferColorDepth|32

[PcdsDynamicDefault.common]
  gEfiMdeModulePkgTokenSpaceGuid.PcdVideoHorizontalResolution|1080
  gEfiMdeModulePkgTokenSpaceGuid.PcdVideoVerticalResolution|2412
  gEfiMdeModulePkgTokenSpaceGuid.PcdSetupVideoHorizontalResolution|1080
  gEfiMdeModulePkgTokenSpaceGuid.PcdSetupVideoVerticalResolution|2412
  gEfiMdeModulePkgTokenSpaceGuid.PcdSetupConOutColumn|135
  gEfiMdeModulePkgTokenSpaceGuid.PcdSetupConOutRow|127
  gEfiMdeModulePkgTokenSpaceGuid.PcdConOutColumn|135
  gEfiMdeModulePkgTokenSpaceGuid.PcdConOutRow|127

!include SM8450Pkg/SM8450Pkg.dsc.inc
