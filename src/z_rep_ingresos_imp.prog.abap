*&---------------------------------------------------------------------*
*&  Include           Z_REP_INGRESOS_IMPV2
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&  Include           Z_REP_INGRESOS_IMP.
*&---------------------------------------------------------------------*


CLASS lcl_screen IMPLEMENTATION.

  METHOD create_fcat.
    DATA: ls_fieldcatalogue TYPE lvc_s_fcat,
          lt_fieldcatalogue TYPE lvc_t_fcat.

    CLEAR ls_fieldcatalogue.
    ls_fieldcatalogue-fieldname = 'BUKRS'. "Sociedad.
    ls_fieldcatalogue-tabname   = 'MT_OUT'.
    ls_fieldcatalogue-outputlen = 4.
    ls_fieldcatalogue-scrtext_l = text-c01. "Sociedad
    ls_fieldcatalogue-key         = 'X'.
    APPEND ls_fieldcatalogue TO lt_fieldcatalogue.
*////////////////////////////////////
    CLEAR ls_fieldcatalogue.
    ls_fieldcatalogue-fieldname = 'GJAHR'. "'Año.
    ls_fieldcatalogue-tabname   = 'MT_OUT'.
    ls_fieldcatalogue-outputlen = 4.
    ls_fieldcatalogue-scrtext_l = text-c02. "Año
    ls_fieldcatalogue-key         = 'X'.
    APPEND ls_fieldcatalogue TO lt_fieldcatalogue.
*////////////////////////////////////
    CLEAR ls_fieldcatalogue.
    ls_fieldcatalogue-fieldname = 'MONAT'. "''Mes
    ls_fieldcatalogue-tabname   = 'MT_OUT'.
    ls_fieldcatalogue-outputlen = 2.
    ls_fieldcatalogue-scrtext_l = text-c03. "Mes
    ls_fieldcatalogue-key         = 'X'.
    APPEND ls_fieldcatalogue TO lt_fieldcatalogue.
*////////////////////////////////////
    CLEAR ls_fieldcatalogue.
    ls_fieldcatalogue-fieldname = 'CPUDT'. "'Fecha de Registro
    ls_fieldcatalogue-tabname   = 'MT_OUT'.
    ls_fieldcatalogue-outputlen = 10.
    ls_fieldcatalogue-scrtext_l = text-c04. "Fecha de Registro
    ls_fieldcatalogue-key         = 'X'.
    APPEND ls_fieldcatalogue TO lt_fieldcatalogue.
*////////////////////////////////////
    CLEAR ls_fieldcatalogue.
    ls_fieldcatalogue-fieldname = 'BLDAT'. "Fecha d Documento
    ls_fieldcatalogue-tabname   = 'MT_OUT'.
    ls_fieldcatalogue-outputlen = 10.
    ls_fieldcatalogue-scrtext_l = text-c05. "Fecha de Documento
    ls_fieldcatalogue-key         = 'X'.
    APPEND ls_fieldcatalogue TO lt_fieldcatalogue.
*////////////////////////////////////

*////////////////////////////////////
      CLEAR ls_fieldcatalogue.
      ls_fieldcatalogue-fieldname = 'VALUT'. "''
      ls_fieldcatalogue-tabname   = 'MT_OUT'.
      ls_fieldcatalogue-ref_field = 'FECHA VALOR'. "'
      ls_fieldcatalogue-outputlen = 25.
      ls_fieldcatalogue-scrtext_l = 'FECHA VALOR'. "'
      APPEND ls_fieldcatalogue TO lt_fieldcatalogue.


*IPA/ATB Ene2020
    CLEAR ls_fieldcatalogue.
    ls_fieldcatalogue-fieldname = 'BLART_P'. "Clase de Doc.Pago
    ls_fieldcatalogue-tabname   = 'MT_OUT'.
    ls_fieldcatalogue-outputlen = 4.
    ls_fieldcatalogue-scrtext_l = text-c36.
    ls_fieldcatalogue-key         = 'X'.
    APPEND ls_fieldcatalogue TO lt_fieldcatalogue.
*////////////////////////////////////

    CLEAR ls_fieldcatalogue.
    ls_fieldcatalogue-fieldname = 'BELNR'. "Documento Contable Ingreso
    ls_fieldcatalogue-tabname   = 'MT_OUT'.
    ls_fieldcatalogue-outputlen = 10.
    ls_fieldcatalogue-NO_zero = 'X'.
    ls_fieldcatalogue-REF_FIELD = 'BELNR'. "
    ls_fieldcatalogue-REF_TABLE   = 'BSEG'.
*    ls_fieldcatalogue-REF_FIELD = 'HKONT'. "Cuenta'.
*    ls_fieldcatalogue-REF_TABLE   = 'BSEG'.
    ls_fieldcatalogue-EDIT_MASK = '__________'.
    ls_fieldcatalogue-scrtext_l = text-c06. "Documento Contable Ingreso
    ls_fieldcatalogue-key         = 'X'.
    APPEND ls_fieldcatalogue TO lt_fieldcatalogue.

*////////////////////////////////////
    CLEAR ls_fieldcatalogue.
    ls_fieldcatalogue-fieldname = 'KUNNR'. "
    ls_fieldcatalogue-tabname   = 'MT_OUT'.
    ls_fieldcatalogue-outputlen = 15.
    ls_fieldcatalogue-scrtext_l = text-c33. "
    APPEND ls_fieldcatalogue TO lt_fieldcatalogue.
*////////////////////////////////////
    CLEAR ls_fieldcatalogue.
    ls_fieldcatalogue-fieldname = 'STCD1'. "RFC.
    ls_fieldcatalogue-tabname   = 'MT_OUT'.
    ls_fieldcatalogue-outputlen = 15.
    ls_fieldcatalogue-scrtext_l = text-c08. "RFC
    APPEND ls_fieldcatalogue TO lt_fieldcatalogue.
*////////////////////////////////////
    CLEAR ls_fieldcatalogue.
    ls_fieldcatalogue-fieldname = 'NAME1'. "Nombre.
    ls_fieldcatalogue-tabname   = 'MT_OUT'.
    ls_fieldcatalogue-outputlen = 30.
    ls_fieldcatalogue-scrtext_l = text-c09. "Nombre
    APPEND ls_fieldcatalogue TO lt_fieldcatalogue.
*////////////////////////////////////

*IPA/ATB Ene2020
    CLEAR ls_fieldcatalogue.
    ls_fieldcatalogue-fieldname = 'METODOP'. "MetodoPago.Pago
    ls_fieldcatalogue-tabname   = 'MT_OUT'.
    ls_fieldcatalogue-outputlen = 4.
    ls_fieldcatalogue-scrtext_l = text-c37.
    APPEND ls_fieldcatalogue TO lt_fieldcatalogue.

    CLEAR ls_fieldcatalogue.
    ls_fieldcatalogue-fieldname = 'FORMAP'.  "FormaPago.Factura
    ls_fieldcatalogue-tabname   = 'MT_OUT'.
    ls_fieldcatalogue-outputlen = 4.
    ls_fieldcatalogue-scrtext_l = text-c38.
    APPEND ls_fieldcatalogue TO lt_fieldcatalogue.

    CLEAR ls_fieldcatalogue.
    ls_fieldcatalogue-fieldname = 'BLART_F'. "Clase de Doc.Factura
    ls_fieldcatalogue-tabname   = 'MT_OUT'.
    ls_fieldcatalogue-outputlen = 4.
    ls_fieldcatalogue-scrtext_l = text-c36.
    APPEND ls_fieldcatalogue TO lt_fieldcatalogue.
*////////////////////////////////////

    CLEAR ls_fieldcatalogue.
    ls_fieldcatalogue-fieldname = 'DOC_PROV'. "Docuemtno Provisión
    ls_fieldcatalogue-tabname   = 'MT_OUT'.
    ls_fieldcatalogue-outputlen = 10.
    ls_fieldcatalogue-scrtext_l = text-c07. " Documento Provisión
    APPEND ls_fieldcatalogue TO lt_fieldcatalogue.
*////////////////////////////////////
    CLEAR ls_fieldcatalogue.
    ls_fieldcatalogue-fieldname = 'FACT_SD'. "Factura
    ls_fieldcatalogue-tabname   = 'MT_OUT'.
    ls_fieldcatalogue-outputlen = 20.
    ls_fieldcatalogue-scrtext_l = text-c35. "
    APPEND ls_fieldcatalogue TO lt_fieldcatalogue.
*////////////////////////////////////
*IPA/ATB MAr2020
    CLEAR ls_fieldcatalogue.
    ls_fieldcatalogue-fieldname = 'UUID_P'. "Nombre.
    ls_fieldcatalogue-tabname   = 'MT_OUT'.
    ls_fieldcatalogue-outputlen = 37.
    ls_fieldcatalogue-scrtext_l = text-c39. "Nombre
    APPEND ls_fieldcatalogue TO lt_fieldcatalogue.

    CLEAR ls_fieldcatalogue.
    ls_fieldcatalogue-fieldname = 'UUID'. "Nombre.
    ls_fieldcatalogue-tabname   = 'MT_OUT'.
    ls_fieldcatalogue-outputlen = 40.
    ls_fieldcatalogue-scrtext_l = text-c10. "Nombre
    APPEND ls_fieldcatalogue TO lt_fieldcatalogue.
*////////////////////////////////////
    CLEAR ls_fieldcatalogue.
    ls_fieldcatalogue-fieldname = 'ARKTX'. "CONCEPTO DE BIEN O SERVICIO
    ls_fieldcatalogue-tabname   = 'MT_OUT'.
    ls_fieldcatalogue-outputlen = 40.
    ls_fieldcatalogue-scrtext_l = text-c11. "Concepto de Bien o Servicio
    APPEND ls_fieldcatalogue TO lt_fieldcatalogue.
*////////////////////////////////////
    CLEAR ls_fieldcatalogue.
    ls_fieldcatalogue-fieldname = 'HKONT'. "Cuenta'.
    ls_fieldcatalogue-tabname   = 'MT_OUT'.
*    ls_fieldcatalogue-REF_FIELD = 'HKONT'. "Cuenta'.
*    ls_fieldcatalogue-REF_TABLE   = 'BSEG'.
*    ls_fieldcatalogue-LZERO = 'X'.
    ls_fieldcatalogue-outputlen = 12.
    ls_fieldcatalogue-scrtext_l = text-c12. "Cuenta
    ls_fieldcatalogue-no_zero = 'X'."quitaba ceros a la derecha sin esta opción
    APPEND ls_fieldcatalogue TO lt_fieldcatalogue.
*////////////////////////////////////
    CLEAR ls_fieldcatalogue.
    ls_fieldcatalogue-fieldname = 'BASE'. "''ID_CTA_BENE'.
    ls_fieldcatalogue-tabname   = 'MT_OUT'.
*    ls_fieldcatalogue-TECH = 'WAERS'.
    ls_fieldcatalogue-outputlen = 15.
    ls_fieldcatalogue-scrtext_l = text-c13. "Base
    APPEND ls_fieldcatalogue TO lt_fieldcatalogue.
*////////////////////////////////////
    CLEAR ls_fieldcatalogue.
    ls_fieldcatalogue-fieldname = 'IVA'.
    ls_fieldcatalogue-tabname   = 'MT_OUT'.
*    ls_fieldcatalogue-TECH = 'WAERS'.
    ls_fieldcatalogue-outputlen = 15.
    ls_fieldcatalogue-scrtext_l = text-c14. "IVA
    ls_fieldcatalogue-emphasize = 'C300'.
    APPEND ls_fieldcatalogue TO lt_fieldcatalogue.
*////////////////////////////////////
    CLEAR ls_fieldcatalogue.
    ls_fieldcatalogue-fieldname = 'IVA_RET'. "'IVA RET.
    ls_fieldcatalogue-tabname   = 'MT_OUT'.
*    ls_fieldcatalogue-TECH = 'WAERS'.
    ls_fieldcatalogue-outputlen = 15.
    ls_fieldcatalogue-scrtext_l = text-c15. "Type ID Bank
    ls_fieldcatalogue-emphasize = 'C711'.
    APPEND ls_fieldcatalogue TO lt_fieldcatalogue.
*////////////////////////////////////

*//////////////////////////////////// modificaciones michael sep 2020 ini
    CLEAR ls_fieldcatalogue.
    ls_fieldcatalogue-fieldname = 'NOM_RET'. "'IVA RET.
    ls_fieldcatalogue-tabname   = 'MT_OUT'.
*    ls_fieldcatalogue-TECH = 'WAERS'.
    ls_fieldcatalogue-outputlen = 15.
    ls_fieldcatalogue-scrtext_l = 'Ret.Nom.'. "Type ID Bank
    ls_fieldcatalogue-emphasize = 'C411'.
    APPEND ls_fieldcatalogue TO lt_fieldcatalogue.
*//////////////////////////////////// modificaciones michael sep 2020 fin

    CLEAR ls_fieldcatalogue.
    ls_fieldcatalogue-fieldname = 'TOTAL'. "'
    ls_fieldcatalogue-tabname   = 'MT_OUT'.
*    ls_fieldcatalogue-TECH = 'WAERS'.
    ls_fieldcatalogue-outputlen = 15.
    ls_fieldcatalogue-scrtext_l = text-c16. "Total
    ls_fieldcatalogue-emphasize = 'C601'.
    APPEND ls_fieldcatalogue TO lt_fieldcatalogue.
*////////////////////////////////////
    CLEAR ls_fieldcatalogue.
    ls_fieldcatalogue-fieldname = 'TOT_INGRESO'. "''
    ls_fieldcatalogue-tabname   = 'MT_OUT'.
*    ls_fieldcatalogue-TECH = 'WAERS'.
    ls_fieldcatalogue-outputlen = 15.
    ls_fieldcatalogue-scrtext_l = text-c17. "
    APPEND ls_fieldcatalogue TO lt_fieldcatalogue.
*////////////////////////////////////
    CLEAR ls_fieldcatalogue.
    ls_fieldcatalogue-fieldname = 'TASA'. "'
    ls_fieldcatalogue-tabname   = 'MT_OUT'.
    ls_fieldcatalogue-outputlen = 5.
    ls_fieldcatalogue-scrtext_l = text-c18.
    APPEND ls_fieldcatalogue TO lt_fieldcatalogue.
*////////////////////////////////////
    CLEAR ls_fieldcatalogue.
    ls_fieldcatalogue-fieldname = 'MONEDA'. "'
    ls_fieldcatalogue-tabname   = 'MT_OUT'.
    ls_fieldcatalogue-ref_field = 'MONEDA'. "'
    ls_fieldcatalogue-outputlen = 4.
    ls_fieldcatalogue-scrtext_l = text-c19. "
    APPEND ls_fieldcatalogue TO lt_fieldcatalogue.


    CLEAR ls_fieldcatalogue.
    ls_fieldcatalogue-fieldname = 'KURSF'. "'
    ls_fieldcatalogue-tabname   = 'MT_OUT'.
    ls_fieldcatalogue-outputlen = 5.
    ls_fieldcatalogue-scrtext_l = 'Tipo de cambio'.
    APPEND ls_fieldcatalogue TO lt_fieldcatalogue.
*//////////////////////////////////// MODIFICACIONES MICHAEL JUL 2020 INICIO
    CLEAR ls_fieldcatalogue.
    ls_fieldcatalogue-fieldname = 'WWERT'. "'
    ls_fieldcatalogue-tabname   = 'MT_OUT'.
    ls_fieldcatalogue-outputlen = 5.
    ls_fieldcatalogue-scrtext_l = 'Fecha Conversión'.
    APPEND ls_fieldcatalogue TO lt_fieldcatalogue.
*//////////////////////////////////// MODIFICACIONES MICHAEL JUL 2020 FIN

    CLEAR ls_fieldcatalogue.
    ls_fieldcatalogue-fieldname = 'SGTXT'. "''
    ls_fieldcatalogue-tabname   = 'MT_OUT'.
    ls_fieldcatalogue-ref_field = 'SGTXT'. "'
    ls_fieldcatalogue-outputlen = 15.
    ls_fieldcatalogue-scrtext_l = text-c21. "Referencia
    APPEND ls_fieldcatalogue TO lt_fieldcatalogue.
*////////////////////////////////////
    CLEAR ls_fieldcatalogue.
    ls_fieldcatalogue-fieldname = 'XBLNR'. "''
    ls_fieldcatalogue-tabname   = 'MT_OUT'.
    ls_fieldcatalogue-ref_field = 'XBLNR'. "'
    ls_fieldcatalogue-outputlen = 25.
    ls_fieldcatalogue-scrtext_l = text-c22. "Forma de Pago
    APPEND ls_fieldcatalogue TO lt_fieldcatalogue.
*////////////////////////////////////
    CLEAR ls_fieldcatalogue.
    ls_fieldcatalogue-fieldname = 'USNAM'. "''
    ls_fieldcatalogue-tabname   = 'MT_OUT'.
    ls_fieldcatalogue-outputlen = 10.
    ls_fieldcatalogue-scrtext_l = text-c23. "Usuario
    APPEND ls_fieldcatalogue TO lt_fieldcatalogue.
*////////////////////////////////////
    CLEAR ls_fieldcatalogue.
    ls_fieldcatalogue-fieldname = 'SAKNR'. "''
    ls_fieldcatalogue-tabname   = 'MT_OUT'.
    ls_fieldcatalogue-outputlen = 10.
    ls_fieldcatalogue-scrtext_l = text-c24. "Cta. Mayor
    APPEND ls_fieldcatalogue TO lt_fieldcatalogue.

*////////////////////////////////////
    CLEAR ls_fieldcatalogue.
      ls_fieldcatalogue-fieldname = 'AUGBL'. "''
      ls_fieldcatalogue-tabname   = 'MT_OUT'.
      ls_fieldcatalogue-ref_field = 'AUGBL'. "'
      ls_fieldcatalogue-outputlen = 25.
      ls_fieldcatalogue-scrtext_l = text-c27. "Doc Cpmpens
*      ls_fieldcatalogue-style = ALV_STYLE_FONT_BOLD.
      APPEND ls_fieldcatalogue TO lt_fieldcatalogue.

    CLEAR ls_fieldcatalogue.
    ls_fieldcatalogue-fieldname = 'AUGDT'. "''
    ls_fieldcatalogue-tabname   = 'MT_OUT'.
    ls_fieldcatalogue-outputlen = 25.
    ls_fieldcatalogue-scrtext_l = text-c26. "Fecha de Pago
    APPEND ls_fieldcatalogue TO lt_fieldcatalogue.

    CLEAR ls_fieldcatalogue.
    ls_fieldcatalogue-fieldname = 'DOC_BANCO'. "'
    ls_fieldcatalogue-tabname   = 'MT_OUT'.
    ls_fieldcatalogue-outputlen = 5.
    ls_fieldcatalogue-scrtext_l = 'Doc. Banco'.
    APPEND ls_fieldcatalogue TO lt_fieldcatalogue.

*////////////////////////////////////
    CLEAR ls_fieldcatalogue.
    ls_fieldcatalogue-fieldname = 'BANCO'. "''
    ls_fieldcatalogue-tabname   = 'MT_OUT'.
    ls_fieldcatalogue-ref_field = 'BANCO'. "'
    ls_fieldcatalogue-outputlen = 25.
    ls_fieldcatalogue-scrtext_l = text-c25. "Banco
    APPEND ls_fieldcatalogue TO lt_fieldcatalogue.


********
***********  Conciliado

*    IF p_conci = 'X'
*
**ATB/IPA Abr2020          "resulta que tambien el concentrado 'contable'
*
**IPA/ATB  Abr2020  En Actualizacion2020, 1ero se dijo(usuario-IT o Funcional)
**que ContableConcentrado = version de Contable, (como lo dice su nombre)
**Despues por reporte usuarioFINAL, +Bien era ConciliadoConcentrado
**Ya no se cambio el nombre  "p_cocon"(ContableConcentrado) aunque ahora = ConciliadoContrado
**    IF  p_conta IS INITIAL   And  p_cocon is initial.
*
*
*     Or p_cocon = 'X'.
*
**////////////////////////////////////
*      CLEAR ls_fieldcatalogue.
*      ls_fieldcatalogue-fieldname = 'AUGBL'. "''
*      ls_fieldcatalogue-tabname   = 'MT_OUT'.
*      ls_fieldcatalogue-ref_field = 'AUGBL'. "'
*      ls_fieldcatalogue-outputlen = 25.
*      ls_fieldcatalogue-scrtext_l = text-c27. "Doc Cpmpens
*      APPEND ls_fieldcatalogue TO lt_fieldcatalogue.
*
**////////////////////////////////////
*      CLEAR ls_fieldcatalogue.
*      ls_fieldcatalogue-fieldname = 'IMPTE_EDO_CTA'. "''
*      ls_fieldcatalogue-tabname   = 'MT_OUT'.
*      ls_fieldcatalogue-ref_field = 'IMPTE_EDO_CTA'. "'
*      ls_fieldcatalogue-outputlen = 25.
*      ls_fieldcatalogue-scrtext_l = text-c28. "Doc Cpmpens
*      APPEND ls_fieldcatalogue TO lt_fieldcatalogue.
*
**////////////////////////////////////
*      CLEAR ls_fieldcatalogue.
*      ls_fieldcatalogue-fieldname = 'DIFERENCIAS'. "''
*      ls_fieldcatalogue-tabname   = 'MT_OUT'.
*      ls_fieldcatalogue-ref_field = 'DIFERENCIAS'. "'
*      ls_fieldcatalogue-outputlen = 25.
*      ls_fieldcatalogue-scrtext_l = text-c29. "Doc Cpmpens
*      APPEND ls_fieldcatalogue TO lt_fieldcatalogue.
*
*          CLEAR ls_fieldcatalogue.
*    ls_fieldcatalogue-fieldname = 'SSBTR'. "'
*    ls_fieldcatalogue-tabname   = 'MT_OUT'.
*    ls_fieldcatalogue-outputlen = 5.
*    ls_fieldcatalogue-scrtext_l = 'Saldo Inicial'.
*    APPEND ls_fieldcatalogue TO lt_fieldcatalogue.
*
*    CLEAR ls_fieldcatalogue.
*    ls_fieldcatalogue-fieldname = 'ESBTR'. "'
*    ls_fieldcatalogue-tabname   = 'MT_OUT'.
*    ls_fieldcatalogue-outputlen = 5.
*    ls_fieldcatalogue-scrtext_l = 'Saldo final'.
*    APPEND ls_fieldcatalogue TO lt_fieldcatalogue.
*
*    CLEAR ls_fieldcatalogue.
*    ls_fieldcatalogue-fieldname = 'CVESAT'. "'
*    ls_fieldcatalogue-tabname   = 'MT_OUT'.
*    ls_fieldcatalogue-outputlen = 5.
*    ls_fieldcatalogue-scrtext_l = 'Clave SAT'.
*    APPEND ls_fieldcatalogue TO lt_fieldcatalogue.
*
*    CLEAR ls_fieldcatalogue.
*    ls_fieldcatalogue-fieldname = 'DESCSAT'. "'
*    ls_fieldcatalogue-tabname   = 'MT_OUT'.
*    ls_fieldcatalogue-outputlen = 5.
*    ls_fieldcatalogue-scrtext_l = 'Descripción SAT'.
*    APPEND ls_fieldcatalogue TO lt_fieldcatalogue.
*
*    CLEAR ls_fieldcatalogue.
*    ls_fieldcatalogue-fieldname = 'MATNR'. "'
*    ls_fieldcatalogue-tabname   = 'MT_OUT'.
*    ls_fieldcatalogue-outputlen = 5.
*    ls_fieldcatalogue-scrtext_l = 'Material'.
*    APPEND ls_fieldcatalogue TO lt_fieldcatalogue.
*
*
*
*    ENDIF.

    re_t_fcat[] = lt_fieldcatalogue[].
  ENDMETHOD.                    "create_fcat

  METHOD create_alv.
    "----------------------------------------------< create_alv >--------------------------------------------------------------
*   @  Created by:    PS31409
*   @  Description: Erstellt das ALV Grid
*   @  PARAMETER:
*   @
*   @  Created on:  05.03.2014 11:26:08
*   ~~~~~~~~~~~~~~~~~~~~~~~~~~-{ TYPES }-~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
*   ~~~~~~~~~~~~~~~~~~~~~~~~~~-{ DATA }-~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
    DATA:
*          ls_layo TYPE lvs_s_layo,
          lt_fcat TYPE lvc_t_fcat,
          ls_vari TYPE disvariant.


    cd_appl = lcl_appl=>get_instance( ).

    lt_fcat = me->create_fcat( ).

    IF cd_o_alv IS NOT BOUND.
      IF cd_o_con IS NOT BOUND.
        CREATE OBJECT cd_o_con
          EXPORTING
            container_name = 'CC_ALV'
            .

      ENDIF.

      CREATE OBJECT cd_o_alv
        EXPORTING
          i_appl_events = 'X'
          i_parent      = cd_o_con.

      mt_out[] = im_t_data[].

      DATA : ls_layo TYPE lvc_s_layo.

      ls_layo-sel_mode = 'A'.
      ls_layo-cwidth_opt = 'X'.
******* MODIFICACIONES MICHAEL para poner color a la fila 27.08.2020 INI

      ls_layo-info_fname = 'COLOR_F'.

******* MODIFICACIONES MICHAEL para poner color a la fila 27.08.2020 FIN

      ls_vari-report = sy-repid.
      ls_vari-variant = '/rep_ingresos'.


      cd_o_alv->set_table_for_first_display(
      EXPORTING
*         I_STRUCTURE_NAME = 'ZINGRESOS_OUTPUT'
        is_layout = ls_layo
        is_variant = ls_vari
        i_save = 'A'
     CHANGING
            it_fieldcatalog = lt_fcat
            it_outtab = mt_out

       ).
    ENDIF.
  ENDMETHOD.                    "create_alv

  METHOD create_fcat_riva.
    DATA: ls_fieldcatalogue TYPE lvc_s_fcat,
          lt_fieldcatalogue TYPE lvc_t_fcat.


    CLEAR ls_fieldcatalogue.
    ls_fieldcatalogue-fieldname = 'CLASIF'. "Clasificacion para separar
    ls_fieldcatalogue-tabname   = 'MT_OUT_IVA'.
    ls_fieldcatalogue-outputlen = 1.
    ls_fieldcatalogue-scrtext_l = text-c34. ".
    APPEND ls_fieldcatalogue TO lt_fieldcatalogue.

    CLEAR ls_fieldcatalogue.
    ls_fieldcatalogue-fieldname = 'HKONT'. "Cuenta'.
    ls_fieldcatalogue-tabname   = 'MT_OUT_IVA'.
    ls_fieldcatalogue-outputlen = 20.
    ls_fieldcatalogue-scrtext_l = text-c12. "Cuenta
    ls_fieldcatalogue-no_zero = 'X'."quitaba ceros a la derecha sin esta opción
   APPEND ls_fieldcatalogue TO lt_fieldcatalogue.
*////////////////////////////////////
    CLEAR ls_fieldcatalogue.
    ls_fieldcatalogue-fieldname = 'CONCEPTO'. "Concepto'.
    ls_fieldcatalogue-tabname   = 'MT_OUT_IVA'.
    ls_fieldcatalogue-outputlen = 35.
    ls_fieldcatalogue-scrtext_l = text-c30. "
    APPEND ls_fieldcatalogue TO lt_fieldcatalogue.
*////////////////////////////////////
    CLEAR ls_fieldcatalogue.
    ls_fieldcatalogue-fieldname = 'BASE'. "''ID_CTA_BENE'.
    ls_fieldcatalogue-tabname   = 'MT_OUT_IVA'.
    ls_fieldcatalogue-outputlen = 25.
    ls_fieldcatalogue-scrtext_l = text-c13. "Base
    APPEND ls_fieldcatalogue TO lt_fieldcatalogue.
*////////////////////////////////////
    CLEAR ls_fieldcatalogue.
    ls_fieldcatalogue-fieldname = 'IVA'.
    ls_fieldcatalogue-tabname   = 'MT_OUT_IVA'.
    ls_fieldcatalogue-outputlen = 25.
    ls_fieldcatalogue-scrtext_l = text-c14. "IVA
    APPEND ls_fieldcatalogue TO lt_fieldcatalogue.



    re_t_fcat[] = lt_fieldcatalogue[].
  ENDMETHOD.                    "create_fcat


  METHOD create_fcat_risr.
    DATA: ls_fieldcatalogue TYPE lvc_s_fcat,
          lt_fieldcatalogue TYPE lvc_t_fcat.

    FREE re_t_fcat.
    FREE lt_fieldcatalogue.

    CLEAR ls_fieldcatalogue.
    ls_fieldcatalogue-fieldname = 'CLASIF'. "Clasificacion para separar
    ls_fieldcatalogue-tabname   = 'MT_OUT_IVA'.
    ls_fieldcatalogue-outputlen = 1.
    ls_fieldcatalogue-scrtext_l = text-c34. ".
    APPEND ls_fieldcatalogue TO lt_fieldcatalogue.

    CLEAR ls_fieldcatalogue.
    ls_fieldcatalogue-fieldname = 'HKONT'. "Cuenta'.
    ls_fieldcatalogue-tabname   = 'MT_OUT_ISR'.
    ls_fieldcatalogue-outputlen = 20.
    ls_fieldcatalogue-scrtext_l = text-c12. "Cuenta
    ls_fieldcatalogue-no_zero = 'X'."quitaba ceros a la derecha sin esta opción
    APPEND ls_fieldcatalogue TO lt_fieldcatalogue.
*////////////////////////////////////
    CLEAR ls_fieldcatalogue.
    ls_fieldcatalogue-fieldname = 'CONCEPTO'. "Concepto'.
    ls_fieldcatalogue-tabname   = 'MT_OUT_ISR'.
    ls_fieldcatalogue-outputlen = 35.
    ls_fieldcatalogue-scrtext_l = text-c30. "Cuenta
    APPEND ls_fieldcatalogue TO lt_fieldcatalogue.
*////////////////////////////////////
    CLEAR ls_fieldcatalogue.
    ls_fieldcatalogue-fieldname = 'BASE'. "''ID_CTA_BENE'.
    ls_fieldcatalogue-tabname   = 'MT_OUT_ISR'.
    ls_fieldcatalogue-outputlen = 25.
    ls_fieldcatalogue-scrtext_l = text-c13. "Base
    APPEND ls_fieldcatalogue TO lt_fieldcatalogue.
*////////////////////////////////////
    re_t_fcat[] = lt_fieldcatalogue[].
  ENDMETHOD.                    "create_fcat_isr

  METHOD create_fcat_res_ing.
    DATA: ls_fieldcatalogue TYPE lvc_s_fcat,
          lt_fieldcatalogue TYPE lvc_t_fcat.

    FREE re_t_fcat.
    FREE lt_fieldcatalogue.

*////////////////////////////////////
    CLEAR ls_fieldcatalogue.
    ls_fieldcatalogue-fieldname = 'CLASIF'. "Clasificacion para separar
    ls_fieldcatalogue-tabname   = 'MT_OUT_IVA'.
    ls_fieldcatalogue-outputlen = 1.
    ls_fieldcatalogue-scrtext_l = text-c34. ".
    APPEND ls_fieldcatalogue TO lt_fieldcatalogue.

    CLEAR ls_fieldcatalogue.
    ls_fieldcatalogue-fieldname = 'CONCEPTO'. "Descripción de laCuenta
    ls_fieldcatalogue-tabname   = 'MT_OUT_RESING'.
    ls_fieldcatalogue-outputlen = 35.
    ls_fieldcatalogue-scrtext_l = text-c31. "
    APPEND ls_fieldcatalogue TO lt_fieldcatalogue.
*////////////////////////////////////
    CLEAR ls_fieldcatalogue.
    ls_fieldcatalogue-fieldname = 'TOTAL'. "'Total
    ls_fieldcatalogue-tabname   = 'MT_OUT_RESING'.
    ls_fieldcatalogue-outputlen = 25.
    ls_fieldcatalogue-scrtext_l = text-c32. "Total
    APPEND ls_fieldcatalogue TO lt_fieldcatalogue.
*////////////////////////////////////
    re_t_fcat[] = lt_fieldcatalogue[].
  ENDMETHOD.                    "create_fcat_RES_ISR

  METHOD create_alv_iva.
    "----------------------------------------------< create_alv >--------------------------------------------------------------
*   @  Created by:    PS31409
*   @  Description: Erstellt das ALV Grid
*   @  PARAMETER:
*   @
*   @  Created on:  05.03.2014 11:26:08
*   ~~~~~~~~~~~~~~~~~~~~~~~~~~-{ TYPES }-~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
*   ~~~~~~~~~~~~~~~~~~~~~~~~~~-{ DATA }-~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
    DATA:
*          ls_layo TYPE lvs_s_layo,
          lt_fcat TYPE lvc_t_fcat,
          ls_variant TYPE disvariant.


    cd_appl = lcl_appl=>get_instance( ).
*
    lt_fcat = me->create_fcat_riva( ).

    IF cd_o_alv IS NOT BOUND.
      IF cd_o_con IS NOT BOUND.
        CREATE OBJECT cd_o_con
          EXPORTING
            container_name = 'CC_ALV'
            .

      ENDIF.

      CREATE OBJECT cd_o_alv
        EXPORTING
          i_appl_events = 'X'
          i_parent      = cd_o_con.


      mt_out_iva[] = im_t_data[].

      DATA : ls_layo TYPE lvc_s_layo.

      ls_layo-sel_mode = 'A'.
      ls_layo-cwidth_opt = ''.

      ls_variant-report = sy-repid.
      ls_variant-variant = '/REP_IVA'.

      cd_o_alv->set_table_for_first_display(
      EXPORTING
           is_layout = ls_layo
        is_variant = ls_variant
        i_save = 'A'
     CHANGING
            it_fieldcatalog = lt_fcat
            it_outtab = mt_out_iva

       ).


    ENDIF.
  ENDMETHOD.                    "create_alv

  METHOD create_alv_isr.
    "----------------------------------------------< create_alv >--------------------------------------------------------------
*   @  Descripcion: Crea Alv Grid y smart ISR
*   ~~~~~~~~~~~~~~~~~~~~~~~~~~-{ TYPES }-~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
*   ~~~~~~~~~~~~~~~~~~~~~~~~~~-{ DATA }-~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
    DATA:
*          ls_layo TYPE lvs_s_layo,
          lt_fcat TYPE lvc_t_fcat,
          ls_variant TYPE disvariant.


    cd_appl = lcl_appl=>get_instance( ).
*    me->mt_out = cd_appl->get_data( ).
*
    FREE lt_fcat.
    lt_fcat = me->create_fcat_risr( ).

    IF cd_o_alv IS NOT BOUND.
      IF cd_o_con IS NOT BOUND.
        CREATE OBJECT cd_o_con
          EXPORTING
*            dynnr = c_dynnr
*            repid = sy-repid
            container_name = 'CC_ALV'
            .

      ENDIF.

      CREATE OBJECT cd_o_alv
        EXPORTING
          i_appl_events = 'X'
          i_parent      = cd_o_con.


*
      mt_out_isr[] = im_t_data[].

      DATA : ls_layo TYPE lvc_s_layo.

      ls_layo-sel_mode = 'A'.
      ls_layo-cwidth_opt = ''.


      ls_variant-report = sy-repid.
      ls_variant-variant = '/REP_ISR'.

      cd_o_alv->set_table_for_first_display(
      EXPORTING
*         i_structure_name = 'ZING_REPS_OUTPUT'
        is_layout = ls_layo
        is_variant = ls_variant
        i_save = 'A'
     CHANGING
            it_fieldcatalog = lt_fcat
            it_outtab = mt_out_isr

       ).


    ENDIF.
  ENDMETHOD.                    "create_alv_isr

  METHOD create_alv_res_ing.
    "----------------------------------------------< create_alv >--------------------------------------------------------------
*   @  Descripcion: Crea Alv Grid y smart RESUMEN
*   ~~~~~~~~~~~~~~~~~~~~~~~~~~-{ TYPES }-~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
*   ~~~~~~~~~~~~~~~~~~~~~~~~~~-{ DATA }-~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
    DATA:
*          ls_layo TYPE lvs_s_layo,
          lt_fcat TYPE lvc_t_fcat,
          ls_variant TYPE disvariant.


    cd_appl = lcl_appl=>get_instance( ).
*    me->mt_out = cd_appl->get_data( ).
*
    FREE lt_fcat.
    lt_fcat = me->create_fcat_res_ing( ).

    IF cd_o_alv IS NOT BOUND.
      IF cd_o_con IS NOT BOUND.
        CREATE OBJECT cd_o_con
          EXPORTING
*            dynnr = c_dynnr
*            repid = sy-repid
            container_name = 'CC_ALV'
            .

      ENDIF.

      CREATE OBJECT cd_o_alv
        EXPORTING
          i_appl_events = 'X'
          i_parent      = cd_o_con.


*
      mt_out_resing[] = im_t_data[].

      DATA : ls_layo TYPE lvc_s_layo.

      ls_layo-sel_mode = 'A'.
      ls_layo-cwidth_opt = ''.


      ls_variant-report = sy-repid.
      ls_variant-variant = '/RES_ING'.

      cd_o_alv->set_table_for_first_display(
      EXPORTING
*         i_structure_name = 'ZING_REPS_OUTPUT'
        is_layout = ls_layo
        is_variant = ls_variant
        i_save = 'A'
     CHANGING
            it_fieldcatalog = lt_fcat
            it_outtab = mt_out_resing

       ).


    ENDIF.
  ENDMETHOD.                    "create_alv_RES_ING



  METHOD show_new.
    DATA: lt_txt TYPE TABLE OF textpool,
          ls_txt TYPE textpool.

    READ TEXTPOOL sy-repid INTO lt_txt LANGUAGE sy-langu.

    READ TABLE lt_txt INTO ls_txt WITH KEY id = 'R'.
    IF sy-subrc EQ 0.
      me->set_title( ls_txt-entry ).
    ENDIF.

    me->set_exit_enabled( iv_enabled = 'X' ).
    me->set_back_enabled( iv_enabled = 'X' ).
    me->set_cancel_enabled( iv_enabled = 'X' ).
    SET HANDLER me->handle_pai FOR me.


    me->create_alv( EXPORTING im_t_data = im_t_data ).

    me->show( ).
  ENDMETHOD.                    "show

*  METHOD show_new_iva.
*    DATA: lt_txt TYPE TABLE OF textpool,
*          ls_txt TYPE textpool.
*
*    READ TEXTPOOL sy-repid INTO lt_txt LANGUAGE sy-langu.
*
**    IF p_riva IS NOT INITIAL.
**      me->set_title( gtext2 ).
**    ENDIF.
*
*
*    me->set_exit_enabled( iv_enabled = 'X' ).
*    me->set_back_enabled( iv_enabled = 'X' ).
*    me->set_cancel_enabled( iv_enabled = 'X' ).
*    SET HANDLER me->handle_pai FOR me.
*
*
*    me->create_alv_iva( EXPORTING im_t_data = im_t_data ).
*
*
**    me->set_edit( space ).
**    RAISE EVENT evt_show.
*    me->show( ).
*
*    DATA: lv_fname TYPE rs38l_fnam.
*
*    CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
*      EXPORTING
*        formname                 = 'ZING_IVA'
**       VARIANT                  = ' '
**       DIRECT_CALL              = ' '
*     IMPORTING
*       fm_name                  = lv_fname
*     EXCEPTIONS
*       no_form                  = 1
*       no_function_module       = 2
*       OTHERS                   = 3
*              .
*    IF sy-subrc <> 0.
*      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*    ENDIF.
*
*    CALL FUNCTION lv_fname
*      EXPORTING
*        header           = 'mes año'
*        titulo           = gtext2
*        nom_soc          = gtext
*        periodo          = gtext3
*      TABLES
*        t_detalle        = im_t_data
*      EXCEPTIONS
*        formatting_error = 1
*        internal_error   = 2
*        send_error       = 3
*        user_canceled    = 4
*        OTHERS           = 5.
*
*    IF sy-subrc <> 0.
*
*      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*
*      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*
*    ENDIF.
*
*
*
*  ENDMETHOD.                    "show_new_IVA

*  METHOD show_rep_isr.
*    DATA: lt_txt TYPE TABLE OF textpool,
*          ls_txt TYPE textpool.
*
*    READ TEXTPOOL sy-repid INTO lt_txt LANGUAGE sy-langu.
*
**    IF p_risr IS NOT INITIAL.
**      me->set_title( gtext2 ).
**    ENDIF.
*
*
*    me->set_exit_enabled( iv_enabled = 'X' ).
*    me->set_back_enabled( iv_enabled = 'X' ).
*    me->set_cancel_enabled( iv_enabled = 'X' ).
*    SET HANDLER me->handle_pai FOR me.
*
*
*    me->create_alv_isr( EXPORTING im_t_data = im_t_data ).
*
*    me->show( ).
*
*    DATA: lv_fname TYPE rs38l_fnam.
*
*    CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
*      EXPORTING
*        formname                 = 'ZING_ISR'
**       VARIANT                  = ' '
**       DIRECT_CALL              = ' '
*     IMPORTING
*       fm_name                  = lv_fname
*     EXCEPTIONS
*       no_form                  = 1
*       no_function_module       = 2
*       OTHERS                   = 3
*              .
*    IF sy-subrc <> 0.
*      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*    ENDIF.
*
*    CALL FUNCTION lv_fname
*      EXPORTING
*        header           = 'mes año'
*        titulo           = gtext2
*        nom_soc          = gtext
*        periodo          = gtext3
*      TABLES
*        t_detalle        = im_t_data
*      EXCEPTIONS
*        formatting_error = 1
*        internal_error   = 2
*        send_error       = 3
*        user_canceled    = 4
*        OTHERS           = 5.
*
*    IF sy-subrc <> 0.
*
*      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*
*      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*
*    ENDIF.
*
*
*
*  ENDMETHOD.                    "show_REP_ISR

*  METHOD show_res_ing.
*    DATA: lt_txt TYPE TABLE OF textpool,
*          ls_txt TYPE textpool.
*
*    READ TEXTPOOL sy-repid INTO lt_txt LANGUAGE sy-langu.
*
**    READ TABLE lt_txt INTO ls_txt WITH KEY id = 'R'.
**    IF sy-subrc EQ 0.
**      me->set_title( ls_txt-entry ).
**    ENDIF.
*
**    IF p_risr IS NOT INITIAL.
**      me->set_title( gtext2 ).
**    ENDIF.
*
*
**    me->set_status( EXPORTING iv_status_key = 'STATUS2000'
**                              iv_status_program = sy-repid ).
*
*    me->set_exit_enabled( iv_enabled = 'X' ).
*    me->set_back_enabled( iv_enabled = 'X' ).
*    me->set_cancel_enabled( iv_enabled = 'X' ).
*    SET HANDLER me->handle_pai FOR me.
*
*
*    me->create_alv_res_ing( EXPORTING im_t_data = im_t_data ).
*
*
**    me->set_edit( space ).
**    RAISE EVENT evt_show.
*    me->show( ).
*
*    DATA: lv_fname TYPE rs38l_fnam.
*
*    CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
*      EXPORTING
*        formname                 = 'ZING_RESUMEN'
**       VARIANT                  = ' '
**       DIRECT_CALL              = ' '
*     IMPORTING
*       fm_name                  = lv_fname
*     EXCEPTIONS
*       no_form                  = 1
*       no_function_module       = 2
*       OTHERS                   = 3
*              .
*    IF sy-subrc <> 0.
*      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*    ENDIF.
*
*    CALL FUNCTION lv_fname
*      EXPORTING
*        header           = 'mes año'
*        titulo           = gtext2
*        nom_soc          = gtext
*        periodo          = gtext3
*      TABLES
*        t_detalle        = im_t_data
*      EXCEPTIONS
*        formatting_error = 1
*        internal_error   = 2
*        send_error       = 3
*        user_canceled    = 4
*        OTHERS           = 5.
*
*    IF sy-subrc <> 0.
*
*      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*
*      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*
*    ENDIF.
*
*
*
*  ENDMETHOD.                    "show_RES_ING

  METHOD handle_pai.
    "----------------------------------------------< handle_pai >--------------------------------------------------------------
*   @  Created by:    SM03427797
*   @  Description: Treated PAI events.
*   @  PARAMETER:
*   @
*   @  Created on:  21.06.2016 11:45
*   ~~~~~~~~~~~~~~~~~~~~~~~~~~-{ TYPES }-~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
*   ~~~~~~~~~~~~~~~~~~~~~~~~~~-{ DATA }-~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
    DATA: lv_string TYPE string.
*        ~~~~~~~~~~~~~~~~~~~~~~~~~~-{ DO }-~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
    CASE iv_function_code.
      WHEN me->gc_function_code_back.
        LEAVE TO SCREEN 0.
      WHEN me->gc_function_code_cancel.

        me->leave( ).

      WHEN me->gc_function_code_exit.

        me->leave( ).

      WHEN OTHERS.

        "do Nothing
    ENDCASE.
*        ~~~~~~~~~~~~~~~~~~~~~~~~~~-{ END METHOD }-~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*

  ENDMETHOD.                    "handle_pai

*********************************

  METHOD pbo_begin.
    super->pbo_begin( ).
*Do not paste code after the super->pbo_begin() call!!!!
  ENDMETHOD.                    "pbo_begin

  METHOD pai_end.
*Do not edit this Method!!!
    super->pai_end( ).
*Do not paste code after the super->pai_end() call!!!!
  ENDMETHOD.                    "pai_end


  METHOD pai_begin.
*Do not edit this Method!!!
    super->pai_begin( ).
*Do not paste code after the super->pai_end() call!!!!
  ENDMETHOD.                    "pai_begin
  METHOD pbo_end.
* PBO - END Processing
    super->pbo_end( ).
*Do not paste Code after the super->pbo_end() call
  ENDMETHOD.                    "pbo_end

  METHOD call_screen.
*Do not edit this method !!!!
    CALL SCREEN iv_dynpro_number.
  ENDMETHOD.                    "call_screen
  METHOD call_screen_starting_at.
*Do not edit this method !!!!
    CALL SCREEN iv_dynpro_number
    STARTING AT iv_xstart iv_ystart
    ENDING AT iv_xend iv_yend.
  ENDMETHOD.                    "call_screen_starting_at
ENDCLASS.                    "lcl_screen IMPLEMENTATION

*----------------------------------------------------------------------*
*       CLASS lcl_appl IMPLEMENTATION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS lcl_appl IMPLEMENTATION.


*
*  METHOD save_concil.
*    DELETE FROM ZINGRE_CONCIL2.
*
**    insert INTO  ZINGRE_CONCIL2 FROM im_t_data.
*    INSERT   ZINGRE_CONCIL2  FROM  TABLE  im_t_data ACCEPTING  DUPLICATE  KEYS .
*    COMMIT WORK AND WAIT.
*  ENDMETHOD.                    "save_concil


  METHOD get_instance.
    "----------------------------------------------< get_instance >--------------------------------------------------------------
*   @  Created by:    SM03427797
*   @  Description: Specifies an instance of the class lcl_appl.
*   @  PARAMETER:
*   @
*   @  Created on:  21.06.2016 14:58
*        ~~~~~~~~~~~~~~~~~~~~~~~~~~-{ DO }-~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
    IF cd_o_appl IS BOUND.
      re_appl = cd_o_appl.
    ELSE.
      CREATE OBJECT cd_o_appl.
      re_appl = cd_o_appl.
    ENDIF.
*        ~~~~~~~~~~~~~~~~~~~~~~~~~~-{ END METHOD }-~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
  ENDMETHOD.                    "lcl_appl

*  METHOD get_rep_iva.
*
*    DATA: lt_data TYPE TABLE OF ZINGRE_CONCIL2,
*          ls_data TYPE ZINGRE_CONCIL2,
*          lt_riva TYPE TABLE OF zing_reps_output,
*          ls_rtotales TYPE zing_reps_output,
*          lt_ing_iva TYPE TABLE OF zing_iva,
*          ls_ing_iva TYPE zing_iva,
*          lt_comp TYPE TABLE OF ZINGRE_CONCIL2,
*          ls_comp TYPE ZINGRE_CONCIL2
*.
***************MODIFICACIONES MICHAEL 20.08.2020 ini
**    DATA: ls_data2 like LINE OF RE_T_DATA.
***************MODIFICACIONES MICHAEL 20.08.2020 fin
*    FREE re_t_data.
*
*    SELECT *
*      INTO CORRESPONDING FIELDS OF TABLE lt_comp
*      FROM ZINGRE_CONCIL2
*      WHERE augbl IS NOT NULL.
*
*
*    SELECT *
*      INTO CORRESPONDING FIELDS OF TABLE lt_data
*      FROM ZINGRE_CONCIL2
*      WHERE anulado <> 'X'.
*
*
*    SELECT *
*      INTO CORRESPONDING FIELDS OF TABLE lt_ing_iva
*      FROM zing_iva
*      WHERE bukrs IN s_bukrs
*      ORDER BY concepto.
*
*    LOOP AT lt_data INTO ls_data WHERE hkont IS NOT INITIAL OR arktx = 'PAGO SIN FACTURAS RELACIONADAS'.
*
*      CLEAR ls_comp.
*      READ TABLE lt_comp INTO ls_comp WITH KEY bukrs = ls_data-bukrs
*                                                       belnr = ls_data-belnr
*                                                       gjahr = p_gjahr.
*
*      IF ( sy-subrc = 0 AND ls_comp-augbl IS NOT INITIAL ) OR
*          ( ls_data-hkont = '0000250020' OR ls_data-hkont = '0000250030' OR
*            ls_data-hkont = '0000250111' OR ls_data-hkont = '0000250112' OR
*            ls_data-hkont = '0000250113' OR ls_data-hkont = '0000250114' OR
*            ls_data-hkont = '0000250115' OR ls_data-hkont = '0000250116' OR
*            ls_data-hkont = '0000250117' )
*        OR ls_data-incluir_rep = 'X' . "Incluir en reportes de IVA aunque no tengan docto de compensación.
*
*        CLEAR ls_rtotales.
*        ls_rtotales-bukrs = ls_data-bukrs.
*        ls_rtotales-hkont = ls_data-hkont.
*        ls_rtotales-base  = ls_data-base.
*        ls_rtotales-iva   = ls_data-iva.
*
*        IF ls_data-hkont+0(5) = '00001' .
*          ls_rtotales-clasif = 'B'.
*        ELSE.
*          ls_rtotales-clasif = 'A'.
*        ENDIF.
*
*        IF ls_data-arktx <> 'PAGO SIN FACTURAS RELACIONADAS'.
*          CLEAR ls_ing_iva.
*          READ TABLE lt_ing_iva INTO ls_ing_iva WITH KEY bukrs = ls_data-bukrs
*                                                         hkont = ls_data-hkont.
*          IF sy-subrc = 0.
*            ls_rtotales-concepto = ls_ing_iva-concepto.
*          ELSE.
*            ls_rtotales-concepto = 'CUENTA SIN CONCEPTO'.
*          ENDIF.
*        ELSE.
*          ls_rtotales-concepto = 'PAGO SIN FACTURAS RELACIONADAS'.
*        ENDIF.
*
*        COLLECT ls_rtotales INTO re_t_data.
*      ENDIF.
*    ENDLOOP.
*
*    SORT re_t_data BY clasif bukrs concepto hkont.
*
*    CLEAR ls_ing_iva.
*****    agregar todas las cuentas de la tabla de cuentas aunque no tengan resultados
*    LOOP AT lt_ing_iva INTO ls_ing_iva.
*      CLEAR ls_rtotales.
*      READ TABLE re_t_data TRANSPORTING NO FIELDS WITH KEY bukrs = ls_ing_iva-bukrs
*                                                           hkont = ls_ing_iva-hkont.
*      IF sy-subrc <> 0.
*
*        ls_rtotales-bukrs = ls_ing_iva-bukrs.
*        ls_rtotales-hkont = ls_ing_iva-hkont.
*        ls_rtotales-concepto = ls_ing_iva-concepto.
*        IF ls_ing_iva-hkont+0(5) = '00001'  .
*          ls_rtotales-clasif = 'B'.
*        ELSE.
*          ls_rtotales-clasif = 'A'.
*        ENDIF.
**        ls_RTOTALES-clasif = 'A'.
*        APPEND ls_rtotales TO re_t_data.
*      ENDIF.
*    ENDLOOP.
*
*    DATA lv_concepto_ant TYPE text50.
*
*
*    FIELD-SYMBOLS <fs> TYPE zing_reps_output.
*    SORT re_t_data BY clasif bukrs concepto hkont.
*
***** sumar por concepto
*    FREE lt_riva.
*    CLEAR ls_rtotales.
*    LOOP AT re_t_data INTO ls_rtotales.
*      IF  ls_rtotales-concepto <> 'CUENTA SIN CONCEPTO'.
*        CLEAR ls_rtotales-hkont .
*      ENDIF.
*      COLLECT ls_rtotales INTO lt_riva.
*    ENDLOOP.
*    re_t_data[] = lt_riva[].
*****
*    SORT lt_ing_iva BY bukrs concepto hkont.
*    LOOP AT re_t_data ASSIGNING <fs>.
*      READ TABLE lt_ing_iva INTO ls_ing_iva WITH KEY bukrs = <fs>-bukrs
*                                                     concepto = <fs>-concepto.
*      IF sy-subrc = 0.
*        <fs>-hkont = ls_ing_iva-hkont.
*      ENDIF.
*    ENDLOOP.
*
*  ENDMETHOD.                    "get_rep_iva


*****   isr
*
*  METHOD get_rep_isr.
*
*    DATA: lt_data TYPE TABLE OF ZINGRE_CONCIL2,
*          ls_data TYPE ZINGRE_CONCIL2,
*          lt_riva TYPE TABLE OF zing_reps_output,
*          ls_rtotales TYPE zing_reps_output,
**          lt_ing_iva TYPE TABLE OF zing_iva,
**          ls_ing_iva TYPE zing_iva,
*          lt_comp TYPE TABLE OF ZINGRE_CONCIL2,
*          ls_comp TYPE ZINGRE_CONCIL2,
*          lt_ing_isr TYPE TABLE OF zing_isr, "Catálogo de cuentas ISR
*          ls_ing_isr TYPE zing_isr.
*
*    FREE re_t_data.
*
*    SELECT *
*      INTO CORRESPONDING FIELDS OF TABLE lt_comp
*     FROM ZINGRE_CONCIL2
*      WHERE augbl IS NOT NULL.
*
*    SELECT *
*      INTO CORRESPONDING FIELDS OF TABLE lt_data
*        FROM ZINGRE_CONCIL2
*        WHERE anulado <> 'X'.
*
*    SELECT *
*      INTO CORRESPONDING FIELDS OF TABLE lt_ing_isr
*      FROM zing_isr
*      WHERE bukrs IN s_bukrs
*      ORDER BY concepto.
*
*
*    LOOP AT lt_data INTO ls_data WHERE hkont IS NOT INITIAL OR arktx = 'PAGO SIN FACTURAS RELACIONADAS'.
*
*      CLEAR ls_comp.
*      READ TABLE lt_comp INTO ls_comp WITH KEY bukrs = ls_data-bukrs
*                                                       belnr = ls_data-belnr
*                                                       gjahr = p_gjahr.
*      IF ( sy-subrc = 0 AND ls_comp-augbl IS NOT INITIAL ) OR
*        ( ls_data-hkont = '0000250020' OR ls_data-hkont = '0000250030' OR
*          ls_data-hkont = '0000250111' OR ls_data-hkont = '0000250112' OR
*          ls_data-hkont = '0000250113' OR ls_data-hkont = '0000250114' OR
*          ls_data-hkont = '0000250115' OR ls_data-hkont = '0000250116' OR
*          ls_data-hkont = '0000250117' )
*        OR ls_data-incluir_rep = 'X' . "Incluir en reportes de IVA aunque no tengan docto de compensación
*
*        CLEAR ls_rtotales.
*        ls_rtotales-bukrs = ls_data-bukrs.
*        ls_rtotales-hkont = ls_data-hkont.
*        ls_rtotales-base  = ls_data-base.
*        ls_rtotales-iva   = ls_data-iva.
**        IF ls_data-INCLUIR_REP = 'X'.
**            ls_rtotales-clasif = 'B'.
**        ELSE.
**           ls_rtotales-clasif = 'A'.
**        ENDIF.
*        IF ls_data-hkont+0(5) = '00001'  .
*          ls_rtotales-clasif = 'B'.
*        ELSE.
*          ls_rtotales-clasif = 'A'.
*        ENDIF.
*
*        IF ls_data-arktx <> 'PAGO SIN FACTURAS RELACIONADAS'.
*          CLEAR ls_ing_isr.
*          READ TABLE lt_ing_isr INTO ls_ing_isr WITH KEY bukrs = ls_data-bukrs
*                                                         hkont = ls_data-hkont.
*          IF sy-subrc = 0.
*            ls_rtotales-concepto = ls_ing_isr-concepto.
*          ELSE.
*            ls_rtotales-concepto = 'CUENTA SIN CONCEPTO'.
*          ENDIF.
*        ELSE.
*          ls_rtotales-concepto = 'PAGO SIN FACTURAS RELACIONADAS'.
*        ENDIF.
*
*        COLLECT ls_rtotales INTO re_t_data.
*      ENDIF.
*    ENDLOOP.
*
*    SORT re_t_data BY clasif bukrs concepto hkont.
*
*    CLEAR ls_ing_isr.
*****    agregar todas las cuentas de la tabla de cuentas aunque no tengan resultados
*    LOOP AT lt_ing_isr INTO ls_ing_isr.
*      CLEAR ls_rtotales.
*      READ TABLE re_t_data TRANSPORTING NO FIELDS WITH KEY bukrs = ls_ing_isr-bukrs
*                                                           hkont = ls_ing_isr-hkont.
*      IF sy-subrc <> 0.
*
*        ls_rtotales-bukrs = ls_ing_isr-bukrs.
*        ls_rtotales-hkont = ls_ing_isr-hkont.
*        ls_rtotales-concepto = ls_ing_isr-concepto.
**        ls_RTOTALES-clasif = 'A'.
*        IF ls_ing_isr-hkont+0(5) = '00001' .
*          ls_rtotales-clasif = 'B'.
*        ELSE.
*          ls_rtotales-clasif = 'A'.
*        ENDIF.
*        APPEND ls_rtotales TO re_t_data.
*      ENDIF.
*    ENDLOOP.
*
*    DATA lv_concepto_ant TYPE text50.
*
*
*    FIELD-SYMBOLS <fs> TYPE zing_reps_output.
*    SORT re_t_data BY clasif bukrs concepto hkont.
*
***** sumar por concepto
*    FREE lt_riva.
*    CLEAR ls_rtotales.
*    LOOP AT re_t_data INTO ls_rtotales.
*      IF  ls_rtotales-concepto <> 'CUENTA SIN CONCEPTO'.
*        CLEAR ls_rtotales-hkont .
*      ENDIF.
*      COLLECT ls_rtotales INTO lt_riva.
*    ENDLOOP.
*    re_t_data[] = lt_riva[].
*****
*    SORT lt_ing_isr BY bukrs concepto hkont.
*    LOOP AT re_t_data ASSIGNING <fs>.
*      READ TABLE lt_ing_isr INTO ls_ing_isr WITH KEY bukrs = <fs>-bukrs
*                                                     concepto = <fs>-concepto.
*      IF sy-subrc = 0.
*        <fs>-hkont = ls_ing_isr-hkont.
*      ENDIF.
*    ENDLOOP.
*
*
*  ENDMETHOD.                    "get_rep_isr

*****  RES_ING

*  METHOD get_res_ing .
*
*    DATA: lt_data TYPE TABLE OF ZINGRE_CONCIL2,
*          ls_data TYPE ZINGRE_CONCIL2,
*          lt_riva TYPE TABLE OF zing_reps_output,
*          ls_rtotales TYPE zing_reps_output,
**          lt_ing_iva TYPE TABLE OF zing_iva,
**          ls_ing_iva TYPE zing_iva,
*          lt_comp TYPE TABLE OF ZINGRE_CONCIL2,
*          ls_comp TYPE ZINGRE_CONCIL2,
*          lt_ing_isr TYPE TABLE OF zing_isr, "Catálogo de cuentas ISR
*          ls_ing_isr TYPE zing_isr.
*
*    FREE re_t_data.
*
*    SELECT *
*      INTO CORRESPONDING FIELDS OF TABLE lt_comp
*     FROM ZINGRE_CONCIL2
*      WHERE augbl IS NOT NULL.
*
*    SELECT *
*      INTO CORRESPONDING FIELDS OF TABLE lt_data
*        FROM ZINGRE_CONCIL2
*        WHERE anulado <> 'X'.
**      ORDER BY bukrs hkont
*
*    SELECT *
*     INTO CORRESPONDING FIELDS OF TABLE lt_ing_isr
*     FROM zing_concentrado
*     WHERE bukrs IN s_bukrs.
*
*
*    LOOP AT lt_data INTO ls_data WHERE hkont IS NOT INITIAL OR arktx = 'PAGO SIN FACTURAS RELACIONADAS'.
*
*      CLEAR ls_comp.
*      READ TABLE lt_comp INTO ls_comp WITH KEY bukrs = ls_data-bukrs
*                                                       belnr = ls_data-belnr
*                                                       gjahr = p_gjahr.
*      IF ( sy-subrc = 0 AND ls_comp-augbl IS NOT INITIAL ) OR
*        ( ls_data-hkont = '0000250020' OR ls_data-hkont = '0000250030' OR
*          ls_data-hkont = '0000250111' OR ls_data-hkont = '0000250112' OR
*          ls_data-hkont = '0000250113' OR ls_data-hkont = '0000250114' OR
*          ls_data-hkont = '0000250115' OR ls_data-hkont = '0000250116' OR
*          ls_data-hkont = '0000250117' )
*        OR ls_data-incluir_rep = 'X' . "Incluir en reportes de IVA aunque no tengan docto de compensación
*
*        CLEAR ls_rtotales.
*        ls_rtotales-bukrs = ls_data-bukrs.
*        ls_rtotales-hkont = ls_data-hkont.
*        ls_rtotales-base  = ls_data-base.
*        ls_rtotales-iva   = ls_data-iva.
*        ls_rtotales-total   = ls_data-total.
**        IF ls_data-INCLUIR_REP = 'X'.
**            ls_rtotales-clasif = 'B'.
**        ELSE.
**           ls_rtotales-clasif = 'A'.
**        ENDIF.
*        IF ls_data-hkont+0(5) = '00001'  .
*          ls_rtotales-clasif = 'B'.
*        ELSE.
*          ls_rtotales-clasif = 'A'.
*        ENDIF.
*
*        IF ls_data-arktx <> 'PAGO SIN FACTURAS RELACIONADAS'.
*          CLEAR ls_ing_isr.
*          READ TABLE lt_ing_isr INTO ls_ing_isr WITH KEY bukrs = ls_data-bukrs
*                                                         hkont = ls_data-hkont.
*          IF sy-subrc = 0.
*            ls_rtotales-concepto = ls_ing_isr-concepto.
*          ELSE.
*            ls_rtotales-concepto = 'CUENTA SIN CONCEPTO'.
*          ENDIF.
*        ELSE.
*          ls_rtotales-concepto = 'PAGO SIN FACTURAS RELACIONADAS'.
*        ENDIF.
*
*        COLLECT ls_rtotales INTO re_t_data.
*      ENDIF.
*    ENDLOOP.
*
*    SORT re_t_data BY clasif bukrs concepto hkont.
*
*    CLEAR ls_ing_isr.
*****    agregar todas las cuentas de la tabla de cuentas aunque no tengan resultados
*    LOOP AT lt_ing_isr INTO ls_ing_isr.
*      CLEAR ls_rtotales.
*      READ TABLE re_t_data TRANSPORTING NO FIELDS WITH KEY bukrs = ls_ing_isr-bukrs
*                                                           hkont = ls_ing_isr-hkont.
*      IF sy-subrc <> 0.
*
*        ls_rtotales-bukrs = ls_ing_isr-bukrs.
*        ls_rtotales-hkont = ls_ing_isr-hkont.
*        ls_rtotales-concepto = ls_ing_isr-concepto.
**        ls_RTOTALES-clasif = 'A'.
*        IF ls_ing_isr-hkont+0(5) = '00001' .
*          ls_rtotales-clasif = 'B'.
*        ELSE.
*          ls_rtotales-clasif = 'A'.
*        ENDIF.
*        APPEND ls_rtotales TO re_t_data.
*      ENDIF.
*    ENDLOOP.
*
*    DATA lv_concepto_ant TYPE text50.
*
*
*    FIELD-SYMBOLS <fs> TYPE zing_reps_output.
*    SORT re_t_data BY clasif bukrs concepto hkont.
*
***** sumar por concepto
*    FREE lt_riva.
*    CLEAR ls_rtotales.
*    LOOP AT re_t_data INTO ls_rtotales.
*      IF  ls_rtotales-concepto <> 'CUENTA SIN CONCEPTO'.
*        CLEAR ls_rtotales-hkont .
*      ENDIF.
*      COLLECT ls_rtotales INTO lt_riva.
*    ENDLOOP.
*    re_t_data[] = lt_riva[].
*****
*    SORT lt_ing_isr BY bukrs concepto hkont.
*    LOOP AT re_t_data ASSIGNING <fs>.
*      READ TABLE lt_ing_isr INTO ls_ing_isr WITH KEY bukrs = <fs>-bukrs
*                                                     concepto = <fs>-concepto.
*      IF sy-subrc = 0.
*        <fs>-hkont = ls_ing_isr-hkont.
*      ENDIF.
*    ENDLOOP.
*
*
*  ENDMETHOD.                    "get_reS_ING



  METHOD get_data.
    "----------------------------------------------< get_instance >--------------------------------------------------------------
*   @  Created by:    SM03427797
*   @  Description: Get Data from DB
*   @  PARAMETER:
*   @
*   @  Created on:  21.06.2016 15:00
*        ~~~~~~~~~~~~~~~~~~~~~~~~~~-{ DATA }-~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
    DATA:
******** MODIFICACIONES MICHAEL tabla mara 10.09.2020
          lt_mara TYPE STANDARD TABLE OF mara,
          ls_mara TYPE mara,
          lt_codsat TYPE STANDARD TABLE OF zfi_tt_clavessat,
          ls_codsat TYPE zfi_tt_clavessat,
******** MODIFICACIONES MICHAEL tabla mara 10.09.2020
          lt_bseg TYPE STANDARD TABLE OF bseg,
          lt_bsegmaxi TYPE STANDARD TABLE OF bseg,
          ls_bseg TYPE bseg,
          ls_bseg3 TYPE bseg,
          ls_bseg_comp2 TYPE bseg,
          lt_bseg_comp2 TYPE TABLE OF bseg,
          lt_kna1 TYPE STANDARD TABLE OF kna1,
          ls_kna1 TYPE kna1,
          lt_bse_clr TYPE TABLE OF bse_clr,
          ls_bse_clr TYPE bse_clr,
          ls_bkpf TYPE bkpf,
          lt_bkpf2 TYPE TABLE OF bkpf,
          ls_bkpf2 TYPE bkpf,
*Z          gt_bkpff TYPE TABLE OF bkpf,
*Z          ls_bkpff TYPE bkpf,
          lt_vbrp TYPE TABLE OF vbrp,
          ls_vbrp TYPE vbrp,
          lt_bseg2 TYPE TABLE OF bseg,
          ls_bseg2 TYPE bseg,
          lt_bseg_iva TYPE TABLE OF bseg,
          ls_bseg_iva TYPE bseg,
          lt_skat TYPE TABLE OF skat,
          ls_skat TYPE skat,
          lt_bse_comp TYPE TABLE OF bse_clr,
          lt_bse_comp2 TYPE TABLE OF bse_clr,
          ls_bse_comp2 TYPE  bse_clr,
          ls_bse_comp TYPE bse_clr,
          lt_bkpf_comp TYPE TABLE OF bkpf,
          lt_bkpf_comp2 TYPE TABLE OF bkpf,
          ls_bkpf_comp TYPE bkpf,
          ls_bkpf_comp2 TYPE bkpf,
          "ls_bseg_tot TYPE tys_bseg_tot,
          "lt_bseg_tot TYPE TABLE OF tys_bseg_tot,
          "lt_bse_tot TYPE TABLE OF tys_bseg_tot,
          "ls_bse_tot TYPE tys_bseg_tot,
          "ls_bse_tot_s TYPE tys_bseg_tot,
          lt_lines TYPE TABLE OF tline,
          ls_line TYPE tline,
          lv_tdname TYPE tdobname,
*          ls_awkey TYPE ty_awkey,
          ls_out   TYPE ZINGRE_CONCIL2,
          ls_out3   TYPE ZINGRE_CONCIL2,
*          ls_out   TYPE ZINGRE_CONCIL2,
          lt_out_tmp TYPE TABLE OF  ZINGRE_CONCIL2,
          lt_out_tmp3 TYPE TABLE OF  ZINGRE_CONCIL2,
          lt_out_aj TYPE TABLE OF  ZINGRE_CONCIL2,
          ls_out2 TYPE ZINGRE_CONCIL2,
******* MODIFICACIONES MICHAEL SEP 2020 ini
          ls_oaux TYPE ZINGRE_CONCIL2,
********* MODIFICACIONES MICHAEL SEP 2020 FIN
          lv_count TYPE i,
          lv_index TYPE i,
          lv_diferencia TYPE dmbtr,
*          lv_name  TYPE string,
*          lv_lines TYPE i.
*          lt_before TYPE STANDARD TABLE OF ZFI_T_HSBC_BEN_R.
          lv_saknr TYPE saknr,
          lv_banco TYPE text50,
          lv_augbl TYPE augbl,
          lv_edo_cta TYPE dmbtr,
          lv_anulado TYPE c,
*IPA/ATB Mar2020 Concentrado
          tt_aux  Type STANDARD TABLE OF ZINGRE_CONCIL2,
****************** MODIFICACIONES MICHAEL CHAVEZ ZARATE GPORRES 15.07.2020 INICIO
*          lt_zuuid TYPE TABLE OF ZFI_TT_UUIDEGRE2,
*          ls_zuuid TYPE zFI_TT_UUIDEGRE2,

          lt_febko TYPE TABLE OF febko,
          ls_febko TYPE febko,

          lt_febep TYPE TABLE OF febep,
          ls_febep TYPE febep.


*          lt_ztest TYPE TABLE OF ZFI_TT_BANCOS,
*          ls_ztest TYPE ZFI_TT_BANCOS,
****************** MODIFICACIONES MICHAEL CHAVEZ ZARATE GPORRES 15.07.2020 FIN.

*************MODIFICACIONES MICHAEL 20.08.2020 ini
    DATA: ls_data2 like LINE OF RE_T_DATA.
*************MODIFICACIONES MICHAEL 20.08.2020 fin

Types:    Begin Of ty_regtran,
          belnr      Type belnr_d,
          End Of   ty_regtran.

Data:     w_kunnr    Type kunnr,
          w_stcd1    Type stcd1,
          w_name1    Type name1,
          w_id       Type THEAD-TDID,
          f_OtrProvision Type char1,
          R_Tab      Type match_result_tab,
          w_tab      Type match_result,
          w_pos      Type i,
          it_xml     Type STANDARD TABLE OF SMUM_XMLTB,
          w_xml      Type SMUM_XMLTB,
          w_pathxml  Type string,
          w_arktx    Type arktx,
          w_hkont    Type hkont,
          w_uuid     Type char40,
          w2_uuid    Type char40,
          w_formapp  Type char2,
          w2_formapp Type char2,
          w_metodop  Type char3,
          wsym_tabix Type sy-tabix,
          wsy_tabix  Type sy-tabix,
          wsy2_tabix Type sy-tabix,
          wsyf_tabix Type sy-tabix,
          w_doc      type belnr_d,
          w_docprov  type belnr_d,
          w_docpago  type belnr_d,
          w_full     type i,
          f_NoTransfer Type char1,
          a_abonos     Type wrbtr,
          a_cargos     Type wrbtr,
          t_regtran    Type STANDARD TABLE OF ty_regtran,
          s_regtran    Type                   ty_regtran,
          it_bse_clr_parci TYPE STANDARD TABLE OF BSE_CLR,
          wt_bse_clr_parci TYPE                   BSE_CLR,
          w_fechaini    type bkpf-budat,
          w_fechafin    type bkpf-budat,
          w_ImpPar      Type  dmbtr,
          w_iva4dec     Type  p length 16 decimals 4,
          w_str         Type  c length 20,
          wlen          Type  i,
          w_blart       Type  blart,
          w_stblg       Type  stblg,
          w_dmbtr       Type  dmbtr,
          w_ivadoc      Type  dmbtr,
          w_ivacal      Type  dmbtr,
          b_same        Type  c length 1,
          w_pagapl      Type  dmbtr,
          sw_onetime    Type  c length 1,
          b_ParOrig     Type  c length 1,
          w_line        Type  i.

Constants k_dospuntos Type char1  value ':'.

    "FIELD-SYMBOLS <fs>  TYPE  tys_bseg_tot.
*        ~~~~~~~~~~~~~~~~~~~~~~~~~~-{ DO }-~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*

    Clear re_t_data[].


**********
**************** SE VALIDA SI BKPF NO VIENE VACIA ****************************
******************* MODIFICACIONES MICHAEL AGO 2020 INICIO
          SELECT *
            INTO TABLE lt_febep
            FROM febep
            WHERE gjahr = '2023'."p_gjahr.
*            FOR ALL ENTRIES IN lt_bse_comp
*            WHERE belnr = lt_bse_comp-belnr
*              AND gjahr = p_gjahr.

            IF sy-subrc = 0.

              SELECT *
                INTO CORRESPONDING FIELDS OF TABLE lt_febko
                FROM febko
                FOR ALL ENTRIES IN lt_febep
                WHERE kukey = lt_febep-kukey.

            ENDIF.
******************* MODIFICACIONES MICHAEL AGO 2020 FIN
******** MODIFICACIONES MICHAEL tabla mara 10.09.2020
            SELECT *
              FROM mara
              INTO table lt_mara.

            SELECT *
              from zfi_tt_clavessat
              into table lt_codsat.
******** MODIFICACIONES MICHAEL tabla mara 10.09.2020
    IF gt_bkpf[] IS NOT INITIAL.

*Z      Clear: lt_bseg[], lt_bsegmaxi[],  lt_bse_comp[],    "lt_bsegpost[],
*Z             lt_kna1[], lt_bkpf_comp[], lt_bkpf2[],    lt_vbrp[],
*Z             lt_skat,   lt_bse_tot[],   lt_out_tmp[],  lt_bseg_tot[],
*Z             lt_bseg_iva[].
      Clear: lt_bseg[], lt_bsegmaxi[].

      SELECT *
          INTO CORRESPONDING FIELDS OF TABLE lt_bseg
          FROM bseg
          FOR ALL ENTRIES IN gt_bkpf
          WHERE bukrs = gt_bkpf-bukrs AND
                belnr = gt_bkpf-belnr AND
                gjahr = gt_bkpf-gjahr
*        and   koart = 'D'
          .
    ENDIF.

*IPA/ATB Para BUG "Evitar que mezcle DZs previos compensados en el DZ que liquida
    Loop At lt_bseg into ls_bseg.
      wsy_tabix = sy-tabix.
      Clear w_blart.
      IF ls_bseg-augbl is not initial.
         Select  Single   blart Into w_blart from BKPF
           Where bukrs =  ls_bseg-bukrs
             And belnr =  ls_bseg-augbl
             And gjahr =  ls_bseg-gjahr.
************ MODIFICACIONES MICHAEL CHAVEZ ZARATE AGO 2020 24.08.2020 INI
         If   w_blart =  'DZ'. " este if era el original
*           If   w_blart =  'DZ' or w_blart = 'AB'.
************ MODIFICACIONES MICHAEL CHAVEZ ZARATE AGO 2020 24.08.2020 FIN
           if ls_bseg-augbl = ls_bseg-belnr.
              Append ls_bseg To lt_bsegmaxi.
           else.
              If w_dmbtr <> ls_bseg-dmbtr.
                 Delete lt_bseg Index wsy_tabix.
              Endif.
           endif.
         Else.
            w_dmbtr = ls_bseg-dmbtr.
         EndIf.
      ENDIF.
    Endloop.

    IF lt_bseg[] IS NOT INITIAL.
      CLEAR lt_kna1[].
      SELECT *
        INTO CORRESPONDING FIELDS OF TABLE lt_kna1
        FROM kna1
        FOR ALL ENTRIES IN lt_bseg
        WHERE kunnr = lt_bseg-kunnr .

****        dOCTOS cOMPENSACIÓN

      SELECT *
        INTO CORRESPONDING FIELDS OF TABLE lt_bse_comp
        FROM bse_clr
        FOR ALL ENTRIES IN lt_bseg
        WHERE bukrs_clr = lt_bseg-bukrs AND
              belnr_clr = lt_bseg-augbl AND
              gjahr_clr = lt_bseg-gjahr.

      SELECT *
        INTO CORRESPONDING FIELDS OF TABLE lt_bkpf_comp
        FROM bkpf
        FOR ALL ENTRIES IN lt_bse_comp
        WHERE bukrs = lt_bse_comp-bukrs AND
              belnr = lt_bse_comp-belnr AND
              gjahr = lt_bse_comp-gjahr AND
              blart = 'ZA'.
    ENDIF.

    CLEAR lt_bse_clr[].
    IF gt_bkpf[] IS NOT INITIAL.
      SELECT *
        INTO CORRESPONDING FIELDS OF TABLE lt_bse_clr
        FROM bse_clr
        FOR ALL ENTRIES IN gt_bkpf
        WHERE bukrs_clr = gt_bkpf-bukrs AND
              belnr_clr = gt_bkpf-belnr AND
              gjahr_clr = gt_bkpf-gjahr.
    ENDIF.

*IPA/ATB Para BUG "Evitar que mezcle DZs previos compensados en el DZ que liquida
    Loop At lt_bse_clr into ls_bse_clr.
      wsy_tabix = sy-tabix.
      Clear w_blart.
      Select Single blart Into w_blart from BKPF
       Where bukrs = ls_bse_clr-bukrs
         And belnr = ls_bse_clr-belnr
         And gjahr = ls_bse_clr-gjahr.
      If  ( w_blart = 'DZ'
        And ls_bse_clr-belnr_clr <> ls_bse_clr-belnr )
      Or    w_blart = 'AB'.
         Delete lt_bse_clr Index wsy_tabix.
      endif.
    Endloop.

    IF lt_bse_clr[] IS NOT INITIAL.
      CLEAR lt_bkpf2[].
      SELECT *
        INTO CORRESPONDING FIELDS OF TABLE lt_bkpf2
        FROM bkpf
        FOR ALL ENTRIES IN lt_bse_clr
        WHERE bukrs = lt_bse_clr-bukrs AND
              belnr = lt_bse_clr-belnr AND
              gjahr = lt_bse_clr-gjahr.

      IF lt_bkpf2[] IS NOT INITIAL.
        CLEAR lt_vbrp[].
        SELECT *
          INTO CORRESPONDING FIELDS OF TABLE lt_vbrp
          FROM vbrp
          FOR ALL ENTRIES IN lt_bkpf2
          WHERE vbeln = lt_bkpf2-awkey+0(10).
      ENDIF.

      CLEAR lt_bseg2[].
      SELECT *
        INTO CORRESPONDING FIELDS OF TABLE lt_bseg2
        FROM bseg
        FOR ALL ENTRIES IN lt_bse_clr
        WHERE  bukrs = lt_bse_clr-bukrs AND
               belnr = lt_bse_clr-belnr AND
               gjahr = lt_bse_clr-gjahr AND
               ( hkont <> '0000167008' AND hkont <> '0000148001'  " ni de retencion
                                       And hkont <> '0000148004' )  ""Ret de IVA 6%
*        AND bschl = '50'
        .

      CLEAR lt_bseg_iva[].
      SELECT *
        INTO CORRESPONDING FIELDS OF TABLE lt_bseg_iva
        FROM bseg
        FOR ALL ENTRIES IN lt_bse_clr
        WHERE  bukrs = lt_bse_clr-bukrs AND
               belnr = lt_bse_clr-belnr AND
               gjahr = lt_bse_clr-gjahr AND
*              bschl = '50'.
               ( hkont = '0000167008' OR " cuenta de IVA
                 hkont = '0000148001' OR " cuenta de retencion
                 hkont = '0000148004' ). " cuenta de retencion 6%
    ENDIF.

    SELECT *
      INTO CORRESPONDING FIELDS OF TABLE lt_skat
      FROM skat
      WHERE spras = sy-langu AND
            ktopl = 'SA00'.



**********************************************************
**********************************************************
*(sumariza bse_clr) Hs

    LOOP AT lt_bse_clr INTO ls_bse_clr.

      ls_bse_tot-bukrs =  ls_bse_clr-bukrs_clr. "docto pago
      ls_bse_tot-belnr =  ls_bse_clr-belnr_clr. "docto pago
      ls_bse_tot-gjahr =  ls_bse_clr-gjahr_clr. "docto pago
      ls_bse_tot-koart =  ls_bse_clr-shkzg.
      IF ls_bse_clr-shkzg = 'H'.
        ls_bse_tot-total =  ls_bse_clr-dmbtr * -1.
        READ TABLE lt_bkpf2 INTO ls_bkpf2 WITH KEY bukrs = ls_bse_clr-bukrs "docto pagado "factura
                                                   belnr = ls_bse_clr-belnr
                                                   gjahr = ls_bse_clr-gjahr.
        IF sy-subrc = 0.
          IF   ls_bkpf2-blart = 'DG'  "si es nota de crédito es como factura

           Or  ls_bkpf2-blart = 'RP'  "IPA/ATB Ene2020   NCre avícola
           Or  ls_bkpf2-blart = 'DD'  "IPA/ATB Ene2020   Dev.deudor
           Or  ls_bkpf2-blart = 'RX'. "IPA/ATB Ene2020   NCre

            ls_bse_clr-shkzg = 'N'.
            ls_bse_tot-koart = 'N'.
            ls_bse_tot-total =  ls_bse_clr-dmbtr.
*                 ls_bse_clr-dmbtr = ls_bse_clr-dmbtr * -1.
            MODIFY lt_bse_clr FROM ls_bse_clr .
          ENDIF.
        ENDIF.

      ELSE.
        ls_bse_tot-total =  ls_bse_clr-dmbtr.
        IF ls_bse_clr-clrin = 2.
          ls_bse_tot-total = ls_bse_clr-wrbtr - ls_bse_clr-difhw.
        ENDIF.
      ENDIF.


      COLLECT ls_bse_tot INTO lt_bse_tot.

    ENDLOOP.



********************************************************************
***********************************************************************
***********************************************************************
*****         Base
    DATA: lv_nodocto TYPE i,
          lv_basetot TYPE dmbtr.
*    lv_nodocto = 2.*
    lv_basetot = 0.


*IPA/ATB Ene2020
*Identifica Docs.de ingreso (DZ/DK) que en realidad son TransferenciasBan
    Describe Table lt_bseg2 lines w_full.
    Clear: w_doc, t_regtran[].
    Loop At lt_bseg2 Into ls_bseg2.
      wsym_tabix = sy-tabix.
      If w_doc <> ls_bseg2-belnr.
         If wsym_tabix <> 1.
            if   f_NoTransfer is initial
             and a_abonos = a_cargos
             and a_abonos is not initial.
                 s_regtran-belnr = w_doc.
                 Append s_regtran To t_regtran.
            endif.
         EndIf.
         w_doc =  ls_bseg2-belnr.
         Clear: f_NoTransfer, a_cargos, a_abonos.
      EndIf.

      If ( ls_bseg2-hkont+0(7) <> '0000113'
       And ls_bseg2-hkont+0(7) <> '0000114' ).
           f_NoTransfer = 'X'.
      Else.
        if ls_bseg2-shkzg = 'H'.
           a_abonos = a_abonos + ls_bseg2-wrbtr.
        else.
           a_cargos = a_cargos + ls_bseg2-wrbtr.
        endif.
      EndIf.

      If wsym_tabix = w_full.
         if   f_NoTransfer is initial
          and a_abonos = a_cargos
          and a_abonos is not initial.
              s_regtran-belnr = w_doc.
              Append s_regtran To t_regtran.
         endif.
      EndIf.
    EndLoop.
    Sort t_regtran By belnr.
*IPA/ATB Ene2020
*Identifica Docs.de ingreso (DZ/DK) que en realidad son TransferenciasBan


    Clear w_kunnr.
    LOOP AT lt_bseg2 INTO ls_bseg2. " WHERE koart = 'S'.
*          WHERE
*                                             bukrs = ls_bse_clr-bukrs AND
*                                             belnr = ls_bse_clr-belnr AND
*                                             gjahr = ls_bse_clr-gjahr AND
*                                             bschl = '50' and "posisiones para calcular la base
*                                             hkont <> '167008' and " Que no sea cuenta de IVA
*                                             hkont <> '148001'. " ni de retencion
      CLEAR ls_out.

      AT NEW belnr.
        lv_nodocto = 1.
        lv_basetot = 0.

*IPA/ATB Ene2020
        Clear: f_OtrProvision, f_NoTransfer.
        Read Table t_regtran Into s_regtran
         With Key  belnr = ls_bseg2-belnr.
        If sy-subrc is not initial.
           f_NoTransfer = 'X'.
        EndIf.
      ENDAT.
*      ls_out-nivel = 3.
      ls_out-nodocto = lv_nodocto.
      ADD 1 TO lv_nodocto.
      ls_out-doc_prov = ls_bseg2-belnr.
***************MODIFICACION MICHAEL 10.09.2020 material SAT ini
      IF p_cocon = 'X'.
        ls_out-matnr = ''.
      ELSE.
        ls_out-matnr = ls_bseg2-matnr.
      ENDIF.

***************MODIFICACION MICHAEL 10.09.2020 material SAT fin
*      ls_out-gjahr_dp = ls_bseg2-
      ls_out-bukrs = ls_bseg2-bukrs.
      ls_out-gjahr = ls_bseg2-gjahr.
      ls_out-hkont = ls_bseg2-hkont.
      ls_out-koart = ls_bseg2-koart.
**************** VALUT**************
      ls_out-valut = ls_bseg2-valut.
******
******
*       CLEAR ls_bse_clr.
*       READ TABLE lt_bse_clr INTO ls_bse_clr WITH  KEY
*                               bukrs = ls_bseg2-bukrs
*                               belnr = ls_bseg2-belnr
*                               gjahr = ls_bseg2-gjahr.
*      IF sy-subrc = 0.
**          ls_out-bukrs = ls_bse_clr-bukrs_clr.
*          ls_out-belnr = ls_bse_clr-belnr_clr.
**          ls_out-gjahr = ls_bse_clr-gjahr_clr.
*      ENDIF.

****       BASE

*IPA/ATB Ene2020
*Documentos DD "provision" sin indicador de IVA
      IF  ls_bseg2-mwskz is initial.
          If    f_OtrProvision is initial.
            if ( ( ls_bseg2-hkont  = '0000100005'   "Cargo a Ventas Publico Gral.
              or   ls_bseg2-hkont  = '0000145000'   "Documentos por cobrar
              or   ls_bseg2-hkont  = '0000120003'   "Deudores Diversos
              or   ls_bseg2-hkont  = '0000148000'   "ISR a Favor!!!
              or   ls_bseg2-hkont  = '0000140000' ) "CLIENTES!!!(Por faltantes??!!)
            and    ls_bseg2-shkzg  = 'S' )
            Or     f_NoTransfer is initial.
                   f_OtrProvision  = 'X'.
            endif.
          Else.
            if ( ls_bseg2-hkont+0(7) <> '0000113'
             and ls_bseg2-hkont+0(7) <> '0000114' )
            Or   ls_bseg2-shkzg      <> 'H'.
                 Clear f_OtrProvision.
            endif.
          EndIf.
      ENDIF.
*IPA/ATB Ene2020

      IF   ( ls_bseg2-mwskz = 'B4'                  "16%    (Repercutido
         Or  ls_bseg2-mwskz = 'A0'                  "0%     (Repercutido
         Or  ls_bseg2-mwskz = 'V0'                  "0%     (Soportado       " Caso 9
         Or  ls_bseg2-mwskz = 'Z0' "IPA/ATB Ene2020 "Exento (Repercutido
         Or  ls_bseg2-mwskz = 'X3' "IPA/ATB Ene2020 "16%    (Soportado

         Or  ls_bseg2-mwskz = '**' "IPA/ATB Ene2020 "Dummy (Se incluye para evitar falso KUNNR

         Or  ls_bseg2-hkont = '0000250053'  " Caso que no pintaba facturas, sin ind impuestos

*ATB/IPA Abril2020 Reportan diferencias porque las facturas se generan de origen
*        SIN indicador de IVA solo en algunas posiciones (Tomé las cuentas de 'ventas' al 0%
         Or  ls_bseg2-hkont = '0000260100'
         Or  ls_bseg2-hkont = '0000260101'
         Or  ls_bseg2-hkont = '0000260002'
         Or  ls_bseg2-hkont = '0000260003'
         Or  ls_bseg2-hkont = '0000260008'
         Or  ls_bseg2-hkont = '0000260050'

*IPA/ATB Ene2020
         Or  f_OtrProvision  is not initial )

         AND
           ls_bseg2-hkont <> '0000167008'.

*IPA/ATB Ene2020
        If ls_bseg2-mwskz <> '**'.

           IF ls_bseg2-bschl = '50'.
             ls_out-base = ls_bseg2-dmbtr.
           ELSEIF ls_bseg2-bschl = '40'.
             ls_out-base = ls_bseg2-dmbtr * -1.
           ENDIF.

*IPA/ATB Ene2020
           If f_NoTransfer is not initial.
              lv_basetot =  ls_bseg2-dmbtr + lv_basetot.
           Else.
             if ls_bseg2-shkzg = 'S'.
                lv_basetot =  ls_bseg2-dmbtr + lv_basetot.
             endif.
           EndIf.

           ls_out-basetot  = lv_basetot .
           ls_out-mwskz = ls_bseg2-mwskz.

        EndIf.

*        CASE ls_bseg2-mwskz.
*          WHEN 'B4'.
*            ls_out-tasa = 16.
*          WHEN 'A0'.
*            ls_out-tasa = 0.
*          WHEN OTHERS.
*        ENDCASE.

*IPA/ATB Ene2020
        If   ls_bseg2-kunnr <> w_kunnr
         And ls_bseg2-kunnr is not initial.
             w_kunnr = ls_bseg2-kunnr.
             Clear: ls_kna1, w_stcd1, w_name1.
             Read Table lt_kna1 Into ls_kna1 With Key kunnr = w_kunnr.
             If sy-subrc is initial.
               w_stcd1 = ls_kna1-stcd1.
               w_name1 = ls_kna1-name1.
               REPLACE all OCCURRENCES OF '"' in w_name1 WITH ''.
             ENDIF.
        EndIf.
*IPA/ATB Ene2020

        IF  ls_bseg2-koart = 'S'  .

*IPA/ATB Ene2020
          ls_out-kunnr = w_kunnr.
          ls_out-stcd1 = w_stcd1.
          ls_out-name1 = w_name1.
*IPA/ATB Ene2020

*              APPEND ls_out to lt_out_tmp. "por cada dpcto clareado agrega el mismo renglon
          COLLECT ls_out INTO lt_out_tmp. "sumariza por cuenta
        ENDIF.
      ENDIF.

*
****      Calcular totales por factura
      MOVE-CORRESPONDING ls_bseg2 TO ls_bseg_tot.
      IF  ls_bseg2-koart = 'S'.
        IF ls_bseg2-bschl = '40'.
          ls_bseg_tot-total = ls_bseg2-wrbtr * -1."ls_bseg2-dmbtr * -1.
                  ELSE.
          ls_bseg_tot-total = ls_bseg2-wrbtr. "ls_bseg2-dmbtr.
        ENDIF.

        " preguntar cuando se busca en bse_clr la base es por el total del docto pagado?
        READ TABLE lt_bse_clr INTO ls_bse_clr WITH KEY  bukrs = ls_bseg2-bukrs
                                                          belnr = ls_bseg2-belnr
                                                          gjahr = ls_bseg2-gjahr .
        IF sy-subrc = 0.
          IF ls_bse_clr-clrin = '2'.
            ls_bseg_tot-total = ls_bse_clr-dmbtr - ls_bse_clr-difhw.
          ENDIF.
        ENDIF.
      ELSE.
        ls_bseg_tot-total = ls_bseg2-dmbtr.
      ENDIF.


***      Totales IVa

      IF ls_bseg2-mwskz = 'B4' AND  ls_bseg2-hkont = '0000167008'.
        ls_bseg_tot-iva = ls_bseg2-dmbtr.
      ENDIF.

******     IVA RETENIDO
      IF ls_bseg2-hkont = '0000148001'
      or ls_bseg2-hkont = '0000148004'.
        ls_bseg_tot-iva_ret =  ls_bseg2-dmbtr * -1 .
      ENDIF.

      COLLECT ls_bseg_tot INTO lt_bseg_tot.

    ENDLOOP.





*****
    SORT lt_out_tmp BY bukrs gjahr doc_prov ASCENDING nodocto DESCENDING .


    DATA: lv_iva_tot TYPE dmbtr,
          lv_factor TYPE zfactor," DECIMALS 7,
          lv_factor2 TYPE zfactor. "p DECIMALS 7.
    CLEAR lv_basetot.
    Clear: w_doc, w_ivadoc, w_ivacal.
    Describe Table lt_out_tmp Lines w_full.
    LOOP AT lt_out_tmp INTO ls_out.

      wsy_tabix = sy-tabix.

      lv_iva_tot = 0.
      LOOP AT lt_bseg_iva INTO ls_bseg_iva WHERE bukrs = ls_out-bukrs AND
                                                 belnr = ls_out-doc_prov AND
                                                 gjahr = ls_out-gjahr AND
                                                 hkont = '0000167008'.
        lv_iva_tot = lv_iva_tot + ls_bseg_iva-dmbtr.
      ENDLOOP.

*IPA/ATB BUG Diferencias de redondeo en calculo de IVA Abr2020
      IF w_doc <> ls_out-doc_prov.
         If w_ivadoc <> w_ivacal.
            wsy_tabix = wsy_tabix - 1.
            Read Table lt_out_tmp Into ls_out2 Index wsy_tabix.
            if sy-subrc is initial.
               ls_out2-iva = ls_out2-iva + ( w_ivadoc - w_ivacal ).
               Modify lt_out_tmp From ls_out2 Index wsy_tabix.
            endif.
         EndIf.
         w_doc = ls_out-doc_prov.
         w_ivadoc = lv_iva_tot.
         Clear w_ivacal.
      ENDIF.


      lv_basetot = ls_out-basetot.
      AT NEW doc_prov.
        lv_factor = lv_basetot.
      ENDAT.

      IF lv_factor IS NOT INITIAL OR lv_factor <> 0.
        ls_out-iva = lv_iva_tot. " * ls_out-base / lv_factor.
      ENDIF.

*IPA/ATB  Mar2020  BUG / calculo de IVA
      If      ls_out-iva is not initial
        And ( ls_out-MWSKZ = 'B4'
           Or ls_out-MWSKZ = 'X3' ).
        ls_out-tasa = '0.16'.

*IPA/ATB Abr2020 BUG / Trunca 'para evitar diferencias?'
        w_iva4dec = ls_out-base * ls_out-tasa.
        w_str = w_iva4dec.
        If w_iva4dec >= 0.
           w_pos = 2.
        Else.
           w_pos = 3.
        EndIf.
        wlen = strlen( w_str ) - w_pos.
        w_str = w_str+0(wlen).
        If w_iva4dec < 0.
           Concatenate w_str '-' Into w_str.
        EndIf.
        Condense w_str.
        ls_out-iva = w_str.
*        ls_out-iva = ls_out-base * ls_out-tasa.

        w_ivacal = w_ivacal + ls_out-iva.

      EndIf.


*IPA/ATB  Mar2020  BUG / calculo de Retencion ???? identificar tasa y aplicar!!!
*****      iva ret

      lv_iva_tot = 0.

      LOOP AT lt_bseg_iva INTO ls_bseg_iva WHERE bukrs = ls_out-bukrs AND
                                                 belnr = ls_out-doc_prov AND
                                                 gjahr = ls_out-gjahr AND
                                              (  hkont = '0000148001' or
                                                 hkont = '0000148004' ).
        lv_iva_tot = lv_iva_tot + ls_bseg_iva-dmbtr.
      ENDLOOP.

*      lv_basetot = ls_out-basetot.
*      at NEW doc_prov.
*        lv_factor = lv_basetot.
*      ENDAT.

      IF lv_factor IS NOT INITIAL OR lv_factor <> 0.
        ls_out-iva_ret = lv_iva_tot * -1. " * ls_out-base / lv_factor.
      ENDIF.


*      ls_out-total = ls_out-base + ls_out-iva + ls_out-iva_ret.


*****         busca uuid
      CLEAR lv_tdname.
      CLEAR ls_bkpf2.
      READ TABLE lt_bkpf2 INTO ls_bkpf2 WITH KEY bukrs = ls_out-bukrs
                                                 belnr = ls_out-doc_prov
                                                 gjahr = ls_out-gjahr.
      IF sy-subrc = 0.
*****   Cambio 2 Cliente
        ls_out-budat = ls_bkpf2-budat.
        ls_out-bldat = ls_bkpf2-bldat.
*****
        lv_tdname = ls_bkpf2-awkey.

*IPA/ATB Ene2020
        ls_out-blart_F = ls_bkpf2-blart.

        w_id = 'Z010'.
        CLEAR lt_lines[].
        CALL FUNCTION 'READ_TEXT'
          EXPORTING
*               CLIENT                        = SY-MANDT
            id                            = w_id
            language                      = sy-langu
            name                          = lv_tdname
            object                        = 'VBBK'
*               ARCHIVE_HANDLE                = 0
*               LOCAL_CAT                     = ' '
*             IMPORTING
*               HEADER                        =
*               OLD_LINE_COUNTER              =
          TABLES
            lines                         = lt_lines
         EXCEPTIONS
           id                            = 1
           language                      = 2
           name                          = 3
           not_found                     = 4
           object                        = 5
           reference_check               = 6
           wrong_access_to_archive       = 7
           OTHERS                        = 8.
       IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
       ELSE.
          CLEAR ls_line.
          READ TABLE lt_lines INTO ls_line INDEX 1.
          IF sy-subrc = 0.
            ls_out-uuid = ls_line+8(36).
            ls_out-fact_sd = ls_bkpf2-awkey.
          ENDIF.
       ENDIF.

        w_id = 'ZOIM'.
        CLEAR lt_lines[].
        CALL FUNCTION 'READ_TEXT'
          EXPORTING
*               CLIENT                        = SY-MANDT
            id                            = w_id
            language                      = sy-langu
            name                          = lv_tdname
            object                        = 'VBBK'
*               ARCHIVE_HANDLE                = 0
*               LOCAL_CAT                     = ' '
*             IMPORTING
*               HEADER                        =
*               OLD_LINE_COUNTER              =
          TABLES
            lines                         = lt_lines
         EXCEPTIONS
           id                            = 1
           language                      = 2
           name                          = 3
           not_found                     = 4
           object                        = 5
           reference_check               = 6
           wrong_access_to_archive       = 7
           OTHERS                        = 8.
        If sy-subrc is initial.
          CLEAR ls_line.
          READ TABLE lt_lines INTO ls_line INDEX 1.
          if sy-subrc = 0.
             Find All Occurrences Of k_dospuntos In ls_line
             Results  R_Tab.
             if R_Tab[] is not initial.
                Read Table R_Tab Into w_tab Index 2.
                If sy-subrc is initial.
                   w_pos = w_tab-offset + 4.
                   ls_out-formap  = ls_line+w_pos(2). "Doc.FactPagada
                   If ls_line+4(3) <> '3.3'.
                      Clear ls_out-formap.            "No es CFDI v 3.3
                   EndIf.
                endif.
             endif.
          endif.
          Loop At lt_lines Into ls_line.
            If     ls_line CS '|PUE|'.
                   ls_out-metodop = 'PUE'.
                   Exit.
            ElseIf ls_line CS '|PPD|'.
                   ls_out-metodop = 'PPD'.
                   Exit.
            EndIf.
          EndLoop.
        EndIf.

*IPA/ATB Ene2020

      ENDIF.

        CLEAR ls_vbrp.
        READ TABLE lt_vbrp INTO ls_vbrp WITH KEY vbeln = ls_bkpf2-awkey+0(10).
        IF sy-subrc = 0.
          ls_out-arktx = ls_vbrp-arktx.
        ENDIF.

*IPA/ATB BUG Diferencias de redondeo en calculo de IVA Abr2020
      If   wsy_tabix = w_full
       And w_ivadoc <> w_ivacal.
           ls_out-iva = ls_out-iva + ( w_ivadoc - w_ivacal ).
      EndIf.

*****
      MODIFY lt_out_tmp FROM ls_out.

    ENDLOOP.
*************************************
**************************************
*************************************    <
    DATA lv_ok TYPE i.
    DATA lv_total TYPE dmbtr.
    DATA lv_subtot TYPE dmbtr.
*    pagos
    LOOP AT gt_bkpf INTO ls_bkpf.

      CLEAR lv_saknr.
      CLEAR lv_banco.
      CLEAR lv_augbl.
      CLEAR lv_edo_cta.
      CLEAR lv_anulado.

*      Clear w_pagapl.

      CLEAR ls_bseg.
      lv_ok = 0.

      LOOP AT lt_bseg INTO ls_bseg WHERE   bukrs = ls_bkpf-bukrs AND
                                                 belnr = ls_bkpf-belnr AND
                                                 gjahr = ls_bkpf-gjahr AND
                                                 hkont+0(7) <> '0000114' AND hkont <> '0000113'.
        lv_ok = 1.

      ENDLOOP.
      IF lv_ok = 0.
        CONTINUE.
      ENDIF.

      CLEAR ls_out.
      MOVE-CORRESPONDING ls_bkpf TO ls_out.

      ls_out-nodocto = 1.
      ls_out-nivel = 1.

*IPA/ATB Ene2020
      ls_out-blart_P = ls_bkpf-blart.
*     ls_out-metodop = No se incluye leer desde ZREPMEN_SATP (Compl.Pago)
*          al revisar ningun registro de la tabla tiene valor en el campo
      ls_out-arktx = w_arktx.

      CLEAR ls_bseg.
      READ TABLE lt_bseg INTO ls_bseg WITH KEY   bukrs = ls_bkpf-bukrs
                                                 belnr = ls_bkpf-belnr
                                                 gjahr = ls_bkpf-gjahr
                                                 koart = 'D'.
      IF sy-subrc = 0.
        ls_out-kunnr = ls_bseg-kunnr.
        CLEAR ls_kna1.
        READ TABLE lt_kna1 INTO ls_kna1 WITH KEY   kunnr = ls_bseg-kunnr.
        IF sy-subrc = 0.
          ls_out-stcd1 = ls_kna1-stcd1.
          ls_out-name1 = ls_kna1-name1.
          REPLACE all OCCURRENCES OF '"' in ls_out-name1 WITH ''.
        ENDIF.
      ENDIF.

*****  TOTAL INGRESOS

      LOOP AT lt_bseg INTO ls_bseg WHERE bukrs = ls_bkpf-bukrs AND
                                         belnr = ls_bkpf-belnr AND
                                         gjahr = ls_bkpf-gjahr.

        IF ls_bseg-hkont+0(7) = '0000113' OR ls_bseg-hkont+0(7) = '0000114'.

*IPA/ATB Ene2020
          If f_NoTransfer is not initial.
             ls_out-tot_ingreso = ls_out-tot_ingreso + ls_bseg-dmbtr.
          Else.
             if ls_bseg-shkzg = 'S'.
                ls_out-tot_ingreso = ls_out-tot_ingreso + ls_bseg-dmbtr.
             endif.
          EndIf.

          ls_out-sgtxt       = ls_bseg-sgtxt.
          ls_out-saknr       = ls_bseg-hkont. "ls_bseg-saknr.
          ls_out-augdt       = ls_bseg-augdt.

***************** VALUT *************
          ls_out-valut       = ls_bseg-valut.
*****         BANCO
          READ TABLE lt_skat INTO ls_skat WITH  KEY saknr = ls_bseg-hkont. "saknr.
          IF sy-subrc = 0.
            ls_out-banco = ls_skat-txt50.
          ENDIF.


          LOOP AT lt_bse_comp INTO ls_bse_comp WHERE bukrs_clr = ls_bseg-bukrs AND
                                                  belnr_clr = ls_bseg-augbl AND
                                                  gjahr_clr = ls_bseg-gjahr.


            READ TABLE lt_bkpf_comp TRANSPORTING NO FIELDS WITH KEY bukrs = ls_bse_comp-bukrs
                                                           belnr = ls_bse_comp-belnr
                                                           gjahr = ls_bse_comp-gjahr.
            IF sy-subrc = 0.
              ls_out-augbl  = ls_bseg-augbl.
              ls_out-impte_edo_cta = ls_bse_comp-dmbtr.
              ls_out-doc_banco = ls_bse_comp-belnr.

            ENDIF.


          ENDLOOP.

        ENDIF.

      ENDLOOP.


*****  Moneda
      ls_out-moneda = ls_bkpf-waers.
      CLEAR ls_out-kursf.
      IF ls_bkpf-waers <> 'MXN'.
        ls_out-kursf = ls_bkpf-kursf.
*  ***************** MODIFICACIONES MICHAEL CHAVEZ ZARATE GPORRES 15.07.2020 INICIO
        ls_out-wwert = ls_bkpf-wwert.
*        ls_out-augdt = ls_bseg-augdt.
      ELSE.
        ls_out-wwert = ''.
*  ***************** MODIFICACIONES MICHAEL CHAVEZ ZARATE GPORRES 15.07.2020 FIN
      ENDIF.

******  BUDAT FECHA DE REGISTRO
*        ls_out-budat = ls_bkpf-budat.

*****  XBLNR forma de pago "verificado c/Enrique
      ls_out-xblnr = ls_bkpf-xblnr.

*****  USNAM USUARIO
      ls_out-usnam = ls_bkpf-usnam.

      IF ls_bkpf-stblg <> ''.
        ls_out-arktx = 'ANULADO'.
        ls_out-anulado = 'X'.
        lv_anulado = 'X'.
      ENDIF.
      lv_saknr = ls_out-saknr.
      lv_banco = ls_out-banco.
      lv_augbl = ls_out-augbl.
      lv_edo_cta = ls_out-impte_edo_cta.

*      lv_stblg   = ls_bkpf-stblg.
***************************** MODIFICACIONES MICHAEL JUL 2020 AJUSTE IMPTE _EDO INICIO

          READ table re_t_data INTO LS_Data2 WITH KEY BELNR = ls_out-belnr
                                                      IMPTE_EDO_CTA = ls_out-IMPTE_EDO_CTA.

          IF SY-SUBRC = 0.
            LS_OUT-IMPTE_EDO_CTA = 0.
            CLEAR LS_DATA2.
          ENDIF.
***************************** MODIFICACIONES MICHAEL JUL 2020 AJUSTE IMPTE _EDO FINI

************************** MODIFICACIONES MICHAEL AGO 2020 INICIO
              READ TABLE lt_febep INTO ls_febep WITH KEY belnr = ls_out-augbl
                                                         budat = ls_out-budat
                                                         gjahr = p_gjahr
                                                         kwbtr = ls_bse_comp-dmbtr.

              IF sy-subrc = 0.

                READ TABLE lt_febko INTO ls_febko WITH KEY kukey = ls_febep-kukey.

                IF sy-subrc = 0.

                  ls_out-SSBTR = ls_febko-ssbtr.
                  ls_out-ESBTR = ls_febko-ESBTR.

                ENDIF.

              ENDIF.

************************** MODIFICACIONES MICHAEL AGO 2020
      APPEND ls_out TO re_t_data.
***************************      <<<<
**************************
      lv_index = 0.
      lv_total = 0.
      LOOP AT lt_bse_clr INTO ls_bse_clr WHERE
                               bukrs_clr = ls_bkpf-bukrs AND
                               belnr_clr = ls_bkpf-belnr AND
                               gjahr_clr = ls_bkpf-gjahr.

        IF ( ls_bse_clr-shkzg = 'S' OR ls_bse_clr-shkzg = 'N' ).

******     start     cambio 19.04.2017 caso 3 1020861

          lv_count = 0.
          LOOP AT lt_out_tmp TRANSPORTING NO FIELDS  WHERE bukrs = ls_bse_clr-bukrs AND
                                                           doc_prov = ls_bse_clr-belnr AND
                                                           gjahr = ls_bse_clr-gjahr.
              lv_count = lv_count + 1.
          endloop.

******     end    cambio 19.04.2017 caso 3 1020861

*
*               ls_out-diferencias = ls_bse_comp-dmbtr - ls_out-tot_ingreso.

*      *** agrega facturas
          lv_nodocto = 0.
          CLEAR ls_out2.

          Describe Table re_t_data Lines w_line.
          w_line = w_line + 1.
          Clear lv_subtot.
          LOOP AT lt_out_tmp INTO ls_out2        WHERE bukrs = ls_bse_clr-bukrs AND
                                                      doc_prov = ls_bse_clr-belnr AND
                                                      gjahr = ls_bse_clr-gjahr.
*                   IF sy-subrc = 0.

            ls_out2-belnr = ls_bse_clr-belnr_clr.

*IPA/ATB Ene2020  (lineas comentarizadas)
********            Cambio 1 cliente
*****            ls_out2-stcd1 = ls_kna1-stcd1.
*****            ls_out2-name1 = ls_kna1-name1.
*****             REPLACE all OCCURRENCES OF '"' in ls_out2-name1 WITH ''.
********
*IPA/ATB Ene2020  (lineas comentarizadas)

***      Cambio 4 Cliente cuenta
            IF ls_bseg-kunnr+0(6) = '000030' AND ls_out2-hkont+0(5) = '00004' .
              ls_out2-hkont = '0000120000'.
            ENDIF.

***
            CLEAR ls_out2-tasa.
            CASE ls_out2-mwskz.
              WHEN 'B4'   Or  'X3'. "IPA/ATB Ene2020
                ls_out2-tasa = 16.
              WHEN 'A0'   Or  'V0'. "IPA/ATB Ene2020
                ls_out2-tasa = 0.
              WHEN OTHERS.
            ENDCASE.

*IPA/ATB Feb2020 Si la factura es liquidada pero tiene parcialidades previas
*Solo debe aparecer el importe compensado por el DZ que liquida
*Corrige BUG=aparecía el importe total de la factura
*Busca si existieron parcialidades previas no anuladas
            Clear:  w_ImpPar, b_ParOrig.
            IF ls_bse_clr-clrin is initial.
               Clear: it_bse_clr_parci[], b_same.
               Select * into corresponding fields of table it_bse_clr_parci
                 from BSE_CLR
                where bukrs_clr  = ls_bse_clr-bukrs
                  and gjahr_clr  = ls_bse_clr-gjahr
                  and bukrs      = ls_bse_clr-bukrs
                  and belnr      = ls_bse_clr-belnr
                  and gjahr      = ls_bse_clr-gjahr.
               If it_bse_clr_parci[] is not initial.
*Identifica y calcula parcialidades
                  Describe Table it_bse_clr_parci Lines w_full.
                  Sort   it_bse_clr_parci by clrin DESCENDING belnr_clr ASCENDING.
                  Loop At it_bse_clr_parci Into wt_bse_clr_parci.
                    wsy_tabix = sy-tabix.
                    Select Single blart stblg Into (w_blart, w_stblg)
                      From BKPF
                     Where bukrs = wt_bse_clr_parci-bukrs_clr
                       And belnr = wt_bse_clr_parci-belnr_clr
                       And gjahr = wt_bse_clr_parci-gjahr_clr.
                    If sy-subrc is initial.
                       if  w_blart <> 'DZ'
                        or w_stblg is not initial
                        or wt_bse_clr_parci-belnr_clr >= ls_bkpf-belnr.
                           Delete it_bse_clr_parci Index wsy_tabix.
                           if wt_bse_clr_parci-belnr_clr = ls_bkpf-belnr.
                              b_same = 'X'.
                           endif.
                           if w_stblg is not initial.
                              w_full = w_full - 1.    "No contar anulados
                           endif.
                       endif.
                    EndIf.
                  EndLoop.
                  If   it_bse_clr_parci[] is not initial.
                    Loop At it_bse_clr_parci Into wt_bse_clr_parci.
                        w_ImpPar = w_ImpPar + wt_bse_clr_parci-dmbtr - wt_bse_clr_parci-difhw.
                    EndLoop.
                    If w_ImpPar is not initial.
                       ls_bse_clr-difhw = w_ImpPar.
                       ls_bse_clr-clrin = '2'.  "La marca como Parcialidad (Pero NO es ORIGINAL)
                    endif.
***Se cancela esta parte, Cuando es liquidacion y no hay Parcialidades
***Si procede que aparezca el total de la Fact liquidada, habrá diferencia vs. Ingreso
***Pero si se deja esta parte solo aparece el 'Maximo' de bancos en todas las facturas!!
****Si no encuentra parcialidades, busca otros DZ aplicados en la liquidacion y los descuenta
***                  Else.
***                    If w_full = 1 and b_same is not initial.
***                       Read Table lt_bsegmaxi Into ls_bseg3
***                         With Key bukrs = ls_bse_clr-bukrs_clr
***                                  belnr = ls_bse_clr-belnr_clr
***                                  gjahr = ls_bse_clr-gjahr_clr
***                                  augbl = ls_bse_clr-belnr_clr.
***                       if sy-subrc is initial.
***                          ls_bse_clr-difhw = ls_bse_clr-dmbtr - ls_bseg3-dmbtr.
***                          if ls_bse_clr-difhw > 0.
***                             ls_bse_clr-clrin = '2'.  "La marca como Parcialidad (Pero NO es ORIGINAL)
***                          else.
****Cuando la diferencia es negativa, no procede, no le corresponde a la factura
***                             Clear ls_bse_clr-difhw.
***                          endif.
***                       endif.
***                    EndIf.
                  EndIf.
               EndIf.
            ELSE. "En pago parcial ORIGINAL solo aplica el Importe en Bancos
                       Read Table lt_bseg     Into ls_bseg3
                         With Key bukrs = ls_bse_clr-bukrs_clr
                                  belnr = ls_bse_clr-belnr_clr
                                  gjahr = ls_bse_clr-gjahr_clr
                                  koart = 'S'
                                  shkzg = 'S'.
                       If    sy-subrc is initial
                        And ( ls_bseg3-hkont+0(7) = '0000113'
                           or ls_bseg3-hkont+0(7) = '0000114' ).
                              w_ImpPar = ls_bseg3-dmbtr.
                              b_ParOrig = 'X'.   "Parcialidad ORIGINAL
                       EndIf.
            ENDIF.
*IPA/ATB Feb2020

*      ****                buscar en bse_clr base si esta parcialmente pagada
            Clear w_dmbtr.
            IF ls_bse_clr-clrin = '2'.
              lv_factor = 0.
              READ TABLE lt_bseg_tot INTO ls_bseg_tot WITH KEY bukrs = ls_bse_clr-bukrs
                                                           belnr = ls_bse_clr-belnr
                                                           gjahr = ls_bse_clr-gjahr
                                                           koart = 'D'.
              IF sy-subrc = 0.
*                                ls_out2-base = ls_bseg_tot-total.
                IF ls_bseg_tot-total <> 0.
                  lv_factor =  ( ls_bse_clr-dmbtr - ls_bse_clr-difhw ) / ls_bseg_tot-total.
*                  lv_factor =  ( ls_bse_clr-dmbtr - ls_bse_clr-difhw - w_pagapl ) / ls_bseg_tot-total.

*IPA/ATB En parcialidades ORIGINALES el maximo a aplicar es el Importe en Bancos.
                  w_dmbtr = ls_bse_clr-dmbtr - ls_bse_clr-difhw.
                  If   w_dmbtr > w_ImpPar
                   And b_ParOrig is not initial.
                       lv_factor =  ls_out2-base / ls_bseg_tot-total.
                       lv_factor =  ( lv_factor * w_ImpPar ) / ls_bseg_tot-total.
                       ls_out2-base = lv_factor * ls_bseg_tot-total.
                  Else.
                       ls_out2-base = lv_factor * ls_out2-base.
                  EndIf.

****                Cambio 3 Cliente no calculaba bien el iva proporcional
*IPA/ATB Abr2020 BUG / Trunca por diferencias
                  w_iva4dec = lv_factor * ls_out2-iva.
                  w_str = w_iva4dec.
                  If w_iva4dec >= 0.
                     w_pos = 2.
                  Else.
                     w_pos = 3.
                  EndIf.
                  wlen = strlen( w_str ) - w_pos.
                  w_str = w_str+0(wlen).
                  If w_iva4dec < 0.
                     Concatenate w_str '-' Into w_str.
                  EndIf.
                  Condense w_str.
                  ls_out2-iva = w_str.
*                  ls_out2-iva = lv_factor * ls_out2-iva.

                  w_iva4dec = lv_factor * ls_out2-iva_ret.
                  w_str = w_iva4dec.
                  If w_iva4dec >= 0.
                     w_pos = 2.
                  Else.
                     w_pos = 3.
                  EndIf.
                  wlen = strlen( w_str ) - w_pos.
                  w_str = w_str+0(wlen).
                  If w_iva4dec < 0.
                     Concatenate w_str '-' Into w_str.
                  EndIf.
                  Condense w_str.
                  ls_out2-iva_ret = w_str.
*                  ls_out2-iva_ret = lv_factor * ls_out2-iva_ret.
                ENDIF.
              ENDIF.

            ELSE.
              w_dmbtr = ls_bse_clr-dmbtr - ls_bse_clr-difhw.
            ENDIF.


*      ****************************************************************************************
*      *************************************** Caso 2 y Caso 3
*      ***                si existen posiciones H en el docto de pago recalcular

*IPA/ATB Solo entra a recalculo cuando no hay parcialidades previas
*Cuando hay parcilidades previas el calculo ya esta bien resuelto
       If   w_ImpPar is initial.

            lv_factor2 = 0.
            CLEAR ls_bse_tot.
            READ TABLE lt_bse_tot INTO ls_bse_tot WITH KEY bukrs = ls_bse_clr-bukrs_clr
                                                             belnr = ls_bse_clr-belnr_clr
                                                             gjahr = ls_bse_clr-gjahr_clr.
*                                                                 koart = 'H'.
            IF sy-subrc = 0 AND ls_bse_tot-koart = 'H'.

*      ***            Caso 9
*      ***            Pero si la H es otra factura - osea nota de credito no aplica
*
*                   READ TABLE lt_bkpf2 INTO ls_bkpf2 WITH KEY bukrs = ls_out2-bukrs
*                                                       belnr = ls_out2-doc_prov
*                                                       gjahr = ls_out2-gjahr
*                                                       BLART = 'DG'.
*                   IF sy-subrc <> 0.

*      ****
              CLEAR ls_bse_tot_s.
              READ TABLE lt_bse_tot INTO ls_bse_tot_s WITH KEY bukrs = ls_bse_clr-bukrs_clr
                                                              belnr = ls_bse_clr-belnr_clr
                                                              gjahr = ls_bse_clr-gjahr_clr
                                                              koart = 'S' .
              IF sy-subrc = 0 AND ls_bse_tot_s-total <> 0."ls_out2-base <> 0.
                lv_diferencia = 0.

                lv_diferencia = ls_bse_tot_s-total - ( ls_bse_tot-total * -1 ). "posiciones S - posiciones H en positivo

                IF lv_diferencia < 0.
*                  Importe de pago / Ss
                  lv_factor2 = ls_out-tot_ingreso / ( ls_bse_tot_s-total  ).
                ELSE.
*                    si la diferencia es positiva pero menor al pago.
                  IF lv_diferencia < ls_out-tot_ingreso.
                    lv_factor2 = ls_out-tot_ingreso / ( ls_bse_tot_s-total ).
                  ELSE.
                    lv_factor2 = ( ls_bse_tot-total / ls_bse_tot_s-total ) + 1. "ls_out2-base ) + 1.
                  ENDIF.
                ENDIF.
**************************************************************
*****        start cambio 19.04.2017 caso3 1020861
*                ls_out2-base = lv_factor2 * ls_out2-base.
***                Cambio 3 Cliente no calculaba bien el iva proporcional
*                ls_out2-iva = lv_factor2 * ls_out2-iva.
*                ls_out2-iva_ret = lv_factor2 * ls_out2-iva_ret.
                IF lv_count > 1.
                        ls_out2-base = lv_factor2 * ls_out2-base.
***                Cambio 3 Cliente no calculaba bien el iva proporcional
                        w_iva4dec = lv_factor2 * ls_out2-iva.
                        w_str = w_iva4dec.
                        If w_iva4dec >= 0.
                           w_pos = 2.
                        Else.
                           w_pos = 3.
                        EndIf.
                        wlen = strlen( w_str ) - w_pos.
                        w_str = w_str+0(wlen).
                        If w_iva4dec < 0.
                           Concatenate w_str '-' Into w_str.
                        EndIf.
                        Condense w_str.
                        ls_out2-iva = w_str.
*                        ls_out2-iva = lv_factor2 * ls_out2-iva.

                        w_iva4dec = lv_factor2 * ls_out2-iva_ret.
                        w_str = w_iva4dec.
                        If w_iva4dec >= 0.
                           w_pos = 2.
                        Else.
                           w_pos = 3.
                        EndIf.
                        wlen = strlen( w_str ) - w_pos.
                        w_str = w_str+0(wlen).
                        If w_iva4dec < 0.
                           Concatenate w_str '-' Into w_str.
                        EndIf.
                        Condense w_str.
                        ls_out2-iva_ret = w_str.
*                        ls_out2-iva_ret = lv_factor2 * ls_out2-iva_ret.

                ENDIF.
*****        end cambio 19.04.2017 caso3 1020861
**************************************************************
*****                <
              ENDIF.

*
            ENDIF.

       EndIf.

            ls_out2-total = ls_out2-base + ls_out2-iva + ls_out2-iva_ret.


            ls_out2-nivel = 2.
            ADD 1 TO lv_nodocto.
            ls_out2-nodocto = lv_nodocto.
*            ls_out2-augbl = ls_out-augbl.

*************************
*            Cambio 5 replicar datos cuenta banco y edo cta
*************************
            ls_out2-saknr = lv_saknr.
            ls_out2-banco = lv_banco.
            ls_out2-augbl = lv_augbl.
            ls_out2-impte_edo_cta = lv_edo_cta.
            IF lv_anulado = 'X'.
              ls_out2-arktx = 'ANULADO'.
              ls_out2-anulado = 'X'.
            ENDIF.
*******************************
***************MODIFICACION MICHAEL 10.09.2020 material SAT ini
      IF ls_out2-matnr EQ SPACE.
        ls_out2-matnr = ls_bseg2-matnr.

        READ TABLE lt_mara INTO ls_mara WITH KEY matnr = ls_bseg2-matnr.

        IF sy-subrc = 0.

          ls_out2-cvesat = ls_mara-bismt.

          READ TABLE lt_codsat INTO ls_codsat WITH KEY cvesat = ls_out2-cvesat.

          IF sy-subrc = 0.

            ls_out2-descsat = ls_codsat-descsat.

          ENDIF.

        ENDIF.
      ELSE.
        READ TABLE lt_mara INTO ls_mara WITH KEY matnr = ls_out2-matnr.

        IF sy-subrc = 0.

          ls_out2-cvesat = ls_mara-bismt.

          READ TABLE lt_codsat INTO ls_codsat WITH KEY cvesat = ls_out2-cvesat.

          IF sy-subrc = 0.

            ls_out2-descsat = ls_codsat-descsat.

          ENDIF.

        ENDIF.



      ENDIF.

      READ TABLE lt_mara INTO ls_mara WITH KEY matnr = ls_out2-matnr.

        IF sy-subrc = 0.

          ls_out2-cvesat = ls_mara-bismt.

          READ TABLE lt_codsat INTO ls_codsat WITH KEY cvesat = ls_out2-cvesat.

          IF sy-subrc = 0.

            ls_out2-descsat = ls_codsat-descsat.

          ENDIF.

        ENDIF.

***************MODIFICACION MICHAEL 10.09.2020 material SAT fin
***************************** MODIFICACIONES MICHAEL JUL 2020 AJUSTE IMPTE _EDO INICIO

          READ table re_t_data INTO LS_Data2 WITH KEY BELNR = ls_out2-belnr
                                                      IMPTE_EDO_CTA = ls_out2-IMPTE_EDO_CTA.

          IF SY-SUBRC = 0.
            LS_OUT2-IMPTE_EDO_CTA = 0.
            CLEAR LS_DATA2.
          ENDIF.
***************************** MODIFICACIONES MICHAEL JUL 2020 AJUSTE IMPTE _EDO FINI

***************************** MODIFICACIONES MICHAEL SEP 2020 AJUSTE nomina INICIO

        IF LS_OUT-BUKRS(2) = 'SA'.

          APPEND ls_out2 TO re_t_data.

        ELSE.

          READ TABLE re_t_data INTO ls_oaux WITH KEY belnr = ls_out2-belnr
                                                     doc_prov = ls_out2-doc_prov.

          IF sy-subrc = 0.

*            if ls_bseg2-mwskz = 'B4'.
             ls_out2-nom_ret = ls_out2-base.
*            ENDIF.

             ls_out2-total = ls_out2-base + ls_out2-iva + ls_out2-iva_ret + ls_out2-nom_ret.

              MODIFY re_t_data FROM ls_out2 TRANSPORTING nom_ret WHERE belnr = ls_out2-belnr
                                                                   AND doc_prov = ls_out2-doc_prov.

              MODIFY re_t_data FROM ls_out2 TRANSPORTING total WHERE belnr = ls_out2-belnr
                                                                   AND doc_prov = ls_out2-doc_prov.

          ELSE.

             APPEND ls_out2 TO re_t_data.

          ENDIF.

        ENDIF.


***************************** MODIFICACIONES MICHAEL SEP 2020 AJUSTE nomina FINI
*            APPEND ls_out2 TO re_t_data. "Este iba solo MICHAEL MODIFICACIONES NOMINA


            lv_total  = lv_total  + ls_out2-total.
            lv_subtot = lv_subtot + ls_out2-total.
*                   ENDIF.
          ENDLOOP.


*IPA/ATB Redondeo en Base y Total
          If   w_dmbtr > w_ImpPar
           And b_ParOrig is not initial.
               w_dmbtr = w_ImpPar.
          EndIf.
          If   lv_total  is not initial
           And lv_subtot is not initial
           And w_dmbtr <> abs( lv_subtot ).
               w_dmbtr = w_dmbtr - abs( lv_subtot ).
               Read Table re_t_data Into ls_out2 Index w_line.
               if sy-subrc is initial.
                  ls_out2-base  = ls_out2-base + w_dmbtr.
"MODIFICACIONES MICHAEL SEP 2020 01.09.2020 INI
                  IF ls_out2-nom_ret NE 0.
                    ls_out2-total = ls_out2-base + ls_out2-iva + ls_out2-iva_ret + LS_OUT2-NOM_RET.
                  ELSE.
                    ls_out2-total = ls_out2-base + ls_out2-iva + ls_out2-iva_ret.
                  ENDIF.
"MODIFICACIONES MICHAEL SEP 2020 01.09.2020 FIN
                  Modify re_t_data From ls_out2 Index w_line.
               endif.
          EndIf.

******** caso cuenta 120004  27.04.2017
          if LS_BSE_CLR-KOART = 'D'.
                clear ls_bseg3.
                read table lt_bseg2 into ls_bseg3 with key bukrs =  LS_BSE_CLR-BUKRS
                                                          belnr =  LS_BSE_CLR-belnr
                                                          gjahr =  LS_BSE_CLR-gjahr
                                                          buzei =  LS_BSE_CLR-buzei.
                IF sy-subrc = 0 and ls_bseg3-hkont = '0000120004'.
                  clear ls_out2.
                    ls_out2-bukrs = ls_bkpf-bukrs.
                    ls_out2-belnr = ls_bkpf-belnr.
                    ls_out2-gjahr = ls_bkpf-gjahr.
                    ls_out2-DOC_PROV = ls_bseg3-belnr.
                    ls_out2-base = ls_bseg3-dmbtr.
                    ls_out2-total = ls_bseg3-dmbtr.
                    ls_out2-hkont = '0000120004'.

***************MODIFICACION MICHAEL 10.09.2020 material SAT ini
                    ls_out2-matnr = ls_bseg3-matnr.
***************MODIFICACION MICHAEL 10.09.2020 material SAT fin
*************************
*            Cambio 5 replicar datos cuenta banco y edo cta
*************************
                      ls_out2-nivel = 2.
                      ADD 1 TO lv_nodocto.
                      ls_out2-nodocto = lv_nodocto.

                      ls_out2-saknr = lv_saknr.
                      ls_out2-banco = lv_banco.
                      ls_out2-augbl = lv_augbl.
                      ls_out2-impte_edo_cta = lv_edo_cta.
                      IF lv_anulado = 'X'.
                        ls_out2-arktx = 'ANULADO'.
                        ls_out2-anulado = 'X'.
                      ENDIF.
*          ******************************
***************************** MODIFICACIONES MICHAEL JUL 2020 AJUSTE IMPTE _EDO INICIO

          READ table re_t_data INTO LS_Data2 WITH KEY BELNR = ls_out2-belnr
                                                      IMPTE_EDO_CTA = ls_out2-IMPTE_EDO_CTA.

          IF SY-SUBRC = 0.
            LS_OUT2-IMPTE_EDO_CTA = 0.
            CLEAR LS_DATA2.
          ENDIF.
***************************** MODIFICACIONES MICHAEL JUL 2020 AJUSTE IMPTE _EDO FINI
                      APPEND ls_out2 TO re_t_data.
*NIVEL
*NODOCTO
                ENDIF.
          endif.

*ls_bseg-bukrs = sa18
*ls_bseg-belnr = 0000000001
*ls_bseg-gjahr = 2015
*ls_bseg- dmbtr = 7500

******** fin caso cuenta 120004  27.04.2017


        ELSE. "" Para H' sin S

*******
          CLEAR ls_bse_tot.
          READ TABLE lt_bse_tot INTO ls_bse_tot WITH KEY bukrs = ls_bse_clr-bukrs_clr
                                                           belnr = ls_bse_clr-belnr_clr
                                                           gjahr = ls_bse_clr-gjahr_clr
                                                           koart = 'S'.
          IF sy-subrc <> 0.
          ENDIF.
****** start add caso bschl = 17 20.04.2017
              CLEAR ls_bseg2.
              read table lt_bseg2 into ls_bseg2 with key bukrs = ls_bse_clr-bukrs
                                                         belnr = ls_bse_clr-belnr
                                                         gjahr = ls_bse_clr-gjahr
                                                         bschl = '17'.
               if sy-subrc = 0.
                 clear ls_out2.
                 MOVE-CORRESPONDING ls_out to ls_out2.
                 clear ls_out2-monat.
                 clear ls_out2-cpudt.
                 CLEAR ls_out2-kunnr.
                 CLEAR ls_out2-moneda.
                 CLEAR ls_out2-xblnr.
                 CLEAR ls_out2-SGTXT.
                 CLEAR ls_out2-usnam.
                 CLEAR ls_out2-usnam.
                 ls_out2-base = ls_bseg2-dmbtr.
                 ls_out2-total = ls_bseg2-dmbtr.
***************************** MODIFICACIONES MICHAEL JUL 2020 AJUSTE IMPTE _EDO INICIO

          READ table re_t_data INTO LS_Data2 WITH KEY BELNR = ls_out2-belnr
                                                      IMPTE_EDO_CTA = ls_out2-IMPTE_EDO_CTA.

          IF SY-SUBRC = 0.
            LS_OUT2-IMPTE_EDO_CTA = 0.
            CLEAR LS_DATA2.
          ENDIF.
***************************** MODIFICACIONES MICHAEL JUL 2020 AJUSTE IMPTE _EDO FINI
                 APPEND ls_out2 TO re_t_data.

                 loop at LT_BSE_TOT assigning <fs> where  bukrs = ls_bse_clr-bukrs_clr and
                                                          belnr = ls_bse_clr-belnr_clr and
                                                          gjahr = ls_bse_clr-gjahr_clr and
                                                          koart = 'S'.
                        <fs>-total = <fs>-total - ls_bseg2-dmbtr.
                  endloop.
               endif.

        ENDIF.
      ENDLOOP.



    ENDLOOP.


*Z    Clear lt_out_aj[].
    LOOP AT re_t_data INTO ls_out2.
      CLEAR ls_out.
      ls_out-belnr = ls_out2-belnr.
      ls_out-bukrs = ls_out2-bukrs.
      ls_out-anulado = ls_out2-anulado.
*      ls_out-total = ls_out2-total.
      ls_out-tot_ingreso = ls_out2-tot_ingreso - ls_out2-total.

*****        buscar para el ajuste la primera cuenta S
**        CLEAR ls_bseg2.
**        READ TABLE lt_bseg2 INTO ls_bseg2 WITH  KEY  bukrs = ls_out2-bukrs
**                                                    belnr = ls_out2-doc_prov
**                                                    gjahr = ls_out2-gjahr
***                                                    bukrs = ls_bse_clr-bukrs
***                                                   doc_prov = ls_bse_clr-belnr
***                                                   gjahr = ls_bse_clr-gjahr
**                                                   koart = 'S'.
**       IF sy-subrc = 0.
*          ls_out-hkont = ls_bseg2-hkont.
**       ENDIF.
*      IF  ls_out-tot_ingreso  <> 0.
      COLLECT ls_out INTO lt_out_aj.
*      ENDIF.
    ENDLOOP.

    DATA: lv_d TYPE c,
          lv_tot TYPE dmbtr.

    lt_out_tmp3[] = re_t_data[].
    LOOP AT lt_out_aj INTO ls_out WHERE tot_ingreso <> 0.
      CLEAR ls_out2.

      ls_out2-belnr = ls_out-belnr.
      ls_out2-bukrs = ls_out-bukrs.
      ls_out2-gjahr = p_gjahr.

*****      Buscar contrapartidas caso 6
      CLEAR lv_tot.
      CLEAR lv_d.
*      busca contrapartidas D con cuenta 000030 de clientes
      LOOP AT lt_bseg INTO ls_bseg WHERE bukrs = ls_out-bukrs AND
                                                belnr = ls_out-belnr AND
                                                gjahr = p_gjahr AND
                                                koart = 'D' AND
                                                kunnr+0(6) = '000030'.
        IF ls_bseg-SHKZG = 'H'.
          lv_tot = ls_bseg-dmbtr  + lv_tot.
        ELSE.
          lv_tot = ( ls_bseg-dmbtr * -1 ) + lv_tot.
        ENDIF.
        lv_d = 'X'.
      ENDLOOP.

      IF  lv_d = 'X'. " entra en caso 6
        ls_out2-hkont = ls_bseg-hkont.
        ls_out2-base = lv_tot.
        ls_out2-total = lv_tot.
        ls_out2-uuid    = ''.
*        ls_out2-kunnr = ls_bseg-kunnr.
*        ls_out2-doc_prov = '111111111'.
        ls_out2-nodocto = 1.
        ls_out2-nivel = 2.

      ELSE. " no entra en caso 6 , pone posición ajusste 9999

*        ls_out2-nodocto = '0000000000'.
        ls_out2-base = ls_out-tot_ingreso.
        ls_out2-doc_prov = '999999999'.
        ls_out2-total   = ls_out-tot_ingreso .


        ls_out2-arktx = 'PAGO SIN FACTURAS RELACIONADAS '.
*        IF ls_out-anulado = 'X'.
*          ls_out2-arktx = 'ANULADO'.
*        ENDIF.
        CLEAR ls_out3.
        READ TABLE lt_out_tmp3 INTO ls_out3 WITH KEY belnr = ls_out-belnr
                                        bukrs = ls_out-bukrs
                                        koart = 'S'.
        IF sy-subrc = 0.
          ls_out2-hkont = ls_out3-hkont.
          ls_out2-arktx = 'DIFERENCIA PAGO VS FACTURAS'.
        ENDIF.

      ENDIF.

      ls_out2-uuid    = ''.
      READ TABLE lt_out_tmp3 INTO ls_out3 WITH KEY belnr = ls_out-belnr
                                                      bukrs = ls_out-bukrs
                                                      gjahr = p_gjahr.
      IF sy-subrc = 0.
*            **        cAMBIO 5

          ls_out2-saknr = ls_out3-saknr.
          ls_out2-banco = ls_out3-banco.
          ls_out2-augbl = ls_out3-augbl.
          ls_out2-impte_edo_cta = ls_out3-impte_edo_cta.

*            **        cAMBIO 5
            IF ls_out3-anulado = 'X'.
               ls_out2-arktx   = 'ANULADO'.
               ls_out2-anulado = ls_out3-anulado.
            ENDIF.
      ENDIF.
*            ****        FIN CAMBIO 5
***************************** MODIFICACIONES MICHAEL JUL 2020 AJUSTE IMPTE _EDO INICIO

          READ table re_t_data INTO LS_Data2 WITH KEY BELNR = ls_out2-belnr
                                                      IMPTE_EDO_CTA = ls_out2-IMPTE_EDO_CTA.

          IF SY-SUBRC = 0.
            LS_OUT2-IMPTE_EDO_CTA = 0.
            CLEAR LS_DATA2.
          ENDIF.
***************************** MODIFICACIONES MICHAEL JUL 2020 AJUSTE IMPTE _EDO FINI

      APPEND ls_out2 TO re_t_data.




    ENDLOOP.

********     Caso 7 Otros doctos

******************** Caso 7 Otros documentos
    DATA: lt_bseg_o TYPE TABLE OF bseg,
          ls_bseg_o TYPE bseg,
          lt_bseg_i TYPE TABLE OF bseg,
          lt_bseg_all_o TYPE TABLE OF bseg,
          ls_bseg_a TYPE bseg,
          ls_bseg_i TYPE bseg,
          lt_bkpf_o TYPE TABLE OF bkpf,
          ls_bkpf_o TYPE bkpf.



*Z*IPA/ATB MAy2020  Solo ejecutar una vez.
*ZIf sw_onetime is initial.
*Z   sw_onetime = 'X'.


*Z    Clear: lt_bseg_o[], lt_bseg_i[], lt_bseg_all_o[], lt_bkpf_o[].

    SELECT *
      INTO CORRESPONDING FIELDS OF TABLE lt_bseg_o
      FROM bseg
      WHERE bukrs IN s_bukrs AND
            belnr IN s_belnr AND
            gjahr = p_gjahr AND
            ( hkont = '0000250020' OR hkont = '0000250030' ) .

    IF lt_bseg_o[] IS  NOT INITIAL.
      SELECT *
      INTO CORRESPONDING FIELDS OF TABLE lt_bkpf_o
       FROM bkpf
      FOR ALL ENTRIES IN lt_bseg_o
      WHERE bukrs = lt_bseg_o-bukrs AND
            belnr = lt_bseg_o-belnr AND
            belnr IN s_belnr AND
            gjahr = lt_bseg_o-gjahr AND
            monat IN s_monat AND
            cpudt IN s_cpudt        AND
            budat IN s_budat        AND
            blart = 'SA'.

      IF lt_bkpf_o[] IS NOT INITIAL.
        SELECT *
          INTO CORRESPONDING FIELDS OF TABLE lt_bseg_i
          FROM bseg
          FOR ALL ENTRIES IN lt_bkpf_o
          WHERE bukrs = lt_bkpf_o-bukrs AND
                belnr = lt_bkpf_o-belnr AND
                gjahr = lt_bkpf_o-gjahr AND

            ( hkont = '0000250020' OR hkont = '0000250030' ) .

        SELECT *
          INTO CORRESPONDING FIELDS OF TABLE lt_bseg_all_o
          FROM bseg
          FOR ALL ENTRIES IN lt_bkpf_o
          WHERE bukrs = lt_bkpf_o-bukrs AND
                belnr = lt_bkpf_o-belnr AND
                gjahr = lt_bkpf_o-gjahr.

      ENDIF.


    ENDIF.

    DATA : lt_bseg_t_o TYPE TABLE OF tys_bseg_tot,
           ls_bseg_t_o TYPE tys_bseg_tot.
    DATA: lv_band TYPE c.

*Z    Clear lt_bseg_t_o[].
    LOOP AT lt_bseg_o INTO ls_bseg_o.
      CLEAR ls_bseg_t_o.

      ls_bseg_t_o-bukrs = ls_bseg_o-bukrs.
      ls_bseg_t_o-belnr = ls_bseg_o-belnr.
      ls_bseg_t_o-gjahr = ls_bseg_o-gjahr.
*          koart TYPE koart,
      ls_bseg_t_o-total = ls_bseg_o-dmbtr.
*       iva   = ls_bseg_o-
*          iva_ret TYPE p DECIMALS 2,
      ls_bseg_t_o-hkont = ls_bseg_o-hkont.
*
      COLLECT ls_bseg_t_o INTO lt_bseg_t_o.
    ENDLOOP.


    LOOP AT  lt_bkpf_o INTO ls_bkpf_o.

      clear lv_anulado.
      CLEAR lv_saknr.
      CLEAR lv_banco.
      CLEAR lv_augbl.
      CLEAR lv_edo_cta.

      CLEAR ls_out.
      MOVE-CORRESPONDING ls_bkpf_o TO ls_out.
      ls_out-cpudt = ls_bkpf_o-cpudt.
      ls_out-bldat = ls_bkpf_o-bldat.
      ls_out-belnr = ls_bkpf_o-belnr.


*****  Moneda
      ls_out-moneda = ls_bkpf_o-waers.
      CLEAR ls_out-kursf.
      IF ls_bkpf-waers <> 'MXN'.
        ls_out-kursf = ls_bkpf-kursf.
*  ***************** MODIFICACIONES MICHAEL CHAVEZ ZARATE GPORRES 15.07.2020 INICIO
        ls_out-wwert = ls_bkpf-wwert.
*        ls_out-augdt = ls_bseg-augdt.
      ELSE.
        ls_out-wwert = ''.
*  ***************** MODIFICACIONES MICHAEL CHAVEZ ZARATE GPORRES 15.07.2020 FIN
      ENDIF.

******  BUDAT FECHA DE REGISTRO
*        ls_out-budat = ls_bkpf-budat.
*****  XBLNR forma de pago "verificado c/Enrique
*      ls_out-xblnr = ls_bkpf-xblnr.
      CLEAR ls_out-xblnr.
*****  USNAM USUARIO
      ls_out-usnam = ls_bkpf-usnam.


***      lbseg totales por cuentas
*      CLEAR ls_bseg_t_o.
*      LOOP AT lt_bseg_t_o INTO ls_bseg_t_o WHERE bukrs = ls_bkpf_o-bukrs AND
*                                                 belnr = ls_bkpf_o-belnr AND
*                                                 gjahr = ls_bkpf_o-gjahr AND
*                                                 ( hkont = '0000250020' OR hkont = '0000250020' ).
*        EXIT.
*      ENDLOOP.
*
*      ls_out-hkont = ls_bseg_t_o-hkont.
*
*
*
*      ls_out-base = ls_bseg_t_o-total.
*      ls_out-total = ls_bseg_t_o-total.
*      ls_out-tot_ingreso = ls_bseg_t_o-total.

*      CLEAR ls_bseg_o.
*      READ TABLE lt_bseg_o INTO ls_bseg_o WITH KEY bukrs = ls_bkpf_o-bukrs
*                                                   belnr = ls_bkpf_o-belnr
*                                                   gjahr = ls_bkpf_o-gjahr
*                                                   hkont = ls_bseg_t_o-hkont.
*      IF sy-subrc = 0.
*        ls_out-sgtxt = ls_bseg_o-sgtxt.
*      ENDIF.



*      CLEAR ls_bseg_i.
*      READ TABLE lt_bseg_i INTO ls_bseg_i WITH KEY bukrs = ls_bkpf_o-bukrs
*                                                   belnr = ls_bkpf_o-belnr
*                                                   gjahr = ls_bkpf_o-gjahr
*                                                   buzei = 1.
*      IF sy-subrc = 0.
*
**        ls_out-saknr = ls_bseg_i-saknr.
**        ls_out-augdt = ls_bseg_i-augdt.
*
**    ***         BANCO
**        READ TABLE lt_skat INTO ls_skat WITH  KEY saknr = ls_bseg_i-saknr.
**        "saknr.
**        IF sy-subrc = 0.
**          ls_out-banco = ls_skat-txt50.
**        ENDIF.
*      ENDIF.


*      APPEND ls_out TO re_t_data.

*** incluir las otras cuentas Camibio 5

      CLEAR lv_band.
      LOOP AT lt_bseg_all_o INTO ls_bseg_a WHERE bukrs = ls_bkpf_o-bukrs AND
                                                 belnr = ls_bkpf_o-belnr AND
                                                 gjahr = ls_bkpf_o-gjahr AND
                                                 ( hkont+0(7) = '0000113' OR hkont+0(7) = '0000113' ).
        lv_band = 'X'.
      ENDLOOP.
      IF  lv_band IS NOT INITIAL.
        LOOP AT lt_bseg_all_o INTO ls_bseg_a WHERE  bukrs = ls_bkpf_o-bukrs AND
                                                    belnr = ls_bkpf_o-belnr AND
                                                    gjahr = ls_bkpf_o-gjahr AND
                                                    buzei = 1.

*                    if ls_bseg_a-BSCHL = '40'.
*                        ls_out-base =  ls_bseg_a-dmbtr * -1.
*                        ls_out-total = ls_bseg_a-dmbtr * -1.
*                    else.
*                        ls_out-base = ls_bseg_a-dmbtr.
*                        ls_out-total = ls_bseg_a-dmbtr.
*                    endif.
*                    ls_out-hkont = ls_bseg_a-hkont.
          ls_out-sgtxt = ls_bseg_a-sgtxt.
          ls_out-impte_edo_cta = ls_bseg_t_o-total.
          ls_out-diferencias =  ls_out-impte_edo_cta  - ls_bseg_t_o-total.
          ls_out-augdt = ls_bseg_i-augdt.

*************** MODIFICACIONES MICHAEL CHAVES AGO cuando hay diferencias
* usamos el color rojo 27.08.2020 INI
          IF ls_out-diferencias NE 0.
            ls_out-color_f = 'C600'.
          ENDIF.
*************** MODIFICACIONES MICHAEL CHAVES AGO cuando hay diferencias
* usamos el color rojo 27.08.2020 FIN
          IF ls_bseg_i-augdt is INITIAL.
              ls_out-augdt = ls_bkpf_o-cpudt.
          ENDIF.
          ls_out-base =  0.
          ls_out-total = 0.
*                    IF ls_bseg_a-BSCHL = '40'.
*                      ls_out-tot_ingreso = ls_bseg_a-dmbtr * -1.
*                    ELSE.
          ls_out-tot_ingreso = ls_bseg_a-dmbtr.
*                    ENDIF.
          ls_out-saknr = ls_bseg_a-hkont.
***         BANCO
          CLEAR ls_skat.
          READ TABLE lt_skat INTO ls_skat WITH  KEY saknr = ls_out-saknr.
          "saknr.
          IF sy-subrc = 0.
            ls_out-banco = ls_skat-txt50.
          ENDIF.

*****                    Caso 5
*****       Anulado

          IF ls_bkpf_o-stblg <> ''.
            ls_out-anulado = 'X'.
            ls_out-arktx = 'ANULADO'.
            lv_anulado = 'X'.
          ENDIF.
          lv_saknr = ls_out-saknr.
          lv_banco = ls_out-banco.
          lv_augbl = ls_out-augbl.
          lv_edo_cta = ls_out-impte_edo_cta.
***************************** MODIFICACIONES MICHAEL JUL 2020 AJUSTE IMPTE _EDO INICIO

          READ table re_t_data INTO LS_Data2 WITH KEY BELNR = ls_out-belnr
                                                      IMPTE_EDO_CTA = ls_out-IMPTE_EDO_CTA.

          IF SY-SUBRC = 0.
            LS_OUT-IMPTE_EDO_CTA = 0.
            CLEAR LS_DATA2.
          ENDIF.
***************************** MODIFICACIONES MICHAEL JUL 2020 AJUSTE IMPTE _EDO FINI
*****                    Caso 5
          APPEND ls_out TO re_t_data.

          CLEAR ls_out-tot_ingreso.
          CLEAR ls_out-banco.
*          CLEAR ls_out-augdt.
          CLEAR ls_out-impte_edo_cta.
          CLEAR ls_out-diferencias.
          CLEAR ls_out-saknr.

*              ENDIF.
        ENDLOOP.
        LOOP AT lt_bseg_all_o INTO ls_bseg_a WHERE  bukrs = ls_bkpf_o-bukrs AND
                                                    belnr = ls_bkpf_o-belnr AND
                                                    gjahr = ls_bkpf_o-gjahr AND
                                                    buzei <> 1.
*                                                  and   ( hkont <> '0000250020' and hkont <> '0000250020' ).
          " Cambio 11 si es la primera posicion es como el pago cta 114 o 113


          IF ls_bseg_a-bschl = '40' OR ls_bseg_a-bschl = '01'.
            ls_out-base =  ls_bseg_a-dmbtr * -1.
            ls_out-total = ls_bseg_a-dmbtr * -1.
          ELSE.
            ls_out-base = ls_bseg_a-dmbtr.
            ls_out-total = ls_bseg_a-dmbtr.
          ENDIF.
          ls_out-hkont = ls_bseg_a-hkont.
          ls_out-sgtxt = ls_bseg_a-sgtxt.

*****                    Caso 5
          ls_out-saknr = lv_saknr.
          ls_out-banco = lv_banco.
          ls_out-augbl = lv_augbl.
          ls_out-impte_edo_cta = lv_edo_cta .
          IF lv_anulado = 'X'.
            ls_out-arktx = 'ANULADO'.
            ls_out-anulado = 'X'.
          ENDIF.
***************************** MODIFICACIONES MICHAEL JUL 2020 AJUSTE IMPTE _EDO INICIO

          READ table re_t_data INTO LS_Data2 WITH KEY BELNR = ls_out-belnr
                                                      IMPTE_EDO_CTA = ls_out-IMPTE_EDO_CTA.

          IF SY-SUBRC = 0.
            LS_OUT-IMPTE_EDO_CTA = 0.
            CLEAR LS_DATA2.
          ENDIF.
***************************** MODIFICACIONES MICHAEL JUL 2020 AJUSTE IMPTE _EDO FINI
*****                    Caso 5
          APPEND ls_out TO re_t_data.

        ENDLOOP.

      ENDIF.

    ENDLOOP.

**************************Caso 10
******************** 250111, 250112, 250113, 250114, 250115, 250116 y 250117
*DATA: lt_bseg_o TYPE TABLE OF bseg,
*      ls_bseg_o TYPE bseg,
*      lt_bseg_i TYPE TABLE OF bseg,
*      ls_bseg_i TYPE bseg,
*      lt_bkpf_o TYPE TABLE OF bkpf,
*      ls_bkpf_o TYPE bkpf.

    FREE lt_bseg_o.
    SELECT *
      INTO CORRESPONDING FIELDS OF TABLE lt_bseg_o
      FROM bseg
      WHERE bukrs IN s_bukrs AND
            belnr IN s_belnr AND
            gjahr = p_gjahr AND
            (    hkont = '0000250111'
              OR hkont = '0000250112'
              OR hkont = '0000250113'
              OR hkont = '0000250114'
              OR hkont = '0000250115'
              OR hkont = '0000250116'
              OR hkont = '0000250117'
      ).

    FREE lt_bkpf_o.
    IF lt_bseg_o[] IS NOT INITIAL.

      SELECT *
        INTO CORRESPONDING FIELDS OF TABLE lt_bkpf_o
         FROM bkpf
        FOR ALL ENTRIES IN lt_bseg_o
        WHERE bukrs = lt_bseg_o-bukrs AND
              belnr = lt_bseg_o-belnr AND
              gjahr = lt_bseg_o-gjahr AND
              monat IN  s_monat AND
              cpudt IN s_cpudt        AND
              budat IN s_budat .
*          AND
*                blart = 'SA'.

      FREE lt_bseg_i.

      IF lt_bkpf_o[] IS NOT INITIAL.
        SELECT *
      INTO CORRESPONDING FIELDS OF TABLE lt_bseg_i
      FROM bseg
      FOR ALL ENTRIES IN lt_bkpf_o
      WHERE bukrs = lt_bkpf_o-bukrs AND
            belnr = lt_bkpf_o-belnr AND
            gjahr = lt_bkpf_o-gjahr AND
        (    hkont = '0000250111'
          OR hkont = '0000250112'
          OR hkont = '0000250113'
          OR hkont = '0000250114'
          OR hkont = '0000250115'
          OR hkont = '0000250116'
          OR hkont = '0000250117'
          ).
      ENDIF.

    ENDIF.

*DATA : lt_bseg_t_o TYPE TABLE OF tys_bseg_tot,
*       ls_bseg_t_o TYPE tys_bseg_tot.


    CLEAR ls_bseg_o.
    FREE lt_bseg_t_o.
    LOOP AT lt_bseg_i INTO ls_bseg_o.
      CLEAR ls_bseg_t_o.

      ls_bseg_t_o-bukrs = ls_bseg_o-bukrs.
      ls_bseg_t_o-belnr = ls_bseg_o-belnr.
      ls_bseg_t_o-gjahr = ls_bseg_o-gjahr.
*          koart TYPE koart,
      ls_bseg_t_o-total = ls_bseg_o-dmbtr.
*       iva   = ls_bseg_o-
*          iva_ret TYPE p DECIMALS 2,
      ls_bseg_t_o-hkont = ls_bseg_o-hkont.
*
      COLLECT ls_bseg_t_o INTO lt_bseg_t_o.
    ENDLOOP.



*Z*IPA/ATB MAy2020  Solo ejecutar una vez.
*ZEndIf.   "Fin de If sw_onetime is initial.



    LOOP AT  lt_bkpf_o INTO ls_bkpf_o.
      clear lv_anulado.
      CLEAR ls_out.
      MOVE-CORRESPONDING ls_bkpf_o TO ls_out.
      ls_out-cpudt = ls_bkpf_o-cpudt.
      ls_out-bldat = ls_bkpf_o-bldat.
      ls_out-belnr = ls_bkpf_o-belnr.
*****  Moneda
      ls_out-moneda = ls_bkpf_o-waers.
      CLEAR ls_out-kursf.
      IF ls_bkpf-waers <> 'MXN'.
        ls_out-kursf = ls_bkpf-kursf.
*  ***************** MODIFICACIONES MICHAEL CHAVEZ ZARATE GPORRES 15.07.2020 INICIO
        ls_out-wwert = ls_bkpf-wwert.
*        ls_out-augdt = ls_bseg-augdt.
      ELSE.
        ls_out-wwert = ''.
*  ***************** MODIFICACIONES MICHAEL CHAVEZ ZARATE GPORRES 15.07.2020 FIN
      ENDIF.
******  BUDAT FECHA DE REGISTRO
*        ls_out-budat = ls_bkpf-budat.
*****  XBLNR forma de pago "verificado c/Enrique
*      ls_out-xblnr = ls_bkpf-xblnr.
      CLEAR ls_out-xblnr.
*****  USNAM USUARIO
      ls_out-usnam = ls_bkpf_o-usnam.


***      lbseg totales por cuentas
      CLEAR ls_bseg_t_o.
      READ TABLE lt_bseg_t_o INTO ls_bseg_t_o WITH KEY bukrs = ls_bkpf_o-bukrs
                                                       belnr = ls_bkpf_o-belnr
                                                       gjahr = ls_bkpf_o-gjahr.
      IF sy-subrc = 0.
        ls_out-hkont = ls_bseg_t_o-hkont.
        ls_out-base = ls_bseg_t_o-total.
        ls_out-total = ls_bseg_t_o-total.
        ls_out-sgtxt = ls_bseg_o-sgtxt.
      ENDIF.


*      ls_out-tot_ingreso = ls_bseg_t_o-total.



*      ls_out-IMPTE_EDO_CTA = ls_bseg_t_o-total.
*      ls_out-DIFERENCIAS =  ls_out-IMPTE_EDO_CTA  - ls_bseg_t_o-total.

*      CLEAR ls_bseg_i.
*      READ TABLE lt_bseg_i into ls_bseg_i WITH KEY bukrs = ls_bkpf_o-bukrs
*                                                   belnr = ls_bkpf_o-belnr
*                                                   gjahr = ls_bkpf_o-gjahr
*                                                   buzei = 1.
*      IF sy-subrc = 0.
*          ls_out-AUGBL = ls_bseg_i-augbl.
*          ls_out-saknr = ls_bseg_i-saknr.
*          ls_out-AUGDT = ls_bseg_i-AUGDT.
*
**    ***         BANCO
*          READ TABLE lt_skat INTO ls_skat WITH  KEY saknr = ls_bseg_i-saknr.
*           "saknr.
*          IF sy-subrc = 0.
*                ls_out-banco = ls_skat-txt50.
*          ENDIF.
*      ENDIF.

*****                    Caso 5
*****       Anulado

      IF ls_bkpf_o-stblg <> ''.
        ls_out-anulado = 'X'.
        ls_out-arktx = 'ANULADO'.
*                        lv_anulado = 'X'.
      ENDIF.
*                    lv_SAKNR = ls_out-SAKNR.
*                    lv_banco = ls_out-banco.
*                    lv_augbl = ls_out-augbl.
*                    lv_EDO_CTA = ls_out-IMPTE_EDO_CTA.

*****                    Caso 5

*IPA/ATB Ajuste para integrar pago con "P/G Cambiaria"
      If ls_out-hkont = '0000250115'.
         Clear ls_out2.
         Read Table re_t_data Into ls_out2
              With Key bukrs = ls_out-bukrs
                       gjahr = ls_out-gjahr
                       belnr = ls_out-belnr
                       nivel = 1.
         If sy-subrc is initial.
            ls_out-nivel = 2.
            ls_out-sgtxt         = 'UTILIDAD CAMBIARIA EN DEUDORES VARIOS'.
            ls_out-blart_p       = ls_out2-blart_p.
            ls_out-augbl         = ls_out2-augbl.
            ls_out-impte_edo_cta = ls_out2-impte_edo_cta.
            ls_out-banco         = ls_out2-banco.
            ls_out-augdt         = ls_out2-augdt.
            ls_out-saknr         = ls_out2-saknr.
            ls_out-xblnr         = ls_out2-xblnr.
            ls_out-name1         = ls_out2-name1.
            ls_out-stcd1         = ls_out2-stcd1.
            ls_out-kunnr         = ls_out2-kunnr.
            ls_out-formap        = ls_out2-formap.
*Borra el reg. de "Ajuste por la diferencia
            Delete re_t_data Where bukrs = ls_out-bukrs
                               And gjahr = ls_out-gjahr
                               And belnr = ls_out-belnr
                               And doc_prov = '999999999'
                               And total = ls_out-total.
         EndIf.
      EndIf.
***************************** MODIFICACIONES MICHAEL JUL 2020 AJUSTE IMPTE _EDO INICIO

          READ table re_t_data INTO LS_Data2 WITH KEY BELNR = ls_out-belnr
                                                      IMPTE_EDO_CTA = ls_out-IMPTE_EDO_CTA.

          IF SY-SUBRC = 0.
            LS_OUT-IMPTE_EDO_CTA = 0.
            CLEAR LS_DATA2.
          ENDIF.
***************************** MODIFICACIONES MICHAEL JUL 2020 AJUSTE IMPTE _EDO FINI
      APPEND ls_out TO re_t_data.




    ENDLOOP.


*Z*IPA/ATB MAy2020  Solo ejecutar una vez.
*ZIf sw_onetime = 'X'.
*Z   sw_onetime = 'Y'.



*********************************************************
******    Cambio 7 rev cliente
    DATA: lt_bseg_7 TYPE TABLE OF bseg,
          ls_bseg_7 TYPE bseg,
          lt_bseg_7i TYPE TABLE OF bseg,
*          lt_bseg_all_o TYPE TABLE OF bseg,
*          ls_bseg_a TYPE bseg,
          ls_bseg_7i TYPE bseg,
          lt_bkpf_7 TYPE TABLE OF bkpf,
          ls_bkpf_7 TYPE bkpf.

*Z    Clear: lt_bseg_7[], lt_bseg_7i[], lt_bkpf_7[].

    SELECT *
      INTO CORRESPONDING FIELDS OF TABLE lt_bseg_7
      FROM bseg
      WHERE bukrs IN s_bukrs AND
            belnr IN s_belnr AND
            gjahr = p_gjahr AND
            ( hkont = '0000250081'  ) .

    IF lt_bseg_7[] IS  NOT INITIAL.
      SELECT *
      INTO CORRESPONDING FIELDS OF TABLE lt_bkpf_7
       FROM bkpf
      FOR ALL ENTRIES IN lt_bseg_7
      WHERE bukrs = lt_bseg_7-bukrs AND
            belnr = lt_bseg_7-belnr AND
            gjahr = lt_bseg_7-gjahr AND
            monat IN s_monat AND
            cpudt IN s_cpudt        AND
            budat IN s_budat        AND
            stblg = ''. " No anulado

      IF lt_bkpf_7[] IS NOT INITIAL.
        SELECT *
          INTO CORRESPONDING FIELDS OF TABLE lt_bseg_7i
          FROM bseg
          FOR ALL ENTRIES IN lt_bkpf_7
          WHERE bukrs = lt_bkpf_7-bukrs AND
                belnr = lt_bkpf_7-belnr AND
                gjahr = lt_bkpf_7-gjahr .
      ENDIF.
    ENDIF.

    CLEAR ls_bseg_o.
    FREE lt_bseg_t_o.
    LOOP AT lt_bseg_7i INTO ls_bseg_o.
      CLEAR ls_bseg_t_o.

      ls_bseg_t_o-bukrs = ls_bseg_o-bukrs.
      ls_bseg_t_o-belnr = ls_bseg_o-belnr.
      ls_bseg_t_o-gjahr = ls_bseg_o-gjahr.
*          koart TYPE koart,
      ls_bseg_t_o-total = ls_bseg_o-dmbtr.
*       iva   = ls_bseg_o-
*          iva_ret TYPE p DECIMALS 2,
      ls_bseg_t_o-hkont = ls_bseg_o-hkont.
*      IF ls_bseg_o-hkont = '0000148001' or ls_bseg_o-hkont = '0000148001'.
      ls_bseg_t_o-bschl = ls_bseg_o-bschl.
*      ENDIF.
*
      COLLECT ls_bseg_t_o INTO lt_bseg_t_o.
    ENDLOOP.

    LOOP AT lt_bkpf_7 INTO ls_bkpf_7.

      CLEAR lv_anulado.
      CLEAR lv_saknr .
      CLEAR lv_banco .
      CLEAR lv_augbl .
      CLEAR lv_edo_cta .

      CLEAR ls_out.
      MOVE-CORRESPONDING ls_bkpf_o TO ls_out.
      ls_out-cpudt = ls_bkpf_7-cpudt.
      ls_out-bldat = ls_bkpf_7-bldat.
      ls_out-belnr = ls_bkpf_7-belnr.
      ls_out-budat = ls_bkpf_7-budat.
*      ls_out-hkont = '0000250081'.
*****  Moneda
      ls_out-moneda = ls_bkpf_7-waers.
      CLEAR ls_out-kursf.
      IF ls_bkpf-waers <> 'MXN'.
        ls_out-kursf = ls_bkpf_7-kursf.
*  ***************** MODIFICACIONES MICHAEL CHAVEZ ZARATE GPORRES 15.07.2020 INICIO
        ls_out-wwert = ls_bkpf_7-wwert.
*        ls_out-augdt = ls_bseg-augdt.
      ELSE.
        ls_out-wwert = ''.
*  ***************** MODIFICACIONES MICHAEL CHAVEZ ZARATE GPORRES 15.07.2020 FIN
      ENDIF.
******  BUDAT FECHA DE REGISTRO
*        ls_out-budat = ls_bkpf-budat.
*****  XBLNR forma de pago "verificado c/Enrique
*      ls_out-xblnr = ls_bkpf-xblnr.
      CLEAR ls_out-xblnr.
*****  USNAM USUARIO
      ls_out-usnam = ls_bkpf_7-usnam.

****      Base
*       CLEAR ls_bseg_t_o.
*      READ TABLE lt_bseg_t_o into ls_bseg_t_o WITH KEY bukrs = ls_bkpf_7-bukrs
*                                                     belnr = ls_bkpf_7-belnr
*                                                     gjahr = ls_bkpf_7-gjahr
*                                                     hkont = '0000250081'.
*      if sy-subrc = 0.
*        ls_out-base = ls_bseg_t_o-total.
*      endif.
***      iva
*      CLEAR ls_bseg_t_o.
*      READ TABLE lt_bseg_t_o into ls_bseg_t_o WITH KEY bukrs = ls_bkpf_7-bukrs
*                                                     belnr = ls_bkpf_7-belnr
*                                                     gjahr = ls_bkpf_7-gjahr
*                                                     hkont = '0000147006'.
*      if sy-subrc = 0.
*        ls_out-iva = ls_bseg_t_o-total.
*      endif.
***      iva ret
*      CLEAR ls_bseg_t_o.
*      READ TABLE lt_bseg_t_o into ls_bseg_t_o WITH KEY bukrs = ls_bkpf_7-bukrs
*                                                     belnr = ls_bkpf_7-belnr
*                                                     gjahr = ls_bkpf_7-gjahr
*                                                     hkont = '0000148001'.
*      if sy-subrc = 0.
******        Cambio 10 cliente Iva retenido no es negativo
*        if ls_bseg_t_o-BSCHL = '40'.
*          ls_out-iva_ret = ls_bseg_t_o-total * -1.
*        else.
*          ls_out-iva_ret = ls_bseg_t_o-total .
*        endif.
*      endif.


*      ls_out-TOT_INGRESO = ls_out-base + ls_out-iva  + ls_out-iva_ret.

*      clear ls_bseg_7i.
*      READ TABLE lt_bseg_7i INTO ls_bseg_7i WITH KEY bukrs = ls_bkpf_7-bukrs
*                                                     belnr = ls_bkpf_7-belnr
*                                                     gjahr = ls_bkpf_7-gjahr
*                                                     hkont = '0000250113'.
*      if sy-subrc = 0.
*        ls_out-sgtxt = ls_bseg_7i-sgtxt.
*      endif.

**** Fecha de Pago

      CLEAR ls_bseg_7i.
      READ TABLE lt_bseg_7i INTO ls_bseg_7i WITH KEY bukrs = ls_bkpf_7-bukrs
                                                     belnr = ls_bkpf_7-belnr
                                                     gjahr = ls_bkpf_7-gjahr
                                                     hkont = '0000250081'.
      IF sy-subrc = 0.
        ls_out-augdt = ls_bseg_7i-augdt.
      ENDIF.

***** Cta de Mayor

      LOOP AT lt_bseg_7i INTO ls_bseg_7i WHERE bukrs = ls_bkpf_7-bukrs AND
                                                   belnr = ls_bkpf_7-belnr AND
                                                   gjahr = ls_bkpf_7-gjahr AND
                                                   ( hkont+0(7) = '0000113' OR hkont+0(7) = '0000114' ).
        ls_out-saknr = ls_bseg_7i-hkont.
****         BANCO
        READ TABLE lt_skat INTO ls_skat WITH  KEY saknr = ls_bseg_7i-hkont. "saknr.
        IF sy-subrc = 0.
          ls_out-banco = ls_skat-txt50.
        ENDIF.
        ls_out-incluir_rep = 'X' . "Incluir en reportes de IVA aunque no tengan docto de compensación
        ls_out-tot_ingreso = ls_bseg_7i-dmbtr.
        ls_out-bukrs = ls_bkpf_7-bukrs.
        ls_out-gjahr = ls_bkpf_7-gjahr.
        ls_out-cpudt = ls_bkpf_7-cpudt.
        ls_out-bldat = ls_bkpf_7-bldat.
        ls_out-belnr = ls_bkpf_7-belnr.
        ls_out-budat = ls_bkpf_7-budat.
        ls_out-sgtxt = ls_bseg_7i-sgtxt.
*    ****  Moneda
        ls_out-moneda = ls_bkpf_7-waers.
      CLEAR ls_out-kursf.
      IF ls_bkpf-waers <> 'MXN'.
        ls_out-kursf = ls_bkpf_7-kursf.
*  ***************** MODIFICACIONES MICHAEL CHAVEZ ZARATE GPORRES 15.07.2020 INICIO
        ls_out-wwert = ls_bkpf_7-wwert.
*        ls_out-augdt = ls_bseg-augdt.
      ELSE.
        ls_out-wwert = ''.
*  ***************** MODIFICACIONES MICHAEL CHAVEZ ZARATE GPORRES 15.07.2020 FIN
      ENDIF.
        CLEAR ls_out-xblnr.
*****  USNAM USUARIO
        ls_out-usnam = ls_bkpf_7-usnam.


*****                    Caso 5
*****       Anulado

        IF ls_bkpf_7-stblg <> ''.
          ls_out-anulado = 'X'.
          ls_out-arktx = 'ANULADO'.
          lv_anulado = 'X'.
        ENDIF.
        lv_saknr = ls_out-saknr.
        lv_banco = ls_out-banco.
        lv_augbl = ls_out-augbl.
        lv_edo_cta = ls_out-impte_edo_cta.
***************************** MODIFICACIONES MICHAEL JUL 2020 AJUSTE IMPTE _EDO INICIO

          READ table re_t_data INTO LS_Data2 WITH KEY BELNR = ls_out-belnr
                                                      IMPTE_EDO_CTA = ls_out-IMPTE_EDO_CTA.

          IF SY-SUBRC = 0.
            LS_OUT-IMPTE_EDO_CTA = 0.
            CLEAR LS_DATA2.
          ENDIF.
***************************** MODIFICACIONES MICHAEL JUL 2020 AJUSTE IMPTE _EDO FINI
*****                    Caso 5
        APPEND ls_out TO re_t_data.

      ENDLOOP.

***** Ctas todas

      LOOP AT lt_bseg_7i INTO ls_bseg_7i WHERE bukrs = ls_bkpf_7-bukrs AND
                                                   belnr = ls_bkpf_7-belnr AND
                                                   gjahr = ls_bkpf_7-gjahr AND
                                                   ( hkont+0(7) <> '0000113' AND hkont+0(7) <> '0000114' ).
*        if ls_bseg_7i-BSCHL = '40'.
*          ls_out-base = ls_bseg_t_o-total * -1.
*        else.
*          ls_out-base = ls_bseg_t_o-total .
*        endif.
*          ls_out-iva = ls_bseg_t_o-total.
        CLEAR ls_out-saknr.
        CLEAR ls_out-banco.
        ls_out-base  = ls_bseg_7i-dmbtr.
        ls_out-sgtxt = ls_bseg_7i-sgtxt.
        ls_out-augdt = ls_bseg_7i-augdt.
        ls_out-hkont = ls_bseg_7i-hkont.
        ls_out-total = ls_out-base + ls_out-iva  + ls_out-iva_ret.
        CLEAR ls_out-tot_ingreso.
        CLEAR ls_out-augdt.

        ls_out-incluir_rep = 'X' . "Incluir en reportes de IVA aunque no tengan docto de compensación

*****                    Caso 5
*****       Anulado

        IF lv_anulado = 'X'.
          ls_out-anulado = 'X'.
          ls_out-arktx = 'ANULADO'.
        ENDIF.
        ls_out-saknr = lv_saknr .
        ls_out-banco = lv_banco.
        ls_out-augbl = lv_augbl.
        ls_out-impte_edo_cta = lv_edo_cta .
***************************** MODIFICACIONES MICHAEL JUL 2020 AJUSTE IMPTE _EDO INICIO

          READ table re_t_data INTO LS_Data2 WITH KEY BELNR = ls_out-belnr
                                                      IMPTE_EDO_CTA = ls_out-IMPTE_EDO_CTA.

          IF SY-SUBRC = 0.
            LS_OUT-IMPTE_EDO_CTA = 0.
            CLEAR LS_DATA2.
          ENDIF.
***************************** MODIFICACIONES MICHAEL JUL 2020 AJUSTE IMPTE _EDO FINI
*****                    Caso 5

        APPEND ls_out TO re_t_data.
      ENDLOOP.
    ENDLOOP.

*******    Caso 6 revision Cliente
*    Porres: No muestra el ingreso por traspaso de otras cuentas.
    DATA : lt_bseg_tras TYPE TABLE OF bseg,
           lt_bseg_tras2 TYPE TABLE OF bseg,
           lt_bkpf_tras TYPE TABLE OF bkpf,
           lt_bseg_comp TYPE TABLE OF bseg,
           ls_bseg_comp TYPE bseg,
           lt_buzei     TYPE TABLE OF bseg,
           ls_buzei     TYPE bseg,
           lv_begda TYPE dats,
           lv_endda TYPE dats,
           lv_tmpdt TYPE dats.
    DATA : lv_40,
           lv_50,
           lv_hkont TYPE hkont.


*Z    Clear: lt_bseg_tras[], lt_bseg_tras2[], lt_bkpf_tras[], lt_bseg_comp[], lt_buzei[].

    CONCATENATE p_gjahr s_monat-low '01' INTO lv_begda.

    IF s_monat-high IS INITIAL.
      CONCATENATE p_gjahr s_monat-high '01' INTO lv_tmpdt.
    ELSE.
      lv_tmpdt = lv_begda.
    ENDIF.

    CALL FUNCTION 'RP_LAST_DAY_OF_MONTHS'
      EXPORTING
        day_in            = lv_begda
      IMPORTING
        last_day_of_month = lv_endda
      EXCEPTIONS
        day_in_no_date    = 1
        OTHERS            = 2.
    IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.


    SELECT *
      INTO CORRESPONDING FIELDS OF TABLE lt_bseg_tras
      FROM bseg
      WHERE bukrs IN s_bukrs
      AND   belnr BETWEEN '0005000001' AND '0005999999'
      AND   gjahr = p_gjahr
      AND   ( hkont BETWEEN '0000114000' AND '0000114999' OR  hkont BETWEEN '0000113000' AND '0000113999' )
      AND   valut BETWEEN lv_begda AND lv_endda.

    REFRESH lt_bkpf_tras.
    IF lt_bseg_tras[] IS NOT INITIAL.

      SELECT *
        INTO CORRESPONDING FIELDS OF TABLE lt_bkpf_tras
        FROM bkpf
        FOR ALL ENTRIES IN lt_bseg_tras
        WHERE bukrs = lt_bseg_tras-bukrs AND
              belnr = lt_bseg_tras-belnr AND
              belnr IN s_belnr AND
              gjahr = lt_bseg_tras-gjahr AND
              cpudt IN s_cpudt AND
              budat IN s_budat
********** MODIFICACIONES MICHAEL 24.08.2020 INI

           AND   blart <> 'ZA'. "este era original
********** MODIFICACIONES MICHAEL 24.08.2020 INI
*                and STBLG = ''. Caso 5 pintar los anulados

      IF lt_bkpf_tras[] IS NOT INITIAL.
        SELECT *
         INTO CORRESPONDING FIELDS OF TABLE lt_bseg_tras2
         FROM bseg
         FOR ALL ENTRIES IN lt_bkpf_tras
         WHERE bukrs = lt_bkpf_tras-bukrs AND
               belnr = lt_bkpf_tras-belnr AND
               gjahr = lt_bkpf_tras-gjahr .
      ENDIF.
    ENDIF.
    IF lt_bseg_tras2[] IS NOT INITIAL.
      FREE lt_bseg_comp.
      SELECT *
        INTO CORRESPONDING FIELDS OF TABLE lt_bse_comp
        FROM bse_clr
        FOR ALL ENTRIES IN lt_bseg_tras2
        WHERE bukrs_clr = lt_bseg_tras2-bukrs AND
              belnr_clr = lt_bseg_tras2-augbl AND
              gjahr_clr = lt_bseg_tras2-gjahr .

      IF lt_bse_comp[] IS NOT INITIAL.
        SELECT *
          INTO CORRESPONDING FIELDS OF TABLE lt_bkpf_comp
          FROM bkpf
          FOR ALL ENTRIES IN lt_bse_comp
          WHERE bukrs = lt_bse_comp-bukrs_clr AND
                belnr = lt_bse_comp-belnr_clr AND
                gjahr = lt_bse_comp-gjahr_clr AND
                blart = 'ZA'.

      ENDIF.

*Z      Clear lt_bkpf_comp2[].
      IF lt_bse_comp[] IS NOT INITIAL.
        SELECT *
          INTO CORRESPONDING FIELDS OF TABLE lt_bkpf_comp2
          FROM bkpf
          FOR ALL ENTRIES IN lt_bse_comp
          WHERE bukrs = lt_bse_comp-bukrs AND
                belnr = lt_bse_comp-belnr AND
                gjahr = lt_bse_comp-gjahr AND
                blart = 'ZA'.

        SELECT *
          INTO CORRESPONDING FIELDS OF TABLE lt_bseg_comp2
          FROM bseg
          FOR ALL ENTRIES IN lt_bse_comp
          WHERE bukrs = lt_bse_comp-bukrs AND
                belnr = lt_bse_comp-belnr AND
                gjahr = lt_bse_comp-gjahr.

      ENDIF.
    ENDIF.


    REFRESH lt_bseg_tot.
    LOOP AT lt_bseg_tras2 INTO ls_bseg.
      CLEAR ls_bseg_tot.
      CLEAR ls_bseg_tot.
      ls_bseg_tot-bukrs = ls_bseg-bukrs.
      ls_bseg_tot-belnr = ls_bseg-belnr.
      ls_bseg_tot-gjahr = ls_bseg-gjahr.
      ls_bseg_tot-bschl = ls_bseg-bschl.
      ls_bseg_tot-total = ls_bseg-dmbtr.
      ls_bseg_tot-hkont = ls_bseg-hkont.
      COLLECT ls_bseg_tot INTO lt_bseg_tot.
    ENDLOOP.



    LOOP AT lt_bseg_tot INTO ls_bseg_tot WHERE bschl = '50' AND"BSCHL = '40' and "Cambia por caso 12
                                               ( hkont+0(7) = '0000114' OR hkont+0(7) = '0000113' ).

      lv_50 = ''.
      CLEAR ls_bseg2.
      READ TABLE lt_bseg_tras2 INTO ls_bseg2 WITH KEY         bukrs = ls_bseg_tot-bukrs
                                                              belnr = ls_bseg_tot-belnr
                                                              gjahr = ls_bseg_tot-gjahr
                                                              bschl = '40'. "'50'. Cambia por caso 12
      IF sy-subrc = 0 AND ls_bseg2-hkont <> ls_bseg_tot-hkont .
        ls_bseg_tot-band = 'X'.
        MODIFY lt_bseg_tot FROM ls_bseg_tot .
      ENDIF.

    ENDLOOP.

    IF lt_bseg_tot[] IS NOT INITIAL.

      SELECT *
       INTO CORRESPONDING FIELDS OF TABLE lt_buzei
       FROM bseg
       FOR ALL ENTRIES IN lt_bseg_tot
       WHERE bukrs = lt_bseg_tot-bukrs AND
             belnr = lt_bseg_tot-belnr AND
             gjahr = lt_bseg_tot-gjahr.
*          ORDER BY buzei DESCENDING.

      SORT lt_buzei BY bukrs gjahr belnr ASCENDING buzei DESCENDING.


    ENDIF.

    LOOP AT lt_bkpf_tras INTO ls_bkpf.
      CLEAR lv_anulado.
      CLEAR ls_out.

      CLEAR ls_bseg.
      READ TABLE lt_bseg_tot INTO ls_bseg_tot WITH KEY bukrs = ls_bkpf-bukrs
                                                              belnr = ls_bkpf-belnr
                                                              gjahr = ls_bkpf-gjahr
                                                              band = 'X'.
      IF sy-subrc = 0.
        READ TABLE lt_buzei INTO ls_buzei WITH  KEY bukrs = ls_bkpf-bukrs
                                                    belnr = ls_bkpf-belnr
                                                    gjahr = ls_bkpf-gjahr.
        IF sy-subrc = 0 AND ls_buzei-buzei = 2.


          MOVE-CORRESPONDING ls_bkpf TO ls_out.
          ls_out-hkont  = ls_bseg_tot-hkont.
*            ls_out-SAKNR  = ls_bseg_tot-hkont.
          ls_out-base   = ls_bseg_tot-total.
          ls_out-total  = ls_bseg_tot-total.
*            ls_out-tot_ingreso  = ls_bseg_tot-total.
          ls_out-moneda = ls_bkpf-waers.
                CLEAR ls_out-kursf.
      IF ls_bkpf-waers <> 'MXN'.
        ls_out-kursf = ls_bkpf-kursf.
*  ***************** MODIFICACIONES MICHAEL CHAVEZ ZARATE GPORRES 15.07.2020 INICIO
        ls_out-wwert = ls_bkpf-wwert.
*        ls_out-augdt = ls_bseg-augdt.
      ELSE.
        ls_out-wwert = ''.
*  ***************** MODIFICACIONES MICHAEL CHAVEZ ZARATE GPORRES 15.07.2020 FIN
      ENDIF.


          CLEAR ls_bseg2.
          LOOP AT lt_bseg_tras2 INTO ls_bseg2 WHERE      bukrs = ls_bkpf-bukrs AND
                                                         belnr = ls_bkpf-belnr AND
                                                         gjahr = ls_bkpf-gjahr AND
*                                                           hkont = ls_out-hkont and
                                                         augbl <> ''.
*            READ TABLE lt_bseg_tras into ls_bseg2 WITH KEY bukrs = ls_bkpf-bukrs
*                                                           belnr = ls_bkpf-belnr
*                                                           gjahr = ls_bkpf-gjahr
*                                                           hkont = ls_out-hkont.
*
*            IF sy-subrc = 0.


            LOOP AT lt_bse_comp INTO ls_bse_comp WHERE bukrs_clr = ls_bseg2-bukrs AND
                                                       belnr_clr = ls_bseg2-augbl AND
                                                       gjahr_clr = ls_bseg2-gjahr.

              READ TABLE lt_bkpf_comp TRANSPORTING NO FIELDS WITH KEY bukrs = ls_bse_comp-bukrs_clr
                                                                      belnr = ls_bse_comp-belnr_clr
                                                                      gjahr = ls_bse_comp-gjahr_clr.
              IF sy-subrc = 0.
                ls_out-impte_edo_cta = ls_bse_comp-dmbtr.
                ls_out-sgtxt  = ls_bseg2-sgtxt.
                ls_out-augdt  = ls_bseg2-augdt.
                ls_out-augbl  = ls_bseg2-augbl.
              ENDIF.

            ENDLOOP.
            IF ls_out-augbl IS INITIAL.

              LOOP AT lt_bse_comp INTO ls_bse_comp WHERE  bukrs_clr = ls_bseg2-bukrs AND
                                                          belnr_clr = ls_bseg2-augbl AND
                                                          gjahr_clr = ls_bseg2-gjahr.


                READ TABLE lt_bkpf_comp2 INTO ls_bkpf_comp2 WITH KEY bukrs = ls_bse_comp-bukrs
                                                               belnr = ls_bse_comp-belnr
                                                               gjahr = ls_bse_comp-gjahr.
                IF sy-subrc = 0.
                  READ TABLE lt_bseg_comp2 INTO ls_bseg_comp2  WITH KEY bukrs = ls_bse_comp-bukrs
                                                               belnr = ls_bse_comp-belnr
                                                               gjahr = ls_bse_comp-gjahr.
                  ls_out-augbl  = ls_bseg_comp2-belnr.
                  ls_out-augdt  = ls_bseg_comp2-augdt.
                  ls_out-impte_edo_cta = ls_bse_comp-dmbtr.

                ENDIF.
              ENDLOOP.
            ENDIF.

*            ENDIF.
          ENDLOOP.



*    ****         BANCO
          CLEAR ls_bseg2.
          READ TABLE lt_bseg_tot INTO ls_bseg_tot WITH KEY bukrs = ls_bkpf-bukrs
                                                         belnr = ls_bkpf-belnr
                                                         gjahr = ls_bkpf-gjahr
                                                         band = ''. " Contrapartida cuenta 114

          IF sy-subrc = 0.
            ls_out-saknr = ls_bseg_tot-hkont.
            ls_out-tot_ingreso = ls_bseg_tot-total.
          ENDIF.
          CLEAR ls_skat.
          READ TABLE lt_skat INTO ls_skat WITH  KEY saknr = ls_out-saknr.
          IF sy-subrc = 0.
            ls_out-banco = ls_skat-txt50.
          ENDIF.
          ls_out-diferencias = ls_out-impte_edo_cta - ls_out-tot_ingreso.
          ls_out-incluir_rep = 'X' . "Incluir en reportes de IVA aunque no tengan docto de compensación

*************** MODIFICACIONES MICHAEL CHAVES AGO cuando hay diferencias
* usamos el color rojo 27.08.2020 INI
          IF ls_out-diferencias NE 0.
            ls_out-color_f = 'C600'.
          ENDIF.
*************** MODIFICACIONES MICHAEL CHAVES AGO cuando hay diferencias

*****                    Caso 5
*****       Anulado

          IF ls_bkpf-stblg <> ''.
            ls_out-anulado = 'X'.
            ls_out-arktx = 'ANULADO'.
            lv_anulado = 'X'.
          ENDIF.
*                    lv_SAKNR = ls_out-SAKNR.
*                    lv_banco = ls_out-banco.
*                    lv_augbl = ls_out-augbl.
*                    lv_EDO_CTA = ls_out-IMPTE_EDO_CTA.
***************************** MODIFICACIONES MICHAEL JUL 2020 AJUSTE IMPTE _EDO INICIO

          READ table re_t_data INTO LS_Data2 WITH KEY BELNR = ls_out-belnr
                                                      IMPTE_EDO_CTA = ls_out-IMPTE_EDO_CTA.

          IF SY-SUBRC = 0.
            LS_OUT-IMPTE_EDO_CTA = 0.
            CLEAR LS_DATA2.
          ENDIF.
***************************** MODIFICACIONES MICHAEL JUL 2020 AJUSTE IMPTE _EDO FINI
************************** MODIFICACIONES MICHAEL AGO 2020 INICIO
              READ TABLE lt_febep INTO ls_febep WITH KEY belnr = ls_out-augbl
                                                         budat = ls_out-budat
                                                         gjahr = p_gjahr
                                                         kwbtr = ls_bse_comp-dmbtr.

              IF sy-subrc = 0.

                READ TABLE lt_febko INTO ls_febko WITH KEY kukey = ls_febep-kukey.

                IF sy-subrc = 0.

                  ls_out-SSBTR = ls_febko-ssbtr.
                  ls_out-ESBTR = ls_febko-ESBTR.

                ENDIF.

              ENDIF.

************************** MODIFICACIONES MICHAEL AGO 2020

************************** MODIFICACIONES MICHAEL AGO 2020 INICIO

            IF ls_out-diferencias < 0 AND LS_OUT-IMPTE_EDO_CTA = 0.
            DATA: lv_dif type dmbtr.

            lv_dif = ls_out-diferencias * -1.
              READ TABLE lt_febep INTO ls_febep WITH KEY belnr = ls_out-belnr
                                                         budat = ls_out-budat
                                                         gjahr = p_gjahr
                                                         kwbtr = lv_dif.

              IF sy-subrc = 0.

                READ TABLE lt_febko INTO ls_febko WITH KEY kukey = ls_febep-kukey.

                IF sy-subrc = 0.

                  ls_out-SSBTR = ls_febko-ssbtr.
                  ls_out-ESBTR = ls_febko-ESBTR.

                ENDIF.

              ENDIF.
            ENDIF.


************************** MODIFICACIONES MICHAEL AGO 2020


************ MODIFICACIONES MICHAEL 27.08.2020 colores ini
*          LS_OUT-COLOR_F = 'C510'.

************ MODIFICACIONES MICHAEL 27.08.2020 colores FIN


*****                    Caso 5
          APPEND ls_out TO re_t_data.
        ENDIF.
      ENDIF.

    ENDLOOP.



*Z*IPA/ATB MAy2020  Solo ejecutar una vez.
*ZEndIf.   "Fin de  sw_onetime = 'X'.



*ZAppend LINES OF re_t_data To tt_aux.

*ZEndLoop.   "Fin de Loop At gt_bkpff Into ls_bkpff.

*Zre_t_data[] = tt_aux[].
*ZClear tt_aux[].



*IPA/ATB  Abr2020  En Actualizacion2020, 1ero se dijo(usuario-IT o Funcional)
*que ContableConcentrado = version de Contable, (como lo dice su nombre)
*Despues por reporte usuarioFINAL, +Bien era ConciliadoConcentrado
*Ya no se cambio el nombre  "p_cocon"(ContableConcentrado) aunque ahora = ConciliadoContrado
*    IF  p_conta IS INITIAL   And  p_cocon is initial.

*** solo se mostrarán anulados en reporte contable [Chempe NO...(o contable concentrado)


    IF  p_conta IS INITIAL.
      DELETE re_t_data WHERE anulado = 'X'.
    ENDIF.

*********************
    SORT re_t_data BY belnr doc_prov nivel nodocto.
    delete re_t_data where base = 0 and total = 0 and tot_ingreso = 0.

*Z    Delete ADJACENT DUPLICATES FROM re_t_data COMPARING ALL FIELDS.

*IPA/ATB Ene2020
    Describe Table re_t_data lines w_full.
    Clear: w_arktx, w_hkont, wsy_tabix, w_doc, w2_uuid, w2_formapp.
*    Loop At re_t_data Into ls_out.
*      wsym_tabix = sy-tabix.
*      IF w_doc <> ls_out-belnr.
*         w_doc  = ls_out-belnr.
*         Clear: w_pathxml, it_xml[], w_xml, w_formapp, w_uuid, w_metodop.
*         Select Single path_xml Into w_pathxml From ZREPMEN_SATP
*          Where bukrs     = ls_out-bukrs
*            And serie     = 'PAGO'
*            And folio_sap = ls_out-belnr
*            And gjahr     = ls_out-gjahr.
*         If sy-subrc is initial And w_pathxml is not initial.
*            Call Function 'ZREP_READXML'
*               Exporting
*                 W_XMLFILE    = w_pathxml
*               Tables
*                 IT_XML_TABLE = it_xml.
*         EndIf.
*         If sy-subrc is initial And it_xml[] is not initial.
*            Read Table it_xml Into w_xml With Key cname = 'FormaDePagoP'.
*            If sy-subrc is initial.
*               w_formapp = w_xml-cvalue.
*            EndIf.
*            Read Table it_xml Into w_xml With Key cname = 'UUID'.
*            If sy-subrc is initial.
*               w_uuid = w_xml-cvalue.
*            EndIf.
*         EndIf.
*         If wsy_tabix is initial.
*            ls_out3   = ls_out.
*            wsy_tabix = wsym_tabix.
*         Else.
*            if   w_arktx is not initial.
**             And w_arktx <> 'DIFERENCIA PAGO VS FACTURAS'.
*               ls_out3-arktx = w_arktx.
*            endif.
*            if w_hkont is not initial.
*               ls_out3-hkont = w_hkont.
*            endif.
*            if w2_formapp is not initial.
*               ls_out3-formap = w2_formapp.
*            endif.
*            if w2_uuid is not initial.
*               ls_out3-uuid_p = w2_uuid.
*            endif.
*            Modify re_t_data From ls_out3 Index wsy_tabix.
*            ls_out3   = ls_out.
*            wsy_tabix = wsym_tabix.
*            Clear: w_arktx, w_hkont, w2_uuid, w2_formapp.
*         EndIf.
*      ELSE.
*         If w_arktx is initial and ls_out-arktx is not initial.
*            w_arktx = ls_out-arktx.
*         EndIf.
*         w_hkont    = ls_out-hkont.
*         w2_uuid    = w_uuid.
*         w2_formapp = w_formapp.
*         Clear w_metodop.
*         ls_out-uuid_p = w_uuid.
*         Modify re_t_data From ls_out Index wsym_tabix.
*      ENDIF.
*
*      If wsym_tabix = w_full.
*         ls_out3-arktx  = w_arktx.
*         ls_out3-hkont  = w_hkont.
*         ls_out3-formap = w2_formapp.
*         ls_out3-uuid_p = w2_uuid.
*         Modify re_t_data From ls_out3 Index wsy_tabix.
*      EndIf.
*
*    EndLoop.


*IPA/ATB Mar2020 Concentrado  (+bien Conciliado-Concentrado)
    If p_cocon is not initial.
       tt_aux[] = re_t_data[].
       Clear: re_t_data[], w_doc, w_hkont.
       Loop At tt_aux Into ls_out.
         Clear: ls_out-nodocto, ls_out-mwskz.
         If ls_out-doc_prov is not initial.
            if ls_out-doc_prov <> w_doc.
               w_doc   = ls_out-doc_prov.
               w_hkont = ls_out-hkont.
            else.
               Clear: ls_out-impte_edo_cta, ls_out-tasa, ls_out-tot_ingreso.
               ls_out-hkont = w_hkont.
            endif.
         EndIf.
         Collect ls_out Into re_t_data.
       EndLoop.
    EndIf.

*        ~~~~~~~~~~~~~~~~~~~~~~~~~~-{ END METHOD }-~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
  ENDMETHOD.                    "get_data

ENDCLASS.                    "lcl_appl IMPLEMENTATION
