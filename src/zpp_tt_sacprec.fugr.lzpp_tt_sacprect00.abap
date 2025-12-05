*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZPP_TT_SACPREC..................................*
DATA:  BEGIN OF STATUS_ZPP_TT_SACPREC                .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZPP_TT_SACPREC                .
CONTROLS: TCTRL_ZPP_TT_SACPREC
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZPP_TT_SACPREC                .
TABLES: ZPP_TT_SACPREC                 .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
