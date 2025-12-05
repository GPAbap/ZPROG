************************************************************************
* Programa             : ZMIIRE_0001                                   *
* Desarrollador        : Roberto Bautista Dominguez                    *
* Descripción          : Envio de IDOCS MSG MATMAS y LOIPRO            *
* Fecha Creación       : 18.11.2014                                    *
* Consultor Funcional  :                                               *
*----------------------------------------------------------------------*

*----------------------------------------------------------------------*
*                    LOG DE MODIFICACIONES                             *
*----------------------------------------------------------------------*
* Descripción          :                                               *
* Funcional            :                                               *
* Desarrollador        :                                               *
* Fecha Modificación   :                                               *
*----------------------------------------------------------------------*
REPORT  zmiire_0001.

*======================================================================*
* Tablas
TABLES:
  caufv,
  marav.

*======================================================================*
* Tipos
TYPES: BEGIN OF ty_obj,
  objectid TYPE caufv-plnbez,
  utime    TYPE cdhdr-utime.
TYPES:   END OF ty_obj.

TYPES: BEGIN OF ty_caufv,
  aufnr   TYPE caufv-aufnr,
  autyp   TYPE caufv-autyp,
  erdat   TYPE caufv-erdat,
  werks   TYPE caufv-werks,
  matnr   TYPE caufv-plnbez,
  aezeit  TYPE caufv-aezeit,
  erfzeit TYPE caufv-erfzeit.
TYPES:  END OF ty_caufv.

TYPES: BEGIN OF ty_marc,
  matnr  TYPE marc-matnr,
  werks  TYPE marc-werks.
TYPES:  END OF ty_marc.

TYPES: BEGIN OF ty_alv,
  semaf  TYPE c LENGTH 1,
  mestyp TYPE tbdme-mestyp,
  aufnr  TYPE caufv-aufnr,
  matnr  TYPE marc-matnr,
  werks  TYPE marc-werks.
TYPES:   END OF ty_alv.

*======================================================================*
* Tablas internas
DATA:
  tg_marc  TYPE STANDARD TABLE OF ty_marc,
  tg_obj   TYPE STANDARD TABLE OF ty_obj,
  tg_caufv TYPE STANDARD TABLE OF ty_caufv,
  tg_alv   TYPE STANDARD TABLE OF ty_alv.

*======================================================================*
* Constantes
CONSTANTS:
  c_1050 TYPE c LENGTH 4 VALUE '1050',
  c_2710 TYPE c LENGTH 4 VALUE '2710',
  c_1020 TYPE c LENGTH 4 VALUE '1020',
  c_eq   TYPE c LENGTH 2 VALUE 'EQ',
  c_i    TYPE c LENGTH 1 VALUE 'I'.

*======================================================================*
* Variables globales
DATA:
  vg_subrc TYPE sy-subrc.

*======================================================================*
* Entradas
SELECTION-SCREEN BEGIN OF BLOCK b3 WITH FRAME TITLE text-t03.

PARAMETERS:
  rb_otro RADIOBUTTON GROUP opc  USER-COMMAND mark  DEFAULT 'X'.

PARAMETERS:
  ch_loi AS CHECKBOX,
  ch_mat AS CHECKBOX.

PARAMETERS:
  rb_inic RADIOBUTTON GROUP opc.

SELECTION-SCREEN END  OF BLOCK b3.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-t01.

SELECT-OPTIONS:
  so_aufnr  FOR caufv-aufnr,
  so_matnr  FOR caufv-plnbez,
*{   REPLACE        SPDK902977                                        1
*\  so_werks  FOR caufv-werks DEFAULT '0310' OBLIGATORY,
  so_werks  FOR caufv-werks DEFAULT 'PP01' OBLIGATORY,
*}   REPLACE
  so_erdat  FOR caufv-erdat,
  so_auart  FOR caufv-auart.

SELECT-OPTIONS:
  s_aufnr  FOR caufv-aufnr  NO-DISPLAY,
  s_aufnr2 FOR caufv-aufnr  NO-DISPLAY,
  s_matnr  FOR caufv-plnbez NO-DISPLAY,
  s_matnr2 FOR caufv-plnbez NO-DISPLAY,
  matsel   FOR marav-matnr  NO-DISPLAY,
  matsel2  FOR marav-matnr  NO-DISPLAY.

PARAMETERS:
  p_autyp TYPE caufv-autyp   NO-DISPLAY DEFAULT '10',
  opt_sys TYPE tbdlst-logsys NO-DISPLAY DEFAULT 'MIIPPAEVOL',
  mestyp  TYPE tbdme-mestyp  NO-DISPLAY DEFAULT 'MATMAS'.

SELECTION-SCREEN END  OF BLOCK b1.

SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE text-t02.

SELECT-OPTIONS:
  so_mtnr2  FOR caufv-plnbez,
*{   REPLACE        SPDK902977                                        2
*\  so_werk2  FOR caufv-werks DEFAULT '0310' OBLIGATORY,
  so_werk2  FOR caufv-werks DEFAULT 'PP01' OBLIGATORY,
*}   REPLACE
  so_ersda  FOR marav-ersda.

SELECTION-SCREEN END  OF BLOCK b2.


*======================================================================*
AT SELECTION-SCREEN.
*======================================================================*

  IF rb_inic IS NOT INITIAL.


    IF  so_aufnr[] IS INITIAL
    AND so_matnr[] IS INITIAL
    AND so_werks[] IS INITIAL.
      MESSAGE e208(00) WITH text-e02.
    ENDIF.

    IF  so_mtnr2[] IS INITIAL
    AND so_werk2[] IS INITIAL.
      MESSAGE e208(00) WITH text-e03.
    ENDIF.

  ENDIF.

  IF ch_loi IS NOT INITIAL.
    IF  so_aufnr[] IS INITIAL
    AND so_matnr[] IS INITIAL
    AND so_werks[] IS INITIAL.
      MESSAGE e208(00) WITH text-e02.
    ENDIF.
  ENDIF.
  IF ch_mat IS NOT INITIAL.
    IF  so_mtnr2[] IS INITIAL
    AND so_werk2[] IS INITIAL.
      MESSAGE e208(00) WITH text-e03.
    ENDIF.
  ENDIF.
*======================================================================*
START-OF-SELECTION.
*======================================================================*

*  PERFORM valida_centro CHANGING vg_subrc.
*  IF vg_subrc = 0.
  PERFORM f_busca_objetos.
  PERFORM f_envia_idoc.
  IF tg_alv[] IS NOT INITIAL.
    PERFORM f_alv.
  ELSE.
    MESSAGE s429(mo).
  ENDIF.
*  ENDIF.

*======================================================================*
END-OF-SELECTION.
*======================================================================*


*======================================================================*
*                   R    u    t   i   n   a   s                        *
*======================================================================*

***********************************************************************
* Proyecto...: GONDI                                                  *
* Rutina.....: F_BUSCA_OBJETOS                                        *
* Descripción: Arma el catalogo de clientes                           *
* Fecha......: 18/11/2014                                             *
* Autor......: Roberto Bautista Dominguez                             *
***********************************************************************
FORM f_busca_objetos.

  DATA:
    vl_uzeit TYPE sy-uzeit.

  CONSTANTS:
    c_mat   TYPE c LENGTH 10 VALUE 'MATERIAL',
    c_i0002 TYPE c LENGTH 5  VALUE 'I0002'.

  " Si es JOB no se captura nada en pantalla, para que se calcule la
  " extracción solo para ordenes
  IF rb_otro IS NOT INITIAL.

    " Busca las modificaciones
    IF  ch_loi IS INITIAL.

      SELECT caufv~aufnr caufv~autyp caufv~erdat caufv~werks caufv~plnbez
             caufv~aezeit caufv~erfzeit
        INTO TABLE tg_caufv
        FROM ( caufv
       INNER JOIN jest
          ON jest~objnr     EQ caufv~objnr )
       WHERE caufv~werks    IN so_werks
         AND caufv~auart    IN so_auart
         AND  ( caufv~erdat EQ sy-datum
          OR    caufv~aedat EQ sy-datum )
          AND    jest~stat  EQ c_i0002.

*      tl_caufv[] = tg_caufv[].
*      DELETE tl_caufv WHERE erdat = sy-datum.
*      DELETE tg_caufv WHERE erdat > sy-datum.
      vl_uzeit = sy-uzeit - 600.
      DELETE tg_caufv WHERE erfzeit NOT BETWEEN vl_uzeit AND sy-uzeit.

    ELSE.

      " Si se ingreso un valor
      SELECT caufv~aufnr caufv~autyp caufv~erdat caufv~werks caufv~plnbez
             caufv~aezeit caufv~erfzeit
        INTO TABLE tg_caufv
        FROM ( caufv
       INNER JOIN jest
          ON jest~objnr EQ caufv~objnr )
       WHERE caufv~aufnr  IN so_aufnr
         AND caufv~plnbez IN so_matnr
         AND caufv~werks  IN so_werks
         AND caufv~auart  IN so_auart
        AND jest~stat     EQ c_i0002.

    ENDIF.

  ELSE.

    " Envio inicial
    SELECT caufv~aufnr caufv~autyp caufv~erdat caufv~werks caufv~plnbez
           caufv~aezeit caufv~erfzeit
      INTO TABLE tg_caufv
      FROM ( caufv
     INNER JOIN jest
        ON jest~objnr   EQ caufv~objnr )
     WHERE caufv~aufnr  IN so_aufnr
       AND caufv~plnbez IN so_matnr
       AND caufv~werks  IN so_werks
       AND caufv~auart  IN so_auart
       AND jest~stat    EQ c_i0002.

  ENDIF.

  IF rb_otro IS NOT INITIAL.
*   Solo para materiales
    IF ch_mat IS INITIAL.

      " Busca nuevos en la fecha y hora correspondiente
      SELECT objectid utime
        INTO TABLE tg_obj
        FROM cdhdr
       WHERE objectclas = c_mat
         AND udate      = sy-datum.

      vl_uzeit = sy-uzeit - 600.
      DELETE tg_obj WHERE utime NOT BETWEEN vl_uzeit AND sy-uzeit.

    ELSE.

      SELECT marc~matnr marc~werks
        INTO TABLE tg_marc
        FROM ( marc
       INNER JOIN mara
          ON mara~matnr EQ marc~matnr )
       WHERE marc~matnr IN so_mtnr2
         AND marc~werks IN so_werk2
         AND mara~ersda IN so_ersda.

    ENDIF.

  ELSE.

    SELECT marc~matnr marc~werks
      INTO TABLE tg_marc
      FROM ( marc
     INNER JOIN mara
        ON mara~matnr EQ marc~matnr )
     WHERE marc~matnr IN so_mtnr2
       AND marc~werks IN so_werk2
       AND mara~ersda IN so_ersda.

  ENDIF.

  IF tg_obj[] IS NOT INITIAL.

    SELECT matnr werks
      INTO TABLE tg_marc
      FROM marc
       FOR ALL ENTRIES IN tg_obj
     WHERE matnr = tg_obj-objectid
       AND werks IN so_werk2.

  ENDIF.

ENDFORM.                    " F_BUSCA_OBJETOS
***********************************************************************
* Proyecto...: GONDI                                                  *
* Rutina.....: F_ENVIA_IDOC                                           *
* Descripción: Envia mensaje LOIPRO y MATMAS                          *
* Fecha......: 18/11/2014                                             *
* Autor......: Roberto Bautista Dominguez                             *
***********************************************************************
FORM f_envia_idoc.

  DATA:
    sl_alv   TYPE ty_alv,
    sl_caufv TYPE ty_caufv,
    sl_marc  TYPE ty_marc.

  DATA:
    vl_low   TYPE c LENGTH 20.

  CONSTANTS:
    c_loipro TYPE tbdme-mestyp  VALUE 'LOIPRO',
    c_matmas TYPE tbdme-mestyp  VALUE 'MATMAS'.
*  c_mii    TYPE c LENGTH 3    VALUE 'MII'.

  mestyp  = c_matmas.
  CLEAR: matsel[],matsel2[].

  LOOP AT tg_marc INTO sl_marc.

*    CLEAR:matsel2[],vl_low.
*    CONCATENATE c_mii sl_marc-werks
*    INTO vl_low
*    SEPARATED BY '_'.
*
*    " Seleccionamos el puerto DESTINO
*    SELECT SINGLE name INTO opt_sys
*    FROM tvarvc
*    WHERE low = vl_low.
*
*    IF sy-subrc = 0.

    CLEAR:matsel2[].
    matsel2-low    = sl_marc-matnr.
    matsel2-sign   = c_i.
    matsel2-option = c_eq.
    APPEND matsel2 TO matsel2.

    SUBMIT rbdsemat
      WITH matsel IN matsel2
      WITH mestyp  = mestyp
      WITH logsys  = opt_sys
      AND RETURN.

    COMMIT WORK.

    sl_alv-semaf  = 3.
*    ELSE.
*    sl_alv-semaf  = 1.
*    ENDIF.
    sl_alv-mestyp = mestyp.
    sl_alv-matnr  = sl_marc-matnr.
    sl_alv-werks  = sl_marc-werks.
    APPEND sl_alv TO tg_alv.
    CLEAR sl_alv.

  ENDLOOP.

  " Envio de ordenes
  CLEAR: s_aufnr[],s_matnr[].
  CLEAR: s_aufnr2[],s_matnr2[].
  mestyp  = c_loipro.

  LOOP AT tg_caufv INTO sl_caufv.

    CLEAR:
      s_aufnr2[],
      s_matnr2[],
      so_werks[],
      vl_low.

*    CONCATENATE c_mii sl_caufv-werks
*    INTO vl_low
*    SEPARATED BY '_'.
*
*    " Seleccionamos el puerto DESTINO
*    SELECT SINGLE name INTO opt_sys
*    FROM tvarvc
*    WHERE low = vl_low.
*
*    IF sy-subrc = 0.

    s_aufnr2-low    = sl_caufv-aufnr.
    s_matnr2-sign   = s_aufnr2-sign   = c_i.
    s_matnr2-option = s_aufnr2-option = c_eq.
    s_matnr2-low    = sl_caufv-matnr.
    APPEND s_aufnr2 TO s_aufnr2.
    APPEND s_matnr2 TO s_matnr2.

    so_werks-low    = sl_caufv-werks.
    so_werks-option = c_eq.
    so_werks-sign   = c_i.
    APPEND so_werks TO so_werks.

    IF s_aufnr2[] IS NOT INITIAL.

      SUBMIT rcclord
      WITH s_aufnr IN s_aufnr2
      WITH s_matnr IN s_matnr2
      WITH p_autyp =  p_autyp
      WITH s_werks IN so_werks
      WITH s_auart IN so_auart
      WITH opt_sys = opt_sys
      WITH mestyp  = mestyp
      AND RETURN.

      COMMIT WORK.

    ENDIF.

    sl_alv-semaf  = 3.
*    ELSE.
*    sl_alv-semaf  = 1.
*    ENDIF.

    sl_alv-mestyp = mestyp.
    sl_alv-aufnr  = sl_caufv-aufnr.
    sl_alv-matnr  = sl_caufv-matnr.
    sl_alv-werks  = sl_caufv-werks.
    APPEND sl_alv TO tg_alv.
    CLEAR sl_alv.

  ENDLOOP.

ENDFORM.                    " F_ENVIA_LOIPRO
***********************************************************************
* Proyecto...: GONDI                                                  *
* Rutina.....: F_ALV                                                  *
* Descripción: Muestra el reporte                                     *
* Fecha......: 18/11/2014                                             *
* Autor......: Roberto Bautista Dominguez                             *
***********************************************************************
FORM f_alv .
  DATA:
        vl_alv    TYPE REF TO cl_salv_table,
        vl_layout TYPE REF TO cl_salv_layout,
        vl_key    TYPE        salv_s_layout_key.

  DATA: vl_columns TYPE REF TO cl_salv_columns_table.
  DATA: vl_column  TYPE REF TO cl_salv_column.

  CLEAR: vl_alv.

  TRY .

      cl_salv_table=>factory(
      IMPORTING
        r_salv_table   = vl_alv
      CHANGING
        t_table        = tg_alv ).

      vl_key-report = sy-repid .
      vl_layout     = vl_alv->get_layout( ) .
      vl_layout->set_key( vl_key ).
      vl_layout->set_save_restriction(
      if_salv_c_layout=>restrict_none ).

      "Hide Columns
      vl_columns = vl_alv->get_columns( ).
      vl_columns->set_exception_column( value = 'SEMAF' ).
      vl_alv->display( ).

    CATCH cx_salv_msg.    " ALV: General Error Class with Message

  ENDTRY.

ENDFORM.                    " F_ALV
***********************************************************************
* Proyecto...: GONDI                                                  *
* Rutina.....: VALIDA_CENTRO                                          *
* Descripción: Muestra el reporte                                     *
* Fecha......: 18/11/2014                                             *
* Autor......: Roberto Bautista Dominguez                             *
***********************************************************************
FORM valida_centro CHANGING sy_subrc.

  IF so_werks IS NOT INITIAL.

    LOOP AT so_werks INTO so_werks.

      IF so_werks-low = c_1050    " DF
      OR so_werks-low = c_1020.   " GDL
        " Do nothing
      ELSE.
        MESSAGE s368(00) WITH text-e01.
        sy_subrc = 4.
      ENDIF.

    ENDLOOP.

  ELSE.

    CLEAR so_werks[].
    so_werks-low = c_1050.
    so_werks-option = c_eq.
    so_werks-sign   = c_i.
    APPEND so_werks TO so_werks.
    so_werks-low = c_1020.
    APPEND so_werks TO so_werks.

  ENDIF.

ENDFORM.                    " VALIDA_CENTRO
