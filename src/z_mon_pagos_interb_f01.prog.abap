************************************************************************
*                                                                      *
*            ********************************************              *
*            *   Confidential and Proprietary           *              *
*            *   XAMAI S.A. de C.V.                     *              *
*            *   All Rights Reserved                    *              *
*            ********************************************              *
*                                                                      *
************************************************************************
* Programa principal  :  ZMONITOR_ALTA_PROV_BBVA_H2H                   *
* Titulo              :  Include de procesamiento                      *
*                                                                      *
* Programador         : David Del Valle Mendoza                        *
* Fecha               : VIII.2020                                      *
************************************************************************
*&---------------------------------------------------------------------*
*&  Include           ZMON_ALTA_PAGOS_F01
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  F_ARMA_CATALOGO
*&---------------------------------------------------------------------*
FORM F_ARMA_CATALOGO .

clear:   WA_FLDCAT, IT_FLDCAT.
refresh: IT_FLDCAT.


*  CLEAR ZPOS.
*  ZPOS = 1.
*
*  WA_FLDCAT-SELTEXT = WA_FLDCAT-REPTEXT = WA_FLDCAT-SCRTEXT_S = WA_FLDCAT-SCRTEXT_M = WA_FLDCAT-SCRTEXT_L = TEXT-H01.
*  WA_FLDCAT-FIELDNAME = 'SEL'.
*  WA_FLDCAT-TABNAME   = 'ZH2H_BBVA_PROV'.
*  WA_FLDCAT-CHECKBOX = 'X'.
*  WA_FLDCAT-EDIT = 'X'.
*  WA_FLDCAT-OUTPUTLEN = '9'.
*  WA_FLDCAT-COL_POS = ZPOS.
*  ADD 1 TO ZPOS.
*  APPEND WA_FLDCAT TO IT_FLDCAT.
*  CLEAR WA_FLDCAT.
*
*  WA_FLDCAT-SELTEXT = WA_FLDCAT-REPTEXT = WA_FLDCAT-SCRTEXT_S = WA_FLDCAT-SCRTEXT_M = WA_FLDCAT-SCRTEXT_L = TEXT-H02.
*  WA_FLDCAT-FIELDNAME = 'STATUS'.
*  WA_FLDCAT-TABNAME   = 'ZH2H_BBVA_PROV'.
*  WA_FLDCAT-OUTPUTLEN = '5'.
*  WA_FLDCAT-COL_POS = ZPOS.
*  ADD 1 TO ZPOS.
*  APPEND WA_FLDCAT TO IT_FLDCAT.
*  CLEAR WA_FLDCAT.
*
*  WA_FLDCAT-SELTEXT = WA_FLDCAT-REPTEXT = WA_FLDCAT-SCRTEXT_S = WA_FLDCAT-SCRTEXT_M = WA_FLDCAT-SCRTEXT_L = TEXT-H03.
*  WA_FLDCAT-FIELDNAME = 'BUKRS'.
*  WA_FLDCAT-TABNAME   = 'ZH2H_BBVA_PROV'.
*  WA_FLDCAT-KEY = 'X'.
*  WA_FLDCAT-OUTPUTLEN = '10'.
*  WA_FLDCAT-COL_POS = ZPOS.
*  ADD 1 TO ZPOS.
*  APPEND WA_FLDCAT TO IT_FLDCAT.
*  CLEAR WA_FLDCAT.
*
*  WA_FLDCAT-SELTEXT = WA_FLDCAT-REPTEXT = WA_FLDCAT-SCRTEXT_S = WA_FLDCAT-SCRTEXT_M = WA_FLDCAT-SCRTEXT_L = TEXT-H04.
*  WA_FLDCAT-FIELDNAME = 'LIFNR'.
*  WA_FLDCAT-TABNAME   = 'ZH2H_BBVA_PROV'.
*  WA_FLDCAT-KEY = 'X'.
*  WA_FLDCAT-OUTPUTLEN = '10'.
*  WA_FLDCAT-COL_POS = ZPOS.
*  ADD 1 TO ZPOS.
*  APPEND WA_FLDCAT TO IT_FLDCAT.
*  CLEAR WA_FLDCAT.
*
*  WA_FLDCAT-SELTEXT = WA_FLDCAT-REPTEXT = WA_FLDCAT-SCRTEXT_S = WA_FLDCAT-SCRTEXT_M = WA_FLDCAT-SCRTEXT_L = TEXT-H05.
*  WA_FLDCAT-FIELDNAME = 'STCD1'.
*  WA_FLDCAT-TABNAME   = 'ZH2H_BBVA_PROV'.
*  WA_FLDCAT-KEY = 'X'.
*  WA_FLDCAT-OUTPUTLEN = '14'.
*  WA_FLDCAT-COL_POS = ZPOS.
*  ADD 1 TO ZPOS.
*  APPEND WA_FLDCAT TO IT_FLDCAT.
*  CLEAR WA_FLDCAT.
*
*  WA_FLDCAT-SELTEXT = WA_FLDCAT-REPTEXT = WA_FLDCAT-SCRTEXT_S = WA_FLDCAT-SCRTEXT_M = WA_FLDCAT-SCRTEXT_L = TEXT-H06.
*  WA_FLDCAT-FIELDNAME = 'COMENTARIO'.
*  WA_FLDCAT-TABNAME   = 'ZH2H_BBVA_PROV'.
*  WA_FLDCAT-OUTPUTLEN = '20'.
*  WA_FLDCAT-COL_POS = ZPOS.
*  ADD 1 TO ZPOS.
*  APPEND WA_FLDCAT TO IT_FLDCAT.
*  CLEAR WA_FLDCAT.
*
*  WA_FLDCAT-SELTEXT = WA_FLDCAT-REPTEXT = WA_FLDCAT-SCRTEXT_S = WA_FLDCAT-SCRTEXT_M = WA_FLDCAT-SCRTEXT_L = TEXT-H07.
*  WA_FLDCAT-FIELDNAME = 'ANRED'.
*  WA_FLDCAT-TABNAME   = 'ZH2H_BBVA_PROV'.
*  WA_FLDCAT-COL_POS = ZPOS.
*  ADD 1 TO ZPOS.
*  APPEND WA_FLDCAT TO IT_FLDCAT.
*  CLEAR WA_FLDCAT.
*
*
*  WA_FLDCAT-SELTEXT = WA_FLDCAT-REPTEXT = WA_FLDCAT-SCRTEXT_S = WA_FLDCAT-SCRTEXT_M = WA_FLDCAT-SCRTEXT_L = TEXT-H08.
*  WA_FLDCAT-FIELDNAME = 'NAME1'.
*  WA_FLDCAT-TABNAME   = 'ZH2H_BBVA_PROV'.
**    WA_FLDCAT-KEY = 'X'.
*  WA_FLDCAT-COL_POS = ZPOS.
*  ADD 1 TO ZPOS.
*  APPEND WA_FLDCAT TO IT_FLDCAT.
*  CLEAR WA_FLDCAT.


  IS_LAYOUT_LVC-ZEBRA      = 'X'.
*  IS_LAYOUT_LVC-BOX_FNAME = 'SEL'.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY_LVC'
    EXPORTING
      I_STRUCTURE_NAME         = 'ZH2H_BBVA_ST_PAG'
*      I_CALLBACK_PF_STATUS_SET = 'ZSET_PF'
*      I_CALLBACK_USER_COMMAND  = 'USER_COMMAND'
      I_CALLBACK_PROGRAM       = SY-REPID
      IT_FIELDCAT_LVC          = IT_FLDCAT
      IS_LAYOUT_LVC            = IS_LAYOUT_LVC
*      IT_SORT_LVC              = LT_SORT
    TABLES
      T_OUTTAB                 = I_ZH2H_BBVA_ST_PAG
    EXCEPTIONS
      PROGRAM_ERROR            = 1
      OTHERS                   = 2.

  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.


ENDFORM.                    " F_ARMA_CATALOGO


*&---------------------------------------------------------------------*
*&      FORM  USER_COMMAND
*&---------------------------------------------------------------------*
*FORM USER_COMMAND USING P_UCOMM TYPE SY-UCOMM
*                        P_SELFLD TYPE SLIS_SELFIELD.
*
**  CASE P_UCOMM.
**    WHEN 'EXIT'.
**      LEAVE TO SCREEN 0.
**
**  ENDCASE.
*
*
*ENDFORM.                    "USER_COMMAND

*&---------------------------------------------------------------------*
*&      Form  ZSET_PF
*&---------------------------------------------------------------------*
FORM ZSET_PF USING RT_EXTAB TYPE SLIS_T_EXTAB.

*  SET PF-STATUS 'ZPROVBBVA'." EXCLUDING RT_EXTAB.

ENDFORM.                               " SET_PF_STATUS
