************************************************************************
* EMPRESA:      GRUPO PORRES DIVISION AZUCAR
* PROGRAMA:     ZRCO0030
* DESCRIPCION:  COMPARACIÓN PLAN REAL PARA CENTROS DE COSTO Y CUENTAS
* AUTOR:        MARIA DEL CARMEN OCOTLAN GUZMAN MEDINA
* FECHA:        NOVIEMBRE DEL 2018
************************************************************************
REPORT zfi_bloqueo_sa00_pres MESSAGE-ID ze LINE-SIZE 255 LINE-COUNT 65.
TABLES:
  csks,          " Centros de Costo
  coss,          " Totales de costes - contabilizaciones internas
  cosp.          " Totales de costes - contabilizaciones externas
************************ MODIFICACIONES MICHAEL CHAVEZ 12.11.2020 INI
DATA: LV_nivel1 TYPE zporcentaje,
      LV_nivel2 TYPE zporcentaje,
      LV_nivel3 TYPE zporcentaje.
DATA: lv_porcentaje1 TYPE dmbtr,
      lv_porcentaje2 TYPE dmbtr,
      lv_porcentaje3 TYPE dmbtr,
      lv_porc1       TYPE char10,
      lv_porc2       TYPE char10,
      lv_porc3       TYPE char10.
DATA: lv_kokrs TYPE kokrs.
DATA: lv_kostl TYPE kostl.
DATA: it_avisos TYPE TABLE OF zco_tt_avisos,
      wa_avisos LIKE LINE OF it_avisos.
DATA: wa        TYPE solisti1,
      it_objtxt TYPE STANDARD TABLE OF solisti1,
      it_objbin TYPE STANDARD TABLE OF solisti1,
      lv_titulo TYPE string,
      lv_cuerpo TYPE string,
      lv_body   TYPE string,
      lv_asunto TYPE string,
      it_tline  TYPE STANDARD TABLE OF tline,
      lv_fol    TYPE string,
      lv_adr    TYPE adrnr,
      lv_emp    TYPE string.
DATA:  BEGIN OF tlines OCCURS 0.
         INCLUDE STRUCTURE tline.
DATA:   END OF tlines.
CONSTANTS: tdobject    LIKE thead-tdobject VALUE 'TEXT',  "Llamar objeto de texto estándar con el cuerpo del Mail
           txtid_beweg LIKE thead-tdid VALUE 'ST'.
FIELD-SYMBOLS : <wa_tline>  LIKE LINE OF it_tline,
                <wa_objbin> LIKE LINE OF it_objbin.
DATA: v_attach   TYPE xstring.
DATA: lv_nom TYPE string.
DATA: lv_name1 TYPE name1,
      lv_mail  TYPE string,
*      lv_correo      TYPE zemail,
*      lv_correoenvia TYPE zemail,
      lv_pernr TYPE persno.
DATA: lv_mensaje TYPE string.
DATA: lv_encabezado TYPE string.
DATA: it_aviso TYPE TABLE OF zco_tt_avisos,
      wa_aviso LIKE LINE OF it_aviso.
************************ MODIFICACIONES MICHAEL CHAVEZ 12.11.2020 FIN
DATA: BEGIN OF bdc_data OCCURS 500.
        INCLUDE STRUCTURE bdcdata.
DATA: END OF bdc_data.
SELECTION-SCREEN BEGIN OF BLOCK block1 WITH FRAME TITLE TEXT-001.
  PARAMETERS:
    versn_p LIKE cosp-versn,
    gjahr_p LIKE cosp-gjahr.
SELECTION-SCREEN END OF BLOCK block1.
DATA:
 band(1) TYPE n.
* TABLA INTERNA DE DATOS
* DAtos Plan
DATA: BEGIN OF cosp_p OCCURS 0,
        objnr   LIKE cosp-objnr,   " objeto de costo
        gjahr   LIKE cosp-gjahr,   " ejercicio
        wrttp   LIKE cosp-wrttp,   " tipo de valor 1 plan 4 real
        kstar   LIKE cosp-kstar,   " clase de costo
        beknz   LIKE cosp-beknz,   " indicador cargo / abono
        wkg001  LIKE cosp-wkg001,  " Marzo
        total_p LIKE cosp-wkg001,
      END OF cosp_p.
DATA: BEGIN OF cosp_pt OCCURS 0,
        objnr LIKE cosp-objnr,   " objeto de costo
        gjahr LIKE cosp-gjahr,   " ejercicio
        total LIKE cosp-wkg001,
      END OF cosp_pt.
* Datos Real
DATA: BEGIN OF cosp_r OCCURS 0,
        objnr   LIKE cosp-objnr,   " objeto de costo
        gjahr   LIKE cosp-gjahr,   " ejercicio
        wrttp   LIKE cosp-wrttp,   " tipo de valor 1 plan 4 real
        kstar   LIKE cosp-kstar,   " clase de costo
        beknz   LIKE cosp-beknz,   " indicador cargo / abono
        wkg001  LIKE cosp-wkg001,  " Marzo
        total_r LIKE cosp-wkg001,
      END OF cosp_r.
DATA: BEGIN OF cosp_rt OCCURS 0,
        objnr LIKE cosp-objnr,   " objeto de costo
        gjahr LIKE cosp-gjahr,   " ejercicio
        total LIKE cosp-wkg001,
      END OF cosp_rt.
DATA:
  ban,
  destino        LIKE sy-uname,
  total_plan(10),
  total_real(10),
  porciento      LIKE cosp-wkg001,
  mes(2).
*DATA:
*  mailtx LIKE sood1-objdes,
*  mailto LIKE sy-uname.
DATA: BEGIN OF mtext OCCURS 0.
        INCLUDE STRUCTURE soli.
DATA: END OF mtext.
*&---------------------------------------------------------------------*
*&     INICIO PROGRAMA
*&---------------------------------------------------------------------*
START-OF-SELECTION.
*  SELECT SINGLE mail
*    FROM zco_tt_mailaviso
*    INTO lv_correoenvia
*    WHERE tipoaviso = 1.
  PERFORM plan.
  PERFORM real.
  PERFORM compara.
end-of-selection.
*****     FIN PROGRAMA
*&---------------------------------------------------------------------*
*&      Form  PROCESO
*&---------------------------------------------------------------------*
FORM plan.
* Selecciona los registros PLAN
* Contabilizaciones Externas
  DATA: rg_objnr  TYPE RANGE OF cosp-objnr,
        wrg_objnr LIKE LINE OF rg_objnr.
  DATA: rg_kstar  TYPE RANGE OF cosp-kstar,
        wrg_kstar LIKE LINE OF rg_kstar.
  wrg_objnr-option = 'BT'.
  wrg_objnr-low = 'KSSA000000000000'.
  wrg_objnr-high = 'KSSA00ZZZZZZZZZZ'.
*  wrg_objnr-low = 'KSSA00GP985000'.
*  wrg_objnr-high = 'KSSA00GP985000'.
  wrg_objnr-sign = 'I'.
  APPEND wrg_objnr TO rg_objnr.
  SELECT objnr, gjahr, wrttp, kstar, wkg001,
         wkg002, wkg003, wkg004, wkg005,
         wkg006, wkg007, wkg008, wkg009,
         wkg010, wkg011, wkg012
    INTO TABLE @DATA(it_cosp)
    FROM cosp
     WHERE  objnr IN @rg_objnr
   AND kstar NOT BETWEEN '0504025112' AND '0504025119'
   AND kstar NOT IN ( '601001012','601001237' )
    AND    gjahr = @gjahr_p
    AND    wrttp = '01'
    AND    versn = @versn_p.
  SORT it_cosp BY objnr.
  LOOP AT it_cosp INTO DATA(wa_cosp).
    CASE sy-datum+4(2).
      WHEN '01'.
        MOVE:
        wa_cosp-objnr  TO cosp_p-objnr,
        wa_cosp-gjahr  TO cosp_p-gjahr,
        wa_cosp-wrttp  TO cosp_p-wrttp,
        wa_cosp-kstar  TO cosp_p-kstar,
        wa_cosp-wkg001 TO cosp_p-wkg001.
        APPEND cosp_p.
      WHEN '02'.
        MOVE:
        wa_cosp-objnr  TO cosp_p-objnr,
        wa_cosp-gjahr  TO cosp_p-gjahr,
        wa_cosp-wrttp  TO cosp_p-wrttp,
        wa_cosp-kstar  TO cosp_p-kstar,
        wa_cosp-wkg002 TO cosp_p-wkg001.
        APPEND cosp_p.
      WHEN '03'.
        MOVE:
        wa_cosp-objnr  TO cosp_p-objnr,
        wa_cosp-gjahr  TO cosp_p-gjahr,
        wa_cosp-wrttp  TO cosp_p-wrttp,
        wa_cosp-kstar  TO cosp_p-kstar,
        wa_cosp-wkg003 TO cosp_p-wkg001.
        APPEND cosp_p.
      WHEN '04'.
        MOVE:
        wa_cosp-objnr  TO cosp_p-objnr,
        wa_cosp-gjahr  TO cosp_p-gjahr,
        wa_cosp-wrttp  TO cosp_p-wrttp,
        wa_cosp-kstar  TO cosp_p-kstar,
        wa_cosp-wkg004 TO cosp_p-wkg001.
        APPEND cosp_p.
      WHEN '05'.
        MOVE:
        wa_cosp-objnr  TO cosp_p-objnr,
        wa_cosp-gjahr  TO cosp_p-gjahr,
        wa_cosp-wrttp  TO cosp_p-wrttp,
        wa_cosp-kstar  TO cosp_p-kstar,
        wa_cosp-wkg005 TO cosp_p-wkg001.
        APPEND cosp_p.
      WHEN '06'.
        MOVE:
        wa_cosp-objnr  TO cosp_p-objnr,
        wa_cosp-gjahr  TO cosp_p-gjahr,
        wa_cosp-wrttp  TO cosp_p-wrttp,
        wa_cosp-kstar  TO cosp_p-kstar,
        wa_cosp-wkg006 TO cosp_p-wkg001.
        APPEND cosp_p.
      WHEN '07'.
        MOVE:
        wa_cosp-objnr  TO cosp_p-objnr,
        wa_cosp-gjahr  TO cosp_p-gjahr,
        wa_cosp-wrttp  TO cosp_p-wrttp,
        wa_cosp-kstar  TO cosp_p-kstar,
        wa_cosp-wkg007 TO cosp_p-wkg001.
        APPEND cosp_p.
      WHEN '08'.
        MOVE:
        wa_cosp-objnr  TO cosp_p-objnr,
        wa_cosp-gjahr  TO cosp_p-gjahr,
        wa_cosp-wrttp  TO cosp_p-wrttp,
        wa_cosp-kstar  TO cosp_p-kstar,
        wa_cosp-wkg008 TO cosp_p-wkg001.
        APPEND cosp_p.
      WHEN '09'.
        MOVE:
        wa_cosp-objnr  TO cosp_p-objnr,
        wa_cosp-gjahr  TO cosp_p-gjahr,
        wa_cosp-wrttp  TO cosp_p-wrttp,
        wa_cosp-kstar  TO cosp_p-kstar,
        wa_cosp-wkg009 TO cosp_p-wkg001.
        APPEND cosp_p.
      WHEN '10'.
        MOVE:
        wa_cosp-objnr  TO cosp_p-objnr,
        wa_cosp-gjahr  TO cosp_p-gjahr,
        wa_cosp-wrttp  TO cosp_p-wrttp,
        wa_cosp-kstar  TO cosp_p-kstar,
        wa_cosp-wkg010 TO cosp_p-wkg001.
        APPEND cosp_p.
      WHEN '11'.
        MOVE:
        wa_cosp-objnr  TO cosp_p-objnr,
        wa_cosp-gjahr  TO cosp_p-gjahr,
        wa_cosp-wrttp  TO cosp_p-wrttp,
        wa_cosp-kstar  TO cosp_p-kstar,
        wa_cosp-wkg011 TO cosp_p-wkg001.
        APPEND cosp_p.
      WHEN '12'.
        MOVE:
        wa_cosp-objnr  TO cosp_p-objnr,
        wa_cosp-gjahr  TO cosp_p-gjahr,
        wa_cosp-wrttp  TO cosp_p-wrttp,
        wa_cosp-kstar  TO cosp_p-kstar,
        wa_cosp-wkg012 TO cosp_p-wkg001.
        APPEND cosp_p.
    ENDCASE.
  ENDLOOP.
  SELECT objnr, gjahr, wrttp, kstar, wkg001,
         wkg002, wkg003, wkg004, wkg005,
         wkg006, wkg007, wkg008, wkg009,
         wkg010, wkg011, wkg012
    INTO TABLE @DATA(it_coss)
    FROM coss
      WHERE  objnr IN @rg_objnr
      AND    kstar NOT BETWEEN '0504025112' AND '0504025119'
       AND kstar NOT IN ( '601001012','601001237' )
      AND    gjahr = @gjahr_p
      AND    wrttp = '01'
      AND    versn = @versn_p.
  SORT it_coss BY objnr.
  LOOP AT it_coss INTO DATA(wa_coss).
    CASE sy-datum+4(2).
      WHEN '01'.
        MOVE:
        wa_coss-objnr  TO cosp_p-objnr,
        wa_coss-gjahr  TO cosp_p-gjahr,
        wa_coss-wrttp  TO cosp_p-wrttp,
        wa_coss-kstar  TO cosp_p-kstar,
        wa_coss-wkg001 TO cosp_p-wkg001.
        APPEND cosp_p.
      WHEN '02'.
        MOVE:
        wa_coss-objnr  TO cosp_p-objnr,
        wa_coss-gjahr  TO cosp_p-gjahr,
        wa_coss-wrttp  TO cosp_p-wrttp,
        wa_coss-kstar  TO cosp_p-kstar,
        wa_coss-wkg002 TO cosp_p-wkg001.
        APPEND cosp_p.
      WHEN '03'.
        MOVE:
        wa_coss-objnr  TO cosp_p-objnr,
        wa_coss-gjahr  TO cosp_p-gjahr,
        wa_coss-wrttp  TO cosp_p-wrttp,
        wa_coss-kstar  TO cosp_p-kstar,
        wa_coss-wkg003 TO cosp_p-wkg001.
        APPEND cosp_p.
      WHEN '04'.
        MOVE:
        wa_coss-objnr  TO cosp_p-objnr,
        wa_coss-gjahr  TO cosp_p-gjahr,
        wa_coss-wrttp  TO cosp_p-wrttp,
        wa_coss-kstar  TO cosp_p-kstar,
        wa_coss-wkg004 TO cosp_p-wkg001.
        APPEND cosp_p.
      WHEN '05'.
        MOVE:
        wa_coss-objnr  TO cosp_p-objnr,
        wa_coss-gjahr  TO cosp_p-gjahr,
        wa_coss-wrttp  TO cosp_p-wrttp,
        wa_coss-kstar  TO cosp_p-kstar,
        wa_coss-wkg005 TO cosp_p-wkg001.
        APPEND cosp_p.
      WHEN '06'.
        MOVE:
        wa_coss-objnr  TO cosp_p-objnr,
        wa_coss-gjahr  TO cosp_p-gjahr,
        wa_coss-wrttp  TO cosp_p-wrttp,
        wa_coss-kstar  TO cosp_p-kstar,
        wa_coss-wkg006 TO cosp_p-wkg001.
        APPEND cosp_p.
      WHEN '07'.
        MOVE:
        wa_coss-objnr  TO cosp_p-objnr,
        wa_coss-gjahr  TO cosp_p-gjahr,
        wa_coss-wrttp  TO cosp_p-wrttp,
        wa_coss-kstar  TO cosp_p-kstar,
        wa_coss-wkg007 TO cosp_p-wkg001.
        APPEND cosp_p.
      WHEN '08'.
        MOVE:
        wa_coss-objnr  TO cosp_p-objnr,
        wa_coss-gjahr  TO cosp_p-gjahr,
        wa_coss-wrttp  TO cosp_p-wrttp,
        wa_coss-kstar  TO cosp_p-kstar,
        wa_coss-wkg008 TO cosp_p-wkg001.
        APPEND cosp_p.
      WHEN '09'.
        MOVE:
        wa_coss-objnr  TO cosp_p-objnr,
        wa_coss-gjahr  TO cosp_p-gjahr,
        wa_coss-wrttp  TO cosp_p-wrttp,
        wa_coss-kstar  TO cosp_p-kstar,
        wa_coss-wkg009 TO cosp_p-wkg001.
        APPEND cosp_p.
      WHEN '10'.
        MOVE:
        wa_coss-objnr  TO cosp_p-objnr,
        wa_coss-gjahr  TO cosp_p-gjahr,
        wa_coss-wrttp  TO cosp_p-wrttp,
        wa_coss-kstar  TO cosp_p-kstar,
        wa_coss-wkg010 TO cosp_p-wkg001.
        APPEND cosp_p.
      WHEN '11'.
        MOVE:
        wa_coss-objnr  TO cosp_p-objnr,
        wa_coss-gjahr  TO cosp_p-gjahr,
        wa_coss-wrttp  TO cosp_p-wrttp,
        wa_coss-kstar  TO cosp_p-kstar,
        wa_coss-wkg011 TO cosp_p-wkg001.
        APPEND cosp_p.
      WHEN '12'.
        MOVE:
        wa_coss-objnr  TO cosp_p-objnr,
        wa_coss-gjahr  TO cosp_p-gjahr,
        wa_coss-wrttp  TO cosp_p-wrttp,
        wa_coss-kstar  TO cosp_p-kstar,
        wa_coss-wkg012 TO cosp_p-wkg001.
        APPEND cosp_p.
    ENDCASE.
  ENDLOOP.
  LOOP AT cosp_p.
    MOVE cosp_p-objnr TO cosp_pt-objnr.
    AT END OF objnr.
      SUM.
      MOVE cosp_p-wkg001 TO cosp_pt-total.
      APPEND cosp_pt.
    ENDAT.
  ENDLOOP.
ENDFORM.
************************************************************************
FORM real.
* Selecciona los registros REAL
* Contabilizaciones externas
  DATA: rg_objnr  TYPE RANGE OF cosp-objnr,
        wrg_objnr LIKE LINE OF rg_objnr.
  DATA: rg_kstar  TYPE RANGE OF cosp-kstar,
        wrg_kstar LIKE LINE OF rg_kstar.
  wrg_objnr-option = 'BT'.
  wrg_objnr-low = 'KSSA000000000000'.
  wrg_objnr-high = 'KSSA00ZZZZZZZZZZ'.
*  wrg_objnr-low = 'KSSA00GP985000'.
*  wrg_objnr-high = 'KSSA00GP985000'.
  wrg_objnr-sign = 'I'.
  APPEND wrg_objnr TO rg_objnr.
  SELECT objnr, gjahr, wrttp, kstar, wkg001,
         wkg002, wkg003, wkg004, wkg005,
         wkg006, wkg007, wkg008, wkg009,
         wkg010, wkg011, wkg012
    INTO TABLE @DATA(it_cosp)
FROM cosp
    WHERE  objnr IN @rg_objnr
*    AND    kstar NOT BETWEEN '0000401600' AND '0000401634'
    AND    kstar NOT BETWEEN '0504025112' AND '0504025119'
    AND kstar NOT IN ( '601001012','601001237' )
    AND    wrttp = '04'
    AND    gjahr = @gjahr_p
    AND    versn = @versn_p.
  SORT it_cosp BY objnr.
  LOOP AT it_cosp INTO DATA(wa_cosp).
    CASE sy-datum+4(2).
      WHEN '01'.
        MOVE:
        wa_cosp-objnr  TO cosp_r-objnr,
        wa_cosp-gjahr  TO cosp_r-gjahr,
        wa_cosp-wrttp  TO cosp_r-wrttp,
        wa_cosp-kstar  TO cosp_r-kstar,
        wa_cosp-wkg001 TO cosp_r-wkg001.
        APPEND cosp_r.
      WHEN '02'.
        MOVE:
        wa_cosp-objnr  TO cosp_r-objnr,
        wa_cosp-gjahr  TO cosp_r-gjahr,
        wa_cosp-wrttp  TO cosp_r-wrttp,
        wa_cosp-kstar  TO cosp_r-kstar,
        wa_cosp-wkg002 TO cosp_r-wkg001.
        APPEND cosp_r.
      WHEN '03'.
        MOVE:
        wa_cosp-objnr  TO cosp_r-objnr,
        wa_cosp-gjahr  TO cosp_r-gjahr,
        wa_cosp-wrttp  TO cosp_r-wrttp,
        wa_cosp-kstar  TO cosp_r-kstar,
        wa_cosp-wkg003 TO cosp_r-wkg001.
        APPEND cosp_r.
      WHEN '04'.
        MOVE:
        wa_cosp-objnr  TO cosp_r-objnr,
        wa_cosp-gjahr  TO cosp_r-gjahr,
        wa_cosp-wrttp  TO cosp_r-wrttp,
        wa_cosp-kstar  TO cosp_r-kstar,
        wa_cosp-wkg004 TO cosp_r-wkg001.
        APPEND cosp_r.
      WHEN '05'.
        MOVE:
        wa_cosp-objnr  TO cosp_r-objnr,
        wa_cosp-gjahr  TO cosp_r-gjahr,
        wa_cosp-wrttp  TO cosp_r-wrttp,
        wa_cosp-kstar  TO cosp_r-kstar,
        wa_cosp-wkg005 TO cosp_r-wkg001.
        APPEND cosp_r.
      WHEN '06'.
        MOVE:
        wa_cosp-objnr  TO cosp_r-objnr,
        wa_cosp-gjahr  TO cosp_r-gjahr,
        wa_cosp-wrttp  TO cosp_r-wrttp,
        wa_cosp-kstar  TO cosp_r-kstar,
        wa_cosp-wkg006 TO cosp_r-wkg001.
        APPEND cosp_r.
      WHEN '07'.
        MOVE:
        wa_cosp-objnr  TO cosp_r-objnr,
        wa_cosp-gjahr  TO cosp_r-gjahr,
        wa_cosp-wrttp  TO cosp_r-wrttp,
        wa_cosp-kstar  TO cosp_r-kstar,
        wa_cosp-wkg007 TO cosp_r-wkg001.
        APPEND cosp_r.
      WHEN '08'.
        MOVE:
        wa_cosp-objnr  TO cosp_r-objnr,
        wa_cosp-gjahr  TO cosp_r-gjahr,
        wa_cosp-wrttp  TO cosp_r-wrttp,
        wa_cosp-kstar  TO cosp_r-kstar,
        wa_cosp-wkg008 TO cosp_r-wkg001.
        APPEND cosp_r.
      WHEN '09'.
        MOVE:
        wa_cosp-objnr  TO cosp_r-objnr,
        wa_cosp-gjahr  TO cosp_r-gjahr,
        wa_cosp-wrttp  TO cosp_r-wrttp,
        wa_cosp-kstar  TO cosp_r-kstar,
        wa_cosp-wkg009 TO cosp_r-wkg001.
        APPEND cosp_r.
      WHEN '10'.
        MOVE:
        wa_cosp-objnr  TO cosp_r-objnr,
        wa_cosp-gjahr  TO cosp_r-gjahr,
        wa_cosp-wrttp  TO cosp_r-wrttp,
        wa_cosp-kstar  TO cosp_r-kstar,
        wa_cosp-wkg010 TO cosp_r-wkg001.
        APPEND cosp_r.
      WHEN '11'.
        MOVE:
        wa_cosp-objnr  TO cosp_r-objnr,
        wa_cosp-gjahr  TO cosp_r-gjahr,
        wa_cosp-wrttp  TO cosp_r-wrttp,
        wa_cosp-kstar  TO cosp_r-kstar,
        wa_cosp-wkg011 TO cosp_r-wkg001.
        APPEND cosp_r.
      WHEN '12'.
        MOVE:
        wa_cosp-objnr  TO cosp_r-objnr,
        wa_cosp-gjahr  TO cosp_r-gjahr,
        wa_cosp-wrttp  TO cosp_r-wrttp,
        wa_cosp-kstar  TO cosp_r-kstar,
        wa_cosp-wkg012 TO cosp_r-wkg001.
        APPEND cosp_r.
    ENDCASE.
  ENDLOOP.
* Contabilizaciones internas
  SELECT objnr, gjahr, wrttp, kstar, wkg001,
       wkg002, wkg003, wkg004, wkg005,
       wkg006, wkg007, wkg008, wkg009,
       wkg010, wkg011, wkg012
  INTO TABLE @DATA(it_coss)
FROM coss
    WHERE  objnr IN @rg_objnr
*      AND    kstar NOT BETWEEN '0000401600' AND '0000401634'
    AND    kstar NOT BETWEEN '0504025112' AND '0504025119'
    AND kstar NOT IN ( '601001012','601001237' )
    AND    wrttp = '04'
    AND    gjahr = @gjahr_p
    AND    versn = @versn_p.
  SORT it_coss BY objnr.
  LOOP AT it_coss INTO DATA(wa_coss).
    CASE sy-datum+4(2).
      WHEN '01'.
        MOVE:
        wa_coss-objnr  TO cosp_r-objnr,
        wa_coss-gjahr  TO cosp_r-gjahr,
        wa_coss-wrttp  TO cosp_r-wrttp,
        wa_coss-kstar  TO cosp_r-kstar,
        wa_coss-wkg001 TO cosp_r-wkg001.
        APPEND cosp_r.
      WHEN '02'.
        MOVE:
        wa_coss-objnr  TO cosp_r-objnr,
        wa_coss-gjahr  TO cosp_r-gjahr,
        wa_coss-wrttp  TO cosp_r-wrttp,
        wa_coss-kstar  TO cosp_r-kstar,
        wa_coss-wkg002 TO cosp_r-wkg001.
        APPEND cosp_r.
      WHEN '03'.
        MOVE:
        wa_coss-objnr  TO cosp_r-objnr,
        wa_coss-gjahr  TO cosp_r-gjahr,
        wa_coss-wrttp  TO cosp_r-wrttp,
        wa_coss-kstar  TO cosp_r-kstar,
        wa_coss-wkg003 TO cosp_r-wkg001.
        APPEND cosp_r.
      WHEN '04'.
        MOVE:
        wa_coss-objnr  TO cosp_r-objnr,
        wa_coss-gjahr  TO cosp_r-gjahr,
        wa_coss-wrttp  TO cosp_r-wrttp,
        wa_coss-kstar  TO cosp_r-kstar,
        wa_coss-wkg004 TO cosp_r-wkg001.
        APPEND cosp_r.
      WHEN '05'.
        MOVE:
        wa_coss-objnr  TO cosp_r-objnr,
        wa_coss-gjahr  TO cosp_r-gjahr,
        wa_coss-wrttp  TO cosp_r-wrttp,
        wa_coss-kstar  TO cosp_r-kstar,
        wa_coss-wkg005 TO cosp_r-wkg001.
        APPEND cosp_r.
      WHEN '06'.
        MOVE:
        wa_coss-objnr  TO cosp_r-objnr,
        wa_coss-gjahr  TO cosp_r-gjahr,
        wa_coss-wrttp  TO cosp_r-wrttp,
        wa_coss-kstar  TO cosp_r-kstar,
        wa_coss-wkg006 TO cosp_r-wkg001.
        APPEND cosp_r.
      WHEN '07'.
        MOVE:
        wa_coss-objnr  TO cosp_r-objnr,
        wa_coss-gjahr  TO cosp_r-gjahr,
        wa_coss-wrttp  TO cosp_r-wrttp,
        wa_coss-kstar  TO cosp_r-kstar,
        wa_coss-wkg007 TO cosp_r-wkg001.
        APPEND cosp_r.
      WHEN '08'.
        MOVE:
        wa_coss-objnr  TO cosp_r-objnr,
        wa_coss-gjahr  TO cosp_r-gjahr,
        wa_coss-wrttp  TO cosp_r-wrttp,
        wa_coss-kstar  TO cosp_r-kstar,
        wa_coss-wkg008 TO cosp_r-wkg001.
        APPEND cosp_r.
      WHEN '09'.
        MOVE:
        wa_coss-objnr  TO cosp_r-objnr,
        wa_coss-gjahr  TO cosp_r-gjahr,
        wa_coss-wrttp  TO cosp_r-wrttp,
        wa_coss-kstar  TO cosp_r-kstar,
        wa_coss-wkg009 TO cosp_r-wkg001.
        APPEND cosp_r.
      WHEN '10'.
        MOVE:
        wa_coss-objnr  TO cosp_r-objnr,
        wa_coss-gjahr  TO cosp_r-gjahr,
        wa_coss-wrttp  TO cosp_r-wrttp,
        wa_coss-kstar  TO cosp_r-kstar,
        wa_coss-wkg010 TO cosp_r-wkg001.
        APPEND cosp_r.
      WHEN '11'.
        MOVE:
        wa_coss-objnr  TO cosp_r-objnr,
        wa_coss-gjahr  TO cosp_r-gjahr,
        wa_coss-wrttp  TO cosp_r-wrttp,
        wa_coss-wkg011 TO cosp_r-wkg001.
        APPEND cosp_r.
      WHEN '12'.
        MOVE:
        wa_coss-objnr  TO cosp_r-objnr,
        wa_coss-gjahr  TO cosp_r-gjahr,
        wa_coss-wrttp  TO cosp_r-wrttp,
        wa_coss-kstar  TO cosp_r-kstar,
        wa_coss-wkg012 TO cosp_r-wkg001.
        APPEND cosp_r.
    ENDCASE.
  ENDLOOP.
  LOOP AT cosp_r.
    MOVE cosp_r-objnr TO cosp_rt-objnr.
    AT END OF objnr.
      SUM.
      MOVE cosp_r-wkg001 TO cosp_rt-total.
      APPEND cosp_rt.
    ENDAT.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  COMPARA
*&---------------------------------------------------------------------*
FORM compara .
  LOOP AT cosp_rt.
    IF cosp_rt-total GT 0.   " si tiene partidas reales registradas
      READ TABLE cosp_pt WITH KEY objnr = cosp_rt-objnr.
      IF sy-subrc = 0.
*        PERFORM valida.
*        IF ban = 1.   " no está bloqueado
        IF cosp_pt-total GT 0.
*******PORCENTAJE NIVEL 3
          SELECT SINGLE porcentaje
          FROM zco_tt_porcaviso
          INTO lv_nivel3
          WHERE kokrs = 'SA00'
          AND nivel_aviso = '3'.
* comparar plan VS real.
          porciento = cosp_rt-total / cosp_pt-total.
*********************** NIVELES PARA DETERMINAR EL NIVEL DE CORREO QUE SE VA A ENVIAR ********************* INI
*            if porciento gt '0.75' and porciento le '0.80'.
          IF porciento GT lv_nivel1 AND porciento LE lv_nivel2.
*            PERFORM buscaceco.
************************** MODIFICACIONES MICHAEL 11.12.2020 ******************
*            REFRESH mtext.
**            elseif porciento gt '0.80' and porciento le '0.85'.
*          ELSEIF porciento GT lv_nivel2 AND porciento LE lv_nivel3. " porciento gt lv_nivel2 and porciento le lv_nivel3.
*            PERFORM buscaceco.
**  ************************ MODIFICACIONES MICHAEL 11.12.2020 ******************
*            REFRESH mtext.
*            elseif porciento gt '0.85'.
          ELSEIF porciento GT lv_nivel3."porciento gt lv_nivel3.
            PERFORM buscaceco.
            PERFORM valida.
            if ban = 1.
            REFRESH bdc_data.
            PERFORM bloqueo.
            endif.
          ENDIF.
        ELSE.
          PERFORM buscaceco.
          PERFORM valida.
          if ban = 1.
            REFRESH bdc_data.
            PERFORM bloqueo.
            endif.
        ENDIF. " tiene plan
      ELSE.   " no tiene presupuesto
*        WRITE:/ 'PLAN', cosp_rt-objnr, '0.00',   "cosp_pt-total',
*                'REAL', cosp_rt-objnr, cosp_rt-total,
*                porciento.
        PERFORM buscaceco.
        PERFORM valida.
        if ban = 1.
            REFRESH bdc_data.
            PERFORM bloqueo.
        endif.
      ENDIF.   " existe registro plan
    ENDIF.   " Si tiene partidas reales registradas
  ENDLOOP.
ENDFORM.                    " COMPARA
*&---------------------------------------------------------------------*
*&      Form  BLOQUEO
*&---------------------------------------------------------------------*
FORM bloqueo .
  WRITE:/ 'PLAN', cosp_pt-objnr, cosp_pt-total,
          'REAL', cosp_rt-objnr, cosp_rt-total,
                  porciento.
  perform pantalla_0200.
ENDFORM.                    " BLOQUEO
*&---------------------------------------------------------------------*
*&      Form  BDC_TRANSACTION
*&---------------------------------------------------------------------*
*FORM bdc_transaction USING tcode.
*  CALL FUNCTION 'BDC_INSERT'
*    EXPORTING
*      tcode            = tcode
*    TABLES
*      dynprotab        = bdc_data
*    EXCEPTIONS
*      internal_error   = 1
*      not_open         = 2
*      queue_error      = 3
*      tcode_invalid    = 4
*      printing_invalid = 5
*      posting_invalid  = 6
*      OTHERS           = 7.
*ENDFORM.                    " BDC_TRANSACTION
*&---------------------------------------------------------------------*
*&      Form  BDC_FIELD
*&---------------------------------------------------------------------*
*FORM bdc_field USING program dynpro.
*  CLEAR bdc_data.
*  bdc_data-fnam = program.
*  bdc_data-fval = dynpro.
*  APPEND bdc_data.
*ENDFORM.                    " BDC_FIELD
*&---------------------------------------------------------------------*
*&      Form  BDC_DYNPRO
*&---------------------------------------------------------------------*
*FORM bdc_dynpro USING program dynpro.
*  CLEAR bdc_data.
*  bdc_data-program = program.
*  bdc_data-dynpro  = dynpro.
*  bdc_data-dynbegin = 'X'.
*  APPEND bdc_data.
*ENDFORM.                    " BDC_DYNPRO
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  BUSCACECO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM buscaceco .
  SELECT SINGLE * FROM  csks
  WHERE  kokrs  = cosp_rt-objnr+2(4)
  AND    kostl  = cosp_rt-objnr+6(10)
  AND    datbi  = '99991231'.
  IF sy-subrc = 0.
  ENDIF.
ENDFORM.                    " BUSCACECO
*&---------------------------------------------------------------------*
*&      Form  VALIDA
*&---------------------------------------------------------------------*
*  Valida que el CeCo esté desbloqueado
*----------------------------------------------------------------------*
FORM valida .
  SELECT SINGLE * FROM  csks
  WHERE  kokrs  = cosp_rt-objnr+2(4)
  AND    kostl  = cosp_rt-objnr+6(10)
  AND    datbi  = '99991231'
  AND    bkzkp  = 'X'
  AND    bkzks  = 'X'.
  IF sy-subrc = 0.
    ban = '1'.
  ENDIF.
ENDFORM.                    " VALIDA
*&---------------------------------------------------------------------*
*& Form pantalla_0200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM pantalla_0200 .
*
perform bdc_dynpro using 'SAPLKMA1' '0200'.
perform bdc_field  using 'BDC_CURSOR' 'CSKSZ-KOSTL'.
perform bdc_field  using 'BDC_OKCODE' '=GRUN'.
perform bdc_field  using 'CSKSZ-KOKRS' cosp_rt-objnr+2(4).
perform bdc_field  using 'CSKSZ-KOSTL' cosp_rt-objnr+6(10).
*
perform bdc_dynpro using 'SAPLKMA1' '0299'.
perform bdc_field  using 'BDC_OKCODE' '=KZEI'.
perform bdc_field  using 'BDC_CURSOR' 'CSKSZ-KTEXT'.
*
*
perform bdc_dynpro using 'SAPLKMA1' '0299'.
perform bdc_field  using 'BDC_OKCODE' '=BU'.
perform bdc_field  using 'BDC_CURSOR' 'CSKSZ-BKZKP'.
perform bdc_field  using 'CSKSZ-BKZKP' ' '.
perform bdc_field  using 'CSKSZ-BKZKS' ' '.
 call transaction 'KS02' using bdc_data mode 'E'.
* call transaction 'KS02' using bdc_data mode 'A'.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form bdc_transaction
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
form bdc_transaction using tcode.
   call function 'BDC_INSERT'
      exporting
         tcode            = tcode
         tables
         dynprotab        = bdc_data
      exceptions
         internal_error   = 1
         not_open         = 2
         queue_error      = 3
         tcode_invalid    = 4
         printing_invalid = 5
         posting_invalid  = 6
         others           = 7.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  BDC_FIELD
*&---------------------------------------------------------------------*
form bdc_field using program dynpro.
   clear bdc_data.
   bdc_data-fnam = program.
   bdc_data-fval = dynpro.
   append bdc_data.
endform.                    " BDC_FIELD
*&---------------------------------------------------------------------*
*&      Form  BDC_DYNPRO
*&---------------------------------------------------------------------*
form bdc_dynpro using program dynpro.
   clear bdc_data.
   bdc_data-program = program.
   bdc_data-dynpro  = dynpro.
   bdc_data-dynbegin = 'X'.
   append bdc_data.
endform.                    " BDC_DYNPRO
