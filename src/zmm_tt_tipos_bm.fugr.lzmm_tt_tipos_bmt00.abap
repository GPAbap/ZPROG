*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZMM_TT_TIPOS_BM.................................*
DATA:  BEGIN OF STATUS_ZMM_TT_TIPOS_BM               .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZMM_TT_TIPOS_BM               .
CONTROLS: TCTRL_ZMM_TT_TIPOS_BM
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZMM_TT_TIPOS_BM               .
TABLES: ZMM_TT_TIPOS_BM                .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
