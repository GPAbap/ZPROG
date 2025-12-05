FUNCTION zfm_export_excel_hierseq.
*"----------------------------------------------------------------------
*"*"Interfase local
*"  IMPORTING
*"     REFERENCE(ESTRUCTURA_HEADER) TYPE  DDOBJNAME
*"     REFERENCE(ESTRUCTURA_ITEMS) TYPE  DDOBJNAME
*"     REFERENCE(IND_HEADER) TYPE  STRING
*"     REFERENCE(CAMPO_CLAVE) TYPE  STRING
*"     REFERENCE(FILENAME) TYPE  STRING
*"  TABLES
*"      TABLA_ENCABEZADO
*"      TABLA_ITEMS
*"
*"----------------------------------------------------------------------
* Desarrollador: Jaime Hernandez Velásquez
* Fecha: 18 Marzo 2020
* Exporta a Excel un ALV Jerarquico
*
*------------------------------------------------------------------------
*Se obtienen los campos que contienen las estructuras header e items
  ref_table_des ?= cl_abap_typedescr=>describe_by_name( estructura_header ).
  iheader_details[] = ref_table_des->components[].

  CLEAR ref_table_des.
  ref_table_des ?= cl_abap_typedescr=>describe_by_name( estructura_items ).
  iitems_details[] = ref_table_des->components[].

  DESCRIBE TABLE iheader_details LINES v_cant_lineas.
  DESCRIBE TABLE iitems_details[] LINES v_cant_lineasi.

  IF v_cant_lineasi > v_cant_lineas.
    v_cant_lineas = v_cant_lineasi.
  ENDIF.



  contador = 1.
  CLEAR lt_fcat.
  " se crea el catalogo de campos con el nombre de COLUMNA mas el consecutivo de N columnas totales
  WHILE contador <= v_cant_lineas.
    campo = contador.
    CONDENSE campo NO-GAPS.
    CONCATENATE 'COLUMNA' campo(2) INTO campo.
    ls_fcat-fieldname = campo.
    ls_fcat-outputlen = 60.
    ls_fcat-tabname   = 'IT_EXCEL'.
    ls_fcat-coltext   = campo.
    ls_fcat-col_pos   = contador.
    APPEND ls_fcat TO lt_fcat.
    CLEAR  ls_fcat.

    contador = contador + 1.
  ENDWHILE.

  "sE CREA LA TABLA DINAMICA PARA OBTENER EL HEADER, EN ESTE CASO, ES MAYOR QUE EL NUMERO DE ITEMS. POR LO QUE SE TOMA PRIMERO.
  CALL METHOD cl_alv_table_create=>create_dynamic_table
    EXPORTING
      "i_style_table   = 'X' "este opcion causa problemas al listar las tablas, por eso se omite, para no causar error en la funcion GUI_DOWNLOAD
      it_fieldcatalog = lt_fcat
    IMPORTING
      ep_table        = lo_tabla
      e_style_fname   = lv_fname.

  ASSIGN lo_tabla->* TO <it_excel_alv>.

  CREATE DATA lo_linea LIKE LINE OF <it_excel_alv>.
  CREATE DATA lo_linea1 LIKE LINE OF <it_excel_alv>.

  ASSIGN lo_linea->* TO <linea>.
  ASSIGN lo_linea1->* TO <linea1>.

  PERFORM llenar_filas_header USING iheader_details[]  estructura_header ind_header. "se llenan los encabezados
  PERFORM llenar_filas_detalles USING iitems_details[] estructura_items. "se llenan los items


  LOOP AT tabla_encabezado ASSIGNING <linea1>.
    "Se inserta el encabezado con datos del acreedor
    ASSIGN COMPONENT campo_clave OF STRUCTURE <linea1> TO <fs>.
    lv_campo_clave = <fs>.
    UNASSIGN <fs>.
    contador = 1.
    LOOP AT iheader_details INTO DATA(wa_header_details) WHERE name NE ind_header. "se omite la columna de despliegue
      campo = contador.
      CONDENSE campo NO-GAPS.
      CONCATENATE 'COLUMNA' campo(2) INTO campo.

      ASSIGN COMPONENT campo OF STRUCTURE <linea> TO <wa_excel_alv>.

      ASSIGN COMPONENT wa_header_details-name OF STRUCTURE <linea1> TO <fs>.
      <wa_excel_alv> = <fs>.
      UNASSIGN <wa_excel_alv>.
      UNASSIGN <fs>.
      contador = contador + 1.
    ENDLOOP.
    APPEND <linea> TO <it_excel_alv>.
    CLEAR <linea>.

    "--------------------------------------------------------
* "---------SE AGREGAN LAS SOCIEDADES ASOCIADAS AL ACREEDOR.
    LOOP AT tabla_items ASSIGNING <linea2> .                              "aqui se filtra por el campo clave
      ASSIGN COMPONENT campo_clave OF STRUCTURE <linea2> TO <fs_campo>.   "para que se vaya uniendo y enlazando
      CHECK <fs_campo> = lv_campo_clave.                                  " los items con su header correspondiente
      contador = 1.
      LOOP AT iitems_details INTO DATA(wa_items_details).
        campo = contador.
        CONDENSE campo NO-GAPS.
        CONCATENATE 'COLUMNA' campo(2) INTO campo.

        ASSIGN COMPONENT campo OF STRUCTURE <linea> TO <wa_excel_alv>.
        ASSIGN COMPONENT wa_items_details-name OF STRUCTURE <linea2> TO <fs>.
        <wa_excel_alv> = <fs>.
        UNASSIGN <wa_excel_alv>.
        contador = contador + 1.
      ENDLOOP.
      APPEND <linea> TO <it_excel_alv>.
      CLEAR <linea>.
    ENDLOOP.
    UNASSIGN <linea2>.
* "-----------------------------------------------------

  ENDLOOP.
  UNASSIGN <linea1>.



  CALL FUNCTION 'GUI_DOWNLOAD' "se descarga la información en el archivo excel.
    EXPORTING
      filename = filename
      filetype = 'DAT'
    TABLES
      data_tab = <it_excel_alv>
*     fieldnames = lt_fcat. "opcional
    .
ENDFUNCTION.

FORM llenar_filas_header USING iheader_details TYPE abap_compdescr_tab
      estructura_header TYPE ddobjname
      indicador_header  TYPE string.



  REFRESH v_rollname.
  contador = 1.
  LOOP AT iheader_details INTO DATA(wa_header_details) WHERE name NE indicador_header.

    campo = contador.
    CONDENSE campo NO-GAPS.
    CONCATENATE 'COLUMNA' campo(2) INTO campo.

    ASSIGN COMPONENT campo OF STRUCTURE <linea> TO <wa_excel_alv>.
    "Se obtienen los textos de los elementos de datos
    CALL FUNCTION 'DDIF_FIELDINFO_GET'
      EXPORTING
        tabname        = estructura_header
        fieldname      = wa_header_details-name
*       langu          = sy-langu
      TABLES
        dfies_tab      = v_rollname
      EXCEPTIONS
        not_found      = 1
        internal_error = 2
        OTHERS         = 3.
    "--------------------------------------------------------
    LOOP AT v_rollname.
      <wa_excel_alv> = v_rollname-scrtext_l."wa_header_details-name.
    ENDLOOP.
    UNASSIGN <wa_excel_alv>.
    contador = contador + 1.
  ENDLOOP.
  APPEND <linea> TO <it_excel_alv>.
  CLEAR <linea>.

ENDFORM.

FORM llenar_filas_detalles USING iitems_details TYPE abap_compdescr_tab
      estructura_items TYPE ddobjname
      .


  REFRESH v_rollname.
  contador = 1.
  LOOP AT iitems_details INTO DATA(wa_items_details).
    campo = contador.
    CONDENSE campo NO-GAPS.
    CONCATENATE 'COLUMNA' campo(2) INTO campo.

    ASSIGN COMPONENT campo OF STRUCTURE <linea> TO <wa_excel_alv>.
    "Se obtienen los textos de los elementos de datos
    CALL FUNCTION 'DDIF_FIELDINFO_GET'
      EXPORTING
        tabname        = estructura_items
        fieldname      = wa_items_details-name
*       langu          = sy-langu
      TABLES
        dfies_tab      = v_rollname
      EXCEPTIONS
        not_found      = 1
        internal_error = 2
        OTHERS         = 3.
    "--------------------------------------------------------
    LOOP AT v_rollname.
      <wa_excel_alv> = v_rollname-scrtext_l."wa_items_details-name.
    ENDLOOP.

    UNASSIGN <wa_excel_alv>.
    contador = contador + 1.

  ENDLOOP.
  APPEND <linea> TO <it_excel_alv>.
  CLEAR <linea>.


ENDFORM.
