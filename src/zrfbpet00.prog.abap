*&---------------------------------------------------------------------*
*& Report ZRFBPET00
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZRFBPET00 NO STANDARD PAGE HEADING
LINE-SIZE  132
*      LINE-COUNT 65(0)
MESSAGE-ID fr.

TABLES: b0sg, bkpf, bseg, bsega,bsegh, bsec, bsed, bhdgd, t001.

* Mary Guzmán 20100111
DATA:
      total LIKE bsega-dmshb.
DATA: zeit(15) TYPE C.                                      "N87422
* Dataset
DATA: BEGIN OF bl,
*     D     LIKE BKDF,                 "Dauerbuchungsinformationen
  k     LIKE bkpf,                 "Belegkopf    "
  p     LIKE bseg,                 "Beleg        "
  C     LIKE bsec,                 "CPD          "
  w     LIKE bsed,                 "Wechsel      "
*     S     LIKE BSET,                 "Steuer       "
END   OF bl.
* Flags
DATA: tbk-flag(1) TYPE C VALUE ' ',    "1 - Buchungskreis tracen
      tbl-flag(1) TYPE C VALUE ' ',    "1 - Belegnummer tracen
      sw-ULINE(1) TYPE C VALUE '0'.    "verhindert doppelte Linienausg.
* Workfields
DATA: BEGIN OF mif1,
  bukrs    LIKE bkpf-bukrs,
  belnr    LIKE bkpf-belnr,
  buzei(3) TYPE C,
END   OF mif1.
DATA: wfxblnr  LIKE bkpf-xblnr VALUE 'GRUNDWERT       ',
      wf-xumsw    LIKE bseg-xumsw,
      wf-umsatzkz LIKE bseg-umskz,
      wf-bukrs LIKE bkpf-bukrs,
      wf-belnr LIKE bkpf-belnr,
      kontonr(10) TYPE C,
      alt_bukrs LIKE bkpf-bukrs,
      ds_nam(50) TYPE C.
DATA: zfdpos LIKE sy-fdpos.                                 "<-- 3.0F
SELECT-OPTIONS: bmonate     FOR  bkpf-monat.     "Buchungsperiode Monate
PARAMETERS:     extrakt     LIKE  rfpdo-bpetextr
DEFAULT ' ',      "Extrakt gewuenscht
ds_name     LIKE  rfpdo-bpetdsna,   "Dataset-Name
SORT        LIKE  rfpdo-bpetsort,   "Beleg-Sortierung
protokol    LIKE  rfpdo-bpetprot
DEFAULT 'X',      "Protokoll gewuensch
daus        LIKE  rfpdo-bpetdaus
DEFAULT 'X'.      "Debitorenteil
SELECT-OPTIONS: dkonto      FOR   bseg-kunnr.       "Debitorenkonto
PARAMETERS:     kaus        LIKE  rfpdo-bpetkaus
DEFAULT 'X'.      "Kreditorenteil
SELECT-OPTIONS: kkonto      FOR   bseg-lifnr.       "Kreditorenkonto
PARAMETERS:     saus        LIKE  rfpdo-bpetsaus
DEFAULT 'X'.      "Sachkontenteil
SELECT-OPTIONS: skonto      FOR   bseg-hkont.       "Kreditorenkonto
PARAMETERS:     aaus        LIKE  rfpdo-bpetaaus
DEFAULT 'X'.      "Anlagenteil
SELECT-OPTIONS: anlage      FOR   bseg-anln1.       "Anlagenkonto
PARAMETERS:     maus        LIKE  rfpdo-bpetmaus
DEFAULT 'X'.      "Materialteil
SELECT-OPTIONS: artnum      FOR   bseg-matnr.       "Artikelnummer

PARAMETERS:     n_belege    LIKE  rfpdo-bpetnbel
DEFAULT 'X',      "Normale Belege.
stat_buc    LIKE  rfpdo-bpetsbel.   "Statistische Belege
SELECT-OPTIONS: tbukrs      FOR  bkpf-bukrs.        "Buchungskreis
SELECT-OPTIONS: tbelnr      FOR  bkpf-belnr.        "Belegnummer
SELECT-OPTIONS: blgdatum    FOR  bkpf-bldat,        "Belegdatum
cpudatum    FOR  bkpf-cpudt,        "CPU-Datum
bu_datum    FOR  bkpf-budat,        "Buchungsdatum
benutzer    FOR  bkpf-usnam,        "Erfasser
waehrung    FOR  bkpf-waers,        "Waehrung
*               REFERENZ    FOR  BKPF-XBLNR,     "Referenzangabe
bktext      FOR  bkpf-bktxt(20),    "Belegkopftext
aenddat     FOR  bkpf-upddt,        "Datum letzte Aender
wertstel    FOR  bkpf-wwert,        "Datum Wertstellung
kursvor     FOR  bkpf-kursf,        "Kursvorgabe
gesber      FOR  bseg-gsber,        "Geschaeftsbereich
mitkont     FOR  bseg-hkont,        "Mitbuchkonto
*               MAHNSCHL    FOR  BSEG-MSCHL,        "Mahnschluessel
*               ZAHLSCHL    FOR  BSEG-ZLSCH,        "Zahlungsschluessel
buschl      FOR  bseg-bschl,        "Buchungsschluessel
zuordnr     FOR  bseg-zuonr,        "Zuordnungsnummer
bewegart    FOR  bseg-anbwa,        "Bewegungsart
kostenst    FOR  bseg-kostl,        "Kostenstelle
werk        FOR  bseg-werks.        "Werk
*PARAMETERS:     TITLE(40)   TYPE C LOWER CASE,   "Kommentar
PARAMETERS:     TITLE       LIKE rfpdo1-allgline,
listsep     LIKE rfpdo-allglsep, "keine Listseparation
mikfiche    LIKE rfpdo-allgmikf. "Microfische
FIELD-GROUPS: HEADER,
dates.
INSERT
bkpf-bukrs
bkpf-belnr
bseg-buzei
INTO HEADER.
INSERT
bl
bkpf-xblnr
bkpf-budat
bkpf-monat
bkpf-gjahr
bkpf-blart
bkpf-bldat
bkpf-cpudt
bkpf-usnam
bseg-bschl
bseg-koart
kontonr
bseg-umskz
bseg-xumsw
bkpf-waers
bseg-wrbtr
bsega-dmshb
bkpf-kursf
INTO dates.
***********************************************************************
*  Konvertierung wenn Selektion auf eine Kontonummer gewünscht ist    *
***********************************************************************
AT SELECTION-SCREEN ON dkonto.
*    Konvertierung der Debitorenkontonummer
*    --------------------------------------
LOOP AT dkonto.
  PERFORM alphaformat(sapfs000)
  USING dkonto-low dkonto-low.
  PERFORM alphaformat(sapfs000)
  USING dkonto-high dkonto-high.
  MODIFY dkonto.
ENDLOOP.
AT SELECTION-SCREEN ON kkonto.
*    Konvertierung der Kreditorenkontonummer
*    --------------------------------------
LOOP AT kkonto.
  PERFORM alphaformat(sapfs000)
  USING kkonto-low kkonto-low.
  PERFORM alphaformat(sapfs000)
  USING kkonto-high kkonto-high.
  MODIFY kkonto.
ENDLOOP.
AT SELECTION-SCREEN ON skonto.
*    Konvertierung der Sachkontonummer
*    ---------------------------------
LOOP AT skonto.
  PERFORM alphaformat(sapfs000)
  USING skonto-low skonto-low.
  PERFORM alphaformat(sapfs000)
  USING skonto-high skonto-high.
  MODIFY skonto.
ENDLOOP.
AT SELECTION-SCREEN ON anlage.
*    Konvertierung der Anlagenummer
*    ------------------------------
LOOP AT anlage.
  PERFORM alphaformat(sapfs000)
  USING anlage-low anlage-low.
  PERFORM alphaformat(sapfs000)
  USING anlage-high anlage-high.
  MODIFY anlage.
ENDLOOP.
AT SELECTION-SCREEN ON artnum.
*    Konvertierung der Artikelnummer
*    -------------------------------
LOOP AT artnum.
  PERFORM alphaformat(sapfs000)
  USING artnum-low artnum-low.
  PERFORM alphaformat(sapfs000)
  USING artnum-high artnum-high.
  MODIFY artnum.
ENDLOOP.
AT SELECTION-SCREEN ON mitkont.
*    Konvertierung des Mitbuchkontos
*    -------------------------------
LOOP AT mitkont.
  PERFORM alphaformat(sapfs000)
  USING mitkont-low mitkont-low.
  PERFORM alphaformat(sapfs000)
  USING mitkont-high mitkont-high.
  MODIFY mitkont.
ENDLOOP.
AT SELECTION-SCREEN.
PERFORM check_path_dsname.
******************************************************************
START-OF-SELECTION.
* Lesen von normalen Belegen.
IF n_belege EQ space.
  b0sg-xstan = ' '.
ENDIF.
* Lesen von statistischen Belegen.
IF stat_buc <> space.
  b0sg-xstas = 'X'.
ENDIF.
* Init. Alt_Bukrs, damit beim 1. GET BKPF Tabelle 001 gelesen wird.
alt_bukrs = space.
MOVE:
'    '      TO bhdgd-bukrs,
sy-linsz    TO bhdgd-LINES,
sy-uname    TO bhdgd-uname,
sy-repid    TO bhdgd-repid,
sy-TITLE    TO bhdgd-line1,
TITLE       TO bhdgd-line2,
mikfiche    TO bhdgd-miffl,
'0'         TO bhdgd-inifl,
'GRUNDWERT' TO wfxblnr,
listsep     TO bhdgd-separ,
'BUKRS'     TO bhdgd-domai.
IF extrakt    NE space. MOVE 'X' TO extrakt.    ENDIF.
IF SORT       NE space. MOVE 'X' TO SORT.       ENDIF.
IF protokol   NE space. MOVE 'X' TO protokol.   ENDIF.
IF saus       NE space. MOVE 'X' TO saus.       ENDIF.
IF aaus       NE space. MOVE 'X' TO aaus.       ENDIF.
IF maus       NE space. MOVE 'X' TO maus.       ENDIF.
IF daus       NE space. MOVE 'X' TO daus.       ENDIF.
IF kaus       NE space. MOVE 'X' TO kaus.       ENDIF.
* Komplettierung Dateipfad zur endgültigen Aufbereitung
IF extrakt EQ 'X'.
  ds_nam = ds_name.
  DESCRIBE FIELD ds_nam.
*       WRITE SY-REPID      TO DS_NAM+SY-FDPOS.
*       SY-FDPOS = SY-FDPOS + 8.
*       WRITE '_'           TO DS_NAM+SY-FDPOS.
*       SY-FDPOS = SY-FDPOS + 1.
*       WRITE SY-UZEIT TO DS_NAM+SY-FDPOS.
  WRITE sy-repid      TO ds_nam+zfdpos.                   "<--3.0F
  zfdpos = zfdpos + 8.                                    "<--3.0F
  WRITE '_'           TO ds_nam+zfdpos.                   "<--3.0F
  zfdpos = zfdpos + 1.                                    "<--3.0F
*       write sy-uzeit to ds_nam+zfdpos.              "<--3.0F
  WRITE sy-uzeit TO zeit.                                 "N87422
  TRANSLATE zeit USING ':_'.                              "N87422
  WRITE zeit TO ds_nam+zfdpos.                            "N87422
ENDIF.
* * * * * * * * *
GET bkpf.
CHECK SELECT-OPTIONS.
* T001 lesen fuer Waehrungschluessel
IF alt_bukrs NE bkpf-bukrs AND SORT EQ space.
  CLEAR t001.
  t001-bukrs = bkpf-bukrs.
  READ TABLE t001.
  alt_bukrs = bkpf-bukrs.
ENDIF.
bl-k = bkpf.
IF SORT = space AND protokol = 'X'.
  bhdgd-grpin = mif1.
* Cabecera
  PERFORM ausgabe-beleg-kopf.
ENDIF.
* * * * * * *  *
GET bseg.
* CHECKs abhaengig von der Kontoart
CASE bseg-koart.
WHEN 'D'.
  CHECK daus EQ 'X'.
  CHECK dkonto.           "Debitorenkonto
  IF bseg-umskz = space.  "Kein Sonderhauptbuchvorgang
    CHECK mitkont.
  ELSE.                   "Sonderhauptbuchvorgang
    kontonr = bseg-hkont.
    bseg-hkont = bseg-saknr.
    CHECK mitkont.
    bseg-hkont = kontonr.
  ENDIF.
  kontonr = bseg-kunnr.
WHEN 'K'.
  CHECK kaus EQ 'X'.
  CHECK kkonto.                     "KREDITORENKONTO
  IF bseg-umskz = space.            "Kein Sonderhauptbuchvorgang
    CHECK mitkont.
  ELSE.                             "Sonderhauptbuchvorgang
    kontonr = bseg-hkont.
    bseg-hkont = bseg-saknr.
    CHECK mitkont.
    bseg-hkont = kontonr.
  ENDIF.
  kontonr = bseg-lifnr.
WHEN 'S'.
  CHECK saus EQ 'X'.
  CHECK skonto.                                 "SACHKONTO
  CHECK bseg-buzei NE 0.
  kontonr = bseg-hkont.
WHEN 'A'.
  CHECK aaus EQ 'X'.
  CHECK: anlage.
  CHECK bseg-buzei NE 0.
  kontonr = bseg-hkont.
WHEN 'M'.
  CHECK maus EQ 'X'.
  CHECK: artnum.
  CHECK bseg-buzei NE 0.
  kontonr = bseg-hkont.
WHEN OTHERS.
  REJECT.
ENDCASE.    "BP-KOART
CHECK:
gesber,                       "GESCHAEFTSBEREICH
buschl,                       "BUCHUNGSSCHLUESSEL
zuordnr,                      "ZUORDNUNGSNUMMER
bewegart,                     "Bewegungsart
kostenst,                     "Kostenstelle
werk.                         "Werk
WRITE bseg-buzei TO mif1-buzei.
bl-p = bseg.
IF bseg-xcpdd NE space.
  bl-C = bsec.
ENDIF.
IF bseg-umsks NE space.
  bl-w = bsed.
ENDIF.
CASE SORT.
WHEN 'X'.
  EXTRACT dates.
WHEN OTHERS.
  CASE protokol.
  WHEN 'X'.
    bhdgd-grpin = mif1.
* Imprime detalle
    PERFORM ausgabe-beleg-POSITION.
  ENDCASE.
  CASE extrakt.
  WHEN 'X'.
    TRANSFER bl TO ds_nam.
  ENDCASE.
ENDCASE.
GET bkpf LATE.
IF protokol EQ 'X' AND SORT EQ space.
  MOVE '1' TO sw-ULINE.
  ULINE.
  MOVE '0' TO sw-ULINE.
ENDIF.
END-OF-SELECTION.
PERFORM totales.
***********************************************************************
CASE SORT.
WHEN 'X'.
  SORT.
  LOOP.
*---------------------------------------------------------------------*
    MOVE bl-k TO bkpf.
    MOVE bl-p TO bseg.
    MOVE bl-C TO bsec.
*Dauerbuchungsdaten!!!!!!!!!!!!!
*       MOVE BL-D TO BKDF.
*Wechseldaten     !!!!!!!!!!!!!
    MOVE bl-w TO bsed.
    AT NEW bkpf-bukrs.
      bhdgd-bukrs = bkpf-bukrs.
      mif1-bukrs  = bkpf-bukrs.
      MOVE bhdgd-bukrs TO bhdgd-werte.
      PERFORM NEW-SECTION(rsbtchh0).
*         Lesen Waehrung
      CLEAR t001.
      t001-bukrs = bkpf-bukrs.
      READ TABLE t001.
    ENDAT.
*---------------------------------------------------------------------*
    AT NEW bkpf-belnr.
      mif1-belnr  = bkpf-belnr.
      IF protokol  NE space.
        RESERVE 5 LINES.
        PERFORM ausgabe-beleg-kopf.
      ENDIF.
    ENDAT.
*---------------------------------------------------------------------*
    AT NEW bseg-buzei.
      WRITE bseg-buzei TO mif1-buzei.
      bhdgd-grpin = mif1.
      IF protokol  NE space.
* Imprime detalle
        PERFORM ausgabe-beleg-POSITION.
      ENDIF.
    ENDAT.
*---------------------------------------------------------------------*
    AT dates.
      CASE extrakt.
      WHEN 'X'.
        TRANSFER bl TO ds_nam.
      ENDCASE.
    ENDAT.
*---------------------------------------------------------------------*
    AT END OF bkpf-belnr.
      IF protokol EQ 'X'.
        MOVE '1' TO sw-ULINE.
        ULINE.
        MOVE '0' TO sw-ULINE.
      ENDIF.
    ENDAT.
* Ausgabe dateiname.
    AT LAST.
      IF extrakt EQ 'X'.
        IF protokol EQ 'X'.
          SKIP.
          WRITE: TEXT-104, space, ds_nam.
        ELSE.
          MESSAGE s128 WITH ds_nam.
        ENDIF.
      ENDIF.
    ENDAT.
*---------------------------------------------------------------------*

*---------------------------------------------------------------------*
  ENDLOOP.
ENDCASE.
* Ausgabe Dateiname.
IF SORT NE 'X'.
  IF extrakt EQ 'X'.
    IF protokol EQ 'X'.
      SKIP.
      WRITE: TEXT-104, space, ds_nam.
    ELSE.
      MESSAGE s128 WITH ds_nam.
    ENDIF.
  ENDIF.
ENDIF.
* Seitenanfangsverarbeitung
* IMPRESIÓN **********************************************************
TOP-OF-PAGE.
MOVE 'GRUNDWERT' TO wfxblnr.
PERFORM batch-heading(rsbtchh0).
ULINE.
IF t001-bukrs NE bkpf-bukrs.
  t001-bukrs = bkpf-bukrs.
  READ TABLE t001.
ENDIF.
WRITE /1    TEXT-100.
DETAIL.
WRITE /1    TEXT-101.
SUMMARY.
IF sw-ULINE = '0'.
  ULINE.
ENDIF.
* Subrutinas **********************************************************
*---------------------------------------------------------------------*
* Pruefen Buchungskreis-Debugging                                     *
*---------------------------------------------------------------------*
FORM tbukrs-CHECK.
  tbk-flag = '0'.
*  CHECK TBUKRS.
  CHECK wf-bukrs IN tbukrs.
  tbk-flag = '1'.
ENDFORM.                    "TBUKRS-CHECK

*---------------------------------------------------------------------*
* Pruefen Belegnummer-Debugging                                       *
*---------------------------------------------------------------------*
FORM tbelnr-CHECK.
  tbl-flag = '0'.
*  CHECK TBELNR.
  CHECK wf-belnr IN tbelnr.
  tbl-flag = '1'.
ENDFORM.                    "TBELNR-CHECK

*---------------------------------------------------------------------*
* Ausgabe eines Protokollsatzes                                       *
* Cabecera                                                            *
*---------------------------------------------------------------------*
FORM ausgabe-beleg-kopf.
  WRITE: /1 bkpf-bukrs,
  bkpf-belnr,
  bkpf-blart,
  bkpf-budat,
  31 bkpf-monat,
  33 bkpf-gjahr+2(2),                            "#EC NO_M_RISC1
  bkpf-bldat,
  bkpf-cpudt,
  bkpf-usnam,
  bkpf-xblnr.
ENDFORM.                    "AUSGABE-BELEG-KOPF

*&---------------------------------------------------------------------*
*&      Form  AUSGABE-BELEG-POSITION
*&---------------------------------------------------------------------*
*       Detalle                                                        *
*----------------------------------------------------------------------*
FORM ausgabe-beleg-POSITION.
  IF bseg-xumsw = 'X'.
    wf-xumsw    = 'X'.                             "Umsatzwirksam
    wf-umsatzkz = space.
  ELSE.
    IF bseg-umskz <> space.
      wf-xumsw    = space.                        "Sonderumsatz
      wf-umsatzkz = bseg-umskz.
    ELSE.
      wf-xumsw    = space.                        "Nicht Umsatzwirksam
      wf-umsatzkz = space.
    ENDIF.
  ENDIF.
  DETAIL.
  WRITE: /6 bseg-gsber,
  bseg-buzei,
  bseg-bschl,
  wf-umsatzkz,
  22 bseg-mwskz,
  26 bseg-zterm,
  31 bseg-koart,
  35 kontonr,
  bseg-shkzg,
*           BSEG-DMBTR NO-ZERO CURRENCY T001-WAERS,
  bsega-dmshb NO-ZERO CURRENCY t001-waers,
  t001-waers.
  IF bseg-koart = 'K'.
    total = total + bsega-dmshb.
  ENDIF.
  IF bkpf-kursf NE 0.
    WRITE: bseg-wrbtr NO-ZERO CURRENCY bkpf-waers,
    bkpf-waers.
  ENDIF.

  IF bkpf-bstat EQ 'D'.
    IF bseg-mwsts <> 0.
      PERFORM ausgabe_steuern.
    ENDIF.
  ENDIF.
  IF bseg-xcpdd NE space.      "CPD-Daten
    SUMMARY.
    WRITE: /11 TEXT-004, bsec-name1,
    TEXT-005, bsec-ort01.
    DETAIL.
  ENDIF.
  SUMMARY.
ENDFORM.                    "AUSGABE-BELEG-POSITION

*&---------------------------------------------------------------------*
*&      Form  AUSGABE_STEUERN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM ausgabe_steuern.
* Fuer Dauerbuchungsurbelege wird keine automatische Buchungszeile fuer
* den Steuerbetrag abgelegt. Die Routine gibt den Steuerbetrag für die
* Sachkontenzeile aus.
  CHECK bseg-koart EQ 'S'.
  WRITE: / TEXT-103 UNDER bseg-buzei,
  46 bseg-shkzg.
  IF bseg-shkzg EQ 'H'.
    bseg-mwsts = bseg-mwsts * -1.
  ENDIF.
  WRITE:   bseg-mwsts CURRENCY t001-waers UNDER bsega-dmshb,
  t001-waers UNDER t001-waers.
  IF bkpf-kursf NE 0.
    WRITE: bseg-wmwst CURRENCY bkpf-waers UNDER bseg-wrbtr,
    bkpf-waers UNDER bkpf-waers.
  ENDIF.
ENDFORM.                    "AUSGABE_STEUERN

*&---------------------------------------------------------------------*
*&      Form  CHECK_PATH_DSNAME
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM check_path_dsname.
*---------------------------------------------------------------------*
*       FORM CHECK_PATH_DSNAME                                        *
*---------------------------------------------------------------------*
*       Die Reorganisationdirectory wird verprobt                     *
*---------------------------------------------------------------------*
  FIELD-SYMBOLS: <f>.
  IF extrakt EQ 'X'.    "X - Extrakt gewünscht.
    IF ds_name IS INITIAL.
      SET CURSOR FIELD 'DS_NAME'.
      MESSAGE e126.
      EXIT.
    ENDIF.
*
*
* Ein kleiner UNIX-Service: '/' wird angehängt, falls nicht eingegeben
*
    IF ds_name CA ' '.
      zfdpos = sy-fdpos.                                    "<--40B
      CASE sy-opsys.
      WHEN 'HP-UX' OR 'SunOS'.
        SET CURSOR FIELD 'DS_NAME'.
        DATA: fdpos LIKE sy-fdpos.
        DATA: rfile(50)      TYPE C.        "Reorganisationsdateiname
        fdpos = sy-fdpos - 1.
        ASSIGN ds_name+fdpos(1) TO <f>.
        IF <f> NE '/'.
          ASSIGN ds_name+sy-fdpos(1) TO <f>.
          <f> = '/'.
          zfdpos = sy-fdpos + 1.                          "<--40B
        ELSE.                                             "<--40B
          zfdpos = sy-fdpos.                              "<--40B
        ENDIF.
      ENDCASE.
    ELSE.                                                   "<--40B
      zfdpos = 30.                                          "<--40B
    ENDIF.
*
* Ein temporäres File wird aufgebaut und getestet
*
    rfile = ds_name.
    IF rfile CA ' '.
      ASSIGN rfile+sy-fdpos(3) TO <f>.
      <f> = 'tmp'.
    ENDIF.
*
    OPEN DATASET rfile FOR OUTPUT IN BINARY MODE.
    IF sy-subrc NE 0.
*
* Dateipfad existiert nicht
*
      SET CURSOR FIELD 'DS_NAME'.
      MESSAGE e127.
    ENDIF.
    CLOSE DATASET rfile.
  ELSE.
    MOVE space TO ds_name.
  ENDIF.
ENDFORM.                    "CHECK_PATH_DSNAME
*&---------------------------------------------------------------------*
*&      Form  TOTALES
*&---------------------------------------------------------------------*
*   Imprime Totales
*----------------------------------------------------------------------*

FORM TOTALES .
  WRITE: 48 total.
  CLEAR total.
ENDFORM.                    " TOTALES
