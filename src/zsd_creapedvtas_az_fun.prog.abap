************************************************************************
************************************************************************
**************** get file para obtener el archivo***********************
************************************************************************
************************************************************************
*- crear una tabla con los archivos y las horas
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

  OPEN DATASET p_file_n FOR INPUT IN TEXT MODE ENCODING NON-UNICODE IGNORING CONVERSION ERRORS.
  IF sy-subrc = 0.
    DO.
      READ DATASET p_file_n INTO wa_tab.
      IF sy-subrc <> 0.
        EXIT.
      ENDIF.

      c = c + 1.

      it_tab-rec = wa_tab.

      APPEND it_tab.

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

    wa_plantillasan-fechaplan = wa_archivos-fecha.

    LOOP AT it_string INTO wa_string.

      cpedido = cpedido + 1.

      IF cpedido = 1.
        wa_datos_pedidos-ticket       = wa_string. "NUMERO DE TICKET SAN

        wa_plantillasan-ticket =      wa_string.
      ENDIF.

      IF cpedido = 2.
        wa_datos_pedidos-auart         = wa_string. "Clase de documento

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
        "***** COPIA PLANTILLA
        wa_plantillasan-spart =       wa_string.
      ENDIF.

      IF cpedido = 6.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = wa_string
          IMPORTING
            output = wa_datos_pedidos-vkbur.
        "***** COPIA PLANTILLA
        wa_plantillasan-vkbur =       wa_string.
      ENDIF.

      IF cpedido = 7.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = wa_string
          IMPORTING
            output = wa_datos_pedidos-vkgrp.

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

  PERFORM cancela_internos.

  PERFORM procesa_cancelados.

  PERFORM procesa_vpg_contado.

  PERFORM ordena_vpg.

  PERFORM separa_sectores.

  PERFORM separa_sectores_vpgi.


*PERFORM Pedidosacrear.

*PERFORM create_ped USING it_datos_pedidos[].
  PERFORM create_ped USING it_datos_pedidosv2[]. "Vpg que no son 18
  PERFORM create_ped USING it_datos_pedidosv182[]. "Vpg que son 18
  PERFORM create_ped USING it_datos_pedidos30f[]. "nominativos que son 30
  PERFORM create_ped USING it_datos_pedidos18f[]. "nominativos que son 18

  PERFORM create_ped USING it_datos_pedidosvpgi01f[].
  PERFORM create_ped USING it_datos_pedidosvpgi11f[].



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

    wa_plantillasan-fechaplan = wa_archivos-fecha.

    LOOP AT it_string INTO wa_string.

      cpedido = cpedido + 1.
************ CODIGO PARA PREPARAR EL EXCEL DE LOS PEDIDOS
*      wa_datos_pedidos-row         = row - 1.
*      ASSIGN COMPONENT 'VBAKAUART' OF STRUCTURE <fs_wa> TO wa_string.
      CASE cpedido.
        WHEN 1.
          wa_datos_pedidos-ticket       = wa_string. "NUMERO DE TICKET SAN
          wa_plantillasan-ticket =      wa_string.
        WHEN 2.
          wa_datos_pedidos-auart         = wa_string. "Clase de documento
          "***** COPIA PLANTILLA
          wa_plantillasan-auart =       wa_string.
        WHEN 3.
          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
            EXPORTING
              input  = wa_string
            IMPORTING
              output = wa_datos_pedidos-vkorg. "Organización de ventas
          wa_plantillasan-vkorg =       wa_string.
        WHEN 4.
          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
            EXPORTING
              input  = wa_string
            IMPORTING
              output = wa_datos_pedidos-vtweg. "Canal de Distribución
          wa_plantillasan-vtweg =       wa_string.
        WHEN 5.
          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
            EXPORTING
              input  = wa_string
            IMPORTING
              output = wa_datos_pedidos-spart. " Sector
          wa_plantillasan-spart =       wa_string.
        WHEN 6.
          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
            EXPORTING
              input  = wa_string
            IMPORTING
              output = wa_datos_pedidos-vkbur. " Oficina de ventas
          wa_plantillasan-vkbur =       wa_string.
        WHEN 7.
          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
            EXPORTING
              input  = wa_string " Grupo de vendedores
            IMPORTING
              output = wa_datos_pedidos-vkgrp.
          wa_plantillasan-vkgrp =       wa_string.
        WHEN 8.

          SELECT SINGLE kunnr INTO lv_sold FROM knb1 WHERE altkn = wa_string.
          IF sy-subrc EQ 0.
            wa_string = lv_sold.
          ENDIF.

          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
            EXPORTING
              input  = wa_string
            IMPORTING
              output = wa_datos_pedidos-sold. "solicitante
          wa_plantillasan-sold =      wa_string.

        WHEN 9.
          wa_datos_pedidos-name1 = wa_string. "Nombre del Cliente
          wa_plantillasan-name1 =       wa_string.
        WHEN 10.
          SELECT SINGLE kunnr INTO lv_sold FROM knb1 WHERE altkn = wa_string.
          IF sy-subrc EQ 0.
            wa_string = lv_sold.
          ENDIF.

          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
            EXPORTING
              input  = wa_string
            IMPORTING
              output = wa_datos_pedidos-ship. "solicitante de envio
          wa_plantillasan-ship =      wa_string.
        WHEN 11.

          TRANSLATE wa_string USING '. '.
          CONDENSE wa_string NO-GAPS.

          CONCATENATE wa_string+4(4) wa_string+2(2) wa_string+0(2) INTO wa_string.
          wa_datos_pedidos-vdatu            = wa_string. " Fecha de entrega
          wa_plantillasan-vdatu =       wa_string.

        WHEN 12.
          TRANSLATE wa_string USING '. '.
          CONDENSE wa_string NO-GAPS.

          CONCATENATE wa_string+4(4) wa_string+2(2) wa_string+0(2) INTO wa_string.
          wa_datos_pedidos-bstdk            = wa_string. "Fecha referencia cliente
          wa_plantillasan-bstdk =       wa_string.

        WHEN 13.
          wa_datos_pedidos-bstkd = wa_string. "Datos referencia cliente
          wa_plantillasan-bstdk = wa_string.
        WHEN 14.
          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
            EXPORTING
              input  = wa_string
            IMPORTING
              output = wa_datos_pedidos-werks. "Centro
          wa_plantillasan-werks =       wa_string.
        WHEN 15.
*          SELECT SINGLE matnr INTO lv_matnr FROM mara WHERE bismt EQ wa_string.
*          IF sy-subrc EQ 0.
*            wa_string = lv_matnr.
*          ENDIF.

          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
            EXPORTING
              input  = wa_string
            IMPORTING
              output = wa_datos_pedidos-matnr. "codigo Material
          wa_plantillasan-matnr =       wa_string.

        WHEN 16.
          wa_datos_pedidos-waerk            = wa_string. "Moneda
          wa_plantillasan-waerk =       wa_string.

        WHEN 17.
          wa_datos_pedidos-kursk            = wa_string. " Tipo de cambio
          wa_plantillasan-kursk =       wa_string.
        WHEN 18.
          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
            EXPORTING
              input  = wa_string
            IMPORTING
              output = wa_datos_pedidos-cust_grp1. "forma de Pago
          wa_plantillasan-formapago = wa_string.
        WHEN 19.
          wa_datos_pedidos-kwmeng = wa_string. " Cantidad Pedida
          wa_plantillasan-kwmeng  = wa_string.
        WHEN 20.
          "no se toma
        WHEN 21.
          wa_datos_pedidos-vrkme            = wa_string. " Unidad de Medida venta
          wa_plantillasan-vrkme =       wa_string.
        WHEN 22.
          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
            EXPORTING
              input  = wa_string
            IMPORTING
              output = wa_datos_pedidos-posnr. "posicion pedido
          wa_plantillasan-posnr =       wa_string.
        WHEN 23.
          TRANSLATE wa_string USING '. '.
          CONDENSE wa_string NO-GAPS.

          CONCATENATE wa_string+4(4) wa_string+2(2) wa_string+0(2) INTO wa_string.
          wa_datos_pedidos-etdat            = wa_string. "fecha de reparto
          wa_plantillasan-etdat =       wa_string.
        WHEN 24.
          "se omite
        WHEN 25.
          wa_datos_pedidos-bmeng            = wa_string. "Cantidad de reparto
          wa_plantillasan-bmeng =       wa_string.
        WHEN 26.
          wa_datos_pedidos-kpein            = '01'. "wa_string. "Contador de condiciones Siempre es 01
          wa_plantillasan-kpein =       wa_string.

        WHEN 27.
          wa_datos_pedidos-dzterm            = wa_string. "Clase de condicion
          wa_plantillasan-dzterm =      wa_string.
        WHEN 28.
          wa_datos_pedidos-kbetr            = wa_string. " Importe condicion. Si existe en hana este sera mandatorio
          wa_plantillasan-kbetr =       wa_string.
        WHEN 29.
          wa_datos_pedidos-route            = wa_string. "Ruta
          wa_plantillasan-route =       wa_string.
        WHEN 30.
          "Validando clases de condición de descuentos para Hana.
          CASE wa_string.
            WHEN 'DEDC'.
              wa_string =  'ZD11'.
            WHEN 'DESC'.
              wa_string = 'ZD02'.
            WHEN OTHERS.
          ENDCASE.

          wa_datos_pedidos-desc            = wa_string." Descuento
          wa_plantillasan-descuento =       wa_string.

        WHEN 31.
          wa_datos_pedidos-porc = wa_string." Descuento
          wa_plantillasan-porc  =       wa_string.
        WHEN 32.
          "se omite
        WHEN 33.
          wa_datos_pedidos-lgort            =  wa_string. "Almacen
          wa_plantillasan-lgort =  wa_string.
        WHEN 34.
          wa_datos_pedidos-texto            = wa_string. "Texto de cabecera
          wa_plantillasan-texto =       wa_string.
        WHEN 35.
          wa_datos_pedidos-fact            = wa_string. "

          wa_plantillasan-fact =      wa_string.

        WHEN 36.
          wa_datos_pedidos-canc            = wa_string. "Marcado cancelado
          wa_plantillasan-canc =      wa_string.
        WHEN 37.
          IF wa_string EQ 'X'.
            wa_datos_pedidos-metpag            = 'PPD'. "metodo de pago
          ELSEIF wa_string EQ space.
            wa_datos_pedidos-metpag            = 'PUE'. "metodo de pago
          ENDIF.

          "***** COPIA PLANTILLA
          wa_plantillasan-metpag =      wa_datos_pedidos-metpag.

        WHEN 38.
          wa_datos_pedidos-vpg            = wa_string. "MArcado para VPG
          wa_plantillasan-vpg =       wa_string.

        WHEN 39.
          wa_datos_pedidos-reft           = wa_string. "REFTICKET
          wa_plantillasan-reft =      wa_string.
        WHEN 40.
          wa_datos_pedidos-gross_wght           = wa_string.
        WHEN 41.
          wa_datos_pedidos-bsark          = wa_string.
          wa_plantillasan-bsark =      wa_string.

          IF wa_datos_pedidos-bsark EQ 'VTRU'.
            CONCATENATE 'VTRU' wa_datos_pedidos-werks '_' wa_datos_pedidos-etdat+6(2)
            wa_datos_pedidos-etdat+4(2) wa_datos_pedidos-etdat+2(2)  INTO wa_plantillasan-nomplan.
          ENDIF.
        WHEN OTHERS.
      ENDCASE.


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

  ENDLOOP.


  PERFORM borra_tickets_creados.


********* Procesos para acomodar pedidos

  PERFORM cancela_internos.

  PERFORM procesa_cancelados.

  PERFORM procesa_vpg_contado.

  PERFORM ordena_vpg.

*  PERFORM separa_sectores.
*  PERFORM separa_sectores_vpgi.


  PERFORM create_ped USING it_datos_pedidos[]. "aqui van todos los pedidos que son a crédito que no son vpg.
  PERFORM create_ped USING it_datos_pedidos_vpg[]. "Vpg de contado

  PERFORM create_ped USING it_datos_pedidos_vpg_i[].


ENDFORM.

************************************************************************
************************************************************************
************* ORDENA VPG******** ***************************************
FORM ordena_vpg.

  it_datos_pedidosv2fp[] = it_datos_pedidos_vpg[].

  SORT it_datos_pedidosv2fp BY vtweg.
  SORT it_datos_pedidosv182fp BY vtweg.


  REFRESH: it_datos_pedidos_vpg.

  DATA: rowo TYPE i,
        poso TYPE i.

  rowo = 0.
  poso = 0.
************************ 30

  poso = 0.

  LOOP AT it_datos_pedidosv2fp INTO wa_datos_pedidosv2fp.

    poso = poso + 10.
    rowo = rowo + 1.
    wa_datos_pedidosv2fp-posnr = poso.
    wa_datos_pedidosv2fp-row = rowo.

    APPEND wa_datos_pedidosv2fp TO it_datos_pedidos_vpg.

  ENDLOOP.
  CLEAR:wa_datos_pedidosv2fp.


*  poso = 0.
*  LOOP AT it_datos_pedidosv2fp INTO wa_datos_pedidosv2fp.
*
*    IF wa_datos_pedidosv2fp-vtweg NE 01.
*      poso = poso + 10.
*      rowo = rowo + 1.
*      wa_datos_pedidosv2fp-posnr = poso.
*      wa_datos_pedidosv2fp-row = rowo.
*
*      APPEND wa_datos_pedidosv2fp TO it_datos_pedidosv2.
*    ENDIF.
*  ENDLOOP.
*  CLEAR:wa_datos_pedidosv2fp.
*
*************************
*  rowo = 0.
*  poso = 0.
*
*  poso = 0.
*
*  LOOP AT it_datos_pedidosv182fp INTO wa_datos_pedidosv182fp.
*
*
*    IF wa_datos_pedidosv182fp-vtweg = 01.
*      poso = poso + 10.
*      rowo = rowo + 1.
*      wa_datos_pedidosv182fp-posnr = poso.
*      wa_datos_pedidosv182fp-row = rowo.
*
*      APPEND wa_datos_pedidosv182fp TO it_datos_pedidosv182.
*    ENDIF.
*
*
*  ENDLOOP.
*
*  CLEAR:wa_datos_pedidosv182fp.


*  poso = 0.
*
*  LOOP AT it_datos_pedidosv182fp INTO wa_datos_pedidosv182fp.
*
*    IF wa_datos_pedidosv182fp-vtweg NE 01.
*      poso = poso + 10.
*      rowo = rowo + 1.
*      wa_datos_pedidosv182fp-posnr = poso.
*      wa_datos_pedidosv182fp-row = rowo.
*
*      APPEND wa_datos_pedidosv182fp TO it_datos_pedidosv182.
*    ENDIF.
*
*  ENDLOOP.


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
        rowvpgi TYPE i,
        pos     TYPE i.

  rowvpg = 0.
******************************************************
  LOOP AT it_datos_pedidos INTO wa_datos_pedidos.

    IF wa_datos_pedidos-vpg = 'X' AND wa_datos_pedidos-metpag EQ 'PUE'.

      rowvpg = rowvpg + 1.

      wa_datos_pedidos-row = rowvpg.

      APPEND wa_datos_pedidos TO it_datos_pedidosv.

    ENDIF.

  ENDLOOP.

  DELETE it_datos_pedidos WHERE vpg = 'X' AND metpag EQ 'PUE'.

  rowvpg = 0.

  pos = 0.


******************************************************
  LOOP AT it_datos_pedidosv INTO wa_datos_pedidosv.
    "ajuste para tomar vpg's individuales
    IF wa_datos_pedidosv-sold EQ lv_vpg. "si son VPG Globales
      pos = pos + 10.

      rowvpg = rowvpg + 1.

      wa_datos_pedidosv-row = rowvpg.

      wa_datos_pedidosv-sold = lv_vpg.
      wa_datos_pedidosv-ship = lv_vpg.


      CONCATENATE wa_datos_pedidosv-bstkd(11) 'VPG' INTO wa_datos_pedidosv-bstkd SEPARATED BY space.

     " wa_datos_pedidosv-posnr = pos.

      APPEND wa_datos_pedidosv TO it_datos_pedidos_vpg.
***************************************************************
      "si son vpgs individuales los guardamos en otra tabla.
    ELSE.

      rowvpgi = rowvpgi + 1.
      wa_datos_pedidosv-row = rowvpgi.
      CONCATENATE wa_datos_pedidosv-bstkd(11) 'VPG' INTO wa_datos_pedidosv-bstkd SEPARATED BY space.
      "wa_datos_pedidosv-posnr = 10.
      APPEND wa_datos_pedidosv TO it_datos_pedidos_vpg_i.


    ENDIF.
  ENDLOOP.
  CLEAR  rowvpg.

  LOOP AT it_datos_pedidos ASSIGNING FIELD-SYMBOL(<fs_pedidos>).
    rowvpg = rowvpg + 1.
    <fs_pedidos>-row = rowvpg.

  ENDLOOP.



ENDFORM.

************************************************************************
************************************************************************
************* SEPARA SECTORES ***************************************

FORM separa_sectores. "02 12 15 18,26,27,28,31,32

  LOOP AT it_datos_pedidos INTO wa_datos_pedidos.

    IF wa_datos_pedidos-spart = 01.

      APPEND wa_datos_pedidos TO it_datos_pedidos30.

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

    READ TABLE it_datos_pedidos30f INTO wa_datos_pedidos30f WITH KEY ticket = wa_datos_pedidos30-ticket.

    IF sy-subrc = 0.

      pos30 = pos30 + 10.

      wa_datos_pedidos30-posnr = pos30.

    ELSE.

      pos30 = 10.

      wa_datos_pedidos30-posnr = pos30.

    ENDIF.

    wa_datos_pedidos30-row = row.
    APPEND wa_datos_pedidos30 TO it_datos_pedidos30f.

  ENDLOOP.



*************** AHORA VAMOS A DARLES NUEVAS POSICIONES POR MISMO ticket
  DATA: pos18 TYPE i.

  row = 0.
  pos18 = 0.

  LOOP AT it_datos_pedidos18 INTO wa_datos_pedidos18.

    row = row + 1.

    READ TABLE it_datos_pedidos18f INTO wa_datos_pedidos18f WITH KEY ticket = wa_datos_pedidos18-ticket.

    IF sy-subrc = 0.

      pos18 = pos18 + 10.

      wa_datos_pedidos18-posnr = pos18.

    ELSE.

      pos18 = 10.

      wa_datos_pedidos18-posnr = pos18.

    ENDIF.

    wa_datos_pedidos18-row = row.
    APPEND wa_datos_pedidos18 TO it_datos_pedidos18f.

  ENDLOOP.

ENDFORM.

****** 29 de enero 2021 VPGI
************************************************************************
************************************************************************
************* ORDENA SECTORES ***************************************
FORM separa_sectores_vpgi.

*  LOOP AT it_datos_pedidos INTO wa_datos_pedidos.
*
*    IF wa_datos_pedidos-spart = 01.
*
*      APPEND wa_datos_pedidos TO it_datos_pedidos30.
*
*    ELSEIF wa_datos_pedidos-spart = 10.
*
*      APPEND wa_datos_pedidos TO it_datos_pedidos18.
*
*    ENDIF.
*
*  ENDLOOP.

*************** AHORA VAMOS A DARLES NUEVAS POSICIONES POR MISMO ticket
  DATA: row   TYPE i,
        pos30 TYPE i.

  row = 0.
  pos30 = 0.

  LOOP AT it_datos_pedidosvpgi2 INTO wa_datos_pedidosvpgi2.

    row = row + 1.

    READ TABLE it_datos_pedidosvpgi01f INTO wa_datos_pedidosvpgi01f WITH KEY ticket = wa_datos_pedidosvpgi2-ticket.

    IF sy-subrc = 0.

      pos30 = pos30 + 10.

      wa_datos_pedidosvpgi2-posnr = pos30.

    ELSE.

      pos30 = 10.

      wa_datos_pedidosvpgi2-posnr = pos30.

    ENDIF.

    wa_datos_pedidosvpgi2-row = row.
    APPEND wa_datos_pedidosvpgi2 TO it_datos_pedidosvpgi01f.

  ENDLOOP.


*************** AHORA VAMOS A DARLES NUEVAS POSICIONES POR MISMO ticket
  DATA: pos18 TYPE i.

  row = 0.
  pos18 = 0.

  LOOP AT it_datos_pedidosvpgi18 INTO wa_datos_pedidosvpgi18.

    row = row + 1.

    READ TABLE it_datos_pedidosvpgi11f INTO wa_datos_pedidosvpgi11f WITH KEY ticket = wa_datos_pedidosvpgi18-ticket.

    IF sy-subrc = 0.

      pos18 = pos18 + 10.

      wa_datos_pedidosvpgi18-posnr = pos18.

    ELSE.

      pos18 = 10.

      wa_datos_pedidosvpgi18-posnr = pos18.

    ENDIF.

    wa_datos_pedidosvpgi18-row = row.
    APPEND wa_datos_pedidosvpgi18 TO it_datos_pedidosvpgi11f.

  ENDLOOP.


ENDFORM.

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
    item-store_loc = 'GPPT'."wa_pedidos-lgort. "Almacen
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

    item-target_qty = wa_pedidos-bmeng."wa_pedidos-gross_wght. " Cantidad Prevista
    itemx-target_qty = 'X'.

    item-net_weight =  wa_pedidos-bmeng. " Cantidad Prevista
    itemx-net_weight = 'X'.

IF  wa_pedidos-vrkme NE 'PZA'.

    item-untof_wght = wa_pedidos-vrkme. "unidad de medida "'EA'.
    itemx-untof_wght = 'X'.

    item-gross_wght =  wa_pedidos-bmeng. " Cantidad Prevista
    itemx-gross_wght = 'X'.
ENDIF.
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
      wa_pedvssan-werks = wa_pedidos-werks.
      wa_pedvssan-bsark = wa_pedidos-bsark.
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

  CLEAR it_tab.REFRESH it_tab.

ENDFORM.

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
*&---------------------------------------------------------------------*
*& Form fill_spart
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM fill_spart .
  "02,12,15, 18,26,27,28,31,32

  wa_spart-option = 'EQ'.
  wa_spart-sign = 'I'.
  wa_spart-low = '02'.
  APPEND wa_spart TO rg_spart.

  wa_spart-option = 'EQ'.
  wa_spart-sign = 'I'.
  wa_spart-low = '12'.
  APPEND wa_spart TO rg_spart.

  wa_spart-option = 'EQ'.
  wa_spart-sign = 'I'.
  wa_spart-low = '15'.
  APPEND wa_spart TO rg_spart.

  wa_spart-option = 'EQ'.
  wa_spart-sign = 'I'.
  wa_spart-low = '18'.
  APPEND wa_spart TO rg_spart.

  wa_spart-option = 'EQ'.
  wa_spart-sign = 'I'.
  wa_spart-low = '26'.
  APPEND wa_spart TO rg_spart.

  wa_spart-option = 'EQ'.
  wa_spart-sign = 'I'.
  wa_spart-low = '27'.
  APPEND wa_spart TO rg_spart.

  wa_spart-option = 'EQ'.
  wa_spart-sign = 'I'.
  wa_spart-low = '28'.
  APPEND wa_spart TO rg_spart.

  wa_spart-option = 'EQ'.
  wa_spart-sign = 'I'.
  wa_spart-low = '31'.
  APPEND wa_spart TO rg_spart.

  wa_spart-option = 'EQ'.
  wa_spart-sign = 'I'.
  wa_spart-low = '32'.
  APPEND wa_spart TO rg_spart.
ENDFORM.
