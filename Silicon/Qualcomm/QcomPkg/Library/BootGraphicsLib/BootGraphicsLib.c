/**
  This BootGraphicsLib is only Intended to be used by BDS to Draw
  and the Main Boot Graphics to the Screen.

  Implementation Borrows from EDK2 BootLogoLib.

  Copyright (c) 2011 - 2018, Intel Corporation. All rights reserved.<BR>
  Copyright (C) Microsoft Corporation. All rights reserved.<BR>

  SPDX-License-Identifier: BSD-2-Clause-Patent
**/

#include <Library/UefiBootServicesTableLib.h>
#include <Library/PcdLib.h>
#include <Library/DebugLib.h>
#include <Library/MemoryAllocationLib.h>
#include <Library/BootGraphicsProviderLib.h>
#include <Library/DisplayDeviceStateLib.h>
#include <Library/BmpSupportLib.h>
#include <Library/UefiLib.h>

#include <Protocol/GraphicsOutput.h>
#include <Protocol/BootLogo2.h>

#define MS_MAX_HEIGHT_PERCENTAGE  40
#define MS_MAX_WIDTH_PERCENTAGE   40

EFI_STATUS
EFIAPI
DisplayBootGraphic (BOOT_GRAPHIC Graphic)
{
  EFI_STATUS                     Status         = EFI_SUCCESS;
  UINTN                          Height         = 0;
  UINTN                          Width          = 0;
  UINT32                         SizeOfX        = 0;
  UINT32                         SizeOfY        = 0;
  INTN                           DestX          = 0;
  INTN                           DestY          = 0;
  UINT8                         *ImageData      = NULL;
  UINTN                          ImageSize      = 0;
  UINT32                         Color          = 0;
  EFI_GRAPHICS_OUTPUT_BLT_PIXEL *Blt            = NULL;
  UINTN                          BltSize        = 0;
  EFI_GRAPHICS_OUTPUT_PROTOCOL  *GraphicsOutput = NULL;
  EDKII_BOOT_LOGO2_PROTOCOL     *BootLogo2      = NULL;

  // Locate Console Out Handle Protocol
  Status = gBS->HandleProtocol (gST->ConsoleOutHandle, &gEfiGraphicsOutputProtocolGuid, (VOID **)&GraphicsOutput);
  if (EFI_ERROR (Status)) {
    DEBUG ((EFI_D_ERROR, "%a: Failed to Locate Graphics Out Handle Protocol! Status = %r\n", __FUNCTION__, Status));

    // Locate the GOP Protocol
    Status = gBS->LocateProtocol (&gEfiGraphicsOutputProtocolGuid, NULL, (VOID **)&GraphicsOutput);
    if (EFI_ERROR (Status)) {
      DEBUG ((EFI_D_ERROR, "%a: Failed to Locate GOP Protocol! Status = %r\n", __FUNCTION__, Status));
      goto CleanUp;
    }
  }

  // Locate EDK2 Boot Logo 2 Protocol
  Status = gBS->LocateProtocol (&gEdkiiBootLogo2ProtocolGuid, NULL, (VOID **)&BootLogo2);
  if (EFI_ERROR (Status)) {
    DEBUG ((EFI_D_ERROR, "%a: Failed to Locate BootLogo2 Protocol! Status = %r\n", __FUNCTION__, Status));
  }

  // Erase Curser
  if (gST->ConOut != NULL) {
    gST->ConOut->EnableCursor (gST->ConOut, FALSE);
  }

  SizeOfX = GraphicsOutput->Mode->Info->HorizontalResolution;
  SizeOfY = GraphicsOutput->Mode->Info->VerticalResolution;
  Color   = GetBackgroundColor ();

  // Color the Background
  Blt = (EFI_GRAPHICS_OUTPUT_BLT_PIXEL *)(&Color);
  GraphicsOutput->Blt (GraphicsOutput, Blt, EfiBltVideoFill, 0, 0, 0, 0, SizeOfX, SizeOfY, 0);
  Blt = NULL;

  // Show the Device State
  DisplayDeviceState ((INT32)SizeOfX, (INT32)SizeOfY);

  // Get the Requested Boot Graphic
  Status = GetBootGraphic (Graphic, &ImageSize, &ImageData);
  if (EFI_ERROR (Status)) {
    DEBUG ((EFI_D_ERROR, "%a: Failed Get Boot Graphic! Status = %r\n", __FUNCTION__, Status));
    goto CleanUp;
  }

  // Convert BMP to GOP Blt
  Status = TranslateBmpToGopBlt (ImageData, ImageSize, &Blt, &BltSize, &Height, &Width);
  if (EFI_ERROR (Status)) {
    DEBUG ((EFI_D_ERROR, "%a: Failed to Translate BMP to Blt! Status = %r\n", __FUNCTION__, Status));
    goto CleanUp;
  }

  if (Graphic == BG_SYSTEM_LOGO) {
    if ((Width > ((SizeOfX * MS_MAX_WIDTH_PERCENTAGE) / 100)) || (Height > ((SizeOfY * MS_MAX_HEIGHT_PERCENTAGE) / 100))) {
      Status = EFI_INVALID_PARAMETER;
      goto CleanUp;
    }
  }

  DestX = (SizeOfX - Width) / 2;
  DestY = (SizeOfY - Height) / 2;

  // Display Boot Graphic on the Screen
  if ((DestX >= 0) && (DestY >= 0)) {
    Status = GraphicsOutput->Blt (GraphicsOutput, Blt, EfiBltBufferToVideo, 0, 0, (UINTN)DestX, (UINTN)DestY, Width, Height, Width * sizeof (EFI_GRAPHICS_OUTPUT_BLT_PIXEL));
    if (EFI_ERROR (Status)) {
      DEBUG ((EFI_D_ERROR, "%a: Failed to Display Boot Graphic! Status = %r\n", __FUNCTION__, Status));
      goto CleanUp;
    }
  } else {
    goto CleanUp;
  }

  // Register Logo to the EDK2 Boot Logo 2 Protocol
  if ((Graphic == BG_SYSTEM_LOGO) && (BootLogo2 != NULL)) {
    Status = BootLogo2->SetBootLogo (BootLogo2, Blt, DestX, DestY, Width, Height);
    if (EFI_ERROR (Status)) {
      DEBUG ((EFI_D_ERROR, "%a: Failed to Set Boot Logo in BootLogo2 Protocol! Status = %r\n", __FUNCTION__, Status));
    }
  }

  // Signal that the Boot Graphic is Displayed
  EfiEventGroupSignal (&gLogoDisplayedEventGroup);

  Status = EFI_SUCCESS;

CleanUp:
  if (Blt != NULL) {
    FreePool (Blt);
  }

  if (ImageData != NULL) {
    FreePool (ImageData);
  }

  return Status;
}
