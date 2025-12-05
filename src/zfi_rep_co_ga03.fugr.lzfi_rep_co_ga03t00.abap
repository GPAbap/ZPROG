*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZFI_REP_CO_GA03.................................*
DATA:  BEGIN OF STATUS_ZFI_REP_CO_GA03               .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZFI_REP_CO_GA03               .
CONTROLS: TCTRL_ZFI_REP_CO_GA03
            TYPE TABLEVIEW USING SCREEN '0001'.
*...processing: ZFI_REP_CO_GAX..................................*
DATA:  BEGIN OF STATUS_ZFI_REP_CO_GAX                .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZFI_REP_CO_GAX                .
CONTROLS: TCTRL_ZFI_REP_CO_GAX
            TYPE TABLEVIEW USING SCREEN '0002'.
*.........table declarations:.................................*
TABLES: *ZFI_REP_CO_GA03               .
TABLES: *ZFI_REP_CO_GAX                .
TABLES: ZFI_REP_CO_GA03                .
TABLES: ZFI_REP_CO_GAX                 .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
