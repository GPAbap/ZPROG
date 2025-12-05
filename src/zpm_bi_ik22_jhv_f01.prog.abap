*&---------------------------------------------------------------------*
*&  Include           ZBIPM0005B_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  VALIDA_REGISTROS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM valida_registros .
*  DATA: lv_tabix TYPE sytabix.
*
*  LOOP AT rec.
*
*    lv_tabix = sy-tabix.
*
*    dia = rec-idate+3(2).
*    mes1 = rec-fecha(1).
*    mes2 = rec-fecha+1(1).
*    anio = rec-fecha+6(2).
*    IF rec-fecha+0(1) <> '1'.
*      mes1 = '0'.
*    ENDIF.
*    CONCATENATE dia
*                mes1
*                mes2
*                anio
*    INTO fecha2.
*
*    IF sy-datum LE '24052011'.
*      fecha2 = '250511'.
*    ENDIF.
*    SELECT * FROM  equi
*      WHERE  groes  = rec-nutar.
** Busca cuando está inactivo
*      IF sy-subrc = 0.
*        SELECT SINGLE * FROM  jest
*        WHERE  objnr  = equi-objnr
*        AND    stat   = 'I0320'
*        AND    inact  = ' '.
*        IF sy-subrc <> 0.
*          PERFORM validar.
*          IF error = ' '.
*            REFRESH bdc_data.
*            PERFORM llena_tabla_bdc.
*            IF salvar = 'X'.
**                CALL TRANSACTION 'IFCU'
**                USING bdc_data MODE 'E'. "Sólo errores
**              PERFORM bdc_transaction USING 'IFCU'. " PROCETI CJTC
*            ELSE.
** INI PROCETI CJTC
*              MOVE-CORRESPONDING: rec TO  i_rec.
*              WRITE: 'salvar <> X' TO i_rec-tperr.
*              APPEND i_rec.
*
*              DELETE rec
*              INDEX lv_tabix.
** FIN PROCETI CJTC
*
*            ENDIF.
*          ELSE.
** INI PROCETI CJTC
*            MOVE-CORRESPONDING: rec TO  i_rec.
*            WRITE: 'Error' TO i_rec-tperr.
*            APPEND i_rec.
*
*            DELETE rec
*            INDEX lv_tabix.
** FIN PROCETI CJTC
*
*          ENDIF.
*        ELSE.
*
** INI PROCETI CJTC
**          WRITE:/ equi-equnr, 'desactivado'.
*          MOVE-CORRESPONDING: rec TO  i_rec.
*          WRITE: 'desactivado' TO i_rec-tperr.
*          APPEND i_rec.
*
*          DELETE rec
*          INDEX lv_tabix.
** FIN PROCETI CJTC
*
*        ENDIF.
** INI PROCETI CJTC
*        MOVE-CORRESPONDING: rec TO  i_rec.
*        WRITE: 'N/A' TO i_rec-tperr.
*        APPEND i_rec.
*
*        DELETE rec
*        INDEX lv_tabix.
** FIN PROCETI CJTC
*      ENDIF.
*    ENDSELECT.
*
*  ENDLOOP.
ENDFORM.                    " VALIDA_REGISTROS
*&---------------------------------------------------------------------*
*&      Form  LLENA_TABLA_BDC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM llena_tabla_bdc .
* Dynpro 0100
*  PERFORM bdc_dynpro USING 'SAPLITOBFLTCON' '0100'.
*  PERFORM bdc_field  USING 'BDC_CURSOR' 'ITOB-EQUNR'.
*  PERFORM bdc_field  USING 'BDC_OKCODE' '=STRT'.
*  PERFORM bdc_field  USING 'ITOB-EQUNR' equi-equnr.
**        'CAM5039'.
*  PERFORM bdc_field  USING 'T370FLD_STN_T-STATION' 'SA1'.
** Dynpro 0200
*  PERFORM bdc_dynpro USING 'SAPLITOBFLTCON' '0200'.
*  PERFORM bdc_field  USING 'BDC_CURSOR' 'RIFLTCOUN-RECNT(01)'.
*  PERFORM bdc_field  USING 'BDC_OKCODE' '=SAVE'.
*  PERFORM bdc_field  USING 'G_POST_DATE' fecha2.     "rec-fecha.
**        '28.07.2009'.
*  PERFORM bdc_field  USING 'G_POST_TIME' rec-horac.
**        '18:52:27'.
*  PERFORM bdc_field  USING 'FLEET-PRI_CALC' 'A'.
*  PERFORM bdc_field  USING 'RIFLTCONS-RECDF(01)' rec-litro.
**        '                    40'.
*  PERFORM bdc_field  USING 'RIFLTCOUN-RECNT(01)' rec-kilom.
*        '                648974'.
ENDFORM.                    " LLENA_TABLA_BDC
*&---------------------------------------------------------------------*
*&      Form  open_group
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM open_group.
  CALL FUNCTION 'BDC_OPEN_GROUP'
    EXPORTING
      client              = sy-mandt
      group               = 'VEHIC'
      user                = sy-uname
    EXCEPTIONS
      client_invalid      = 1
      destination_invalid = 2
      group_invalid       = 3
      group_is_locked     = 4
      holddate_invalid    = 5
      internal_error      = 6
      queue_error         = 7
      running             = 8
      system_lock_error   = 9
      user_invalid        = 10
      OTHERS              = 11.
ENDFORM.                    " OPEN_GROUP
*&---------------------------------------------------------------------*
*&      Form  BDC_TRANSACTION
*&---------------------------------------------------------------------*
FORM call_transaction
  USING p_tcode
        p_mode.
  DATA: lv_msg_type TYPE  pmst_message-msg_type,
        lv_msg_id   TYPE  pmst_message-msg_id,
        lv_msg_no   TYPE  pmst_message-msg_no,
        lv_msg_arg1 TYPE  pmst_message-msg_arg1,
        lv_msg_arg2 TYPE  pmst_message-msg_arg2,
        lv_msg_arg3 TYPE  pmst_message-msg_arg3,
        lv_msg_arg4 TYPE  pmst_message-msg_arg4,
        lv_language LIKE  sy-langu.
  DATA: lw_raw_message  TYPE  pmst_raw_message.

  CLEAR: i_messages.
  CALL TRANSACTION p_tcode
  USING bdc_data
  MODE p_mode
  MESSAGES INTO i_messages.

  LOOP AT i_messages.


    MOVE: i_messages-msgtyp TO lv_msg_type,
    i_messages-msgid   TO lv_msg_id,
    i_messages-msgnr   TO lv_msg_no,
    i_messages-msgv1 TO  lv_msg_arg1,
    i_messages-msgv2 TO lv_msg_arg2,
    i_messages-msgv3 TO lv_msg_arg3,
    i_messages-msgv4 TO lv_msg_arg4.
*  i_messages-language to sy-langu
*
    CALL FUNCTION 'CULI_GET_MESSAGE'
      EXPORTING
        msg_type       = lv_msg_type
        msg_id         = lv_msg_id
        msg_no         = lv_msg_no
        msg_arg1       = lv_msg_arg1
        msg_arg2       = lv_msg_arg2
        msg_arg3       = lv_msg_arg3
        msg_arg4       = lv_msg_arg4
        language       = sy-langu
      IMPORTING
        raw_message    = lw_raw_message
      EXCEPTIONS
        msg_not_found  = 1
        internal_error = 2
        OTHERS         = 3.
    IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.


    MOVE-CORRESPONDING: rec TO i_disp_log.
    MOVE: lw_raw_message TO i_disp_log-log.
    APPEND: i_disp_log.
  ENDLOOP.
ENDFORM.                    " BDC_TRANSACTION
*&---------------------------------------------------------------------*
*&      Form  CLOSE_GROUP
*&---------------------------------------------------------------------*
FORM close_group.
  CALL FUNCTION 'BDC_CLOSE_GROUP'
    EXCEPTIONS
      not_open    = 1
      queue_error = 2
      OTHERS      = 3.
ENDFORM.                    " CLOSE_GROUP
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
*&      Form  VALIDAR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM validar .
  CLEAR error.
  CLEAR iloa.
* Busca a quien esta asignada la unidad
  SELECT SINGLE * FROM  equz
  WHERE  equnr  = equi-equnr
  AND    datbi  = '99991231'.
  IF sy-subrc = 0.
* Valida que exista imputación
    SELECT SINGLE * FROM  iloa
    WHERE  iloan  = equz-iloan.
    IF sy-subrc = 0.
      IF iloa-kostl = '          '.
        IF iloa-aufnr = ' '.
          error = 'X'.
          WRITE:/ 'Error en ', equi-equnr, '(falta imputación)'.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.
* Busca id de los puntos de medición (distance y fuel)
  SELECT * FROM  imptt
  WHERE mpobj  = equi-objnr.
    IF sy-subrc <> 0.
      error = 'X'.
      WRITE:/ 'Error en ', equi-equnr, '(no tiene pundos de medida)'.
    ENDIF.
  ENDSELECT.
ENDFORM.                    " VALIDAR
*&---------------------------------------------------------------------*
*&      Form  F_VALUE_REQUES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_value_reques .


  PERFORM f_get_path
    USING p_file
          'S'.

ENDFORM.                    " F_VALUE_REQUES
*&---------------------------------------------------------------------*
*&      Form  F_GET_PATH
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_FILE  text
*      -->P_0401   text
*----------------------------------------------------------------------*
FORM f_get_path

     USING def_path LIKE rlgrap-filename
           mode     TYPE c.

  DATA: tmp_filename LIKE rlgrap-filename.
  DATA: tmp_mask LIKE global_filemask_all.
  FIELD-SYMBOLS: <tmp_sym>.

* build filter for fileselektor

  IF global_filemask_mask IS INITIAL.
    tmp_mask = ',*.*,*.*.'.
  ELSE.
    tmp_mask = ','.
    WRITE global_filemask_text TO tmp_mask+1.
    WRITE ',' TO tmp_mask+21.
    WRITE global_filemask_mask TO tmp_mask+22.
    WRITE '.' TO tmp_mask+42.
    CONDENSE tmp_mask NO-GAPS.
  ENDIF.

  IF NOT global_filemask_all IS INITIAL.
    tmp_mask = global_filemask_all.
  ENDIF.

  fieldln = strlen( def_path ) - 1.
  ASSIGN def_path+fieldln(1) TO <tmp_sym>.
  IF <tmp_sym> IS ASSIGNED.

    IF <tmp_sym> = '/' OR <tmp_sym> = '\'.
      CLEAR <tmp_sym>.
    ENDIF.
  ENDIF.


  call FUNCTION 'F4_FILENAME'
    EXPORTING
      program_name  = SYST-CPROG       " Module pool program name for screen field
      dynpro_number = SYST-DYNNR       " Dynpro number where F4 help is needed
      field_name    = space            " name of field where path is to be entered
    IMPORTING
      file_name     = tmp_filename                 " Path name selected by user with help of Filemngr
    .
*
*  CALL FUNCTION 'WS_FILENAME_GET'
*    EXPORTING
*      def_filename     = p_file "rlgrap-filename
*      def_path         = def_path
**     mask             = ',*.*,*.*.'
*      mask             = tmp_mask
*      mode             = mode
**     title            = ' '
*    IMPORTING
*      filename         = tmp_filename
**     rc               =
*    EXCEPTIONS
*      inv_winsys       = 01
*      no_batch         = 02
*      selection_cancel = 03
*      selection_error  = 04.

  IF sy-subrc = 0.
*     rlgrap-filename = tmp_filename.
    p_file = tmp_filename.
  ELSE.
* if sy-subrc = 01.    "// Does not work, why ???
*   messageline = 'Not supported'.
* endif.
  ENDIF.
ENDFORM.                    " F_GET_PATH
*&---------------------------------------------------------------------*
*&      Form  F_CARGA_ARCHIVO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_carga_archivo .

  CALL FUNCTION 'WS_UPLOAD'
    EXPORTING
      filename   = p_file
      filetype   = type
    IMPORTING
      filelength = length
    TABLES
      data_tab   = rec.

ENDFORM.                    " F_CARGA_ARCHIVO
*&---------------------------------------------------------------------*
*&      Form  F_EJECUTA_BATCH
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_ejecuta_batch .
  DATA: li_rec LIKE TABLE OF rec WITH HEADER LINE.
  DATA: lv_pos(2) TYPE c.
  DATA: lv_itime TYPE string.
*  li_rec[] = rec[].
*  SORT li_rec
*    BY
  CLEAR: i_disp_log[].
*  LOOP AT rec.
*    CLEAR: bdc_data[].
*
*    PERFORM bdc_dynpro
*    USING 'SAPLIMR0' '1220' .
*
*    PERFORM bdc_field
*    USING: 'BDC_OKCODE' '/00',
*           'EQUI-EQUNR' rec-equnr.
*
*
*    PERFORM bdc_dynpro
*    USING 'SAPLIMR0' '4210' .
*
*    PERFORM bdc_field
*    USING: 'BDC_OKCODE' '=ADAL'.
*
*
*    PERFORM bdc_dynpro
*    USING 'SAPLIMR0' '4210' .
*
*    PERFORM bdc_field
*    USING: 'BDC_OKCODE' '=BU',
*           'RIMR0-RDCNT(01)' rec-rdcnt,
*           'RIMR0-RDCNT(02)' rec-rdlts,
*           'IMRG-IDATE(01)' rec-idate,
*           'IMRG-IDATE(02)' rec-idate,
*        'IMRG-ITIME(01)' rec-itime,
*        'IMRG-ITIME(02)' rec-itime.
*
*    PERFORM call_transaction
*    USING 'IK22' " PROCETI CJTC
*          p_mode.
*
*  ENDLOOP.

  LOOP AT rec.
    CLEAR: bdc_data[].

    PERFORM bdc_dynpro USING 'SAPLIMR0'  '1220'.

    PERFORM bdc_field USING: 'BDC_CURSOR'	'RIMR0-DFTIM',
                             'BDC_OKCODE'	'/00',
                             'RIMR0-DFTIM'  rec-itime, "12:15:21,
                             'RIMR0-DFDAT'  rec-idate, "03.02.2022
                             'RIMR0-DFRDR'  sy-uname,
                             'EQUI-EQUNR'  rec-equnr.                                " AUT0012

    PERFORM bdc_dynpro USING 'SAPLIMR0'	'4210'.	" X
    PERFORM bdc_field  USING: 'BDC_CURSOR'      'IMRG-POINT(01)',
                              'BDC_OKCODE'      '=ADAL',
                              'RIMR0-DFTIM'     rec-itime, " 12:15:21
                              'RIMR0-DFDAT'     rec-idate, " 03.02.2022
                              'RIMR0-DFRDR'     sy-uname.


    PERFORM bdc_dynpro USING 'SAPLIMR0'	'4210'.	" X
    PERFORM bdc_field  USING: 'BDC_CURSOR'      'IMRG-POINT(02)',
                              'BDC_OKCODE'  '/00',
                              'RIMR0-DFTIM'  rec-itime, " 12:15:21
                              'RIMR0-DFDAT'  rec-idate, " 03.02.2022
                              'RIMR0-DFRDR'  sy-uname,
                              'RIMR0-RDCNT(01)' rec-rdcnt,
                              'RIMR0-CDIFC(02)'  rec-rdlts.

    PERFORM bdc_dynpro USING 'SAPLIMR0' '4210'."  X
    PERFORM bdc_field  USING: 'BDC_CURSOR'  'RIMR0-FLGSL(01)',
                              'BDC_OKCODE'  '=BU',
                              'RIMR0-DFTIM'  rec-itime,
                              'RIMR0-DFDAT'  rec-idate,
                              'RIMR0-DFRDR'  sy-uname.
    PERFORM call_transaction
    USING 'IK22' " PROCETI CJTC
          p_mode.

  ENDLOOP.

  IF NOT i_disp_log[] IS INITIAL.
    CALL SCREEN 100.
  ENDIF.
ENDFORM.                    " F_EJECUTA_BATCH
*&---------------------------------------------------------------------*
*&      Form  F_FIELDCAT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_FIELDCATALOG  text
*      -->P_0018   text
*      -->P_0019   text
*      -->P_0020   text
*      -->P_0021   text
*----------------------------------------------------------------------*
FORM f_fieldcat
  TABLES pt_fieldcatalog  STRUCTURE w_fieldcatalog
  USING    p_fieldname
           p_fieldtext
           p_outputlen
           p_colpos.

  CLEAR: w_fieldcatalog.
  w_fieldcatalog-fieldname = p_fieldname.
  w_fieldcatalog-scrtext_s = p_fieldname.
  w_fieldcatalog-scrtext_m = p_fieldname.
  w_fieldcatalog-scrtext_l = p_fieldname.
  w_fieldcatalog-outputlen = p_outputlen.
  w_fieldcatalog-col_pos   = p_colpos.

  APPEND w_fieldcatalog TO pt_fieldcatalog.

ENDFORM.                    " F_FIELDCAT
*&---------------------------------------------------------------------*
*&      Form  F_DISPLAY_GRID
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_LOGAMPL[]  text
*      -->P_I_FIELDCATALOG  text
*----------------------------------------------------------------------*
FORM f_display_grid
  TABLES pt_display STRUCTURE i_disp_log
         pt_fieldcatalog STRUCTURE w_fieldcatalog.
  DATA: li_display LIKE TABLE OF i_disp_log.

  li_display[] = pt_display[].

  IF cc_grid IS INITIAL.

    CREATE OBJECT cc_grid
      EXPORTING
        container_name = 'CC_GRID'.

    CREATE OBJECT o_grid
      EXPORTING
        i_parent = cc_grid.


    CALL METHOD o_grid->set_table_for_first_display
*      EXPORTING
*        i_structure_name     = 'I_DISPLAY'
*        is_layout            = gs_layout
*        it_toolbar_excluding = it_toolbar_excludingorg
      CHANGING
        it_outtab       = li_display[]
        it_fieldcatalog = pt_fieldcatalog[].

  ELSE.

    CALL METHOD o_grid->refresh_table_display.

  ENDIF.


ENDFORM.                    " F_DISPLAY_GRID
