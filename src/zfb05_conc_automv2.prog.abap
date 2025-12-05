************************************************************************
*                                                                      *
*            ********************************************              *
*            *   Confidential and Proprietary           *              *
*            *   XAMAI S.A. de C.V.                     *              *
*            *   All Rights Reserved                    *              *
*            ********************************************              *
*                                                                      *
************************************************************************
* Include             :  ZFB05_CONC_AUTOM                              *
* Titulo              :  Grabaciones FB05 para conciliacion automatica *
*                                                                      *
* Programador         : David Del Valle Mendoza
* Programador         : Jaime Hernández Velásquez (Correcciones y mejoras)
* Fecha               : II.2021                                        *
************************************************************************
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
***INCLUDE ZFB05_CONC_AUTOM .
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  F_TOT
*&      UN solo pago TOTAL
*&---------------------------------------------------------------------*
FORM f_tot .

  CLEAR:   i_msg, bdcdata_tab, bdcdata_wa.
  REFRESH: i_msg, bdcdata_tab.

  READ TABLE i_facturas_pagar INDEX 1.

*** Contabilizar y compensar : Datos cabecera
  PERFORM f_fb05_pant1.

*** Contabilizar y compensar : Añadir cta. de mayor
  PERFORM f_fb05_pant2.

*** Ventana Bloque de imputación
  PERFORM f_fb05_pant3.

*** Contabilizar y compensar : Seleccionar partidas abiertas
  PERFORM f_fb05_pant4.

*** Contabilizar y compensar : Entrar condiciones de seleccion
*** indicar documentos a pagar
  PERFORM bdc_build_script_record USING:
          'X' 'SAPMF05A' '0731',
          ' ' 'BDC_OKCODE' '/00'.

  CLEAR: v_pos, v_line.

  LOOP AT i_facturas_pagar.

    ADD 1 TO v_pos.
    CONCATENATE 'RF05A-SEL01(' v_pos ')' INTO v_line.
    PERFORM bdc_build_script_record USING:
          ' ' v_line i_facturas_pagar-belnr.

    IF v_pos = 10.
      PERFORM bdc_build_script_record USING:
              'X' 'SAPMF05A' '0731',
              ' ' 'BDC_OKCODE' '/00'.
      CLEAR: v_pos.
    ENDIF.

  ENDLOOP.

*** Boton Tratar PAs
  PERFORM bdc_build_script_record USING:
            'X' 'SAPMF05A' '0731',
            ' ' 'BDC_OKCODE' '=PA'.

*** Crea el documento
  PERFORM bdc_build_script_record USING:
            'X' 'SAPDF05X' '3100',
            ' ' 'BDC_OKCODE' '=AB'.

*** Crea las posiciones del documento
*** Guarda el documento
*** Ventana forma de pago
*** Manda llamar la transaccion
  PERFORM f_fb05_pant5.

ENDFORM.                    " F_TOT


*&---------------------------------------------------------------------*
*&      Form  F_REM
*&      UN solo pago REMANENTE
*&---------------------------------------------------------------------*
FORM f_rem .

  CLEAR:   i_msg, bdcdata_tab, bdcdata_wa.
  REFRESH: i_msg, bdcdata_tab.

  READ TABLE i_facturas_pagar INDEX 1.

*** Contabilizar y compensar : Datos cabecera
  PERFORM f_fb05_pant1.

*** Contabilizar y compensar : Añadir cta. de mayor
  PERFORM f_fb05_pant2.

*** Ventana Bloque de imputación
  PERFORM f_fb05_pant3.

*** Contabilizar y compensar : Seleccionar partidas abiertas
  PERFORM f_fb05_pant4.

*** Contabilizar y compensar : Entrar condiciones de seleccion
*** indicar documentos a pagar
  PERFORM bdc_build_script_record USING:
          'X' 'SAPMF05A' '0731',
          ' ' 'BDC_OKCODE' '/00'.


*** Agrega todos los remanentes con los docs relacionados
  CLEAR: v_pos, v_line.
  LOOP AT i_facturas_pagar WHERE tipo = 1.
    LOOP AT i_bsid_doc WHERE vbeln = i_facturas_pagar-vbeln.

      ADD 1 TO v_pos.
      CONCATENATE 'RF05A-SEL01(' v_pos ')' INTO v_line.
      PERFORM bdc_build_script_record USING:
            ' ' v_line i_bsid_doc-belnr.

      IF v_pos = 12.
        PERFORM bdc_build_script_record USING:
                'X' 'SAPMF05A' '0731',
                ' ' 'BDC_OKCODE' '/00'.
        CLEAR: v_pos.
      ENDIF.

    ENDLOOP.
  ENDLOOP.


*** Boton Tratar PAs
  PERFORM bdc_build_script_record USING:
            'X' 'SAPMF05A' '0731',
            ' ' 'BDC_OKCODE' '=PA'.

***
  PERFORM bdc_build_script_record USING:
            'X' 'SAPDF05X' '3100',
            ' ' 'BDC_OKCODE' '=PPD'.

***
  PERFORM bdc_build_script_record USING:
            'X' 'SAPDF05X' '3100',
            ' ' 'BDC_OKCODE' '/00'.

***
  PERFORM bdc_build_script_record USING:
            'X' 'SAPDF05X' '3100',
            ' ' 'BDC_OKCODE' '/00'.

*** Crea el documento
  PERFORM bdc_build_script_record USING:
            'X' 'SAPDF05X' '3100',
            ' ' 'BDC_OKCODE' '=AB'.

*** Crea las posiciones del documento
*** Guarda el documento
*** Ventana forma de pago
*** Manda llamar la transaccion
  PERFORM f_fb05_pant5.


ENDFORM.                    " F_REM

*&---------------------------------------------------------------------*
*&      Form  F_PAR
*&      UN solo pago PARCIAL
*&---------------------------------------------------------------------*
FORM f_par .

  CLEAR:   i_msg, bdcdata_tab, bdcdata_wa.
  REFRESH: i_msg, bdcdata_tab.

  READ TABLE i_facturas_pagar INDEX 1.

*** Contabilizar y compensar : Datos cabecera
  PERFORM f_fb05_pant1.

*** Contabilizar y compensar : Añadir cta. de mayor
  PERFORM f_fb05_pant2.

*** Ventana Bloque de imputación
  PERFORM f_fb05_pant3.

*** Contabilizar y compensar : Seleccionar partidas abiertas
  PERFORM f_fb05_pant4.

*** Contabilizar y compensar : Entrar condiciones de seleccion
*** indicar documentos a pagar
  PERFORM bdc_build_script_record USING:
          'X' 'SAPMF05A' '0731',
          ' ' 'BDC_OKCODE' '/00'.

  CLEAR: v_pos, v_line.

  LOOP AT i_facturas_pagar.

    ADD 1 TO v_pos.
    CONCATENATE 'RF05A-SEL01(' v_pos ')' INTO v_line.
    PERFORM bdc_build_script_record USING:
          ' ' v_line i_facturas_pagar-belnr.

    IF v_pos = 12.
      PERFORM bdc_build_script_record USING:
              'X' 'SAPMF05A' '0731',
              ' ' 'BDC_OKCODE' '/00'.
      CLEAR: v_pos.
    ENDIF.

  ENDLOOP.

*** Boton Tratar PAs
  PERFORM bdc_build_script_record USING:
            'X' 'SAPMF05A' '0731',
            ' ' 'BDC_OKCODE' '=PA'.

*** Moverse a la pestaña de Parciales
  PERFORM bdc_build_script_record USING:
            'X' 'SAPDF05X' '3100',
            ' ' 'BDC_OKCODE' '=PART',
            ' ' 'RF05A-ABPOS' '1'.

*** Pone el importe del pago en la posición
  PERFORM bdc_build_script_record USING:
          'X' 'SAPDF05X' '3100',
          ' ' 'BDC_CURSOR'  'DF05B-PSZAH(01)',
          ' ' 'BDC_OKCODE' '=PI',
          ' ' 'RF05A-ABPOS' '1'.

*** Crea el documento
  PERFORM bdc_build_script_record USING:
            'X' 'SAPDF05X' '3100',
            ' ' 'BDC_OKCODE' '=AB'.

*** Crea las posiciones del documento
*** Guarda el documento
*** Ventana forma de pago
*** Manda llamar la transaccion
  PERFORM f_fb05_pant5.

ENDFORM.                    " F_PAR

*&---------------------------------------------------------------------*
*&      Form  F_TOT_PAR
*&      1:N Totales + 1 PARCIAL
*&---------------------------------------------------------------------*
FORM f_tot_par .

  CLEAR:   i_msg, bdcdata_tab, bdcdata_wa.
  REFRESH: i_msg, bdcdata_tab.
*** Contabilizar y compensar : Datos cabecera
  PERFORM f_fb05_pant1.

*** Contabilizar y compensar : Añadir cta. de mayor
  PERFORM f_fb05_pant2.

*** Ventana Bloque de imputación
  PERFORM f_fb05_pant3.

*** Contabilizar y compensar : Seleccionar partidas abiertas
  PERFORM f_fb05_pant4.

*** Contabilizar y compensar : Entrar condiciones de seleccion
*** indicar documentos a pagar
  PERFORM bdc_build_script_record USING:
          'X' 'SAPMF05A' '0731',
          ' ' 'BDC_OKCODE' '/00'.

  CLEAR: v_pos, v_line.

*** Pega Totales (1:n)
  LOOP AT i_facturas_pagar WHERE tipo = '2'.

    ADD 1 TO v_pos.
    CONCATENATE 'RF05A-SEL01(' v_pos ')' INTO v_line.
    PERFORM bdc_build_script_record USING:
          ' ' v_line i_facturas_pagar-belnr.

    IF v_pos = 12.
      PERFORM bdc_build_script_record USING:
              'X' 'SAPMF05A' '0731',
              ' ' 'BDC_OKCODE' '/00'.
      CLEAR: v_pos.
    ENDIF.

  ENDLOOP.

*** Pega Parcial (1:1)
  READ TABLE i_facturas_pagar WITH KEY tipo = '3'.

  ADD 1 TO v_pos.
  CONCATENATE 'RF05A-SEL01(' v_pos ')' INTO v_line.
  PERFORM bdc_build_script_record USING:
        ' ' v_line i_facturas_pagar-belnr.


*** Presiona boton Tratar PAs
  PERFORM bdc_build_script_record USING:
          'X' 'SAPMF05A' '0731',
          ' ' 'BDC_OKCODE' '=PA'.

*** Se mueve a la pestaña de "Pago parc."
  PERFORM bdc_build_script_record USING:
          'X' 'SAPDF05X' '3100',
          ' ' 'BDC_OKCODE' '=PART'.


*** Arma la posicion de donde esta el parcial
  CLEAR v_pos_parc.
  CONCATENATE 'DF05B-PSZAH(' v_pos ')'
    INTO v_pos_parc.

*** Asigna el importe sobrante despues del total al segundo documento
  PERFORM bdc_build_script_record USING:
        'X' 'SAPDF05X' '3100',
        ' ' 'BDC_OKCODE' '=PI',
        ' ' 'BDC_CURSOR' v_pos_parc.

*** Se mueve a pestaña resumen
  PERFORM bdc_build_script_record USING:
        'X' 'SAPDF05X' '3100',
        ' ' 'BDC_OKCODE' '=AB',
        ' ' 'BDC_CURSOR' v_pos_parc.

*** Agrega las partidas de cliente
  PERFORM bdc_build_script_record USING:
      'X' 'SAPMF05A' '0700',
      ' ' 'BDC_OKCODE' '=BS'.
*          ' ' 'BKPF-XBLNR' 'REFERENCIA',
*          ' ' 'BKPF-BKTXT' 'Txt.Cab.Doc.'.

*** Entra a la posicoin del parcial
  CLEAR v_pos_parc.
  CONCATENATE 'RF05A-AZEI1(' v_pos ')'
    INTO v_pos_parc.

  PERFORM bdc_build_script_record USING:
      'X' 'SAPMF05A' '0700',
      ' ' 'BDC_OKCODE' '=PI',
      ' ' 'BDC_CURSOR' v_pos_parc.

*** Regresa al resumen
  READ TABLE i_facturas_pagar WITH KEY tipo = '2'.
  PERFORM bdc_build_script_record USING:
      'X' 'SAPMF05A' '0301',
      ' ' 'BDC_OKCODE' '=AB',
*      ' ' 'BSEG-GSBER' '100'                     " Division?
      ' ' 'BSEG-ZFBDT' v_fecha_campo,             " Fecha base
      ' ' 'BSEG-ZUONR' i_facturas_pagar-vbeln.    " Asignacion

*** Guardar
  PERFORM bdc_build_script_record USING:
            'X' 'SAPMF05A' '0700',
            ' ' 'BDC_OKCODE' '=BU'.

*** Ventana forma de pago
  PERFORM bdc_build_script_record USING:
              'X' 'SAPLSPO4' '0300',
              ' ' 'BDC_OKCODE' 'FURT',
              ' ' 'SVALD-VALUE(01)' v_forma_pago.

*** Manda llamar la transaccion
  PERFORM f_fb05_llamada.

ENDFORM.                    " F_TOT_PAR




*&---------------------------------------------------------------------*
*&      Form  F_REM_TOT_PAR
*&      1 Remanente + 1:N Totales + 1 Parcial
*&---------------------------------------------------------------------*
FORM f_rem_tot_par .
  CLEAR:   i_msg, bdcdata_tab, bdcdata_wa.
  data lv_ciclos type p DECIMALS 2.

  REFRESH: i_msg, bdcdata_tab.
*** Contabilizar y compensar : Datos cabecera
  PERFORM f_fb05_pant1.

*** Contabilizar y compensar : Añadir cta. de mayor
  PERFORM f_fb05_pant2.

*** Ventana Bloque de imputación
  PERFORM f_fb05_pant3.

*** Contabilizar y compensar : Seleccionar partidas abiertas
  PERFORM f_fb05_pant4.

*** Contabilizar y compensar : Entrar condiciones de seleccion
*** indicar documentos a pagar
  PERFORM bdc_build_script_record USING:
          'X' 'SAPMF05A' '0731',
          ' ' 'BDC_OKCODE' '/00'.

  CLEAR: v_pos, v_line.

*** Pega Remanente (1:1)
  LOOP AT i_facturas_pagar WHERE tipo = 1.

    LOOP AT i_bsid_doc WHERE vbeln = i_facturas_pagar-vbeln.
      ADD 1 TO v_pos_tot.
      ADD 1 TO v_pos.
      CONCATENATE 'RF05A-SEL01(' v_pos ')' INTO v_line.
      PERFORM bdc_build_script_record USING:
            ' ' v_line i_bsid_doc-belnr.

      IF v_pos = 12.
        PERFORM bdc_build_script_record USING:
                'X' 'SAPMF05A' '0731',
                ' ' 'BDC_OKCODE' '/00'.
        CLEAR: v_pos.
      ENDIF.

    ENDLOOP.
  ENDLOOP.

*** Pega Totales (1:n)
  LOOP AT i_facturas_pagar WHERE tipo = '2'.

    ADD 1 TO v_pos.
    ADD 1 TO v_pos_tot.
    CONCATENATE 'RF05A-SEL01(' v_pos ')' INTO v_line.
    PERFORM bdc_build_script_record USING:
          ' ' v_line i_facturas_pagar-belnr.

    IF v_pos = 12.
      PERFORM bdc_build_script_record USING:
              'X' 'SAPMF05A' '0731',
              ' ' 'BDC_OKCODE' '/00'.
      CLEAR: v_pos.
    ENDIF.

  ENDLOOP.

*** Pega Parcial (1:1)
  READ TABLE i_facturas_pagar WITH KEY tipo = '3'.

  ADD 1 TO v_pos.
  ADD 1 TO v_pos_tot.
  IF v_pos = 12.
        PERFORM bdc_build_script_record USING:
                'X' 'SAPMF05A' '0731',
                ' ' 'BDC_OKCODE' '/00'.
        CLEAR: v_pos.
        ADD 1 TO v_pos.
  ENDIF.

  CONCATENATE 'RF05A-SEL01(' v_pos ')' INTO v_line.
  PERFORM bdc_build_script_record USING:
        ' ' v_line i_facturas_pagar-belnr.

*** Presiona boton Tratar PAs
  PERFORM bdc_build_script_record USING:
          'X' 'SAPMF05A' '0731',
          ' ' 'BDC_OKCODE' '=PA'.

*** Se mueve a la pestaña de "Pago parc."
  PERFORM bdc_build_script_record USING:
        'X' 'SAPDF05X' '3100',
        ' ' 'BDC_OKCODE' '=PART'.


  CLEAR v_pos_parc.

  CLEAR v_pos_parc.
  v_pos = v_pos_tot.

  IF v_pos > 7.
    v_pos_tot = v_pos - 7 .
    lv_ciclos = v_pos / 7.
    lv_ciclos = ceil( lv_ciclos ).
    lv_ciclos = lv_ciclos - 1.

    DO lv_ciclos TIMES.


     PERFORM bdc_build_script_record USING:
          'X' 'SAPDF05X' '3100',
          ' ' 'BDC_OKCODE' '=P+',
          ' ' 'BDC_CURSOR' 'RFOPS_DK-BELNR(01)'.
    ENDDO.
  ENDIF.


  CONCATENATE 'DF05B-PSZAH(' v_pos_tot ')'
    INTO v_pos_parc.

*** Asigna el importe sobrante despues del total al segundo documento
  PERFORM bdc_build_script_record USING:
        'X' 'SAPDF05X' '3100',
        ' ' 'BDC_OKCODE' '=PI',
        ' ' 'BDC_CURSOR' v_pos_parc.


*** Crea el documento
  PERFORM bdc_build_script_record USING:
            'X' 'SAPDF05X' '3100',
            ' ' 'BDC_OKCODE' '=AB'.

*** Crea las posiciones del documento
*** Guarda el documento
*** Ventana forma de pago
*** Manda llamar la transaccion
  PERFORM f_fb05_pant5.

ENDFORM.                    " F_REM_TOT_PAR



*&---------------------------------------------------------------------*
*&      Form  F_REM_PAR
*&      1 Remanente + 1 Parcial
*&---------------------------------------------------------------------*
FORM f_rem_par .
  CLEAR:   i_msg, bdcdata_tab, bdcdata_wa.
  data lv_ciclos type p DECIMALS 2.
  REFRESH: i_msg, bdcdata_tab.

*** Contabilizar y compensar : Datos cabecera
  PERFORM f_fb05_pant1.

*** Contabilizar y compensar : Añadir cta. de mayor
  PERFORM f_fb05_pant2.

*** Ventana Bloque de imputación
  PERFORM f_fb05_pant3.

*** Contabilizar y compensar : Seleccionar partidas abiertas
  PERFORM f_fb05_pant4.

*** Contabilizar y compensar : Entrar condiciones de seleccion
*** indicar documentos a pagar
  PERFORM bdc_build_script_record USING:
          'X' 'SAPMF05A' '0731',
          ' ' 'BDC_OKCODE' '/00'.

  CLEAR: v_pos, v_line, v_pos_tot.

*** Pega Remanente (1:1)
  LOOP AT i_facturas_pagar WHERE tipo = 1.

    LOOP AT i_bsid_doc WHERE vbeln = i_facturas_pagar-vbeln.
      ADD 1 TO v_pos_tot.
      ADD 1 TO v_pos.
      CONCATENATE 'RF05A-SEL01(' v_pos ')' INTO v_line.
      PERFORM bdc_build_script_record USING:
            ' ' v_line i_bsid_doc-belnr.

      IF v_pos = 12.
        PERFORM bdc_build_script_record USING:
                'X' 'SAPMF05A' '0731',
                ' ' 'BDC_OKCODE' '/00'.
        CLEAR: v_pos.
      ENDIF.
    ENDLOOP.
  ENDLOOP.

*** Pega Parcial (1:1)
  READ TABLE i_facturas_pagar WITH KEY tipo = '3'.
  ADD 1 TO v_pos.
  ADD 1 TO v_pos_tot.
  IF v_pos = 12.
        PERFORM bdc_build_script_record USING:
                'X' 'SAPMF05A' '0731',
                ' ' 'BDC_OKCODE' '/00'.
        CLEAR: v_pos.
        ADD 1 TO v_pos.
  ENDIF.

  CONCATENATE 'RF05A-SEL01(' v_pos ')' INTO v_line.
  PERFORM bdc_build_script_record USING:
        ' ' v_line i_facturas_pagar-belnr.


*** Presiona boton Tratar PAs
  PERFORM bdc_build_script_record USING:
          'X' 'SAPMF05A' '0731',
          ' ' 'BDC_OKCODE' '=PA'.

*** Se mueve a la pestaña de "Pago parc."
  PERFORM bdc_build_script_record USING:
        'X' 'SAPDF05X' '3100',
        ' ' 'BDC_OKCODE' '=PART'.


  CLEAR v_pos_parc.
  v_pos = v_pos_tot .

  IF v_pos > 7.
    v_pos_tot = v_pos - 7 .
    lv_ciclos = v_pos / 7.
    lv_ciclos = ceil( lv_ciclos ).
     lv_ciclos = lv_ciclos - 1.

    DO lv_ciclos TIMES.

     PERFORM bdc_build_script_record USING:
          'X' 'SAPDF05X' '3100',
          ' ' 'BDC_OKCODE' '=P+',
          ' ' 'BDC_CURSOR' 'RFOPS_DK-BELNR(01)'.
    ENDDO.
  ENDIF.

  CONCATENATE 'DF05B-PSZAH(' v_pos_tot ')'
    INTO v_pos_parc.



*** Asigna el importe sobrante despues del total al segundo documento
  PERFORM bdc_build_script_record USING:
        'X' 'SAPDF05X' '3100',
        ' ' 'BDC_OKCODE' '=PI',
        ' ' 'BDC_CURSOR' v_pos_parc.


*** Crea el documento
  PERFORM bdc_build_script_record USING:
            'X' 'SAPDF05X' '3100',
            ' ' 'BDC_OKCODE' '=AB'.

*** Crea las posiciones del documento
  PERFORM bdc_build_script_record USING:
            'X' 'SAPMF05A' '0700',
            ' ' 'BDC_OKCODE' '=BS'.

*** Entra a la posicion parcial
  PERFORM bdc_build_script_record USING:
            'X' 'SAPMF05A' '0700',
            ' ' 'BDC_CURSOR' 'RF05A-AZEI1(02)',
            ' ' 'BDC_OKCODE' '=PI'.

*** Agrega la referencia de la factura parcial
  READ TABLE i_facturas_pagar WITH KEY tipo = '3'.
  PERFORM bdc_build_script_record USING:
           'X' 'SAPMF05A' '0301',
*            ' ' 'BDC_CURSOR' 'BSEG-WRBTR
           ' ' 'BDC_OKCODE' '=AB',
           ' ' 'BSEG-ZFBDT' v_fecha_campo,             " Fecha base
           ' ' 'BSEG-ZUONR' i_facturas_pagar-vbeln.    " Asignacion


*** Guarda el documento
  PERFORM bdc_build_script_record USING:
            'X' 'SAPMF05A' '0700',
            ' ' 'BDC_OKCODE' '=BU'.

*** Ventana forma de pago
  PERFORM bdc_build_script_record USING:
              'X' 'SAPLSPO4' '0300',
              ' ' 'BDC_OKCODE' 'FURT',
              ' ' 'SVALD-VALUE(01)' v_forma_pago.

*** Manda llamar la transaccion
  PERFORM f_fb05_llamada.


ENDFORM.                    " F_REM_PAR


*&---------------------------------------------------------------------*
*&      Form  F_REM_TOT
*&      1:n Remanente + 1:n Total
*&---------------------------------------------------------------------*
FORM f_rem_tot .
  CLEAR:   i_msg, bdcdata_tab, bdcdata_wa.
  REFRESH: i_msg, bdcdata_tab.
*** Contabilizar y compensar : Datos cabecera
  PERFORM f_fb05_pant1.

*** Contabilizar y compensar : Añadir cta. de mayor
  PERFORM f_fb05_pant2.

*** Ventana Bloque de imputación
  PERFORM f_fb05_pant3.

*** Contabilizar y compensar : Seleccionar partidas abiertas
  PERFORM f_fb05_pant4.

*** Contabilizar y compensar : Entrar condiciones de seleccion
*** indicar documentos a pagar
  PERFORM bdc_build_script_record USING:
          'X' 'SAPMF05A' '0731',
          ' ' 'BDC_OKCODE' '/00'.

  CLEAR: v_pos, v_line.

*** Pega Remanente (1:1)
  LOOP AT i_facturas_pagar WHERE tipo = 1.
    ADD 1 TO v_pos_tot.
    LOOP AT i_bsid_doc WHERE vbeln = i_facturas_pagar-vbeln.

      ADD 1 TO v_pos.
      CONCATENATE 'RF05A-SEL01(' v_pos ')' INTO v_line.
      PERFORM bdc_build_script_record USING:
            ' ' v_line i_bsid_doc-belnr.

      IF v_pos = 12.
        PERFORM bdc_build_script_record USING:
                'X' 'SAPMF05A' '0731',
                ' ' 'BDC_OKCODE' '/00'.
        CLEAR: v_pos.
      ENDIF.

    ENDLOOP.
  ENDLOOP.

*** Pega Totales (1:n)
  LOOP AT i_facturas_pagar WHERE tipo = '2'.

    ADD 1 TO v_pos.
    ADD 1 TO v_pos_tot.
    CONCATENATE 'RF05A-SEL01(' v_pos ')' INTO v_line.
    PERFORM bdc_build_script_record USING:
          ' ' v_line i_facturas_pagar-belnr.

    IF v_pos = 12.
      PERFORM bdc_build_script_record USING:
              'X' 'SAPMF05A' '0731',
              ' ' 'BDC_OKCODE' '/00'.
      CLEAR: v_pos.
    ENDIF.

  ENDLOOP.

*** Presiona boton Tratar PAs
  PERFORM bdc_build_script_record USING:
          'X' 'SAPMF05A' '0731',
          ' ' 'BDC_OKCODE' '=PA'.

*** Crea el documento
  PERFORM bdc_build_script_record USING:
            'X' 'SAPDF05X' '3100',
            ' ' 'BDC_OKCODE' '=AB'.

  PERFORM f_fb05_pant5.

ENDFORM.                    " F_REM_TOT




*&---------------------------------------------------------------------*
*&      Form  F_FB05_PANT1
*&---------------------------------------------------------------------*
FORM f_fb05_pant1 .

  CLEAR: v_fecha_campo, v_fecha_docum.

  CONCATENATE i_facturas_pagar-fecha_doc+6(2)
              i_facturas_pagar-fecha_doc+4(2)
              i_facturas_pagar-fecha_doc+0(4)
    INTO v_fecha_docum SEPARATED BY '.'.

  IF i_facturas_pagar-budat+0(4) < sy-datum+0(4).
    CONCATENATE sy-datum+6(2)
                sy-datum+4(2)
                sy-datum+0(4)
    INTO v_fecha_campo SEPARATED BY '.'.
  ELSE.
    v_fecha_campo = v_fecha_docum.
  ENDIF.

*** Contabilizar y compensar : Datos cabecera
  PERFORM bdc_build_script_record USING:
          'X' 'SAPMF05A' '0122',
          ' ' 'BDC_OKCODE' '/00',
          ' ' 'BKPF-BLDAT' v_fecha_docum,                   " Fecha documento
          ' ' 'BKPF-BLART' 'DZ',                            " Clase
          ' ' 'BKPF-BUKRS' v_bukrs,                         " Sociedad
          ' ' 'BKPF-BUDAT' v_fecha_campo,                   " Fecha Contab.
          ' ' 'BKPF-MONAT' i_facturas_pagar-budat+4(2),     " Periodo
          ' ' 'BKPF-WAERS' i_facturas_pagar-waers,          " Moneda
          ' ' 'BKPF-XBLNR' v_xblnr,                         " Referencia
          ' ' 'BKPF-BKTXT' v_bktxt,                         " Txt.cab.doc.
          ' ' 'RF05A-AUGTX' v_augtx,                        " Texto compens.
          ' ' 'FS006-DOCID' '*',                            " Clase documento
          ' ' 'RF05A-NEWBS' '40',                           " Clave cuenta
          ' ' 'RF05A-NEWKO' v_cta.                          " Cuenta

ENDFORM.                    " F_FB05_PANT1

*&---------------------------------------------------------------------*
*&      Form  F_FB05_PANT2
*&---------------------------------------------------------------------*
FORM f_fb05_pant2.

*  CLEAR V_FECHA_CAMPO.
*
*  CONCATENATE I_FACTURAS_PAGAR-BUDAT+6(2)
*              I_FACTURAS_PAGAR-BUDAT+4(2)
*              I_FACTURAS_PAGAR-BUDAT+0(4)
*    INTO V_FECHA_CAMPO SEPARATED BY '.'.

*** Contabilizar y compensar : Añadir cta. de mayor


  PERFORM bdc_build_script_record USING:
        'X' 'SAPMF05A' '0300',
        ' ' 'BDC_OKCODE' '=SL',
*        ' ' 'BSEG-WRBTR' I_FACTURAS_PAGAR-NETWR,          " Importe
        ' ' 'BSEG-WRBTR' i_febep-kwbtr,                    " Importe
        ' ' 'BSEG-HBKID' i_febko-hbkid,                         " id banco propio
        ' ' 'BSEG-HKTID' i_febko-hktid,                         " id cuenta banco propio
        ' ' 'BSEG-VALUT' v_fecha_campo,                   " Fecha valor
        ' ' 'BSEG-ZUONR' i_facturas_pagar-vbeln,          " Asignacion
        ' ' 'BSEG-SGTXT' v_texto_pos,                     " Texto
        ' ' 'DKACB-FMORE' 'X'.                            " Checkbox Mas

ENDFORM.                    " F_FB05_PANT2

*&---------------------------------------------------------------------*
*&      Form  F_FB05_PANT3
*&---------------------------------------------------------------------*
FORM f_fb05_pant3 .

*** Ventana Bloque de imputación
  PERFORM bdc_build_script_record USING:
        'X' 'SAPLKACB' '0002',
        ' ' 'BDC_OKCODE' '=ENTE'.

ENDFORM.                    " F_FB05_PANT3

*&---------------------------------------------------------------------*
*&      Form  F_FB05_PANT4
*&---------------------------------------------------------------------*
FORM f_fb05_pant4 .

*** Contabilizar y compensar : Seleccionar partidas abiertas
  PERFORM bdc_build_script_record USING:
          'X' 'SAPMF05A' '0710',
          ' ' 'BDC_OKCODE' '/00',
          ' ' 'RF05A-AGKON' i_facturas_pagar-kunnr,       " Cuenta (Interlocutor)
          ' ' 'RF05A-XNOPS' 'X',                          " Checkbox Pas. normales
          ' ' 'RF05A-XPOS1(01)' '',                       " Opcion Ning.
          ' ' 'RF05A-XPOS1(03)' 'X'.                      " Opcion No. Documento

ENDFORM.                    " F_FB05_PANT4

*&---------------------------------------------------------------------*
*&      Form  F_FB05_PANT5
*&---------------------------------------------------------------------*
FORM f_fb05_pant5 .

*** Crea las posiciones del documento
  PERFORM bdc_build_script_record USING:
            'X' 'SAPMF05A' '0700',
            ' ' 'BDC_OKCODE' '=BS'.

*** Guarda el documento
  PERFORM bdc_build_script_record USING:
            'X' 'SAPMF05A' '0700',
            ' ' 'BDC_OKCODE' '=BU'.

*** Ventana forma de pago
  PERFORM bdc_build_script_record USING:
              'X' 'SAPLSPO4' '0300',
              ' ' 'BDC_OKCODE' 'FURT',
              ' ' 'SVALD-VALUE(01)' v_forma_pago.

*** Manda llamar la transaccion
  PERFORM f_fb05_llamada.

ENDFORM.                    " F_FB05_PANT5

*&---------------------------------------------------------------------*
*&      Form  F_FB05_LLAMADA
*&---------------------------------------------------------------------*
FORM f_fb05_llamada .

  CLEAR: i_msg, wa_msg.
  REFRESH: i_msg.
  DATA: v_mode TYPE c.
  CLEAR v_mode.

  DATA wa_params TYPE ctu_params.


  IF p_modo = 'X'.
  v_mode = 'A'.
ELSE.
  v_mode = 'E'.
ENDIF.

  wa_params-dismode = v_mode. "(modo de visualización)
  "wa_params-updmode = 'S'. "(modo de actualizacion)
  wa_params-defsize = 'X'. "(resolución de la pantalla)
  "wa_params-nobinpt = 'X'. "(ocultar la ventana emergente y la pantalla no deseada)

*CALL TRANSACTION 'FB05' USING bdcdata_tab
*          MODE v_mode
*          MESSAGES INTO i_msg.

CALL TRANSACTION 'FB05' USING bdcdata_tab
      OPTIONS FROM wa_params
      MESSAGES INTO i_msg.



COMMIT WORK AND WAIT.

ENDFORM.                    " F_FB05_LLAMADA
