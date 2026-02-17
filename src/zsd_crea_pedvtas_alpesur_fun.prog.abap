*&---------------------------------------------------------------------*
*& Include zsd_crea_pedvtas_alpesur_fun
*&---------------------------------------------------------------------*

FORM get_parametros.

  "obtener 5 dias de pedidos creados anteriormente a la fecha de ejecución
  CALL FUNCTION 'RP_CALC_DATE_IN_INTERVAL'
    EXPORTING
      date      = sy-datum
      days      = ndias
      months    = 00
      signum    = '-'
      years     = 00
    IMPORTING
      calc_date = lv_datecrea.



  "se obtienen los depositos activos para generar pedidos de venta
  SELECT werks
    FROM zsd_tt_configsan
    INTO TABLE @DATA(it_dep)
    WHERE activado = 'X'.
  """"""""ruta del repositorio de archivos de SAN
  SELECT SINGLE directorio
  FROM zsd_tt_dirsftp
  INTO lv_directorio
  WHERE reservado1 = 'X'.
  """""se obtienen todos los tickets que se crearon a partir de la fecha de
  """""""de ejecución y 5 dias antras.
  SELECT ticket, werks, posnr, nomplan, fechaplan
  FROM zsd_tt_plantsan
    INTO TABLE @it_valida
  WHERE fechaplan BETWEEN @lv_datecrea AND @sy-datum.
  """""""""""""""se obtienen los clientes VPG

  SELECT werks, cliente
  INTO TABLE @it_clientes_vpg
  FROM zsd_tt_configvpg.

  """""

  SELECT mandt, ruta_file, fechafile INTO TABLE @it_files
    FROM zsd_tt_san_files
  WHERE fechafile BETWEEN @lv_datecrea AND @sy-datum.
  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""


  "Se llena la tabla it_archivos para extraer los archivos del repositorio
  LOOP AT it_dep INTO DATA(wa_dep).
    DATA(lv_fecha) = lv_datecrea.
    DO ndias TIMES.

      CALL FUNCTION 'RP_CALC_DATE_IN_INTERVAL'
        EXPORTING
          date      = lv_fecha
          days      = 1
          months    = 00
          signum    = '+'
          years     = 00
        IMPORTING
          calc_date = lv_fecha.


      wa_archivos-werks = wa_dep-werks.
      wa_archivos-fecha = lv_fecha.
      APPEND wa_archivos TO it_archivos.

      w_rg_fechas-option = 'EQ'.
      w_rg_fechas-sign = 'I'.
      w_rg_fechas-low = lv_fecha.
      APPEND w_rg_fechas TO rg_fechas.
      CLEAR w_rg_fechas.
    ENDDO.

  ENDLOOP.
  SORT rg_fechas BY low.
  DELETE ADJACENT DUPLICATES FROM rg_fechas COMPARING ALL FIELDS.

ENDFORM.

FORM limpiar_tablas. "por cada revisión de deposito, se limpian todas las tablas para evitar
  "se queden datos de otro deposito

  REFRESH: "it_datos_pedidos,
           it_plantillaSAN,
           it_tab.

  CLEAR: wa_datos_pedidos,
         wa_plantillasan,
         wa_row.
ENDFORM.
"""""""""""""ruta y nombre de archivo pedidos con ruta

FORM get_files_rutas USING p_werks TYPE werks_d.



  DATA: vl_name(50)      TYPE c, vl_ext(6) TYPE c, vl_fecha TYPE string, vl_fecha_file(6) TYPE c.
  DATA: vl_long TYPE i.
  DATA: vl_directorioc TYPE eps2filnam.
  DATA vl_ifile TYPE STANDARD TABLE OF eps2fili.


  DATA: vl_rg_fechas TYPE RANGE OF string,
        wa_rg_fechas LIKE LINE OF vl_rg_fechas.

  CONCATENATE lv_directorio
              p_werks '/RUTAS/'
  INTO lv_directoriocp.

  vl_directorioc = lv_directoriocp.

  CALL FUNCTION 'ZEPS2_GET_DIRECTORY_LISTING'
    EXPORTING
      iv_dir_name            = vl_directorioc
    TABLES
      dir_list               = vl_ifile
      zrg_fechas             = rg_fechas
    EXCEPTIONS
      invalid_eps_subdir     = 1
      sapgparam_failed       = 2
      build_directory_failed = 3
      no_authorization       = 4
      read_directory_failed  = 5
      too_many_read_errors   = 6
      empty_directory_list   = 7
      OTHERS                 = 8.


*  LOOP AT rg_fechas INTO DATA(w_fechas).
*
*    CONCATENATE  w_fechas-low+6(2) '.'
*                 w_fechas-low+4(2) '.'
*                 w_fechas-low+0(4)
*             INTO vl_fecha.
*
*    wa_rg_fechas-sign = 'I'.
*    wa_rg_fechas-option = 'EQ'.
*    wa_rg_fechas-low = vl_fecha.
*    APPEND wa_rg_fechas TO vl_rg_fechas.
*    CLEAR vl_fecha.
*
*  ENDLOOP.



*  SORT vl_ifile BY mtim ASCENDING.
*  LOOP AT vl_ifile ASSIGNING FIELD-SYMBOL(<wa>).
*    <wa>-mtim = <wa>-mtim+0(10).
*    CONDENSE <wa>-mtim NO-GAPS.
*  ENDLOOP.

*  DELETE vl_ifile WHERE mtim NOT IN vl_rg_fechas.
  APPEND LINES OF vl_ifile TO ifile.
ENDFORM.

"""""""""""""ruta y nombre de archivo pedidos normales

FORM get_file USING "p_directorio TYPE char80
                    p_werks TYPE werks_d.
*                    p_fecha TYPE sy-datum
*              CHANGING p_file_n.

*  CONCATENATE p_directorio
*              p_werks '/'
*              p_werks '_'
*              p_fecha+6(2)
*              p_fecha+4(2)
*              p_fecha+2(2)
*              '.csv'
*    INTO p_file_n.



  DATA: vl_name(50)      TYPE c, vl_ext(6) TYPE c, vl_fecha TYPE string, vl_fecha_file(6) TYPE c.
  DATA: vl_long TYPE i.
  DATA: vl_directorioc TYPE eps2filnam.
  DATA vl_ifile TYPE STANDARD TABLE OF eps2fili.


  DATA: vl_rg_fechas TYPE RANGE OF string,
        wa_rg_fechas LIKE LINE OF vl_rg_fechas.

  CONCATENATE lv_directorio
              p_werks '/'
  INTO lv_directoriocp.

  vl_directorioc = lv_directoriocp.

  CALL FUNCTION 'ZEPS2_GET_DIRECTORY_LISTING'
    EXPORTING
      iv_dir_name            = vl_directorioc
    TABLES
      dir_list               = vl_ifile
      zrg_fechas             = rg_fechas
    EXCEPTIONS
      invalid_eps_subdir     = 1
      sapgparam_failed       = 2
      build_directory_failed = 3
      no_authorization       = 4
      read_directory_failed  = 5
      too_many_read_errors   = 6
      empty_directory_list   = 7
      OTHERS                 = 8.


  APPEND LINES OF vl_ifile TO ifile.


ENDFORM.


* Aquí vamos a leer el archivo directo del servidor y, por dataset, vamos
* a pasar los datos del archivo .CSV a una tabla, posterior, tomaremos los
*datos de esta tabla para darle el formato para la BAPI

FORM set_data USING p_file_n TYPE localfile.
************************************************************************

  DATA c TYPE i.

  OPEN DATASET p_file_n FOR INPUT IN TEXT MODE ENCODING NON-UNICODE IGNORING CONVERSION ERRORS.
  IF sy-subrc = 0.
    DO.
      READ DATASET p_file_n INTO wa_row.
      IF sy-subrc <> 0.
        EXIT.
      ENDIF.

      c = c + 1.
*      it_tab-rec = wa_tab.
*      APPEND it_tab.
      APPEND wa_row TO it_tab.

    ENDDO.
  ENDIF.
  CLOSE DATASET p_file_n.


ENDFORM.

FORM fill_it_pedidos USING p_werks TYPE werks_d
                           p_fecha TYPE sy-datum
                           p_file_n TYPE localfile
                           p_bsark TYPE bsark.

  DATA lv_matnr TYPE matnr18.
  DATA lv_sold TYPE kunnr.
  DATA: cpedido TYPE i, row TYPE i.


  cpedido = 0.
  row = 0.

  LOOP AT it_tab INTO DATA(wa_itab).

    CLEAR: lv_matnr, lv_sold.
    row = row + 1.
    wa_datos_pedidos-row = row.

    SPLIT wa_itab-srec AT ',' INTO TABLE it_string.
    wa_plantillasan-renglon = row.

    CONCATENATE p_werks '_' p_fecha+6(2) p_fecha+4(2) p_fecha+2(2) INTO wa_plantillasan-nomplan.
    wa_plantillasan-fechaplan = p_fecha.

    LOOP AT it_string INTO DATA(wa_string).

      cpedido = cpedido + 1.

************ CODIGO PARA PREPARAR EL EXCEL DE LOS PEDIDOS
      CASE cpedido.
        WHEN 1.
          wa_datos_pedidos-ticket = wa_string. "NUMERO DE TICKET SAN
          wa_plantillasan-ticket  = wa_string.
        WHEN 2.
          wa_datos_pedidos-auart         = wa_string. "Clase de documento
          wa_plantillasan-auart =       wa_string.

        WHEN 3."Organización de ventas
          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
            EXPORTING
              input  = wa_string
            IMPORTING
              output = wa_datos_pedidos-vkorg.
          wa_plantillasan-vkorg = wa_string.

        WHEN 4. "Canal de Distribución
          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
            EXPORTING
              input  = wa_string
            IMPORTING
              output = wa_datos_pedidos-vtweg.
          wa_plantillasan-vtweg =       wa_string.

        WHEN 5. "Sector
          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
            EXPORTING
              input  = wa_string
            IMPORTING
              output = wa_datos_pedidos-spart.
          wa_plantillasan-spart =       wa_string.

        WHEN 6." Oficina de ventas
          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
            EXPORTING
              input  = wa_string
            IMPORTING
              output = wa_datos_pedidos-vkbur.
          wa_plantillasan-vkbur =       wa_string.

        WHEN 7." Grupo de vendedores
          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
            EXPORTING
              input  = wa_string
            IMPORTING
              output = wa_datos_pedidos-vkgrp.
          wa_plantillasan-vkgrp =       wa_string.

        WHEN 8. "Solicitante
          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
            EXPORTING
              input  = wa_string
            IMPORTING
              output = wa_datos_pedidos-sold.
          wa_plantillasan-sold = wa_string.

        WHEN 9. "Nombre del solicitante
          wa_datos_pedidos-name1 = wa_string.
          wa_plantillasan-name1   = wa_string.

        WHEN 10. "Destinatario
          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
            EXPORTING
              input  = wa_string
            IMPORTING
              output = wa_datos_pedidos-ship.
          wa_plantillasan-ship =      wa_string.

        WHEN 11. "Fecha(VDATU)
          TRANSLATE wa_string USING '. '.
          CONDENSE wa_string NO-GAPS.

          CONCATENATE wa_string+4(4) wa_string+2(2) wa_string+0(2) INTO wa_string.
          wa_datos_pedidos-vdatu = wa_string.
          wa_plantillasan-vdatu  =       wa_string.

        WHEN 12. "Fecha
          TRANSLATE wa_string USING '. '.
          CONDENSE wa_string NO-GAPS.

          CONCATENATE wa_string+4(4) wa_string+2(2) wa_string+0(2) INTO wa_string.
          wa_datos_pedidos-bstdk = wa_string.
          wa_plantillasan-bstdk  =       wa_string.

        WHEN 13. "Datos referencia cliente
          wa_datos_pedidos-bstkd            = wa_string.

        WHEN 14. "Centro
          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
            EXPORTING
              input  = wa_string
            IMPORTING
              output = wa_datos_pedidos-werks.
          wa_plantillasan-werks =       wa_string.

        WHEN 15. "Material
          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
            EXPORTING
              input  = wa_string
            IMPORTING
              output = wa_datos_pedidos-matnr.
          wa_plantillasan-matnr =       wa_string.

        WHEN 16. "Moneda
          wa_datos_pedidos-waerk = wa_string.

          wa_plantillasan-waerk    = wa_string.

        WHEN 17." Tipo de cambio
          wa_datos_pedidos-kursk            = wa_string.
          wa_plantillasan-kursk =       wa_string.

        WHEN 18. " Forma de pago
          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
            EXPORTING
              input  = wa_string
            IMPORTING
              output = wa_datos_pedidos-cust_grp1.
          wa_plantillasan-formapago =       wa_string.

        WHEN 19." Cantidad Pedida
          wa_datos_pedidos-kwmeng            = wa_string.
          "***** COPIA PLANTILLA
          wa_plantillasan-kwmeng =      wa_string.

        WHEN 20.

        WHEN 21. " Unidad de Medida
          wa_datos_pedidos-vrkme            = wa_string.
          wa_plantillasan-vrkme =       wa_string.

        WHEN 22. "Posición

          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
            EXPORTING
              input  = wa_string
            IMPORTING
              output = wa_datos_pedidos-posnr.
          wa_plantillasan-posnr =       wa_string.

        WHEN 23."fecha de reparto
          TRANSLATE wa_string USING '. '.
          CONDENSE wa_string NO-GAPS.

          CONCATENATE wa_string+4(4) wa_string+2(2) wa_string+0(2) INTO wa_string.
          wa_datos_pedidos-etdat            = wa_string.
          wa_plantillasan-etdat =       wa_string.

        WHEN 24.

        WHEN 25."Cantidad de reparto
          wa_datos_pedidos-bmeng            = wa_string.
          wa_plantillasan-bmeng =       wa_string.

        WHEN 26. "Contador de condiciones Siempre es 01
          wa_datos_pedidos-kpein            = '01'. "wa_string.
          wa_plantillasan-kpein =       wa_string.

        WHEN 27. "Clase de condicion
          wa_datos_pedidos-dzterm            = wa_string.
          wa_plantillasan-dzterm =      wa_string.

        WHEN 28. " Importe condicion. Si existe en hana este sera mandatorio
          wa_datos_pedidos-kbetr            = wa_string.
          wa_plantillasan-kbetr =       wa_string.

        WHEN 29."Ruta
          wa_datos_pedidos-route = wa_string.
          "***** COPIA PLANTILLA
          wa_plantillasan-route =       wa_string.

        WHEN 30.
          "Validando clases de condición de descuentos para Hana.
          CASE wa_string.
            WHEN 'DEDC'.
              wa_string = 'ZD01'.
            WHEN 'DESC'.
              wa_string = 'ZD02'.
            WHEN OTHERS.
          ENDCASE.

          wa_datos_pedidos-desc    = wa_string.
          wa_plantillasan-descuento =       wa_string.

        WHEN 31.
          wa_datos_pedidos-porc = wa_string.
          wa_plantillasan-porc =      wa_string.

        WHEN 32.
          wa_datos_pedidos-tippor            = wa_string.

        WHEN 33. "Almacen
          wa_datos_pedidos-lgort            = wa_string.
          wa_plantillasan-lgort =       wa_string.

        WHEN 34. "Texto de cabecera
          wa_datos_pedidos-texto            = wa_string.
          wa_plantillasan-texto =       wa_string.

        WHEN 35. "Fact
          wa_datos_pedidos-fact            = wa_string.
          wa_plantillasan-fact =      wa_string.

        WHEN 36. "Marcado como cancelado
          wa_datos_pedidos-canc            = wa_string.
          wa_plantillasan-canc =      wa_string.

        WHEN 37. "metodo de pago
          IF wa_string EQ 'X'.
            wa_datos_pedidos-metpag            = 'PPD'.
          ELSEIF wa_string EQ space.
            wa_datos_pedidos-metpag            = 'PUE'. "metodo de pago
          ENDIF.
          wa_plantillasan-metpag =      wa_datos_pedidos-metpag.

        WHEN 38. "Venta public en General ( X si es VPG )
          wa_datos_pedidos-vpg            = wa_string.
          wa_plantillasan-vpg =       wa_string.

        WHEN 39. "REFTICKET
          wa_datos_pedidos-reft           = wa_string.
          wa_plantillasan-reft =      wa_string.
        WHEN 40.

        WHEN 41.
          wa_datos_pedidos-bsark          = wa_string.
          wa_plantillasan-bsark =      wa_string.

          IF wa_datos_pedidos-bsark EQ 'VTRU'.
            CONCATENATE 'VTRU' p_werks '_' p_fecha+6(2) p_fecha+4(2) p_fecha+2(2)  INTO wa_plantillasan-nomplan.
          ENDIF.
        WHEN 42.

      ENDCASE.

    ENDLOOP.

*    IF wa_datos_pedidos-bsark EQ 'VTRU'.
*      APPEND wa_datos_pedidos TO it_datos_pedidos_vtru.
*    ELSE.
    wa_datos_pedidos-p_file = p_file_n.
    APPEND wa_datos_pedidos TO it_datos_pedidos.
*    ENDIF.
    cpedido = 0.
    wa_plantillasan-p_file = p_file_n.
    APPEND wa_plantillasan TO it_plantillasan.


    "INSERT zsd_tt_plantsan FROM wa_plantillasan. "PARA PRUEBAS NO VAMOS A INGRESAR A LA TABLA DDIC
    MODIFY zsd_tt_plantsan FROM wa_plantillasan.

********** CASO FACTURADO
* Cuando un ticket se pide que se facture de inmediato, se omite en su creación,
* Por lo que si la posición de ticket facturado viene marcada no se crea el pedido
*    IF wa_datos_pedidos-bsark EQ 'VTRU'.
*      DELETE it_datos_pedidos_vtru WHERE fact = 'X'. "se borran los facturados
*      " borrando datos de la tabla (borramos los cancelados, los marcados con una equis).
*      DELETE it_datos_pedidos_vtru WHERE canc = 'X'.". AND reft EQ space.
*
*      it_datos_pedidos_vtru = FILTER #( it_datos_pedidos_vtru USING KEY pk EXCEPT IN it_valida WHERE ticket = ticket AND werks = werks AND posnr = posnr ).
********** OBSERVACIONES 23.09.200 FIN
*    ELSE.
    DELETE it_datos_pedidos WHERE fact = 'X'. "se borran los facturados
    " borrando datos de la tabla (borramos los cancelados, los marcados con una equis).
    DELETE it_datos_pedidos WHERE canc = 'X'.". AND reft EQ space.

    it_datos_pedidos = FILTER #( it_datos_pedidos USING KEY pk EXCEPT IN it_valida WHERE ticket = ticket AND werks = werks AND posnr = posnr ).
*    ENDIF.
    CLEAR: wa_string,wa_datos_pedidos.
    cpedido = 0.

  ENDLOOP.

ENDFORM.

FORM recorre_centros.
  DATA vl_strmsg TYPE string.
  DATA vl_werks TYPE werks_d.

  GET TIME.

  initial_time = sy-uzeit.

  DATA(it_centros) = it_archivos[].

  SORT it_centros BY werks.

  DELETE ADJACENT DUPLICATES FROM it_centros COMPARING werks.

  LOOP AT it_centros INTO DATA(wa_werks).

    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    PERFORM get_files_rutas
      USING
        wa_werks-werks.



  ENDLOOP.


  PERFORM limpiar_tablas.

  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  LOOP AT it_centros INTO wa_werks.

    CLEAR lv_directoriocp.
    CONCATENATE lv_directorio
                wa_werks-werks '/RUTAS/'
   INTO lv_directoriocp.

    LOOP AT ifile INTO wa_ifile WHERE name+4(4) EQ wa_werks-werks .
      CLEAR: p_file_n.
      p_file_n = wa_ifile-name.
      "vl_werks = wa_ifile-name+5(4).
      CONCATENATE lv_directoriocp p_file_n INTO p_file_n.

      READ TABLE it_files WITH KEY mandt = sy-mandt ruta_file =  p_file_n TRANSPORTING NO FIELDS. "se busca si el archivo ya fue procesado.
      IF  sy-subrc NE 0.

        REFRESH it_tab.
        PERFORM set_data
               USING p_file_n.



        CLEAR wa_files.
        wa_files-ruta_file = p_file_n.
        CALL FUNCTION 'CONVERT_DATE_TO_INTERNAL'
          EXPORTING
            date_external            = wa_ifile-mtim
*           accept_initial_date      =
          IMPORTING
            date_internal            = wa_files-fechafile
          EXCEPTIONS
            date_external_is_invalid = 1
            OTHERS                   = 2.
        TRY.
            MODIFY zsd_tt_san_files FROM wa_files.
            PERFORM fill_it_pedidos USING wa_werks-werks
                                          wa_werks-fecha
                                          p_file_n
                                          'VTRU'.
          CATCH cx_sy_sql_error .
            MESSAGE 'No se grabo el registro' TYPE 'S'.
        ENDTRY.


      ENDIF.

    ENDLOOP.

  ENDLOOP.

  GET TIME.
  current_time = sy-uzeit.
  DATA(vl_calc) = ( current_time - initial_time ) / 100.

  IF vl_calc GE '4.5'.
    MESSAGE e001(00) WITH 'Prog. interrumpido. Evita encolamiento. (VTRU)'.
    EXIT.
  ENDIF.

  BREAK jhernandev.
  """"""""pedidos normales
  REFRESH ifile.
  LOOP AT it_centros INTO wa_werks.

    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    PERFORM get_file "get_files_rutas
      USING
        wa_werks-werks.

  ENDLOOP.


  "LOOP AT it_archivos INTO wa_archivos.

  LOOP AT it_centros INTO wa_werks.

    REFRESH it_tab.

    CLEAR lv_directoriocp.
    CONCATENATE lv_directorio
                wa_werks-werks '/'
   INTO lv_directoriocp.


    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
*    PERFORM get_file
*      USING
*        lv_directorio
*        wa_archivos-werks
*        wa_archivos-fecha
*      CHANGING
*        p_file_n.
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

    LOOP AT ifile INTO wa_ifile WHERE name+0(4) EQ wa_werks-werks.
      CLEAR: p_file_n.
      p_file_n = wa_ifile-name.

      CONCATENATE lv_directoriocp p_file_n INTO p_file_n.

      READ TABLE it_files WITH KEY mandt = sy-mandt ruta_file =  p_file_n TRANSPORTING NO FIELDS. "se busca si el archivo ya fue procesado.
      IF  sy-subrc NE 0.

        """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
        PERFORM set_data
          USING
            p_file_n
          .

        CLEAR wa_files.
        wa_files-ruta_file = p_file_n.
        CALL FUNCTION 'CONVERT_DATE_TO_INTERNAL'
          EXPORTING
            date_external            = wa_ifile-mtim
*           accept_initial_date      =
          IMPORTING
            date_internal            = wa_files-fechafile
          EXCEPTIONS
            date_external_is_invalid = 1
            OTHERS                   = 2.
        TRY.
            MODIFY zsd_tt_san_files FROM wa_files.
            PERFORM fill_it_pedidos USING wa_werks-werks
                              wa_werks-fecha
                              p_file_n
                              'VTMO'.
          CATCH cx_sy_sql_error .
            MESSAGE 'No se grabo el registro' TYPE 'S'.
        ENDTRY.
      ENDIF.
    ENDLOOP.
  ENDLOOP.


  GET TIME.
  current_time = sy-uzeit.
  vl_calc = ( current_time - initial_time ) / 100.

  IF vl_calc GE '4.5'.
    MESSAGE e001(00) WITH 'Prog. interrumpido. Evita encolamiento. (VTRU)'.
    EXIT.
  ELSE.
    vl_strmsg = vl_calc.
    CONCATENATE 'Time Collect Files' vl_strmsg 'minutes' INTO vl_strmsg SEPARATED BY space.
    MESSAGE s001(00) WITH  vl_strmsg.
  ENDIF.

  """"
  CLEAR lv_vpg.
  SELECT SINGLE cliente
 FROM zsd_tt_configvpg
 INTO lv_vpg
 WHERE werks = wa_archivos-werks.
  ""clasifica y crea pedidos

  PERFORM crea_pedidos.
  PERFORM limpiar_tablas.
  REFRESH it_datos_pedidos.

  GET TIME.
  current_time = sy-uzeit.
  vl_calc = ( current_time - initial_time ) / 100.
  IF vl_calc GE '4.5'.
    MESSAGE e001(00) WITH  'Prog. interrumpido. Evitar encolamiento. (PED)'.
    EXIT.
  ENDIF.


  GET TIME.
  current_time = sy-uzeit.
  vl_calc = ( current_time - initial_time ) / 100.
  IF vl_calc GE '4.5'.
    MESSAGE e001(00) WITH  'Programa interrumpido para evitar encolamiento. (PED)'.
    EXIT.
  ELSE.
    vl_strmsg = vl_calc.
    CONCATENATE 'Job terminado en' vl_strmsg 'minutos' INTO vl_strmsg SEPARATED BY space.

    MESSAGE s001(00) WITH  vl_strmsg.

  ENDIF.

ENDFORM.
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
FORM crea_pedidos.

  DATA: rg_sectores TYPE RANGE OF vbak-spart,
        rg_dzterm   TYPE RANGE OF zsd_tt_plantsan-dzterm.

  DATA: it_vpg   TYPE STANDARD TABLE OF zsd_st_datos_pedidos,
        it_novpg TYPE STANDARD TABLE OF zsd_st_datos_pedidos,
        it_vpgi  TYPE STANDARD TABLE OF zsd_st_datos_pedidos.
  .

  SORT it_datos_pedidos BY ticket werks posnr bsark.
  DELETE ADJACENT DUPLICATES FROM it_Datos_pedidos COMPARING ticket werks posnr bsark.

  DATA(it_pedidos_vtru) = it_datos_pedidos[].

  DELETE it_datos_pedidos WHERE bsark EQ 'VTRU'.
  DELETE it_pedidos_vtru WHERE bsark NE 'VTRU'.


  obj_pedidos->get_sectores(
    EXPORTING
      i_tt_pedidos = it_datos_pedidos
    IMPORTING
      e_sectores   = rg_sectores
  ).

  LOOP AT rg_sectores INTO DATA(wa_sectores).

    "se obtienen pedidos de venta público en general.
    obj_pedidos->get_vpg(
      EXPORTING
        i_sector     = wa_sectores-low
        i_c_vpg      = lv_vpg
        i_tt_pedidos = it_datos_pedidos
      CHANGING
        c_vpg        = it_vpg
        c_vpgi      = it_vpgi
    ).

    "se obtienen pedidos que no son venta público en general.
    obj_pedidos->get_novpg(
      EXPORTING
        i_sector     = wa_sectores-low
        i_c_vpg      = lv_vpg
        i_tt_pedidos = it_datos_pedidos
      CHANGING
        c_vpg        = it_novpg
        c_vpgi      = it_vpgi
    ).

    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
*    BREAK jhernandev.
    "primero los vpg
    obj_pedidos->set_crea_vpg(
   EXPORTING
     i_sector     = wa_sectores-low
     i_indicavpg  = abap_true
     i_tt_pedidos = it_vpg
     i_tt_pedidosi = it_vpgi
  ).

    "despues no que no son vpg
    obj_pedidos->set_crea_vpg(
         EXPORTING
           i_sector     = wa_sectores-low
           i_indicavpg  = abap_false
           i_tt_pedidos = it_novpg
           i_tt_pedidosi = it_vpgi
        ).


  ENDLOOP.

  """"""""""""""""pedidos a ruta""""""""""""""""""""""""""""""""""""""""
  REFRESH: rg_sectores,
            it_vpg,
            it_vpgi,
            it_novpg.


  obj_pedidos->get_sectores(
      EXPORTING
        i_tt_pedidos = it_pedidos_vtru
      IMPORTING
        e_sectores   = rg_sectores
    ).

  LOOP AT rg_sectores INTO wa_sectores.

    "se obtienen pedidos de venta público en general.
    obj_pedidos->get_vpg(
      EXPORTING
        i_sector     = wa_sectores-low
        i_c_vpg      = lv_vpg
        i_tt_pedidos = it_pedidos_vtru
      CHANGING
        c_vpg        = it_vpg
        c_vpgi      = it_vpgi
    ).

    "se obtienen pedidos que no son venta público en general.
    obj_pedidos->get_novpg(
      EXPORTING
        i_sector     = wa_sectores-low
        i_c_vpg      = lv_vpg
        i_tt_pedidos = it_pedidos_vtru
      CHANGING
        c_vpg        = it_novpg
        c_vpgi      = it_vpgi
    ).

    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
*    BREAK jhernandev.
    "primero los vpg
    obj_pedidos->set_crea_vpg(
   EXPORTING
     i_sector     = wa_sectores-low
     i_indicavpg  = abap_true
     i_tt_pedidos = it_vpg
     i_tt_pedidosi = it_vpgi
  ).

    "despues no que no son vpg
    obj_pedidos->set_crea_vpg(
         EXPORTING
           i_sector     = wa_sectores-low
           i_indicavpg  = abap_false
           i_tt_pedidos = it_novpg
           i_tt_pedidosi = it_vpgi
        ).


  ENDLOOP.


ENDFORM.
