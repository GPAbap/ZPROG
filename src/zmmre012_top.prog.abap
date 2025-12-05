*&---------------------------------------------------------------------*
*& Include          ZMMRE012_TOP
*&---------------------------------------------------------------------*
*&----------------------------------------------------------------------------------------------*
*& Report  ZMMRE012
*& Autor: Omar Rodriguez Gamez
*& Fecha: 22.05.2012
*&----------------------------------------------------------------------------------------------*
*& Genera un reporte con las columnas de Stock Total y Consumo Total
*& ademas de las columnas resultantes Valor Stock Valorado, Consumo Diario y Cobertura en Dias
*&----------------------------------------------------------------------------------------------*
*& Modificaciones:
*& - Se modifico el Select del Join ya que tomaba mucho tiempo para procesarse, se añadio
*&   el campo periodo para mejorar la velocidad.
*&----------------------------------------------------------------------------------------------*


Tables:
  S031,
  MAKT,
  MBEW,
  MKPF,
  MSEG,
  MARD,
  bsim.

constants : c_space(01) type c value ' '.


*DATA: BEGIN OF cons_total OCCURS 0,
*      werks LIKE s031-werks, " Centro
*      matnr LIKE s031-matnr, " Material
*      basme LIKE s031-basme, " Unidad de medida
*      lgort LIKE s031-lgort, " Almacén
*      spmon LIKE s031-spmon, " Fecha contabilizacion
*      mgvbr LIKE s031-mgvbr. " Cantidad total de consumo
*DATA: END   OF cons_total.
*
*DATA: BEGIN OF cons_diario OCCURS 0,
*      matnr     LIKE s031-matnr, " Material
*      n_dias(2) type c,          " Numero de dias habiles
*      c_diario  LIKE s031-mgvbr, " Consumo diario
*      ban(1)    type c.
*DATA: END   OF cons_diario.
*
*DATA: BEGIN OF cobertura OCCURS 0,
*      matnr     LIKE s031-matnr, " Material
*      c_dias    type p.          " Cobertura en dias
*DATA: END   OF cobertura.
*
*DATA: BEGIN OF tab_final OCCURS 0,
*      matnr     LIKE s031-matnr, " Material
*      stock_t   LIKE mseg-menge, " Stock Total
*      consumo_t LIKE s031-mgvbr, " Consumo Total
*      consumo_d LIKE s031-mgvbr, " Consumo Diario
*      cober_d   type p.
*DATA: END   OF tab_final.

DATA: BEGIN OF tab_final OCCURS 0,
      werks LIKE s031-werks,     " Centro
      matnr LIKE s031-matnr,     " Material
      basme LIKE s031-basme,     " Unidad de medida
      lgort LIKE s031-lgort,     " Almacén
      spmon LIKE s031-spmon,     " Fecha contabilizacion
      endmenge(09) TYPE P DECIMALS 3,   " Stock Total
      meins LIKE MARA-MEINS,     " Unidad Medida Stock
      mgvbr LIKE s031-mgvbr,     " Cantidad total de consumo
      n_dias(2) type c,          " Numero de dias habiles
      c_diario  LIKE s031-mgvbr, " Consumo diario
      ban(1)    type c,          " Bandera evitar division por cero
      c_dias    type p,          " Cobertura en dias
      borrar(1) type c,          " Campo borrar duplicados matnr
      valor LIKE mbew-salk3.     " Valor stock valorado
DATA: END   OF tab_final.

DATA: BEGIN OF tab_final2 OCCURS 0,
      werks LIKE s031-werks,     " Centro
      matnr LIKE s031-matnr,     " Material
      maktx LIKE makt-maktx,     " Descripcion del material
      basme LIKE s031-basme,     " Unidad de medida
      lgort LIKE s031-lgort,     " Almacén
      spmon LIKE s031-spmon,     " Fecha contabilizacion
      endmenge(09) TYPE P DECIMALS 3,   " Stock Total
      meins LIKE MARA-MEINS,     " Unidad Medida Stock
      mgvbr LIKE s031-mgvbr,     " Cantidad total de consumo
      n_dias(2) type c,          " Numero de dias habiles
      c_diario  LIKE s031-mgvbr, " Consumo diario
      ban(1)    type c,          " Bandera evitar division por cero
      c_dias    type p,          " Cobertura en dias
      borrar(1) type c,          " Campo borrar duplicados matnr
      valor LIKE mbew-salk3.     " Valor stock valorado
DATA: END   OF tab_final2.




DATA: BEGIN OF IMSWEG OCCURS 1000,
        MBLNR LIKE MSEG-MBLNR,
        MJAHR LIKE MSEG-MJAHR,
        ZEILE LIKE MSEG-ZEILE,
        MATNR LIKE MSEG-MATNR,
        CHARG LIKE MSEG-CHARG,
        BWTAR LIKE MSEG-BWTAR,
        WERKS LIKE MSEG-WERKS,
        LGORT LIKE MSEG-LGORT,
        SOBKZ LIKE MSEG-SOBKZ,
        BWART LIKE MSEG-BWART,
        SHKZG LIKE MSEG-SHKZG,
        XAUTO LIKE MSEG-XAUTO,
        MENGE LIKE MSEG-MENGE,
        MEINS LIKE MSEG-MEINS,
        DMBTR LIKE MSEG-DMBTR,
        DMBUM LIKE MSEG-DMBUM,
        BUSTM LIKE MSEG-BUSTM,
        BUSTW LIKE MSEG-BUSTW.
DATA:  END OF IMSWEG.

DATA: BEGIN OF WEG_MAT OCCURS 100,
        WERKS LIKE MSEG-WERKS,
        LGORT LIKE MSEG-LGORT,
        MATNR LIKE MSEG-MATNR,
        SHKZG LIKE MSEG-SHKZG,
        MEINS LIKE MSEG-MEINS,
        MENGE(09) TYPE P DECIMALS 3.
DATA:  END OF WEG_MAT.

DATA: BEGIN OF BESTAND OCCURS 100,
        BWKEY LIKE MBEW-BWKEY,
        WERKS LIKE MSEG-WERKS,
        MATNR LIKE MSEG-MATNR,
        CHARG LIKE MSEG-CHARG,
*(DEL)  endmenge like mard-labst,          "Bestand zu 'datum-high' XJD
        ENDMENGE(09) TYPE P DECIMALS 3,    "Bestand zu 'datum-high' XJD
*(DEL)  anfmenge like mard-labst,          "Bestand zu 'datum-low'  XJD
        ANFMENGE(09) TYPE P DECIMALS 3,   "Bestand zu 'datum-low'   XJD
        MEINS LIKE MARA-MEINS,             "Mengeneinheit
*       values at date-low and date-high                    "n497992
        endwert(09)          TYPE P    DECIMALS 2,          "n497992
        anfwert(09)          TYPE P    DECIMALS 2,          "n497992

*(DEL)  soll  like mseg-menge,                                     "XJD
        SOLL(09) TYPE P DECIMALS 3,                                "XJD
*(DEL)  haben like mseg-menge,                                     "XJD
        HABEN(09) TYPE P DECIMALS 3,                               "XJD
        SOLLWERT(09)         TYPE P    DECIMALS 2,          "n497992
        HABENWERT(09)        TYPE P    DECIMALS 2,          "n497992
        WAERS LIKE T001-WAERS.             "Währungsschlüssel
DATA:   END OF BESTAND.

DATA: BEGIN OF IMARD OCCURS 100,    "aktueller Materialbestand
        WERKS LIKE MARD-WERKS,      "Werk
        MATNR LIKE MARD-MATNR,      "Material
        LGORT LIKE MARD-LGORT,      "Lagerort
        LABST LIKE MARD-LABST,      "frei verwendbarer Bestand
        UMLME LIKE MARD-UMLME,      "Umlagerungsbestand
        INSME LIKE MARD-INSME,      "Qualitätsprüfbestand
        EINME LIKE MARD-EINME,      "nicht frei verwendbarer Bestand
        SPEME LIKE MARD-SPEME,      "gesperrter Bestand
        RETME LIKE MARD-RETME,      "gesperrter Bestand
        KLABS LIKE MARD-KLABS,      "frei verw. Konsignationsbestand
        LBKUM LIKE MBEW-LBKUM,      "bewerteter Bestand
        SALK3(09)            TYPE P    DECIMALS 2,          "n497992
        WAERS LIKE T001-WAERS.      "Währungseinheit
DATA:   END OF IMARD.



Data:
      t_diario    like s031-mgvbr,
      t_cobertura type p,
      day(2)      type c,
      year(4)     type c,
      ban1(1)     type c,
      precio(08)  type p decimals 3,
      valor2      like mbew-salk3.

TYPES : BEGIN OF STYPE_MSEG_LEAN,
          MBLNR             LIKE      MKPF-MBLNR,
           MJAHR             LIKE      MKPF-MJAHR,
           VGART             LIKE      MKPF-VGART,
           BLART             LIKE      MKPF-BLART,
           BUDAT             LIKE      MKPF-BUDAT,
           CPUDT             LIKE      MKPF-CPUDT,
           CPUTM             LIKE      MKPF-CPUTM,
           USNAM             LIKE      MKPF-USNAM,
* process 'goods receipt/issue slip' as hidden field        "n450596
           XABLN             LIKE      MKPF-XABLN,          "n450596

           LBBSA             LIKE      T156M-LBBSA,
           BWAGR             LIKE      T156S-BWAGR,
           BUKRS             LIKE      T001-BUKRS,

           BELNR             LIKE      BKPF-BELNR,
           GJAHR             LIKE      BKPF-GJAHR,

           WAERS             LIKE      MSEG-WAERS,
           ZEILE             LIKE      MSEG-ZEILE,
           BWART             LIKE      MSEG-BWART,
           MATNR             LIKE      MSEG-MATNR,
           WERKS             LIKE      MSEG-WERKS,
           LGORT             LIKE      MSEG-LGORT,
           CHARG             LIKE      MSEG-CHARG,
           BWTAR             LIKE      MSEG-BWTAR,
           KZVBR             LIKE      MSEG-KZVBR,
           KZBEW             LIKE      MSEG-KZBEW,
           SOBKZ             LIKE      MSEG-SOBKZ,
           KZZUG             LIKE      MSEG-KZZUG,
           BUSTM             LIKE      MSEG-BUSTM,
           BUSTW             LIKE      MSEG-BUSTW,
           MENGU             LIKE      MSEG-MENGU,
           WERTU             LIKE      MSEG-WERTU,
           SHKZG             LIKE      MSEG-SHKZG,
           MENGE             LIKE      MSEG-MENGE,
           MEINS             LIKE      MSEG-MEINS,
           DMBTR             LIKE      MSEG-DMBTR,
           DMBUM             LIKE      MSEG-DMBUM,
           XAUTO             LIKE      MSEG-XAUTO,
           KZBWS             LIKE      MSEG-KZBWS,
*          special flag for retail                          "n497992
           retail(01)        type c,                        "n497992

* define the fields for the IO-OIL specific functions       "n599218 A
*          mseg-oiglcalc     CHAR          1                "n599218 A
*          mseg-oiglsku      QUAN         13                "n599218 A
           oiglcalc(01)      type  c,                       "n599218 A
           oiglsku(07)       type  p  decimals 3,           "n599218 A
           insmk             like      mseg-insmk,          "n599218 A

* the following fields are used for the selection of
* the reversal movements
          SMBLN    LIKE      MSEG-SMBLN,    " No. doc
          SJAHR    LIKE      MSEG-SJAHR,    " Year          "n497992
          SMBLP    LIKE      MSEG-SMBLP.    " Item in doc

TYPES : END OF STYPE_MSEG_LEAN.

TYPES: STAB_MSEG_LEAN        TYPE STANDARD TABLE OF STYPE_MSEG_LEAN
                             WITH KEY MBLNR MJAHR.

Data : BEGIN OF t_temp OCCURS 100,
          MBLNR             LIKE      MKPF-MBLNR,
           MJAHR             LIKE      MKPF-MJAHR,
           VGART             LIKE      MKPF-VGART,
           BLART             LIKE      MKPF-BLART,
           BUDAT             LIKE      MKPF-BUDAT,
           CPUDT             LIKE      MKPF-CPUDT,
           CPUTM             LIKE      MKPF-CPUTM,
           USNAM             LIKE      MKPF-USNAM,
* process 'goods receipt/issue slip' as hidden field        "n450596
           XABLN             LIKE      MKPF-XABLN,          "n450596

           LBBSA             LIKE      T156M-LBBSA,
           BWAGR             LIKE      T156S-BWAGR,
           BUKRS             LIKE      T001-BUKRS,

           BELNR             LIKE      BKPF-BELNR,
           GJAHR             LIKE      BKPF-GJAHR,

           WAERS             LIKE      MSEG-WAERS,
           ZEILE             LIKE      MSEG-ZEILE,
           BWART             LIKE      MSEG-BWART,
           MATNR             LIKE      MSEG-MATNR,
           WERKS             LIKE      MSEG-WERKS,
           LGORT             LIKE      MSEG-LGORT,
           CHARG             LIKE      MSEG-CHARG,
           BWTAR             LIKE      MSEG-BWTAR,
           KZVBR             LIKE      MSEG-KZVBR,
           KZBEW             LIKE      MSEG-KZBEW,
           SOBKZ             LIKE      MSEG-SOBKZ,
           KZZUG             LIKE      MSEG-KZZUG,
           BUSTM             LIKE      MSEG-BUSTM,
           BUSTW             LIKE      MSEG-BUSTW,
           MENGU             LIKE      MSEG-MENGU,
           WERTU             LIKE      MSEG-WERTU,
           SHKZG             LIKE      MSEG-SHKZG,
           MENGE             LIKE      MSEG-MENGE,
           MEINS             LIKE      MSEG-MEINS,
           DMBTR             LIKE      MSEG-DMBTR,
           DMBUM             LIKE      MSEG-DMBUM,
           XAUTO             LIKE      MSEG-XAUTO,
           KZBWS             LIKE      MSEG-KZBWS,
*          special flag for retail                          "n497992
           retail(01)        type c,                        "n497992

* define the fields for the IO-OIL specific functions       "n599218 A
*          mseg-oiglcalc     CHAR          1                "n599218 A
*          mseg-oiglsku      QUAN         13                "n599218 A
           oiglcalc(01)      type  c,                       "n599218 A
           oiglsku(07)       type  p  decimals 3,           "n599218 A
           insmk             like      mseg-insmk,          "n599218 A

* the following fields are used for the selection of
* the reversal movements
          SMBLN    LIKE      MSEG-SMBLN,    " No. doc
          SJAHR    LIKE      MSEG-SJAHR,    " Year          "n497992
          SMBLP    LIKE      MSEG-SMBLP.    " Item in doc

Data : END OF t_temp.




Data:
      G_T_MSEG_LEAN         TYPE STAB_MSEG_LEAN,
*      t_temp                type t_temporal, " Tabla temporal para almacenar datos de MKPF
      G_S_MSEG_LEAN         TYPE STYPE_MSEG_LEAN.

ranges : g_ra_sobkz          for mseg-sobkz.     "special st. ind.


*----------------------------------------------------------------------------
*--
*********************************************************
*Type pools
*********************************************************
type-pools: slis.
*********************************************************
*Variables globales
*********************************************************
data: xrepid like sy-repid.
*********************************************************
*Estructuras
*********************************************************
data:
  wa_fieldcat type slis_fieldcat_alv,
  t_fieldcat  type slis_t_fieldcat_alv,
  e_layout    type slis_layout_alv,
  e_print     type slis_print_alv,
  wa_heading  type slis_listheader,
  t_heading   type slis_t_listheader.
*--

*----------------------------------------------------------------------------
selection-screen begin of block menu with frame title text-001.
select-options: sl_werks for s031-werks.
select-options: sl_lgort for s031-lgort.
select-options: sl_matnr for s031-matnr.
select-options: sl_spmon for MKPF-BUDAT.
PARAMETERS:
  ejer like mkpf-mjahr.
selection-screen end of block menu.

selection-screen begin of block menu2 with frame title text-002.
PARAMETERS:
  dias(2) type c.
selection-screen end of block menu2.

selection-screen begin of block menu3 with frame title text-003.
PARAMETERS:
  matA like s031-matnr NO-DISPLAY,
  diasA(2) type c NO-DISPLAY,
  matB like s031-matnr NO-DISPLAY,
  diasB(2) type c NO-DISPLAY,
  matC like s031-matnr NO-DISPLAY,
  diasC(2) type c NO-DISPLAY,
  matD like s031-matnr NO-DISPLAY,
  diasD(2) type c NO-DISPLAY,
  matE like s031-matnr NO-DISPLAY,
  diasE(2) type c NO-DISPLAY,
  matF like s031-matnr NO-DISPLAY,
  diasF(2) type c NO-DISPLAY,
  matG like s031-matnr NO-DISPLAY,
  diasG(2) type c NO-DISPLAY,
  matH like s031-matnr NO-DISPLAY,
  diasH(2) type c NO-DISPLAY,
  matI like s031-matnr NO-DISPLAY,
  diasI(2) type c NO-DISPLAY,
  matJ like s031-matnr NO-DISPLAY,
  diasJ(2) type c NO-DISPLAY.
selection-screen end of block menu3.
