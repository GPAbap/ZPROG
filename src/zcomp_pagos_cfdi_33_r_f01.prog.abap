************************************************************************
*                                                                      *
*            ********************************************              *
*            *   Confidential and Proprietary           *              *
*            *   XAMAI S.A. de C.V.                     *              *
*            *   All Rights Reserved                    *              *
*            ********************************************              *
*                                                                      *
************************************************************************
* Programa principal  :  ZCOMPLEMENTO_PAGOS_CFDI_33                    *
* Titulo              :  Generación de XML con complemento de pagos    *
*                                                                      *
* Programador         : David Del Valle Mendoza                        *
* Fecha               : VII.2017                                       *
************************************************************************
*&---------------------------------------------------------------------*
*&  Include           ZCOMP_PAGOS_CFDI_33_F01
*&---------------------------------------------------------------------*
*******************************************************************************************************
*******************************************************************************************************
****************** S4  HANA  VERSION modified to ECC **************************************************
****************** to include FI carga inicial       **************************************************
*******************************************************************************************************
*******************************************************************************************************
*&---------------------------------------------------------------------*
*&      Form  F_CREATE_ALV_STRUCT
*&---------------------------------------------------------------------*
FORM f_create_alv_struct .

*** Catalogo de campos
  CREATE DATA dref TYPE s_data_alv.
  ASSIGN dref->* TO <fs>.

  lr_rtti_struc ?= cl_abap_structdescr=>describe_by_data( <fs> ).

  CLEAR gt_data.
  REFRESH gt_data.

**** Extrae informacion para criterios de seleccion
  PERFORM f_get_data.

  IF NOT gt_data[] IS INITIAL.
**** Llena la tabla para el ALV
    PERFORM f_process_data.

    CLEAR it_fldcat.
    REFRESH it_fldcat.

    zogt[]  = lr_rtti_struc->components.
    LOOP AT zogt INTO zog.
      CLEAR wa_it_fldcat.
      wa_it_fldcat-fieldname = zog-name .
      wa_it_fldcat-datatype = zog-type_kind.
      wa_it_fldcat-inttype = zog-type_kind.
      wa_it_fldcat-intlen = zog-length / 2.
      wa_it_fldcat-decimals = zog-decimals.
      wa_it_fldcat-coltext = zog-name.
      wa_it_fldcat-lowercase = 'X'.

      IF wa_it_fldcat-fieldname = 'LLAVE'.
        wa_it_fldcat-no_out = 'X'.
      ELSEIF wa_it_fldcat-fieldname = 'CHECK'.
        wa_it_fldcat-checkbox = 'X'.
        wa_it_fldcat-edit = 'X'.
        wa_it_fldcat-coltext = 'Generar'.
        wa_it_fldcat-outputlen = '7'.
        wa_it_fldcat-no_out = 'X'.
      ELSEIF wa_it_fldcat-fieldname = 'ANULADA'.
        wa_it_fldcat-icon = 'X'.
        wa_it_fldcat-coltext = 'Status'.
        wa_it_fldcat-outputlen = '6'.
      ELSEIF wa_it_fldcat-fieldname = 'BUKRS'.
        wa_it_fldcat-coltext = TEXT-h01.                  " Sociedad
        wa_it_fldcat-scrtext_m = TEXT-h01.
      ELSEIF wa_it_fldcat-fieldname = 'KUNNR'.
        wa_it_fldcat-coltext = TEXT-h02.                  " Cliente
        wa_it_fldcat-scrtext_m = TEXT-h02.
        wa_it_fldcat-no_zero = 'X'.
      ELSEIF wa_it_fldcat-fieldname = 'NAME1'.
        wa_it_fldcat-coltext = 'Nombre'.                  " Cliente
        wa_it_fldcat-scrtext_m = 'Nombre'.
        wa_it_fldcat-seltext = 'Nombre'.
        wa_it_fldcat-scrtext_s = 'Nombre'.
        wa_it_fldcat-scrtext_l = 'Nombre'.

        wa_it_fldcat-no_zero = 'X'.
      ELSEIF wa_it_fldcat-fieldname = 'DOC_PAGO'.
        wa_it_fldcat-coltext = TEXT-h03.                  " Doc. de pago
        wa_it_fldcat-scrtext_m = TEXT-h03.
      ELSEIF wa_it_fldcat-fieldname = 'IND_PC'.
        wa_it_fldcat-coltext = TEXT-h04.                  " Pago Total
        wa_it_fldcat-scrtext_m = TEXT-h04.
        wa_it_fldcat-just = 'C'.
      ELSEIF wa_it_fldcat-fieldname = 'IND_PP'.
        wa_it_fldcat-coltext = TEXT-h05.                  " Pago Parcial
        wa_it_fldcat-scrtext_m = TEXT-h05.
        wa_it_fldcat-just = 'C'.
      ELSEIF wa_it_fldcat-fieldname = 'DOC_COMP'.
        wa_it_fldcat-coltext = TEXT-h06.                  " Doc. financiero
        wa_it_fldcat-scrtext_m = TEXT-h06.
      ELSEIF wa_it_fldcat-fieldname = 'FACTURA'.
        wa_it_fldcat-coltext = TEXT-h07.                  " Factura
        wa_it_fldcat-scrtext_m = TEXT-h07.
        wa_it_fldcat-no_zero = 'X'.
      ELSEIF wa_it_fldcat-fieldname = 'ZTERM'.
        wa_it_fldcat-coltext = 'Cond.Pago'.                  " Cliente
        wa_it_fldcat-scrtext_m = 'Cond. Pago'.
*        WA_IT_FLDCAT-NO_ZERO = 'X'.
      ELSEIF wa_it_fldcat-fieldname = 'PAGO_DOC'.
        wa_it_fldcat-coltext = TEXT-h08.                  " Imp. de pago
        wa_it_fldcat-scrtext_m = TEXT-h08.
        wa_it_fldcat-just = 'R'.
      ELSEIF wa_it_fldcat-fieldname = 'CURRENCY'.
        wa_it_fldcat-coltext = TEXT-h09.                  " Moneda pago
        wa_it_fldcat-scrtext_m = TEXT-h09.
      ELSEIF wa_it_fldcat-fieldname = 'CURREN_DR'.
        wa_it_fldcat-coltext = TEXT-h10.                  " Moneda fact
        wa_it_fldcat-scrtext_m = TEXT-h10.
      ELSEIF wa_it_fldcat-fieldname = 'BUDAT'.
        wa_it_fldcat-coltext = TEXT-h11.                  " Fecha de pago
        wa_it_fldcat-scrtext_m = TEXT-h11.
      ELSEIF wa_it_fldcat-fieldname = 'PARCIALIDAD'.
        wa_it_fldcat-coltext = TEXT-h12.                  " Num. parc.
        wa_it_fldcat-scrtext_m = TEXT-h12.
        wa_it_fldcat-outputlen = '5'.
      ELSEIF wa_it_fldcat-fieldname = 'IMP_FACT_DOC'.
        wa_it_fldcat-coltext = TEXT-h13.                  " Imp. factura
        wa_it_fldcat-scrtext_m = TEXT-h13.
        wa_it_fldcat-just = 'R'.
      ELSEIF wa_it_fldcat-fieldname = 'FKDAT'.
        wa_it_fldcat-coltext = TEXT-h14.                  " Fecha fact.
        wa_it_fldcat-scrtext_m = TEXT-h14.
      ELSEIF wa_it_fldcat-fieldname = 'UUID'.
        wa_it_fldcat-coltext = TEXT-h15.               " UUID
        wa_it_fldcat-scrtext_m = TEXT-h15.
        wa_it_fldcat-outputlen = '10'.
      ELSEIF wa_it_fldcat-fieldname = 'COMENTARIO'.
        wa_it_fldcat-coltext = TEXT-h16.                  " UUID
        wa_it_fldcat-scrtext_m = TEXT-h16.
        wa_it_fldcat-outputlen = '20'.
      ELSEIF wa_it_fldcat-fieldname = 'PDF' OR
        wa_it_fldcat-fieldname = 'XML'." OR
*        WA_IT_FLDCAT-FIELDNAME = 'PDF_CANC'.
        wa_it_fldcat-icon = 'X'.
        wa_it_fldcat-outputlen = '3'.
        wa_it_fldcat-hotspot = 'X'.
      ELSEIF wa_it_fldcat-fieldname = 'STAT_CANC'.
        wa_it_fldcat-coltext = TEXT-h32.                  "
        wa_it_fldcat-scrtext_m = TEXT-h32.
        wa_it_fldcat-outputlen = '8'.
      ELSEIF wa_it_fldcat-fieldname = 'BASEIVA16'.
        wa_it_fldcat-coltext = TEXT-h33.                  "
        wa_it_fldcat-scrtext_m = TEXT-h33.
        wa_it_fldcat-outputlen = '16'.
      ELSEIF wa_it_fldcat-fieldname = 'IVATRAS16'.
        wa_it_fldcat-coltext = TEXT-h34.                  "
        wa_it_fldcat-scrtext_m = TEXT-h34.
        wa_it_fldcat-outputlen = '16'.
      ELSEIF wa_it_fldcat-fieldname = 'BASEIVA0'.
        wa_it_fldcat-coltext = TEXT-h35.                  "
        wa_it_fldcat-scrtext_m = TEXT-h35.
        wa_it_fldcat-outputlen = '16'.
      ELSEIF wa_it_fldcat-fieldname = 'SALDOPAGAR'.
        wa_it_fldcat-coltext = TEXT-h36.
        wa_it_fldcat-scrtext_m = TEXT-h36.
        wa_it_fldcat-outputlen = '16'.
      ELSEIF wa_it_fldcat-fieldname = 'SALDOANT'.
        wa_it_fldcat-coltext = TEXT-h37.
        wa_it_fldcat-scrtext_m = TEXT-h37.
        wa_it_fldcat-outputlen = '16'.
      ELSEIF wa_it_fldcat-fieldname = 'FOLFIS'.
        wa_it_fldcat-coltext = TEXT-h38.
        wa_it_fldcat-scrtext_m = TEXT-h38.
        wa_it_fldcat-outputlen = '36'.
      ELSEIF wa_it_fldcat-fieldname = 'FORMPAGO'.
        wa_it_fldcat-coltext = TEXT-h39.
        wa_it_fldcat-scrtext_m = TEXT-h39.
        wa_it_fldcat-outputlen = '5'.
      ELSEIF wa_it_fldcat-fieldname = 'MONTOTOTPAGO'.
        wa_it_fldcat-coltext = TEXT-h40.
        wa_it_fldcat-scrtext_m = TEXT-h40.
        wa_it_fldcat-outputlen = '16'.

      ELSEIF wa_it_fldcat-fieldname = 'STATUS'.
      ELSEIF wa_it_fldcat-fieldname = 'TC_PAGO' OR
             wa_it_fldcat-fieldname = 'TC_DR' OR
             wa_it_fldcat-fieldname = 'PAGO_LOCAL' OR
             wa_it_fldcat-fieldname = 'IMP_FACT_LOCAL' OR
             wa_it_fldcat-fieldname = 'UUID_DR' OR
             wa_it_fldcat-fieldname = 'PDF_CANC'.
        wa_it_fldcat-no_out = 'X'.
      ENDIF.
      APPEND wa_it_fldcat TO it_fldcat.
      CLEAR wa_it_fldcat.

    ENDLOOP.

*** Construye la tabla de salida dinamicamente
    CALL METHOD cl_alv_table_create=>create_dynamic_table
      EXPORTING
        it_fieldcatalog  = it_fldcat
        i_length_in_byte = 'X'
      IMPORTING
        ep_table         = dy_table.

    ASSIGN dy_table->* TO <dyn_table>.
    CREATE DATA dy_line LIKE LINE OF <dyn_table>.
    ASSIGN dy_line->* TO <dyn_wa>.
*** Se manda la info a la tabla
    LOOP AT wa_data_alv.
      MOVE-CORRESPONDING wa_data_alv TO <dyn_wa>.
      APPEND <dyn_wa> TO  <dyn_table>.
    ENDLOOP.

  ENDIF.

  "nombre de columnas
  TRY.
      CALL METHOD cl_salv_table=>factory
        IMPORTING
          r_salv_table = gr_table
        CHANGING
          t_table      = <dyn_table>.
    CATCH cx_salv_msg.
  ENDTRY.

  gr_columns = gr_table->get_columns( ).
  REFRESH : lt_column_ref.
  CLEAR : ls_column_ref.
  lt_column_ref = gr_columns->get( ).
  LOOP AT lt_column_ref INTO ls_column_ref.

    TRY.
        gr_column ?= gr_columns->get_column( ls_column_ref-columnname ).
      CATCH cx_salv_not_found.
    ENDTRY.

    IF gr_column IS NOT INITIAL.

      CASE ls_column_ref-columnname.
        WHEN 'BUKRS'.
          gr_column->set_short_text( 'Sociedad' ).
          gr_column->set_medium_text( 'Sociedad' ).
          gr_column->set_long_text( 'Sociedad' ).
        WHEN 'KUNNR'.
          gr_column->set_short_text( 'Cliente' ).
          gr_column->set_medium_text( 'Cliente' ).
          gr_column->set_long_text( 'Cliente' ).
        WHEN 'NAME1'.
          gr_column->set_short_text( 'Nombre' ).
          gr_column->set_medium_text( 'Nombre' ).
          gr_column->set_long_text( 'Nombre' ).
        WHEN 'DOC_PAGO'.
          gr_column->set_short_text( 'Doc Pago' ).
          gr_column->set_medium_text( 'Doc de Pago' ).
          gr_column->set_long_text( 'Doc de Pago' ).
        WHEN 'IND_PC'.
          gr_column->set_short_text( 'P. Total' ).
          gr_column->set_medium_text( 'P. Total' ).
          gr_column->set_long_text( 'P. Total' ).
        WHEN 'IND_PP'.
          gr_column->set_short_text( 'P. Parcial' ).
          gr_column->set_medium_text( 'P. Parcial' ).
          gr_column->set_long_text( 'P. Parcial' ).
        WHEN 'DOC_COMP'.
          gr_column->set_short_text( 'Doc Finac.' ).
          gr_column->set_medium_text( 'Doc financiero' ).
          gr_column->set_long_text( 'Doc financiero' ).
        WHEN 'FACTURA'.
          gr_column->set_short_text( 'Factura' ).
          gr_column->set_medium_text( 'Factura' ).
          gr_column->set_long_text( 'Factura' ).
        WHEN 'ZTERM'.
          gr_column->set_short_text( 'Cond.Pago' ).
          gr_column->set_medium_text( 'Cond.Pago' ).
          gr_column->set_long_text( 'Cond.Pago' ).
        WHEN 'PAGO_DOC'.
          gr_column->set_short_text( 'Imp. Pago' ).
          gr_column->set_medium_text( 'Imp. de Pago' ).
          gr_column->set_long_text( 'Imp. de Pago' ).
        WHEN 'CURRENCY'.
          gr_column->set_short_text( 'Mon. Pago' ).
          gr_column->set_medium_text( 'Moneda Pago' ).
          gr_column->set_long_text( 'Moneda Pago' ).
        WHEN 'CURREN_DR'.
          gr_column->set_short_text( 'Mon. Fact.' ).
          gr_column->set_medium_text( 'Moneda Fact.' ).
          gr_column->set_long_text( 'Moneda Fact.' ).
        WHEN 'BUDAT'.
          gr_column->set_short_text( 'Fecha Pago' ).
          gr_column->set_medium_text( 'Fecha de Pago' ).
          gr_column->set_long_text( 'Fecha de Pago' ).
        WHEN 'PARCIALIDAD'.
          gr_column->set_short_text( 'Parcial.' ).
          gr_column->set_medium_text( 'Parcialidad' ).
          gr_column->set_long_text( 'Parcialidad' ).
        WHEN 'IMP_FACT_DOC'.
          gr_column->set_short_text( 'Imp Fact.' ).
          gr_column->set_medium_text( 'Imp Factura' ).
          gr_column->set_long_text( 'Imp Factura' ).
        WHEN 'FKDAT'.
          gr_column->set_short_text( 'Fecha fact' ).
          gr_column->set_medium_text( 'Fecha fact' ).
          gr_column->set_long_text( 'Fecha fact' ).
        WHEN 'UUID'.
          gr_column->set_short_text( 'UUID' ).
          gr_column->set_medium_text( 'UUID' ).
          gr_column->set_long_text( 'UUID' ).
        WHEN 'COMENTARIO'.
          gr_column->set_short_text( 'Comentario' ).
          gr_column->set_medium_text( 'Comentario' ).
          gr_column->set_long_text( 'Comentario' ).
        WHEN 'STAT_CANC'.
          gr_column->set_short_text( 'Stat.Canc.' ).
          gr_column->set_medium_text( 'Stat.Canc.' ).
          gr_column->set_long_text( 'Stat.Canc.' ).
        WHEN 'BASEIVA16'.
          gr_column->set_short_text( 'B. IVA 16%' ).
          gr_column->set_medium_text( 'Base IVA 16%' ).
          gr_column->set_long_text( 'Base IVA 16%' ).
        WHEN 'IVATRAS16'.
          gr_column->set_short_text( 'T. IVA 16%' ).
          gr_column->set_medium_text( 'IVA Trasl. 16%' ).
          gr_column->set_long_text( 'IVA Trasl. 16%' ).
        WHEN 'BASEIVA0'.
          gr_column->set_short_text( 'B. IVA 0%' ).
          gr_column->set_medium_text( 'Base IVA 0%' ).
          gr_column->set_long_text( 'Base IVA 0%' ).
        WHEN 'SALDOPAGAR'.
          gr_column->set_short_text( 'Saldo Pag.' ).
          gr_column->set_medium_text( 'Saldo Por Pagar' ).
          gr_column->set_long_text( 'Saldo Por Pagar' ).
        WHEN 'SALDOANT'.
          gr_column->set_short_text( 'Saldo Ant.' ).
          gr_column->set_medium_text( 'Saldo Anterior' ).
          gr_column->set_long_text( 'Saldo Anterior' ).
        WHEN 'FOLFIS'.
          gr_column->set_short_text( 'Fol. Fisc.' ).
          gr_column->set_medium_text( 'Folio Fiscal Relac.' ).
          gr_column->set_long_text( 'Folio Fiscal Relac.' ).
        WHEN 'FORMPAGO'.
          gr_column->set_short_text( 'Forma Pago' ).
          gr_column->set_medium_text( 'Forma de Pago' ).
          gr_column->set_long_text( 'Forma de Pago' ).
        WHEN 'MONTOTOTPAGO'.
          gr_column->set_short_text( 'Monto Pago' ).
          gr_column->set_medium_text( 'Monto Pago' ).
          gr_column->set_long_text( 'Monto Pago' ).

      ENDCASE.


    ENDIF.

  ENDLOOP.


ENDFORM.                    " F_CREATE_ALV_STRUCT

*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA
*&---------------------------------------------------------------------*
FORM f_get_data.

*** Limpia todas las tablas del proxy

  v_ejercicio = s_budat-low+0(4).
  v_ejerciciom1 = v_ejercicio - 1.
  v_ejerciciop1 = v_ejercicio + 1.

  CLEAR:   i_lineitems, i_fechas, i_customer.
  REFRESH: i_lineitems, i_fechas, i_customer.

  COMMIT WORK.

*** Llena el parametro de fecha para la bapi
  LOOP AT s_budat.
    MOVE-CORRESPONDING s_budat TO i_fechas.
    APPEND i_fechas.
  ENDLOOP.

*** Llena el parametro de cliente para la bapi
  LOOP AT s_kunnr.
    MOVE-CORRESPONDING s_kunnr TO i_customer.
    APPEND i_customer.
  ENDLOOP.

  CLEAR: i_lineitems.
  REFRESH: i_lineitems.

  CALL FUNCTION 'ZBAPI_AR_ACC_GETOPENITEMS'
    EXPORTING
      companycode = s_bukrs-low
      customer    = '*'
    IMPORTING
      return      = i_return
    TABLES
      lineitems   = i_lineitems
      fechas      = i_fechas
      customer2   = i_customer.

  SORT i_lineitems BY doc_no.

*** Borra los documentos no solicitados
  DELETE i_lineitems WHERE doc_no NOT IN s_belnr.

*** Borra los documentos de compensacion
  DELETE i_lineitems WHERE doc_no+0(4) = '0100'.

*** Borra los docuemtnos anulados
  DELETE i_lineitems WHERE reversal_doc IS NOT INITIAL.

  DATA: BEGIN OF i_line_dup OCCURS 0,
          cant   TYPE i,
          doc_no LIKE i_lineitems-doc_no.
  DATA: END OF i_line_dup.

  LOOP AT i_lineitems.
    MOVE-CORRESPONDING i_lineitems TO i_line_dup.
    i_line_dup-cant = 1.
    COLLECT i_line_dup.
  ENDLOOP.

  DELETE i_line_dup WHERE cant = 1.

  LOOP AT i_line_dup.
    DELETE i_lineitems WHERE
      customer+0(2) = 'IS'       AND
      doc_no = i_line_dup-doc_no AND
      clear_date IS INITIAL  AND
      clr_doc_no IS INITIAL.
  ENDLOOP.

  DELETE ADJACENT DUPLICATES FROM i_lineitems.

  IF i_lineitems[] IS INITIAL.
    IF sy-langu = 'S'.
      MESSAGE e001(00) WITH 'No existe informacion para los' ' criterios de selección'.
      EXIT.
    ELSE.
      MESSAGE e001(00) WITH 'No information found for' ' selection criteria'.
      EXIT.
    ENDIF.
    EXIT.
  ENDIF.

*** Si encontro documentos de pago a procesar
  IF i_lineitems[] IS NOT INITIAL.

*** Copia la tabla de documentos para conservar los 11 y 01
    CLEAR: i_lineitems_comp.
    i_lineitems_comp[] = i_lineitems[].

*** Para los pagos totales debe ir a buscar los documentos relacionados
    CLEAR:   i_bsad.
    REFRESH: i_bsad[].

    SELECT *
      FROM bsad
      INTO TABLE i_bsad
      FOR ALL ENTRIES IN i_lineitems
      WHERE bukrs = s_bukrs-low
      AND   kunnr = i_lineitems-customer
      AND   augbl = i_lineitems-doc_no
      AND   augdt = i_lineitems-pstng_date
      AND   bschl = '01'.

*** Este cambio es por las que tienen pagos antes de la fecha de la factura
*** y no salen cuando se corre en conjunto...
    SELECT *
    FROM bsad
    APPENDING CORRESPONDING FIELDS OF TABLE i_bsad
    FOR ALL ENTRIES IN i_lineitems
    WHERE bukrs = s_bukrs-low
    AND   kunnr = i_lineitems-customer
    AND   augbl = i_lineitems-doc_no
*      AND   AUGDT = I_LINEITEMS-PSTNG_DATE
    AND   gjahr = i_lineitems-pstng_date+0(4)
    AND   bschl = '01'.

    DELETE ADJACENT DUPLICATES FROM i_bsad.

*** Barre cada documento de pago **********************************************************************
    CLEAR:   i_documentos.
    REFRESH: i_documentos.

    DATA: v_tabix_items TYPE sy-tabix.
    SORT i_lineitems BY doc_no.
    LOOP AT i_lineitems  WHERE post_key = '15'
                            OR post_key = '16'
                            OR post_key = '17'. " Complementos de compensación de Chedraui
      CLEAR v_tabix_items.
      v_tabix_items = sy-tabix.
**** Cuando es un documento de pago final no tiene las referencias
      IF i_lineitems-bill_doc IS INITIAL AND                   " PAGO TOTAL FACTURA LOGISTICA
         i_lineitems-inv_ref    IS INITIAL.

        LOOP AT i_bsad WHERE bukrs = s_bukrs-low
                         AND kunnr = i_lineitems-customer
                         AND augbl = i_lineitems-doc_no
                         AND bschl = '01'.

          IF i_bsad-vbeln IS NOT INITIAL.
            i_documentos-tipo   = 'SDT'.                           " Factura de ventas pago total
            i_documentos-factura        = i_bsad-vbeln.
            i_documentos-doc_comp       = i_bsad-belnr.
            i_documentos-doc_pago       = i_lineitems-doc_no.
            i_documentos-doc_clr        = i_lineitems-clr_doc_no.
            i_documentos-kunnr          = i_lineitems-customer.
          ELSE.
            i_documentos-tipo   = 'FIT'.                           " Factura de ventas pago total
            i_documentos-factura        = i_bsad-belnr.
            i_documentos-doc_comp       = i_bsad-belnr.
            i_documentos-doc_pago       = i_lineitems-doc_no.
            i_documentos-doc_clr        = i_lineitems-clr_doc_no.
            i_documentos-kunnr          = i_lineitems-customer.
          ENDIF.
          APPEND i_documentos.
        ENDLOOP.

      ELSEIF i_lineitems-bill_doc IS NOT INITIAL AND            " PAGO PARCIAL FACTURA LOGISTICA
             i_lineitems-inv_ref    IS NOT INITIAL.
        i_documentos-tipo   = 'SDP'.            " Factura de ventas pago parcial
        i_documentos-factura  = i_lineitems-bill_doc.   "ALLOC_NMBR.
        i_documentos-doc_pago = i_lineitems-doc_no.
        i_documentos-doc_comp = i_lineitems-inv_ref.
        i_documentos-doc_clr        = i_lineitems-clr_doc_no.
        i_documentos-kunnr          = i_lineitems-customer.
        APPEND i_documentos.

*** Cuando es una factura financiera se debe de ir a sacar el resto de la info
      ELSEIF i_lineitems-bill_doc IS INITIAL AND                " PAGO PARCIAL FACTURA FINANCIERA
             i_lineitems-inv_ref    IS NOT INITIAL.
        i_documentos-tipo   = 'FIP'.                               " Factura financiera
        i_documentos-factura  = i_lineitems-inv_ref."I_LINEITEMS-ALLOC_NMBR.
        i_documentos-doc_pago = i_lineitems-doc_no.
        i_documentos-doc_comp = i_lineitems-inv_ref.
        i_documentos-doc_clr  = i_lineitems-clr_doc_no.
        i_documentos-kunnr    = i_lineitems-customer.
        APPEND i_documentos.
      ELSE.
        i_documentos-tipo   = 'FIT'.            " Factura de ventas pago parcial
        i_documentos-factura  = i_lineitems-inv_ref.
        i_documentos-doc_pago = i_lineitems-doc_no.
        i_documentos-doc_comp = i_lineitems-inv_ref.
        i_documentos-doc_clr  = i_lineitems-clr_doc_no.
        i_documentos-kunnr    = i_lineitems-customer.
        APPEND i_documentos.

      ENDIF.

    ENDLOOP.

    IF i_documentos[] IS INITIAL.
      IF sy-langu = 'S'.
        MESSAGE e001(00) WITH 'No existen pagos a procesar'.
        EXIT.
      ELSE.
        MESSAGE e001(00) WITH 'No payments to process'.
        EXIT.
      ENDIF.
      EXIT.
    ENDIF.
    SORT i_documentos.
    DELETE ADJACENT DUPLICATES FROM i_documentos.

*** Elimina documentos que tengan metodo de pago PUE

*** Valida el metodo de pagod e la factura
    DATA: i_zsd_cfdi_timbre_pue TYPE zsd_cfdi_timbre OCCURS 0 WITH HEADER LINE.
    CLEAR: i_zsd_cfdi_timbre_pue.
    REFRESH: i_zsd_cfdi_timbre_pue.

    SELECT *
      FROM zsd_cfdi_timbre
      INTO TABLE i_zsd_cfdi_timbre_pue
      FOR ALL ENTRIES IN i_documentos
      WHERE vbeln = i_documentos-factura
      AND metodo_pago = 'PUE'.

    LOOP AT i_documentos.

      READ TABLE i_zsd_cfdi_timbre_pue WITH KEY
          vbeln = i_documentos-factura.
      IF sy-subrc EQ 0.
        DELETE i_documentos.
      ENDIF.
    ENDLOOP.

*** Valida el metodo de pago directo del campo del pedido de la factura
    DATA: i_vbrp_pue TYPE vbrp OCCURS 0 WITH HEADER LINE,
          i_vbak_pue TYPE vbak OCCURS 0 WITH HEADER LINE.

    CLEAR:   i_vbrp_pue, i_vbak_pue.
    REFRESH: i_vbrp_pue, i_vbak_pue.

    SELECT *
      FROM vbrp
      INTO TABLE i_vbrp_pue
      FOR ALL ENTRIES IN i_documentos
      WHERE vbeln = i_documentos-factura.

    SELECT *
      FROM vbak
      INTO TABLE i_vbak_pue
      FOR ALL ENTRIES IN i_vbrp_pue
      WHERE vbeln = i_vbrp_pue-aubel.

    LOOP AT i_documentos.
*** Extrae el pedido
      CLEAR: i_vbrp_pue, i_vbak_pue.
      READ TABLE i_vbrp_pue WITH KEY vbeln = i_documentos-factura.
      IF sy-subrc EQ 0.
        READ TABLE i_vbak_pue WITH KEY vbeln = i_vbrp_pue-aubel.
        IF sy-subrc EQ 0.
          IF i_vbak_pue-kvgr2 = 'PUE'.
            DELETE i_documentos.
          ENDIF.
        ENDIF.
      ENDIF.

    ENDLOOP.

*** Saca los campos de la factura que se envian al ALV y al SAT
    DATA: i_zsd_cfdi_timbre TYPE zsd_cfdi_timbre OCCURS 0 WITH HEADER LINE.
    CLEAR: i_zsd_cfdi_timbre.

    SELECT *                                                       " D001
      FROM zsd_cfdi_timbre
      INTO TABLE i_zsd_cfdi_timbre
      FOR ALL ENTRIES IN i_documentos
      WHERE vbeln = i_documentos-factura.
*** Agregar logica para extraer el UUID de las facturas logisticas
*** Fin de modificar M001
  ENDIF.
  .
*** Extrae todos los registros ya con status para los documentos de pago
  CLEAR i_zalv_comp_pago.
  REFRESH i_zalv_comp_pago.

  SELECT *
    FROM zalv_comp_pago
    INTO TABLE i_zalv_comp_pago
    FOR ALL ENTRIES IN i_documentos
    WHERE bukrs    = s_bukrs-low
    AND   doc_pago = i_documentos-doc_pago
    AND   factura  = i_documentos-factura.

  CLEAR:  gt_data.
  REFRESH gt_data.

  SORT i_documentos BY doc_pago ASCENDING.
  LOOP AT i_documentos.
    MOVE-CORRESPONDING i_documentos TO gt_data.
*** Asigna el UUID DEL PAGO **********************************************************************
    READ TABLE i_zalv_comp_pago WITH KEY doc_pago = i_documentos-doc_pago
                                         factura  = i_documentos-factura.
    IF sy-subrc EQ 0.
      MOVE-CORRESPONDING i_zalv_comp_pago TO gt_data.
    ENDIF.
*** Asigna el UUID de la factura de ventas **********************************************************************
    READ TABLE i_zsd_cfdi_timbre WITH KEY vbeln = i_documentos-factura.
    IF sy-subrc EQ 0.
      gt_data-uuid_dr = i_zsd_cfdi_timbre-uuid.

    ELSE.
      gt_data-kunnr = i_documentos-kunnr.
      v_flag_ci = 'X'.

      SELECT SINGLE sgtxt zuonr
        FROM bsad
        INTO (gt_data-uuid_dr, v_zuonr_ci)
        WHERE bukrs = s_bukrs-low
        AND   augbl = i_documentos-doc_pago
        AND   belnr = i_documentos-doc_comp
        AND   blart = 'DR'
        AND   bschl = '01'.

      IF sy-subrc NE 0.
        SELECT SINGLE sgtxt
          FROM bsid
          INTO gt_data-uuid_dr
          WHERE bukrs = s_bukrs-low
          AND   belnr = i_documentos-doc_comp
          AND   blart = 'DR'
          AND   bschl = '01'.
        IF sy-subrc NE 0.
          SELECT SINGLE sgtxt zuonr
            FROM bsad
            INTO (gt_data-uuid_dr, v_zuonr_ci)
            WHERE bukrs = s_bukrs-low
            AND   belnr = i_documentos-doc_comp
            AND   blart = 'DR'
            AND   bschl = '01'.
        ENDIF.

      ENDIF.
    ENDIF.
    APPEND gt_data.

    CLEAR: i_documentos, gt_data, i_zalv_comp_pago.

  ENDLOOP.

ENDFORM.                    " F_GET_DATA

*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_DATA
*&---------------------------------------------------------------------*
FORM f_process_data .

  REFRESH gt_data_alv.

  CLEAR:   i_vbrk, i_bkpf.
  REFRESH: i_vbrk[], i_bkpf[].

*** Extrae los datos adicoinales de cada factura
  SELECT *
    FROM vbrk
    INTO TABLE i_vbrk
    FOR ALL ENTRIES IN gt_data
    WHERE vbeln = gt_data-factura.

  IF gt_data[] IS INITIAL.
    IF sy-langu = 'S'.
      MESSAGE e001(00) WITH 'No existen pagos a procesar'.
      EXIT.
    ELSE.
      MESSAGE e001(00) WITH 'No payments to process'.
      EXIT.
    ENDIF.
    EXIT.
  ENDIF.
*** Extrae los datos adicionales de cada documento de pago
  SELECT *
    FROM bkpf
    INTO TABLE i_bkpf
    FOR ALL ENTRIES IN gt_data
    WHERE bukrs = s_bukrs-low
    AND   belnr = gt_data-doc_pago
    AND   ( gjahr = v_ejercicio OR gjahr = v_ejerciciop1 ).


*** Para cada documento encontrado
  LOOP AT gt_data.

*** Valida si es un pago unico o es un pago multiple
    DATA: v_lines TYPE i.
    CLEAR v_lines.

    LOOP AT i_documentos WHERE doc_pago = gt_data-doc_pago.
      ADD 1 TO v_lines.
    ENDLOOP.
    CLEAR: i_vbrk, i_documentos, i_lineitems, i_zalv_comp_pago.

*** Se lee la tabla del detalle de pago
    READ TABLE i_vbrk WITH KEY vbeln = gt_data-factura.
    READ TABLE i_documentos WITH KEY factura  = gt_data-factura
                                     doc_pago = gt_data-doc_pago
                                     doc_comp = gt_data-doc_comp.
    READ TABLE i_bkpf WITH KEY belnr = gt_data-doc_pago.

*** Se lee la tabla con toda la info de la bapi
    IF v_lines = 1.
      READ TABLE i_lineitems WITH KEY doc_no      = gt_data-doc_pago.
    ELSE.
      IF i_documentos-tipo = 'SDP'.
        READ TABLE i_lineitems WITH KEY doc_no      = gt_data-doc_pago
                                        bill_doc    = gt_data-factura
                                        inv_ref     = gt_data-doc_comp.
      ELSEIF i_documentos-tipo = 'FIP'.
        READ TABLE i_lineitems WITH KEY doc_no      = gt_data-doc_pago
                                        inv_ref     = gt_data-doc_comp.
      ENDIF.
    ENDIF.

*** Se asigna el UUID correspondiente
    wa_data_alv-uuid       = gt_data-uuid.
    "wa_data_alv-uuid_dr    = gt_data-uuid_dr.
    wa_data_alv-comentario = gt_data-comentario.
    wa_data_alv-parcialidad = gt_data-numparcialidad.
    wa_data_alv-stat_canc = gt_data-stat_canc.
    "wa_data_alv-status = gt_data-status.

    IF gt_data-uuid IS NOT INITIAL.
      wa_data_alv-pdf = icon_pdf.
      wa_data_alv-xml = icon_xml_doc.
    ENDIF.
    IF gt_data-stat_canc IS NOT INITIAL.
      "wa_data_alv-pdf_canc = icon_pdf.
    ENDIF.

*** CAMPOS DEL ALV **********************************************************************

*** Si la factura ya fue timbrada se pone en rojo
*** Si tuvo algun error se pone en amarillo
*** Si todo esta bien se pone en verde para enviar
    READ TABLE i_zalv_comp_pago WITH KEY doc_pago = gt_data-doc_pago
                                         factura  = gt_data-factura.

    CASE i_zalv_comp_pago-semaforo.
      WHEN 'T'.                         " Timbrada
        wa_data_alv-anulada = icon_green_light.
      WHEN 'S'.                         " Timbrada
        wa_data_alv-anulada = icon_green_light.
      WHEN 'P'.                         " Enviada al PAC
        wa_data_alv-anulada = icon_yellow_light.
      WHEN space.                         " Nueva
        wa_data_alv-anulada = icon_red_light.
      WHEN 'E'.                         " Error
        wa_data_alv-anulada = icon_red_light.
      WHEN OTHERS.
        wa_data_alv-anulada = icon_red_light.
    ENDCASE.

    wa_data_alv-bukrs           = s_bukrs-low.                          " Sociedad

*** De la tabla GT_DATA
    wa_data_alv-doc_pago        = gt_data-doc_pago.                     " Documento de pago
    wa_data_alv-factura         = gt_data-factura.                      " Factura
    wa_data_alv-doc_comp        = gt_data-doc_comp.                     " Documento de compensacion

*** De la tabla de la BAPI
    READ TABLE i_documentos WITH KEY factura = gt_data-factura
    doc_pago = gt_data-doc_pago
    doc_comp = gt_data-doc_comp.
    IF i_documentos-tipo = 'SDT'     OR i_documentos-tipo = 'FIT'.
      wa_data_alv-ind_pc = 'X'.
    ELSEIF i_documentos-tipo = 'SDP' OR i_documentos-tipo = 'FIP'.
      wa_data_alv-ind_pp = 'X'.
    ENDIF.

    IF i_lineitems-customer IS INITIAL.
*** Va y busca la info en la tabla BSAD porque es un pago total
      CLEAR: v_monto_pago_doc, v_monto_fact_doc,
             v_monto_pago_local, v_monto_fact_local.

      IF i_documentos-tipo = 'SDT'.
*** Extrae el monto del pago
        READ TABLE i_bsad WITH KEY vbeln = gt_data-factura
                                   belnr = gt_data-doc_comp
                                   augbl = gt_data-doc_pago.
        v_monto_pago_doc   = i_bsad-wrbtr.
        v_monto_pago_local = i_bsad-dmbtr.

        DATA: i_bsad_nc LIKE bsad OCCURS 0 WITH HEADER LINE.
        CLEAR i_bsad_nc.
        REFRESH i_bsad_nc.

        SELECT *
          FROM bsad
          INTO TABLE i_bsad_nc
          WHERE kunnr = gt_data-kunnr
          AND   augbl = gt_data-doc_pago
          AND   zuonr = gt_data-factura
          AND   bschl = '11'.

        IF NOT i_bsad_nc[] IS INITIAL.
          LOOP AT i_bsad_nc.
            v_monto_pago_doc   = v_monto_pago_doc   - i_bsad_nc-wrbtr.
            v_monto_pago_local = v_monto_pago_local - i_bsad_nc-dmbtr.
          ENDLOOP.
        ENDIF.

      ELSEIF i_documentos-tipo = 'FIT'.
*** Extrae el monto del pago
        READ TABLE i_bsad WITH KEY vbeln = space
                                   belnr = gt_data-doc_comp
                                   augbl = gt_data-doc_pago.


        v_monto_pago_doc   = i_bsad-wrbtr.
        v_monto_pago_local = i_bsad-dmbtr.

        CLEAR i_bsad_nc.
        REFRESH i_bsad_nc.

        DATA: v_zuonr_nc TYPE bsad-zuonr.
        CLEAR v_zuonr_nc.

        SELECT SINGLE zuonr
          FROM bsad
          INTO v_zuonr_nc
          WHERE bukrs = s_bukrs-low
          AND   kunnr = gt_data-kunnr
          AND   augbl = gt_data-doc_pago
          AND   belnr = gt_data-factura
          AND   zuonr NE space.

        SELECT *
          FROM bsad
          INTO TABLE i_bsad_nc
          WHERE bukrs = s_bukrs-low
          AND   kunnr = gt_data-kunnr
          AND   augbl = gt_data-doc_pago
          AND   zuonr = v_zuonr_nc
          AND   bschl = '11'.

        IF NOT i_bsad_nc[] IS INITIAL.
          LOOP AT i_bsad_nc.
            v_monto_pago_doc   = v_monto_pago_doc   - i_bsad_nc-wrbtr.
            v_monto_pago_local = v_monto_pago_local - i_bsad_nc-dmbtr.
          ENDLOOP.
        ENDIF.



*** Valida si tiene pagos previos (para ver si es liquidacion)
      ENDIF.

      CLEAR:   i_bsid_bsad_pagos.
      REFRESH: i_bsid_bsad_pagos.

      SELECT augbl rebzg wrbtr dmbtr
        FROM bsid
      INTO CORRESPONDING FIELDS OF TABLE i_bsid_bsad_pagos
        WHERE bukrs = s_bukrs-low
        AND   rebzg = gt_data-doc_comp
        AND   gjahr = v_ejercicio
        AND   kunnr = gt_data-kunnr                   " REVISAR
        AND   xstov NE 'X'.

      SELECT augbl rebzg wrbtr dmbtr
        FROM bsad
      APPENDING CORRESPONDING FIELDS OF TABLE i_bsid_bsad_pagos
        WHERE bukrs = s_bukrs-low
        AND   rebzg = gt_data-doc_comp
        AND   augbl = gt_data-doc_pago
        AND   gjahr = v_ejercicio
        AND   kunnr = gt_data-kunnr                   " REVISAR
        AND   xstov NE 'X'.

      IF i_bsid_bsad_pagos[] IS NOT INITIAL.
        LOOP AT i_bsid_bsad_pagos.
          v_monto_pago_doc = v_monto_pago_doc - i_bsid_bsad_pagos-wrbtr.
          v_monto_pago_local = v_monto_pago_local - i_bsid_bsad_pagos-dmbtr.
        ENDLOOP.
      ENDIF.

      IF i_bsad-qsskz = 'XX'.

        CLEAR v_wt_qbshb.

        SELECT SINGLE wt_qbshb
          FROM with_item
          INTO v_wt_qbshb
          WHERE belnr = i_bsad-belnr.
        v_monto_pago_doc = v_monto_pago_doc - v_wt_qbshb.
        v_monto_pago_local = v_monto_pago_local - v_wt_qbshb.
      ENDIF.

      wa_data_alv-kunnr           = i_bsad-kunnr.                     " Cliente
      SELECT SINGLE name1
        INTO wa_data_alv-name1
        FROM kna1
        WHERE kunnr = i_bsad-kunnr.
      wa_data_alv-pago_doc        = v_monto_pago_doc.                 " Importe de pago en moneda del documento
      "wa_data_alv-pago_local      = v_monto_pago_local.               " Importe de pago en moneda local
      wa_data_alv-currency        = i_bsad-waers.                     " Moneda de pago
      WRITE i_bsad-augdt TO wa_data_alv-budat.                        " Fecha de pago
      v_fecha_pago = i_bsad-augdt.


    ELSE.
      CLEAR:   v_monto_pago_local, v_monto_pago_doc,
       v_monto_pago_local2, v_monto_pago_doc2.
** Valida si existe un documento 08 con el importe correcto
      SELECT SINGLE wrbtr dmbtr
        INTO (v_monto_pago_doc2, v_monto_pago_local2)
        FROM bsad
        WHERE bukrs = s_bukrs-low
        AND   kunnr = i_lineitems-customer
      AND   augbl = wa_data_alv-doc_pago
      AND   gjahr = v_ejercicio
      AND   bschl = '08'.


      v_monto_pago_doc   = i_lineitems-amt_doccur - v_monto_pago_doc2.
      v_monto_pago_local = i_lineitems-lc_amount - v_monto_pago_local2.

*** Valida si tiene retencion
      DATA: v_qsskz TYPE bsid-qsskz.
      CLEAR: v_qsskz.

      READ TABLE i_bsad WITH KEY vbeln = gt_data-factura
                                 belnr = gt_data-doc_comp
                                 augbl = gt_data-doc_pago.

      IF sy-subrc NE 0.
*** Es un pago parcial
        SELECT SINGLE qsskz
          FROM bsid
          INTO v_qsskz
          WHERE ( kunnr = gt_data-kunnr OR kunnr = i_lineitems-customer )
          AND   belnr = gt_data-doc_comp
          AND   gjahr = v_ejercicio.
      ENDIF.

      IF i_bsad-qsskz = 'XX' OR v_qsskz = 'XX'.
        CLEAR v_wt_qbshb.

        IF v_qsskz = 'XX'.
          SELECT SINGLE wt_qbshb
            FROM with_item
            INTO v_wt_qbshb
            WHERE belnr = gt_data-doc_pago
            AND   gjahr = v_ejercicio.
          v_wt_qbshb = abs( v_wt_qbshb ).
        ELSE.

          SELECT SINGLE wt_qbshb
            FROM with_item
            INTO v_wt_qbshb
            WHERE belnr = gt_data-doc_comp
            AND   gjahr = v_ejercicio.
        ENDIF.

        v_monto_pago_doc = v_monto_pago_doc - v_wt_qbshb.
        v_monto_pago_local = v_monto_pago_local - v_wt_qbshb.
      ENDIF.

      v_monto_pago_doc            = v_monto_pago_doc.                 " Pago en la moneda del documento
      v_monto_pago_local          = v_monto_pago_local.               " Pago en la moneda local
      wa_data_alv-kunnr           = i_lineitems-customer.             " Cliente
      SELECT SINGLE name1
        INTO wa_data_alv-name1
        FROM kna1
        WHERE kunnr = i_lineitems-customer.
      wa_data_alv-pago_doc        = v_monto_pago_doc.                 " Importe de pago en moneda documento
      "wa_data_alv-pago_local      = v_monto_pago_local.               " Importe de pago en moneda local
      wa_data_alv-currency        = i_lineitems-currency.             " Moneda de pago
      WRITE i_lineitems-pstng_date TO wa_data_alv-budat.              " Fecha de pago
      v_fecha_pago = i_lineitems-pstng_date.

    ENDIF.

*** De la tabla de facturas
    IF i_documentos-tipo = 'SDT' OR i_documentos-tipo = 'SDP'.

      CLEAR: v_monto_fact_doc, v_monto_fact_local.

      DATA: i_bsad_nc_parc        LIKE bsad OCCURS 0 WITH HEADER LINE,
            v_monto_doc_nc_parc   TYPE p DECIMALS 2,
            v_monto_local_nc_parc TYPE p DECIMALS 2.

      CLEAR: i_bsad_nc_parc, v_monto_doc_nc_parc,
             v_monto_local_nc_parc.
      REFRESH i_bsad_nc_parc.

      SELECT *
        FROM bsad
        INTO TABLE i_bsad_nc_parc
        WHERE kunnr = gt_data-kunnr
        AND   augbl = gt_data-doc_pago
        AND   zuonr = gt_data-factura
        AND   bschl = '11'.

      IF i_bsad_nc_parc[] IS NOT INITIAL.
        LOOP AT i_bsad_nc_parc.
          ADD i_bsad_nc_parc-wrbtr TO v_monto_doc_nc_parc.
          ADD i_bsad_nc_parc-dmbtr TO v_monto_local_nc_parc.
        ENDLOOP.
      ENDIF.

      IF v_qsskz = 'XX'.
        v_monto_fact_doc = i_vbrk-netwr - v_monto_doc_nc_parc.
      ELSE.
        v_monto_fact_doc = i_vbrk-netwr + i_vbrk-mwsbk -
                           v_monto_doc_nc_parc.        " Importe de la factura en moneda local
      ENDIF.
      wa_data_alv-imp_fact_doc = v_monto_fact_doc.
      CONDENSE wa_data_alv-imp_fact_doc.

      IF i_vbrk-waerk NE 'MXN' AND i_vbrk-waerk NE 'MXP'.
        IF v_qsskz = 'XX'.
          v_monto_fact_local = ( i_vbrk-netwr - v_monto_local_nc_parc ) *
                                 i_vbrk-kurrf.        " Importe de la factura en moneda local
        ELSE.
          v_monto_fact_local = ( i_vbrk-netwr +
                                 i_vbrk-mwsbk -
                                 v_monto_local_nc_parc ) *
                                 i_vbrk-kurrf.        " Importe de la factura en moneda local
        ENDIF.
        "wa_data_alv-imp_fact_local = v_monto_fact_local.
        "CONDENSE wa_data_alv-imp_fact_local.
      ELSE.
*        wa_data_alv-imp_fact_local = v_monto_fact_doc.
*        CONDENSE wa_data_alv-imp_fact_local.
      ENDIF.

      WRITE i_vbrk-fkdat TO wa_data_alv-fkdat.         " Fecha de la factura
      v_fecha_fact = i_vbrk-fkdat.
      wa_data_alv-curren_dr = i_vbrk-waerk.

      IF i_vbrk-kurrf > 0.
        "wa_data_alv-tc_dr     = i_vbrk-kurrf.
      ENDIF.

    ELSEIF i_documentos-tipo = 'FIP' OR i_documentos-tipo = 'FIT'.

      DATA: v_wrbtr_fi   LIKE bsid-wrbtr,
            v_dmbtr_fi   LIKE bsid-dmbtr,
            v_bldat_fi   LIKE bsid-bldat,
            v_waers_fi   LIKE bsid-waers,
            v_kunnr_pago TYPE kunnr,
            v_gjahr_pago TYPE gjahr.

      CLEAR: v_wrbtr_fi, v_dmbtr_fi, v_bldat_fi, v_monto_fact_doc, v_monto_fact_local, v_waers_fi,
             v_kunnr_pago, v_gjahr_pago.

      v_kunnr_pago = i_lineitems-customer.
      SELECT SINGLE name1
        INTO wa_data_alv-name1
        FROM kna1
        WHERE kunnr = i_lineitems-customer.
      v_gjahr_pago = i_lineitems-fisc_year.

      IF v_kunnr_pago IS INITIAL.
        v_kunnr_pago = i_bsad-kunnr.
      ENDIF.

      IF v_gjahr_pago IS INITIAL.
        v_gjahr_pago = i_bsad-gjahr.
      ENDIF.

      SELECT SINGLE wrbtr dmbtr bldat waers
        FROM bsid
        INTO (v_wrbtr_fi, v_dmbtr_fi, v_bldat_fi, v_waers_fi)
        WHERE bukrs = s_bukrs-low
        AND   kunnr = v_kunnr_pago
        AND   belnr = gt_data-doc_comp
        AND   gjahr = v_gjahr_pago.
      IF v_wrbtr_fi IS INITIAL.
        SELECT SINGLE wrbtr dmbtr bldat waers
        FROM bsad
        INTO (v_wrbtr_fi, v_dmbtr_fi, v_bldat_fi, v_waers_fi)
        WHERE bukrs = s_bukrs-low
        AND   kunnr = v_kunnr_pago
        AND   belnr = gt_data-doc_comp
        AND   gjahr = v_gjahr_pago.
        IF sy-subrc NE 0 AND ( gt_data-doc_comp = gt_data-factura ).
          DATA: v_gjahr_pago_temp LIKE v_gjahr_pago.
          CLEAR v_gjahr_pago_temp.
          v_gjahr_pago_temp = v_gjahr_pago - 1.
          SELECT SINGLE wrbtr dmbtr bldat waers
            FROM bsid
            INTO (v_wrbtr_fi, v_dmbtr_fi, v_bldat_fi, v_waers_fi)
            WHERE bukrs = s_bukrs-low
            AND   kunnr = v_kunnr_pago
            AND   belnr = gt_data-doc_comp
            AND   gjahr = v_gjahr_pago_temp.
          IF v_wrbtr_fi IS INITIAL.
            SELECT SINGLE wrbtr dmbtr bldat waers
              FROM bsad
              INTO (v_wrbtr_fi, v_dmbtr_fi, v_bldat_fi, v_waers_fi)
              WHERE bukrs = s_bukrs-low
              AND   kunnr = v_kunnr_pago
              AND   belnr = gt_data-doc_comp
             AND   gjahr = v_gjahr_pago_temp.
          ENDIF.
        ENDIF.
      ENDIF.

      v_monto_fact_doc = v_wrbtr_fi.
      v_monto_fact_local = v_dmbtr_fi.
      "wa_data_alv-imp_fact_local = v_monto_fact_local.
      wa_data_alv-imp_fact_doc   = v_monto_fact_doc.
      "CONDENSE wa_data_alv-imp_fact_local.
      CONDENSE wa_data_alv-imp_fact_doc.
      WRITE v_bldat_fi TO wa_data_alv-fkdat.
      v_fecha_fact = v_bldat_fi.
      wa_data_alv-curren_dr = v_waers_fi.

    ENDIF.
    IF i_bkpf-kursf NE 0.
      IF i_bkpf-kursf > 0.
        "wa_data_alv-tc_pago          = i_bkpf-kursf.
      ELSEIF i_bkpf-kursf < 0.
        "wa_data_alv-tc_pago        = 1 / abs( i_bkpf-kursf ).
      ENDIF.
      "CONDENSE wa_data_alv-tc_pago.
    ELSE.
    ENDIF.

*    IF wa_data_alv-tc_pago = 0.
*      wa_data_alv-tc_pago = 1.
*    ENDIF.

*** Le da formato a los importes
    DATA: v_importe TYPE wrbtr.
    CLEAR v_importe.
    v_importe = wa_data_alv-imp_fact_doc.
    WRITE v_importe CURRENCY 'MXN' TO wa_data_alv-imp_fact_doc.
    CONDENSE wa_data_alv-imp_fact_doc.

    CLEAR v_importe.
    v_importe = wa_data_alv-pago_doc.
    WRITE v_importe CURRENCY 'MXN' TO wa_data_alv-pago_doc.
    CONDENSE wa_data_alv-pago_doc.

    "Consulta al XML guardado en AWS; Jaime Hernandez Velasquez 21/06/2023
    CLEAR xml_file.
    xml_file = gt_data-archivoxml.
    REFRESH it_xmlsat.
    IF xml_file IS NOT INITIAL.
      PERFORM transformar_xml TABLES it_xmlsat[] USING xml_file.
    ENDIF.

    IF it_xmlsat[] IS NOT INITIAL.

      PERFORM distribuir_xml TABLES it_xmlsat
                             CHANGING wa_data_alv.
   endif.

    IF p_rad1 IS INITIAL AND wa_data_alv-uuid IS NOT INITIAL.
      CLEAR: wa_data_alv, i_vbrk, i_lineitems, i_lineitems_comp, i_zalv_comp_pago, i_bsad.
      CONTINUE.
    ELSE.
      APPEND wa_data_alv.
    ENDIF.

    CLEAR: wa_data_alv, i_vbrk, i_lineitems, i_lineitems_comp, i_zalv_comp_pago, i_bsad.

  ENDLOOP.

  SORT wa_data_alv.
  DELETE ADJACENT DUPLICATES FROM wa_data_alv.

ENDFORM.                    " F_PROCESS_DATA


**&---------------------------------------------------------------------*
**&      Form  F_AGRUPA_PAGO
**&---------------------------------------------------------------------*
FORM f_agrupa_pago .

*** Primero hace una tabla con los pagos a procesar sin importar
*** si selecciono uno o varios renglones del pago
  DATA: BEGIN OF wa_data_alv_temp OCCURS 0,
          v_doc_pago_check LIKE wa_data_alv-doc_pago.
  DATA: END OF wa_data_alv_temp.

  CLEAR:   wa_data_alv_temp,i_log, i_data_alv.
  REFRESH: wa_data_alv_temp,i_log, i_data_alv.

  DESCRIBE TABLE <dyn_table> LINES t_size.
  t_index = 1.
  WHILE t_index LE t_size.
    CLEAR wa_data_alv.
    READ TABLE <dyn_table> INDEX t_index INTO wa_data_alv..
*** Procesa solo los renglones seleccionados
    IF wa_data_alv-check = 'X'.
      wa_data_alv_temp-v_doc_pago_check = wa_data_alv-doc_pago.
      APPEND wa_data_alv_temp.
    ENDIF.
    t_index = t_index + 1.
  ENDWHILE.

*** Vuelve a barrer para conservar TODOS los renglones de los pagos
*** seleccionados aunque solo tuviera un check
  DESCRIBE TABLE <dyn_table> LINES t_size.
  t_index = 1.

  WHILE t_index LE t_size.
    CLEAR wa_data_alv.
    READ TABLE <dyn_table> INDEX t_index INTO wa_data_alv.
*** Procesa solo los renglones seleccionados
    READ TABLE wa_data_alv_temp WITH KEY v_doc_pago_check = wa_data_alv-doc_pago.
    IF sy-subrc EQ 0.
      IF wa_data_alv-uuid IS INITIAL.
        MOVE-CORRESPONDING wa_data_alv TO i_data_alv.
        i_data_alv-llave = wa_data_alv-doc_pago.
        APPEND i_data_alv.
      ELSE.
        CONCATENATE 'Documento:' wa_data_alv-doc_pago INTO i_log-msg1 SEPARATED BY space.
        i_log-msg2 = 'previamente timbrado'.
        APPEND i_log.
      ENDIF.
    ENDIF.
    t_index = t_index + 1.
  ENDWHILE.

  IF i_log[] IS NOT INITIAL.
    PERFORM f_ventana_log.
  ENDIF.

  DELETE ADJACENT DUPLICATES FROM i_data_alv.

  IF i_data_alv[] IS NOT INITIAL.
    PERFORM f_llena_tablas_comp.
  ENDIF.

ENDFORM.                    " F_AGRUPA_PAGO

*&---------------------------------------------------------------------*
*&      Form  F_LLENA_TABLAS_COMP
*&---------------------------------------------------------------------*
FORM f_llena_tablas_comp .

*** Para calcular saldos insolutos, parcialidades etc debe ir a buscar todo los
*** pagos de las facturas a procesar
  CLEAR:   i_bsad_extra, i_bkpf_fi, i_kna1.
  REFRESH: i_bsad_extra[], i_bkpf_fi[], i_kna1[].

  SELECT *
    FROM bsad
    INTO TABLE i_bsad_extra
    FOR ALL ENTRIES IN i_data_alv
    WHERE bukrs = s_bukrs-low
    AND   belnr = i_data_alv-factura
    AND   gjahr = i_fechas-low+0(4).

  SELECT *
    FROM bsad
    APPENDING CORRESPONDING FIELDS OF TABLE i_bsad_extra
    FOR ALL ENTRIES IN i_data_alv
    WHERE bukrs = s_bukrs-low
    AND   belnr = i_data_alv-factura
    AND   gjahr = i_fechas-low+0(4).

*** Extrae los datos de la factur financiera
*** Extrae los datos adicionales de cada documento de pago
  SELECT *
    FROM bkpf
    INTO TABLE i_bkpf_fi
    FOR ALL ENTRIES IN gt_data
    WHERE bukrs = s_bukrs-low
    AND   belnr = gt_data-doc_comp
    AND   gjahr = v_ejercicio.

*** Extrare el RFC y datos adicionales de cada cliente
  SELECT *
    FROM kna1
    INTO TABLE i_kna1
    FOR ALL ENTRIES IN i_lineitems
    WHERE kunnr = i_lineitems-customer.

*** Extrae los datos del emisor (Sociedad)
  CLEAR: v_rfc_soc, v_regimen, v_nombre_soc.

*** RFC Sociedad
  SELECT SINGLE paval                                                                                 " MODIFICAR_CLIENTE_CFDI
    FROM t001z
    INTO v_rfc_soc
    WHERE bukrs = s_bukrs-low
    AND   party = 'MX_RFC'.

*** Regimen Fiscal
  DATA: v_adrnr_reg           LIKE t001-adrnr.
  CLEAR v_adrnr_reg.

  SELECT SINGLE adrnr
    FROM t001
    INTO v_adrnr_reg
    WHERE bukrs = s_bukrs-low.

  SELECT SINGLE remark
    FROM adrct
    INTO v_regimen
    WHERE addrnumber = v_adrnr_reg.

  IF v_regimen IS INITIAL.
    v_regimen = '601'.
  ENDIF.

  SELECT SINGLE butxt adrnr
    FROM t001
    INTO (v_nombre_soc, v_adrnr_soc)
    WHERE bukrs = s_bukrs-low.

  SELECT SINGLE post_code1
    FROM adrc
    INTO v_lugar_exp
    WHERE addrnumber = v_adrnr_soc.

*** Se lee el codigo postal del lugar de expedicion de la tabla de parametros
  SELECT SINGLE parva
    FROM usr05
    INTO v_lugar_exp
    WHERE bname = sy-uname
    AND   parid = 'ZCPSUC'.

  SELECT SINGLE name1 name2
    INTO (v_name1soc, v_name2soc)
    FROM adrc
    WHERE addrnumber = v_adrnr_soc.

  CLEAR v_nombre_soc.
  CONCATENATE v_name1soc v_name2soc INTO v_nombre_soc SEPARATED BY space.
*** Extrae el lugar de expedicion

  DATA: v_monto_pago_local TYPE netwr,
        v_monto_fact_local TYPE netwr,
        v_monto_global_s   TYPE string,
        v_monto_global     TYPE netwr,
        v_pago_calculado   TYPE p DECIMALS 2.

  CLEAR:   i_data_alv_global, i_comprobante, i_pago10_pago, i_pago10_doctorelacionado,
           v_monto_pago_local, v_monto_fact_local, v_monto_global.
  REFRESH: i_data_alv_global, i_comprobante, i_pago10_pago, i_pago10_doctorelacionado.

  LOOP AT i_data_alv INTO wa_data_alv.

    v_monto_global_s = wa_data_alv-pago_doc.
    REPLACE ALL OCCURRENCES OF ',' IN v_monto_global_s WITH space.
    CONDENSE v_monto_global_s.
    ADD v_monto_global_s TO v_monto_global.

    APPEND wa_data_alv TO i_data_alv_global.

    CLEAR: i_lineitems, i_vbrk, i_bkpf.
    READ TABLE i_lineitems_comp   WITH KEY doc_no   = wa_data_alv-doc_pago.
    READ TABLE i_vbrk             WITH KEY vbeln    = wa_data_alv-factura.
    READ TABLE i_bsad_extra       WITH KEY belnr    = wa_data_alv-factura.
    READ TABLE i_bsad             WITH KEY belnr    = wa_data_alv-doc_comp.
    READ TABLE i_bkpf             WITH KEY belnr    = wa_data_alv-doc_pago.
    READ TABLE i_bkpf_fi          WITH KEY belnr    = wa_data_alv-doc_comp.

    REPLACE ALL OCCURRENCES OF ',' IN wa_data_alv-pago_doc WITH space.
    CONDENSE wa_data_alv-pago_doc.
    REPLACE ALL OCCURRENCES OF ',' IN wa_data_alv-imp_fact_doc WITH space.
    CONDENSE wa_data_alv-imp_fact_doc.
    "v_monto_pago_local = wa_data_alv-pago_local.
    "v_monto_fact_local = wa_data_alv-imp_fact_local.

*** Extrae el tipo de cambio de la fecha
    CLEAR:   i_exch_rate, i_return_exch.

    CLEAR: v_tc, v_tc_s.

    CALL FUNCTION 'READ_EXCHANGE_RATE'
      EXPORTING
        date             = i_bkpf-budat "BLDAT
        foreign_currency = 'USD'
        local_currency   = 'MXN'
        type_of_rate     = 'M'
      IMPORTING
        exchange_rate    = v_tc
      EXCEPTIONS
        no_rate_found    = 1
        no_factors_found = 2
        no_spread_found  = 3
        derived_2_times  = 4
        overflow         = 5
        zero_rate        = 6
        OTHERS           = 7.
    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF.
    v_tc_s = v_tc.

    IF NOT v_tc_s IS INITIAL.
      CONDENSE v_tc_s.
      "wa_data_alv-tc_pago = v_tc_s.
      "CONDENSE wa_data_alv-tc_pago.
    ENDIF.

*** Para cada registro del pago
************************************************************************************************************
*** ESCENARIO 1. PAGO TOTAL/FINAL con monto IGUAL al monto de la factura ***********************************
************************************************************************************************************
    IF v_monto_pago_local = v_monto_fact_local.

      i_pago10_doctorelacionado-doc_pago          = wa_data_alv-doc_pago.
      i_pago10_doctorelacionado-factura           = wa_data_alv-factura.
      "i_pago10_doctorelacionado-iddocumento       = wa_data_alv-uuid_dr.              " UUID
      i_pago10_doctorelacionado-folio              = wa_data_alv-factura.

      "*** Para este doc unicamente
      CLEAR v_zuonr_ci.
      SELECT SINGLE zuonr
       FROM bsad
       INTO v_zuonr_ci
       WHERE bukrs = s_bukrs-low
       AND   augbl = wa_data_alv-doc_pago
       AND   belnr = wa_data_alv-doc_comp
       AND   ( blart = 'DR' OR blart = 'MA' )
       AND   bschl = '01'.

      IF v_zuonr_ci IS NOT INITIAL.
        i_pago10_doctorelacionado-folio = v_zuonr_ci.
      ENDIF.


      i_pago10_doctorelacionado-monedadr = wa_data_alv-curren_dr.                     " Moneda

*************************************************
*******Se agrega código par tipo de cambio*******
*************************************************
      IF wa_data_alv-curren_dr NE wa_data_alv-currency.
        IF wa_data_alv-curren_dr = 'MXN' OR wa_data_alv-curren_dr = 'MXP'.
*          I_PAGO10_DOCTORELACIONADO-TIPOCAMBIODR = '1'.
          IF wa_data_alv-currency NE 'MXN'.

            CLEAR v_tipocambio.
            v_tipocambio = i_bkpf-kursf * -1.
            v_tipocambio = abs( v_tipocambio ).
            v_tipocambios = v_tipocambio.
            DO 6 TIMES.
              SHIFT v_tipocambios RIGHT DELETING TRAILING str1.
            ENDDO.
            CONDENSE v_tipocambios.
            i_pago10_doctorelacionado-tipocambiodr = v_tipocambios.
          ELSE.
            i_pago10_doctorelacionado-tipocambiodr = '1'.
          ENDIF.


        ELSEIF wa_data_alv-curren_dr NE 'MXN' AND wa_data_alv-curren_dr NE 'MXP'.
          IF wa_data_alv-tc_dr IS NOT INITIAL.
            IF wa_data_alv-currency EQ 'MXN'.
              IF wa_data_alv-tc_pago NE 0.
                CLEAR v_tipocambio.
                v_tipocambio = 1 / wa_data_alv-tc_pago.
                i_pago10_doctorelacionado-tipocambiodr = v_tipocambio.
              ENDIF.
            ELSE.
              i_pago10_doctorelacionado-tipocambiodr = wa_data_alv-tc_dr.
            ENDIF.
          ELSE.
            IF wa_data_alv-currency EQ 'MXN'.
              IF i_bkpf_fi-kursf NE 0.
                CLEAR v_tipocambio.
                v_tipocambio = 1 / wa_data_alv-tc_pago.
                i_pago10_doctorelacionado-tipocambiodr = v_tipocambio.
              ENDIF.
            ELSE.
              i_pago10_doctorelacionado-tipocambiodr = i_bkpf_fi-kursf.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
      CONDENSE i_pago10_doctorelacionado-tipocambiodr.

      i_pago10_doctorelacionado-metododepagodr    = 'PPD'.                            " Metodo de pago
      IF v_zuonr_ci IS INITIAL.
        i_pago10_doctorelacionado-numparcialidad    = '1'.                              " Parcialidad
      ELSE.
        CLEAR v_parc_ci.
        SELECT COUNT(*)
          FROM bsad_view
          WHERE bukrs = @s_bukrs-low
          AND   augbl = @wa_data_alv-doc_pago
          AND   zuonr = @v_zuonr_ci
          AND sgtxt IS INITIAL
        INTO @v_parc_ci.
        ADD 1 TO v_parc_ci.
        i_pago10_doctorelacionado-numparcialidad    = v_parc_ci.

      ENDIF.
      i_pago10_doctorelacionado-impsaldoant       = wa_data_alv-imp_fact_doc.         " Importe saldo anterior
      i_pago10_doctorelacionado-imppagado         = wa_data_alv-imp_fact_doc.         " Importe pago
      i_pago10_doctorelacionado-impsaldoinsoluto  = '0.0'.                            " Importe saldo insoluto

      IF wa_data_alv-ind_pc = 'X'.
        i_pago10_doctorelacionado-parc_o_total = 'T'.
      ELSEIF wa_data_alv-ind_pp = 'X'.
        i_pago10_doctorelacionado-parc_o_total = 'P'.
      ENDIF.

      APPEND i_pago10_doctorelacionado.
      CLEAR  i_pago10_doctorelacionado.
************************************************************************************************************
*** ESCENARIO 2. PAGO PARCIAL pero FINAL *******************************************************************
*** El importe del pago no coincide con el de la factura pero al ser pago total es el ultimo             ***
************************************************************************************************************
    ELSEIF v_monto_pago_local NE  v_monto_fact_local AND wa_data_alv-ind_pc = 'X'.

      i_pago10_doctorelacionado-doc_pago          = wa_data_alv-doc_pago.
      i_pago10_doctorelacionado-factura           = wa_data_alv-factura.
*      i_pago10_doctorelacionado-iddocumento       = wa_data_alv-uuid_dr.              " UUID
**        I_PAGO10_DOCTORELACIONADO-SERIE              = ''.                           " Opcional
      i_pago10_doctorelacionado-folio              = wa_data_alv-factura.

      "*** Para este doc unicamente
      CLEAR v_zuonr_ci.
      SELECT SINGLE zuonr
       FROM bsad
       INTO v_zuonr_ci
       WHERE bukrs = s_bukrs-low
       AND   augbl = wa_data_alv-doc_pago
       AND   belnr = wa_data_alv-doc_comp
       AND   ( blart = 'DR' OR blart = 'MA' )
       AND   bschl = '01'.

      IF v_zuonr_ci IS NOT INITIAL.
        i_pago10_doctorelacionado-folio = v_zuonr_ci.
      ENDIF.

      i_pago10_doctorelacionado-monedadr          = wa_data_alv-curren_dr.            " Moneda

**************BEGIN XAMAI PZV 29 AGOSTO 2020 ****************************
*** Se agrega código par tipo de cambio   *******************************
*************************************************************************
      IF wa_data_alv-curren_dr NE wa_data_alv-currency.
        IF wa_data_alv-curren_dr = 'MXN' OR wa_data_alv-curren_dr = 'MXP'.
          i_pago10_doctorelacionado-tipocambiodr = '1'.
        ELSEIF wa_data_alv-curren_dr NE 'MXN' AND wa_data_alv-curren_dr NE 'MXP'.
          IF wa_data_alv-tc_dr IS NOT INITIAL.
            IF wa_data_alv-currency EQ 'MXN'.
              IF wa_data_alv-tc_dr NE 0.
                CLEAR v_tipocambio.
                v_tipocambio = 1 / wa_data_alv-tc_pago.
                i_pago10_doctorelacionado-tipocambiodr = v_tipocambio.
              ENDIF.
            ELSE.
              i_pago10_doctorelacionado-tipocambiodr = wa_data_alv-tc_dr.
            ENDIF.
          ELSE.
            IF wa_data_alv-currency EQ 'MXN'.
              IF i_bkpf_fi-kursf NE 0.
                CLEAR v_tipocambio.
*                V_TIPOCAMBIO = 1 / I_BKPF_FI-KURSF.
                v_tipocambio = 1 / wa_data_alv-tc_pago.
                i_pago10_doctorelacionado-tipocambiodr =  v_tipocambio.
              ENDIF.
            ELSE.
              i_pago10_doctorelacionado-tipocambiodr = i_bkpf_fi-kursf.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
********************** END XAMAI PZV 29 AGOSTO 2020 *************************
      CONDENSE i_pago10_doctorelacionado-tipocambiodr.

      i_pago10_doctorelacionado-metododepagodr    = 'PPD'.                            " Metodo de pago

      CLEAR: v_num_parcialidad, v_num_parcialidad_s, v_imp_sald_ant,
             v_imp_pagado_doc, v_imp_pagado_local, v_imp_sald_ins.

*** Valida si tiene pagos anteriores y cuantos
      IF gt_data-factura = gt_data-doc_comp
         AND gt_data-doc_comp+2(1) NE '9'.

        IF v_num_parcialidad IS INITIAL.
          DO 2 TIMES.
            WAIT UP TO 1 SECONDS.
            CLEAR v_num_parcialidad.
            SELECT COUNT(*)
              FROM bsad
              INTO v_num_parcialidad
                WHERE bukrs = s_bukrs-low
                AND   kunnr = gt_data-kunnr
                AND   augbl = gt_data-doc_pago
                AND   belnr NE gt_data-doc_pago
                AND   ( bschl = '11' OR bschl = '15' )
                AND   blart = 'DZ'.
          ENDDO.
        ENDIF.
        ADD 1 TO v_num_parcialidad.

*** Calcula el saldo anterior
        DATA: i_bsad_ant_fisc       TYPE bsad OCCURS 0 WITH HEADER LINE,
              v_saldo_anterior_fisc LIKE bsad-dmbtr.

        CLEAR: v_saldo_anterior_fisc, i_bsad_ant_fisc.
        REFRESH i_bsad_ant_fisc.

        SELECT SINGLE dmbtr
          FROM bsad
          INTO v_saldo_anterior_fisc
          WHERE bukrs = s_bukrs-low
          AND   kunnr = gt_data-kunnr
          AND   augbl = gt_data-doc_pago
          AND   belnr = gt_data-doc_comp
          AND   bschl = '01'
          AND   blart = 'DR'.
*

        SELECT *
          FROM bsad
          INTO TABLE i_bsad_ant_fisc
          WHERE bukrs = s_bukrs-low
          AND   kunnr = gt_data-kunnr
          AND   augbl = gt_data-doc_pago
          AND   belnr NE gt_data-doc_pago
                AND   ( bschl = '11' OR bschl = '15' )
                AND   blart = 'DZ'.

        LOOP AT i_bsad_ant_fisc.
          IF i_bsad_ant_fisc-blart = 'DR'.
            v_saldo_anterior_fisc = v_saldo_anterior_fisc + i_bsad_ant_fisc-dmbtr.
          ELSEIF i_bsad_ant_fisc-blart = 'DG' OR i_bsad_ant_fisc-blart = 'DZ'.
            v_saldo_anterior_fisc = v_saldo_anterior_fisc - i_bsad_ant_fisc-dmbtr.
          ENDIF.
        ENDLOOP.

      ELSE.
        SELECT *
          FROM bsid
          INTO TABLE i_bsid_bsad_parc
            WHERE bukrs = s_bukrs-low
            AND   rebzg = wa_data_alv-doc_comp
          AND kunnr = wa_data_alv-kunnr.        " REVISAR

        IF i_bsid_bsad_parc[] IS INITIAL.
          SELECT *
            FROM bsad
            INTO TABLE i_bsid_bsad_parc
              WHERE bukrs = s_bukrs-low
              AND   rebzg = wa_data_alv-doc_comp
            AND kunnr = wa_data_alv-kunnr.
        ENDIF.

        CLEAR i_bkpf_anuladas.
        REFRESH: i_bkpf_anuladas.

        SELECT *
          FROM bkpf
          INTO TABLE i_bkpf_anuladas
          FOR ALL ENTRIES IN i_bsid_bsad_parc
          WHERE bukrs = i_bsid_bsad_parc-bukrs
          AND   belnr = i_bsid_bsad_parc-belnr
          AND   gjahr = i_bsid_bsad_parc-gjahr
          AND   xreversal = '1'.

        IF i_bkpf_anuladas[] IS NOT INITIAL.
          LOOP AT i_bsid_bsad_parc.
            READ TABLE i_bkpf_anuladas WITH KEY belnr = i_bsid_bsad_parc-belnr.
            IF sy-subrc EQ 0.
              DELETE i_bsid_bsad_parc.
            ENDIF.
          ENDLOOP.
        ENDIF.

        DESCRIBE TABLE i_bsid_bsad_parc LINES v_num_parcialidad.

**** Agrega un pago
        ADD 1 TO v_num_parcialidad.

      ENDIF.

      v_num_parcialidad_s = v_num_parcialidad.
      CONDENSE v_num_parcialidad_s.

      IF v_zuonr_ci IS NOT INITIAL.
        CLEAR v_parc_ci.
        SELECT COUNT(*)
          FROM bsad_view
          WHERE bukrs = @s_bukrs-low
          AND   augbl = @wa_data_alv-doc_pago
          AND   zuonr = @v_zuonr_ci
          AND sgtxt IS INITIAL
        INTO @v_parc_ci.
        v_num_parcialidad_s = v_parc_ci + 1.

      ENDIF.

      i_pago10_doctorelacionado-numparcialidad    = v_num_parcialidad_s.                    " Parcialidad

      IF wa_data_alv-curren_dr = 'MXN'.
*        i_pago10_doctorelacionado-impsaldoant       = wa_data_alv-pago_local.               " Importe saldo anterior
*        i_pago10_doctorelacionado-imppagado         = wa_data_alv-pago_local.               " Importe pagado
      ELSEIF wa_data_alv-curren_dr NE 'MXN' AND
             ( wa_data_alv-curren_dr NE wa_data_alv-currency ).
*** No se tiene el pago en la segunda moneda porque no hay conversion, se tiene que calcular
        CLEAR: v_pago_calculado.
        v_pago_calculado = wa_data_alv-pago_doc / i_pago10_doctorelacionado-tipocambiodr.
        i_pago10_doctorelacionado-impsaldoant       = v_pago_calculado.                     " Importe saldo anterior
        i_pago10_doctorelacionado-imppagado         = v_pago_calculado.                     " Importe pagado
      ELSE.
        i_pago10_doctorelacionado-impsaldoant       = wa_data_alv-pago_doc.                 " Importe saldo anterior
        i_pago10_doctorelacionado-imppagado         = wa_data_alv-pago_doc.                 " Importe pagado
      ENDIF.
      i_pago10_doctorelacionado-impsaldoinsoluto  = '0.0'.                                  " Importe saldo insoluto

      IF wa_data_alv-ind_pc = 'X'.
        i_pago10_doctorelacionado-parc_o_total = 'T'.
      ELSEIF wa_data_alv-ind_pp = 'X'.
        i_pago10_doctorelacionado-parc_o_total = 'P'.
      ENDIF.

      APPEND i_pago10_doctorelacionado.
      CLEAR  i_pago10_doctorelacionado.

************************************************************************************************************
*** ESCENARIO 3. PAGO PARCIAL ******************************************************************************
*** El importe del pago no coincide con el de la factura y es pago parcial                               ***
************************************************************************************************************
    ELSEIF v_monto_pago_local NE  v_monto_fact_local AND wa_data_alv-ind_pp = 'X'.

      i_pago10_doctorelacionado-doc_pago          = wa_data_alv-doc_pago.
      i_pago10_doctorelacionado-factura           = wa_data_alv-factura.
*      i_pago10_doctorelacionado-iddocumento       = wa_data_alv-uuid_dr.              " UUID
*        I_PAGO10_DOCTORELACIONADO-SERIE              = ''.                            " Opcional
      i_pago10_doctorelacionado-folio              = wa_data_alv-factura.

      "*** Para este doc unicamente
      CLEAR v_zuonr_ci.
      SELECT SINGLE zuonr
       FROM bsad
       INTO v_zuonr_ci
       WHERE bukrs = s_bukrs-low
       AND   augbl = wa_data_alv-doc_pago
       AND   belnr = wa_data_alv-doc_comp
       AND   ( blart = 'DR' OR blart = 'MA' )
       AND   bschl = '01'.

      IF v_zuonr_ci IS NOT INITIAL.
        i_pago10_doctorelacionado-folio = v_zuonr_ci.
      ENDIF.

      i_pago10_doctorelacionado-monedadr          = wa_data_alv-curren_dr.            " Moneda

*************************************************************************
      IF wa_data_alv-curren_dr NE wa_data_alv-currency.
        IF wa_data_alv-curren_dr = 'MXN' OR wa_data_alv-curren_dr = 'MXP'.
          IF wa_data_alv-currency NE 'MXN'.
            i_pago10_doctorelacionado-tipocambiodr = wa_data_alv-tc_pago.
          ELSE.
            i_pago10_doctorelacionado-tipocambiodr = '1'.
          ENDIF.
        ELSEIF wa_data_alv-curren_dr NE 'MXN' AND wa_data_alv-curren_dr NE 'MXP'.
          IF wa_data_alv-tc_dr IS NOT INITIAL.
            IF wa_data_alv-currency EQ 'MXN'.
              IF wa_data_alv-tc_dr NE 0.
                CLEAR v_tipocambio.
                v_tipocambio = 1 / wa_data_alv-tc_pago.
                i_pago10_doctorelacionado-tipocambiodr = v_tipocambio.
              ENDIF.
            ELSE.
              i_pago10_doctorelacionado-tipocambiodr = wa_data_alv-tc_dr.
            ENDIF.
          ELSE.
            IF wa_data_alv-currency EQ 'MXN'.
              IF i_bkpf_fi-kursf NE 0.
                CLEAR v_tipocambio.
*                V_TIPOCAMBIO = 1 / I_BKPF_FI-KURSF.
                v_tipocambio = 1 / wa_data_alv-tc_pago.
                i_pago10_doctorelacionado-tipocambiodr = v_tipocambio.
              ENDIF.
            ELSE.
              i_pago10_doctorelacionado-tipocambiodr = i_bkpf_fi-kursf.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.

      CONDENSE i_pago10_doctorelacionado-tipocambiodr.

      i_pago10_doctorelacionado-metododepagodr    = 'PPD'.                            " Metodo de pago

      CLEAR:    v_num_parcialidad, v_num_parcialidad_s, v_imp_sald_ant,
                v_imp_pagado_doc, v_imp_pagado_local, v_imp_sald_ins,i_bsid_bsad_parc.
      REFRESH:  i_bsid_bsad_parc.

      SELECT *
        FROM bsid
        INTO TABLE i_bsid_bsad_parc
          WHERE bukrs = s_bukrs-low
          AND   rebzg = wa_data_alv-doc_comp
        AND kunnr = wa_data_alv-kunnr.

      IF i_bsid_bsad_parc[] IS INITIAL.
        SELECT *
          FROM bsad
          INTO TABLE i_bsid_bsad_parc
            WHERE bukrs = s_bukrs-low
            AND   rebzg = wa_data_alv-doc_comp
          AND kunnr = wa_data_alv-kunnr.
      ENDIF.

      CLEAR i_bkpf_anuladas.
      REFRESH: i_bkpf_anuladas.

      SELECT *
        FROM bkpf
        INTO TABLE i_bkpf_anuladas
        FOR ALL ENTRIES IN i_bsid_bsad_parc
        WHERE bukrs = i_bsid_bsad_parc-bukrs
        AND   belnr = i_bsid_bsad_parc-belnr
        AND   gjahr = i_fechas-low+0(4)
        AND   xreversal = '1'.

      IF i_bkpf_anuladas[] IS NOT INITIAL.
        LOOP AT i_bsid_bsad_parc.
          READ TABLE i_bkpf_anuladas WITH KEY belnr = i_bsid_bsad_parc-belnr.
          IF sy-subrc EQ 0.
            DELETE i_bsid_bsad_parc.
          ENDIF.
        ENDLOOP.
      ENDIF.

      SORT i_bsid_bsad_parc BY belnr.
      LOOP AT i_bsid_bsad_parc.
        IF i_bsid_bsad_parc-belnr = wa_data_alv-doc_pago.
          v_num_parcialidad = sy-tabix.
          EXIT.
        ENDIF.
        IF i_bsid_bsad_parc-qsskz = 'XX'.
          DATA: v_dmbtr_iva TYPE dmbtr,
                v_wrbtr_iva TYPE wrbtr.
          CLEAR: v_dmbtr_iva, v_wrbtr_iva.

          SELECT SINGLE dmbtr wrbtr
            INTO (v_dmbtr_iva, v_wrbtr_iva)
            FROM bseg
            WHERE bukrs = i_bsid_bsad_parc-bukrs
            AND   belnr = i_bsid_bsad_parc-belnr
            AND   gjahr = i_fechas-low+0(4)
            AND qsskz = 'ZV'.

          v_imp_pagado_local = v_imp_pagado_local + i_bsid_bsad_parc-dmbtr - v_dmbtr_iva.
          v_imp_pagado_doc   = v_imp_pagado_doc   + i_bsid_bsad_parc-wrbtr - v_wrbtr_iva.
        ELSE.

*** Se agrega logica para cuando es un pago final mezclado
          DATA: v_tipocambio_previo LIKE bkpf-kurs3.
          CLEAR v_tipocambio_previo.
          SELECT SINGLE kurs3
            FROM bkpf
            INTO v_tipocambio_previo
            WHERE bukrs = i_bsid_bsad_parc-bukrs
            AND   belnr = i_bsid_bsad_parc-belnr
            AND   gjahr = i_bsid_bsad_parc-gjahr.

          IF v_tipocambio_previo IS INITIAL OR
             v_tipocambio_previo = 0.

*** Extrae el tipo de cambio de la fecha
            CLEAR:   i_exch_rate, i_return_exch.

            CLEAR: v_tc, v_tc_s.

            CALL FUNCTION 'READ_EXCHANGE_RATE'
              EXPORTING
                date             = i_bsid_bsad_parc-budat
                foreign_currency = 'USD'
                local_currency   = 'MXN'
                type_of_rate     = 'M'
              IMPORTING
                exchange_rate    = v_tc
              EXCEPTIONS
                no_rate_found    = 1
                no_factors_found = 2
                no_spread_found  = 3
                derived_2_times  = 4
                overflow         = 5
                zero_rate        = 6
                OTHERS           = 7.
            IF sy-subrc <> 0.
* Implement suitable error handling here
            ENDIF.
            v_tc_s = v_tc.

            IF NOT v_tc_s IS INITIAL.
              v_tipocambio_previo = v_tc_s.
            ENDIF.

          ENDIF.


          DATA: v_flag_calculo TYPE c.
          CLEAR v_flag_calculo.

          IF
*            I_BKPF-WAERS = 'MXN'            AND
             wa_data_alv-curren_dr  NE 'MXN' AND
             i_bsid_bsad_parc-waers NE 'MXN'.
            v_imp_pagado_doc = v_imp_pagado_doc +
                               i_bsid_bsad_parc-wrbtr * abs( v_tipocambio_previo ).
            v_imp_pagado_local = v_imp_pagado_local +
                                 i_bsid_bsad_parc-wrbtr.
            v_flag_calculo = 1.
          ELSEIF wa_data_alv-curren_dr  NE 'MXN' AND
                 i_bsid_bsad_parc-waers EQ 'MXN'.
            v_imp_pagado_doc = v_imp_pagado_doc +
                               i_bsid_bsad_parc-wrbtr / abs( v_tipocambio_previo ).
            v_imp_pagado_local = v_imp_pagado_local +
                                 i_bsid_bsad_parc-wrbtr.
            v_flag_calculo = 2.
          ELSE.
            ADD i_bsid_bsad_parc-dmbtr TO v_imp_pagado_local.
            ADD i_bsid_bsad_parc-wrbtr TO v_imp_pagado_doc.
            v_flag_calculo = 2.
          ENDIF.
        ENDIF.
      ENDLOOP.
********************** END XAMAI PZV 29 AGOSTO 2020 *************************
      IF i_bsid_bsad_parc[] IS INITIAL.
        v_num_parcialidad = 1.
      ENDIF.


      v_num_parcialidad_s = v_num_parcialidad.
      CONDENSE v_num_parcialidad_s.
      i_pago10_doctorelacionado-numparcialidad    = v_num_parcialidad_s.

      IF wa_data_alv-curren_dr = 'MXN'.
*        i_pago10_doctorelacionado-impsaldoant       = wa_data_alv-imp_fact_local - v_imp_pagado_local.        " Importe saldo anterior
*        i_pago10_doctorelacionado-imppagado         = wa_data_alv-pago_local.                                 " Importe pagado
      ELSEIF wa_data_alv-curren_dr NE 'MXN' AND
             ( wa_data_alv-curren_dr NE wa_data_alv-currency ).
*** No se tiene el pago en la segunda moneda porque no hay conversion, se tiene que calcular
        CLEAR: v_pago_calculado.
        v_pago_calculado = wa_data_alv-pago_doc / wa_data_alv-tc_pago. "I_PAGO10_DOCTORELACIONADO-TIPOCAMBIODR.
        IF v_flag_calculo = 1.
          i_pago10_doctorelacionado-impsaldoant  = wa_data_alv-imp_fact_doc -
                                                   v_imp_pagado_local.            " Importe saldo anterior
        ELSE.
          i_pago10_doctorelacionado-impsaldoant  = wa_data_alv-imp_fact_doc -
                                                   v_imp_pagado_doc.            " Importe saldo anterior
        ENDIF.

        i_pago10_doctorelacionado-imppagado         = v_pago_calculado.                                       " Importe pagado
      ELSE.
        IF wa_data_alv-curren_dr = 'USD'.
          i_pago10_doctorelacionado-impsaldoant       = wa_data_alv-imp_fact_doc -
                                                        v_imp_pagado_local.            " Importe saldo anterior
          i_pago10_doctorelacionado-imppagado         = wa_data_alv-pago_doc.
        ELSE.
          i_pago10_doctorelacionado-impsaldoant       = wa_data_alv-imp_fact_doc - v_imp_pagado_doc.            " Importe saldo anterior
          i_pago10_doctorelacionado-imppagado         = wa_data_alv-pago_doc.                                   " Importe pagado
        ENDIF.
      ENDIF.

*** El saldo insoluto es la resta
      i_pago10_doctorelacionado-impsaldoinsoluto  = i_pago10_doctorelacionado-impsaldoant -
                                                    i_pago10_doctorelacionado-imppagado.                      " Importe saldo insoluto

      IF wa_data_alv-ind_pc = 'X'.
        i_pago10_doctorelacionado-parc_o_total = 'T'.
      ELSEIF wa_data_alv-ind_pp = 'X'.
        i_pago10_doctorelacionado-parc_o_total = 'P'.
      ENDIF.

      APPEND i_pago10_doctorelacionado.
      CLEAR  i_pago10_doctorelacionado.

    ENDIF.


*** Al finalizar los registros
*** llena la cabecera
    AT END OF llave.

      READ TABLE i_data_alv_global INDEX 1.
      READ TABLE i_lineitems WITH KEY doc_no = i_data_alv_global-doc_pago.
      READ TABLE i_bkpf WITH KEY belnr = i_data_alv_global-doc_pago.

*** Llena tabla para nodo cfdi:Comprobante **********************************************************************

*** Documento de pago
      i_comprobante-doc_pago            = i_data_alv_global-llave.

*** Version
      i_comprobante-version             = '3.3'.

*** Serie
      CONCATENATE s_bukrs-low i_data_alv_global-llave i_lineitems-fisc_year
      INTO i_comprobante-serie.

*** Folio
      i_comprobante-folio = i_comprobante-serie.

*** Fecha de emision del CFDI
      CONCATENATE sy-datum+0(4) sy-datum+4(2) sy-datum+6(2)
        INTO i_comprobante-fecha SEPARATED BY '-'.
      CONCATENATE  i_comprobante-fecha  'T' sy-timlo+0(2) ':' sy-timlo+2(2) ':' sy-timlo+4(2)
        INTO i_comprobante-fecha.

*** El sello no se llena porque se calcula en el sellado
*** o el PAC lo crea
      i_comprobante-certificado         = v_cont_cert.                              " Contenido del certificado   " MODIFICAR_CLIENTE_CFDI
      i_comprobante-subtotal            = '0'.                                      " Subtotal
      i_comprobante-moneda              = 'XXX'.                                    " Moneda
      i_comprobante-total               = '0'.                                      " Total
      i_comprobante-tipodecomprobante   = 'P'.                                      " Tipo de comprobante
      i_comprobante-lugarexpedicion     = v_lugar_exp.                              " Lugar de expedicion


*** Confirmacion
*** En caso de que se requiera este campo, se debe definir con el usuario donde lo va a almacenar PREVIO a la
*** emision del comprobant
*I_COMPROBANTE-CONFIRMACION  = ''.                                                                " MODIFICAR_CLIENTE_CFDI

*** Datos Emisor
      i_comprobante-rfc_emisor                = v_rfc_soc.
      i_comprobante-nombre_emisor             = v_nombre_soc.
      i_comprobante-regimenfiscal_emisor      = v_regimen.

*** Datos Receptor
      READ TABLE i_kna1 WITH KEY kunnr = i_data_alv_global-kunnr.
      IF i_kna1-stcd1 IS NOT INITIAL.
        i_comprobante-rfc_receptor                = i_kna1-stcd1.
      ELSE.
        i_comprobante-rfc_receptor                = i_kna1-stcd3.
      ENDIF.
      i_comprobante-kunnr                       = i_data_alv_global-kunnr.
      IF i_kna1-stkzn = 'X'.
        DATA: i_but000 TYPE but000 OCCURS 0 WITH HEADER LINE.
        CLEAR i_but000.  REFRESH i_but000.

        SELECT *
          FROM but000
          INTO TABLE i_but000
          WHERE partner = i_kna1-kunnr.

        READ TABLE i_but000 INDEX 1.

        CONCATENATE i_but000-name_first
                    i_but000-namemiddle
                    i_but000-name_last
          INTO i_comprobante-nombre_receptor SEPARATED BY space.

*** Persona moral
      ELSE.
        CONCATENATE i_kna1-name1 i_kna1-name2 INTO i_comprobante-nombre_receptor SEPARATED BY space.
      ENDIF.

*** Estos datos son unicamente si el receptor de la factura reside en el extranjero
      i_comprobante-usocfdi                     = 'P01'.

*** Datos "Producto"
      i_comprobante-claveprodserv               = '84111506'.
      i_comprobante-cantidad                    = '1'.
      i_comprobante-claveunidad                 = 'ACT' .
      i_comprobante-descripcion                 = 'Pago'.
      i_comprobante-valorunitario               = '0'.
      i_comprobante-importe                     = '0'.

      APPEND i_comprobante.
      CLEAR  i_comprobante.

*** Nodo COMPLEMENTO DE PAGO **********************************************************************************

      " Documento de pago para referencia en el llenado del xml
      i_pago10_pago-doc_pago                  = i_data_alv_global-doc_pago.

*** Fecha del pago
      CONCATENATE i_bkpf-bldat+0(4) i_bkpf-bldat+4(2) i_bkpf-bldat+6(2)
        INTO i_pago10_pago-fechapago SEPARATED BY '-'.
      CONCATENATE i_pago10_pago-fechapago 'T' sy-timlo+0(2) ':' sy-timlo+2(2) ':' sy-timlo+4(2)
        INTO i_pago10_pago-fechapago.

      CONCATENATE i_bkpf-budat+0(4) i_bkpf-budat+4(2) i_bkpf-budat+6(2)
              INTO v_fecha_pago_12 SEPARATED BY '-'.
      CONCATENATE v_fecha_pago_12 'T12:00:00' INTO v_fecha_pago_12.


      CONCATENATE sy-datum+0(4) sy-datum+4(2) sy-datum+6(2)
                    INTO v_fecha_creacion SEPARATED BY '-'.
      CONCATENATE v_fecha_creacion 'T' sy-timlo+0(2) ':' sy-timlo+2(2) ':' sy-timlo+4(2)
      INTO v_fecha_creacion.

*** Forma de pago
      "ITEM_TEXT <--->  ALLOC_NMBR
      CLEAR: v_pago_sust,v_parc_sust.
      SELECT SINGLE zzfpago
        FROM bseg
        INTO i_pago10_pago-formadepagop
        WHERE bukrs = i_lineitems_comp-comp_code
        AND   belnr = i_lineitems_comp-doc_no
        AND   gjahr = i_lineitems_comp-fisc_year
        AND   zzfpago NE space.
      IF i_pago10_pago-formadepagop IS INITIAL.
        SELECT SINGLE xref3
          FROM bseg
          INTO i_pago10_pago-formadepagop
          WHERE bukrs = i_lineitems_comp-comp_code
          AND   belnr = i_lineitems_comp-doc_no
          AND   gjahr = i_lineitems_comp-fisc_year
          AND xref3 NE space.
      ENDIF.
      IF i_lineitems_comp-post_key = '17'.

      ENDIF.

*** Moneda de pago
      i_pago10_pago-monedap                     = i_lineitems-currency.
********XAMAI PZV 29 08 2020 TIPO DE CAMBIO ***************************************
      IF i_pago10_pago-monedap NE 'MXP' AND i_pago10_pago-monedap NE 'MXN'.
        i_pago10_pago-tipocambiop  = i_data_alv_global-tc_pago.
        CONDENSE i_pago10_pago-tipocambiop.
      ENDIF.

      i_pago10_pago-monto = v_monto_global.

      i_pago10_pago-numoperacion = i_bkpf-bktxt.

*** Todos estos campos son opcionales
      DATA: i_knbk TYPE knbk OCCURS 0 WITH HEADER LINE.
      CLEAR i_knbk.
      REFRESH i_knbk.

      SELECT SINGLE *
        FROM knbk
        INTO i_knbk
        WHERE kunnr = i_data_alv_global-kunnr.

      READ TABLE i_knbk INDEX 1.
*** RFC emisor cuenta ordenante
      i_pago10_pago-rfcemisorctaord = i_knbk-bkref.

*** Nombre banco ordenante
      SELECT SINGLE banka
        FROM bnka
        INTO i_pago10_pago-nombancoordext
        WHERE bankl = i_knbk-bankl.

*** Cuenta ordenante
      i_pago10_pago-ctaordenante = i_knbk-bankn.

*** RFC emisor cuenta beneficiario
      DATA: v_hkont_pago TYPE hkont,
            v_hbkid_pago TYPE hbkid.


      SELECT SINGLE hkont
        FROM bseg
        INTO v_hkont_pago
        WHERE belnr = i_lineitems-doc_no
        AND   buzei = '01'.

      SELECT SINGLE hbkid
        FROM skb1
        INTO v_hbkid_pago
        WHERE saknr = v_hkont_pago.

      SELECT SINGLE stcd1
        FROM t012
        INTO i_pago10_pago-rfcemisorctaben
        WHERE hbkid = v_hbkid_pago.

      SELECT SINGLE bankn
      FROM t012k
      INTO i_pago10_pago-ctabeneficiario
      WHERE hbkid = v_hbkid_pago.


*** Estos cuatro campos dependen de los opcionales de arriba
*I_PAGO10_PAGO-TIPOCADPAGO
*I_PAGO10_PAGO-CERTPAGO
*I_PAGO10_PAGO-CADPAGO
*I_PAGO10_PAGO-SELLOPAGO

      APPEND i_pago10_pago.
      CLEAR  i_pago10_pago.

*** Manda llamar el perform que envia la info de acuerdo a cada usuario
      PERFORM f_genera_xml.

*** Llena la tabla con los datos antes del timbrado
*** (solo para este registro)
      PERFORM f_llena_tabla_pagos.

*** Timbra el documento
      PERFORM f_proxy_timbrado.
      WAIT UP TO 1 SECONDS.

      CLEAR:   i_data_alv_global, i_comprobante, i_pago10_pago, i_pago10_doctorelacionado,
         v_monto_pago_local, v_monto_fact_local, v_monto_global_s, v_monto_global.
      REFRESH: i_data_alv_global, i_comprobante, i_pago10_pago, i_pago10_doctorelacionado.

    ENDAT.
  ENDLOOP.

  DELETE ADJACENT DUPLICATES FROM i_log.
  PERFORM f_ventana_log.

  PERFORM f_update_tabla.

  PERFORM f_refresh.


ENDFORM.                    " F_LLENA_TABLAS_COMP

*&---------------------------------------------------------------------*
*&      Form  F_LLENA_TABLA_PAGOS
*&---------------------------------------------------------------------*
FORM f_llena_tabla_pagos .


  CLEAR:   i_zalv_comp_pago.
  REFRESH: i_zalv_comp_pago.

  DATA: i_data_alv_global_comp  TYPE s_data_alv OCCURS 0 WITH HEADER LINE.
  CLEAR: i_data_alv_global_comp.
  REFRESH: i_data_alv_global_comp.

  i_data_alv_global_comp[] = i_data_alv[].

  LOOP AT i_data_alv_global_comp WHERE bukrs    = i_data_alv_global-bukrs
                                   AND kunnr    = i_data_alv_global-kunnr
                                   AND doc_pago = i_data_alv_global-doc_pago.

    MOVE-CORRESPONDING i_data_alv_global_comp TO i_zalv_comp_pago.
    i_zalv_comp_pago-semaforo    = 'P'.
    i_zalv_comp_pago-comentario  = 'Enviada al PAC'.

*** Importe del pago
    CLEAR v_importes_formato.
    v_importes_formato = i_data_alv_global_comp-pago_doc.
    REPLACE ALL OCCURRENCES OF ',' IN v_importes_formato WITH space.
    i_zalv_comp_pago-dmbtr       =  v_importes_formato.

    CONCATENATE i_data_alv_global_comp-budat+6(4) i_data_alv_global_comp-budat+3(2) i_data_alv_global_comp-budat+0(2)
      INTO i_zalv_comp_pago-budat.

*** Importe de la factura
    CLEAR v_importes_formato.
    v_importes_formato = i_data_alv_global_comp-imp_fact_doc.
    REPLACE ALL OCCURRENCES OF ',' IN v_importes_formato WITH space.
    i_zalv_comp_pago-netwr       =  v_importes_formato.

    CONCATENATE i_data_alv_global_comp-fkdat+6(4) i_data_alv_global_comp-fkdat+3(2) i_data_alv_global_comp-fkdat+0(2)
      INTO i_zalv_comp_pago-fkdat.
    i_zalv_comp_pago-gjahr = i_data_alv_global_comp-budat+6(4).

    READ TABLE i_pago10_pago WITH KEY doc_pago  = i_data_alv_global_comp-doc_pago.
    MOVE-CORRESPONDING i_pago10_pago TO i_zalv_comp_pago.

    READ TABLE i_pago10_doctorelacionado WITH KEY doc_pago = i_data_alv_global_comp-doc_pago
                                                  factura  = i_data_alv_global_comp-factura.
    MOVE-CORRESPONDING i_pago10_doctorelacionado TO i_zalv_comp_pago.
    CONDENSE i_zalv_comp_pago-imppagado.
    APPEND i_zalv_comp_pago.

  ENDLOOP.

  LOOP AT i_zalv_comp_pago.
    MODIFY zalv_comp_pago FROM TABLE i_zalv_comp_pago.
    COMMIT WORK AND WAIT.
  ENDLOOP.

ENDFORM.                    " F_LLENA_TABLA_PAGOS

*&---------------------------------------------------------------------*
*&      Form  SHOW_DOCUMENT
*&---------------------------------------------------------------------*
FORM show_document  USING p_row TYPE salv_de_row
                          p_column TYPE salv_de_column .

  DATA: lv_url          TYPE          c LENGTH 255,
        lv_type         TYPE          c LENGTH 20,
        lv_subtype      TYPE          c LENGTH 20,
        lcl_html_viewer TYPE REF TO   cl_gui_html_viewer,
        lt_binary_tab   TYPE TABLE OF sdokcntbin,
        lv_length       TYPE          i,
        lv_xstring      TYPE          xstring,
        lv_error        TYPE          boolean,
        lv_file         TYPE string.

  TYPES: lty_x_line(256) TYPE                   x,
         lty_x_tab       TYPE STANDARD TABLE OF lty_x_line.

  DATA: lt_xtab TYPE        lty_x_tab.

  FIELD-SYMBOLS: <ls_data>     LIKE LINE OF gt_data,
                 <ls_data_alv> LIKE LINE OF gt_data_alv.



*** Ve el renglon seleccionado
*** Elimina renglones duplicados
  SORT gt_data BY doc_pago factura doc_comp.
  DELETE ADJACENT DUPLICATES FROM gt_data.

  READ TABLE gt_data INDEX  p_row.
  IF sy-subrc EQ 0.

*** Crea la llamada a la pantalla externa
    CALL METHOD cl_gui_cfw=>flush.

    CREATE OBJECT lcl_html_viewer
      EXPORTING
        parent   = cl_gui_container=>screen2
        lifetime = 0.

    CASE p_column.

*** Abre el PDF
      WHEN 'PDF'.

        IF gt_data-archivopdf IS NOT INITIAL.

          v_url = gt_data-archivopdf.
          IF v_url IS NOT INITIAL.

            CALL FUNCTION 'CALL_BROWSER'
              EXPORTING
                url                    = v_url
              EXCEPTIONS
                frontend_not_supported = 1
                frontend_error         = 2
                prog_not_found         = 3
                no_batch               = 4
                unspecified_error      = 5
                OTHERS                 = 6.
            IF sy-subrc <> 0.
              MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
            ENDIF.

          ENDIF.

        ELSE.

        ENDIF.

*** Abre el XML
      WHEN 'XML' .

        IF gt_data-archivoxml IS NOT INITIAL.

          v_url = gt_data-archivoxml.
          IF v_url IS NOT INITIAL.

            CALL FUNCTION 'CALL_BROWSER'
              EXPORTING
                url                    = v_url
              EXCEPTIONS
                frontend_not_supported = 1
                frontend_error         = 2
                prog_not_found         = 3
                no_batch               = 4
                unspecified_error      = 5
                OTHERS                 = 6.
            IF sy-subrc <> 0.
              MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
            ENDIF.

          ENDIF.


        ELSE.

        ENDIF.
    ENDCASE.
  ENDIF.


ENDFORM.                    " SHOW_DOCUMENT

*&---------------------------------------------------------------------*
*&      Form  F_VENTANA_LOG
*&---------------------------------------------------------------------*
FORM f_ventana_log .

  DATA: i_tsmesg TYPE tsmesg OCCURS 0,
        i_xx     TYPE LINE OF tsmesg.

  CLEAR:    i_tsmesg.
  REFRESH:  i_tsmesg.


  DATA: gt_mesg  TYPE  tsmesg.
  DATA:
    ls_mesg  TYPE  smesg.

  LOOP AT i_log.
    ls_mesg-arbgb = '00'.
    ls_mesg-txtnr = '001'.
    ls_mesg-zeile = sy-tabix.
    IF i_log-msg1+0(1) = 'D'.
      ls_mesg-msgty = 'I'.
    ELSE.
      ls_mesg-msgty = 'I'.
    ENDIF.
    ls_mesg-msgv1 = i_log-msg1.
    ls_mesg-msgv2 = i_log-msg2.
    APPEND ls_mesg TO gt_mesg.
  ENDLOOP.


  CALL FUNCTION 'FB_MESSAGES_DISPLAY_POPUP'
    EXPORTING
      it_smesg        = gt_mesg
      id_send_if_one  = abap_true
    EXCEPTIONS
      no_messages     = 1
      popup_cancelled = 2
      OTHERS          = 3.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  "PERFORM deselect_all_rows.

ENDFORM.                    " F_VENTANA_LOG
*&---------------------------------------------------------------------*
*& Form transformar_xml
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> IT_XMLSAT[]
*&      --> XML_FILE
*&---------------------------------------------------------------------*
FORM transformar_xml  TABLES   gt_xml_data STRUCTURE smum_xmltb
                      USING    ruta_xml TYPE zaxnare_el034.

  DATA: gcl_xml       TYPE REF TO cl_xml_document.
  DATA: gv_subrc      TYPE sy-subrc.
  DATA: gv_xml_string TYPE xstring.
  DATA: gv_size       TYPE sytabix.
  DATA: gwa_xml_data  TYPE smum_xmltb.
  DATA: gt_return     TYPE TABLE OF bapiret2.
  DATA: gv_tabix      TYPE sytabix.

  DATA: http_client TYPE REF TO if_http_client .
  DATA: xml_out TYPE string  .


  DATA lv_filename TYPE string.
  REFRESH gt_xml_data.
  CREATE OBJECT gcl_xml.
  lv_filename = ruta_xml.

  "se consulta por URL
  CALL METHOD cl_http_client=>create_by_url
    EXPORTING
      url    = lv_filename
    IMPORTING
      client = http_client.

  http_client->send( ).
  http_client->receive( ).
  CLEAR xml_out .
  xml_out = http_client->response->get_cdata( ).
  http_client->close( ).


  CALL FUNCTION 'SCMS_STRING_TO_XSTRING'
    EXPORTING
      text   = xml_out
    IMPORTING
      buffer = gv_xml_string
    EXCEPTIONS
      failed = 1
      OTHERS = 2.
* Convert XML to internal table
  CALL FUNCTION 'SMUM_XML_PARSE'
    EXPORTING
      xml_input = gv_xml_string
    TABLES
      xml_table = gt_xml_data
      return    = gt_return.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form exportar_xls
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM exportar_xls .
  DATA: lt_bintab   TYPE STANDARD TABLE OF solix,
        lv_size     TYPE i,
        lv_filename TYPE string,
        v_path      TYPE string,   " directorio del archivo
        v_fullpath  TYPE string.   " ruta del arhivo completa

  REFRESH data_alv.
  data_alv[] = wa_data_alv[].

  cl_gui_frontend_services=>file_save_dialog(
    EXPORTING
       window_title              = 'Guardar Documento...'
       file_filter               = '*.XLS'
       default_extension         = 'xls'
       default_file_name         = 'ZDATOS_EXCEL'
       prompt_on_overwrite       = 'X'
    CHANGING
      filename                  = lv_filename
      path                      = v_path
      fullpath                  = v_fullpath
*      user_action               =
*      file_encoding             =
    EXCEPTIONS
      cntl_error                = 1
      error_no_gui              = 2
      not_supported_by_gui      = 3
      invalid_default_file_name = 4
      OTHERS                    = 5
  ).
  IF sy-subrc <> 0.
*   MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*     WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.


* Get New Instance for ALV Table Object
*  cl_salv_table=>factory(
*    IMPORTING
*      r_salv_table   = DATA(lo_alv)
*    CHANGING
*      t_table        =  <dyn_table> ).

* Convert ALV Table Object to XML
  DATA(lv_xml) = gr_table->to_xml( xml_type = '02' ).


* Convert XTRING to Binary
  CALL FUNCTION 'SCMS_XSTRING_TO_BINARY'
    EXPORTING
      buffer        = lv_xml
    IMPORTING
      output_length = lv_size
    TABLES
      binary_tab    = lt_bintab.

  "lv_filename = p_fname.

* Download File
  CALL FUNCTION 'GUI_DOWNLOAD'
    EXPORTING
      bin_filesize            = lv_size
      filename                = lv_filename
      filetype                = 'BIN'
    TABLES
      data_tab                = lt_bintab
    EXCEPTIONS
      file_write_error        = 1
      no_batch                = 2
      gui_refuse_filetransfer = 3
      invalid_type            = 4
      no_authority            = 5
      unknown_error           = 6
      header_not_allowed      = 7
      separator_not_allowed   = 8
      filesize_not_allowed    = 9
      header_too_long         = 10
      dp_error_create         = 11
      dp_error_send           = 12
      dp_error_write          = 13
      unknown_dp_error        = 14
      access_denied           = 15
      dp_out_of_memory        = 16
      disk_full               = 17
      dp_timeout              = 18
      file_not_found          = 19
      dataprovider_exception  = 20
      control_flush_error     = 21
      OTHERS                  = 22.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form distribuir_xml
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> TABLE
*&      --> IT_XMLSAT
*&      <-- WA_DATA_ALV
*&---------------------------------------------------------------------*
FORM distribuir_xml  TABLES p_it_xmlsat STRUCTURE  smum_xmltb
                     CHANGING wa_data_alv TYPE s_data_alv.
CLEAR wa_xmlsat.
data: indice_base type i, indice_inc type i.
data: vl_valor type p DECIMALS 6,  vl_tasa type p DECIMALS 6.

READ TABLE p_it_xmlsat into wa_xmlsat WITH key cname = 'Folio' cvalue = wa_data_alv-factura.
IF sy-tabix eq 0 or wa_data_alv-factura cp '180*'.
  exit.
ENDIF.

indice_base = sy-tabix - 1.


clear wa_xmlsat.
read TABLE p_it_xmlsat into wa_xmlsat INDEX indice_base. "folio relacionado posicion 53
wa_data_alv-folfis =  wa_xmlsat-cvalue.

clear wa_xmlsat.
indice_inc = indice_base + 5. "saldo anterior
READ TABLE it_xmlsat INTO wa_xmlsat index indice_inc.
wa_data_alv-saldoant = wa_xmlsat-cvalue.

clear wa_xmlsat.
indice_inc = indice_base + 7. " ImpSaldoInsoluto
READ TABLE it_xmlsat INTO wa_xmlsat index indice_inc.
wa_data_alv-saldopagar = wa_xmlsat-cvalue.


clear wa_xmlsat.
*READ TABLE it_xmlsat INTO wa_xmlsat WITH KEY cname = 'TasaOCuotaP'.
*vl_tasa = wa_xmlsat-cvalue. "se obtiene si es 0 o 16
*indice_inc = sy-tabix + 1. "Base P de esa TasaOcuotaP
*
*clear wa_xmlsat.
*READ TABLE it_xmlsat INTO wa_xmlsat index indice_inc.
*vl_valor = wa_xmlsat-cvalue.
*
*IF vl_tasa eq 0 and vl_valor eq 0 and wa_data_alv-parcialidad eq 1. "si tasa = e ImporteP = 0
*
*     indice_inc = indice_inc - 4. "BASE P
*     clear wa_xmlsat.
*     READ TABLE it_xmlsat INTO wa_xmlsat index indice_inc.
*     wa_data_alv-baseiva0 = wa_xmlsat-cvalue.
*     wa_data_alv-baseiva16 = '0.00'.
*ELSE.
*   indice_inc = indice_inc + 5. "otro Impuesto
*   clear wa_xmlsat.
*   READ TABLE it_xmlsat INTO wa_xmlsat index indice_inc.
*   IF wa_xmlsat-cname eq 'TasaOCuotaP'.
*      indice_inc =  indice_inc - 3. "base P tasa 16
*      clear wa_xmlsat.
*      READ TABLE it_xmlsat INTO wa_xmlsat index indice_inc.
*      IF vl_tasa eq 0 and vl_valor eq 0.
*        wa_data_alv-baseiva0 = wa_xmlsat-cvalue.
*        wa_data_alv-baseiva16 = '0.00'.
*       else.
*        wa_data_alv-baseiva16 = wa_xmlsat-cvalue.
*        wa_data_alv-baseiva0 = '0.00'.
*      endif.
*   else.
*    indice_inc = indice_inc - 9. "regresanmos a la posición original
*    clear wa_xmlsat.
*    READ TABLE it_xmlsat INTO wa_xmlsat index indice_inc.
*    IF vl_tasa eq 0 and vl_valor eq 0.
*      wa_data_alv-baseiva0 = wa_xmlsat-cvalue.
*      wa_data_alv-baseiva16 = '0.00'.
*    else.
*      wa_data_alv-baseiva0 = '0.00'.
*      wa_data_alv-baseiva16 = wa_xmlsat-cvalue.
*    endif.
*   ENDIF.
*
*ENDIF.



clear wa_xmlsat.
indice_inc = indice_base + 16. " Importe DR
READ TABLE it_xmlsat INTO wa_xmlsat index indice_inc.
wa_data_alv-ivatras16 = wa_xmlsat-cvalue.

"nueva validación de Tasa
indice_inc = indice_inc - 1. "TasaOCuotaDR
READ TABLE it_xmlsat INTO wa_xmlsat index indice_inc.
vl_tasa = wa_xmlsat-cvalue.
indice_inc = indice_inc - 3. " Base DR
READ TABLE it_xmlsat INTO wa_xmlsat index indice_inc.
IF vl_tasa > 0. "es .16
  wa_data_alv-baseiva0 = '0.00'.
  wa_data_alv-baseiva16 = wa_xmlsat-cvalue.
 else.
     wa_data_alv-baseiva0 = wa_xmlsat-cvalue.
  wa_data_alv-baseiva16 =  '0.00'.
ENDIF.

CLEAR wa_xmlsat.
READ TABLE it_xmlsat INTO wa_xmlsat WITH KEY cname = 'FormaDePagoP'.
wa_data_alv-formpago = wa_xmlsat-cvalue.

CLEAR wa_xmlsat.
READ TABLE it_xmlsat INTO wa_xmlsat WITH KEY cname = 'Monto'.
wa_data_alv-montototpago = wa_xmlsat-cvalue.

ENDFORM.
