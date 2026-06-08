*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZFI_F01_CTA_DET.................................*
DATA:  BEGIN OF STATUS_ZFI_F01_CTA_DET               .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZFI_F01_CTA_DET               .
CONTROLS: TCTRL_ZFI_F01_CTA_DET
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZFI_F01_CTA_DET               .
TABLES: ZFI_F01_CTA_DET                .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
