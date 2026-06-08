CLASS zcl_des_bloqueo_proveedor DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES: BEGIN OF ty_log,
             lifnr  TYPE lifnr,
             bukrs  TYPE bukrs,
             ekorg  TYPE ekorg,
             level  TYPE char20,
             status TYPE char10,
             text   TYPE string,
           END OF ty_log,
           tt_log TYPE STANDARD TABLE OF ty_log WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_status,
             lifnr           TYPE lifnr,
             central_fi      TYPE abap_bool,
             central_mm      TYPE abap_bool,
             any_bukrs_block TYPE abap_bool,
             any_ekorg_block TYPE abap_bool,
             all_bukrs_block TYPE abap_bool,
             all_ekorg_block TYPE abap_bool,
           END OF ty_status.


    METHODS block_vendor
      IMPORTING
        iv_lifnr     TYPE lifnr
        iv_do_commit TYPE abap_bool DEFAULT abap_true
      EXPORTING
        et_log       TYPE tt_log
      RAISING
        zcx_des_bloqueo_proveedor.

    METHODS unblock_vendor
      IMPORTING
        iv_lifnr     TYPE lifnr
        iv_do_commit TYPE abap_bool DEFAULT abap_true
      EXPORTING
        et_log       TYPE tt_log
      RAISING
        zcx_des_bloqueo_proveedor.

    METHODS get_block_status
      IMPORTING
        iv_lifnr  TYPE lifnr
      EXPORTING
        es_status TYPE ty_status
      RAISING
        zcx_des_bloqueo_proveedor.


  PROTECTED SECTION.
  PRIVATE SECTION.

    METHODS set_vendor_status
      IMPORTING
        iv_lifnr     TYPE lifnr
        iv_block     TYPE abap_bool
        iv_do_commit TYPE abap_bool
      EXPORTING
        et_log       TYPE tt_log
      RAISING
        zcx_des_bloqueo_proveedor.

    METHODS get_general_data
      IMPORTING
        iv_lifnr    TYPE lifnr
      EXPORTING
        es_lfa1_old TYPE lfa1
        es_lfa1_new TYPE lfa1
      RAISING
        zcx_des_bloqueo_proveedor.

    METHODS update_general_data
      IMPORTING
        is_lfa1_old TYPE lfa1
        is_lfa1_new TYPE lfa1
        iv_lifnr    TYPE lifnr
      CHANGING
        ct_log      TYPE tt_log.

    METHODS update_company_codes
      IMPORTING
        iv_lifnr    TYPE lifnr
        is_lfa1_old TYPE lfa1
        is_lfa1_new TYPE lfa1
        iv_flag     TYPE c
      CHANGING
        ct_log      TYPE tt_log.

    METHODS update_purchasing_orgs
      IMPORTING
        iv_lifnr    TYPE lifnr
        is_lfa1_old TYPE lfa1
        is_lfa1_new TYPE lfa1
        iv_flag     TYPE c
      CHANGING
        ct_log      TYPE tt_log.

    METHODS verify_after_update
      IMPORTING
        iv_lifnr TYPE lifnr
        iv_flag  TYPE c
      CHANGING
        ct_log   TYPE tt_log.

    METHODS verify_general_data
      IMPORTING
        iv_lifnr TYPE lifnr
        iv_flag  TYPE c
      CHANGING
        ct_log   TYPE tt_log.

    METHODS verify_company_codes
      IMPORTING
        iv_lifnr TYPE lifnr
        iv_flag  TYPE c
      CHANGING
        ct_log   TYPE tt_log.

    METHODS verify_purchasing_orgs
      IMPORTING
        iv_lifnr TYPE lifnr
        iv_flag  TYPE c
      CHANGING
        ct_log   TYPE tt_log.

    METHODS add_log
      IMPORTING
        iv_lifnr  TYPE lifnr
        iv_bukrs  TYPE bukrs
        iv_ekorg  TYPE ekorg
        iv_level  TYPE char20
        iv_status TYPE char10
        iv_text   TYPE string
      CHANGING
        ct_log    TYPE tt_log.

    METHODS add_ddic_log
      IMPORTING
        zlifnr  TYPE lifnr
        zaction TYPE char8
        zuname  TYPE uname
        zdatum  TYPE datum
        zuzeit  TYPE uzeit
        zsource TYPE repid.

ENDCLASS.



CLASS ZCL_DES_BLOQUEO_PROVEEDOR IMPLEMENTATION.


  METHOD add_ddic_log.
    DATA wa TYPE zmm_log_bl_prov.

    wa-zlifnr = zlifnr.
    wa-zaction = zaction.
    wa-zuname = zuname.
    wa-zdatum = zdatum.
    wa-zuzeit = zuzeit.
    wa-zsource = zsource.

    TRY.
        INSERT zmm_log_bl_prov FROM wa.
      CATCH zcx_des_bloqueo_proveedor INTO DATA(cx).
        WRITE cx->mv_text.
    ENDTRY.


  ENDMETHOD.


  METHOD add_log.

    APPEND VALUE #(
      lifnr  = iv_lifnr
      bukrs  = iv_bukrs
      ekorg  = iv_ekorg
      level  = iv_level
      status = iv_status
      text   = iv_text
    ) TO ct_log.

  ENDMETHOD.


  METHOD block_vendor.
    me->set_vendor_status(
      EXPORTING
        iv_lifnr     = iv_lifnr
        iv_block     = abap_true
        iv_do_commit = iv_do_commit
      IMPORTING
        et_log       = et_log
    ).
  ENDMETHOD.


  METHOD get_block_status.

    DATA: ls_lfa1 TYPE lfa1,
          lt_lfb1 TYPE STANDARD TABLE OF lfb1,
          lt_lfm1 TYPE STANDARD TABLE OF lfm1,
          ls_lfb1 TYPE lfb1,
          ls_lfm1 TYPE lfm1.

    CLEAR es_status.
    es_status-lifnr = iv_lifnr.

    "-----------------------------------
    " LFA1 (bloqueos centrales)
    "-----------------------------------
    SELECT SINGLE *
      INTO ls_lfa1
      FROM lfa1
     WHERE lifnr = iv_lifnr.

    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE zcx_des_bloqueo_proveedor
        EXPORTING
          iv_text = |Proveedor { iv_lifnr } no existe|.
    ENDIF.

    es_status-central_fi = xsdbool( ls_lfa1-sperr = 'X' ).
    es_status-central_mm = xsdbool( ls_lfa1-sperm = 'X' ).

    "-----------------------------------
    " LFB1 (sociedades)
    "-----------------------------------
    SELECT *
      INTO TABLE lt_lfb1
      FROM lfb1
     WHERE lifnr = iv_lifnr.

    IF lt_lfb1 IS NOT INITIAL.

      DATA(lv_total_bukrs) = lines( lt_lfb1 ).
      DATA(lv_block_bukrs) = 0.

      LOOP AT lt_lfb1 INTO ls_lfb1.
        IF ls_lfb1-sperr = 'X'.
          lv_block_bukrs = lv_block_bukrs + 1.
        ENDIF.
      ENDLOOP.

      es_status-any_bukrs_block = xsdbool( lv_block_bukrs > 0 ).
      es_status-all_bukrs_block = xsdbool( lv_block_bukrs = lv_total_bukrs ).

    ENDIF.

    "-----------------------------------
    " LFM1 (org. compras)
    "-----------------------------------
    SELECT *
      INTO TABLE lt_lfm1
      FROM lfm1
     WHERE lifnr = iv_lifnr.

    IF lt_lfm1 IS NOT INITIAL.

      DATA(lv_total_ekorg) = lines( lt_lfm1 ).
      DATA(lv_block_ekorg) = 0.

      LOOP AT lt_lfm1 INTO ls_lfm1.
        IF ls_lfm1-sperm = 'X'.
          lv_block_ekorg = lv_block_ekorg + 1.
        ENDIF.
      ENDLOOP.

      es_status-any_ekorg_block = xsdbool( lv_block_ekorg > 0 ).
      es_status-all_ekorg_block = xsdbool( lv_block_ekorg = lv_total_ekorg ).

    ENDIF.

  ENDMETHOD.


  METHOD get_general_data.

    SELECT SINGLE *
      INTO es_lfa1_old
      FROM lfa1
     WHERE lifnr = iv_lifnr.

    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE zcx_des_bloqueo_proveedor
        EXPORTING
          iv_text = |Proveedor { iv_lifnr } no existe en LFA1|.
    ENDIF.

    es_lfa1_new = es_lfa1_old.

  ENDMETHOD.


  METHOD set_vendor_status.

    DATA: lv_flag     TYPE c LENGTH 1,
          ls_lfa1_old TYPE lfa1,
          ls_lfa1_new TYPE lfa1.

    CLEAR et_log.

    IF iv_block = abap_true.
      lv_flag = 'X'.
    ELSE.
      CLEAR lv_flag.
    ENDIF.

    me->get_general_data(
      EXPORTING
        iv_lifnr    = iv_lifnr
      IMPORTING
        es_lfa1_old = ls_lfa1_old
        es_lfa1_new = ls_lfa1_new
    ).

    ls_lfa1_new-sperr = lv_flag.
    ls_lfa1_new-sperm = lv_flag.

    me->update_general_data(
      EXPORTING
        is_lfa1_old = ls_lfa1_old
        is_lfa1_new = ls_lfa1_new
        iv_lifnr    = iv_lifnr
      CHANGING
        ct_log      = et_log
    ).

    me->update_company_codes(
      EXPORTING
        iv_lifnr    = iv_lifnr
        is_lfa1_old = ls_lfa1_old
        is_lfa1_new = ls_lfa1_new
        iv_flag     = lv_flag
      CHANGING
        ct_log      = et_log
    ).

    me->update_purchasing_orgs(
      EXPORTING
        iv_lifnr    = iv_lifnr
        is_lfa1_old = ls_lfa1_old
        is_lfa1_new = ls_lfa1_new
        iv_flag     = lv_flag
      CHANGING
        ct_log      = et_log
    ).

    IF iv_do_commit = abap_true.
      COMMIT WORK AND WAIT.

      me->add_log(
        EXPORTING
          iv_lifnr  = iv_lifnr
          iv_bukrs  = space
          iv_ekorg  = space
          iv_level  = 'COMMIT'
          iv_status = 'OK'
          iv_text   = 'COMMIT WORK AND WAIT ejecutado'
        CHANGING
          ct_log    = et_log
      ).

      me->add_ddic_log(
        zlifnr  = iv_lifnr
        zaction = COND #( WHEN iv_block = abap_true THEN 'BLOCK' ELSE 'UNBLOCK' )
      zuname  = sy-uname
      zdatum  = sy-datum
      zuzeit  = sy-uzeit
      zsource = sy-repid
    ).

      me->verify_after_update(
        EXPORTING
          iv_lifnr = iv_lifnr
          iv_flag  = lv_flag
        CHANGING
          ct_log   = et_log
      ).

    ELSE.
      me->add_log(
        EXPORTING
          iv_lifnr  = iv_lifnr
          iv_bukrs  = space
          iv_ekorg  = space
          iv_level  = 'COMMIT'
          iv_status = 'PENDING'
          iv_text   = 'Actualizaciones registradas en update task; commit pendiente'
        CHANGING
          ct_log    = et_log
      ).
    ENDIF.

  ENDMETHOD.


  METHOD unblock_vendor.
    me->set_vendor_status(
      EXPORTING
        iv_lifnr     = iv_lifnr
        iv_block     = abap_false
        iv_do_commit = iv_do_commit
      IMPORTING
        et_log       = et_log
    ).
  ENDMETHOD.


  METHOD update_company_codes.

    DATA: lt_lfb1_old       TYPE STANDARD TABLE OF lfb1,
          ls_lfb1_old       TYPE lfb1,
          ls_lfb1_new       TYPE lfb1,
          ls_dummy_lfm1_old TYPE lfm1,
          ls_dummy_lfm1_new TYPE lfm1,
          lt_xlfas          TYPE STANDARD TABLE OF flfas,
          lt_ylfas          TYPE STANDARD TABLE OF flfas,
          lt_xlfb5          TYPE STANDARD TABLE OF flfb5,
          lt_ylfb5          TYPE STANDARD TABLE OF flfb5,
          lt_xlfbk          TYPE STANDARD TABLE OF flfbk,
          lt_ylfbk          TYPE STANDARD TABLE OF flfbk,
          lt_xlfza          TYPE STANDARD TABLE OF flfza,
          lt_ylfza          TYPE STANDARD TABLE OF flfza.

    SELECT *
      INTO TABLE lt_lfb1_old
      FROM lfb1
     WHERE lifnr = iv_lifnr.

    IF lt_lfb1_old IS INITIAL.
      me->add_log(
        EXPORTING
          iv_lifnr  = iv_lifnr
          iv_bukrs  = space
          iv_ekorg  = space
          iv_level  = 'BUKRS'
          iv_status = 'INFO'
          iv_text   = 'No existen sociedades para el proveedor'
        CHANGING
          ct_log    = ct_log
      ).
      RETURN.
    ENDIF.

    LOOP AT lt_lfb1_old INTO ls_lfb1_old.
      ls_lfb1_new = ls_lfb1_old.
      ls_lfb1_new-sperr = iv_flag.

      CALL FUNCTION 'VENDOR_UPDATE' IN UPDATE TASK
        EXPORTING
          i_lfa1  = is_lfa1_new
          i_lfb1  = ls_lfb1_new
          i_lfm1  = ls_dummy_lfm1_new
          i_ylfa1 = is_lfa1_old
          i_ylfb1 = ls_lfb1_old
          i_ylfm1 = ls_dummy_lfm1_old
        TABLES
          t_xlfas = lt_xlfas
          t_xlfb5 = lt_xlfb5
          t_xlfbk = lt_xlfbk
          t_xlfza = lt_xlfza
          t_ylfas = lt_ylfas
          t_ylfb5 = lt_ylfb5
          t_ylfbk = lt_ylfbk
          t_ylfza = lt_ylfza.

      me->add_log(
        EXPORTING
          iv_lifnr  = iv_lifnr
          iv_bukrs  = ls_lfb1_old-bukrs
          iv_ekorg  = space
          iv_level  = 'BUKRS'
          iv_status = 'QUEUED'
          iv_text   = |Actualizacion registrada para sociedad { ls_lfb1_old-bukrs }|
        CHANGING
          ct_log    = ct_log
      ).
    ENDLOOP.

  ENDMETHOD.


  METHOD update_general_data.

    DATA: ls_dummy_lfb1_old TYPE lfb1,
          ls_dummy_lfb1_new TYPE lfb1,
          ls_dummy_lfm1_old TYPE lfm1,
          ls_dummy_lfm1_new TYPE lfm1,
          lt_xlfas          TYPE STANDARD TABLE OF flfas,
          lt_ylfas          TYPE STANDARD TABLE OF flfas,
          lt_xlfb5          TYPE STANDARD TABLE OF flfb5,
          lt_ylfb5          TYPE STANDARD TABLE OF flfb5,
          lt_xlfbk          TYPE STANDARD TABLE OF flfbk,
          lt_ylfbk          TYPE STANDARD TABLE OF flfbk,
          lt_xlfza          TYPE STANDARD TABLE OF flfza,
          lt_ylfza          TYPE STANDARD TABLE OF flfza.

    CALL FUNCTION 'VENDOR_UPDATE' IN UPDATE TASK
      EXPORTING
        i_lfa1  = is_lfa1_new
        i_lfb1  = ls_dummy_lfb1_new
        i_lfm1  = ls_dummy_lfm1_new
        i_ylfa1 = is_lfa1_old
        i_ylfb1 = ls_dummy_lfb1_old
        i_ylfm1 = ls_dummy_lfm1_old
      TABLES
        t_xlfas = lt_xlfas
        t_xlfb5 = lt_xlfb5
        t_xlfbk = lt_xlfbk
        t_xlfza = lt_xlfza
        t_ylfas = lt_ylfas
        t_ylfb5 = lt_ylfb5
        t_ylfbk = lt_ylfbk
        t_ylfza = lt_ylfza.

    me->add_log(
      EXPORTING
        iv_lifnr  = iv_lifnr
        iv_bukrs  = space
        iv_ekorg  = space
        iv_level  = 'GENERAL'
        iv_status = 'QUEUED'
        iv_text   = 'Actualizacion general registrada en update task'
      CHANGING
        ct_log    = ct_log
    ).

  ENDMETHOD.


  METHOD update_purchasing_orgs.

    DATA: lt_lfm1_old       TYPE STANDARD TABLE OF lfm1,
          ls_lfm1_old       TYPE lfm1,
          ls_lfm1_new       TYPE lfm1,
          ls_dummy_lfb1_old TYPE lfb1,
          ls_dummy_lfb1_new TYPE lfb1,
          lt_xlfas          TYPE STANDARD TABLE OF flfas,
          lt_ylfas          TYPE STANDARD TABLE OF flfas,
          lt_xlfb5          TYPE STANDARD TABLE OF flfb5,
          lt_ylfb5          TYPE STANDARD TABLE OF flfb5,
          lt_xlfbk          TYPE STANDARD TABLE OF flfbk,
          lt_ylfbk          TYPE STANDARD TABLE OF flfbk,
          lt_xlfza          TYPE STANDARD TABLE OF flfza,
          lt_ylfza          TYPE STANDARD TABLE OF flfza.

    SELECT *
      INTO TABLE lt_lfm1_old
      FROM lfm1
     WHERE lifnr = iv_lifnr.

    IF lt_lfm1_old IS INITIAL.
      me->add_log(
        EXPORTING
          iv_lifnr  = iv_lifnr
          iv_bukrs  = space
          iv_ekorg  = space
          iv_level  = 'EKORG'
          iv_status = 'INFO'
          iv_text   = 'No existen organizaciones de compras para el proveedor'
        CHANGING
          ct_log    = ct_log
      ).
      RETURN.
    ENDIF.

    LOOP AT lt_lfm1_old INTO ls_lfm1_old.
      ls_lfm1_new = ls_lfm1_old.
      ls_lfm1_new-sperm = iv_flag.

      CALL FUNCTION 'VENDOR_UPDATE' IN UPDATE TASK
        EXPORTING
          i_lfa1  = is_lfa1_new
          i_lfb1  = ls_dummy_lfb1_new
          i_lfm1  = ls_lfm1_new
          i_ylfa1 = is_lfa1_old
          i_ylfb1 = ls_dummy_lfb1_old
          i_ylfm1 = ls_lfm1_old
        TABLES
          t_xlfas = lt_xlfas
          t_xlfb5 = lt_xlfb5
          t_xlfbk = lt_xlfbk
          t_xlfza = lt_xlfza
          t_ylfas = lt_ylfas
          t_ylfb5 = lt_ylfb5
          t_ylfbk = lt_ylfbk
          t_ylfza = lt_ylfza.

      me->add_log(
        EXPORTING
          iv_lifnr  = iv_lifnr
          iv_bukrs  = space
          iv_ekorg  = ls_lfm1_old-ekorg
          iv_level  = 'EKORG'
          iv_status = 'QUEUED'
          iv_text   = |Actualizacion registrada para org. compras { ls_lfm1_old-ekorg }|
        CHANGING
          ct_log    = ct_log
      ).
    ENDLOOP.

  ENDMETHOD.


  METHOD verify_after_update.
    me->verify_general_data(
      EXPORTING
        iv_lifnr = iv_lifnr
        iv_flag  = iv_flag
      CHANGING
        ct_log   = ct_log
    ).

    me->verify_company_codes(
      EXPORTING
        iv_lifnr = iv_lifnr
        iv_flag  = iv_flag
      CHANGING
        ct_log   = ct_log
    ).

    me->verify_purchasing_orgs(
      EXPORTING
        iv_lifnr = iv_lifnr
        iv_flag  = iv_flag
      CHANGING
        ct_log   = ct_log
    ).
  ENDMETHOD.


  METHOD verify_company_codes.

    DATA lt_lfb1 TYPE STANDARD TABLE OF lfb1.
    DATA ls_lfb1 TYPE lfb1.

    SELECT *
      INTO TABLE lt_lfb1
      FROM lfb1
     WHERE lifnr = iv_lifnr.

    IF lt_lfb1 IS INITIAL.
      me->add_log(
        EXPORTING
          iv_lifnr  = iv_lifnr
          iv_bukrs  = space
          iv_ekorg  = space
          iv_level  = 'VERIFY_BUKRS'
          iv_status = 'INFO'
          iv_text   = 'No existen registros LFB1 para verificar'
        CHANGING
          ct_log    = ct_log
      ).
      RETURN.
    ENDIF.

    LOOP AT lt_lfb1 INTO ls_lfb1.
      IF ls_lfb1-sperr = iv_flag.
        me->add_log(
          EXPORTING
            iv_lifnr  = iv_lifnr
            iv_bukrs  = ls_lfb1-bukrs
            iv_ekorg  = space
            iv_level  = 'VERIFY_BUKRS'
            iv_status = 'OK'
            iv_text   = |Sociedad { ls_lfb1-bukrs } verificada|
          CHANGING
            ct_log    = ct_log
        ).
      ELSE.
        me->add_log(
          EXPORTING
            iv_lifnr  = iv_lifnr
            iv_bukrs  = ls_lfb1-bukrs
            iv_ekorg  = space
            iv_level  = 'VERIFY_BUKRS'
            iv_status = 'ERROR'
            iv_text   = |Sociedad { ls_lfb1-bukrs } no quedo con SPERR esperado|
          CHANGING
            ct_log    = ct_log
        ).
      ENDIF.
    ENDLOOP.

  ENDMETHOD.


  METHOD verify_general_data.

    DATA ls_lfa1 TYPE lfa1.

    SELECT SINGLE *
      INTO ls_lfa1
      FROM lfa1
     WHERE lifnr = iv_lifnr.

    IF sy-subrc <> 0.
      me->add_log(
        EXPORTING
          iv_lifnr  = iv_lifnr
          iv_bukrs  = space
          iv_ekorg  = space
          iv_level  = 'VERIFY_GEN'
          iv_status = 'ERROR'
          iv_text   = 'No fue posible releer LFA1 despues del commit'
        CHANGING
          ct_log    = ct_log
      ).
      RETURN.
    ENDIF.

    IF ls_lfa1-sperr = iv_flag AND ls_lfa1-sperm = iv_flag.
      me->add_log(
        EXPORTING
          iv_lifnr  = iv_lifnr
          iv_bukrs  = space
          iv_ekorg  = space
          iv_level  = 'VERIFY_GEN'
          iv_status = 'OK'
          iv_text   = 'LFA1 verificado correctamente'
        CHANGING
          ct_log    = ct_log
      ).
    ELSE.
      me->add_log(
        EXPORTING
          iv_lifnr  = iv_lifnr
          iv_bukrs  = space
          iv_ekorg  = space
          iv_level  = 'VERIFY_GEN'
          iv_status = 'ERROR'
          iv_text   = |LFA1 inconsistente. SPERR={ ls_lfa1-sperr } SPERM={ ls_lfa1-sperm }|
        CHANGING
          ct_log    = ct_log
      ).
    ENDIF.

  ENDMETHOD.


  METHOD verify_purchasing_orgs.

    DATA lt_lfm1 TYPE STANDARD TABLE OF lfm1.
    DATA ls_lfm1 TYPE lfm1.

    SELECT *
      INTO TABLE lt_lfm1
      FROM lfm1
     WHERE lifnr = iv_lifnr.

    IF lt_lfm1 IS INITIAL.
      me->add_log(
        EXPORTING
          iv_lifnr  = iv_lifnr
          iv_bukrs  = space
          iv_ekorg  = space
          iv_level  = 'VERIFY_EKORG'
          iv_status = 'INFO'
          iv_text   = 'No existen registros LFM1 para verificar'
        CHANGING
          ct_log    = ct_log
      ).
      RETURN.
    ENDIF.

    LOOP AT lt_lfm1 INTO ls_lfm1.
      IF ls_lfm1-sperm = iv_flag.
        me->add_log(
          EXPORTING
            iv_lifnr  = iv_lifnr
            iv_bukrs  = space
            iv_ekorg  = ls_lfm1-ekorg
            iv_level  = 'VERIFY_EKORG'
            iv_status = 'OK'
            iv_text   = |Org. compras { ls_lfm1-ekorg } verificada|
          CHANGING
            ct_log    = ct_log
        ).
      ELSE.
        me->add_log(
          EXPORTING
            iv_lifnr  = iv_lifnr
            iv_bukrs  = space
            iv_ekorg  = ls_lfm1-ekorg
            iv_level  = 'VERIFY_EKORG'
            iv_status = 'ERROR'
            iv_text   = |Org. compras { ls_lfm1-ekorg } no quedo con SPERM esperado|
          CHANGING
            ct_log    = ct_log
        ).
      ENDIF.
    ENDLOOP.

  ENDMETHOD.
ENDCLASS.
