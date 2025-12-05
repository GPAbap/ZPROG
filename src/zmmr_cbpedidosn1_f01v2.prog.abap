*&---------------------------------------------------------------------*
*&  Include           ZMMR_CBPEDIDOSF01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  GET_PUCHARSE_ORDER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
* Fecha/Autor :   29.08.2022  Víctor Madera
* Incidente   :   240 Debe mostrar solo lo de las sociedades que tienen
*                     asignada en una variante
*----------------------------------------------------------------------*
FORM get_pucharse_order .

  REFRESH gt_alv.

  DATA: lr_bukrs TYPE RANGE OF bukrs,
        lv_stako TYPE ekko-stako.
  IF s_bstyp-low EQ 'A'.
*    lr_bukrs[] = gr_bukrs[].       "vmr02- Incidente 240
    lv_stako = abap_true.
  ELSEIF s_bstyp-low EQ 'F'.
    CLEAR: lr_bukrs, lv_stako.
  ENDIF.
  lr_bukrs[] = gr_bukrs[].          "vmr02+ Incidente 240

*vmr01--> Tipo de documentos a considerar no liberados
*  IF  gr_bukrs[]  IS NOT INITIAL
  IF gr_bsartn[] IS NOT INITIAL
  AND gr_frgken[] IS NOT INITIAL.
    SELECT * FROM ekko INNER JOIN ekpo ON ( ekko~ebeln = ekpo~ebeln )
       INTO CORRESPONDING FIELDS OF TABLE gt_alv
        WHERE ekko~ebeln IN s_ebeln
          AND ekko~bukrs IN lr_bukrs  " ADD - HZAVALA
          AND ekko~bstyp IN s_bstyp  " ADD - CBARRERA
          AND ekko~ekorg IN s_ekorg
          AND ekko~ekgrp IN s_ekgrp
          AND ekko~lifnr IN s_lifnr
          AND ekko~reswk IN s_reswk
          AND ekko~bedat IN s_bedat
          AND ekko~frgke IN gr_frgken  " ADD - HZAVALA
          AND ekko~bsart IN gr_bsartn
          AND ekko~stako EQ lv_stako
          AND ekpo~matnr IN s_matnr
          AND ekpo~matkl IN s_matkl
          AND ekpo~loekz EQ ' '.
  ENDIF.
*  IF  gr_bukrs[] IS NOT INITIAL
  IF gr_bsart[] IS NOT INITIAL
  AND gr_frgke[] IS NOT INITIAL.
*vmr01<--FIN
    SELECT * FROM ekko INNER JOIN ekpo ON ( ekko~ebeln = ekpo~ebeln )
       APPENDING CORRESPONDING FIELDS OF TABLE gt_alv
        WHERE ekko~ebeln IN s_ebeln
          AND ekko~bukrs IN lr_bukrs  " ADD - HZAVALA
          AND ekko~bstyp IN s_bstyp  " ADD - CBARRERA
          AND ekko~ekorg IN s_ekorg
          AND ekko~ekgrp IN s_ekgrp
          AND ekko~lifnr IN s_lifnr
          AND ekko~reswk IN s_reswk
          AND ekko~bedat IN s_bedat
          AND ekko~frgke IN gr_frgke  " ADD - HZAVALA
          AND ekko~bsart IN gr_bsart  " ADD - HZAVALA
          AND ekpo~matnr IN s_matnr
          AND ekpo~matkl IN s_matkl
          AND ekpo~loekz EQ ' '.
  ENDIF.    "vmr


  IF gt_alv[] IS NOT INITIAL.
    LOOP AT gt_alv ASSIGNING <fs_alv>.
      CLEAR <fs_alv>-smtp_addr.
      SELECT SINGLE name1 adrnr FROM lfa1
       INTO (<fs_alv>-name1, <fs_alv>-adrnr)
        WHERE lifnr EQ <fs_alv>-lifnr.

      IF sy-subrc EQ 0.
        SELECT SINGLE smtp_addr FROM adr6
          INTO <fs_alv>-smtp_addr
          WHERE addrnumber EQ <fs_alv>-adrnr.
      ENDIF.
      IF <fs_alv>-adrnr IS INITIAL.
        <fs_alv>-adrnr = sy-uname.
      ENDIF.

* Graba Fecha y hora de envio de correo
      CLEAR: vg_datum, vg_uzeit.
      SELECT SINGLE datum uzeit FROM  zpedcom_env
             INTO (vg_datum, vg_uzeit)
             WHERE  ebeln  = <fs_alv>-ebeln
             AND    ekorg  = <fs_alv>-ekorg.
      WRITE vg_datum TO <fs_alv>-datum USING EDIT MASK '__.__.____' NO-ZERO.
      WRITE vg_uzeit TO <fs_alv>-uzeit USING EDIT MASK '__:__:__' NO-ZERO.
    ENDLOOP.

    SORT gt_alv BY ebeln ASCENDING.
    DELETE ADJACENT DUPLICATES FROM gt_alv COMPARING ebeln.

    PERFORM create_alv.

  ELSE.
    MESSAGE s006(zmm_barcode).
    EXIT.
  ENDIF.

ENDFORM.                    " GET_PUCHARSE_ORDER
*&---------------------------------------------------------------------*
*&      Form  CREATE_ALV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM create_alv .

* ALV required data objects.
  DATA: w_title  TYPE lvc_title,
        w_repid  TYPE syrepid,
        w_comm   TYPE slis_formname,
        w_status TYPE slis_formname,
        x_layout TYPE slis_layout_alv,
        t_event  TYPE slis_t_event.

  REFRESH gt_fieldcat.
  CLEAR: x_layout,  w_title.

  PERFORM build_catalog.

*  Layout
  x_layout-zebra         = 'X'.
*  x_layout-box_fieldname = 'SEL'.

* GUI Status
  w_repid = sy-repid.
  w_status = 'PF_STATUS_SET'.
*  User commands
  w_comm   = 'USER_COMMAND'.

* Displays the ALV grid
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
*     i_bypassing_buffer       = 'X'
*     i_buffer_active          = 'X'
      i_callback_program       = w_repid
      it_fieldcat              = gt_fieldcat
      is_layout                = x_layout
*     it_sort                  = t_sort
      i_callback_pf_status_set = w_status
      i_callback_user_command  = w_comm
*     i_callback_html_top_of_page = 'TOP_PAGE'
      i_save                   = 'X'
      "it_events                   = t_event
      "i_grid_title                = w_title
    TABLES
      t_outtab                 = gt_alv
    EXCEPTIONS
      program_error            = 1
      OTHERS                   = 2.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFORM.                    " CREATE_ALV
*&---------------------------------------------------------------------*
*&      Form  BUILD_CATALOG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM build_catalog .
  DATA ls_fieldcat TYPE slis_fieldcat_alv.

  CLEAR ls_fieldcat.
  ls_fieldcat-col_pos = 1.
  ls_fieldcat-fieldname = 'SEL'.
  ls_fieldcat-input = 'X'.
  ls_fieldcat-edit = 'X'.
  ls_fieldcat-checkbox = 'X'.
  ls_fieldcat-inttype = 'C'.
  ls_fieldcat-key = 'X'.
  ls_fieldcat-just = 'C'.
  ls_fieldcat-outputlen = 4.
  ls_fieldcat-seltext_m = 'Sel'.
  APPEND ls_fieldcat TO gt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-col_pos = 2.
  ls_fieldcat-fieldname = 'EBELN'.
*  ls_fieldcat-hotspot = 'X'.
  ls_fieldcat-inttype = 'C'.
  ls_fieldcat-key = 'X'.
  ls_fieldcat-just = 'C'.
  ls_fieldcat-outputlen = 11.
  ls_fieldcat-seltext_m = 'Pedido'.
  APPEND ls_fieldcat TO gt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-col_pos = 3.
  ls_fieldcat-fieldname = 'BUKRS'.
  ls_fieldcat-inttype = 'C'.
  ls_fieldcat-just = 'C'.
  ls_fieldcat-outputlen = 5.
  ls_fieldcat-seltext_m = 'Soc.'.
  APPEND ls_fieldcat TO gt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-col_pos = 4.
  ls_fieldcat-fieldname = 'BSTYP'.
  ls_fieldcat-inttype = 'C'.
  ls_fieldcat-just = 'C'.
  ls_fieldcat-outputlen = 4.
  ls_fieldcat-seltext_m = 'TDoc'.
  APPEND ls_fieldcat TO gt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-col_pos = 5.
  ls_fieldcat-fieldname = 'BSART'.
  ls_fieldcat-inttype = 'C'.
  ls_fieldcat-just = 'C'.
  ls_fieldcat-outputlen = 5.
  ls_fieldcat-seltext_m = 'Cldoc'.
  APPEND ls_fieldcat TO gt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-col_pos = 6.
  ls_fieldcat-fieldname = 'AEDAT'.
  ls_fieldcat-inttype = 'C'.
  ls_fieldcat-just = 'C'.
  ls_fieldcat-outputlen = 11.
  ls_fieldcat-edit_mask = '__/__/____'.
  ls_fieldcat-seltext_m = 'Creación'.
  APPEND ls_fieldcat TO gt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-col_pos = 7.
  ls_fieldcat-fieldname = 'LIFNR'.
  ls_fieldcat-inttype = 'C'.
  ls_fieldcat-just = 'C'.
  ls_fieldcat-outputlen = 11.
  ls_fieldcat-seltext_m = 'No.Prov.'.
  APPEND ls_fieldcat TO gt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-col_pos   = 8.
  ls_fieldcat-fieldname = 'NAME1'.
  ls_fieldcat-inttype   = 'C'.
  ls_fieldcat-just      = 'L'.
  ls_fieldcat-no_zero   = 'X'.
  ls_fieldcat-outputlen = 40.
  ls_fieldcat-seltext_m = 'Descripción'.
  APPEND ls_fieldcat TO gt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-col_pos   = 9.
  ls_fieldcat-fieldname = 'DATUM'.
  ls_fieldcat-inttype   = 'C'.
  ls_fieldcat-just      = 'L'.
*  ls_fieldcat-no_zero   = 'X'.
  ls_fieldcat-outputlen = 10.
  ls_fieldcat-seltext_m = 'Fec Crea'.
  APPEND ls_fieldcat TO gt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-col_pos = 10.
  ls_fieldcat-fieldname = 'UZEIT'.
  ls_fieldcat-inttype = 'C'.
  ls_fieldcat-just = 'L'.
  ls_fieldcat-outputlen = 10.
  ls_fieldcat-seltext_m = 'Hora Crea'.
  APPEND ls_fieldcat TO gt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-col_pos = 11.
  ls_fieldcat-fieldname = 'SMTP_ADDR'.
  ls_fieldcat-inttype = 'C'.
  ls_fieldcat-just = 'L'.
  ls_fieldcat-input = 'X'.
  ls_fieldcat-edit = 'X'.
  ls_fieldcat-lowercase = 'X'.
  ls_fieldcat-outputlen = 50.
  ls_fieldcat-seltext_m = 'Correo Electrónico'.
  APPEND ls_fieldcat TO gt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-col_pos = 12.
  ls_fieldcat-fieldname = 'EKORG'.
  ls_fieldcat-inttype = 'C'.
  ls_fieldcat-just = 'C'.
  ls_fieldcat-outputlen = 5.
  ls_fieldcat-seltext_m = 'OrgCo'.
  APPEND ls_fieldcat TO gt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-col_pos = 13.
  ls_fieldcat-fieldname = 'EKGRP'.
  ls_fieldcat-inttype = 'C'.
  ls_fieldcat-just = 'C'.
  ls_fieldcat-outputlen = 5.
  ls_fieldcat-seltext_m = 'GpoCo'.
  APPEND ls_fieldcat TO gt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-col_pos = 14.
  ls_fieldcat-fieldname = 'WAERS'.
  ls_fieldcat-inttype = 'C'.
  ls_fieldcat-just = 'C'.
  ls_fieldcat-outputlen = 5.
  ls_fieldcat-seltext_m = 'Mon'.
  APPEND ls_fieldcat TO gt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-col_pos = 15.
  ls_fieldcat-fieldname = 'FRGKE'.
  ls_fieldcat-inttype = 'C'.
  ls_fieldcat-just = 'C'.
  ls_fieldcat-outputlen = 3.
  ls_fieldcat-seltext_m = 'Lib'.
  APPEND ls_fieldcat TO gt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-col_pos = 16.
  ls_fieldcat-fieldname = 'MEMORY'.
  ls_fieldcat-inttype = 'C'.
  ls_fieldcat-just = 'C'.
  ls_fieldcat-checkbox = 'X'.
  ls_fieldcat-outputlen = 3.
  ls_fieldcat-seltext_m = 'PIn'.
  APPEND ls_fieldcat TO gt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-col_pos = 17.
  ls_fieldcat-fieldname = 'PROCSTAT'.
  ls_fieldcat-inttype = 'C'.
  ls_fieldcat-just = 'C'.
  ls_fieldcat-outputlen = 3.
  ls_fieldcat-seltext_m = 'St'.
  APPEND ls_fieldcat TO gt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-col_pos = 18.
  ls_fieldcat-fieldname = 'SMTP_ADD1'.
  ls_fieldcat-inttype = 'C'.
  ls_fieldcat-just = 'L'.
  ls_fieldcat-input = 'X'.
  ls_fieldcat-edit = 'X'.
  ls_fieldcat-lowercase = 'X'.
  ls_fieldcat-outputlen = 50.
  ls_fieldcat-seltext_m = 'Mail Alternativo1'.
  APPEND ls_fieldcat TO gt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-col_pos = 19.
  ls_fieldcat-fieldname = 'SMTP_ADD2'.
  ls_fieldcat-inttype = 'C'.
  ls_fieldcat-just = 'L'.
  ls_fieldcat-input = 'X'.
  ls_fieldcat-edit = 'X'.
  ls_fieldcat-lowercase = 'X'.
  ls_fieldcat-outputlen = 50.
  ls_fieldcat-seltext_m = 'Mail Alternativo2'.
  APPEND ls_fieldcat TO gt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-col_pos = 20.
  ls_fieldcat-fieldname = 'SMTP_ADD3'.
  ls_fieldcat-inttype = 'C'.
  ls_fieldcat-just = 'L'.
  ls_fieldcat-input = 'X'.
  ls_fieldcat-edit = 'X'.
  ls_fieldcat-lowercase = 'X'.
  ls_fieldcat-outputlen = 50.
  ls_fieldcat-seltext_m = 'Mail Alternativo3'.
  APPEND ls_fieldcat TO gt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-col_pos = 21.
  ls_fieldcat-fieldname = 'SMTP_ADD4'.
  ls_fieldcat-inttype = 'C'.
  ls_fieldcat-just = 'L'.
  ls_fieldcat-input = 'X'.
  ls_fieldcat-edit = 'X'.
  ls_fieldcat-lowercase = 'X'.
  ls_fieldcat-outputlen = 50.
  ls_fieldcat-seltext_m = 'Mail Alternativo4'.
  APPEND ls_fieldcat TO gt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-col_pos = 22.
  ls_fieldcat-fieldname = 'WKURS'.
*  ls_fieldcat-inttype = 'C'.
*  ls_fieldcat-just = 'L'.
*  ls_fieldcat-input = 'X'.
*  ls_fieldcat-edit = 'X'.
  ls_fieldcat-lowercase = 'X'.
  ls_fieldcat-outputlen = 10.
  ls_fieldcat-seltext_m = 'Cant'.
  APPEND ls_fieldcat TO gt_fieldcat.

ENDFORM.                    " BUILD_CATALOG

*&------------------------------------------------------------------*
*&      Form  user_command
*&------------------------------------------------------------------*
*       Called on user_command ALV event.
*       Executes custom commands.
*-------------------------------------------------------------------*
FORM user_command USING r_ucomm     LIKE sy-ucomm
                        rs_selfield TYPE slis_selfield.

  DATA: lt_poitems    TYPE STANDARD TABLE OF bapiekpo,
        l_num         TYPE i,
        bdcdata_wa    TYPE bdcdata,
        bdcdata_tab   TYPE TABLE OF bdcdata,
        lv_fname      TYPE rs38l_fnam,
        l_pedidos     TYPE char1,
        w_msg(100)    TYPE c,
        lw_data       TYPE tt_alv,
        lv_ebeln      TYPE ebeln,
        ls_ekko       TYPE ekko,
        lv_formname   TYPE tdsfname  VALUE 'ZMMSF_PEDIDO2N',
        lv_srecipient TYPE swotobjid,
        lv_ssender    TYPE swotobjid,
        lv_sjob_info  TYPE ssfcrescl,
        lt_otf        TYPE TABLE OF itcoo,
        lv_subrc      LIKE sy-subrc.

  IF gcl_ref_grid IS INITIAL.  "Se guarda el objeto de ALV
    CALL FUNCTION 'GET_GLOBALS_FROM_SLVC_FULLSCR'
      IMPORTING
        e_grid = gcl_ref_grid.
  ENDIF.
  IF gcl_ref_grid IS NOT INITIAL.
    CALL METHOD gcl_ref_grid->check_changed_data.  " Se verifican datos que cambiaron en la edición de ALV
  ENDIF.

  CASE r_ucomm.
    WHEN '&ALL1'.
      LOOP AT gt_alv[] ASSIGNING <fs_alv>.
        <fs_alv>-sel = 'X'.
      ENDLOOP.
      CALL METHOD gcl_ref_grid->refresh_table_display.
    WHEN '&SAL1'.
      LOOP AT gt_alv[] ASSIGNING <fs_alv>.
        <fs_alv>-sel = space.
      ENDLOOP.
      CALL METHOD gcl_ref_grid->refresh_table_display.
*vmr
    WHEN 'PDF'  OR 'SENDM'.
      PERFORM print.
* - JSA Ajuste 01072022
* Actualiza fecha y hora en pedido
      LOOP AT gt_alv INTO gs_alv
           WHERE sel = 'X'.
        IF gs_alv-datum IS INITIAL.

          MOVE gs_alv-ebeln TO zpedcom_env-ebeln.
          MOVE gs_alv-ekorg TO zpedcom_env-ekorg.
          MOVE sy-datum     TO zpedcom_env-datum.
          MOVE sy-uzeit     TO zpedcom_env-uzeit.
          MODIFY zpedcom_env.

          WRITE zpedcom_env-datum TO gs_alv-datum USING EDIT MASK '__.__.____'.
          WRITE zpedcom_env-uzeit TO gs_alv-uzeit USING EDIT MASK '__:__:__'.
          MODIFY gt_alv FROM gs_alv.
        ENDIF.
      ENDLOOP.
      rs_selfield-refresh = 'X'.
* - JSA Termina Ajuste 01072022

*vmr
    WHEN 'PRINT'.   " OR 'SENDM' .

******************************
* Actualiza fecha y hora en pedido
      LOOP AT gt_alv INTO gs_alv
           WHERE sel = 'X'.
        IF gs_alv-datum IS INITIAL.

          MOVE gs_alv-ebeln TO zpedcom_env-ebeln.
          MOVE gs_alv-ekorg TO zpedcom_env-ekorg.
          MOVE sy-datum     TO zpedcom_env-datum.
          MOVE sy-uzeit     TO zpedcom_env-uzeit.
          MODIFY zpedcom_env.

          WRITE zpedcom_env-datum TO gs_alv-datum USING EDIT MASK '__.__.____'.
          WRITE zpedcom_env-uzeit TO gs_alv-uzeit USING EDIT MASK '__:__:__'.
          MODIFY gt_alv FROM gs_alv.
        ENDIF.
      ENDLOOP.
      rs_selfield-refresh = 'X'.
******************************

      gt_seleccion[] = gt_alv[].
      DELETE gt_seleccion WHERE sel = ''.
      DESCRIBE TABLE gt_seleccion LINES l_num.

      IF l_num = 0.
        MESSAGE TEXT-012 TYPE 'E'.
        RETURN.
      ENDIF.

      w_msg = l_num.
      MESSAGE s000(zmm_barcode) WITH TEXT-002 w_msg 'Lineas'.
      IF s_bstyp-low EQ 'A'.
        lv_formname   = 'ZMMSF_PEDIDO3N'.
      ELSE.
        lv_formname   = 'ZMMSF_PEDIDO2N'.
      ENDIF.
      CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
        EXPORTING
          formname           = lv_formname
        IMPORTING
          fm_name            = lv_fname
        EXCEPTIONS
          no_form            = 1
          no_function_module = 2
          OTHERS             = 3.
      IF sy-subrc = 0.
        CLEAR: lv_scontrol_param, lv_scomposer_param.
        IF r_ucomm EQ 'SENDM'.
          lv_scontrol_param-getotf = 'X'.
          lv_scomposer_param-tdnoprev = 'X'.
          lv_scontrol_param-preview = space.
          lv_scontrol_param-no_dialog = 'X'.
          "Impresora por defecto en Vista TVARV
          SELECT SINGLE low FROM tvarvc INTO lv_scomposer_param-tddest
            WHERE name EQ TEXT-016.
        ENDIF.
*         lw_compop-tddest = gv_printer.
        lv_scontrol_param-device = 'PRINTER'.
        lv_scomposer_param-tdreceiver = sy-uname.
        lv_scomposer_param-tdcopies = 1.
        lv_scomposer_param-tdimmed = 'X'.
        lv_scomposer_param-tddelete = 'X'.
        lv_scomposer_param-tdnewid = 'X'.
        lv_scomposer_param-tdfinal = 'X'.
        IF l_num GT 1 AND r_ucomm NE 'SENDM'.
          CLEAR gv_noprint.
          lv_scomposer_param-tddataset = 'SMART'.
          lv_scomposer_param-tdsuffix2 = sy-uname.
          CALL SCREEN 0100 STARTING AT 1 1.
          CHECK gv_noprint IS INITIAL.
          lv_scontrol_param-no_dialog = 'X'.
          lv_scontrol_param-preview = space.
          lv_scomposer_param-tdnoprev = 'X'.
        ENDIF.
*         READ TABLE gt_seleccion INTO gs_alv INDEX 1.
        LOOP AT gt_seleccion INTO gs_alv.
          MOVE-CORRESPONDING gs_alv TO ls_ekko.
          CLEAR lv_sjob_info.
          REFRESH lv_sjob_info-otfdata[].
          CALL FUNCTION lv_fname
            EXPORTING
*             archive_index      = toa_dara
*             archive_parameters = arc_params
              control_parameters = lv_scontrol_param
*             mail_appl_obj      =
              mail_recipient     = lv_srecipient
              mail_sender        = lv_ssender
              output_options     = lv_scomposer_param
              user_settings      = space
              ps_ekko            = ls_ekko
              ps_cp              = wa_cp    "vmr
            IMPORTING
              job_output_info    = lv_sjob_info
*           TABLES
*             ps_textos          = ps_textos
            EXCEPTIONS
              formatting_error   = 1
              internal_error     = 2
              send_error         = 3
              user_canceled      = 4
              OTHERS             = 5.

          lv_subrc = sy-subrc.
          CASE lv_subrc .
            WHEN 1 .
              MESSAGE TEXT-003 TYPE 'E' .

            WHEN 2 .
              MESSAGE TEXT-004 TYPE 'E' .

            WHEN 3 .
              MESSAGE TEXT-005 TYPE 'E' .

            WHEN 4 .
              MESSAGE TEXT-006 TYPE 'S' .

            WHEN 5 .
              MESSAGE TEXT-007 TYPE 'E' .

          ENDCASE .

          CHECK lv_subrc EQ 0.
          IF r_ucomm EQ 'SENDM'.
            CLEAR lt_otf.
            lt_otf[] = lv_sjob_info-otfdata[].
            PERFORM send_mail TABLES lt_otf
                               USING ls_ekko .

          ELSE.
            MESSAGE s000(zmm_barcode) WITH TEXT-008 ls_ekko-ebeln.
          ENDIF.
        ENDLOOP.
      ELSE.
        MESSAGE TEXT-009 TYPE 'E' .
      ENDIF.

      DATA: gcl_ref_grid   TYPE REF TO cl_gui_alv_grid.
      IF gcl_ref_grid IS INITIAL.  "Se guarda el objeto de ALV
        CALL FUNCTION 'GET_GLOBALS_FROM_SLVC_FULLSCR'
          IMPORTING
            e_grid = gcl_ref_grid.
        CALL METHOD gcl_ref_grid->check_changed_data.
      ENDIF.

    WHEN '&IC1'  .
      IF rs_selfield-sel_tab_field CS 'EBELN'.
        lv_ebeln = rs_selfield-value.
        SET PARAMETER ID 'BES' FIELD lv_ebeln .
        "CALL TRANSACTION 'ME23N'.
      ENDIF.


  ENDCASE.
ENDFORM.                    "user_command

*&---------------------------------------------------------------------*
*&      Form  pf_status_set
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->PT_EXTAB   text
*----------------------------------------------------------------------*
FORM pf_status_set USING pt_extab TYPE slis_t_extab.

  SET PF-STATUS 'ZMM_ALVSTANDARD'.

ENDFORM.                    "pf_status_set
*&---------------------------------------------------------------------*
*&      Form  SEND_MAIL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LV_SJOB_INFO_OTFDATA  text
*      -->P_LS_EKKO  text
*----------------------------------------------------------------------*
FORM send_mail  TABLES  it_formulario_otf STRUCTURE itcoo
               USING    p_ekko TYPE ekko.

  DATA: it_objbin    TYPE STANDARD TABLE OF solisti1,
        it_record    TYPE STANDARD TABLE OF solisti1,
        it_objtxt    TYPE STANDARD TABLE OF solisti1,
        it_objpack   TYPE STANDARD TABLE OF sopcklsti1,
        it_otf       TYPE STANDARD TABLE OF itcoo,
        it_tline     TYPE STANDARD TABLE OF tline,
        it_reclist   TYPE STANDARD TABLE OF somlreci1,
        lv_len       TYPE i,
        lv_bin_size  TYPE i,
        lv_pos       TYPE i,
        wa           TYPE solisti1,
        wa_objhead   TYPE soli_tab,
        wa_doc_chng  TYPE sodocchgi1,
        wa_objpack   TYPE sopcklsti1,
        wa_reclist   TYPE somlreci1,
        lv_buffer    TYPE string,
        lv_medio     TYPE na_nacha,
        lv_factura   TYPE string,
        lv_titulo    TYPE string,
        lv_xblnr     TYPE xblnr,
        lv_bukrs     TYPE bukrs,
        lv_lin_txt   TYPE i,
        lv_lin_bin   TYPE i,
        ls_sofm_id   TYPE sofm,
        lv_objnam    TYPE so_obj_nam,
        lv_sapnam    TYPE so_sap_nam,
        lv_so_key    TYPE ad_so_key,
        lv_smtp_addr TYPE ad_smtpadr,
        xtdname      LIKE thead-tdname,
        lt_somg_tab  TYPE STANDARD TABLE OF somg WITH HEADER LINE.
  DATA:  BEGIN OF tlines OCCURS 0.
           INCLUDE STRUCTURE tline.
  DATA:   END OF tlines.

  CONSTANTS: tdobject    LIKE thead-tdobject VALUE 'TEXT',  "Llamar objeto de texto estándar con el cuerpo del Mail
             txtid_beweg LIKE thead-tdid VALUE 'ST'.

  FIELD-SYMBOLS : <wa_tline>  LIKE LINE OF it_tline
                  ,<wa_objbin> LIKE LINE OF it_objbin.

  READ TABLE gt_alv INTO gs_alv WITH KEY ebeln = p_ekko-ebeln.
  SHIFT p_ekko-ebeln LEFT DELETING LEADING '0'.
*  lv_titulo = text-014.
  CLEAR wa_reclist.
  REFRESH it_reclist.
  IF gs_alv-smtp_addr IS INITIAL.
    gs_alv-smtp_addr = sy-uname.
  ENDIF.
  PERFORM reclist TABLES   it_reclist
                  USING    gs_alv-smtp_addr
                  CHANGING wa_reclist.

  PERFORM reclist TABLES   it_reclist  "Direcciones de email alternativo
                  USING    gs_alv-smtp_add1
                  CHANGING wa_reclist.

  PERFORM reclist TABLES   it_reclist
                  USING    gs_alv-smtp_add2
                  CHANGING wa_reclist.

  PERFORM reclist TABLES   it_reclist
                  USING    gs_alv-smtp_add3
                  CHANGING wa_reclist.

  PERFORM reclist TABLES   it_reclist
                  USING    gs_alv-smtp_add4
                  CHANGING wa_reclist.

  it_otf[] = it_formulario_otf[].
  CLEAR it_tline.
  CALL FUNCTION 'CONVERT_OTF'
    EXPORTING
      format                = 'PDF'
      max_linewidth         = 132
    IMPORTING
      bin_filesize          = lv_bin_size
    TABLES
      otf                   = it_otf
      lines                 = it_tline
    EXCEPTIONS
      err_max_linewidth     = 1
      err_format            = 2
      err_conv_not_possible = 3
      OTHERS                = 4.

  IF sy-subrc EQ 0.
    CLEAR: wa, lv_len.
    LOOP AT it_tline ASSIGNING <wa_tline>.
      lv_pos = 255 - lv_len.
      IF lv_pos > 134. "length of pdf_table
        lv_pos = 134.
      ENDIF.
      wa+lv_len = <wa_tline>(lv_pos).
      lv_len = lv_len + lv_pos.
      IF lv_len = 255. "length of out (contents_bin)
        APPEND wa TO it_record.
        CLEAR: wa, lv_len.
        IF lv_pos < 134.
          wa = <wa_tline>+lv_pos.
          lv_len = 134 - lv_pos.
        ENDIF.
      ENDIF.
    ENDLOOP.
    IF lv_len > 0.
      APPEND wa TO it_record.
    ENDIF.

* Attachment
    REFRESH: it_objtxt,
             it_objbin,
             it_objpack,
             tlines.

    it_objbin[] = it_record[].
* Create Message Body Title and Description
    CLEAR: wa, wa_doc_chng ,wa_objhead, xtdname.

* Modificaciones por Arturo Huesca / Aporta
    IF p_ekko-bukrs+0(1) NE 'G'.
      "Texto en el body del mail
      SELECT SINGLE low FROM tvarvc INTO xtdname
        WHERE name EQ TEXT-015.
    ELSE.
      SELECT SINGLE low FROM tvarvc INTO xtdname
      WHERE name EQ TEXT-017.
    ENDIF.
    IF s_bstyp-low = 'A'.
      xtdname = 'ZMM_PETOFEMAIL'.
    ENDIF.

    CALL FUNCTION 'READ_TEXT'
      EXPORTING
*       CLIENT                  = SY-MANDT
        id                      = txtid_beweg
        language                = sy-langu
        name                    = xtdname
        object                  = tdobject
*       ARCHIVE_HANDLE          = 0
*       LOCAL_CAT               = ' '
*     IMPORTING
*       HEADER                  =
      TABLES
        lines                   = tlines
      EXCEPTIONS
        id                      = 1
        language                = 2
        name                    = 3
        not_found               = 4
        object                  = 5
        reference_check         = 6
        wrong_access_to_archive = 7
        OTHERS                  = 8.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE 'I' NUMBER sy-msgno
               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      wa = p_ekko-ebeln.
      APPEND wa TO it_objtxt.
    ELSE.
      LOOP AT tlines.
        CLEAR wa.
        MOVE tlines-tdline TO wa.
        APPEND wa TO it_objtxt.
      ENDLOOP.
      READ TABLE it_objtxt INTO wa INDEX 1.
      IF sy-subrc EQ 0.
        "Jaime Hernandez Velasquez;26042023;Se cambia el
        "titulo a la primera linea del objeto de Texto.
        "Sol. Claudia Luna (C. MM)
        lv_titulo = wa-line. "TEXT-020. " Se asigna Titulo
        DELETE it_objtxt INDEX 1.  "Se borra 1 linea asignada al titulo
      ENDIF.
    ENDIF.

    DESCRIBE TABLE it_objtxt LINES lv_lin_txt.
    READ TABLE it_objtxt INTO wa INDEX lv_lin_txt.
    wa_doc_chng-obj_name = lv_titulo.
    wa_doc_chng-expiry_dat = sy-datum + 10.
    wa_doc_chng-obj_descr = lv_titulo.
    wa_doc_chng-sensitivty = 'F'.
    wa_doc_chng-doc_size = lv_lin_txt * 255.

* Main Text
    CLEAR  wa_objpack.
    wa_objpack-head_start = 1.
    wa_objpack-head_num = 0.
    wa_objpack-body_start = 1.
    wa_objpack-body_num = lv_lin_txt.
    wa_objpack-doc_type = 'RAW'.
    APPEND wa_objpack TO it_objpack.
* Attachment (pdf-Attachment)
    CLEAR  wa_objpack.
    wa_objpack-transf_bin = 'X'.
    wa_objpack-head_start = 1.
    wa_objpack-head_num = 0.
    wa_objpack-body_start = 1.
    DESCRIBE TABLE it_objbin LINES lv_lin_bin.
    READ TABLE it_objbin ASSIGNING <wa_objbin> INDEX lv_lin_bin.
    wa_objpack-doc_size = ( lv_lin_bin - 1 ) * 255 + strlen( <wa_objbin> ) .
    wa_objpack-body_num = lv_lin_bin.
    wa_objpack-doc_type = 'PDF'.
    wa_objpack-obj_name = 'ATTACHMENT'.
    wa_objpack-obj_descr = p_ekko-ebeln.
    APPEND wa_objpack TO it_objpack.

    CALL FUNCTION 'SO_NEW_DOCUMENT_ATT_SEND_API1'
      EXPORTING
        document_data              = wa_doc_chng
        put_in_outbox              = 'X'
        commit_work                = 'X'
      TABLES
        packing_list               = it_objpack
        object_header              = wa_objhead
        contents_bin               = it_objbin
        contents_txt               = it_objtxt
        receivers                  = it_reclist
      EXCEPTIONS
        too_many_receivers         = 1
        document_not_sent          = 2
        document_type_not_exist    = 3
        operation_no_authorization = 4
        parameter_error            = 5
        x_error                    = 6
        enqueue_error              = 7
        OTHERS                     = 8.

    IF sy-subrc <> 0.
      MESSAGE i000(zmm_barcode) WITH TEXT-011 p_ekko-ebeln 'y Destinatario: ' gs_alv-smtp_addr.
      EXIT.
    ENDIF.
    MESSAGE s000(zmm_barcode) WITH TEXT-013 p_ekko-ebeln.
*      WAIT UP TO 2 SECONDS.
*      SUBMIT RSCONN01 WITH MODE = 'INT'
*      WITH OUTPUT = 'X'
*      AND RETURN.
  ELSE.

    MESSAGE i000(zmm_barcode) WITH TEXT-010 p_ekko-ebeln.
*        error handling
  ENDIF.


ENDFORM.                    " SEND_MAIL
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command INPUT.
  DATA lv_okcode TYPE sy-ucomm.
  lv_okcode = fcode.
  CLEAR fcode.
  CASE lv_okcode.
    WHEN 'BACK' OR 'CANCEL'.
      gv_noprint = 'X'.
      SET SCREEN 0.
    WHEN 'EXIT'.
      LEAVE PROGRAM.
    WHEN 'PRINT'.
      CLEAR gv_noprint.
      SET SCREEN 0.

  ENDCASE.

ENDMODULE.                 " USER_COMMAND  INPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
  SET PF-STATUS 'M0100'.
  SET TITLEBAR 'T1'.

ENDMODULE.                 " STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*&      Form  RECLIST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_IT_RECLIST  text
*      -->P_GS_ALV_SMTP_ADDR  text
*      <--P_WA_RECLIST  text
*----------------------------------------------------------------------*
FORM reclist  TABLES   pt_reclist STRUCTURE somlreci1
              USING    p_smtp_addr TYPE ad_smtpadr
              CHANGING pw_reclist TYPE somlreci1.

  CHECK p_smtp_addr IS NOT INITIAL.
  CLEAR pw_reclist.

  IF p_smtp_addr CS '@'.
    pw_reclist-receiver = p_smtp_addr."Dirección de Internet
    pw_reclist-rec_type = 'U'.
  ELSE.
    pw_reclist-receiver = p_smtp_addr."Usuarios Internos
    pw_reclist-rec_type = 'B'.
  ENDIF.
  APPEND pw_reclist TO pt_reclist.

ENDFORM.                    " RECLIST
*&---------------------------------------------------------------------*
*& Form f_fill_ranges
*&---------------------------------------------------------------------*
FORM f_fill_ranges .
  CLEAR: gr_bsart[], gr_bsartn[], gr_frgke[].

  " Tipo de documentos a considerar
  SELECT * FROM tvarvc
  INTO TABLE @DATA(lt_low)
        WHERE name = @gc_zmm_cb020.
  IF sy-subrc EQ 0.
    gr_bsart = VALUE #( FOR ls_low IN lt_low
                       ( sign    = ls_low-sign
                         option  = ls_low-opti
                         low     = ls_low-low
                         high    = ls_low-high ) ).
  ENDIF.

  " Tipo de documentos a considerar new
  SELECT * FROM tvarvc
  INTO TABLE @DATA(lt_low1)
        WHERE name = @gc_zmm_cb020n.
  IF sy-subrc EQ 0.
    gr_bsartn = VALUE #( FOR ls_low1 IN lt_low1
                       ( sign    = ls_low1-sign
                         option  = ls_low1-opti
                         low     = ls_low1-low
                         high    = ls_low1-high ) ).
  ENDIF.

  " Indicadores de liberado
  gr_frgke = VALUE #( sign    = |I|
                      option  = |EQ|
                    ( low     = |R| )
                    ( low     = |G| )
                    ).

*vmr01--> Tipo de documentos a considerar no liberados
  SELECT * FROM tvarvc
    INTO TABLE @DATA(lt_low2)
    WHERE name = 'ZMM_NO_LIB_CBF'.
  IF sy-subrc EQ 0.
    gr_frgken = VALUE #( FOR ls_low2 IN lt_low2
                       ( sign    = ls_low2-sign
                         option  = ls_low2-opti
                         low     = ls_low2-low
                         high    = ls_low2-high ) ).
  ENDIF.
*vmr01<--FIN

  " Sociedades a considerar
  SELECT * FROM tvarvc
  INTO TABLE @DATA(lt_tvarv)
        WHERE name = @gc_cb020n_bukrs.
  IF sy-subrc EQ 0.
    CLEAR: gr_bukrs[].

    gr_bukrs = VALUE #( FOR ls_tvarv IN lt_tvarv
                       ( sign    = ls_tvarv-sign
                         option  = ls_tvarv-opti
                         low     = ls_tvarv-low
                         high    = ls_tvarv-high ) ).
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form print
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM print .
  DATA: "it_agrupa        type tt_agrupa  WITH HEADER LINE,
    control          TYPE ssfctrlop,
    output_options   TYPE ssfcompop,
    user_settings    TYPE tdbool,
    v_e_devtype      TYPE rspoptype,
    ls_job_info      TYPE ssfcrescl,
    v_bin_filesize   TYPE i,
    fm_name          TYPE rs38l_fnam,
    l_xstring        TYPE xstring,
    lt_data          TYPE STANDARD TABLE OF x255,
    wa_data          TYPE x255,
    lv_url           TYPE char255,
    g_html_container TYPE REF TO cl_gui_custom_container,
    g_html_control   TYPE REF TO cl_gui_html_viewer.

  DATA: lt_poitems    TYPE STANDARD TABLE OF bapiekpo,
        l_num         TYPE i,
        bdcdata_wa    TYPE bdcdata,
        bdcdata_tab   TYPE TABLE OF bdcdata,
        lv_fname      TYPE rs38l_fnam,
        l_pedidos     TYPE char1,
        w_msg(100)    TYPE c,
        lw_data       TYPE tt_alv,
        lv_ebeln      TYPE ebeln,
        ls_ekko       TYPE ekko,
        lv_formname   TYPE tdsfname, "  VALUE 'ZMMSF_PEDIDO2',
        lv_srecipient TYPE swotobjid,
        lv_ssender    TYPE swotobjid,
        lv_sjob_info  TYPE ssfcrescl,
        lt_otf        TYPE TABLE OF itcoo,
        lv_subrc      LIKE sy-subrc.

*vmr
  SELECT SINGLE low FROM tvarvc
    INTO lv_formname
   WHERE name EQ TEXT-015.
*vmr

  IF s_bstyp-low EQ 'A'.
    lv_formname   = 'ZMMSF_PEDIDO3N'.
  ELSE.
    lv_formname   = 'ZMMSF_PEDIDO2N'.
  ENDIF.
**********************CARTA PORTE*************
  CALL FUNCTION 'SSF_GET_DEVICE_TYPE'
    EXPORTING
      i_language    = sy-langu
      i_application = 'SAPDEFAULT'
    IMPORTING
      e_devtype     = v_e_devtype.

  output_options-tdprinter = v_e_devtype.
  output_options-tdcopies  = 1.
  output_options-tdarmod   = 1.
  control-no_dialog        = 'X'.
  control-getotf           = 'X'.


*      CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
*      EXPORTING
*        formname           = c_smart
*      IMPORTING
*        fm_name            = fm_name
*      EXCEPTIONS
*        no_form            = 1
*        no_function_module = 2
*        OTHERS             = 3.
  CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
    EXPORTING
      formname           = lv_formname
    IMPORTING
      fm_name            = fm_name
    EXCEPTIONS
      no_form            = 1
      no_function_module = 2
      OTHERS             = 3.

  IF sy-subrc <> 0.
    CLEAR: l_xstring.
  ELSE.

    gt_seleccion[] = gt_alv[].
    DELETE gt_seleccion WHERE sel = ''.
    DESCRIBE TABLE gt_seleccion LINES l_num.

    IF l_num = 0.
      MESSAGE TEXT-012 TYPE 'E'.
      RETURN.
    ENDIF.

    w_msg = l_num.
    SHIFT w_msg LEFT DELETING LEADING space.
    MESSAGE s000(zmm_barcode) WITH TEXT-002 w_msg 'línea(s)'.
*carta porte*
    CLEAR wa_cp.
*carta porte*
    LOOP AT gt_seleccion INTO gs_alv.
      MOVE-CORRESPONDING gs_alv TO ls_ekko.

*******************************************************centro destino
      SELECT SINGLE werks
        INTO wa_cp-werksd
        FROM ekpo
        WHERE ebeln = ls_ekko-ebeln.

      SELECT SINGLE stras
         FROM t001w
         INTO wa_cp-strasd
         WHERE werks = wa_cp-werksd.

      SELECT SINGLE pstlz
        FROM t001w
        INTO wa_cp-pstlzd
        WHERE werks = wa_cp-werksd.

      SELECT SINGLE regio
        FROM t001w
        INTO wa_cp-regiod
        WHERE werks = wa_cp-werksd.

      SELECT SINGLE ort01
        FROM t001w
        INTO wa_cp-ort01d
        WHERE werks = wa_cp-werksd.
****************** CARTAPORTE **********************
      SELECT SINGLE bednr
        INTO wa_cp-unidad
        FROM ekpo
        WHERE ebeln = ls_ekko-ebeln.

      SELECT SINGLE reswk
        INTO wa_cp-werks
        FROM ekko
        WHERE ebeln = ls_ekko-ebeln.
*            wa_cp-werks = ls_ekko-reswk.
      SELECT SINGLE stras
        FROM t001w
        INTO wa_cp-stras
        WHERE werks = wa_cp-werks.


      SELECT SINGLE pstlz
        FROM t001w
        INTO wa_cp-pstlz
        WHERE werks = wa_cp-werks.

      SELECT SINGLE regio
        FROM t001w
        INTO wa_cp-regio
        WHERE werks = wa_cp-werks.

      SELECT SINGLE ort01
        FROM t001w
        INTO wa_cp-ort01
        WHERE werks = wa_cp-werks.

************************* datos unidad*******
      IF wa_cp-unidad NE space.

        SELECT SINGLE marca
             INTO wa_cp-marca
             FROM ztm_tt_lounits
             WHERE nounidad = wa_cp-unidad.

        SELECT SINGLE tipounidad
          INTO wa_cp-tipounidad
          FROM ztm_tt_lounits
          WHERE nounidad = wa_cp-unidad.

        SELECT SINGLE modelo
          INTO wa_cp-modelo
          FROM ztm_tt_lounits
          WHERE nounidad = wa_cp-unidad.

        SELECT SINGLE noplacas
          INTO wa_cp-noplacas
          FROM ztm_tt_lounits
          WHERE nounidad = wa_cp-unidad.

        SELECT SINGLE nooperador
          INTO wa_cp-nooperador
          FROM ztm_tt_lounits
          WHERE nounidad = wa_cp-unidad.


        SELECT SINGLE pernr
          INTO wa_cp-pernr
          FROM ztm_tt_lounits
          WHERE nounidad = wa_cp-unidad.

      ENDIF.

      IF wa_cp-pernr NE space.

        SELECT SINGLE icnum
          FROM pa0185
          INTO wa_cp-rfc
          WHERE pernr = wa_cp-pernr
            AND ictyp = '02'.

        SELECT SINGLE icnum
          FROM pa0185
          INTO wa_cp-lic
          WHERE pernr = wa_cp-pernr
            AND ictyp = '03'.

      ENDIF.


      IF wa_cp-noplacas NE space.

        SELECT SINGLE aseg_civil
          FROM zcarta_porte
          INTO wa_cp-asegura
          WHERE placas = wa_cp-noplacas.

        SELECT SINGLE poliza_civil
          FROM zcarta_porte
          INTO wa_cp-poliza
          WHERE placas = wa_cp-noplacas.

        SELECT SINGLE permiso_sct
          FROM zcarta_porte
          INTO wa_cp-permiso
          WHERE placas = wa_cp-noplacas.


      ENDIF.

****************** CARTAPORTE **********************
      CLEAR lv_sjob_info.
      REFRESH lv_sjob_info-otfdata[].
      CALL FUNCTION fm_name
        EXPORTING
          control_parameters = control
          output_options     = output_options
          user_settings      = user_settings
*         mail_appl_obj      =
          mail_recipient     = lv_srecipient
          mail_sender        = lv_ssender
*         output_options     = lv_scomposer_param
*         user_settings      = space
          ps_ekko            = ls_ekko
*CARTA PORTE
          ps_cp              = wa_cp
        IMPORTING
          job_output_info    = lv_sjob_info
        EXCEPTIONS
          formatting_error   = 1
          internal_error     = 2
          send_error         = 3
          user_canceled      = 4
          OTHERS             = 5.
      lv_subrc = sy-subrc.
      CASE lv_subrc .
        WHEN 1 .
          MESSAGE TEXT-003 TYPE 'E' .

        WHEN 2 .
          MESSAGE TEXT-004 TYPE 'E' .

        WHEN 3 .
          MESSAGE TEXT-005 TYPE 'E' .

        WHEN 4 .
          MESSAGE TEXT-006 TYPE 'S' .

        WHEN 5 .
          MESSAGE TEXT-007 TYPE 'E' .

      ENDCASE .
      CHECK lv_subrc EQ 0.
*vmr-->
      IF sy-ucomm EQ 'SENDM'.
        CLEAR lt_otf.
        lt_otf[] = lv_sjob_info-otfdata[].
        PERFORM send_mail TABLES lt_otf
                           USING ls_ekko .
*        RETURN.
      ENDIF.
*vmr<--
    ENDLOOP.
*          CALL FUNCTION fm_name
*           EXPORTING
*             control_parameters = control
*             output_options     = output_options
*             user_settings      = user_settings
*           IMPORTING
*             JOB_OUTPUT_INFO       = ls_job_info
*            TABLES
*              IT_REMISION          = gt_remision
*                    .
*          IF SY-SUBRC <> 0.
*          ENDIF.


    IF sy-subrc <> 0.
      CLEAR: l_xstring.
    ELSE.
*   convert to otf to PDF in xstring file
      DATA lt_lines TYPE TABLE OF tline.

      CLEAR: lt_lines[].

      CALL FUNCTION 'CONVERT_OTF'
        EXPORTING
          format                = 'PDF'
        IMPORTING
          bin_filesize          = v_bin_filesize
          bin_file              = l_xstring
        TABLES
          otf                   = lv_sjob_info-otfdata
          lines                 = lt_lines
        EXCEPTIONS
          err_max_linewidth     = 1
          err_format            = 2
          err_conv_not_possible = 3
          err_bad_otf           = 4
          OTHERS                = 5.

*        l_byte_out = l_xstring.

      IF sy-subrc <> 0.
        CLEAR: l_xstring.
      ENDIF.
    ENDIF.
  ENDIF.

  CALL FUNCTION 'SCMS_XSTRING_TO_BINARY'
    EXPORTING
      buffer     = l_xstring "xpdf
    TABLES
      binary_tab = lt_data.

  IF p_show = 'X' OR
     sy-ucomm EQ 'PDF'.

    FREE: g_html_container, g_html_control.

    CREATE OBJECT g_html_container
      EXPORTING
        container_name = 'PDF'.

    CREATE OBJECT g_html_control
      EXPORTING
        parent = g_html_container.

*   Load the HTML
    CALL METHOD g_html_control->load_data(
      EXPORTING
        type                 = 'application'
        subtype              = 'pdf'
      IMPORTING
        assigned_url         = lv_url
      CHANGING
        data_table           = lt_data
      EXCEPTIONS
        dp_invalid_parameter = 1
        dp_error_general     = 2
        cntl_error           = 3
        OTHERS               = 4 ).

*   Show it
    CALL METHOD g_html_control->show_url_in_browser( url = lv_url ).
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form f_validate_type
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM f_validate_type .
  IF s_bstyp-low IS NOT INITIAL AND s_bstyp-low NE 'A' AND s_bstyp-low NE 'F' OR s_bstyp-low IS INITIAL .
    MESSAGE e032(m7) WITH s_bstyp-low.
  ENDIF.
ENDFORM.
