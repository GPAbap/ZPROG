*&---------------------------------------------------------------------*
*&  Include           ZSD_AUT_CREAPEDVTAS_03_FUNCV2
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&  Include           ZSD_AUT_CREAPEDVTAS_03_FUNC
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&  Include           ZSD_AUT_CREAPEDVTAS_02_FUNC
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&  Include           ZSD_AUT_CREAPEDVTAS_01_FUNC
*&------------------------------------------------------------- -------*

*&---------------------------------------------------------------------*
*&  Include           ZSD_AUT_PEDVTAMAS_F01
*&---------------------------------------------------------------------*

************************************************************************
************************************************************************
**************** get file para obtener el archivo***********************
************************************************************************
************************************************************************
*- Pendiente*** crear una tabla con los archivos y las horas
FORM get_file.

  CONCATENATE lv_directorio
              wa_archivos-werks '/'
              wa_archivos-werks '_'
              wa_archivos-fecha+6(2)
              wa_archivos-fecha+4(2)
              wa_archivos-fecha+2(2)
              '.csv'
    INTO p_file_n.

ENDFORM.


************************************************************************
************************************************************************
**************** Set data para pasar archivo a tabla *******************
************************************************************************
************************************************************************
* Aquí vamos a leer el archivo directo del servidor y, por dataset, vamos
* a pasar los datos del archivo .CSV a una tabla, posterior, tomaremos los
*datos de esta tabla para darle el formato para la BAPI

FORM set_data.
************************************************************************
************************************************************************
************************************************************************
************************************************************************
************************************************************************
  CLEAR it_tab.
  REFRESH it_tab.

  "OPEN DATASET p_file_n FOR INPUT IN TEXT MODE ENCODING DEFAULT.
  OPEN DATASET p_file_n FOR INPUT IN TEXT MODE ENCODING NON-UNICODE IGNORING CONVERSION ERRORS.
  IF sy-subrc = 0.
    DO.
      READ DATASET p_file_n INTO wa_tab.
      IF sy-subrc <> 0.
        EXIT.
      ENDIF.

      c = c + 1.

*      IF c > 5. "if cuando traen cabecera
      it_tab-rec = wa_tab.

      APPEND it_tab.
*      ENDIF.

    ENDDO.
  ENDIF.
  CLOSE DATASET p_file_n.

ENDFORM.


FORM process_data_dir.

  cpedido = 0.



  row = 0.

  "codigo para dividir en columnas

  LOOP AT it_tab.

    row = row + 1.
    wa_datos_pedidos-row         = row.

    SPLIT it_tab-rec AT ',' INTO TABLE it_string.

***** COPIA PLANTILLA
    wa_plantillasan-renglon =       row.

    "***** COPIA PLANTILLA

    CONCATENATE wa_archivos-werks '_' wa_archivos-fecha+6(2) wa_archivos-fecha+4(2) wa_archivos-fecha+2(2) INTO wa_plantillasan-nomplan.

*wa_plantillaSAN-NOMPLAN = p_file_n(17)      . "******falta

    "***** COPIA PLANTILLA
*wa_plantillaSAN-FECHAPLAN =     'fecha de la plantilla' ."*********falta
*wa_plantillaSAN-FECHAPLAN = lv_newdate.
    wa_plantillasan-fechaplan = wa_archivos-fecha.

    LOOP AT it_string INTO wa_string.

      cpedido = cpedido + 1.
************ CODIGO PARA PREPARAR EL EXCEL DE LOS PEDIDOS
*      wa_datos_pedidos-row         = row - 1.
*      ASSIGN COMPONENT 'VBAKAUART' OF STRUCTURE <fs_wa> TO wa_string.
      IF cpedido = 1.
        wa_datos_pedidos-ticket       = wa_string. "NUMERO DE TICKET SAN
        "***** COPIA PLANTILLA
        wa_plantillasan-ticket =      wa_string.
      ENDIF.

      IF cpedido = 2.
        wa_datos_pedidos-auart         = wa_string. "Clase de documento
        "***** COPIA PLANTILLA
        wa_plantillasan-auart =       wa_string.
      ENDIF.

      IF cpedido = 3.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = wa_string
          IMPORTING
            output = wa_datos_pedidos-vkorg.
*                         = WA_STRING. "Organización de ventas

        "***** COPIA PLANTILLA
        wa_plantillasan-vkorg =       wa_string.
      ENDIF.

      IF cpedido = 4.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = wa_string
          IMPORTING
            output = wa_datos_pedidos-vtweg.
        "= WA_STRING."Canal de Distribución
        "***** COPIA PLANTILLA
        wa_plantillasan-vtweg =       wa_string.
      ENDIF.

      IF cpedido = 5.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = wa_string
          IMPORTING
            output = wa_datos_pedidos-spart.
        "= WA_STRING. " Sector
        "***** COPIA PLANTILLA
        wa_plantillasan-spart =       wa_string.
      ENDIF.

      IF cpedido = 6.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = wa_string
          IMPORTING
            output = wa_datos_pedidos-vkbur.
        "=  WA_STRING. " Oficina de ventas
        "***** COPIA PLANTILLA
        wa_plantillasan-vkbur =       wa_string.
      ENDIF.

      IF cpedido = 7.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = wa_string
          IMPORTING
            output = wa_datos_pedidos-vkgrp.
        "wa_datos_pedidos-vkgrp             = WA_STRING. " Grupo de vendedores
        "***** COPIA PLANTILLA
        wa_plantillasan-vkgrp =       wa_string.
      ENDIF.

      IF cpedido = 8.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = wa_string
          IMPORTING
            output = wa_datos_pedidos-sold.
        "***** COPIA PLANTILLA
        wa_plantillasan-sold =      wa_string.
      ENDIF.

      IF cpedido = 9.
        wa_datos_pedidos-name1             = wa_string. "Nombre del Cliente
        "***** COPIA PLANTILLA
        wa_plantillasan-name1 =       wa_string.
      ENDIF.

      IF cpedido = 10.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = wa_string
          IMPORTING
            output = wa_datos_pedidos-ship.
        "***** COPIA PLANTILLA
        wa_plantillasan-ship =      wa_string.
      ENDIF.

      IF cpedido = 11.
        TRANSLATE wa_string USING '. '.
        CONDENSE wa_string NO-GAPS.

        CONCATENATE wa_string+4(4) wa_string+2(2) wa_string+0(2) INTO wa_string.
        wa_datos_pedidos-vdatu            = wa_string. " Fecha de entrega
        "***** COPIA PLANTILLA
        wa_plantillasan-vdatu =       wa_string.
      ENDIF.

      IF cpedido = 12.

        TRANSLATE wa_string USING '. '.
        CONDENSE wa_string NO-GAPS.

        CONCATENATE wa_string+4(4) wa_string+2(2) wa_string+0(2) INTO wa_string.
        wa_datos_pedidos-bstdk            = wa_string. "Fecha referencia cliente

        "***** COPIA PLANTILLA
        wa_plantillasan-bstdk =       wa_string.
      ENDIF.

      IF cpedido = 13.
        wa_datos_pedidos-bstkd            = wa_string. "Datos referencia cliente
      ENDIF.

      IF cpedido = 14.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = wa_string
          IMPORTING
            output = wa_datos_pedidos-werks.
        "wa_datos_pedidos-werks            = wa_string. " Centro
        "***** COPIA PLANTILLA
        wa_plantillasan-werks =       wa_string.
      ENDIF.

      IF cpedido = 15.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = wa_string
          IMPORTING
            output = wa_datos_pedidos-matnr.
        "***** COPIA PLANTILLA
        wa_plantillasan-matnr =       wa_string.
      ENDIF.

      IF cpedido = 16.
        wa_datos_pedidos-waerk            = wa_string. "Moneda
        "***** COPIA PLANTILLA
        wa_plantillasan-waerk =       wa_string.
      ENDIF.

      IF cpedido = 17.
        wa_datos_pedidos-kursk            = wa_string. " Tipo de cambio
        "***** COPIA PLANTILLA
        wa_plantillasan-kursk =       wa_string.
      ENDIF.

      IF cpedido = 18.
        wa_datos_pedidos-cust_grp1         = wa_string. " Forma de pago
        "***** COPIA PLANTILLA
        wa_plantillasan-formapago =       wa_string.
      ENDIF.

      IF cpedido = 19.
        wa_datos_pedidos-kwmeng            = wa_string. " Cantidad Pedida
        "***** COPIA PLANTILLA
        wa_plantillasan-kwmeng =      wa_string.
      ENDIF.

      IF cpedido = 21.
        wa_datos_pedidos-vrkme            = wa_string. " Unidad de Medida
        "***** COPIA PLANTILLA
        wa_plantillasan-vrkme =       wa_string.
      ENDIF.

      "falta 21

      IF cpedido = 22.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = wa_string
          IMPORTING
            output = wa_datos_pedidos-posnr.
        "***** COPIA PLANTILLA
        wa_plantillasan-posnr =       wa_string.
      ENDIF.

      IF cpedido = 23.
        TRANSLATE wa_string USING '. '.
        CONDENSE wa_string NO-GAPS.

        CONCATENATE wa_string+4(4) wa_string+2(2) wa_string+0(2) INTO wa_string.
        wa_datos_pedidos-etdat            = wa_string. "fecha de reparto

        "***** COPIA PLANTILLA
        wa_plantillasan-etdat =       wa_string.
      ENDIF.

*        IF CPEDIDO = 22.
*          wa_datos_pedidos-pstyv            = wa_string. " tipo de posicion
*        ENDIF.

      IF cpedido = 25.
        wa_datos_pedidos-bmeng            = wa_string. "Cantidad de reparto
        "***** COPIA PLANTILLA
        wa_plantillasan-bmeng =       wa_string.
      ENDIF.

      IF cpedido = 26.
        wa_datos_pedidos-kpein            = '01'. "wa_string. "Contador de condiciones Siempre es 01
        "***** COPIA PLANTILLA
        wa_plantillasan-kpein =       wa_string.
      ENDIF.

      IF cpedido = 27.
        wa_datos_pedidos-dzterm            = wa_string."'PR45'."wa_string. "Clase de condicion
        "***** COPIA PLANTILLA
        wa_plantillasan-dzterm =      wa_string.
      ENDIF.

      IF cpedido = 28.
        wa_datos_pedidos-kbetr            = wa_string. " Importe condicion. Si existe en hana este sera mandatorio
        "***** COPIA PLANTILLA
        wa_plantillasan-kbetr =       wa_string.
      ENDIF.

      "RUTA??
      IF cpedido = 29.
        wa_datos_pedidos-route            = wa_string. "Ruta
        "***** COPIA PLANTILLA
        wa_plantillasan-route =       wa_string.
      ENDIF.

      IF cpedido = 30.
        wa_datos_pedidos-desc            = wa_string."Metodo de pago son numeros
        "***** COPIA PLANTILLA
        wa_plantillasan-descuento =       wa_string.
      ENDIF.

      IF cpedido = 18.
        wa_datos_pedidos-porc            = wa_string."Metodo de pago son numeros
        "***** COPIA PLANTILLA
        wa_plantillasan-porc =      wa_string.
      ENDIF.

*        IF CPEDIDO = 32.
*          wa_datos_pedidos-tippor            = wa_string."Metodo de pago son numeros
*        ENDIF.

      IF cpedido = 33.
        wa_datos_pedidos-lgort            = wa_string. "Almacen
        "***** COPIA PLANTILLA
        wa_plantillasan-lgort =       wa_string.
      ENDIF.

      IF cpedido = 34.
        wa_datos_pedidos-texto            = wa_string. "Texto de cabecera
        "***** COPIA PLANTILLA
        wa_plantillasan-texto =       wa_string.
      ENDIF.

*        IF CPEDIDO = 30.
*          wa_datos_pedidos-CUST_GRP1            = wa_string."Metodo de pago son numeros
*        ENDIF.
*
*        IF CPEDIDO = 18.
*          wa_datos_pedidos-CUST_GRP2            = wa_string."Metodo de pago son numeros
*        ENDIF.
      IF cpedido = 35.
        wa_datos_pedidos-fact            = wa_string. "Texto de cabecera
        "***** COPIA PLANTILLA
        wa_plantillasan-fact =      wa_string.
      ENDIF.

      IF cpedido = 36.
        wa_datos_pedidos-canc            = wa_string. "Texto de cabecera
        "***** COPIA PLANTILLA
        wa_plantillasan-canc =      wa_string.
      ENDIF.

      IF cpedido = 37.
        IF wa_string EQ 'X'.
          wa_datos_pedidos-metpag            = 'PPD'. "metodo de pago
        ELSEIF wa_string EQ space.
          wa_datos_pedidos-metpag            = 'PUE'. "metodo de pago
        ENDIF.

        "***** COPIA PLANTILLA
        wa_plantillasan-metpag =      wa_datos_pedidos-metpag.

      ENDIF.

      IF cpedido = 38.
        wa_datos_pedidos-vpg            = wa_string. "Texto de cabecera
        "***** COPIA PLANTILLA
        wa_plantillasan-vpg =       wa_string.
      ENDIF.

      IF cpedido = 39.
        wa_datos_pedidos-reft           = wa_string. "REFTICKET
        "***** COPIA PLANTILLA
        wa_plantillasan-reft =      wa_string.
      ENDIF.

      IF cpedido = 40.
        wa_datos_pedidos-gross_wght           = wa_string. "REFTICKET
        "***** COPIA PLANTILLA
*          wa_plantillaSAN-REFT =      Wa_string.
      ENDIF.

*        IF CPEDIDO = 41.
*          WA_DATOS_PEDIDOS-NET_WEIGHT           = WA_STRING. "REFTICKET
*          "***** COPIA PLANTILLA
**          wa_plantillaSAN-REFT =      Wa_string.
*        ENDIF.

*        IF CPEDIDO = 42.
*          WA_DATOS_PEDIDOS-UNTOF_WGHT           = WA_STRING. "REFTICKET
*          "***** COPIA PLANTILLA
**          wa_plantillaSAN-REFT =      Wa_string.
*        ENDIF.
*
*        IF CPEDIDO = 43.
*          WA_DATOS_PEDIDOS-UNOF_WTISO           = WA_STRING. "REFTICKET
*          "***** COPIA PLANTILLA
**          wa_plantillaSAN-REFT =      Wa_string.
*        ENDIF.

    ENDLOOP.

    IF wa_datos_pedidos-auart NE ''.
********** CASO FACTURADO
* Cuando un ticket se pide que se facture de inmediato, se omite en su creación,
* Por lo que si la posición de ticket facturado viene marcada no se crea el pedido
*        IF wa_datos_pedidos-fact NE 'X'. "eliminamos los facturados
      APPEND wa_datos_pedidos TO it_datos_pedidos.
      cpedido = 0.

      APPEND wa_plantillasan TO it_plantillasan.
      INSERT zsd_tt_plantsan FROM wa_plantillasan.
*        ENDIF.

    ENDIF.

********* OBSERVACIONES 23.09.2020 INI
*borramos los facturados.
    DELETE it_datos_pedidos WHERE fact = 'X'.
********* OBSERVACIONES 23.09.200 FIN

    CLEAR: wa_string,wa_datos_pedidos.
*      REFRESH wa_string.
  ENDLOOP.

  IF sy-subrc = 0.

  ENDIF.

  PERFORM borra_tickets_creados.

*PERFORM COPIA_PLANTILLA.

********* Procesos para acomodar pedidos
*PERFORM RESTA_CANCELADOS.

  PERFORM cancela_internos.

  PERFORM procesa_cancelados.

  PERFORM procesa_vpg_contado.

  PERFORM ordena_vpg.

  PERFORM separa_sectores.

  PERFORM separa_sectores_vpgi.

  PERFORM separa_ordena_of_vtas_vpg. "separamos por oficina de ventas
*PERFORM Pedidosacrear.

*PERFORM create_ped USING it_datos_pedidos[].
  PERFORM create_ped USING it_datos_pedidosv2[]. "Vpg que no son 18
  PERFORM create_ped USING it_datos_pedidosv182[]. "Vpg que son 18
  PERFORM create_ped USING it_datos_pedidos30f[]. "nominativos que son 30
  PERFORM create_ped USING it_datos_pedidos18f[]. "nominativos que son 18

  PERFORM create_ped USING it_datos_pedidosvpgi01f[].
  PERFORM create_ped USING it_datos_pedidosvpgi11f[].

*PERFORM pedidos_creados.
*
*PERFORM pedidos_no_creados.

ENDFORM.


************** MODIFICACIONES CARTA PORTE FIN

************************************************************************
************************************************************************
************************************************************************
************************************************************************
************************************************************************
FORM process_data.
  DATA lv_matnr TYPE matnr.
  DATA lv_sold TYPE kunnr.

  cpedido = 0.



  row = 0.

  "codigo para dividir en columnas

  LOOP AT it_tab.

    row = row + 1.
    wa_datos_pedidos-row         = row.

    SPLIT it_tab-rec AT ',' INTO TABLE it_string.

***** COPIA PLANTILLA
    wa_plantillasan-renglon =       row.

    "***** COPIA PLANTILLA

    CONCATENATE wa_archivos-werks '_' wa_archivos-fecha+6(2) wa_archivos-fecha+4(2) wa_archivos-fecha+2(2) INTO wa_plantillasan-nomplan.

*wa_plantillaSAN-NOMPLAN = p_file_n(17)      . "******falta

    "***** COPIA PLANTILLA
*wa_plantillaSAN-FECHAPLAN =     'fecha de la plantilla' ."*********falta
*wa_plantillaSAN-FECHAPLAN = lv_newdate.
    wa_plantillasan-fechaplan = wa_archivos-fecha.

    LOOP AT it_string INTO wa_string.

      cpedido = cpedido + 1.
************ CODIGO PARA PREPARAR EL EXCEL DE LOS PEDIDOS
*      wa_datos_pedidos-row         = row - 1.
*      ASSIGN COMPONENT 'VBAKAUART' OF STRUCTURE <fs_wa> TO wa_string.
      IF cpedido = 1.
        wa_datos_pedidos-ticket       = wa_string. "NUMERO DE TICKET SAN
        "***** COPIA PLANTILLA
        wa_plantillasan-ticket =      wa_string.
      ENDIF.

      IF cpedido = 2.
        wa_datos_pedidos-auart         = wa_string. "Clase de documento
        "***** COPIA PLANTILLA
        wa_plantillasan-auart =       wa_string.
      ENDIF.

      IF cpedido = 3.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = wa_string
          IMPORTING
            output = wa_datos_pedidos-vkorg.
*                         = WA_STRING. "Organización de ventas

        "***** COPIA PLANTILLA
        wa_plantillasan-vkorg =       wa_string.
      ENDIF.

      IF cpedido = 4.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = wa_string
          IMPORTING
            output = wa_datos_pedidos-vtweg.
        "= WA_STRING."Canal de Distribución
        "***** COPIA PLANTILLA
        wa_plantillasan-vtweg =       wa_string.
      ENDIF.

      IF cpedido = 5.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = wa_string
          IMPORTING
            output = wa_datos_pedidos-spart.
        "= WA_STRING. " Sector
        "***** COPIA PLANTILLA
        wa_plantillasan-spart =       wa_string.
      ENDIF.

      IF cpedido = 6.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = wa_string
          IMPORTING
            output = wa_datos_pedidos-vkbur.
        "=  WA_STRING. " Oficina de ventas
        "***** COPIA PLANTILLA
        wa_plantillasan-vkbur =       wa_string.
      ENDIF.

      IF cpedido = 7.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = wa_string
          IMPORTING
            output = wa_datos_pedidos-vkgrp.
        "wa_datos_pedidos-vkgrp             = WA_STRING. " Grupo de vendedores
        "***** COPIA PLANTILLA
        wa_plantillasan-vkgrp =       wa_string.
      ENDIF.

      IF cpedido = 8.

        SELECT SINGLE kunnr INTO lv_sold FROM knb1 WHERE altkn = wa_string.
        IF sy-subrc EQ 0.
          wa_string = lv_sold.
        ENDIF.


        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = wa_string
          IMPORTING
            output = wa_datos_pedidos-sold.
        "***** COPIA PLANTILLA
        wa_plantillasan-sold =      wa_string.
      ENDIF.

      IF cpedido = 9.
        wa_datos_pedidos-name1             = wa_string. "Nombre del Cliente
        "***** COPIA PLANTILLA
        wa_plantillasan-name1 =       wa_string.
      ENDIF.

      IF cpedido = 10.

        SELECT SINGLE kunnr INTO lv_sold FROM knb1 WHERE altkn = wa_string.
        IF sy-subrc EQ 0.
          wa_string = lv_sold.
        ENDIF.

        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = wa_string
          IMPORTING
            output = wa_datos_pedidos-ship.
        "***** COPIA PLANTILLA
        wa_plantillasan-ship =      wa_string.
      ENDIF.

      IF cpedido = 11.
        TRANSLATE wa_string USING '. '.
        CONDENSE wa_string NO-GAPS.

        CONCATENATE wa_string+4(4) wa_string+2(2) wa_string+0(2) INTO wa_string.
        wa_datos_pedidos-vdatu            = wa_string. " Fecha de entrega
        "***** COPIA PLANTILLA
        wa_plantillasan-vdatu =       wa_string.
      ENDIF.

      IF cpedido = 12.

        TRANSLATE wa_string USING '. '.
        CONDENSE wa_string NO-GAPS.

        CONCATENATE wa_string+4(4) wa_string+2(2) wa_string+0(2) INTO wa_string.
        wa_datos_pedidos-bstdk            = wa_string. "Fecha referencia cliente

        "***** COPIA PLANTILLA
        wa_plantillasan-bstdk =       wa_string.
      ENDIF.

      IF cpedido = 13.
        wa_datos_pedidos-bstkd            = wa_string. "Datos referencia cliente
      ENDIF.

      IF cpedido = 14.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = wa_string
          IMPORTING
            output = wa_datos_pedidos-werks.
        "wa_datos_pedidos-werks            = wa_string. " Centro
        "***** COPIA PLANTILLA
        wa_plantillasan-werks =       wa_string.
      ENDIF.

      IF cpedido = 15.

        "25/10/2022 se consulta el material antiguo. Si se encuentra se trae el equivalente en Hana, de lo contrario
        "se trae directo el de Hana. MGUZMAN

        SELECT SINGLE matnr INTO lv_matnr FROM mara WHERE bismt EQ wa_string.
        IF sy-subrc EQ 0.
          wa_string = lv_matnr.
        ENDIF.


        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = wa_string
          IMPORTING
            output = wa_datos_pedidos-matnr.
        "***** COPIA PLANTILLA
        wa_plantillasan-matnr =       wa_string.
      ENDIF.

      IF cpedido = 16.
        wa_datos_pedidos-waerk            = wa_string. "Moneda
        "***** COPIA PLANTILLA
        wa_plantillasan-waerk =       wa_string.
      ENDIF.

      IF cpedido = 17.
        wa_datos_pedidos-kursk            = wa_string. " Tipo de cambio
        "***** COPIA PLANTILLA
        wa_plantillasan-kursk =       wa_string.
      ENDIF.

      IF cpedido = 18.

        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = wa_string
          IMPORTING
            output = wa_datos_pedidos-cust_grp1.


        "wa_datos_pedidos-cust_grp1         = wa_string. " Forma de pago
        "***** COPIA PLANTILLA
        wa_plantillasan-formapago =       wa_string.
      ENDIF.

      IF cpedido = 19.
        wa_datos_pedidos-kwmeng            = wa_string. " Cantidad Pedida
        "***** COPIA PLANTILLA
        wa_plantillasan-kwmeng =      wa_string.
      ENDIF.

      IF cpedido = 21.
        wa_datos_pedidos-vrkme            = wa_string. " Unidad de Medida
        "***** COPIA PLANTILLA
        wa_plantillasan-vrkme =       wa_string.
      ENDIF.

      "falta 21

      IF cpedido = 22.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = wa_string
          IMPORTING
            output = wa_datos_pedidos-posnr.
        "***** COPIA PLANTILLA
        wa_plantillasan-posnr =       wa_string.
      ENDIF.

      IF cpedido = 23.
        TRANSLATE wa_string USING '. '.
        CONDENSE wa_string NO-GAPS.

        CONCATENATE wa_string+4(4) wa_string+2(2) wa_string+0(2) INTO wa_string.
        wa_datos_pedidos-etdat            = wa_string. "fecha de reparto

        "***** COPIA PLANTILLA
        wa_plantillasan-etdat =       wa_string.
      ENDIF.

*        IF CPEDIDO = 22.
*          wa_datos_pedidos-pstyv            = wa_string. " tipo de posicion
*        ENDIF.

      IF cpedido = 25.
        wa_datos_pedidos-bmeng            = wa_string. "Cantidad de reparto
        "***** COPIA PLANTILLA
        wa_plantillasan-bmeng =       wa_string.
      ENDIF.

      IF cpedido = 26.
        wa_datos_pedidos-kpein            = '01'. "wa_string. "Contador de condiciones Siempre es 01
        "***** COPIA PLANTILLA
        wa_plantillasan-kpein =       wa_string.
      ENDIF.

      IF cpedido = 27.
        wa_datos_pedidos-dzterm            = wa_string."'PR45'."wa_string. "Clase de condicion
        "***** COPIA PLANTILLA
        wa_plantillasan-dzterm =      wa_string.
      ENDIF.

      IF cpedido = 28.
        wa_datos_pedidos-kbetr            = wa_string. " Importe condicion. Si existe en hana este sera mandatorio
        "***** COPIA PLANTILLA
        wa_plantillasan-kbetr =       wa_string.
      ENDIF.

      "RUTA??
      IF cpedido = 29.
        wa_datos_pedidos-route            = wa_string. "Ruta
        "***** COPIA PLANTILLA
        wa_plantillasan-route =       wa_string.
      ENDIF.

      IF cpedido = 30.
        "Validando clases de condición de descuentos para Hana.
        CASE wa_string.
          WHEN 'DEDC'.
            wa_string = 'ZD01'.
          WHEN 'DESC'.
            wa_string = 'ZD02'.
          WHEN OTHERS.
        ENDCASE.


        wa_datos_pedidos-desc            = wa_string."Metodo de pago son numeros
        "***** COPIA PLANTILLA
        wa_plantillasan-descuento =       wa_string.
      ENDIF.

      IF cpedido = 18.
        wa_datos_pedidos-porc            = wa_string."Metodo de pago son numeros
        "***** COPIA PLANTILLA
        wa_plantillasan-porc =      wa_string.
      ENDIF.

*        IF CPEDIDO = 32.
*          wa_datos_pedidos-tippor            = wa_string."Metodo de pago son numeros
*        ENDIF.

      IF cpedido = 33.
        wa_datos_pedidos-lgort            = wa_string. "Almacen
        "***** COPIA PLANTILLA
        wa_plantillasan-lgort =     wa_string.
      ENDIF.

      IF cpedido = 34.
        wa_datos_pedidos-texto            = wa_string. "Texto de cabecera
        "***** COPIA PLANTILLA
        wa_plantillasan-texto =       wa_string.
      ENDIF.

*        IF CPEDIDO = 30.
*          wa_datos_pedidos-CUST_GRP1            = wa_string."Metodo de pago son numeros
*        ENDIF.
*
*        IF CPEDIDO = 18.
*          wa_datos_pedidos-CUST_GRP2            = wa_string."Metodo de pago son numeros
*        ENDIF.
      IF cpedido = 35.
        wa_datos_pedidos-fact            = wa_string. "Texto de cabecera
        "***** COPIA PLANTILLA
        wa_plantillasan-fact =      wa_string.
      ENDIF.

      IF cpedido = 36.
        wa_datos_pedidos-canc            = wa_string. "Texto de cabecera
        "***** COPIA PLANTILLA
        wa_plantillasan-canc =      wa_string.
      ENDIF.

      IF cpedido = 37.
        IF wa_string EQ 'X'.
          wa_datos_pedidos-metpag            = 'PPD'. "metodo de pago
        ELSEIF wa_string EQ space.
          wa_datos_pedidos-metpag            = 'PUE'. "metodo de pago
        ENDIF.

        "***** COPIA PLANTILLA
        wa_plantillasan-metpag =      wa_datos_pedidos-metpag.

      ENDIF.

      IF cpedido = 38.
        wa_datos_pedidos-vpg            = wa_string. "Texto de cabecera
        "***** COPIA PLANTILLA
        wa_plantillasan-vpg =       wa_string.
      ENDIF.

      IF cpedido = 39.
        wa_datos_pedidos-reft           = wa_string. "REFTICKET
        "***** COPIA PLANTILLA
        wa_plantillasan-reft =      wa_string.
      ENDIF.

      IF cpedido = 40.
        wa_datos_pedidos-gross_wght           = wa_string. "REFTICKET
        "***** COPIA PLANTILLA
*          wa_plantillaSAN-REFT =      Wa_string.
      ENDIF.

    ENDLOOP.

    IF wa_datos_pedidos-auart NE ''.
********** CASO FACTURADO
* Cuando un ticket se pide que se facture de inmediato, se omite en su creación,
* Por lo que si la posición de ticket facturado viene marcada no se crea el pedido
*        IF wa_datos_pedidos-fact NE 'X'. "eliminamos los facturados
      APPEND wa_datos_pedidos TO it_datos_pedidos.
      cpedido = 0.

      APPEND wa_plantillasan TO it_plantillasan.
      INSERT zsd_tt_plantsan FROM wa_plantillasan.
*        ENDIF.

    ENDIF.

********* OBSERVACIONES 23.09.2020 INI
*borramos los facturados.
    DELETE it_datos_pedidos WHERE fact = 'X'.
********* OBSERVACIONES 23.09.200 FIN

    CLEAR: wa_string,wa_datos_pedidos.
*      REFRESH wa_string.
  ENDLOOP.

  IF sy-subrc = 0.

  ENDIF.

  PERFORM borra_tickets_creados.
********* Procesos para acomodar pedidos
*PERFORM RESTA_CANCELADOS.

  PERFORM cancela_internos.

  PERFORM procesa_cancelados.

  PERFORM procesa_vpg_contado.

  PERFORM ordena_vpg.

  PERFORM separa_sectores.

  PERFORM separa_sectores_vpgi.

  "PERFORM separa_ordena_of_vtas_vpg. "separamos por oficina de ventas
*PERFORM Pedidosacrear.

*PERFORM create_ped USING it_datos_pedidos[].
  PERFORM create_ped USING it_datos_pedidosv2[]. "Vpg que no son 18
  PERFORM create_ped USING it_datos_pedidosv182[]. "Vpg que son 18
  PERFORM create_ped USING it_datos_pedidos30f[]. "nominativos que son 30
  PERFORM create_ped USING it_datos_pedidos18f[]. "nominativos que son 18

  PERFORM create_ped USING it_datos_pedidosvpgi01f[].
  PERFORM create_ped USING it_datos_pedidosvpgi11f[].

*PERFORM pedidos_creados.
*
*PERFORM pedidos_no_creados.

ENDFORM.
************************************************************************
************************************************************************
************* Resta cancelados******** ***************************************
FORM resta_cancelados.

  LOOP AT it_datos_pedidos INTO wa_datos_pedidos.

    IF wa_datos_pedidos-canc = 'X' AND wa_datos_pedidos-reft NE space.

      APPEND wa_datos_resta TO it_datos_resta.

    ENDIF.

  ENDLOOP.

  LOOP AT it_datos_pedidos INTO wa_datos_pedidos.

    READ TABLE it_datos_resta INTO wa_datos_resta WITH KEY ticket = wa_datos_resta-reft
                                                           matnr = wa_datos_resta-matnr.

    IF sy-subrc = 0.

      wa_datos_resp-kwmeng = wa_datos_resp-kwmeng - wa_datos_resta-kwmeng.

      wa_datos_resp-bmeng = wa_datos_resp-bmeng - wa_datos_resta-bmeng.

*    wa_datos_pedidos-kbetr = wa_datos_pedidos-kbetr - wa_datos_resta-kbetr.

      wa_datos_resp-gross_wght = wa_datos_resp-gross_wght - wa_datos_resta-gross_wght.
    ENDIF.

    IF wa_datos_resp-kwmeng = 0 OR wa_datos_resp-bmeng = 0 OR wa_datos_resp-gross_wght = 0.

      DELETE it_datos_resp WHERE ticket = wa_datos_resp-ticket.

      DELETE it_datos_resp WHERE reft = wa_datos_resp-ticket.
*    AND KWMENG = WA_DATOS_PEDIDOS2-KWMENG
*     AND  MATNR = wa_datos_pedidos2-matnr and BMENG = WA_DATOS_PEDIDOS2-BMENG. "AND KBETR = WA_DATOS_PEDIDOS2-KBETR.

    ENDIF.

    APPEND wa_datos_resp TO it_datos_resp.

  ENDLOOP.

  CLEAR: wa_datos_pedidos, it_datos_pedidos.
  REFRESH:  it_datos_pedidos.

  it_datos_pedidos[] = it_datos_resp[].

  CLEAR: wa_datos_resp.
  REFRESH: it_datos_resp.

ENDFORM.
************************************************************************
************************************************************************
************* Resta cancelados******** ***************************************


************************************************************************
************************************************************************
************* SEPARA y ORDENA Of VTAS******** ***************************************

************************************************************************
************************************************************************
************* SEPARA y ORDENA Of VTAS******** ***************************************
FORM separa_ordena_of_vtas_vpg.

  it_datosauxv2[] = it_datos_pedidosv2[]. "Vpg que no son 18
  it_datosauxv18[] = it_datos_pedidosv182[]. "Vpg que son 18

  SORT it_datosauxv2 BY vkbur.
  SORT it_datosauxv18 BY vkbur.

  REFRESH: it_datos_pedidosv2, it_datos_pedidosv182.

  DATA: row91 TYPE i,
        pos91 TYPE i,
        row93 TYPE i,
        pos93 TYPE i.

  row91 = 0.
  pos91 = 0.

  row93 = 0.
  pos93 = 0.
************************ 0091
  LOOP AT it_datosauxv2 INTO wa_datosauxv2.

*     IF wa_datos_pedidosv2fp-CUST_GRP1 = wa_tvv1-KVGR1.
    IF wa_datosauxv2-vkbur = 0091.


      pos91 = pos91 + 10.
      row91 = row91 + 1.
      wa_datosauxv2-posnr = pos91.
      wa_datosauxv2-row = row91.

      APPEND wa_datosauxv2 TO it_datos_pedidosv2.

    ENDIF.
*     ENDIF.

  ENDLOOP.
  CLEAR: wa_datos_pedidosv2.

************************ 0093
  LOOP AT it_datosauxv2 INTO wa_datosauxv2.

*     IF wa_datos_pedidosv2fp-CUST_GRP1 = wa_tvv1-KVGR1.
    IF wa_datosauxv2-vkbur = 0093.


      pos93 = pos93 + 10.
      row93 = row93 + 1.
      wa_datosauxv2-posnr = pos93.
      wa_datosauxv2-row = row93.

      APPEND wa_datosauxv2 TO it_datos_pedidosv2.

    ENDIF.
*     ENDIF.

  ENDLOOP.
  CLEAR: wa_datosauxv2.
  row91 = 0.
  pos91 = 0.

  row93 = 0.
  pos93 = 0.
****************************************************
****************************************************
****************************************************
****************************************************
****************************************************
*it_datos_pedidosv182[]. "Vpg que son 18

  row91 = 0.
  pos91 = 0.

  row93 = 0.
  pos93 = 0.
************************ 0091
  LOOP AT it_datosauxv18 INTO wa_datosauxv18.

*     IF wa_datos_pedidosv2fp-CUST_GRP1 = wa_tvv1-KVGR1.
    IF wa_datosauxv18-vkbur = 0091.


      pos91 = pos91 + 10.
      row91 = row91 + 1.
      wa_datosauxv18-posnr = pos91.
      wa_datosauxv18-row = row91.

      APPEND wa_datosauxv18 TO it_datos_pedidosv182.

    ENDIF.

*     ENDIF.

  ENDLOOP.
  CLEAR: wa_datosauxv18.

************************ 0093
  LOOP AT it_datosauxv18 INTO wa_datosauxv18.

*     IF wa_datos_pedidosv2fp-CUST_GRP1 = wa_tvv1-KVGR1.
    IF wa_datosauxv18-vkbur = 0093.


      pos93 = pos93 + 10.
      row93 = row93 + 1.
      wa_datosauxv18-posnr = pos93.
      wa_datosauxv18-row = row93.

      APPEND wa_datosauxv18 TO it_datos_pedidosv182.

    ENDIF.
*     ENDIF.

  ENDLOOP.
  CLEAR: wa_datosauxv18.

  row91 = 0.
  pos91 = 0.

  row93 = 0.
  pos93 = 0.



****************************************************
****************************************************
****************************************************
****************************************************
****************************************************
ENDFORM.
************************************************************************
************************************************************************
************* SEPARA y ORDENA Of VTAS******** ***************************************

************************************************************************
************************************************************************
************* ORDENA VPG******** ***************************************
FORM ordena_vpg.

  it_datos_pedidosv2fp[] = it_datos_pedidosv2[].
  it_datos_pedidosv182fp[] = it_datos_pedidosv182[].

  SORT it_datos_pedidosv2fp BY vtweg. "Vpg que no son 18
  SORT it_datos_pedidosv182fp BY vtweg. "Vpg que son 18

*  CLEAR: it_datos_pedidosv2, it_datos_pedidosv182.
  REFRESH: it_datos_pedidosv2, it_datos_pedidosv182.

  DATA: rowo TYPE i,
        poso TYPE i.

  rowo = 0.
  poso = 0.
************************ 30
*LOOP AT it_tvv1 INTO wa_tvv1.

*rowo = 0.
  poso = 0.

  LOOP AT it_datos_pedidosv2fp INTO wa_datos_pedidosv2fp.

*     IF wa_datos_pedidosv2fp-CUST_GRP1 = wa_tvv1-KVGR1.
    IF wa_datos_pedidosv2fp-vtweg = 01.


      poso = poso + 10.
      rowo = rowo + 1.
      wa_datos_pedidosv2fp-posnr = poso.
      wa_datos_pedidosv2fp-row = rowo.

      APPEND wa_datos_pedidosv2fp TO it_datos_pedidosv2.
    ENDIF.
*     ENDIF.

  ENDLOOP.
  CLEAR:wa_datos_pedidosv2fp.
******************** LOOP para sacar los que son canal de distribucion 06
*rowo = 0.
  poso = 0.
  LOOP AT it_datos_pedidosv2fp INTO wa_datos_pedidosv2fp.

    IF wa_datos_pedidosv2fp-vtweg NE 01.
      poso = poso + 10.
      rowo = rowo + 1.
      wa_datos_pedidosv2fp-posnr = poso.
      wa_datos_pedidosv2fp-row = rowo.

      APPEND wa_datos_pedidosv2fp TO it_datos_pedidosv2.
    ENDIF.
  ENDLOOP.
  CLEAR:wa_datos_pedidosv2fp.
*ENDLOOP.
************************ 18
  rowo = 0.
  poso = 0.
*LOOP AT it_tvv1 INTO wa_tvv1.

*rowo = 0.
  poso = 0.

  LOOP AT it_datos_pedidosv182fp INTO wa_datos_pedidosv182fp.

*    IF wa_datos_pedidosv182FP-CUST_GRP1 = wa_tvv1-KVGR1.
    IF wa_datos_pedidosv182fp-vtweg = 01.
      poso = poso + 10.
      rowo = rowo + 1.
      wa_datos_pedidosv182fp-posnr = poso.
      wa_datos_pedidosv182fp-row = rowo.

      APPEND wa_datos_pedidosv182fp TO it_datos_pedidosv182.
    ENDIF.
*    ENDIF.

  ENDLOOP.

  CLEAR:wa_datos_pedidosv182fp.

*  rowo = 0.
  poso = 0.

  LOOP AT it_datos_pedidosv182fp INTO wa_datos_pedidosv182fp.

*    IF wa_datos_pedidosv182FP-CUST_GRP1 = wa_tvv1-KVGR1.
    IF wa_datos_pedidosv182fp-vtweg NE 01.
      poso = poso + 10.
      rowo = rowo + 1.
      wa_datos_pedidosv182fp-posnr = poso.
      wa_datos_pedidosv182fp-row = rowo.

      APPEND wa_datos_pedidosv182fp TO it_datos_pedidosv182.
    ENDIF.
*    ENDIF.

  ENDLOOP.

*ENDLOOP.


  IF sy-subrc = 0.

  ENDIF.
******************************************************

ENDFORM.
************************************************************************
************************************************************************
************* ORDENA VPG******** ***************************************

************************************************************************
************************************************************************
************* BORRA_TICKETS_CREADOS ***************************************
FORM borra_tickets_creados.

* Se van a borrar todos los tickets que ya hayan sido creados.
  LOOP AT it_datos_pedidos INTO wa_tickets_creados.

    READ TABLE it_valida INTO wa_valida WITH KEY ticket = wa_tickets_creados-ticket.

    IF sy-subrc = 0.

      DELETE it_datos_pedidos WHERE ticket = wa_valida-ticket.

    ENDIF.

  ENDLOOP.

ENDFORM.

************* CANCELA INTERNOS ***************************************
FORM cancela_internos.

  LOOP AT it_datos_pedidos INTO wa_datos_pedidos.

    IF wa_datos_pedidos-canc = 'X' AND wa_datos_pedidos-reft EQ space.

      APPEND wa_datos_pedidos TO it_datos_pedidos3.

    ENDIF.

  ENDLOOP.

  LOOP AT it_datos_pedidos3 INTO wa_datos_pedidos3.

    wa_datos_pedidos3-kwmeng = wa_datos_pedidos3-kwmeng * -1.

    wa_datos_pedidos3-bmeng = wa_datos_pedidos3-bmeng * -1.

    wa_datos_pedidos3-kbetr = wa_datos_pedidos3-kbetr * -1.

****** validaciones extra para cancelación 23.09.2020

    " borrando de la tabla de datos principal (borramos los tickets correspondientes)
*    DELETE it_datos_pedidos where TICKET = WA_DATOS_PEDIDOS3-TICKET AND KWMENG = WA_DATOS_PEDIDOS3-KWMENG
*    AND  MATNR = wa_datos_pedidos3-matnr and BMENG = WA_DATOS_PEDIDOS3-BMENG AND KBETR = WA_DATOS_PEDIDOS3-KBETR.

    DELETE it_datos_pedidos WHERE ticket = wa_datos_pedidos3-ticket AND kwmeng = wa_datos_pedidos3-kwmeng
    AND  matnr = wa_datos_pedidos3-matnr AND bmeng = wa_datos_pedidos3-bmeng. "AND KBETR = WA_DATOS_PEDIDOS3-KBETR.

  ENDLOOP.

  " borrando datos de la tabla (borramos los cancelados, los marcados con una equis).
  DELETE it_datos_pedidos WHERE canc = 'X' AND reft EQ space.

  IF sy-subrc = 0.

  ENDIF.


ENDFORM.

************************************************************************
************************************************************************
************* PROCESA CANCELADOS ***************************************
FORM procesa_cancelados.

*it_datos_pedidos2 = it_datos_pedidos.

  LOOP AT it_datos_pedidos INTO wa_datos_pedidos.

    IF wa_datos_pedidos-canc = 'X' AND wa_datos_pedidos-reft NE space.

      APPEND wa_datos_pedidos TO it_datos_pedidos2.

    ENDIF.

  ENDLOOP.

  LOOP AT it_datos_pedidos2 INTO wa_datos_pedidos2.

    wa_datos_pedidos2-kwmeng = wa_datos_pedidos2-kwmeng * -1.

    wa_datos_pedidos2-bmeng = wa_datos_pedidos2-bmeng * -1.

    wa_datos_pedidos2-kbetr = wa_datos_pedidos2-kbetr * -1.
    " borrando de la tabla de datos principal (borramos los tickets correspondientes)
*  DELETE it_datos_pedidos where TICKET = WA_DATOS_PEDIDOS2-REFT AND KWMENG = WA_DATOS_PEDIDOS2-KWMENG
*  AND  MATNR = wa_datos_pedidos2-matnr and BMENG = WA_DATOS_PEDIDOS2-BMENG AND KBETR = WA_DATOS_PEDIDOS2-KBETR.

    DELETE it_datos_pedidos WHERE ticket = wa_datos_pedidos2-reft AND kwmeng = wa_datos_pedidos2-kwmeng
    AND  matnr = wa_datos_pedidos2-matnr AND bmeng = wa_datos_pedidos2-bmeng. "AND KBETR = WA_DATOS_PEDIDOS2-KBETR.


  ENDLOOP.

  " borrando datos de la tabla (borramos los cancelados, los marcados con una equis).
  DELETE it_datos_pedidos WHERE canc = 'X'.

  IF sy-subrc = 0.

  ENDIF.

ENDFORM.

************* PROCESA CANCELADOS ***************************************
************************************************************************
************************************************************************


************************************************************************
************************************************************************
************* PROCESA VPG ***************************************
FORM procesa_vpg_contado.

  DATA: rowvpg  TYPE i,
        rowvpgi TYPE i.

  rowvpg = 0.
******************************************************
  LOOP AT it_datos_pedidos INTO wa_datos_pedidos.

    IF wa_datos_pedidos-vpg = 'X' AND wa_datos_pedidos-metpag NE 'PPD'.

      rowvpg = rowvpg + 1.

      wa_datos_pedidos-row = rowvpg.

      APPEND wa_datos_pedidos TO it_datos_pedidosv.

    ENDIF.

  ENDLOOP.

  DELETE it_datos_pedidos WHERE vpg = 'X' AND metpag NE 'PPD'.

  rowvpg = 0.
******************************************************
  LOOP AT it_datos_pedidosv INTO wa_datos_pedidosv.

*    IF WA_DATOS_PEDIDOSV-SPART = 11.
    IF wa_datos_pedidosv-spart = 10.
      rowvpg = rowvpg + 1.

      wa_datos_pedidosv-row = rowvpg.

      APPEND wa_datos_pedidosv TO it_datos_pedidosv18.

    ENDIF.

  ENDLOOP.

*  DELETE IT_DATOS_PEDIDOSV WHERE SPART = 11.
  DELETE it_datos_pedidosv WHERE spart = 10.
******************************************************

  DATA: pos TYPE i.

  pos = 0.

  rowvpg = 0.
******************************************************
  LOOP AT it_datos_pedidosv INTO wa_datos_pedidosv.
    "ajuste para tomar vpg's individuales
    IF wa_datos_pedidosv-sold EQ lv_vpg.
      pos = pos + 10.

      rowvpg = rowvpg + 1.

      wa_datos_pedidosv-row = rowvpg.

*      wa_datos_pedidosv-sold = '0000700038'. "hay que pasar a tabla z
*      wa_datos_pedidosv-ship = '0000700038'."hay que pasar a tabla z
      wa_datos_pedidosv-sold = lv_vpg. "hay que pasar a tabla z
      wa_datos_pedidosv-ship = lv_vpg."hay que pasar a tabla z


      CONCATENATE wa_datos_pedidosv-bstkd(11) 'VPG' INTO wa_datos_pedidosv-bstkd SEPARATED BY space.

      wa_datos_pedidosv-posnr = pos.

      APPEND wa_datos_pedidosv TO it_datos_pedidosv2.
***************************************************************
      "si son vpgs individuales los guardamos en otra tabla.
    ELSE.

      rowvpgi = rowvpgi + 1.
      wa_datos_pedidosv-row = rowvpgi.
      CONCATENATE wa_datos_pedidosv-bstkd(11) 'VPG' INTO wa_datos_pedidosv-bstkd SEPARATED BY space.
      wa_datos_pedidosv-posnr = 10.
      APPEND wa_datos_pedidosv TO it_datos_pedidosvpgi2.


    ENDIF.
  ENDLOOP.
******************************************************
  pos = 0.

  rowvpg = 0.
******************************************************
  LOOP AT it_datos_pedidosv18 INTO wa_datos_pedidosv18.
    IF wa_datos_pedidosv18-sold EQ lv_vpg.
      pos = pos + 10.

      rowvpg = rowvpg + 1.

      wa_datos_pedidosv18-row = rowvpg.

      wa_datos_pedidosv18-posnr = pos.
*      wa_datos_pedidosv18-sold = '0000700038'.
*      wa_datos_pedidosv18-ship = '0000700038'.
      wa_datos_pedidosv18-sold = lv_vpg.
      wa_datos_pedidosv18-ship = lv_vpg.

      CONCATENATE wa_datos_pedidosv18-bstkd(11) 'VPG' INTO wa_datos_pedidosv18-bstkd SEPARATED BY space.

      APPEND wa_datos_pedidosv18 TO it_datos_pedidosv182.
***************************************************************
      "si son vpgs individuales los guardamos en otra tabla.
    ELSE.

      rowvpgi = rowvpgi + 1.
      wa_datos_pedidosv18-row = rowvpgi.
      CONCATENATE wa_datos_pedidosv18-bstkd(11) 'VPG' INTO wa_datos_pedidosv18-bstkd SEPARATED BY space.
      wa_datos_pedidosv18-posnr = 10.
      APPEND wa_datos_pedidosv18 TO it_datos_pedidosvpgi18.

    ENDIF.
    "ajuste para tomar vpg's individuales
***************************************************************
  ENDLOOP.
******************************************************
  IF sy-subrc = 0.

  ENDIF.

ENDFORM.

************* PROCESA VPG ***************************************
************************************************************************
************************************************************************


************************************************************************
************************************************************************
************* ORDENA SECTORES ***************************************
FORM separa_sectores.

*it_datos_pedidos2 = it_datos_pedidos.

  LOOP AT it_datos_pedidos INTO wa_datos_pedidos.

    IF wa_datos_pedidos-spart = 01.

      APPEND wa_datos_pedidos TO it_datos_pedidos30.

*    ELSEIF WA_DATOS_PEDIDOS-SPART = 11.
    ELSEIF wa_datos_pedidos-spart = 10.

      APPEND wa_datos_pedidos TO it_datos_pedidos18.

    ENDIF.

  ENDLOOP.

*************** AHORA VAMOS A DARLES NUEVAS POSICIONES POR MISMO ticket
  DATA: row   TYPE i,
        pos30 TYPE i.

  row = 0.
  pos30 = 0.

  LOOP AT it_datos_pedidos30 INTO wa_datos_pedidos30.

    row = row + 1.

*  AT NEW ticket.
**    wa_datos_pedidos_30f-posnr = '000000'.
*    pos30 = 0.
*  ENDAT.

    READ TABLE it_datos_pedidos30f INTO wa_datos_pedidos30f WITH KEY ticket = wa_datos_pedidos30-ticket.

    IF sy-subrc = 0.

      pos30 = pos30 + 10.

      wa_datos_pedidos30-posnr = pos30.

    ELSE.

      pos30 = 10.

      wa_datos_pedidos30-posnr = pos30.

    ENDIF.

    wa_datos_pedidos30-row = row.
*  POS30 = POS30 + 10.
*  wa_datos_pedidos30-posnr = pos30.

    APPEND wa_datos_pedidos30 TO it_datos_pedidos30f.

  ENDLOOP.

  IF sy-subrc = 0.

  ENDIF.


*************** AHORA VAMOS A DARLES NUEVAS POSICIONES POR MISMO ticket
  DATA: pos18 TYPE i.

  row = 0.
  pos18 = 0.

  LOOP AT it_datos_pedidos18 INTO wa_datos_pedidos18.

    row = row + 1.

*  AT NEW ticket.
**    wa_datos_pedidos_30f-posnr = '000000'.
*    pos30 = 0.
*  ENDAT.

    READ TABLE it_datos_pedidos18f INTO wa_datos_pedidos18f WITH KEY ticket = wa_datos_pedidos18-ticket.

    IF sy-subrc = 0.

      pos18 = pos18 + 10.

      wa_datos_pedidos18-posnr = pos18.

    ELSE.

      pos18 = 10.

      wa_datos_pedidos18-posnr = pos18.

    ENDIF.

    wa_datos_pedidos18-row = row.
*  POS30 = POS30 + 10.
*  wa_datos_pedidos30-posnr = pos30.

    APPEND wa_datos_pedidos18 TO it_datos_pedidos18f.

  ENDLOOP.

*IF sy-subrc = 0.

*ENDIF.


ENDFORM.

************* ORDENA SECTORES ***************************************
************************************************************************
************************************************************************


****** 29 de enero 2021 VPGI
************************************************************************
************************************************************************
************* ORDENA SECTORES ***************************************
FORM separa_sectores_vpgi.

*it_datos_pedidos2 = it_datos_pedidos.

  LOOP AT it_datos_pedidos INTO wa_datos_pedidos.

    IF wa_datos_pedidos-spart = 01.

      APPEND wa_datos_pedidos TO it_datos_pedidos30.

*    ELSEIF WA_DATOS_PEDIDOS-SPART = 11.
    ELSEIF wa_datos_pedidos-spart = 10.

      APPEND wa_datos_pedidos TO it_datos_pedidos18.

    ENDIF.

  ENDLOOP.

*************** AHORA VAMOS A DARLES NUEVAS POSICIONES POR MISMO ticket
  DATA: row   TYPE i,
        pos30 TYPE i.

  row = 0.
  pos30 = 0.

  LOOP AT it_datos_pedidosvpgi2 INTO wa_datos_pedidosvpgi2.

    row = row + 1.

*  AT NEW ticket.
**    wa_datos_pedidos_30f-posnr = '000000'.
*    pos30 = 0.
*  ENDAT.

    READ TABLE it_datos_pedidosvpgi01f INTO wa_datos_pedidosvpgi01f WITH KEY ticket = wa_datos_pedidosvpgi2-ticket.

    IF sy-subrc = 0.

      pos30 = pos30 + 10.

      wa_datos_pedidosvpgi2-posnr = pos30.

    ELSE.

      pos30 = 10.

      wa_datos_pedidosvpgi2-posnr = pos30.

    ENDIF.

    wa_datos_pedidosvpgi2-row = row.
*  POS30 = POS30 + 10.
*  wa_datos_pedidos30-posnr = pos30.

    APPEND wa_datos_pedidosvpgi2 TO it_datos_pedidosvpgi01f.

  ENDLOOP.

  IF sy-subrc = 0.

  ENDIF.


*************** AHORA VAMOS A DARLES NUEVAS POSICIONES POR MISMO ticket
  DATA: pos18 TYPE i.

  row = 0.
  pos18 = 0.

  LOOP AT it_datos_pedidosvpgi18 INTO wa_datos_pedidosvpgi18.

    row = row + 1.

*  AT NEW ticket.
**    wa_datos_pedidos_30f-posnr = '000000'.
*    pos30 = 0.
*  ENDAT.

    READ TABLE it_datos_pedidosvpgi11f INTO wa_datos_pedidosvpgi11f WITH KEY ticket = wa_datos_pedidosvpgi18-ticket.

    IF sy-subrc = 0.

      pos18 = pos18 + 10.

      wa_datos_pedidosvpgi18-posnr = pos18.

    ELSE.

      pos18 = 10.

      wa_datos_pedidosvpgi18-posnr = pos18.

    ENDIF.

    wa_datos_pedidosvpgi18-row = row.
*  POS30 = POS30 + 10.
*  wa_datos_pedidos30-posnr = pos30.

    APPEND wa_datos_pedidosvpgi18 TO it_datos_pedidosvpgi11f.

  ENDLOOP.

*IF sy-subrc = 0.

*ENDIF.


ENDFORM.

************* ORDENA SECTORES ***************************************
************************************************************************
************************************************************************

********** SEPARA VPGI 29 de enero 2021

************************************************************************
************************************************************************
************************************************************************
************************************************************************
************************************************************************
FORM create_ped USING it_pedidosv.


  DATA: it_pedidos TYPE STANDARD TABLE OF st_datos_pedidos,
        wa_pedidos LIKE LINE OF it_pedidos.

  DATA lv_mensaje TYPE string.



  DATA: it_logp TYPE STANDARD TABLE OF zsd_tt_logsanp,
        it_logh TYPE STANDARD TABLE OF zsd_tt_logsanh,
        wa_logp LIKE LINE OF it_logp,
        wa_logh LIKE LINE OF it_logh.

  it_pedidos[] = it_pedidosv.

  t = 0.

  dsched_line = '0001'.
  indice = 1.
  LOOP AT it_pedidos INTO wa_pedidos.

    logic_switch-cond_handl = 'X'.
*    logic_switch-PRICING = 'C'.

** HEADER DATA
    header-doc_type = wa_pedidos-auart. "Clase de documento
    headerx-doc_type = 'X'.

    header-sales_org = wa_pedidos-vkorg. "Organizacion de ventas
    headerx-sales_org = 'X'.

    header-ref_1  = '0000'.
    headerx-ref_1 = 'X'.
************** MODIFICACIONES MICHAEL 03.09.2020 INI
*    IF WA_PEDIDOS-VKORG = '0002' OR WA_PEDIDOS-VKORG = '0007'.
    IF wa_pedidos-vkorg = 'AV02' OR wa_pedidos-vkorg = 'AV06'.
      header-ord_reason	= 'A05'. "A05 VENTA CONCRETADA EN HANA "'007'.
      headerx-ord_reason  = 'X'.
*    ELSEIF WA_PEDIDOS-VKORG = '0013'.
    ELSEIF wa_pedidos-vkorg = 'AV03'.
      header-ord_reason	= 'A05'."'PPA'.
      headerx-ord_reason  = 'X'.
    ENDIF.
************** MODIFICACIONES MICHAEL 03.09.2020 FIN
    header-distr_chan  = wa_pedidos-vtweg. "canal de distribucion.
    headerx-distr_chan = 'X'.

    header-division = wa_pedidos-spart. "Sector
    headerx-division = 'X'.

    header-sales_grp = wa_pedidos-vkgrp. "Grupo de Vendedores
    headerx-sales_grp = 'X'.

    header-sales_off = wa_pedidos-vkbur. "Oficina de Ventas
    headerx-sales_off = 'X'.

*    header-req_date_h = wa_pedidos-vdatu. "fecha preferente de entrega
    header-req_date_h = sy-datum. "fecha preferente de entrega
    headerx-req_date_h = 'X'.

*    header-purch_date = wa_pedidos-bstdk. "Fecha Referencia del cliente
    header-purch_date = sy-datum. "Fecha Referencia del cliente
    headerx-purch_date = 'X'.

    header-purch_no_c = wa_pedidos-bstkd. "Datos referencia Cliente
    headerx-purch_no_c = 'X'.

************ SE AÑADE numero de ticket a campo de texto posición
*    header-PURCH_NO_S = wa_pedidos-ticket-
*    headerx-PURCH_NO_S = 'X'
*********************************************************

    header-currency = wa_pedidos-waerk. "Moneda
    headerx-currency = 'X'.
    headerx-updateflag = 'I'.

******* AJUSTE CABECERA
*    IF wa_pedidos-VPG = 'X'.
*      header-CUST_GRP1 = '01'. "METODO DE PAGO
*    ELSE.
*      header-CUST_GRP1 = wa_pedidos-CUST_GRP1. "METODO DE PAGO
*    ENDIF.
    header-cust_grp1 = wa_pedidos-cust_grp1. "METODO DE PAGO
    headerx-cust_grp1 = 'X'.
*
*    header-CUST_GRP2 = wa_pedidos-CUST_GRP2. "FORMA
    IF wa_pedidos-metpag EQ space.
      header-cust_grp2 = 'PUE'. "FORMA
    ELSE.
      header-cust_grp2 = wa_pedidos-metpag. "FORMA
    ENDIF.

    headerx-cust_grp2 = 'X'.

    "************* Se agrega la clase de pedido de Ventas de Mostrador, porque son de deposito. en Hana.
    header-po_method = 'VTMO'.
    headerx-po_method = 'X'.
***=======================================================28/11/2022

** PARTNER DATA
    partner-partn_role = 'AG'.
    partner-partn_numb = wa_pedidos-sold. "Cliente

    APPEND partner.

    partner-partn_role = 'WE'.
    partner-partn_numb = wa_pedidos-ship. "Envio Cliente

    APPEND partner.


* ITEM DATA
    itemx-updateflag = 'I'.

    item-material = wa_pedidos-matnr. "MAterial
    itemx-material = 'X'.

    item-exchg_rate = wa_pedidos-kursk. "tipo de cambio
    itemx-exchg_rate = 'X'.

*    item-target_qty = wa_pedidos-bmeng. " Cantidad Prevista
*    itemx-target_qty = 'X'.
*
*    item-target_qu = wa_pedidos-vrkme. "unidad de medida "'EA'.
*    itemx-target_qu = 'X'.

    item-itm_number = wa_pedidos-posnr.    "posicion del documento                               "'000010'.
    itemx-itm_number = wa_pedidos-posnr. "corregido por Michael Chavez

    item-purch_no_s = wa_pedidos-ticket.
    itemx-purch_no_s = 'X'.
*    item-item_categ = wa_pedidos-pstyv. " Tipo de posicion.
*    itemx-item_categ = 'X'.

    "item-PMNTTRMS = wa_pedidos-dzterm. "Clase de condiciones de pago
*itemx-PMNTTRMS = 'X'.
*item-unit_of_weight = wa_pedidos-vrkme. "unidad de medida
*itemx-unit_of_weight = 'X'.


    item-route = wa_pedidos-route. "ruta
    itemx-route = 'X'.

    "Se cambia debido a que  en hana, todo sale del almacen GPPT en producto terminado en depositos
    item-store_loc = wa_pedidos-lgort. "Almacen
    itemx-store_loc = 'X'.

    item-plant    = wa_pedidos-werks. "Centro
    itemx-plant   = 'X'.

******** AÑADIDOS POLLO VIVO PIEZAS Y KG

*    item-target_qty = wa_pedidos-bmeng. " Cantidad Prevista
*    itemx-target_qty = 'X'.


*    item-target_qu = wa_pedidos-vrkme. "unidad de medida "'EA'.
*    itemx-target_qu = 'X'.

    DATA:lv_test TYPE string.

    CALL FUNCTION 'CONVERSION_EXIT_CUNIT_INPUT'
      EXPORTING
        input    = wa_pedidos-vrkme "'PZA'            "Texto comercial.     Eje: CJ (cajas)
        language = sy-langu "Idioma.                   Eje: ES (español)
      IMPORTING
        output   = lv_test. "Unidad de medida. Eje: CS

    item-target_qu = lv_test. "unidad de medida "'EA'.
    itemx-target_qu = 'X'.



    lv_test = ''.
*    item-target_qty = lv_Test.
*    itemx-target_qu = 'X'.

    item-target_qty = wa_pedidos-bmeng."wa_pedidos-gross_wght. " Cantidad Prevista
    itemx-target_qty = 'X'.

    item-net_weight =  wa_pedidos-bmeng. " Cantidad Prevista
    itemx-net_weight = 'X'.

    item-untof_wght = wa_pedidos-vrkme. "unidad de medida "'EA'.
    itemx-untof_wght = 'X'.

    item-gross_wght =  wa_pedidos-bmeng. " Cantidad Prevista
    itemx-gross_wght = 'X'.

*   Fill schedule lines
    lt_schedules_in-itm_number = wa_pedidos-posnr.          "'000010'.
    lt_schedules_in-sched_line = dsched_line.
*    lt_schedules_in-req_qty    = wa_pedidos-kwmeng.
    lt_schedules_in-req_qty    = wa_pedidos-bmeng. "wa_pedidos-gross_wght.

*   Fill schedule line flags
    lt_schedules_inx-itm_number  = wa_pedidos-posnr.        "'000010'.
    lt_schedules_inx-sched_line  = dsched_line.
    lt_schedules_inx-updateflag  = 'X'.
    lt_schedules_inx-req_qty     = 'X'.

    order_cond-itm_number   = wa_pedidos-posnr."posicion.
    order_condx-itm_number   = wa_pedidos-posnr. "corregido Michael TAMBIEN LLEVANUMERO
    order_cond-cond_type    = wa_pedidos-dzterm.""'ZP01'.
    order_condx-cond_type    = 'X'.
    order_cond-cond_value   = wa_pedidos-kbetr. "monto
    order_condx-cond_value   = 'X'.
*    IF wa_pedidos-kbetr is not INITIAL and wa_pedidos-pstyv ne 'TAD'.
*        last_price = wa_pedidos-kbetr.
*    ENDIF.

    order_cond-currency     = wa_pedidos-waerk."moneda.
    order_condx-currency    = 'X'.

************ PRUEBA MICHAEL MODIFICACIONES 04.09.2020 INI
    order_cond-cond_updat   = 'X'.
    order_condx-updateflag  = 'U'.
************ PRUEBA MICHAEL MODIFICACIONES 04.09.2020 FIN

    IF wa_pedidos-texto IS NOT INITIAL.

      itext-text_id = '0001'.
      itext-langu = 'E'.
      itext-text_line = wa_pedidos-texto. "texto de cabecera
      itext-function = '005'.
      APPEND itext.
    ENDIF.


    APPEND item.
    APPEND itemx.
    APPEND lt_schedules_in.
    APPEND lt_schedules_inx.
    APPEND order_cond.
    APPEND order_condx.

***** MODIFICACIONES MICHAEL 18.08.2020 INI
    IF wa_pedidos-desc NE space.
      order_cond-itm_number   = wa_pedidos-posnr."posicion.
      order_condx-itm_number   = wa_pedidos-posnr. "corregido Michael TAMBIEN LLEVANUMERO
      order_cond-cond_type    = wa_pedidos-desc.""'ZP01'.
      order_condx-cond_type    = 'X'.
      order_cond-cond_value   = wa_pedidos-porc. "monto
      order_condx-cond_value   = 'X'.
      order_cond-calctypcon   = wa_pedidos-tippor.
*      order_condx-CALCTYPCON  =  'X'.

      order_cond-currency     = ''."moneda.

      order_cond-cond_unit    = ''."i_tab_dtl-kmein.


      APPEND order_cond.
    ENDIF.

********* TABLA RELACIón PEDIDOS vs SAN
    READ TABLE it_pedvssan INTO wa_pedvssan WITH KEY ticket = wa_pedidos-ticket.

    IF sy-subrc NE 0.

      wa_pedvssan-ticket = wa_pedidos-ticket.
      wa_pedvssan-posnr = wa_pedidos-posnr.
*      wa_pedvssan-vbeln = wa_pedidos-vbeln.

      APPEND wa_pedvssan TO it_pedvssan.

    ENDIF.

***** MODIFICACIONES MICHAEL 18.08.2020 FIN

    indice = indice + 1.

    READ TABLE it_pedidos INTO wa_pedidos WITH KEY row = indice."indice + 1.
    IF sy-subrc EQ 0.
      posnr_aux = wa_pedidos-posnr.
    ELSE.
      posnr_aux = '000010'.
    ENDIF.

    IF posnr_aux EQ '000010'.

* Call the BAPI
      GET RUN TIME FIELD t1.
      REFRESH return.
      CALL FUNCTION 'BAPI_SALESORDER_CREATEFROMDAT2' "'BAPI_SALESDOCU_CREATEFROMDATA1'
        EXPORTING
          order_header_in      = header
          order_header_inx     = headerx
          logic_switch         = logic_switch
        IMPORTING
          salesdocument        = v_vbeln
        TABLES
          return               = return
          order_items_in       = item[]
          order_items_inx      = itemx[]
          order_schedules_in   = lt_schedules_in[]
          order_schedules_inx  = lt_schedules_inx[]
          order_partners       = partner
          order_conditions_in  = order_cond[]
          order_conditions_inx = order_condx[]
          order_text           = itext.

      CLEAR header.
      CLEAR headerx.
      REFRESH partner.
      REFRESH item.
      REFRESH itemx.
      REFRESH lt_schedules_in.
      REFRESH lt_schedules_inx.
      REFRESH order_cond.
      REFRESH order_condx.
      REFRESH itext.

      GET RUN TIME FIELD t2.

      contador = contador + 1.

      IF v_vbeln IS NOT INITIAL.

**************
        LOOP AT it_pedvssan INTO wa_pedvssan.

          IF v_vbeln NE space.
            wa_pedvssan2-ticket = wa_pedvssan-ticket.
            wa_pedvssan2-posnr = wa_pedvssan-posnr.
            wa_pedvssan2-vbeln = v_vbeln.
            wa_pedvssan2-werks = wa_pedvssan-werks.
            wa_pedvssan2-fechacrea = sy-datum.

            INSERT zsd_tt_pedticsan FROM wa_pedvssan2.

          ENDIF.


        ENDLOOP.

        CLEAR: wa_pedvssan, wa_pedvssan2.
        REFRESH: it_pedvssan, it_pedvssan2.
**************

        READ TABLE it_pedidos INTO wa_pedidos WITH KEY row = indice.
        wa_pedidosg-vbeln = v_vbeln.
        wa_pedidosg-auart = wa_pedidos-auart.
        wa_pedidosg-vkorg = wa_pedidos-vkorg.
        wa_pedidosg-vtweg = wa_pedidos-vtweg.
        wa_pedidosg-spart = wa_pedidos-spart.
        wa_pedidosg-route = wa_pedidos-route.
        wa_pedidosg-lgort = wa_pedidos-lgort.
        wa_pedidosg-bstdk = wa_pedidos-bstdk.
        wa_pedidosg-sold  = wa_pedidos-sold.
        wa_pedidosg-name1 = wa_pedidos-name1.
        wa_pedidosg-bmeng = wa_pedidos-bmeng.
        wa_pedidosg-kbetr = last_price. "wa_pedidos-kbetr.
        wa_pedidosg-status = 'Creado'.
        APPEND wa_pedidosg TO it_pedidosg.

********************************** MICHAEL CREACION DE PEDIDO ************
        wa_zpedido-vbeln = v_vbeln.
        wa_zpedido-fechacrea = sy-datum.
        wa_zpedido-auart = wa_pedidos-auart.
        wa_zpedido-vkorg = wa_pedidos-vkorg.
        wa_zpedido-vtweg = wa_pedidos-vtweg.
        wa_zpedido-spart = wa_pedidos-spart.
        wa_zpedido-route = wa_pedidos-route.
        wa_zpedido-lgort = wa_pedidos-lgort.
        wa_zpedido-bstdk = wa_pedidos-bstdk.
        wa_zpedido-sold  = wa_pedidos-sold.
        wa_zpedido-name1 = wa_pedidos-name1.
        wa_zpedido-bmeng = wa_pedidos-bmeng.
        wa_zpedido-kbetr = last_price. "wa_pedidos-kbetr.

        INSERT zsd_tt_pedcreaut FROM wa_zpedido.
********************************** MICHAEL CREACION DE PEDIDO ************

        COMMIT WORK AND WAIT.



*          ****************************
*                Codigo a testear    *
*          ****************************


        t2 = t2 - t1.

*            T = T + T2 / 1000000."N 10000.
        t = t + t2.
        t = t / 1000000.

        ttime = ttime + t.

      ELSE.
        LOOP AT it_pedvssan INTO wa_pedvssan.
          LOOP AT return INTO wa_ret WHERE ( type = 'E' OR type = 'A' ) AND number NE 219.
            wa_logp-ticket = wa_pedvssan-ticket.
            wa_logp-pos    = wa_pedvssan-posnr.
            wa_logp-auart = wa_pedidos-auart.
            wa_logp-vkorg = wa_pedidos-vkorg.
            wa_logp-vtweg = wa_pedidos-vtweg.
            wa_logp-spart = wa_pedidos-spart.
            wa_logp-route = wa_pedidos-route.
            wa_logp-lgort = wa_pedidos-lgort.
            wa_logp-bstdk = wa_pedidos-bstdk.
            wa_logp-sold  = wa_pedidos-sold.
            wa_logp-name1 = wa_pedidos-name1.
            wa_logp-bmeng = wa_pedidos-bmeng.
            wa_logp-kbetr = wa_pedidos-kbetr.
            CONCATENATE wa_ret-message wa_ret-message_v1
            wa_ret-message_v2 wa_ret-message_v3
            wa_ret-message_v4 INTO lv_mensaje SEPARATED BY space.

            wa_logp-message = lv_mensaje.
          ENDLOOP.

          SELECT SINGLE ticket
          FROM zsd_tt_logsanh
          INTO @DATA(it_nocrea2)
                WHERE ticket = @wa_pedvssan-ticket.

          wa_logh-ticket = wa_pedvssan-ticket.
          wa_logh-werks = wa_pedvssan-werks.
          wa_logh-fecha = wa_archivos-fecha.


          IF it_nocrea2 IS NOT INITIAL.
            INSERT zsd_tt_logsanp FROM wa_logp.
          ELSE.
            INSERT zsd_tt_logsanp FROM wa_logp.
            INSERT zsd_tt_logsanh FROM wa_logh.
          ENDIF.
        ENDLOOP.

        CLEAR: wa_nocreados.
        REFRESH: it_nocreados.

      ENDIF.

      LOOP AT return WHERE ( type = 'E' OR type = 'A' ) AND number NE 219.
        APPEND return TO return_all.
        IF v_vbeln IS INITIAL.
          READ TABLE it_pedidos INTO wa_pedidos WITH KEY row = indice.
          wa_pedidosg-vbeln = v_vbeln.
          wa_pedidosg-auart = wa_pedidos-auart.
          wa_pedidosg-vkorg = wa_pedidos-vkorg.
          wa_pedidosg-vtweg = wa_pedidos-vtweg.
          wa_pedidosg-spart = wa_pedidos-spart.
          wa_pedidosg-route = wa_pedidos-route.
          wa_pedidosg-lgort = wa_pedidos-lgort.
          wa_pedidosg-bstdk = wa_pedidos-bstdk.
          wa_pedidosg-sold  = wa_pedidos-sold.
          wa_pedidosg-name1 = wa_pedidos-name1.
          wa_pedidosg-bmeng = wa_pedidos-bmeng.
          wa_pedidosg-kbetr = wa_pedidos-kbetr.
          wa_pedidosg-status = return-message.
          APPEND wa_pedidosg TO it_pedidosg.



        ENDIF.

      ENDLOOP.




    ENDIF.

*    indice = indice + 1.
  ENDLOOP.
* Check the return table.
  LOOP AT return_all WHERE type = 'E' OR type = 'A'.
    EXIT.
  ENDLOOP.

*  IF sy-subrc = 0.
*
*    WRITE: / 'Error al crear documentos de ventas'.
*    WRITE:/ ''.
*    WRITE:/ 'Num. Error', ' Mensaje'.
*    LOOP AT return_all WHERE ( type = 'E' OR type = 'A' ) AND number NE 219  .
*      WRITE:/ return_all-number, return_all-message.
*    ENDLOOP.



*  ELSE.

*    COMMIT WORK AND WAIT.

*    WRITE: / 'Document generados: '.
*    LOOP AT it_pedidosg INTO wa_pedidosg.
*      WRITE:/ wa_pedidosg-vbeln.
*    ENDLOOP.

*  ENDIF.

*WRITE: / 'Tiempo de ejecución: ', Ttime, 'microsegundos  y se contaron ', contador, ' pedidos'.

*PERFORM display.


  CLEAR it_tab.REFRESH it_tab.

ENDFORM.
*****************************************************
*****************************************************
*****************************************************
*************CODIGO PARA CREAR PEDIDO FIN************

************************************************************************
************************************************************************
************************************************************************
************************************************************************
************************************************************************
FORM display.




  ncolumnas = ncolumnas + 1.
  lw_fieldcat-fieldname = 'VBELN'.   "nombre del campo debe ser igual a la interna
  lw_fieldcat-outputlen = 10.
  lw_fieldcat-ref_tabname = 'it_pedidosg'.
  lw_fieldcat-tabname = 'it_pedidosg'.
  lw_fieldcat-seltext_l = 'Documento SAP'.
  lw_fieldcat-col_pos = ncolumnas.
  APPEND lw_fieldcat TO lt_fieldcat.
  CLEAR lw_fieldcat.


  ncolumnas = ncolumnas + 1.
  lw_fieldcat-fieldname = 'AUART'.   "nombre del campo debe ser igual a la interna
  lw_fieldcat-outputlen = 10.
  lw_fieldcat-ref_tabname = 'it_pedidosg'.
  lw_fieldcat-tabname = 'it_pedidosg'.
  lw_fieldcat-seltext_l = 'Clase Doc.'.
  lw_fieldcat-col_pos = ncolumnas.
  APPEND lw_fieldcat TO lt_fieldcat.
  CLEAR lw_fieldcat.

  ncolumnas = ncolumnas + 1.
  lw_fieldcat-fieldname = 'VKORG'.   "nombre del campo debe ser igual a la interna
  lw_fieldcat-outputlen = 10.
  lw_fieldcat-ref_tabname = 'it_pedidosg'.
  lw_fieldcat-tabname = 'it_pedidosg'.
  lw_fieldcat-seltext_l = 'Org. Ventas'.
  lw_fieldcat-col_pos = ncolumnas.
  APPEND lw_fieldcat TO lt_fieldcat.
  CLEAR lw_fieldcat.

  ncolumnas = ncolumnas + 1.
  lw_fieldcat-fieldname = 'VTWEG'.   "nombre del campo debe ser igual a la interna
  lw_fieldcat-outputlen = 10.
  lw_fieldcat-ref_tabname = 'it_pedidosg'.
  lw_fieldcat-tabname = 'it_pedidosg'.
  lw_fieldcat-seltext_l = 'Canal Dist.'.
  lw_fieldcat-col_pos = ncolumnas.
  APPEND lw_fieldcat TO lt_fieldcat.
  CLEAR lw_fieldcat.

  ncolumnas = ncolumnas + 1.
  lw_fieldcat-fieldname = 'SPART'.   "nombre del campo debe ser igual a la interna
  lw_fieldcat-outputlen = 10.
  lw_fieldcat-ref_tabname = 'it_pedidosg'.
  lw_fieldcat-tabname = 'it_pedidosg'.
  lw_fieldcat-seltext_l = 'Sector'.
  lw_fieldcat-col_pos = ncolumnas.
  APPEND lw_fieldcat TO lt_fieldcat.
  CLEAR lw_fieldcat.

  ncolumnas = ncolumnas + 1.
  lw_fieldcat-fieldname = 'ROUTE'.   "nombre del campo debe ser igual a la interna
  lw_fieldcat-outputlen = 10.
  lw_fieldcat-ref_tabname = 'it_pedidosg'.
  lw_fieldcat-tabname = 'it_pedidosg'.
  lw_fieldcat-seltext_l = 'Ruta'.
  lw_fieldcat-col_pos = ncolumnas.
  APPEND lw_fieldcat TO lt_fieldcat.
  CLEAR lw_fieldcat.

  ncolumnas = ncolumnas + 1.
  lw_fieldcat-fieldname = 'LGORT'.   "nombre del campo debe ser igual a la interna
  lw_fieldcat-outputlen = 10.
  lw_fieldcat-ref_tabname = 'it_pedidosg'.
  lw_fieldcat-tabname = 'it_pedidosg'.
  lw_fieldcat-seltext_l = 'Almacen'.
  lw_fieldcat-col_pos = ncolumnas.
  APPEND lw_fieldcat TO lt_fieldcat.
  CLEAR lw_fieldcat.

  ncolumnas = ncolumnas + 1.
  lw_fieldcat-fieldname = 'BSTDK'.   "nombre del campo debe ser igual a la interna
  lw_fieldcat-outputlen = 10.
  lw_fieldcat-ref_tabname = 'it_pedidosg'.
  lw_fieldcat-tabname = 'it_pedidosg'.
  lw_fieldcat-seltext_l = 'Referencia'.
  lw_fieldcat-col_pos = ncolumnas.
  APPEND lw_fieldcat TO lt_fieldcat.
  CLEAR lw_fieldcat.

  ncolumnas = ncolumnas + 1.
  lw_fieldcat-fieldname = 'SOLD'.   "nombre del campo debe ser igual a la interna
  lw_fieldcat-outputlen = 10.
  lw_fieldcat-ref_tabname = 'it_pedidosg'.
  lw_fieldcat-tabname = 'it_pedidosg'.
  lw_fieldcat-seltext_l = 'Num. Cliente'.
  lw_fieldcat-col_pos = ncolumnas.
  APPEND lw_fieldcat TO lt_fieldcat.
  CLEAR lw_fieldcat.

  ncolumnas = ncolumnas + 1.
  lw_fieldcat-fieldname = 'NAME1'.   "nombre del campo debe ser igual a la interna
  lw_fieldcat-outputlen = 10.
  lw_fieldcat-ref_tabname = 'it_pedidosg'.
  lw_fieldcat-tabname = 'it_pedidosg'.
  lw_fieldcat-seltext_l = 'Nom. Cliente'.
  lw_fieldcat-col_pos = ncolumnas.
  APPEND lw_fieldcat TO lt_fieldcat.
  CLEAR lw_fieldcat.

  ncolumnas = ncolumnas + 1.
  lw_fieldcat-fieldname = 'BMENG'.   "nombre del campo debe ser igual a la interna
  lw_fieldcat-outputlen = 10.
  lw_fieldcat-ref_tabname = 'it_pedidosg'.
  lw_fieldcat-tabname = 'it_pedidosg'.
  lw_fieldcat-seltext_l = 'Cantidad'.
  lw_fieldcat-col_pos = ncolumnas.
  APPEND lw_fieldcat TO lt_fieldcat.
  CLEAR lw_fieldcat.

  ncolumnas = ncolumnas + 1.
  lw_fieldcat-fieldname = 'KBETR'.   "nombre del campo debe ser igual a la interna
  lw_fieldcat-outputlen = 10.
  lw_fieldcat-ref_tabname = 'it_pedidosg'.
  lw_fieldcat-tabname = 'it_pedidosg'.
  lw_fieldcat-seltext_l = 'Precio'.
  lw_fieldcat-col_pos = ncolumnas.
  APPEND lw_fieldcat TO lt_fieldcat.
  CLEAR lw_fieldcat.

  ncolumnas = ncolumnas + 1.
  lw_fieldcat-fieldname = 'STATUS'.   "nombre del campo debe ser igual a la interna
  lw_fieldcat-outputlen = 10.
  lw_fieldcat-ref_tabname = 'it_pedidosg'.
  lw_fieldcat-tabname = 'it_pedidosg'.
  lw_fieldcat-seltext_l = 'Status'.
  lw_fieldcat-col_pos = ncolumnas.
  APPEND lw_fieldcat TO lt_fieldcat.
  CLEAR lw_fieldcat.


  lw_layout-colwidth_optimize = 'X'.
*****************FIELDCATS *************************

****************ALV ********************************
  lw_layout-zebra = 'X'.
  lw_layout-expand_fieldname = 'IND'.
  lw_layout-expand_all = 'X'.


  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program      = sy-repid
      i_callback_user_command = 'USER_COMMAND'
      is_layout               = lw_layout
      it_fieldcat             = lt_fieldcat
    TABLES
      t_outtab                = it_pedidosg
    EXCEPTIONS
      program_error           = 1
      OTHERS                  = 2.

ENDFORM.

************************************************************************
************************************************************************
************************************************************************
************************************************************************
************************************************************************
FORM user_command USING r_ucomm TYPE sy-ucomm
rs_selfield TYPE slis_selfield.


  rs_selfield-refresh = 'X'.

  CASE r_ucomm.
    WHEN '&IC1'.

      IF rs_selfield-fieldname = 'vbeln'.
        READ TABLE it_pedidosg INTO wa_pedidosg INDEX rs_selfield-tabindex.
        SET PARAMETER ID 'AUN' FIELD wa_pedidosg-vbeln.
        CALL TRANSACTION 'VA03' AND SKIP FIRST SCREEN.
      ENDIF.
  ENDCASE.


ENDFORM.
************************************************************************
************************************************************************
************************************************************************
************************************************************************
************************************************************************
*&---------------------------------------------------------------------*
*& Form load_tables_conf
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM load_tables_conf .

  SELECT mandt auart_ecc auart_hana vkorg_ecc vkorg_hana vtweg_ecc vtweg_hana spart_ecc
  spart_hana vkbur_ecc vkbur_hana vkgrp_ecc vkgrp_hana
  INTO TABLE it_equivaleppa
  FROM zsd_tt_ppaequsan.

*** equivalencias de Centros.
***PP
  wa_centros-werks_hana = 'PP28'.
  wa_centros-werks_ecc = '0037'.
  APPEND wa_centros TO it_centros. CLEAR wa_centros.

  wa_centros-werks_hana = 'PP27'.
  wa_centros-werks_ecc = '0035'.
  APPEND wa_centros TO it_centros. CLEAR wa_centros.

  wa_centros-werks_hana = 'PP29'.
  wa_centros-werks_ecc = '0344'.
  APPEND wa_centros TO it_centros. CLEAR wa_centros.

  wa_centros-werks_hana = 'PP30'.
  wa_centros-werks_ecc = '0353'.
  APPEND wa_centros TO it_centros. CLEAR wa_centros.

  wa_centros-werks_hana = 'PP12'.
  wa_centros-werks_ecc = '2150'.
  APPEND wa_centros TO it_centros. CLEAR wa_centros.

  wa_centros-werks_hana = 'PP08'.
  wa_centros-werks_ecc = '0338'.
  APPEND wa_centros TO it_centros. CLEAR wa_centros.

  wa_centros-werks_hana = 'PP13'.
  wa_centros-werks_ecc = '2151'.
  APPEND wa_centros TO it_centros. CLEAR wa_centros.

  wa_centros-werks_hana = 'PP14'.
  wa_centros-werks_ecc = '2152'.
  APPEND wa_centros TO it_centros. CLEAR wa_centros.

  wa_centros-werks_hana = 'PP04'.
  wa_centros-werks_ecc = '0327'.
  APPEND wa_centros TO it_centros. CLEAR wa_centros.

  wa_centros-werks_hana = 'PP06'.
  wa_centros-werks_ecc = '0329'.
  APPEND wa_centros TO it_centros. CLEAR wa_centros.

  wa_centros-werks_hana = 'PP02'.
  wa_centros-werks_ecc = '0312'.
  APPEND wa_centros TO it_centros. CLEAR wa_centros.

***AD
  wa_centros-werks_hana = 'AD01'.
  wa_centros-werks_ecc = '0403'.
  APPEND wa_centros TO it_centros. CLEAR wa_centros.

  wa_centros-werks_hana = 'AD02'.
  wa_centros-werks_ecc = '0406'.
  APPEND wa_centros TO it_centros. CLEAR wa_centros.

  wa_centros-werks_hana = 'AD03'.
  wa_centros-werks_ecc = '0409'.
  APPEND wa_centros TO it_centros. CLEAR wa_centros.

  wa_centros-werks_hana = 'AD04'.
  wa_centros-werks_ecc = '0412'.
  APPEND wa_centros TO it_centros. CLEAR wa_centros.

  wa_centros-werks_hana = 'AD05'.
  wa_centros-werks_ecc = '0414'.
  APPEND wa_centros TO it_centros. CLEAR wa_centros.

  wa_centros-werks_hana = 'AD06'.
  wa_centros-werks_ecc = '0424'.
  APPEND wa_centros TO it_centros. CLEAR wa_centros.

  wa_centros-werks_hana = 'AD06'.
  wa_centros-werks_ecc = '0424'.
  APPEND wa_centros TO it_centros. CLEAR wa_centros.

  wa_centros-werks_hana = 'AD07'.
  wa_centros-werks_ecc = '0427'.
  APPEND wa_centros TO it_centros. CLEAR wa_centros.

  wa_centros-werks_hana = 'AD08'.
  wa_centros-werks_ecc = '0429'.
  APPEND wa_centros TO it_centros. CLEAR wa_centros.

  wa_centros-werks_hana = 'AD09'.
  wa_centros-werks_ecc = '0430'.
  APPEND wa_centros TO it_centros. CLEAR wa_centros.

  wa_centros-werks_hana = 'AD10'.
  wa_centros-werks_ecc = '0431'.
  APPEND wa_centros TO it_centros. CLEAR wa_centros.

  wa_centros-werks_hana = 'AD11'.
  wa_centros-werks_ecc = '0432'.
  APPEND wa_centros TO it_centros. CLEAR wa_centros.

  wa_centros-werks_hana = 'AD12'.
  wa_centros-werks_ecc = '0433'.
  APPEND wa_centros TO it_centros. CLEAR wa_centros.

  wa_centros-werks_hana = 'AD13'.
  wa_centros-werks_ecc = '0434'.
  APPEND wa_centros TO it_centros. CLEAR wa_centros.

  wa_centros-werks_hana = 'AD14'.
  wa_centros-werks_ecc = '0435'.
  APPEND wa_centros TO it_centros. CLEAR wa_centros.

  wa_centros-werks_hana = 'AD15'.
  wa_centros-werks_ecc = '0402'.
  APPEND wa_centros TO it_centros. CLEAR wa_centros.


************************************************************


  SELECT auart INTO CORRESPONDING FIELDS OF TABLE it_tvakt FROM tvakt WHERE spras = 'S'.
  SELECT vkorg INTO CORRESPONDING FIELDS OF TABLE it_tvko FROM tvko.
  SELECT vtweg INTO CORRESPONDING FIELDS OF TABLE it_TVTW FROM tvtw.
  SELECT vkorg vtweg spart INTO CORRESPONDING FIELDS OF TABLE  it_TVTA FROM tvta.
  SELECT vkorg vtweg spart vkbur INTO CORRESPONDING FIELDS OF TABLE it_TVKBZ FROM tvkbz.
  SELECT vkbur vkgrp INTO CORRESPONDING FIELDS OF TABLE it_TVBVK  FROM tvbvk.
  SELECT augru INTO CORRESPONDING FIELDS OF TABLE it_TVAU FROM tvau.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form update_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM update_data .

  TYPES: BEGIN OF st_dzterm,
           dzterm_ecc  TYPE dzterm,
           dzterm_hana TYPE dzterm,
         END OF st_dzterm.

*  TYPES: BEGIN OF st_vkorg,
*    vkorg_ecc TYPE vkorg,
*    vkorg_hana TYPE vkorg,
*  END OF st_vkorg.

  DATA: it_dzterm TYPE STANDARD TABLE OF st_dzterm,
        wa_dzterm LIKE LINE OF it_dzterm.

  FIELD-SYMBOLS <wa_pedidos> TYPE st_datos_pedidos.
*        it_vkorg TYPE STANDARD TABLE OF st_vkorg,
*        wa_vkorg LIKE LINE OF it_vkorg.

**---------- Condición de Venta (credito / contado )
  wa_dzterm-dzterm_ecc = 'PR25'.
  wa_dzterm-dzterm_hana = 'ZV06'.
  APPEND wa_dzterm TO it_dzterm.

  wa_dzterm-dzterm_ecc = 'PR26'.
  wa_dzterm-dzterm_hana = 'ZV07'.
  APPEND wa_dzterm TO it_dzterm.

  wa_dzterm-dzterm_ecc = 'PR27'.
  wa_dzterm-dzterm_hana = 'ZV08'.
  APPEND wa_dzterm TO it_dzterm.

  wa_dzterm-dzterm_ecc = 'PR28'.
  wa_dzterm-dzterm_hana = 'ZV09'.
  APPEND wa_dzterm TO it_dzterm.

  wa_dzterm-dzterm_ecc = 'PR45'.
  wa_dzterm-dzterm_hana = 'ZV13'.
  APPEND wa_dzterm TO it_dzterm.

  wa_dzterm-dzterm_ecc = 'PR46'.
  wa_dzterm-dzterm_hana = 'ZV14'.
  APPEND wa_dzterm TO it_dzterm.
*****-----------------------------------




  LOOP AT it_datos_pedidos ASSIGNING <wa_pedidos>.
    "equivalencia oficina de ventas
    READ TABLE it_equivaleppa INTO DATA(wa_vkorg) WITH KEY vkorg_ecc = <wa_pedidos>-vkorg.
    IF sy-subrc EQ 0.
      <wa_pedidos>-vkorg = wa_vkorg-vkorg_hana.
    ENDIF.

    "equivalencia canal de distribucion
    READ TABLE it_equivaleppa INTO DATA(wa_vtweg) WITH KEY vtweg_ecc = <wa_pedidos>-vtweg.
    IF sy-subrc EQ 0.
      <wa_pedidos>-vtweg = wa_vtweg-vtweg_hana.
    ENDIF.

    "equivalencia spart
    READ TABLE it_equivaleppa INTO DATA(wa_spart) WITH KEY spart_ecc = <wa_pedidos>-spart.
    IF sy-subrc EQ 0.
      <wa_pedidos>-spart = wa_spart-spart_hana.
    ENDIF.

    "equivalencia Clase de Documento
    READ TABLE it_equivaleppa INTO DATA(wa_auart) WITH KEY auart_ecc = <wa_pedidos>-auart vkorg_hana = <wa_pedidos>-vkorg.
    IF sy-subrc EQ 0.
      <wa_pedidos>-auart = wa_auart-auart_hana.
    ENDIF.

    "equivalencia oficina de ventas
    READ TABLE it_equivaleppa INTO DATA(wa_vkbur) WITH KEY vkbur_ecc = <wa_pedidos>-vkbur.
    IF sy-subrc EQ 0.
      <wa_pedidos>-vkbur = wa_vkbur-vkbur_hana.
    ENDIF.

    "equivalencia grupo de vendedores
    READ TABLE it_equivaleppa INTO DATA(wa_vkGRP) WITH KEY vkgrp_ecc = <wa_pedidos>-vkgrp.
    IF sy-subrc EQ 0.
      <wa_pedidos>-vkgrp = wa_vkgrp-vkgrp_hana.
    ENDIF.


    "equivalencias centro
    READ TABLE it_centros INTO wa_centros WITH KEY werks_ecc = <wa_pedidos>-werks.
    IF sy-subrc EQ 0.
      <wa_pedidos>-werks = wa_centros-werks_hana.
    ENDIF.

    "Equivalencia Dztermn Condicion de pago
    CLEAR wa_dzterm.
    READ TABLE it_dzterm INTO wa_dzterm WITH KEY dzterm_ecc = <wa_pedidos>-dzterm.
    IF sy-subrc EQ 0.
      <wa_pedidos>-dzterm = wa_dzterm-dzterm_hana.
    ENDIF.

  ENDLOOP.
ENDFORM.
