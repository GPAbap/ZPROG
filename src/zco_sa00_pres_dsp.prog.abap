************************************************************************
* EMPRESA:      GRUPO PORRES DIVISION AZUCAR
* PROGRAMA:     ZRCO0030
* DESCRIPCION:  COMPARACIÓN PLAN REAL PARA CENTROS DE COSTO Y CUENTAS
* AUTOR:        MARIA DEL CARMEN OCOTLAN GUZMAN MEDINA
* FECHA:        NOVIEMBRE DEL 2018
* Migrado a Hana: MARZO 24 DEL 2023
************************************************************************
REPORT zco_sa00_pres_dsp MESSAGE-ID ze LINE-SIZE 255 LINE-COUNT 65.
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
*        lv_nom TYPE name1,
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

DATA: lv_name1       TYPE name1,
      lv_mail        TYPE string,
*      LV_CORREO TYPE COMM_ID_LONG,
      lv_correo      TYPE zemail,
      lv_correoenvia TYPE zemail,
      lv_pernr       TYPE persno.

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
*    PERIO_P LIKE COEP-PERIO.
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
DATA:
  mailtx LIKE sood1-objdes,
  mailto LIKE sy-uname.
DATA: BEGIN OF mtext OCCURS 0.
        INCLUDE STRUCTURE soli.
DATA: END OF mtext.
*&---------------------------------------------------------------------*
*&     INICIO PROGRAMA
*&---------------------------------------------------------------------*
START-OF-SELECTION.

  SELECT SINGLE mail
    FROM zco_tt_mailaviso
    INTO lv_correoenvia
    WHERE tipoaviso = 1.

  PERFORM plan.
  PERFORM real.
  PERFORM compara.
  SUBMIT zfi_nobloqueo_pres AND RETURN. "Excenta de bloqueo ciertas Sociedades con CeCos.

end-of-selection.
*****     FIN PROGRAMA
*&---------------------------------------------------------------------*
*&      Form  PROCESO
*&---------------------------------------------------------------------*
FORM plan.
* Selecciona los registros PLAN
* Contabilizaciones Externas
  SELECT * FROM cosp
*    WHERE  OBJNR eq 'KSGA00SP0141'
    WHERE  objnr BETWEEN 'KSSA000000000000' AND 'KSSA00ZZZZZZZZZZ'
*    AND    kstar NOT BETWEEN '0000401600' AND '0000401634'
   AND    kstar NOT BETWEEN '0504025112' AND '0504025119'
    AND    gjahr = gjahr_p
    AND    wrttp = '01'
    AND    versn = versn_p.
    CASE sy-datum+4(2).
      WHEN '01'.
        MOVE:
        cosp-objnr  TO cosp_p-objnr,
        cosp-gjahr  TO cosp_p-gjahr,
        cosp-wrttp  TO cosp_p-wrttp,
        cosp-kstar  TO cosp_p-kstar,
        cosp-kstar  TO cosp_p-kstar,
        cosp-wkg001 TO cosp_p-wkg001.
        APPEND cosp_p.
      WHEN '02'.
        MOVE:
        cosp-objnr  TO cosp_p-objnr,
        cosp-gjahr  TO cosp_p-gjahr,
        cosp-wrttp  TO cosp_p-wrttp,
        cosp-kstar  TO cosp_p-kstar,
        cosp-kstar  TO cosp_p-kstar,
        cosp-wkg002 TO cosp_p-wkg001.
        APPEND cosp_p.
      WHEN '03'.
        MOVE:
        cosp-objnr  TO cosp_p-objnr,
        cosp-gjahr  TO cosp_p-gjahr,
        cosp-wrttp  TO cosp_p-wrttp,
        cosp-kstar  TO cosp_p-kstar,
        cosp-kstar  TO cosp_p-kstar,
        cosp-wkg003 TO cosp_p-wkg001.
        APPEND cosp_p.
      WHEN '04'.
        MOVE:
        cosp-objnr  TO cosp_p-objnr,
        cosp-gjahr  TO cosp_p-gjahr,
        cosp-wrttp  TO cosp_p-wrttp,
        cosp-kstar  TO cosp_p-kstar,
        cosp-kstar  TO cosp_p-kstar,
        cosp-wkg004 TO cosp_p-wkg001.
        APPEND cosp_p.
      WHEN '05'.
        MOVE:
        cosp-objnr  TO cosp_p-objnr,
        cosp-gjahr  TO cosp_p-gjahr,
        cosp-wrttp  TO cosp_p-wrttp,
        cosp-kstar  TO cosp_p-kstar,
        cosp-kstar  TO cosp_p-kstar,
        cosp-wkg005 TO cosp_p-wkg001.
        APPEND cosp_p.
      WHEN '06'.
        MOVE:
        cosp-objnr  TO cosp_p-objnr,
        cosp-gjahr  TO cosp_p-gjahr,
        cosp-wrttp  TO cosp_p-wrttp,
        cosp-kstar  TO cosp_p-kstar,
        cosp-kstar  TO cosp_p-kstar,
        cosp-wkg006 TO cosp_p-wkg001.
        APPEND cosp_p.
      WHEN '07'.
        MOVE:
        cosp-objnr  TO cosp_p-objnr,
        cosp-gjahr  TO cosp_p-gjahr,
        cosp-wrttp  TO cosp_p-wrttp,
        cosp-kstar  TO cosp_p-kstar,
        cosp-kstar  TO cosp_p-kstar,
        cosp-wkg007 TO cosp_p-wkg001.
        APPEND cosp_p.
      WHEN '08'.
        MOVE:
        cosp-objnr  TO cosp_p-objnr,
        cosp-gjahr  TO cosp_p-gjahr,
        cosp-wrttp  TO cosp_p-wrttp,
        cosp-kstar  TO cosp_p-kstar,
        cosp-kstar  TO cosp_p-kstar,
        cosp-wkg008 TO cosp_p-wkg001.
        APPEND cosp_p.
      WHEN '09'.
        MOVE:
        cosp-objnr  TO cosp_p-objnr,
        cosp-gjahr  TO cosp_p-gjahr,
        cosp-wrttp  TO cosp_p-wrttp,
        cosp-kstar  TO cosp_p-kstar,
        cosp-kstar  TO cosp_p-kstar,
        cosp-wkg009 TO cosp_p-wkg001.
        APPEND cosp_p.
      WHEN '10'.
        MOVE:
        cosp-objnr  TO cosp_p-objnr,
        cosp-gjahr  TO cosp_p-gjahr,
        cosp-wrttp  TO cosp_p-wrttp,
        cosp-kstar  TO cosp_p-kstar,
        cosp-kstar  TO cosp_p-kstar,
        cosp-wkg010 TO cosp_p-wkg001.
        APPEND cosp_p.
      WHEN '11'.
        MOVE:
        cosp-objnr  TO cosp_p-objnr,
        cosp-gjahr  TO cosp_p-gjahr,
        cosp-wrttp  TO cosp_p-wrttp,
        cosp-kstar  TO cosp_p-kstar,
        cosp-kstar  TO cosp_p-kstar,
        cosp-wkg011 TO cosp_p-wkg001.
        APPEND cosp_p.
      WHEN '12'.
        MOVE:
        cosp-objnr  TO cosp_p-objnr,
        cosp-gjahr  TO cosp_p-gjahr,
        cosp-wrttp  TO cosp_p-wrttp,
        cosp-kstar  TO cosp_p-kstar,
        cosp-kstar  TO cosp_p-kstar,
        cosp-wkg012 TO cosp_p-wkg001.
        APPEND cosp_p.
    ENDCASE.
  ENDSELECT.
* Contabilizaciones Internas
  SELECT * FROM coss
*    WHERE  OBJNR eq 'KSGA00SP0141'
      WHERE  objnr BETWEEN 'KSSA000000000000' AND 'KSSA00ZZZZZZZZZZ'
*      AND    kstar NOT BETWEEN '0000401600' AND '0000401634'
      AND    kstar NOT BETWEEN '0504025112' AND '0504025119'
      AND    gjahr = gjahr_p
      AND    wrttp = '01'
      AND    versn = versn_p.
    CASE sy-datum+4(2).
      WHEN '01'.
        MOVE:
        coss-objnr  TO cosp_p-objnr,
        coss-gjahr  TO cosp_p-gjahr,
        coss-wrttp  TO cosp_p-wrttp,
        coss-kstar  TO cosp_p-kstar,
*      coss-kstar  to cosp_p-kstar,
        coss-wkg001 TO cosp_p-wkg001.
        APPEND cosp_p.
      WHEN '02'.
        MOVE:
        coss-objnr  TO cosp_p-objnr,
        coss-gjahr  TO cosp_p-gjahr,
        coss-wrttp  TO cosp_p-wrttp,
        coss-kstar  TO cosp_p-kstar,
*      coss-kstar  to cosp_p-kstar,
        coss-wkg002 TO cosp_p-wkg001.
        APPEND cosp_p.
      WHEN '03'.
        MOVE:
        coss-objnr  TO cosp_p-objnr,
        coss-gjahr  TO cosp_p-gjahr,
        coss-wrttp  TO cosp_p-wrttp,
        coss-kstar  TO cosp_p-kstar,
*      coss-kstar  to cosp_p-kstar,
        coss-wkg003 TO cosp_p-wkg001.
        APPEND cosp_p.
      WHEN '04'.
        MOVE:
        coss-objnr  TO cosp_p-objnr,
        coss-gjahr  TO cosp_p-gjahr,
        coss-wrttp  TO cosp_p-wrttp,
        coss-kstar  TO cosp_p-kstar,
*      coss-kstar  to cosp_p-kstar,
        coss-wkg004 TO cosp_p-wkg001.
        APPEND cosp_p.
      WHEN '05'.
        MOVE:
        coss-objnr  TO cosp_p-objnr,
        coss-gjahr  TO cosp_p-gjahr,
        coss-wrttp  TO cosp_p-wrttp,
        coss-kstar  TO cosp_p-kstar,
*      coss-kstar  to cosp_p-kstar,
        coss-wkg005 TO cosp_p-wkg001.
        APPEND cosp_p.
      WHEN '06'.
        MOVE:
        coss-objnr  TO cosp_p-objnr,
        coss-gjahr  TO cosp_p-gjahr,
        coss-wrttp  TO cosp_p-wrttp,
        coss-kstar  TO cosp_p-kstar,
*      coss-kstar  to cosp_p-kstar,
        coss-wkg006 TO cosp_p-wkg001.
        APPEND cosp_p.
      WHEN '07'.
        MOVE:
        coss-objnr  TO cosp_p-objnr,
        coss-gjahr  TO cosp_p-gjahr,
        coss-wrttp  TO cosp_p-wrttp,
        coss-kstar  TO cosp_p-kstar,
*      coss-kstar  to cosp_p-kstar,
        coss-wkg007 TO cosp_p-wkg001.
        APPEND cosp_p.
      WHEN '08'.
        MOVE:
        coss-objnr  TO cosp_p-objnr,
        coss-gjahr  TO cosp_p-gjahr,
        coss-wrttp  TO cosp_p-wrttp,
        coss-kstar  TO cosp_p-kstar,
*      coss-kstar  to cosp_p-kstar,
        coss-wkg008 TO cosp_p-wkg001.
        APPEND cosp_p.
      WHEN '09'.
        MOVE:
        coss-objnr  TO cosp_p-objnr,
        coss-gjahr  TO cosp_p-gjahr,
        coss-wrttp  TO cosp_p-wrttp,
        coss-kstar  TO cosp_p-kstar,
*      coss-kstar  to cosp_p-kstar,
        coss-wkg009 TO cosp_p-wkg001.
        APPEND cosp_p.
      WHEN '10'.
        MOVE:
        coss-objnr  TO cosp_p-objnr,
        coss-gjahr  TO cosp_p-gjahr,
        coss-wrttp  TO cosp_p-wrttp,
        coss-kstar  TO cosp_p-kstar,
*      coss-kstar  to cosp_p-kstar,
        coss-wkg010 TO cosp_p-wkg001.
        APPEND cosp_p.
      WHEN '11'.
        MOVE:
        coss-objnr  TO cosp_p-objnr,
        coss-gjahr  TO cosp_p-gjahr,
        coss-wrttp  TO cosp_p-wrttp,
        coss-kstar  TO cosp_p-kstar,
*      coss-kstar  to cosp_p-kstar,
        coss-wkg011 TO cosp_p-wkg001.
        APPEND cosp_p.
      WHEN '12'.
        MOVE:
        coss-objnr  TO cosp_p-objnr,
        coss-gjahr  TO cosp_p-gjahr,
        coss-wrttp  TO cosp_p-wrttp,
        coss-kstar  TO cosp_p-kstar,
*      coss-kstar  to cosp_p-kstar,
        coss-wkg012 TO cosp_p-wkg001.
        APPEND cosp_p.
    ENDCASE.
  ENDSELECT.
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
  SELECT * FROM cosp
    WHERE  objnr BETWEEN 'KSSA000000000000' AND 'KSSA00ZZZZZZZZZZ'
*    AND    kstar NOT BETWEEN '0000401600' AND '0000401634'
    AND    kstar NOT BETWEEN '0504025112' AND '0504025119'
    AND    wrttp = '04'
    AND    gjahr = gjahr_p.
    CASE sy-datum+4(2).
      WHEN '01'.
        MOVE:
        cosp-objnr  TO cosp_r-objnr,
        cosp-gjahr  TO cosp_r-gjahr,
        cosp-wrttp  TO cosp_r-wrttp,
        cosp-kstar  TO cosp_r-kstar,
        cosp-kstar  TO cosp_r-kstar,
        cosp-wkg001 TO cosp_r-wkg001.
        APPEND cosp_r.
      WHEN '02'.
        MOVE:
        cosp-objnr  TO cosp_r-objnr,
        cosp-gjahr  TO cosp_r-gjahr,
        cosp-wrttp  TO cosp_r-wrttp,
        cosp-kstar  TO cosp_r-kstar,
        cosp-kstar  TO cosp_r-kstar,
        cosp-wkg002 TO cosp_r-wkg001.
        APPEND cosp_r.
      WHEN '03'.
        MOVE:
        cosp-objnr  TO cosp_r-objnr,
        cosp-gjahr  TO cosp_r-gjahr,
        cosp-wrttp  TO cosp_r-wrttp,
        cosp-kstar  TO cosp_r-kstar,
        cosp-kstar  TO cosp_r-kstar,
        cosp-wkg003 TO cosp_r-wkg001.
        APPEND cosp_r.
      WHEN '04'.
        MOVE:
        cosp-objnr  TO cosp_r-objnr,
        cosp-gjahr  TO cosp_r-gjahr,
        cosp-wrttp  TO cosp_r-wrttp,
        cosp-kstar  TO cosp_r-kstar,
        cosp-kstar  TO cosp_r-kstar,
        cosp-wkg004 TO cosp_r-wkg001.
        APPEND cosp_r.
      WHEN '05'.
        MOVE:
        cosp-objnr  TO cosp_r-objnr,
        cosp-gjahr  TO cosp_r-gjahr,
        cosp-wrttp  TO cosp_r-wrttp,
        cosp-kstar  TO cosp_r-kstar,
        cosp-kstar  TO cosp_r-kstar,
        cosp-wkg005 TO cosp_r-wkg001.
        APPEND cosp_r.
      WHEN '06'.
        MOVE:
        cosp-objnr  TO cosp_r-objnr,
        cosp-gjahr  TO cosp_r-gjahr,
        cosp-wrttp  TO cosp_r-wrttp,
        cosp-kstar  TO cosp_r-kstar,
        cosp-kstar  TO cosp_r-kstar,
        cosp-wkg006 TO cosp_r-wkg001.
        APPEND cosp_r.
      WHEN '07'.
        MOVE:
        cosp-objnr  TO cosp_r-objnr,
        cosp-gjahr  TO cosp_r-gjahr,
        cosp-wrttp  TO cosp_r-wrttp,
        cosp-kstar  TO cosp_r-kstar,
        cosp-kstar  TO cosp_r-kstar,
        cosp-wkg007 TO cosp_r-wkg001.
        APPEND cosp_r.
      WHEN '08'.
        MOVE:
        cosp-objnr  TO cosp_r-objnr,
        cosp-gjahr  TO cosp_r-gjahr,
        cosp-wrttp  TO cosp_r-wrttp,
        cosp-kstar  TO cosp_r-kstar,
        cosp-kstar  TO cosp_r-kstar,
        cosp-wkg008 TO cosp_r-wkg001.
        APPEND cosp_r.
      WHEN '09'.
        MOVE:
        cosp-objnr  TO cosp_r-objnr,
        cosp-gjahr  TO cosp_r-gjahr,
        cosp-wrttp  TO cosp_r-wrttp,
        cosp-kstar  TO cosp_r-kstar,
        cosp-kstar  TO cosp_r-kstar,
        cosp-wkg009 TO cosp_r-wkg001.
        APPEND cosp_r.
      WHEN '10'.
        MOVE:
        cosp-objnr  TO cosp_r-objnr,
        cosp-gjahr  TO cosp_r-gjahr,
        cosp-wrttp  TO cosp_r-wrttp,
        cosp-kstar  TO cosp_r-kstar,
        cosp-kstar  TO cosp_r-kstar,
        cosp-wkg010 TO cosp_r-wkg001.
        APPEND cosp_r.
      WHEN '11'.
        MOVE:
        cosp-objnr  TO cosp_r-objnr,
        cosp-gjahr  TO cosp_r-gjahr,
        cosp-wrttp  TO cosp_r-wrttp,
        cosp-kstar  TO cosp_r-kstar,
        cosp-kstar  TO cosp_r-kstar,
        cosp-wkg011 TO cosp_r-wkg001.
        APPEND cosp_r.
      WHEN '12'.
        MOVE:
        cosp-objnr  TO cosp_r-objnr,
        cosp-gjahr  TO cosp_r-gjahr,
        cosp-wrttp  TO cosp_r-wrttp,
        cosp-kstar  TO cosp_r-kstar,
        cosp-kstar  TO cosp_r-kstar,
        cosp-wkg012 TO cosp_r-wkg001.
        APPEND cosp_r.
    ENDCASE.
  ENDSELECT.
* Contabilizaciones internas
  SELECT * FROM cosp
      WHERE  objnr BETWEEN 'KSSA000000000000' AND 'KSSA00ZZZZZZZZZZ'
*      AND    kstar NOT BETWEEN '0000401600' AND '0000401634'
      AND    kstar NOT BETWEEN '0504025112' AND '0504025119'
      AND    wrttp = '04'
      AND    gjahr = gjahr_p.
    CASE sy-datum+4(2).
      WHEN '01'.
        MOVE:
        coss-objnr  TO cosp_r-objnr,
        coss-gjahr  TO cosp_r-gjahr,
        coss-wrttp  TO cosp_r-wrttp,
        coss-kstar  TO cosp_r-kstar,
        coss-kstar  TO cosp_r-kstar,
        coss-wkg001 TO cosp_r-wkg001.
        APPEND cosp_r.
      WHEN '02'.
        MOVE:
        coss-objnr  TO cosp_r-objnr,
        coss-gjahr  TO cosp_r-gjahr,
        coss-wrttp  TO cosp_r-wrttp,
        coss-kstar  TO cosp_r-kstar,
        coss-kstar  TO cosp_r-kstar,
        coss-wkg002 TO cosp_r-wkg001.
        APPEND cosp_r.
      WHEN '03'.
        MOVE:
        coss-objnr  TO cosp_r-objnr,
        coss-gjahr  TO cosp_r-gjahr,
        coss-wrttp  TO cosp_r-wrttp,
        coss-kstar  TO cosp_r-kstar,
        coss-kstar  TO cosp_r-kstar,
        coss-wkg003 TO cosp_r-wkg001.
        APPEND cosp_r.
      WHEN '04'.
        MOVE:
        coss-objnr  TO cosp_r-objnr,
        coss-gjahr  TO cosp_r-gjahr,
        coss-wrttp  TO cosp_r-wrttp,
        coss-kstar  TO cosp_r-kstar,
        coss-kstar  TO cosp_r-kstar,
        coss-wkg004 TO cosp_r-wkg001.
        APPEND cosp_r.
      WHEN '05'.
        MOVE:
        coss-objnr  TO cosp_r-objnr,
        coss-gjahr  TO cosp_r-gjahr,
        coss-wrttp  TO cosp_r-wrttp,
        coss-kstar  TO cosp_r-kstar,
        coss-kstar  TO cosp_r-kstar,
        coss-wkg005 TO cosp_r-wkg001.
        APPEND cosp_r.
      WHEN '06'.
        MOVE:
        coss-objnr  TO cosp_r-objnr,
        coss-gjahr  TO cosp_r-gjahr,
        coss-wrttp  TO cosp_r-wrttp,
        coss-kstar  TO cosp_r-kstar,
        coss-kstar  TO cosp_r-kstar,
        coss-wkg006 TO cosp_r-wkg001.
        APPEND cosp_r.
      WHEN '07'.
        MOVE:
        coss-objnr  TO cosp_r-objnr,
        coss-gjahr  TO cosp_r-gjahr,
        coss-wrttp  TO cosp_r-wrttp,
        coss-kstar  TO cosp_r-kstar,
        coss-kstar  TO cosp_r-kstar,
        coss-wkg007 TO cosp_r-wkg001.
        APPEND cosp_r.
      WHEN '08'.
        MOVE:
        coss-objnr  TO cosp_r-objnr,
        coss-gjahr  TO cosp_r-gjahr,
        coss-wrttp  TO cosp_r-wrttp,
        coss-kstar  TO cosp_r-kstar,
        coss-kstar  TO cosp_r-kstar,
        coss-wkg008 TO cosp_r-wkg001.
        APPEND cosp_r.
      WHEN '09'.
        MOVE:
        coss-objnr  TO cosp_r-objnr,
        coss-gjahr  TO cosp_r-gjahr,
        coss-wrttp  TO cosp_r-wrttp,
        coss-kstar  TO cosp_r-kstar,
        coss-kstar  TO cosp_r-kstar,
        coss-wkg009 TO cosp_r-wkg001.
        APPEND cosp_r.
      WHEN '10'.
        MOVE:
        coss-objnr  TO cosp_r-objnr,
        coss-gjahr  TO cosp_r-gjahr,
        coss-wrttp  TO cosp_r-wrttp,
        coss-kstar  TO cosp_r-kstar,
        coss-kstar  TO cosp_r-kstar,
        coss-wkg010 TO cosp_r-wkg001.
        APPEND cosp_r.
      WHEN '11'.
        MOVE:
        coss-objnr  TO cosp_r-objnr,
        coss-gjahr  TO cosp_r-gjahr,
        coss-wrttp  TO cosp_r-wrttp,
        coss-kstar  TO cosp_r-kstar,
        coss-kstar  TO cosp_r-kstar,
        coss-wkg011 TO cosp_r-wkg001.
        APPEND cosp_r.
      WHEN '12'.
        MOVE:
        coss-objnr  TO cosp_r-objnr,
        coss-gjahr  TO cosp_r-gjahr,
        coss-wrttp  TO cosp_r-wrttp,
        coss-kstar  TO cosp_r-kstar,
        coss-kstar  TO cosp_r-kstar,
        coss-wkg012 TO cosp_r-wkg001.
        APPEND cosp_r.
    ENDCASE.
  ENDSELECT.
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
        PERFORM valida.
        IF ban = 1.   " no está bloqueado
          IF cosp_pt-total GT 0.
************************ MODIFICACIONES MICHAEL CHAVEZ 12.11.2020 INI
*********************** SELECT QUE SE TIENEN QUE HACER PARA OBTENER LOS PARAMETROS DE PORCENTAJE ********** INI
*******PORCENTAJE NIVEL 1
            SELECT SINGLE porcentaje
              FROM zco_tt_porcaviso
              INTO lv_nivel1
              WHERE kokrs = 'SA00'
            AND nivel_aviso = '1'.

*******PORCENTAJE NIVEL 2
            SELECT SINGLE porcentaje
              FROM zco_tt_porcaviso
              INTO lv_nivel2
              WHERE kokrs = 'SA00'
            AND nivel_aviso = '2'.

*******PORCENTAJE NIVEL 3
            SELECT SINGLE porcentaje
              FROM zco_tt_porcaviso
              INTO lv_nivel3
              WHERE kokrs = 'SA00'
            AND nivel_aviso = '3'.
*********************** SELECT QUE SE TIENEN QUE HACER PARA OBTENER LOS PARAMETROS DE PORCENTAJE ********** FIN
************************ MODIFICACIONES MICHAEL CHAVEZ 12.11.2020 FIN
* comparar plan VS real.
            porciento = cosp_rt-total / cosp_pt-total.
            WRITE:/ 'PLAN', cosp_pt-objnr, cosp_pt-total,
                    'REAL', cosp_rt-objnr, cosp_rt-total,
                    porciento.
*********************** NIVELES PARA DETERMINAR EL NIVEL DE CORREO QUE SE VA A ENVIAR ********************* INI
*            if porciento gt '0.75' and porciento le '0.80'.
            IF porciento GT lv_nivel1 AND porciento LE lv_nivel2. "porciento gt lv_nivel1 and porciento le lv_nivel2.
              PERFORM buscaceco.
************************* MODIFICACIONES MICHAEL 11.12.2020 ******************
              PERFORM EnviaCorreo1.
************************* MODIFICACIONES MICHAEL 11.12.2020 ******************
*              perform correo1.
              REFRESH mtext.
*            elseif porciento gt '0.80' and porciento le '0.85'.
            ELSEIF porciento GT lv_nivel2 AND porciento LE lv_nivel3. " porciento gt lv_nivel2 and porciento le lv_nivel3.
              PERFORM buscaceco.
*              perform correo2.
*  ************************ MODIFICACIONES MICHAEL 11.12.2020 ******************
              PERFORM EnviaCorreo2.
*  ************************ MODIFICACIONES MICHAEL 11.12.2020 ******************
              REFRESH mtext.
*            elseif porciento gt '0.85'.
            ELSEIF porciento GT lv_nivel3."porciento gt lv_nivel3.
              PERFORM buscaceco.
              REFRESH bdc_data.
*              PERFORM bloqueo.
*  ************************ MODIFICACIONES MICHAEL 11.12.2020 ******************
              PERFORM EnviaCorreo3.
*  ************************ MODIFICACIONES MICHAEL 11.12.2020 ******************
*              perform correo1.
              REFRESH mtext.
            ENDIF.
          ELSE.
            PERFORM buscaceco.
            REFRESH bdc_data.
*            PERFORM bloqueo.
*{   INSERT         PROK902811                                        1
*  ************************ MODIFICACIONES MICHAEL 11.12.2020 ******************
            PERFORM EnviaCorreo3.
*  ************************ MODIFICACIONES MICHAEL 11.12.2020 *******************
*}   INSERT
*        perform correo3.
            REFRESH mtext.
          ENDIF. " tiene plan
        ENDIF.     " no esta bloqueado
      ELSE.   " no tiene presupuesto
        WRITE:/ 'PLAN', cosp_pt-objnr, cosp_pt-total,
                'REAL', cosp_rt-objnr, cosp_rt-total,
                porciento.
        PERFORM buscaceco.
        REFRESH bdc_data.
*        PERFORM bloqueo.
*{   INSERT         PROK902811                                        2
**  ************************ MODIFICACIONES MICHAEL 11.12.2020 ******************
        PERFORM EnviaCorreo3.
*  ************************ MODIFICACIONES MICHAEL 11.12.2020 ******************
*}   INSERT
*          perform correo3.
        REFRESH mtext.
      ENDIF.   " existe registro plan
    ENDIF.   " Si tiene partidas reales registradas
  ENDLOOP.
*  perform close_group.
ENDFORM.                    " COMPARA
*&---------------------------------------------------------------------*
*&      Form  CORREO1
*&---------------------------------------------------------------------*
* avisar que llegó al pocerntaje del 85
*----------------------------------------------------------------------*
FORM correo1 .
  total_real = cosp_rt-total.
  total_plan = cosp_pt-total.
  CONCATENATE 'Centro de Costo:' cosp_rt-objnr+6(10) 'al 80% del PLAN'
  INTO mailtx SEPARATED BY space.
  CONCATENATE 'Centro de Costo:' cosp_rt-objnr+6(10) " 'al 85% del PLAN'
  INTO mtext SEPARATED BY space.
  APPEND mtext.
  CLEAR mtext.
  APPEND mtext.
  CONCATENATE 'ha llegado al 80% del PLAN, ' total_real 'de' total_plan
   INTO mtext SEPARATED BY space.
  APPEND mtext.
  CLEAR mtext.
  APPEND mtext.
  MOVE 'Favor de revisar sus registros para evitar su bloqueo'
  TO mtext.
  APPEND mtext.
  CLEAR mtext.
  APPEND mtext.
  MOVE 'Para cualquier aclaración llamar a su Gerente Administrativo'
  TO mtext.
  APPEND mtext.
  CLEAR mtext.
  APPEND mtext.
  MOVE 'GRACIAS' TO mtext.
  APPEND mtext.
  MOVE csks-datlt TO destino.
*  mailto = destino.
  mailto = 'MARY'.
  CALL FUNCTION 'RS_SEND_MAIL_FOR_SPOOLLIST'
    EXPORTING
*     SPOOLNUMBER       = SY-SPONO
      mailname  = sy-uname
      mailtitel = mailtx
      user      = mailto
    TABLES
      text      = mtext.
*   EXCEPTIONS
*     ERROR             = 1
*     OTHERS            = 2
  .
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  CORREO2
*&---------------------------------------------------------------------*
*  avisar que llegó al porentaje del 90
*----------------------------------------------------------------------*
FORM correo2 .
  total_real = cosp_rt-total.
  total_plan = cosp_pt-total.
  CONCATENATE 'Centro de Costo:' cosp_rt-objnr+6(10) 'al 85% del PLAN'
  INTO mailtx SEPARATED BY space.
  CONCATENATE 'Centro de Costo:' cosp_rt-objnr+6(10)
  INTO mtext SEPARATED BY space.
  APPEND mtext.
  CLEAR mtext.
  APPEND mtext.
  CONCATENATE 'ha llegado al 85% del PLAN, ' total_real 'de' total_plan
   INTO mtext SEPARATED BY space.
  APPEND mtext.
  CLEAR mtext.
  APPEND mtext.
  MOVE 'Favor de revisar sus registros para evitar su bloqueo'
  TO mtext.
  APPEND mtext.
  CLEAR mtext.
  APPEND mtext.
  MOVE 'Para cualquier aclaración llamar a su Gerente Administrativo'
  TO mtext.
  APPEND mtext.
  CLEAR mtext.
  APPEND mtext.
  MOVE 'GRACIAS' TO mtext.
  APPEND mtext.
  MOVE csks-datlt TO destino.
*  mailto = destino.
  mailto = 'MARY'.
  CALL FUNCTION 'RS_SEND_MAIL_FOR_SPOOLLIST'
    EXPORTING
*     SPOOLNUMBER       = SY-SPONO
      mailname  = sy-uname
      mailtitel = mailtx
      user      = mailto
    TABLES
      text      = mtext.
*   EXCEPTIONS
*     ERROR             = 1
*     OTHERS            = 2
  .
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.
ENDFORM.                    " CORREO2
*&---------------------------------------------------------------------*
*&      Form  CORREO3
*&---------------------------------------------------------------------*
*  avisar que el centro de costo está bloqueado
*----------------------------------------------------------------------*
FORM correo3 .
  total_real = cosp_rt-total.
  total_plan = cosp_pt-total.
  CONCATENATE 'Centro de Costo:' cosp_rt-objnr+6(10) 'al 90% del PLAN'
  INTO mailtx SEPARATED BY space.
  CONCATENATE 'Centro de Costo:' cosp_rt-objnr+6(10)
  INTO mtext SEPARATED BY space.
  APPEND mtext.
  CLEAR mtext.
  APPEND mtext.
  CONCATENATE 'ha llegado al 90% del PLAN, ' total_real 'de' total_plan
   INTO mtext SEPARATED BY space.
  APPEND mtext.
  CLEAR mtext.
  APPEND mtext.
  MOVE 'El centro de costo antes mencionado ha sido bloqueado'
  TO mtext.
  APPEND mtext.
  CLEAR mtext.
  APPEND mtext.
  MOVE 'Para cualquier aclaración llamar a su Gerente Administrativo'
  TO mtext.
  APPEND mtext.
  CLEAR mtext.
  APPEND mtext.
  MOVE 'GRACIAS' TO mtext.
  APPEND mtext.
  MOVE csks-datlt TO destino.
*  mailto = destino.
  mailto = 'MARY'.
  CALL FUNCTION 'RS_SEND_MAIL_FOR_SPOOLLIST'
    EXPORTING
*     SPOOLNUMBER       = SY-SPONO
      mailname  = sy-uname
      mailtitel = mailtx
      user      = mailto
    TABLES
      text      = mtext.
*   EXCEPTIONS
*     ERROR             = 1
*     OTHERS            = 2
  .
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.
ENDFORM.                    " CORREO3
*&---------------------------------------------------------------------*
*&      Form  BLOQUEO
*&---------------------------------------------------------------------*
FORM bloqueo .
  DATA: vl_CONTROLLINGAREA LIKE bapi0012_gen-co_area,
        it_COSTCENTERLIST  TYPE STANDARD TABLE OF bapi0012_ccinputlist,
        wa_COSTCENTERLIST  LIKE LINE OF it_COSTCENTERLIST,
        it_RETURN          TYPE STANDARD TABLE OF bapiret2.


** Dynpro
*  PERFORM bdc_dynpro USING 'SAPLKMA1' '0200'.
*  PERFORM bdc_field  USING 'BDC_CURSOR' 'CSKSZ-KOKRS'.
*  PERFORM bdc_field  USING 'BDC_OKCODE' '/00'.
*  PERFORM bdc_field  USING 'CSKSZ-KOKRS' cosp_rt+2(4).
*  PERFORM bdc_field  USING 'CSKSZ-KOSTL' cosp_rt+6(10).
** Dynpro
*  PERFORM bdc_dynpro USING 'SAPLKMA1' '0299'.
*  PERFORM bdc_field  USING 'BDC_OKCODE' '=KZEI'.
*  PERFORM bdc_field  USING 'BDC_SUBSCR' 'SAPLKMA1                                0300SUBSCREEN_EINZEL'.
*  PERFORM bdc_field  USING 'BDC_CURSOR' 'CSKSZ-KTEXT'.
** Dynpro
*  PERFORM bdc_dynpro USING 'SAPLKMA1' '0299'.
*  PERFORM bdc_field  USING 'BDC_OKCODE' '=BU'.
*  PERFORM bdc_field  USING 'BDC_SUBSCR' 'SAPLKMA1                                0310SUBSCREEN_EINZEL'.
*  PERFORM bdc_field  USING 'BDC_CURSOR' 'CSKSZ-PKZER'.
*  PERFORM bdc_field  USING 'CSKSZ-BKZKP' 'X'.
*  PERFORM bdc_field  USING 'CSKSZ-BKZKS' 'X'.
*  PERFORM bdc_field  USING 'CSKSZ-BKZER' 'X'.
*  PERFORM bdc_field  USING 'CSKSZ-PKZER' 'X'.
*  CALL TRANSACTION 'KS02' USING bdc_data MODE 'E'.
* call transaction 'KS02' using bdc_data mode 'A'.

  vl_controllingarea = cosp_rt+2(4).
  wa_costcenterlist-costcenter = cosp_rt+6(10).
  wa_costcenterlist-valid_from = '20220101'.
  wa_costcenterlist-valid_to = '99991231'.
  wa_costcenterlist-lock_ind_actual_primary_costs = 'X'.
  wa_costcenterlist-lock_ind_act_secondary_costs = 'X'.
  "wa_costcenterlist-lock_ind_actual_revenues = 'X'.
  "wa_costcenterlist-lock_ind_plan_revenues = 'X'.
  APPEND wa_costcenterlist TO it_costcenterlist.

  CALL FUNCTION 'BAPI_COSTCENTER_CHANGEMULTIPLE'
    EXPORTING
      controllingarea = vl_controllingarea
    TABLES
      costcenterlist  = it_costcenterlist
      return          = it_return
     .

   IF IT_RETURN[] IS NOT INITIAL.
     READ TABLE it_return into data(wa) WITH KEY TYPE = 'E'.
     IF sy-subrc ne 0.
       CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          WAIT          = 'X'
        .

     ENDIF.
  ENDIF.

ENDFORM.                    " BLOQUEO
*&---------------------------------------------------------------------*
*&      Form  BDC_TRANSACTION
*&---------------------------------------------------------------------*
FORM bdc_transaction USING tcode.
  CALL FUNCTION 'BDC_INSERT'
    EXPORTING
      tcode            = tcode
    TABLES
      dynprotab        = bdc_data
    EXCEPTIONS
      internal_error   = 1
      not_open         = 2
      queue_error      = 3
      tcode_invalid    = 4
      printing_invalid = 5
      posting_invalid  = 6
      OTHERS           = 7.
ENDFORM.                    " BDC_TRANSACTION
*&---------------------------------------------------------------------*
*&      Form  BDC_FIELD
*&---------------------------------------------------------------------*
FORM bdc_field USING program dynpro.
  CLEAR bdc_data.
  bdc_data-fnam = program.
  bdc_data-fval = dynpro.
  APPEND bdc_data.
ENDFORM.                    " BDC_FIELD
*&---------------------------------------------------------------------*
*&      Form  BDC_DYNPRO
*&---------------------------------------------------------------------*
FORM bdc_dynpro USING program dynpro.
  CLEAR bdc_data.
  bdc_data-program = program.
  bdc_data-dynpro  = dynpro.
  bdc_data-dynbegin = 'X'.
  APPEND bdc_data.
ENDFORM.                    " BDC_DYNPRO
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
  AND    bkzkp  = ' '
  AND    bkzks  = ' '.
  IF sy-subrc = 0.
    ban = '1'.
  ENDIF.
ENDFORM.                    " VALIDA

********************************* MODIFICACIONES MICHAEL 12.11.2020 INI
********************************* FUNCIONES PARA ENVIAR CORREO DE ACUERDO A NIVEL ****************************** INI
FORM EnviaCorreo1.
**  ************** SE HACE SELECT Y SE TIENE QUE HACER SELECT POR NIVEL
*  SELECT *
*    FROM zco_tt_avisos
*    INTO TABLE it_avisos
*    WHERE ceco = cosp_rt-objnr+6(10)
*    AND ano = sy-datum(4)
*    AND periodo = sy-datum+4(2)
*  AND nivel_aviso = 1.
** Si no es igual a cero se tiene que enviar el correo
*  IF sy-subrc NE 0.
*    SELECT SINGLE email
*      FROM zco_tt_cecoaut
*      INTO lv_correo
*      WHERE kokrs = 'GA00' " de prueba
*    AND kostl = cosp_rt-objnr+6(10).
*    IF sy-subrc = 0.
*      lv_mail = lv_correo.
*      " si encuentra datos
*      IF sy-subrc = 0.
**     " Mandamos el correo
*        CLEAR: lv_porcentaje1, lv_porc1, lv_mensaje, lv_encabezado.
*        lv_porcentaje1 = lv_nivel1 * 100.
*        lv_porc1 = lv_porcentaje1.
*        CONCATENATE lv_porc1 '%' INTO lv_porc1.
*        CONCATENATE 'El centro de costos' cosp_rt-objnr+6(10) 'ha llegado al' lv_porc1 'del plan.' INTO lv_mensaje SEPARATED BY space.
*        CONCATENATE 'CECO' cosp_rt-objnr+6(10) '[AVISO DE LIMITE DE PRESUPUESTO]' INTO lv_encabezado SEPARATED BY space.
*        CALL FUNCTION 'ZCFD_SEND_CORREO'
*          EXPORTING
*            correos    = lv_mail
*            body       = lv_mensaje "'aquí va el cuerpo del correo'
*            asunto     = lv_encabezado "'Aviso presupuesto'
*            mailsender = lv_correoenvia. "'mchavez@gporres.com.mx'.
*        " si se envio el correo
*        IF sy-subrc = 0.
*          wa_aviso-ano = sy-datum(4).
*          wa_aviso-periodo = sy-datum+4(2).
*          wa_aviso-ceco = cosp_rt-objnr+6(10).
*          wa_aviso-nivel_aviso = 1. "nivel que le toca.
*          wa_aviso-fecha = sy-datum.
*          wa_aviso-hora = sy-uzeit.
*          wa_aviso-porcentajereal = porciento.
*          wa_aviso-porcentajeplan = lv_nivel1.
*          INSERT
*          zco_tt_avisos
*          FROM
*          wa_aviso.
*          IF sy-subrc = 0.
*            CLEAR wa_aviso.
*          ENDIF.
*        ENDIF.
*      ENDIF.
*    ENDIF.
*  ENDIF.
ENDFORM.


FORM EnviaCorreo2.
**  ************** SE HACE SELECT Y SE TIENE QUE HACER SELECT POR NIVEL
*  SELECT *
*    FROM zco_tt_avisos
*    INTO TABLE it_avisos
*    WHERE ceco = cosp_rt-objnr+6(10)
*    AND ano = sy-datum(4)
*    AND periodo = sy-datum+4(2)
*  AND nivel_aviso = 2.
**   Si no es igual a cero se tiene que enviar el correo
*  IF sy-subrc NE 0.
*    SELECT SINGLE email
*      FROM zco_tt_cecoaut
*      INTO lv_correo
*      WHERE kokrs = 'SA00' " de prueba
*    AND kostl = cosp_rt-objnr+6(10).
*    IF sy-subrc = 0.
*      lv_mail = lv_correo.
*      IF sy-subrc = 0.
*        CLEAR: lv_porcentaje2, lv_porc2, lv_mensaje, lv_encabezado.
*        lv_porcentaje2 = lv_nivel2 * 100.
*        lv_porc2 = lv_porcentaje2.
*        CONCATENATE lv_porc2 '%' INTO lv_porc2.
*        CONCATENATE 'El centro de costos' cosp_rt-objnr+6(10) 'ha llegado al' lv_porc2 'del plan y está próximo a bloquearse' INTO lv_mensaje SEPARATED BY space.
*        CONCATENATE 'CECO' cosp_rt-objnr+6(10) '[AVISO DE LIMITE DE PRESUPUESTO]' INTO lv_encabezado SEPARATED BY space.
*
*        CALL FUNCTION 'ZCFD_SEND_CORREO'
*          EXPORTING
*            correos    = lv_mail
*            body       = lv_mensaje "'aquí va el cuerpo del correo'
*            asunto     = lv_encabezado "'Aviso presupuesto'
*            mailsender = lv_correoenvia. "'mchavez@gporres.com.mx'.
*
*        " si se envio el correo
*        IF sy-subrc = 0.
*
**          wa_aviso-kokrs = 'GA00'.
*          wa_aviso-ano = sy-datum(4).
*          wa_aviso-periodo = sy-datum+4(2).
*          wa_aviso-ceco = cosp_rt-objnr+6(10).
*          wa_aviso-nivel_aviso = 2. "nivel que le toca.
*          wa_aviso-fecha = sy-datum.
*          wa_aviso-hora = sy-uzeit.
*          wa_aviso-porcentajereal = porciento.
*          wa_aviso-porcentajeplan = lv_nivel2.
*
*          INSERT
*          zco_tt_avisos
*          FROM
*          wa_aviso.
*
*          IF sy-subrc = 0.
*            CLEAR wa_aviso.
*          ENDIF.
*        ENDIF.
*      ENDIF.
*    ENDIF.
*  ENDIF.
ENDFORM.


FORM EnviaCorreo3.
**  ************** SE HACE SELECT Y SE TIENE QUE HACER SELECT POR NIVEL
*  SELECT *
*    FROM zco_tt_avisos
*    INTO TABLE it_avisos
*    WHERE ceco = cosp_rt-objnr+6(10)
*    AND ano = sy-datum(4)
*    AND periodo = sy-datum+4(2)
*  AND nivel_aviso = 3.
**   Si no es igual a cero se tiene que enviar el correo
*  IF sy-subrc NE 0.
**  Query para obtener el numero de empleado del ceco
**  SELECT SINGLE name1
**    FROM csks
**    INTO lv_name1
**    WHERE KOKRS = 'GA00' " de prueba
**      AND KOSTL = cosp_rt-objnr+6(10).
*
*    SELECT SINGLE email
*      FROM zco_tt_cecoaut
*      INTO lv_correo
*      WHERE kokrs = 'SA00' " de prueba
*    AND kostl = cosp_rt-objnr+6(10).
*
*    IF sy-subrc = 0.
**
**      lv_pernr = lv_name1.
**
**      SELECT SINGLE USRID_LONG
**        FROM PA0105
**        INTO LV_CORREO
**        WHERE pernr = lv_pernr.
*
*      lv_mail = lv_correo.
*
*      IF sy-subrc = 0.
*
**    Query para sacar el correo del ceco
*
*        CLEAR: lv_porcentaje3, lv_porc3, lv_mensaje, lv_encabezado.
*        lv_porcentaje3 = lv_nivel3 * 100.
*        lv_porc3 = lv_porcentaje3.
*        CONCATENATE lv_porc3 '%' INTO lv_porc3.
*        CONCATENATE 'El centro de costos' cosp_rt-objnr+6(10) 'ha llegado al' lv_porc3 'del plan y se ha bloqueado.' INTO lv_mensaje SEPARATED BY space.
*        CONCATENATE 'CECO' cosp_rt-objnr+6(10) '[AVISO DE LIMITE DE PRESUPUESTO]' INTO lv_encabezado SEPARATED BY space.
*
**      CALL FUNCTION 'ZCFD_SEND_EMAIL_ATTACH'
*        CALL FUNCTION 'ZCFD_SEND_CORREO'
*          EXPORTING
*            correos    = lv_mail
*            body       = lv_mensaje "'aquí va el cuerpo del correo'
*            asunto     = lv_encabezado "'Aviso presupuesto'
*            mailsender = lv_correoenvia. "'mchavez@gporres.com.mx'.
*
*        " si se envio el correo
*        IF sy-subrc = 0.
*
**          wa_aviso-kokrs = 'GA00'.
*          wa_aviso-ano = sy-datum(4).
*          wa_aviso-periodo = sy-datum+4(2).
*          wa_aviso-ceco = cosp_rt-objnr+6(10).
*          wa_aviso-nivel_aviso = 3. "nivel que le toca.
*          wa_aviso-fecha = sy-datum.
*          wa_aviso-hora = sy-uzeit.
*          wa_aviso-porcentajereal = porciento.
*          wa_aviso-porcentajeplan = lv_nivel3.
*
*          INSERT
*          zco_tt_avisos
*          FROM
*          wa_aviso.
*
*          IF sy-subrc = 0.
*            CLEAR wa_aviso.
*          ENDIF.
*        ENDIF.
*      ENDIF.
*    ENDIF.
*  ENDIF.
ENDFORM.
********************************* FUNCIONES PARA ENVIAR CORREO DE ACUERDO A NIVEL ****************************** FIN
********************************* MODIFICACIONES MICHAEL 12.11.2020 FIN
