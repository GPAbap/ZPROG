FUNCTION ZRZL_READ_DIR_LOCAL.
*"----------------------------------------------------------------------
*"*"Interfase local
*"  IMPORTING
*"     VALUE(NAME) LIKE  SALFILE-LONGNAME
*"     VALUE(FROMLINE) TYPE  I DEFAULT 0
*"     VALUE(NRLINES) TYPE  I DEFAULT 1000
*"  TABLES
*"      FILE_TBL STRUCTURE  ZSALFLDIR
*"  EXCEPTIONS
*"      ARGUMENT_ERROR
*"      NOT_FOUND
*"      NO_ADMIN_AUTHORITY
*"----------------------------------------------------------------------
INCLUDE RSADMKEY.   " ... ADM-Kommunikation
  DATA: BEGIN OF LINE_TBL OCCURS 100.
          INCLUDE STRUCTURE SPFLIST.
  DATA: END OF LINE_TBL.

  DATA: LOC_NAME(200).
  DATA: LOC_DIR(200).
  DATA: TMP_LOC_DIR(200).
  DATA: LOC_DIR_LEN TYPE I.
  DATA: TOLINE TYPE I.
  DATA: FULL_NAME(400).
  DATA: para_name TYPE string.
  DATA: para_val  TYPE string.
  DATA: rc        TYPE I.
  DATA vl_len type i.

************************************************************************
*  Check for admin permissions (reading)
************************************************************************
  AUTHORITY-CHECK OBJECT 'S_RZL_ADM'
     ID 'ACTVT' FIELD '03'.
  IF sy-subrc <> 0.
    RAISE NO_ADMIN_AUTHORITY.
  ENDIF.

  IF NAME <> SPACE.
    LOC_NAME = NAME.
    LOC_DIR = NAME.
    SHIFT LOC_DIR LEFT BY 2 PLACES.
    LOC_DIR_LEN = STRLEN( LOC_DIR ).
    LOC_DIR_LEN = LOC_DIR_LEN - 1.
    SHIFT LOC_DIR CIRCULAR LEFT BY LOC_DIR_LEN PLACES.
    IF LOC_NAME(2) = '$(' AND LOC_DIR(1) = ')'.
      LOC_DIR(1) = SPACE.
      SHIFT LOC_DIR CIRCULAR RIGHT BY LOC_DIR_LEN PLACES.

*     replace macro $(...)
      para_name = LOC_DIR.
      rc = cl_spfl_profile_parameter=>get_value( EXPORTING name = para_name
                                                 IMPORTING value = para_val ).
      IF rc = 0.
        FULL_NAME = para_val.
      ELSE.
        FULL_NAME = NAME.
      ENDIF.
    ELSE.
      FULL_NAME = NAME.
    ENDIF.

  ELSE.
    FULL_NAME = NAME.
  ENDIF.

  REFRESH LINE_TBL.

* check arguments for requested entries
  IF FROMLINE < 0.
    RAISE ARGUMENT_ERROR.
  ENDIF.
  IF NRLINES > 100000.
    RAISE ARGUMENT_ERROR.
  ENDIF.

  IF NRLINES <= 0.
    RETURN.
  ENDIF.

************************************************************************
*  call kernel
************************************************************************

  CALL 'RZLCallFromABAP' ID 'OPCODE'       FIELD RZL_OP_RD_DIR
                         ID 'FILE_NAME'    FIELD FULL_NAME
                         ID 'DIR_TBL'      FIELD LINE_TBL-*SYS*.

  CASE SY-SUBRC.
    WHEN 0.
*     ABAP index starts with 1
      ADD 1 TO FROMLINE.
      TOLINE   = FROMLINE + NRLINES.
      SUBTRACT 1 FROM TOLINE.

      LOOP AT LINE_TBL FROM FROMLINE TO TOLINE.
        FILE_TBL-SIZE = LINE_TBL(11).
        FILE_TBL-NAME = LINE_TBL+12.
        vl_len = strlen( FILE_TBL-name ).
        IF vl_len > 10.
           vl_len = vl_len - 10.
           FILE_TBL-date = FILE_TBL-name+vl_len(6).
        ENDIF.
        APPEND FILE_TBL.
      ENDLOOP.
    WHEN OTHERS.
      RAISE NOT_FOUND.
  ENDCASE.

ENDFUNCTION.
