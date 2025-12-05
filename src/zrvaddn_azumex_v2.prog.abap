*----------------------------------------------------------------------*
* Print of a delivery note by SAPscript                                *
* FECHA DE RE-TRANSPORTE 050399
*----------------------------------------------------------------------*
REPORT zvaddn01 LINE-COUNT 100.
TABLES:
* MARY GUZMAN
  lfa1,
  zope,
  zuni,
  zent,                          " Tabla de cliente para entregas
  likp,                          " Doc.comercial: Entrega - Datos de cab
  t001n,                         " NIF
  t001,                          " Compañías
  t001l,                         " Almacenes
  t001w,                         " Centros/Sucursales
  t166p,
  ttxit,                         " Textos para IDs de texto
* MARY GUZMAN
  vbco3,                         "Campos clave acceso documento comercia
  vbdkl,                         "Vista cabecera de documento albarán de
  vbdpl,                         "Vista posición documento albarán de en
  komser,                        "Estructura para impresión de números d
  conf_out,                      "Output de la configuración
  tvko,                          "Unidad org.: Organizaciones de ventas
  tvst,                          "Unidad de organización: Puestos de exp
  t001g,                         "Conservas de textos dependientes de la
  rdgprint,                      "Estructura p.la impresión de datos de
  rdgtxtprt,                     "para la salida de textos estándares MP
  komk,                          "Determinación precio cabecera de comun
  komp,                          "Determinación de precio posición comun
  komvd.                         "Determinación precio reg.condición com
INCLUDE rvadtabl.
****** LAURA MENDIOLA G. (IBM)
TABLES:
  vbpa,    " obtener el vendedor
  kna1,    " obtener el RFC de Cliente
  t005u,   " obtener la region
  spell,
  vbdkr,   " Vista cabecera de documento factura
  vbrk.    " RFC prodiverso
DATA:
  vg_conver1 TYPE p, " decimals 2,
  vg_conver2 TYPE p,                                        "ecimals 2,
  vg_convert TYPE p, " decimals 2.
  largo      TYPE n,
  transpor   LIKE lfa1-name1,
  campo(15).
DATA:
  cont       TYPE i, "Cambio de tipo "c" a "i".
  bultos     LIKE vbdpr-ntgew,            " Bultos de 20 kgs.
  sum_ntgew  LIKE vbdpr-ntgew,         "total cantidad pedida
  sum_fkimg  LIKE vbdpr-fkimg,     " total cant. surtida.
  sum_bultos LIKE vbdpr-ntgew.            " suma bultos
*********************
* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
DATA: retcode   LIKE sy-subrc.         "Returncode
DATA: xscreen(1) TYPE c.               "Output on printer or screen
DATA: BEGIN OF tvbdpl OCCURS 0.        "Internal table for items
        INCLUDE STRUCTURE vbdpl.
DATA: END OF tvbdpl.
DATA: BEGIN OF tkomv OCCURS 50.
        INCLUDE STRUCTURE komv.
DATA: END OF tkomv.
DATA: BEGIN OF tkomvd OCCURS 50.
        INCLUDE STRUCTURE komvd.
DATA: END OF tkomvd.
DATA: BEGIN OF tkomcon OCCURS 50.      "...  for configuration data
        INCLUDE STRUCTURE conf_out.
DATA: END OF tkomcon.
DATA: BEGIN OF tkomser OCCURS 5.
        INCLUDE STRUCTURE riserls.
DATA: END   OF tkomser.
DATA: BEGIN OF tkomser_print OCCURS 5.
        INCLUDE STRUCTURE komser.
DATA: END   OF tkomser_print.
DATA: BEGIN OF tkombat OCCURS 50.      " configuration data for batches
        INCLUDE STRUCTURE conf_out.
DATA: END   OF tkombat.
DATA:  address_selection LIKE addr1_sel.                    "MOS
DATA: pr_kappl(01)   TYPE c VALUE 'V'. "Application for pricing
DATA: price(1) TYPE c.                 "price switch
DATA: BEGIN OF rdgprint_tab OCCURS 0.
        INCLUDE STRUCTURE rdgprint.
DATA: END   OF rdgprint_tab.
******** LMG ( IBM 20-ENE-99 )
DATA: BEGIN OF texto_remision OCCURS 0.
        INCLUDE STRUCTURE tline.
DATA: END OF texto_remision.
DATA: i_tdgc3_tab LIKE tdgc3 OCCURS 0 WITH HEADER LINE. " undepend Texts
DATA: i_undep_txt   LIKE rdgtxtprt OCCURS 0 WITH HEADER LINE, "undepend Tex
      l_spras_txt   LIKE rdgtxtprt OCCURS 0 WITH HEADER LINE, "undepend Tex
      i_idname_text LIKE rdgtxtprt OCCURS 0 WITH HEADER LINE.
TYPES: dg_buftab_type        LIKE dgtmd OCCURS 0,
       i_sd_profilestab_type LIKE rdgsdprof OCCURS 0.
* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
FORM entry USING return_code us_screen.
  CLEAR retcode.
  CLEAR price.
  xscreen = us_screen.
  PERFORM processing USING us_screen.
  IF retcode NE 0.
    return_code = 1.
  ELSE.
    return_code = 0.
  ENDIF.
ENDFORM.                    "ENTRY
* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
FORM entry_price USING return_code us_screen.
  CLEAR retcode.
  price = 'X'.
  xscreen = us_screen.
  PERFORM processing USING us_screen.
  IF retcode NE 0.
    return_code = 1.
  ELSE.
    return_code = 0.
  ENDIF.
ENDFORM.                    "ENTRY_PRICE
*---------------------------------------------------------------------*
*       FORM PROCESSING                                               *
*---------------------------------------------------------------------*
*  -->  PROC_SCREEN                                                   *
*---------------------------------------------------------------------*
FORM processing USING proc_screen.
  PERFORM get_data.
  CHECK retcode = 0.
  PERFORM form_open USING proc_screen vbdkl-land1.
******LMG  ( IBM )
  PERFORM imprime_direcciones.
*****************
  CHECK retcode = 0.
  PERFORM check_repeat.
  PERFORM header_data_print.
  CHECK retcode = 0.
  PERFORM header_text_print.
  CHECK retcode = 0.
  PERFORM item_print.
* MG
  cont = 0.
  SELECT  * FROM  nast
    WHERE kappl = 'V2'
    AND   objky = vbco3-vbeln
    AND   kschl = 'LD10'.
*    and   spras = 'S'.
*    and   parnr = vbco3-KUNDE
*    and   parvw = 'WE'.
*    and   nacha between '1' and '4'.
    IF sy-subrc = 0.
      cont = cont + 1.
    ENDIF.
  ENDSELECT.
  IF cont NE 0.
    PERFORM check_repeat1.
  ENDIF.
* MG
  CHECK retcode = 0.
  PERFORM end_print.
  CHECK retcode = 0.
  PERFORM form_close.
  CHECK retcode = 0.
ENDFORM.                    "PROCESSING
***********************************************************************
*       S U B R O U T I N E S                                         *
***********************************************************************
*---------------------------------------------------------------------*
*       FORM CHECK_REPEAT                                             *
*---------------------------------------------------------------------*
*       A text is printed, if it is a repeat print for the document.  *
*---------------------------------------------------------------------*
FORM check_repeat1.
  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      element = 'REPEAT1'
      window  = 'REPEAT1'
    EXCEPTIONS
      element = 1
      window  = 2.
ENDFORM.
*---------------------------------------------------------------------*
*       FORM CHECK_REPEAT                                             *
*---------------------------------------------------------------------*
*       A text is printed, if it is a repeat print for the document.  *
*---------------------------------------------------------------------*
FORM check_repeat.
  SELECT * INTO *nast FROM nast WHERE kappl = nast-kappl
                                AND   objky = nast-objky
                                AND   kschl = nast-kschl
                                AND   spras = nast-spras
                                AND   parnr = nast-parnr
                                AND   parvw = nast-parvw
                                AND   nacha BETWEEN '1' AND '4'.
    CHECK *nast-vstat = '1'.
    CALL FUNCTION 'WRITE_FORM'
      EXPORTING
        element = 'REPEAT'
        window  = 'REPEAT'
      EXCEPTIONS
        element = 1
        window  = 2.
    IF sy-subrc NE 0.
      PERFORM protocol_update.
    ENDIF.
    EXIT.
  ENDSELECT.
ENDFORM.                    "CHECK_REPEAT
*---------------------------------------------------------------------*
*       FORM END_PRINT                                                *
*---------------------------------------------------------------------*
FORM end_print.
  IF price = 'X'.
    PERFORM get_header_prices.
    CALL FUNCTION 'CONTROL_FORM'
      EXPORTING
        command = 'PROTECT'.
    PERFORM header_price_print.
    CALL FUNCTION 'WRITE_FORM'
      EXPORTING
        element = 'END_VALUES'
      EXCEPTIONS
        OTHERS  = 1.
    CALL FUNCTION 'CONTROL_FORM'
      EXPORTING
        command = 'ENDPROTECT'.
  ENDIF.
  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      element = 'SUPPLEMENT_TEXT'
    EXCEPTIONS
      element = 1
      window  = 2.
  IF sy-subrc NE 0.
    PERFORM protocol_update.
  ENDIF.
* print standard texts for dangerous goods
  PERFORM dg_print_undep_text.
ENDFORM.                    "END_PRINT
*---------------------------------------------------------------------*
*       FORM FORM_CLOSE                                               *
*---------------------------------------------------------------------*
*       End of printing the form                                      *
*---------------------------------------------------------------------*
FORM form_close.
  CALL FUNCTION 'CLOSE_FORM'           "...Ende Formulardruck
    EXCEPTIONS
      OTHERS = 1.
  IF sy-subrc NE 0.
    retcode = 1.
    PERFORM protocol_update.
  ENDIF.
  SET COUNTRY space.
ENDFORM.                    "FORM_CLOSE
*---------------------------------------------------------------------*
*       FORM FORM_OPEN                                                *
*---------------------------------------------------------------------*
*       Start of printing the form                                    *
*---------------------------------------------------------------------*
*  -->  US_SCREEN  Output on screen                                   *
*                  ' ' = printer                                      *
*                  'X' = screen                                       *
*  -->  US_COUNTRY County for telecommunication and SET COUNTRY       *
*---------------------------------------------------------------------*
FORM form_open USING us_screen us_country.
  INCLUDE rvadopfo.
ENDFORM.                    "FORM_OPEN
*---------------------------------------------------------------------*
*       FORM GET_DATA                                                 *
*---------------------------------------------------------------------*
*       General provision of data for the form                        *
*---------------------------------------------------------------------*
FORM get_data.
  vbco3-spras = nast-spras.
  vbco3-vbeln = nast-objky.
  vbco3-kunde = nast-parnr.
  vbco3-parvw = nast-parvw.


  DATA tdname LIKE thead-tdname.

  SELECT SINGLE * FROM likp
    WHERE vbeln = vbco3-vbeln.
***** Mary Guzmán (inicio) add zent *****     20040316
* Busca pedido y entrega
  SELECT SINGLE * FROM zent
  WHERE vbeln_e = vbco3-vbeln.
* Busca datos del Operador
  SELECT SINGLE * FROM  zope
  WHERE  bukrs  = zent-bukrs
  AND    lifnr  = zent-lifnr
  AND    zifeop = zent-zifeop.
* busca datos de la unidad.
  SELECT SINGLE * FROM  zuni
  WHERE  bukrs  = zent-bukrs
  AND    lifnr  = zent-lifnr
  AND    zplcvh = zent-zplcvh.
* Busca nombre del transportista
  SELECT SINGLE * FROM  lfa1
  WHERE  lifnr  = zent-lifnr.
  MOVE lfa1-name1 TO transpor.

*afp 24 oct 2022
************************************************************************************
**** En hana los datos de unidad y chofer se toman de TM con base en la entrega ****
************************************************************************************
  DATA: lv_unidad         TYPE char10.
  DATA: lv_placas         TYPE char10.
  DATA: lv_cporte         TYPE char10.
  DATA: lv_sellos         TYPE char50,
        LV_sello1         TYPE char10,
        LV_sello2         TYPE char10,
        LV_sello3         TYPE char10,
        LV_sello4         TYPE char10.
  data: lv_chedraui       type char200,
        lv_chedraui1      type char50,
        lv_chedraui2      type char50,
        lv_chedraui3      type char50,
        lv_chedraui4      type char50,
        lv_chedraui5      type char50,
        lv_chedraui6      type char50.

  DATA: lv_chofer         TYPE char25.
  DATA: lv_fecha_prom     TYPE datum.
  DATA: lv_hora_prom      TYPE uzeit.
  DATA: lv_trayecto       TYPE uzeit.
  DATA: lv_transporte     TYPE /scmtms/trq_id.
  CALL FUNCTION 'ZSD_FU_TRASPORTE_PEDIDO_N'
    EXPORTING
      entrega    = vbco3-vbeln           "vbdkl- -ENTREGA
    IMPORTING
      transporte = lv_transporte
      unidad     = lv_unidad
      placas     = lv_placas
      chofer     = lv_chofer
      fecha_prom = lv_fecha_prom
      hora_prom  = lv_hora_prom
      trayecto   = lv_trayecto.

  tdname = vbco3-vbeln.
  "-------------------Datos de Operador---------
  PERFORM get_datos_tm  USING 'ZS01' "ID objeto
                             tdname "Num. Entrega
                        'operador'
                        CHANGING
                            lv_chofer.
  "---------------------------------------------
  "-------datos de la placa---------------------
  PERFORM get_datos_tm  USING 'ZS09' "ID objeto
                        tdname "Num. Entrega
                        'placas'
                        CHANGING
                          lv_placas
                        .

  "-------------------------------
  "-----Carta Porte
  PERFORM get_datos_tm  USING 'ZS13' "ID objeto
                          tdname "Num. Entrega
                        'cporte'
                       CHANGING
                         lv_cporte
                       .

  "-----Sellos
  PERFORM get_datos_tm USING 'ZS14' "ID objeto
                         tdname "Num. Entrega
                         'sellos'
                       CHANGING
                         lv_sellos
                       .
 SPLIT lv_sellos at cl_abap_char_utilities=>newline into: lv_sello1 lv_sello2 lv_sello3 lv_sello4.


  "-----Textos Chedraui
  PERFORM get_datos_tm USING 'ZS15' "ID objeto
                       tdname "Num. Entrega
                       'chedraui'
                       CHANGING
                           lv_chedraui
                       .
SPLIT lv_chedraui at cl_abap_char_utilities=>newline into: lv_chedraui1 lv_chedraui2
                                                           lv_chedraui3 lv_chedraui4
                                                           lv_chedraui5 lv_chedraui6.
  "----------------------------------------

  MOVE lv_chofer TO transpor.
  lfa1-name1 = lv_chofer.
  MOVE lv_unidad TO zent-zplccj.
  MOVE lv_placas TO zent-zplcvh.
  MOVE lv_cporte TO zent-zcrtpo.
  MOVE lv_sello1 TO zent-sello1.
  MOVE lv_sello2 TO zent-sello2.
  MOVE lv_sello3 TO zent-sello3.
  MOVE lv_sello4 TO zent-sello4.
  move lv_chedraui1 to zent-gv_chedraui1.
  move lv_chedraui2 to zent-gv_chedraui2.
  move lv_chedraui3 to zent-gv_chedraui3.
  move lv_chedraui4 to zent-gv_chedraui4.
  move lv_chedraui5 to zent-gv_chedraui5.
  move lv_chedraui6 to zent-gv_chedraui6.



  "fecha real de entrega
  MOVE likp-wadat_ist TO zent-zfe4en.
  "hora salida
  MOVE likp-spe_wauhr_ist TO zent-zhr4en.
************************************************************************************


***** Mary Guzmán (fin) *****
*********L M G (IBM)
**  select single * from t005u        " obtener la Región del consignado
**    where spras = 'S'
**      and land1 = vbdkl-land1_we
**      and bland = vbdkl-regio_we.
*  move t005u-bezei to vbdkl-name4_we.  "almacenar region en vbdkr-name4
**   select single * from kna1              " Obtener el RFC
**     where  kunnr = vbco3-kunde.
**  select single * from t005u        " obtener la Región
**    where spras = 'S'
**      and land1 = kna1-land1
**     and bland = kna1-regio.
  PERFORM imprime_mensaje.
***********
  CALL FUNCTION 'RV_DELIVERY_PRINT_VIEW'
    EXPORTING
      comwa = vbco3
    IMPORTING
      kopf  = vbdkl
    TABLES
      pos   = tvbdpl.
* Data selection for dangerous goods
  PERFORM dg_data_select USING vbdkl.
  PERFORM sender.
ENDFORM.                    "GET_DATA


FORM get_datos_tm USING p_id TYPE tdid
                   p_tdname TYPE tdobname
                   p_select type c
                  CHANGING
                    p_dato type c
                  .

  DATA tdlines TYPE STANDARD TABLE OF tline.
  data lv_cadena type string.

  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      client                  = sy-mandt
      id                      = p_id
      language                = sy-langu
      name                    = p_tdname
      object                  = 'VBBK'
    TABLES
      lines                   = tdlines
    EXCEPTIONS
      id                      = 1
      language                = 2
      name                    = 3
      not_found               = 4
      object                  = 5
      reference_check         = 6
      wrong_access_to_archive = 7
      OTHERS                  = 8.
  IF sy-subrc EQ 0.


IF p_select eq 'sellos' or p_select eq 'chedraui' .
  LOOP AT tdlines into DATA(wa).
    CONCATENATE lv_cadena wa-tdline cl_abap_char_utilities=>newline into lv_cadena.
  ENDLOOP.
  p_dato = lv_cadena.
else.
    READ TABLE tdlines INTO DATA(wa_) INDEX 1.
    IF sy-subrc EQ 0.
      p_dato = wa_-tdline.
    ENDIF.
ENDIF.

*    READ TABLE tdlines INTO DATA(wa_operador) INDEX 1.
*    IF sy-subrc EQ 0.
*      p_dato = wa_operador-tdline.
*    ENDIF.
  ENDIF.

ENDFORM.

*---------------------------------------------------------------------*
*       FORM GET_HEADER_PRICES                                        *
*---------------------------------------------------------------------*
*       In this routine the price data for the header is fetched from *
*       the database.                                                 *
*---------------------------------------------------------------------*
FORM get_header_prices.
  CALL FUNCTION 'RV_PRICE_PRINT_HEAD'
    EXPORTING
      comm_head_i = komk
      language    = nast-spras
    IMPORTING
      comm_head_e = komk
    TABLES
      tkomv       = tkomv
      tkomvd      = tkomvd.
ENDFORM.                    "GET_HEADER_PRICES
*---------------------------------------------------------------------*
*       FORM GET_ITEM_CHARACTERISTICS                                 *
*---------------------------------------------------------------------*
*       In this routine the configuration data item is fetched from   *
*       the database.                                                 *
*---------------------------------------------------------------------*
FORM get_item_characteristics.
* MARY GUZMAN   28122000
  SELECT SINGLE * FROM t001w
  WHERE werks = vbdpl-werks.
  SELECT SINGLE * FROM t001l
  WHERE werks = vbdpl-werks
  AND   lgort = vbdpl-lgort.
* MARY GUZMAN   28122000
  DATA da_t_cabn LIKE cabn OCCURS 10 WITH HEADER LINE.
  DATA: BEGIN OF da_key,
          mandt LIKE cabn-mandt,
          atinn LIKE cabn-atinn,
        END   OF da_key.
  REFRESH tkomcon.
  CHECK NOT vbdpl-cuobj IS INITIAL.
  CALL FUNCTION 'CUD0_GET_CONFIGURATION'
    EXPORTING
      instance      = vbdpl-cuobj
      language      = nast-spras
    TABLES
      configuration = tkomcon
    EXCEPTIONS
      OTHERS        = 4.
  RANGES : da_in_cabn FOR da_t_cabn-atinn.
  CLEAR da_in_cabn. REFRESH da_in_cabn.
  LOOP AT tkomcon.
    da_in_cabn-option = 'EQ'.
    da_in_cabn-sign   = 'I'.
    da_in_cabn-low    = tkomcon-atinn.
    APPEND da_in_cabn.
  ENDLOOP.
  CLEAR da_t_cabn. REFRESH da_t_cabn.
  CALL FUNCTION 'CLSE_SELECT_CABN'
    TABLES
      in_cabn        = da_in_cabn
      t_cabn         = da_t_cabn
    EXCEPTIONS
      no_entry_found = 1
      OTHERS         = 2.
* Preisfindungsmerkmale herausnehmen
  SORT da_t_cabn.
  LOOP AT tkomcon.
    da_key-mandt = sy-mandt.
    da_key-atinn = tkomcon-atinn.
    READ TABLE da_t_cabn WITH KEY da_key BINARY SEARCH.
    IF sy-subrc <> 0 OR
        ( da_t_cabn-attab = 'SDCOM' AND da_t_cabn-atfel = 'VKOND' ) .
      DELETE tkomcon.
    ENDIF.
  ENDLOOP.
ENDFORM.                    "GET_ITEM_CHARACTERISTICS
*---------------------------------------------------------------------*
*       FORM GET_ITEM_CHARACTERISTICS_BATCH                           *
*---------------------------------------------------------------------*
*       In this routine the configuration data for batches is fetched *
*       from the database                                             *
*---------------------------------------------------------------------*
FORM get_item_characteristics_batch.
  REFRESH tkombat.
  CHECK NOT vbdpl-charg IS INITIAL.
  CALL FUNCTION 'VB_BATCH_VALUES_FOR_OUTPUT'
    EXPORTING
      material       = vbdpl-matnr
      plant          = vbdpl-werks
      batch          = vbdpl-charg
      language       = nast-spras
    TABLES
      classification = tkombat
    EXCEPTIONS
      OTHERS         = 4.
  IF sy-subrc NE 0.
    PERFORM protocol_update.
  ENDIF.
ENDFORM.                    "GET_ITEM_CHARACTERISTICS_BATCH
*---------------------------------------------------------------------*
*       FORM GET_ITEM_PRICES                                          *
*---------------------------------------------------------------------*
*       In this routine the price data for the item is fetched from   *
*       the database.                                                 *
*---------------------------------------------------------------------*
FORM get_item_prices.
  CLEAR: komp,
         tkomv.
  IF komk-knumv NE vbdkl-knump.
    CLEAR komk.
    komk-mandt = sy-mandt.
    komk-kalsm = vbdkl-kalsp.
    komk-kappl = pr_kappl.
    komk-waerk = vbdkl-waerk.
    komk-knumv = vbdkl-knump.
    komk-vbtyp = vbdkl-vbtyp.
  ENDIF.
  komp-kposn = vbdpl-posnr.
  CALL FUNCTION 'RV_PRICE_PRINT_ITEM'
    EXPORTING
      comm_head_i = komk
      comm_item_i = komp
      language    = nast-spras
    IMPORTING
      comm_head_e = komk
      comm_item_e = komp
    TABLES
      tkomv       = tkomv
      tkomvd      = tkomvd.
ENDFORM.                    "GET_ITEM_PRICES
*---------------------------------------------------------------------*
*       FORM GET_SERIAL_NO                                            *
*---------------------------------------------------------------------*
*       In this routine the serialnumbers are fetched from the        *
*       database.                                                     *
*---------------------------------------------------------------------*
FORM get_serial_no.
  REFRESH tkomser.
  REFRESH tkomser_print.
  CHECK vbdpl-anzsn > 0.
* Read the Serialnumbers of a Position.
  CALL FUNCTION 'SERIAL_LS_PRINT'
    EXPORTING
      vbeln  = vbdkl-vbeln
      posnr  = vbdpl-posnr
    TABLES
      iserls = tkomser.
* Process the stringtable for Printing.
  CALL FUNCTION 'PROCESS_SERIALS_FOR_PRINT'
    EXPORTING
      i_boundary_left             = '(_'
      i_boundary_right            = '_)'
      i_sep_char_strings          = ',_'
      i_sep_char_interval         = '_-_'
      i_use_interval              = ' '              " 'X'
      i_boundary_method           = 'C'
      i_line_length               = 129                 "50
      i_no_zero                   = 'X'
      i_alphabet                  = sy-abcde
      i_digits                    = '0123456789'
      i_special_chars             = '-'
      i_with_second_digit         = ' '
    TABLES
      serials                     = tkomser
      serials_print               = tkomser_print
    EXCEPTIONS
      boundary_missing            = 01
      interval_separation_missing = 02
      length_to_small             = 03
      internal_error              = 04
      wrong_method                = 05
      wrong_serial                = 06
      two_equal_serials           = 07
      serial_with_wrong_char      = 08
      serial_separation_missing   = 09.
  IF sy-subrc NE 0.
    PERFORM protocol_update.
  ENDIF.
ENDFORM.                    "GET_SERIAL_NO
*&---------------------------------------------------------------------*
*&      Form  HEADER_DATA_PRINT
*&---------------------------------------------------------------------*
*       Printing of the header data like terms, weights                *
*----------------------------------------------------------------------*
FORM header_data_print.
  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      element = 'HEADER_DATA'
    EXCEPTIONS
      element = 1
      window  = 2.
  IF sy-subrc NE 0.
    PERFORM protocol_update.
  ENDIF.
ENDFORM.                               " HEADER_DATA_PRINT
*---------------------------------------------------------------------*
*       FORM HEADER_PRICE_PRINT                                       *
*---------------------------------------------------------------------*
*       Printout of the header prices                                 *
*---------------------------------------------------------------------*
FORM header_price_print.
  LOOP AT tkomvd.
    AT FIRST.
      IF komk-supos NE 0.
        CALL FUNCTION 'WRITE_FORM'
          EXPORTING
            element = 'ITEM_SUM'
          EXCEPTIONS
            element = 1
            window  = 2.
      ELSE.
        CALL FUNCTION 'WRITE_FORM'
          EXPORTING
            element = 'UNDER_LINE'
          EXCEPTIONS
            element = 1
            window  = 2.
        IF sy-subrc NE 0.
          PERFORM protocol_update.
        ENDIF.
      ENDIF.
    ENDAT.
    komvd = tkomvd.
    IF komvd-koaid = 'D'.
      CALL FUNCTION 'WRITE_FORM'
        EXPORTING
          element = 'TAX_LINE'
        EXCEPTIONS
          element = 1
          window  = 2.
    ELSE.
      CALL FUNCTION 'WRITE_FORM'
        EXPORTING
          element = 'SUM_LINE'
        EXCEPTIONS
          element = 1
          window  = 2.
    ENDIF.
  ENDLOOP.
  DESCRIBE TABLE tkomvd LINES sy-tfill.
  IF sy-tfill = 0.
    CALL FUNCTION 'WRITE_FORM'
      EXPORTING
        element = 'UNDER_LINE'
      EXCEPTIONS
        element = 1
        window  = 2.
    IF sy-subrc NE 0.
      PERFORM protocol_update.
    ENDIF.
  ENDIF.
ENDFORM.                    "HEADER_PRICE_PRINT
*---------------------------------------------------------------------*
*       FORM HEADER_TEXT_PRINT                                        *
*---------------------------------------------------------------------*
*       Printout of the headertexts                                   *
*---------------------------------------------------------------------*
FORM header_text_print.
  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      element = 'HEADER_TEXT'
    EXCEPTIONS
      element = 1
      window  = 2.
  IF sy-subrc NE 0.
    PERFORM protocol_update.
  ENDIF.
ENDFORM.                    "HEADER_TEXT_PRINT
*---------------------------------------------------------------------*
*       FORM ITEM_PRINT                                               *
*---------------------------------------------------------------------*
*       Printout of the items                                         *
*---------------------------------------------------------------------*
FORM item_print.
  DATA: campo1 LIKE vbdkr-name1.
  DATA: vl_fpart.

  CALL FUNCTION 'WRITE_FORM'           "First header
    EXPORTING
      element = 'ITEM_HEADER'
    EXCEPTIONS
      OTHERS  = 1.
  IF sy-subrc NE 0.
    PERFORM protocol_update.
  ENDIF.
  CALL FUNCTION 'WRITE_FORM'          "Activate header
    EXPORTING
      element = 'ITEM_HEADER'
      type    = 'TOP'
    EXCEPTIONS
      OTHERS  = 1.
  IF sy-subrc NE 0.
    PERFORM protocol_update.
  ENDIF.

  vl_fpart = ''.

  LOOP AT tvbdpl.
    vbdpl = tvbdpl.
* Mary Guzmán     Saca los bultos por tonelada para imprimirlos 20040531
    bultos = vbdpl-ntgew / 50.
    sum_ntgew = sum_ntgew + vbdpl-ntgew.  "suma de columnas
    sum_fkimg = sum_fkimg + vbdpl-lfimg.
    sum_bultos = sum_bultos + bultos.

    IF vbdpl-vrkme NE 'BTO'.
      CLEAR bultos.
      CLEAR sum_bultos.
    ENDIF.

    IF vbdpl-uecha IS INITIAL.
      CALL FUNCTION 'CONTROL_FORM'
        EXPORTING
          command = 'PROTECT'.
*********LMG (IBM)
**** se almacena en la estructura spell el proceso de conversión
      CLEAR: spell.
      vg_conver1 = vbdpl-ntgew.
      vg_conver2 = vbdpl-lfimg.
      IF vg_conver2 NE 0.
        vg_convert = vg_conver1 MOD vg_conver2. "obtener decimales.
        vg_convert = ( vg_convert * 1000 ) DIV vg_conver2.
        vbdkr-skfbk = vg_convert.
        campo1 = vbdkr-skfbk.
        IF vg_convert NE 0.
          spell-decimal = campo1+8.
        ELSE.
          spell-decimal = '   '.
        ENDIF.
        vg_convert = vg_conver1 DIV vg_conver2.
        vbdkr-skfbk = vg_convert.
        spell-number = vg_convert.
        SHIFT spell-number LEFT DELETING LEADING '0'.
        IF spell-number(1) = space.
          spell-number(1) = '0'.
        ENDIF.
*        SUM_NTGEW = SUM_NTGEW + VBDPL-NTGEW.  "suma de columnas
*        SUM_FKIMG = SUM_FKIMG + VBDPL-LFIMG.
      ELSE.
        vg_convert = 0.
      ENDIF.
************
      IF vbdpl-ntgew GT 0.

        CALL FUNCTION 'WRITE_FORM'
          EXPORTING
            element = 'ITEM_LINE'.
      ELSE.
        vl_fpart = 'X'. " determina si la entrega es particionada
      ENDIF.


      PERFORM dg_print_data_get.
      PERFORM dg_data_print.
      IF price = 'X'.
        PERFORM get_item_prices.
        PERFORM item_price_print.
      ENDIF.
      PERFORM get_serial_no.
      PERFORM item_serial_no_print.
      PERFORM get_item_characteristics.
      PERFORM item_characteristics_print.
      PERFORM get_item_characteristics_batch.
      PERFORM item_characteristics_batch.
******LMG (IBM)
**  select single * from vbpa          " obtener CLIENTE
**      where vbeln = vbdkl-vbeln
**         and ( parvw = 'AG' or parvw = 'SP' ).
**  select single * from vbpa          " obtener DESTINATARIO
**      where vbeln = vbdkl-vbeln
**        and ( parvw = 'WE' or parvw = 'SH' ).
************
      IF vbdpl-vbeln_vauf NE space AND
         vbdpl-vbeln_vauf NE vbdkl-vbeln_vauf.
        CALL FUNCTION 'WRITE_FORM'
          EXPORTING
            element = 'ITEM_REFERENCE'
          EXCEPTIONS
            element = 1
            window  = 2.
        IF sy-subrc NE 0.
          PERFORM protocol_update.
        ENDIF.
      ENDIF.
      CALL FUNCTION 'WRITE_FORM'
        EXPORTING
          element = 'ITEM_PURCHASE_DATA'
        EXCEPTIONS
          element = 1
          window  = 2.
      IF sy-subrc NE 0.
        PERFORM protocol_update.
      ENDIF.
      CALL FUNCTION 'CONTROL_FORM'
        EXPORTING
          command = 'ENDPROTECT'.
    ELSE.
      CALL FUNCTION 'WRITE_FORM'
        EXPORTING
          element = 'ITEM_LINE_BATCH'.
      IF sy-subrc NE 0.
        PERFORM protocol_update.
      ENDIF.
      PERFORM get_serial_no.
      PERFORM item_serial_no_print.
      PERFORM get_item_characteristics_batch.
      PERFORM item_characteristics_batch.
    ENDIF.
  ENDLOOP.

  IF  vl_fpart EQ 'X'.
    vbdpl-ntgew = sum_ntgew.  "suma de columnas
    vbdpl-lfimg = sum_fkimg.
    bultos = sum_bultos.

    CALL FUNCTION 'WRITE_FORM'
      EXPORTING
        element = 'ITEM_LINE'.
  ENDIF.
  CALL FUNCTION 'WRITE_FORM'          "Deactivate Header
    EXPORTING
      element  = 'ITEM_HEADER'
      function = 'DELETE'
      type     = 'TOP'
    EXCEPTIONS
      OTHERS   = 1.

  IF sy-subrc NE 0.
    PERFORM protocol_update.
  ENDIF.
ENDFORM.                    "ITEM_PRINT
*---------------------------------------------------------------------*
*       FORM ITEM_CHARACERISTICS_BATCH                                *
*---------------------------------------------------------------------*
*       Printout of the item characteristics for batches              *
*---------------------------------------------------------------------*
FORM item_characteristics_batch.
  LOOP AT tkombat.
    conf_out = tkombat.
    IF sy-tabix = 1.
      CALL FUNCTION 'WRITE_FORM'
        EXPORTING
          element = 'ITEM_LINE_CONFIGURATION_BATCH_HEADER'
        EXCEPTIONS
          OTHERS  = 1.
      IF sy-subrc NE 0.
        PERFORM protocol_update.
      ENDIF.
    ELSE.
      CALL FUNCTION 'WRITE_FORM'
        EXPORTING
          element = 'ITEM_LINE_CONFIGURATION_BATCH'
        EXCEPTIONS
          OTHERS  = 1.
      IF sy-subrc NE 0.
        PERFORM protocol_update.
      ENDIF.
    ENDIF.
  ENDLOOP.
ENDFORM.                    "ITEM_CHARACTERISTICS_BATCH
*---------------------------------------------------------------------*
*       FORM ITEM_CHARACERISTICS_PRINT                                *
*---------------------------------------------------------------------*
*       Printout of the item characteristics -> configuration         *
*---------------------------------------------------------------------*
FORM item_characteristics_print.
  LOOP AT tkomcon.
    conf_out = tkomcon.
    IF sy-tabix = 1.
      CALL FUNCTION 'WRITE_FORM'
        EXPORTING
          element = 'ITEM_LINE_CONFIGURATION_HEADER'
        EXCEPTIONS
          OTHERS  = 1.
      IF sy-subrc NE 0.
        PERFORM protocol_update.
      ENDIF.
    ELSE.
      CALL FUNCTION 'WRITE_FORM'
        EXPORTING
          element = 'ITEM_LINE_CONFIGURATION'
        EXCEPTIONS
          OTHERS  = 1.
      IF sy-subrc NE 0.
        PERFORM protocol_update.
      ENDIF.
    ENDIF.
  ENDLOOP.
ENDFORM.                    "ITEM_CHARACTERISTICS_PRINT
*---------------------------------------------------------------------*
*       FORM ITEM_PRICE_PRINT                                         *
*---------------------------------------------------------------------*
*       Printout of the item prices                                   *
*---------------------------------------------------------------------*
FORM item_price_print.
  LOOP AT tkomvd.
    komvd = tkomvd.
    IF sy-tabix = 1.
      CALL FUNCTION 'WRITE_FORM'
        EXPORTING
          element = 'ITEM_LINE_PRICE_QUANTITY'
        EXCEPTIONS
          element = 1
          window  = 2.
    ELSE.
      CALL FUNCTION 'WRITE_FORM'
        EXPORTING
          element = 'ITEM_LINE_PRICE_TEXT'
        EXCEPTIONS
          element = 1
          window  = 2.
    ENDIF.
  ENDLOOP.
ENDFORM.                    "ITEM_PRICE_PRINT
*---------------------------------------------------------------------*
*       FORM ITEM_SERIAL_NO_PRINT                                     *
*---------------------------------------------------------------------*
*       Printout of the item serialnumbers                            *
*---------------------------------------------------------------------*
FORM item_serial_no_print.
  LOOP AT tkomser_print.
    komser = tkomser_print.
    IF sy-tabix = 1.
*     Output of the Headerline
      CALL FUNCTION 'WRITE_FORM'
        EXPORTING
          element = 'ITEM_LINE_SERIAL_NO_HEADER'
        EXCEPTIONS
          element = 1
          window  = 2.
      IF sy-subrc NE 0.
        PERFORM protocol_update.
      ENDIF.
    ELSE.
*     Output of the following printlines
      CALL FUNCTION 'WRITE_FORM'
        EXPORTING
          element = 'ITEM_LINE_SERIAL_NO'
        EXCEPTIONS
          element = 1
          window  = 2.
      IF sy-subrc NE 0.
        PERFORM protocol_update.
      ENDIF.
    ENDIF.
    AT LAST.
      CALL FUNCTION 'CONTROL_FORM'
        EXPORTING
          command = 'NEW-LINE'.
      IF sy-subrc NE 0.
        PERFORM protocol_update.
      ENDIF.
    ENDAT.
  ENDLOOP.
ENDFORM.                    "ITEM_SERIAL_NO_PRINT
*---------------------------------------------------------------------*
*       FORM PROTOCOL_UPDATE                                          *
*---------------------------------------------------------------------*
*       The messages are collected for the processing protocol.       *
*---------------------------------------------------------------------*
FORM protocol_update.

  CHECK xscreen = space.
  CALL FUNCTION 'NAST_PROTOCOL_UPDATE'
    EXPORTING
      msg_arbgb = syst-msgid
      msg_nr    = syst-msgno
      msg_ty    = syst-msgty
      msg_v1    = syst-msgv1
      msg_v2    = syst-msgv2
      msg_v3    = syst-msgv3
      msg_v4    = syst-msgv4
    EXCEPTIONS
      OTHERS    = 1.
ENDFORM.                    "PROTOCOL_UPDATE
*---------------------------------------------------------------------*
*       FORM SENDER                                                   *
*---------------------------------------------------------------------*
*       This routine determines the address of the sender             *
*---------------------------------------------------------------------*
FORM sender.
  SELECT SINGLE * FROM tvko  WHERE vkorg = vbdkl-vkorg.
  IF sy-subrc NE 0.
    syst-msgid = 'VN'.
    syst-msgno = '203'.
    syst-msgty = 'W'.
    syst-msgv1 = 'TVKO'.
    syst-msgv2 = syst-subrc.
    PERFORM protocol_update.
  ENDIF.
  SELECT SINGLE * FROM t001 WHERE bukrs = zent-bukrs."TVKO-BUKRS.
  SELECT SINGLE * FROM t001n WHERE bukrs = tvko-bukrs AND land1 = 'MX'.
  SELECT SINGLE * FROM tvst  WHERE vstel = vbdkl-vstel.
  IF sy-subrc NE 0.
    syst-msgid = 'VN'.
    syst-msgno = '203'.
    syst-msgty = 'W'.
    syst-msgv1 = 'TVST'.
    syst-msgv2 = syst-subrc.
    PERFORM protocol_update.
  ENDIF.
  SELECT SINGLE * FROM t001g WHERE bukrs    = vbdkl-bukrs
                             AND   programm = 'ZRVADDN01'
                             AND   txtid    = space.
  IF sy-subrc NE 0.
    syst-msgid = 'VN'.
    syst-msgno = '203'.
    syst-msgty = 'W'.
    syst-msgv1 = 'T001G'.
    syst-msgv2 = syst-subrc.
    PERFORM protocol_update.
  ENDIF.
ENDFORM.                    "SENDER
*&---------------------------------------------------------------------*
*&      Form  DG_DATA_SELECT
*&---------------------------------------------------------------------*
*           Get data for dangerous goods positions
*----------------------------------------------------------------------*
FORM dg_data_select USING i_vbdkl LIKE vbdkl.
  DATA: dg_flag VALUE ' '.

  LOOP AT tvbdpl.
    IF tvbdpl-idgpa EQ 'X'.
      dg_flag = 'X'.
      EXIT.
    ENDIF.
  ENDLOOP.
*---Data select for dangerous Goods
  IF dg_flag EQ 'X'.
    CALL FUNCTION 'HAZMAT_PRI_DATA_GET'
      EXPORTING
        e_vbdkl        = i_vbdkl
        i_nspras       = nast-spras
      TABLES
        e_rdgprint_tab = rdgprint_tab
        e_tvbdpl       = tvbdpl
        e_undep_text   = i_undep_txt
        e_spras_txt    = l_spras_txt
        e_idname_text  = i_idname_text
        e_tdgc3_tab    = i_tdgc3_tab
      EXCEPTIONS
        get_data_error = 1
        OTHERS         = 2.
* set retcode
    IF sy-subrc = 1.
      retcode = 1.
    ELSE.
      retcode = 0.
    ENDIF.
  ENDIF.
ENDFORM.                               " DG_DATA_SELECT
*&---------------------------------------------------------------------*
*&      Form  DG_PRINT_DATA_GET
*&---------------------------------------------------------------------*
*       Prepares Data in printstructure
*----------------------------------------------------------------------*
FORM dg_print_data_get.
  DATA lin TYPE i.
  CHECK NOT tvbdpl-idgpa IS INITIAL.
  DESCRIBE TABLE rdgprint_tab LINES lin.
  CHECK lin GT 0.
*......................................................................
* GET PRINT CONDITIONS
*......................................................................
  CALL FUNCTION 'HAZMAT_PRI_COND_GET'
    EXPORTING
      i_vbdkl      = vbdkl
    TABLES
      rdgprint_tab = rdgprint_tab
    EXCEPTIONS
      OTHERS       = 1.
*......................................................................
* GET TEXT-IDS FOR DEPENDENT TEXT
*......................................................................
  CALL FUNCTION 'HAZMAT_GET_TEXT_KEYS'
    EXPORTING
      i_sprache      = nast-spras
      i_matnr        = tvbdpl-matnr
    TABLES
      i_rdgprint_tab = rdgprint_tab
      i_idname_text  = i_idname_text
      i_undep_text   = i_undep_txt
      i_spras_txt    = l_spras_txt
      i_tvbdpl       = tvbdpl
      i_tdgc3_tab    = i_tdgc3_tab
    EXCEPTIONS
      OTHERS         = 1.
ENDFORM.                               " DG_DATA_GET
*&---------------------------------------------------------------------*
*&      Form  DG_DATA_PRINT
*&---------------------------------------------------------------------*
*       Print Data to layout
*----------------------------------------------------------------------*
FORM dg_data_print.
  DATA: lin       TYPE i,
        first_mat LIKE tvbdpl-matnr,
        sec_mat   LIKE tvbdpl-matnr.
  first_mat = 0.
  CHECK NOT tvbdpl-idgpa IS INITIAL.
  DESCRIBE TABLE rdgprint_tab LINES lin.
  CHECK lin GT 0.
  CLEAR l_spras_txt.
* print position data
  LOOP AT rdgprint_tab WHERE matnr = tvbdpl-matnr.
    MOVE-CORRESPONDING rdgprint_tab TO rdgprint.
    sec_mat = first_mat.
    first_mat = tvbdpl-matnr.
    IF first_mat NE sec_mat.
      CALL FUNCTION 'WRITE_FORM'       " Header Text
        EXPORTING
          element = 'ITEM_LINE_DG_HEADER'
        EXCEPTIONS
          OTHERS  = 1.
    ENDIF.
    CALL FUNCTION 'WRITE_FORM'
      EXPORTING
        element = 'ITEM_LINE_DG'
      EXCEPTIONS
        OTHERS  = 1.
* print dependent position text
    LOOP AT i_idname_text WHERE mot = rdgprint_tab-mot
                          AND rvlid = rdgprint_tab-rvlid
                          AND matnr = rdgprint_tab-matnr.
      READ TABLE l_spras_txt WITH KEY mot = i_idname_text-mot
                                    rvlid = i_idname_text-rvlid.
      IF rdgprint_tab-sprsls = l_spras_txt-tdspras.
        rdgtxtprt-tdspras = l_spras_txt-tdspras.
      ENDIF.
      rdgprint-txname = i_idname_text-tdname.
      rdgprint-iddep = i_idname_text-tdid.
      CLEAR rdgtxtprt-tdname.
      CALL FUNCTION 'WRITE_FORM'
        EXPORTING
          element = 'ITEM_LINE_DG_TEXT'
        EXCEPTIONS
          OTHERS  = 1.
      CLEAR rdgprint-txname.
      CLEAR rdgprint-iddep.
      CLEAR rdgtxtprt-tdspras.
    ENDLOOP.
* print undependent position text
    LOOP AT i_undep_txt.               " where mot = rdgprint_tab-mot
      "    and rvlid = rdgprint_tab-rvlid.
      READ TABLE l_spras_txt WITH KEY mot = i_undep_txt-mot
                                  rvlid = i_undep_txt-rvlid.
      rdgtxtprt-tdname = i_undep_txt-tdname.
      rdgtxtprt-tdspras = i_undep_txt-tdspras.

      CLEAR:  rdgprint-txname,
              rdgprint-iddep .

      CALL FUNCTION 'WRITE_FORM'
        EXPORTING
          element = 'ITEM_LINE_DG_TEXT'
        EXCEPTIONS
          OTHERS  = 1.
    ENDLOOP.
  ENDLOOP.
ENDFORM.                               " DG_DATA_PRINT
*&---------------------------------------------------------------------*
*&      Form  DG_MESSAGE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM dg_message
    USING temp    TYPE LINE OF dg_buftab_type
          sd_prof TYPE LINE OF i_sd_profilestab_type
          no.
  CASE no.
    WHEN 1.                            "no countries /no transportmodes
      syst-msgid = 'DG'.
      syst-msgno = '510'.
      syst-msgty = 'E'.
      syst-msgv1 = vbdpl-vbeln.
      PERFORM protocol_update.
    WHEN 2.                            "no dangerous goods records found
      syst-msgid = 'DG'.
      syst-msgno = '503'.
      syst-msgty = 'E'.
      PERFORM protocol_update.
    WHEN 3.                      "no released dangerous goods data found
      syst-msgid = 'DG'.
      syst-msgno = '505'.
      syst-msgty = 'E'.
      syst-msgv1 = temp-matnr.
      syst-msgv2 = temp-mot.
      syst-msgv3 = temp-rvlid.
      PERFORM protocol_update.
    WHEN 4.                            "no proper shipping names found
      syst-msgid = 'DG'.
      syst-msgno = '507'.
      syst-msgty = 'E'.
      PERFORM protocol_update.
    WHEN 5.                            "no trafic categories found
      syst-msgid = 'DG'.
      syst-msgno = '508'.
      syst-msgty = 'E'.
      PERFORM protocol_update.
    WHEN 6.                            "no validity area found
      syst-msgid = 'DG'.
      syst-msgno = '506'.
      syst-msgty = 'E'.
      syst-msgv1 = temp-matnr.
      syst-msgv2 = temp-mot.
      syst-msgv3 = sd_prof-dgctry.
      PERFORM protocol_update.
    WHEN 7.                            "no secondary language
      syst-msgid = 'DG'.
      syst-msgno = '515'.
      syst-msgty = 'E'.
      syst-msgv1 = temp-rvlid.
      PERFORM protocol_update.
    WHEN 8.                            "no date for selection
      syst-msgid = 'DG'.
      syst-msgno = '509'.
      syst-msgty = 'E'.
      PERFORM protocol_update.
    WHEN 9.                            "no disjunct validity areas
      syst-msgid = 'DG'.
      syst-msgno = '504'.
      syst-msgty = 'E'.
      syst-msgv1 = sd_prof-dgctry.
      PERFORM protocol_update.
  ENDCASE.
ENDFORM.                    "DG_MESSAGE
*&---------------------------------------------------------------------*
*&      Form  DG_PRINT_UNDEP_TEXT
*&---------------------------------------------------------------------*
FORM dg_print_undep_text.
  TABLES: tdg47 .
  DATA: rdgprint_satz LIKE rdgprint OCCURS 0 WITH HEADER LINE,
        i_print_flag,
        lin           TYPE i,
        e_vbdkl       LIKE vbdkl.
  CONSTANTS: a_rand(6)    VALUE 'A_RAND',
             rep_quan(8)  VALUE 'REP_QUAN',
             transpp7(8)  VALUE 'TRANSPP7',
             high_visc(9) VALUE 'HIGH_VISC'.

  DESCRIBE TABLE rdgprint_tab LINES lin.
  CHECK lin GT 0.
  e_vbdkl = vbdkl.
  CLEAR rdgtxtprt-tdname.
  LOOP AT i_tdgc3_tab.
    IF i_tdgc3_tab-text_key NE a_rand
    AND i_tdgc3_tab-text_key NE rep_quan
    AND i_tdgc3_tab-text_key NE transpp7
    AND i_tdgc3_tab-text_key NE high_visc.
      SELECT SINGLE * FROM tdg47 WHERE text_key = i_tdgc3_tab-text_key.
      LOOP AT rdgprint_tab.
        MOVE rdgprint_tab TO rdgprint_satz.
        APPEND rdgprint_satz.
        CALL FUNCTION i_tdgc3_tab-nam_fn
          EXPORTING
            i_vbdkl          = e_vbdkl
          IMPORTING
            e_print_flag     = i_print_flag
          TABLES
            i_rdgprint_tab   = rdgprint_tab
            i_rdgprint_zeile = rdgprint_satz
            i_tvbdpl         = tvbdpl.
        IF i_print_flag = 'X'.
          rdgtxtprt-tdname = tdg47-tdname.
          CALL FUNCTION 'WRITE_FORM'
            EXPORTING
              element = 'DG_STANDARD_TEXT'
            EXCEPTIONS
              OTHERS  = 1.
          EXIT.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDLOOP.
ENDFORM.                               " DG_PRINT_UNDEP_TEXT
*&---------------------------------------------------------------------*
*&      Form  IMPRIME_MENSAJE
*&---------------------------------------------------------------------*
FORM imprime_mensaje.
********** LMG   ( IBM   20-ENE-99 )
  CALL FUNCTION 'READ_TEXT'
    EXPORTING
*     CLIENT                  = SY-MANDT
      id                      = '0011'
      language                = 'S'
      name                    = vbdkl-tdname
      object                  = 'VBBK'
*     ARCHIVE_HANDLE          = 0
*        IMPORTING
*     HEADER                  =
    TABLES
      lines                   = texto_remision
    EXCEPTIONS
      id                      = 1
      language                = 2
      name                    = 3
      not_found               = 4
      object                  = 5
      reference_check         = 6
      wrong_access_to_archive = 7
      OTHERS                  = 8.

  READ TABLE texto_remision.
ENDFORM.                    " IMPRIME_MENSAJE
*&---------------------------------------------------------------------*
*&      Form  IMPRIME_DIRECCIONES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM imprime_direcciones.
******LMG (IBM)
**  select single * from vbpa          " obtener DESTINATARIO
**      where vbeln = vbdkl-vbeln
**        and ( parvw = 'WE' or parvw = 'SH' ).
*  select single * from vbpa          " obtener DESTINATARIO
*     where vbeln = vbdkl-vbeln
*       and ( parvw = 'WE' or parvw = 'SH' ).
  SELECT SINGLE * FROM vbpa          " obtener CLIENTE
      WHERE vbeln = vbdkl-vbeln
         AND ( parvw = 'AG' OR parvw = 'SP' ).
  IF vbpa-xcpdk = 'X'.     " CLIENTE PRODIVERSO
    SELECT SINGLE * FROM vbrk              " Obtener datos cliente
      WHERE vbeln = vbdkl-vbeln.           " RFC
    MOVE vbrk-stceg TO kna1-stcd1.      " Para prodiverso
  ELSE.                                   " no hay rfc.
    SELECT SINGLE * FROM kna1              " Obtener datos cliente
      WHERE  kunnr = vbpa-kunnr.           " RFC
  ENDIF.
  SELECT SINGLE * FROM t005u        " obtener la Región cliente
    WHERE spras = 'S'
      AND land1 = kna1-land1
      AND bland = kna1-regio.

  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      element = 'VENDIDO_A'
      window  = 'ADDRESS'
    EXCEPTIONS
      element = 1
      window  = 2.
  IF sy-subrc NE 0.
    PERFORM protocol_update.
  ENDIF.
  IF vbco3-kunde NE vbpa-kunnr.
    SELECT SINGLE * FROM t005u        " obtener la Región DESTINATARIO
      WHERE spras = 'S'
        AND land1 = vbdkl-land1
        AND bland = vbdkl-regio.
    IF sy-subrc = 0.
      MOVE t005u-bezei TO vbdkl-name4.
    ENDIF.
    CALL FUNCTION 'WRITE_FORM'
      EXPORTING
        element = 'CONSIGNADO_A'
        window  = 'CONSGNEE'
      EXCEPTIONS
        element = 1
        window  = 2.
    IF sy-subrc NE 0.
      PERFORM protocol_update.
    ENDIF.
  ELSE.
    CALL FUNCTION 'WRITE_FORM'
      EXPORTING
        element = 'IMPRIME_LINEAS'
        window  = 'CONSGNEE'
      EXCEPTIONS
        element = 1
        window  = 2.
    IF sy-subrc NE 0.
      PERFORM protocol_update.
    ENDIF.
  ENDIF.
*******L M G (IBM)
ENDFORM.                    " IMPRIME_DIRECCIONES
