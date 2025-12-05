**********************************************************************
* Grupo Porres División Ingenios
* Autor:María del Carmen Ocotlán Guzmán Medina
* programa: ZBICOPRESUP
* Descripción: BATC INPUT para cargar Cecos de manera masiva
* Transacción KP06
* Fecha: Septiembre del 2019
************************************************************************
REPORT zbico_mfn1 NO STANDARD PAGE HEADING LINE-SIZE 255.
DATA:
  v_error(1).
* archivo plano
DATA: BEGIN OF tab OCCURS 0,     " Estructura para archivo plano
        orden(10),
      END OF tab.


TYPES: BEGIN OF st_log,
         msg TYPE char255,
       END OF st_log.

DATA: it_log TYPE STANDARD TABLE OF st_log.
FIELD-SYMBOLS <fs_log> TYPE st_log.

DATA: type LIKE rlgrap-filetype VALUE 'ASC'.
DATA: length TYPE i.
DATA: BEGIN OF bdc_data OCCURS 500.
        INCLUDE STRUCTURE bdcdata.
DATA: END OF bdc_data.

DATA gctu_params LIKE ctu_params.

* Parámetros de selección
SELECTION-SCREEN BEGIN OF BLOCK block1 WITH FRAME TITLE TEXT-001.
  PARAMETERS:
    from_p  LIKE rkauf-from  OBLIGATORY DEFAULT sy-datum+4(2),
    gjahr_p LIKE rkauf-gjahr OBLIGATORY DEFAULT sy-datum+0(4),
    " mode_p  OBLIGATORY DEFAULT 'A',
    archivo TYPE localfile DEFAULT 'D:\ordenes_ga99.prn'.
SELECTION-SCREEN END OF BLOCK block1.

SELECTION-SCREEN BEGIN OF BLOCK block2 WITH FRAME TITLE TEXT-002.
  PARAMETERS: ck_mode1 RADIOBUTTON GROUP r1,
              ck_mode2 RADIOBUTTON GROUP r1,
              ck_mode3 RADIOBUTTON GROUP r1.
SELECTION-SCREEN END OF BLOCK block2.


AT SELECTION-SCREEN ON VALUE-REQUEST FOR archivo.

  CALL FUNCTION 'KD_GET_FILENAME_ON_F4'
    EXPORTING
*     PROGRAM_NAME  = SYST-REPID
*     DYNPRO_NUMBER = SYST-DYNNR
*     FIELD_NAME    = ' '
      static        = 'X'
*     MASK          = ' '
    CHANGING
      file_name     = archivo
    EXCEPTIONS
      mask_too_long = 1
      OTHERS        = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

START-OF-SELECTION.
*carga archivo a tabla internas
  CALL FUNCTION 'WS_UPLOAD'
    EXPORTING
      filename                = archivo
      filetype                = 'ASC' "type
*   importing
*     filesize                = length
    TABLES
      data_tab                = tab
    EXCEPTIONS
      conversion_error        = 1
      file_open_error         = 2
      file_read_error         = 3
      invalid_type            = 4
      no_batch                = 5
      unknown_error           = 6
      invalid_table_width     = 7
      gui_refuse_filetransfer = 8
      customer_error          = 9
      OTHERS                  = 10.
  IF sy-subrc <> 0.
    MESSAGE e600(fr) WITH 'No se pudo subir el archivo'.
  ENDIF.
  DATA:
* RUTINA PRINCIPAL
    start-of-selection.
  LOOP AT tab.
    REFRESH bdc_data.
    PERFORM llena_tabla_bdc.
    "CALL TRANSACTION 'MFN1' USING bdc_data." MODE mode_p.
    PERFORM bdc_transaction USING 'MFN1'.
*endform.
  ENDLOOP.

  IF it_log IS NOT INITIAL.
    CALL FUNCTION 'POPUP_WITH_TABLE'
      EXPORTING
        endpos_col   = 60
        endpos_row   = 20
        startpos_col = 5
        startpos_row = 5
        titletext    = 'Log del Proceso'
*   IMPORTING
*       CHOICE       =
      TABLES
        valuetab     = it_log
      EXCEPTIONS
        break_off    = 1
        OTHERS       = 2.
    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF.

  ENDIF.

  MESSAGE 'Fin del proceso' TYPE 'S'.

FORM llena_tabla_bdc .
  PERFORM bdc_dynpro USING 'SAPLKAZB' '1000'.
  PERFORM bdc_field  USING 'BDC_CURSOR' 'RKAUF-TEST'.
  PERFORM bdc_field  USING 'BDC_OKCODE' '=RUN'.
  PERFORM bdc_field  USING 'RKAUF-TEST' ''.
  PERFORM bdc_field  USING 'CODIA-AUFNR' tab-orden.
  PERFORM bdc_field  USING 'RKAUF-FROM' from_p.
  PERFORM bdc_field  USING 'RKAUF-GJAHR' gjahr_p.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  BDC_FIELD
*&---------------------------------------------------------------------*
FORM bdc_field USING program dynpro.
  CLEAR bdc_data.
  bdc_data-fnam = program.
  bdc_data-fval = dynpro.
  APPEND bdc_data.
ENDFORM.                    " BDC_FIELD
*&---------------------------------------------------------------------*
*&      Form  BDC_DYNPRO
*&---------------------------------------------------------------------*
FORM bdc_dynpro USING program dynpro.
  CLEAR bdc_data.
  bdc_data-program = program.
  bdc_data-dynpro  = dynpro.
  bdc_data-dynbegin = 'X'.
  APPEND bdc_data.
ENDFORM.                    " BDC_DYNPRO
*&---------------------------------------------------------------------*
*&      Form  BDC_TRANSACTION
*&---------------------------------------------------------------------*
FORM bdc_transaction USING tcode.
  DATA vl_msg TYPE string.

  DATA messtab LIKE bdcmsgcoll OCCURS 0 WITH HEADER LINE.
  DATA l_messtab TYPE bdcmsgcoll.

  IF ck_mode1     EQ 'X'.
    gctu_params-dismode = 'N'. "Solo errores
  ELSEIF ck_mode2 EQ 'X'.
    gctu_params-dismode = 'A'. "todas las Ventanas
  ELSEIF ck_mode3 EQ 'X'.
    gctu_params-dismode = 'S'. "Sin Ventanas
  ENDIF.


* batch input session
  REFRESH messtab.
  CALL TRANSACTION tcode USING bdc_data
        MODE gctu_params-dismode
        UPDATE 'U'
        MESSAGES INTO messtab.

  IF messtab[] IS INITIAL.
    APPEND INITIAL LINE TO it_log ASSIGNING <fs_log>.
    CONCATENATE 'La orden' tab-orden 'termino sin errores' INTO vl_msg SEPARATED BY space.
    <fs_log>-msg = vl_msg.
  ELSE.
    READ TABLE messtab INTO DATA(wa) WITH KEY msgtyp = 'E'.
    IF sy-subrc EQ 0.
      APPEND INITIAL LINE TO it_log ASSIGNING <fs_log>.
      CONCATENATE 'La orden' tab-orden 'termino con errores' wa-msgid wa-msgnr wa-msgv1 INTO vl_msg SEPARATED BY space.
      <fs_log>-msg = vl_msg.
    ELSE.
      APPEND INITIAL LINE TO it_log ASSIGNING <fs_log>.
      CONCATENATE 'La orden' tab-orden ':' wa-msgid wa-msgnr wa-msgv1 wa-msgv2  INTO vl_msg SEPARATED BY space.
      <fs_log>-msg = vl_msg.
    ENDIF.
  ENDIF.

  REFRESH bdc_data.

*  CALL FUNCTION 'BDC_INSERT'
*    EXPORTING
*      tcode            = tcode
*      ctuparams        = gctu_params
*    TABLES
*      dynprotab        = bdc_data
*    EXCEPTIONS
*      internal_error   = 1
*      not_open         = 2
*      queue_error      = 3
*      tcode_invalid    = 4
*      printing_invalid = 5
*      posting_invalid  = 6
*      OTHERS           = 7.
*
* IF sy-subrc <> 0.
*  APPEND INITIAL LINE TO it_log ASSIGNING <fs_log>.
*  CONCATENATE 'La orden' tab-orden 'termino con errores' into vl_msg SEPARATED BY space.
*  <fs_log>-msg = vl_msg.
*
* ENDIF.

ENDFORM.                    " BDC_TRANSACTION
