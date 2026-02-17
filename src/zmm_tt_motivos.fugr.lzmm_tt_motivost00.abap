*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZMM_TT_MOTIVOS..................................*
DATA:  BEGIN OF STATUS_ZMM_TT_MOTIVOS                .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZMM_TT_MOTIVOS                .
CONTROLS: TCTRL_ZMM_TT_MOTIVOS
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZMM_TT_MOTIVOS                .
TABLES: ZMM_TT_MOTIVOS                 .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
