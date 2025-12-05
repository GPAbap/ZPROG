*&---------------------------------------------------------------------*
*&  Include           ZCO_COCKPIT_PRESUPUESTO_TOP01
*& 07032023
*&---------------------------------------------------------------------*

* Tabla final
TYPES: BEGIN OF st_pendientes,
  idpres TYPE char10,
  versn type versn,
  gjahr TYPE gjahr,
  cveaut TYPE char2,
  usuario TYPE uname,
  fecha TYPE datum,
  hora TYPE uzeit,
  autorizado TYPE char1,
  autorizador TYPE uname,
  fechaaut TYPE datum,
  horaaut TYPE uzeit,
  comentario TYPE char200,
  statustx TYPE char20,
  flag(1), " for selection of records
END OF st_pendientes,

BEGIN OF ty_zplanda,
  idpres TYPE char10,
  versn type versn,
  gjahr  TYPE gjahr,
  cveaut TYPE char2,
  usuario TYPE uname,
  fecha TYPE datum,
  hora TYPE uzeit,
  autorizado TYPE char1,
  autorizador TYPE uname,
  fechaaut TYPE datum,
  horaaut TYPE uzeit,
  comentario TYPE char200,
  statustx  TYPE char20,
END OF ty_zplanda,

* Tabla para procesar datos
BEGIN OF st_proceso,
  idpres TYPE char10,
  cveaut TYPE char2,
  usuario TYPE uname,
  fecha TYPE datum,
  hora TYPE uzeit,
  autorizado TYPE char1,
  autorizador TYPE uname,
  fechaaut TYPE datum,
  horaaut TYPE uzeit,
END OF st_proceso,

* Tabla para mensajes
BEGIN OF st_mensajes,
  aufnr TYPE aufk-aufnr, "order number
  msg(200), "message text
END OF st_mensajes.

* Tablas internas y work areas

*DATA: gt_zco_tt_plandati TYPE TABLE OF zco_tt_plandati,
*      wa_zco_tt_plandati LIKE LINE OF gt_zco_tt_plandati,
DATA:
      gt_zco_tt_planpres TYPE TABLE OF zco_tt_planpres,
      wa_zco_tt_planpres LIKE LINE OF gt_zco_tt_planpres,

      it_posiciones TYPE TABLE OF zco_tt_planpres,
      wa_posiciones LIKE LINE OF it_posiciones.


*      gt_historial TYPE TABLE OF zco_tt_plandatih,
*      wa_historial LIKE LINE OF gt_historial.

DATA: gt_zplanda TYPE STANDARD TABLE OF ty_zplanda,
      wa_zplanda LIKE LINE OF gt_zplanda.

* TYPE OF T_FINAL
*
DATA : it_pendientes TYPE STANDARD TABLE OF st_pendientes,
      wa_pendientes TYPE st_pendientes,

      it_arma TYPE STANDARD TABLE OF st_pendientes,
      wa_arma TYPE st_pendientes.

* TYPE OF T_PROCESS
DATA : it_proceso TYPE STANDARD TABLE OF st_proceso,
* final work area to select final records to be displayed
      wa_process TYPE st_proceso.

** Tabla de log
DATA: it_zco_tt_logpres TYPE TABLE OF zco_tt_logpres,
      wa_zco_tt_logpres LIKE LINE OF it_zco_tt_logpres.

DATA : v_rep_id TYPE sy-repid,   " report id
      v_cdate TYPE sy-datum,    " current system date
      v_line_count TYPE I,      " number of lines in final internal table
      v_line_hist TYPE I.

*&---------------------------------------------------------------------*
*          CONSTANTES
*&---------------------------------------------------------------------*


CONSTANTS : c_check(1) VALUE 'X',    " value used to set X for a field
c_langu(1) VALUE 'E',    " language used
c_ustat(4) VALUE 'TECO'. " object status description

* Declaración de cabeceras, no llevan prefijo por ser para una carga
TYPES:
BEGIN OF ty_layouts,
  INDEX TYPE VAL_INDX,
  COST_ELEM TYPE KSTAR,
  CENAME TYPE CHAR40,
  FIX_VAL_PER01	 TYPE	BAPICURR_D,
  FIX_VAL_PER02	 TYPE	BAPICURR_D,
  FIX_VAL_PER03	 TYPE	BAPICURR_D,
  FIX_VAL_PER04	 TYPE	BAPICURR_D,
  FIX_VAL_PER05	 TYPE	BAPICURR_D,
  FIX_VAL_PER06	 TYPE	BAPICURR_D,
  FIX_VAL_PER07	 TYPE	BAPICURR_D,
  FIX_VAL_PER08	 TYPE	BAPICURR_D,
  FIX_VAL_PER09	 TYPE	BAPICURR_D,
  FIX_VAL_PER10	 TYPE	BAPICURR_D,
  FIX_VAL_PER11	 TYPE	BAPICURR_D,
  FIX_VAL_PER12	 TYPE	BAPICURR_D,
END OF ty_layouts.

DATA:
      it_layouts TYPE TABLE OF ty_layouts,
      WA_LAYOUTs LIKE LINE OF IT_LAYOUTs.

************** nuevas declaraciones *************
DATA: it_collect TYPE TABLE OF ZCO_TT_PLANDATIB,
      wa_collect LIKE LINE OF it_collect.
