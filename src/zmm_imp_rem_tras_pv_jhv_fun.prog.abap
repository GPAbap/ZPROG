*&---------------------------------------------------------------------*
*& Include          ZMM_IMP_REM_TRAS_PV_JHV_FUN
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form consultar_pedido
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM consultar_pedido .

  DATA: pos_nr   TYPE posnr, vl_ebelp TYPE ebelp, vl_index TYPE sy-tabix.

  DATA: it_poitem     TYPE STANDARD TABLE OF bapimepoitem,
        it_potextitem TYPE STANDARD TABLE OF bapimepotext.


  DATA: vl_caseta    TYPE string,
        vl_zona      TYPE string,
        vl_pigmento  TYPE string,
        vl_ppromedio TYPE string,
        vl_obs_cab type string.

  SELECT t~name1 AS zcliente, t~ort01 AS zdireccion, t~ort01 AS zdestino,
    h~ebeln AS zid_portal,
    h~ebeln AS zpedido_sap, bedat AS zfecha,
    bedat AS zfecha_entr, l~erzet AS zhora_entr,
    '      ' AS zcant_mh10,'      ' AS zcant_mh20,'      ' AS zcant_mh30,
  '     ' AS zpeso_prom10,'     ' AS zpeso_prom20,'     ' AS zpeso_prom30,
  '    ' AS zpigmento10,'    ' AS zpigmento20,'    ' AS zpigmento30,
  l~erzet AS zhr_lleg_cte,
  ' ' AS zzona_carga10,' ' AS zzona_carga20,' ' AS zzona_carga30,
  p~werks AS zno_granja10,p~werks AS zno_granja20,p~werks AS zno_granja30,
  '      ' AS zcaseta10,'      ' AS zcaseta20,'      ' AS zcaseta30,
  '      ' AS zlote10,'        ' AS zlote20,'        ' AS zlote30,
  '      ' AS zedad10,'     ' AS zedad20,'     ' AS zedad30,
  '                                                         ' AS zobservaciones,
    menge AS zkwmeng,
    concat( p~ebeln, p~ebelp ) AS txid, p~ebelp AS posnr, l~spart,
  CASE WHEN l~spart EQ '92' THEN 'M' ELSE
  CASE WHEN l~spart EQ '91' THEN 'H' ELSE
  CASE WHEN l~spart EQ '93' THEN 'R' ELSE
  CASE WHEN l~spart EQ '94' THEN 'HL' ELSE ts~vtext END END END END  AS txtspart

    FROM ekko AS h
    INNER JOIN ekpo AS p ON p~ebeln = h~ebeln
    INNER JOIN t001w AS t ON t~werks = p~werks
    LEFT JOIN lips AS l ON l~vgbel EQ h~ebeln
    INNER JOIN tspat AS ts ON ts~spart EQ l~spart AND ts~spras = 'S'
    WHERE h~ebeln EQ @p_belnr
   INTO CORRESPONDING FIELDS OF TABLE @it_remision.

  DELETE ADJACENT DUPLICATES FROM it_remision COMPARING ALL FIELDS.

  LOOP AT it_remision ASSIGNING FIELD-SYMBOL(<fs_wa>).
    ASSIGN COMPONENT 'ZPEDIDO_SAP' OF STRUCTURE <fs_wa> TO FIELD-SYMBOL(<fs_field>).
    vl_tdname = <fs_field>.

    ASSIGN COMPONENT 'POSNR' OF STRUCTURE <fs_wa> TO <fs_field>.
    pos_nr = <fs_field>.
    vl_ebelp = |{ pos_nr ALPHA = OUT }|.

    ASSIGN COMPONENT 'POSNR' OF STRUCTURE <fs_wa> TO <fs_field>.
    vl_posnr = <fs_field>.

    ASSIGN COMPONENT 'zhora_entr' OF STRUCTURE <fs_wa> TO <fs_field>.
    lv_timestamp = <fs_field>.

    CONCATENATE lv_timestamp+0(2)':' lv_timestamp+2(2) INTO lv_timestamp.
    <fs_field> = lv_timestamp.

    PERFORM get_textos USING 'F05'
                                 vl_tdname
                                 vl_posnr
                                 'EKKO'
               CHANGING vl_obs_cab
                        vl_caseta
                        vl_zona
                        vl_pigmento
                        vl_ppromedio.

    ASSIGN COMPONENT 'ZOBSERVACIONES' OF STRUCTURE <fs_wa> TO <fs_field>.
    <fs_field> = vl_obs_cab.

    "textos de posicion

    PERFORM get_textos USING 'F01'
                             vl_tdname
                             vl_posnr
                             'EKPO'
           CHANGING vl_obs_cab
                    vl_caseta
                    vl_zona
                    vl_pigmento
                    vl_ppromedio.

*    "CASETA
    CASE vl_posnr.
      WHEN '000010'.
        ASSIGN COMPONENT 'ZCASETA10' OF STRUCTURE <fs_wa> TO <fs_field>.
        vl_caseta10 = vl_caseta.
        <fs_field> = vl_caseta.
      WHEN '000020'.
        ASSIGN COMPONENT 'ZCASETA20' OF STRUCTURE <fs_wa> TO <fs_field>.
        vl_caseta20 = vl_caseta.
        <fs_field> = vl_caseta.
      WHEN '000030'.
        ASSIGN COMPONENT 'ZCASETA30' OF STRUCTURE <fs_wa> TO <fs_field>.
        vl_caseta30 = vl_caseta.
        <fs_field> = vl_caseta.
      WHEN OTHERS.
    ENDCASE.

    PERFORM get_textos USING 'F02'
                                 vl_tdname
                                 vl_posnr
                                 'EKPO'
               CHANGING vl_obs_cab
                        vl_caseta
                        vl_zona
                        vl_pigmento
                        vl_ppromedio.


    "ZONA DE CARGA

    CASE vl_posnr.
      WHEN '000010'.
        ASSIGN COMPONENT 'ZZONA_CARGA10' OF STRUCTURE <fs_wa> TO <fs_field>.
        vl_zona10 = vl_zona.
        <fs_field> = vl_zona.

        ASSIGN COMPONENT 'ZPIGMENTO10' OF STRUCTURE <fs_wa> TO <fs_field>.
        vl_pigmento10 =  vl_pigmento.
        <fs_field> = vl_pigmento.

        ASSIGN COMPONENT 'ZPESO_PROM10' OF STRUCTURE <fs_wa> TO <fs_field>.
        vl_pp10 = vl_ppromedio.
        <fs_field> = vl_ppromedio.

*         ASSIGN COMPONENT 'ZEDAD10' OF STRUCTURE <fs_wa> TO <fs_field>.
*         vl_edad10 = wa_p-text_line.
*         <fs_field> = wa_p-text_line.
*

      WHEN '000020'.
        ASSIGN COMPONENT 'ZZONA_CARGA20' OF STRUCTURE <fs_wa> TO <fs_field>.
        vl_zona20 = vl_zona.
        <fs_field> = vl_zona.

        ASSIGN COMPONENT 'ZPIGMENTO20' OF STRUCTURE <fs_wa> TO <fs_field>.
        vl_pigmento20 =  vl_pigmento.
        <fs_field> = vl_pigmento.

        ASSIGN COMPONENT 'ZPESO_PROM20' OF STRUCTURE <fs_wa> TO <fs_field>.
        vl_pp20 = vl_ppromedio.
        <fs_field> = vl_ppromedio.

      WHEN '000030'.

        ASSIGN COMPONENT 'ZZONA_CARGA30' OF STRUCTURE <fs_wa> TO <fs_field>.
        vl_zona30 = vl_zona.
        <fs_field> = vl_zona.

        ASSIGN COMPONENT 'ZPIGMENTO30' OF STRUCTURE <fs_wa> TO <fs_field>.
        vl_pigmento30 =  vl_pigmento.
        <fs_field> = vl_pigmento.

        ASSIGN COMPONENT 'ZPESO_PROM30' OF STRUCTURE <fs_wa> TO <fs_field>.
        vl_pp30 = vl_ppromedio.
        <fs_field> = vl_ppromedio.

      WHEN OTHERS.
    ENDCASE.


    PERFORM get_detalle USING vl_tdname
                              vl_posnr
                 CHANGING vl_valor
                         it_potextitem
                         it_poitem  .

    "se suma la cantidad de las posiciones
    READ TABLE it_poitem INTO DATA(wa_item) WITH KEY vl_ebelp.
    CASE vl_posnr.
      WHEN '000010'.
        ASSIGN COMPONENT 'ZCANT_MH10' OF STRUCTURE <fs_wa> TO <fs_field>.
        vl_cant10 = wa_item-quantity.
        <fs_field> = wa_item-quantity.
        vl_total_aves = vl_total_aves + <fs_field>.
        SPLIT vl_cant10 AT '.' INTO vl_cant10 vl_cantidad_mh.
        CONDENSE vl_cant10 NO-GAPS.
        CONDENSE <fs_field> NO-GAPS.

        ASSIGN COMPONENT 'ZLOTE10' OF STRUCTURE <fs_wa> TO <fs_field>.
        vl_lote10 = wa_item-batch.
        <fs_field> = wa_item-batch.

      WHEN '000020'.
        ASSIGN COMPONENT 'ZCANT_MH20' OF STRUCTURE <fs_wa> TO <fs_field>.
        vl_cant20 = wa_item-quantity.
        <fs_field> = vl_cant20.
        vl_total_aves = vl_total_aves + <fs_field>.
        SPLIT vl_cant20 AT '.' INTO vl_cant20 vl_cantidad_mh.
        "translate vl_cant20 using '.'.
        CONDENSE vl_cant20 NO-GAPS.
        CONDENSE <fs_field> NO-GAPS.

        ASSIGN COMPONENT 'ZLOTE20' OF STRUCTURE <fs_wa> TO <fs_field>.
        vl_lote20 = wa_item-batch.
        <fs_field> = wa_item-batch.

      WHEN '000030'.
        ASSIGN COMPONENT 'ZCANT_MH30' OF STRUCTURE <fs_wa> TO <fs_field>.
        vl_cant30 = wa_item-quantity.
        <fs_field> = vl_cant30.
        SPLIT vl_cant30 AT '.' INTO vl_cant30 vl_cantidad_mh.
        " translate vl_cant30 using '.'.
        CONDENSE vl_cant30 NO-GAPS.
        CONDENSE <fs_field> NO-GAPS.

        ASSIGN COMPONENT 'ZLOTE30' OF STRUCTURE <fs_wa> TO <fs_field>.
        vl_lote30 = wa_item-batch.
        <fs_field> = wa_item-batch.

      WHEN OTHERS.
    ENDCASE.



  ENDLOOP.
  DELETE ADJACENT DUPLICATES FROM it_remision COMPARING zcliente.

  LOOP AT it_remision ASSIGNING <fs_wa>.
    ASSIGN COMPONENT 'ZCANT_MH10' OF STRUCTURE <fs_wa> TO <fs_field>.
    <fs_field> = vl_cant10.
    ASSIGN COMPONENT 'ZCANT_MH20' OF STRUCTURE <fs_wa> TO <fs_field>.
    <fs_field> = vl_cant20.
    ASSIGN COMPONENT 'ZCANT_MH30' OF STRUCTURE <fs_wa> TO <fs_field>.
    <fs_field> = vl_cant30.

    ASSIGN COMPONENT 'ZPESO_PROM10' OF STRUCTURE <fs_wa> TO <fs_field>.
    <fs_field> = vl_pp10.
    ASSIGN COMPONENT 'ZPESO_PROM20' OF STRUCTURE <fs_wa> TO <fs_field>.
    <fs_field> = vl_pp20.
    ASSIGN COMPONENT 'ZPESO_PROM30' OF STRUCTURE <fs_wa> TO <fs_field>.
    <fs_field> = vl_pp30.

    ASSIGN COMPONENT 'ZPIGMENTO10' OF STRUCTURE <fs_wa> TO <fs_field>.
    <fs_field> = vl_pigmento10.
    ASSIGN COMPONENT 'ZPIGMENTO20' OF STRUCTURE <fs_wa> TO <fs_field>.
    <fs_field> = vl_pigmento20.
    ASSIGN COMPONENT 'ZPIGMENTO30' OF STRUCTURE <fs_wa> TO <fs_field>.
    <fs_field> =  vl_pigmento30.

    ASSIGN COMPONENT 'ZZONA_CARGA10' OF STRUCTURE <fs_wa> TO <fs_field>.
    <fs_field> = vl_zona10.
    ASSIGN COMPONENT 'ZZONA_CARGA20' OF STRUCTURE <fs_wa> TO <fs_field>.
    <fs_field> = vl_zona20.
    ASSIGN COMPONENT 'ZZONA_CARGA30' OF STRUCTURE <fs_wa> TO <fs_field>.
    <fs_field> = vl_zona30.

    ASSIGN COMPONENT 'ZCASETA10' OF STRUCTURE <fs_wa> TO <fs_field>.
    <fs_field> = vl_caseta10.
    ASSIGN COMPONENT 'ZCASETA20' OF STRUCTURE <fs_wa> TO <fs_field>.
    <fs_field> = vl_caseta20.
    ASSIGN COMPONENT 'ZCASETA30' OF STRUCTURE <fs_wa> TO <fs_field>.
    <fs_field> = vl_caseta30.

    ASSIGN COMPONENT 'ZLOTE10' OF STRUCTURE <fs_wa> TO <fs_field>.
    <fs_field> = vl_lote10.
    ASSIGN COMPONENT 'ZLOTE20' OF STRUCTURE <fs_wa> TO <fs_field>.
    <fs_field> = vl_lote20.
    ASSIGN COMPONENT 'ZLOTE30' OF STRUCTURE <fs_wa> TO <fs_field>.
    <fs_field> = vl_lote30.

    ASSIGN COMPONENT 'ZEDAD10' OF STRUCTURE <fs_wa> TO <fs_field>.
    <fs_field> = vl_edad10.
    ASSIGN COMPONENT 'ZEDAD20' OF STRUCTURE <fs_wa> TO <fs_field>.
    <fs_field> = vl_edad20.
    ASSIGN COMPONENT 'ZEDAD30' OF STRUCTURE <fs_wa> TO <fs_field>.
    <fs_field> = vl_edad30.
  ENDLOOP.

  PERFORM cons_bascula USING p_belnr vl_total_aves.
ENDFORM.

FORM print_smartform TABLES p_tabla_r TYPE STANDARD TABLE
                            p_tabla_b TYPE STANDARD TABLE
                     USING  gv_bascula TYPE tdbool.

  CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
    EXPORTING
      formname           = 'ZSD_REMISION_TRAS_PV'
*     variant            = space
*     direct_call        = space
    IMPORTING
      fm_name            = l_function
    EXCEPTIONS
      no_form            = 1
      no_function_module = 2
      OTHERS             = 3.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.


  CALL FUNCTION l_function
    EXPORTING
      gv_datos_bascula = gv_bascula
    TABLES
      it_datos_cli     = p_tabla_r
      it_datos_bas     = p_tabla_b
    EXCEPTIONS
      formatting_error = 1
      internal_error   = 2
      send_error       = 3
      user_canceled    = 4
      OTHERS           = 5.
ENDFORM.

FORM get_textos USING td_id TYPE tdid
                      p_order TYPE tdobname
                      td_posnr TYPE posnr
                      td_object TYPE tdobject

           CHANGING p_obs_cabecera TYPE string
                    p_caseta TYPE string
                    p_carga TYPE string
                    p_pigmento TYPE string
                    p_pprom TYPE string.

  DATA: vl_string TYPE string,
        td_tdname TYPE tdobname,
        it_lines  TYPE STANDARD TABLE OF tline,
        vl_ebelnp TYPE ebelp.

  vl_ebelnp = |{ td_posnr ALPHA = OUT }|. "pone ceros

  IF td_id EQ 'F05'.
    td_tdname = p_order.
  ELSE.
    CONCATENATE p_order vl_ebelnp INTO vl_string.
    td_tdname = vl_string.

  ENDIF.


  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      client                  = sy-mandt         " Mandante
      id                      = td_id                 " ID del texto a leer
      language                = 'S'                 " Idioma del texto a leer
      name                    = td_tdname                " Nombre del texto a leer
      object                  = td_object                 " Objeto del texto a leer
    TABLES
      lines                   = it_lines                 " Líneas del texto leído
    EXCEPTIONS
      id                      = 1                " ID de texto no válida
      language                = 2                " Idioma no válido
      name                    = 3                " Nombre de texto no válido
      not_found               = 4                " El texto no existe.
      object                  = 5                " Objeto de texto no válido
      reference_check         = 6                " Cadena de referencia interrumpida
      wrong_access_to_archive = 7                " Archive handle no permitido para el acceso
      OTHERS                  = 8.

  IF sy-subrc <> 0.
*    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSE.
    LOOP AT it_lines INTO DATA(wa_lines).
      IF td_id EQ 'F01'. "caseta
        CONDENSE wa_lines-tdline NO-GAPS.
        p_caseta = wa_lines-tdline.
      ELSEIF td_id EQ 'F02'. "pigmento y pprom
        CASE sy-tabix.
          WHEN 1.
            CONDENSE wa_lines-tdline NO-GAPS.
            p_carga = wa_lines-tdline.
          WHEN 2.
            CONDENSE wa_lines-tdline NO-GAPS.
            p_pigmento = wa_lines-tdline.
          WHEN 3.
            CONDENSE wa_lines-tdline NO-GAPS.
            p_pprom = wa_lines-tdline.
        ENDCASE.
      ELSEIF td_id EQ 'F05'. "txt observaciones cabecera
        CONDENSE wa_lines-tdline NO-GAPS.
        p_obs_cabecera = wa_lines-tdline.
      ENDIF.
    ENDLOOP.
  ENDIF.



ENDFORM.

FORM cons_bascula USING p_belnr p_total_aves TYPE menge_d.

*  """"""""buscamos los pesos en bascula
*  UNASSIGN <fs_wa>.
  SELECT
    z2~tticket, z1~f_proc_ent, z1~h_proc_ent, CAST( z1~pbas_ent AS CHAR( 20 ) ) AS pbas_ent, z1~umpbas_ent,
    z1~placac,
    z1~f_proc_sal, z1~h_proc_sal, CAST( z1~pbas_sal AS CHAR( 20 ) ) AS pbas_sal, z1~umpbas_sal,
    CAST( z1~dif_pentpsal AS CHAR( 20 ) ) AS dif_pentpsal,z2~uname_ent, z2~uname_sal
    INTO TABLE @it_bascula
    FROM zbasculatrasla_1 AS z1
    INNER JOIN zbasculatrasla_2 AS z2 ON z2~ebeln = z1~ebeln
    WHERE z1~ebeln = @p_belnr.
*
  IF it_bascula IS NOT INITIAL.

    READ TABLE it_bascula ASSIGNING FIELD-SYMBOL(<wa_bas>) INDEX 1.
    ASSIGN COMPONENT 'DIF_PENTPSAL' OF STRUCTURE <wa_bas> TO FIELD-SYMBOL(<row>).
    IF <row> GT 0.
      gv_bascula = abap_true.
      vl_peso_prom = <row> / p_total_aves.

      ASSIGN COMPONENT 'TOTAL_AVES' OF STRUCTURE <wa_bas> TO <row>.
      <row> = p_total_aves.
      CONDENSE <row>  NO-GAPS.
      ASSIGN COMPONENT 'PESO_PROM' OF STRUCTURE <wa_bas> TO <row>.
      <row> = vl_peso_prom.
      CONDENSE <row>  NO-GAPS.

      "formatting
      ASSIGN COMPONENT 'PBAS_ENT' OF STRUCTURE <wa_bas> TO <row>.
      SPLIT <row> AT '.' INTO <row> vl_cantidad_mh.
      CONDENSE <row>  NO-GAPS.

      ASSIGN COMPONENT 'PBAS_SAL' OF STRUCTURE <wa_bas> TO <row>.
      SPLIT <row> AT '.' INTO <row> vl_cantidad_mh.
      CONDENSE <row>  NO-GAPS.

      ASSIGN COMPONENT 'DIF_PENTPSAL' OF STRUCTURE <wa_bas> TO <row>.
      SPLIT <row> AT '.' INTO <row> vl_cantidad_mh.
      CONDENSE <row>  NO-GAPS.

      """"""""""""""""222

    ELSE.
      gv_bascula = abap_false.
    ENDIF.

  ENDIF.

  """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

ENDFORM.

FORM get_detalle USING td_tdname TYPE tdobname
                       td_posnr TYPE posnr
                 CHANGING p_valor TYPE string
                         p_potextitem TYPE STANDARD TABLE
                         p_item TYPE STANDARD TABLE.

  DATA: vl_purchaseorder TYPE bapimepoheader-po_number,
        vl_header_text   TYPE bapimmpara-selection,
        vl_item_text     TYPE bapimmpara-selection,
        it_potextheader  TYPE STANDARD TABLE OF bapimepotextheader,
        it_potextitem    TYPE STANDARD TABLE OF bapimepotext,
        it_return        TYPE STANDARD TABLE OF bapiret2,
        it_poitem        TYPE STANDARD TABLE OF bapimepoitem,
        vl_ebelp         TYPE ebelp.

  vl_purchaseorder = td_tdname.

  vl_ebelp = |{ td_posnr ALPHA = OUT }|.



  CALL FUNCTION 'BAPI_PO_GETDETAIL1'
    EXPORTING
      purchaseorder = vl_purchaseorder
      item_text     = 'X'
      header_text   = 'X'
    TABLES
      return        = it_return
      poitem        = it_poitem
      potextheader  = it_potextheader
      potextitem    = it_potextitem.

  p_potextitem = it_potextitem[].
  p_item =  it_poitem[].


ENDFORM.
