*&---------------------------------------------------------------------*
*& Include          ZRFCHKN00_TOP
*&---------------------------------------------------------------------*
* tablas
TYPE-POOLS slis.
TABLES:
  Bsik,                      " Contabilidad: índice secundario para acre
  zfi_tt_iva,
  lfa1,                      " Maestro de Proveedores
  bseg,                      " Segmento de documento de contabilidad
  bsak,                      " Contabilidad: Índice secundario p.acreedores (part.comp.)
  bset,                      " Mary Guzmán IVA
  autha,
  bhdgd,                     "Batch-Heading
  bnka,                      "Bankdaten
  payr,                      "Scheckdatei
  rfsdo,                     "Select-Options
  t001,                      "für das Land des Buchungskreises
  t005,                      "für den Bankschlüsseltyp im Land
  t012,                      "Banken
  t012k,                     "Bankenkonten
  t042z,                     "Name des Zahlweges
  tcurx,                     "Nachkommastellen
  tvoit.                     "Grund ungültiger Scheck, Text

TYPES: BEGIN OF st_payr,
         chect TYPE chect,
         checf TYPE checf,
         vblnr TYPE vblnr,
         zaldt TYPE dzaldt,
         waers TYPE waers,
         rwbtr TYPE rwbtr,
         rzawe TYPE rzawe,
         xmanu TYPE xmanu,
         lifnr TYPE lifnr,
         name1 TYPE name1_gp,
         znme1 TYPE dznme1,
         znme2 TYPE dznme1,
         stcd1 TYPE stcd1,
         text1 TYPE text1,
         pernr TYPE p_pernr,
         voidr TYPE voidr,
         zort1 TYPE dzort1,
         zpfor TYPE pfort_z,
         zregi TYPE dzregi,
         xbanc TYPE xbanc,
         bancd TYPE bancd,
         voidd TYPE voidd,
         voidu TYPE voidu,
         voidt TYPE voidt,
         banka TYPE banka,
         ort01 TYPE ort01_gp,
         hbkid TYPE hbkid,
         hktid TYPE hktid,
         bankl TYPE bankk,
         bankn TYPE bankn,
       END OF st_payr.

DATA it_zpayr TYPE STANDARD TABLE OF st_payr.
FIELD-SYMBOLS <fs_wa> TYPE st_payr.

* rangos
RANGES:
  sel_laud  FOR payr-laufd,
  sel_laui  FOR payr-laufi,
  sel_xdat  FOR payr-extrd,
  sel_xtim  FOR payr-extrt,
  sel_echt  FOR payr-voidr.
INCLUDE rfeposc1.                      "Tabelle POSTAB für Rechnungsinfo
* Variables
DATA:
* Mary Guzmán
  sum_iva         LIKE bset-hwste,     " Variable para sumarizar IVA
  tot_iva         LIKE bset-hwste,     " Variable para totalizar IVA
  g_tot_iva       LIKE bset-hwste,     " Variable para totalizar IVA
  sum_bas         LIKE bset-hwste,     " Variable para sumarizar base iv
  tot_bas         LIKE postab-wskto,   " Totaliza Retenciones
  g_tot_bas       LIKE postab-wskto,   " Totaliza Retenciones
  suma_importe    LIKE postab-wrshb,   " Suma Importes Totales (cheques y transferencias)
  suma_base       LIKE bset-hwste,     " Suma Base Total (cheques y transferencias)
  suma_importeg   LIKE postab-wrshb,   " Suma General Transferencias
  suma_general    LIKE postab-wskto,   " Suma General (cheques y transferencias)

* Mary Gzumán
  flg_intensiv(1) TYPE n,              "1 - Color intensiv (Streifen)
  flg_posten(1)   TYPE n,              "1 - Rechnungsposten selektiert
  flg_summe(1)    TYPE n,              "1 - Summe der EPs möglich
  hlp_datum(10)   TYPE c,              "aufbereitetes Datum
* MARY GUZMAN     20030820
  hlp_subrc       LIKE sy-subrc,       "Returncode
  hlp_von_bis(27) TYPE c,              "von Nummer bis Nummer
  hlp_waers       LIKE postab-waers,   "Währung der EPs
  sum_wrshb       LIKE postab-wrshb,
  g_tot_abzug     LIKE postab-wskto,   " Mary Guzmán
  tot_abzug       LIKE postab-wskto,     " Mary Guzmán
  sum_abzug       LIKE postab-wskto,   "Summen für die Rechnungssumme
  sum_netto       LIKE postab-wrshb,
  txt_zeile(200)  TYPE c,              "Textzeile
* Tablas Internas
  BEGIN OF tab_summe OCCURS 10,        "pro Zahlweg Summe je Währung
    waers    LIKE payr-waers,
    rwbtr(9) TYPE p,
  END OF tab_summe,
  BEGIN OF tab_laufk OCCURS 1.
    INCLUDE STRUCTURE ilaufk.
DATA: END OF tab_laufk,
BEGIN OF mikline,                      "Feldleiste zur Aufnahem des
  zbukr LIKE payr-zbukr,               "variablen Teils der Mikro-Fiche-
  hbkid LIKE payr-hbkid,               "Zeile
  hktid LIKE payr-hktid,
  rzawe LIKE payr-rzawe,
  checf LIKE payr-checf,
END OF mikline.
FIELD-GROUPS:
  header,
  zahlung,
  rechnung.
INSERT
  payr-hbkid
  payr-hktid
  payr-xmanu
  payr-rzawe
  payr-chect
  postab-bukrs
  postab-gjahr
  postab-belnr
INTO header.
INSERT
  payr
INTO zahlung.
INSERT
  postab
INTO rechnung.
*****************FOR ALV

DATA: gt_fieldcat TYPE slis_t_fieldcat_alv,
      wa_fieldcat TYPE slis_fieldcat_alv,
      gl_layout   TYPE slis_layout_alv,
      gt_sort     TYPE slis_sortinfo_alv.

**HEADER
DATA:
  gt_header     TYPE slis_t_listheader,
  wa_header     TYPE slis_listheader,
  t_line        LIKE wa_header-info,
  ld_lines      TYPE i,
  ld_linesc(10) TYPE c.

* Especificaciones de Entrada
************************************************************************
*---------------------------------------------------------------------*
* Deklarationsteil                                                    *
* Sección de  declaración                                             *
*---------------------------------------------------------------------*
*---------------------------------------------------------------------*
* Selektionsparameter                                                 *
* Selección de Parámetros                                             *
*---------------------------------------------------------------------*

PARAMETERS:
  par_zbuk LIKE payr-zbukr MEMORY ID buk. "Sociedad Pagadora

SELECT-OPTIONS:
  sel_hbki FOR payr-hbkid.             "Banco Propio

PARAMETERS p_gjahr LIKE bseg-gjahr NO-DISPLAY.   "Ejercicio

SELECT-OPTIONS  sel_zald FOR rfsdo-chkladat. " Fecha de Emisión

SELECTION-SCREEN SKIP.
