*&---------------------------------------------------------------------*
*& Include          ZMM_APP_BASC_MANUAL_TOP
*&---------------------------------------------------------------------*
TABLES:
  zmm_tt_bascm_ent,
  zturnosbascula,       "Encargado de báscula en turno
  zautorizabascula,     "Usu. Autor. para el proyecto de Básculas
  pa0002.               "Maestro de personal Info0002 (Dto.pers.)
*---*---* Declaración de tablas, variables, constantes.
DATA: BEGIN OF tab_autorizacion OCCURS 0.
**      Include structure ZAUTORIZABASCULA.
        INCLUDE STRUCTURE zuser_bascula.
DATA: END OF tab_autorizacion.
DATA:
  ok_code      LIKE sy-ucomm,
  w_numero     LIKE pa0002-pernr,
  w_nombre     LIKE pa0002-cname,
  w_fecha      LIKE sy-datum,
  w_hora       LIKE sy-uzeit,
  w_usuario    LIKE sy-uname,
  w_pedido_sap TYPE ebeln.

TYPES: BEGIN OF st_entrada_m,
         no_ticket     TYPE znnea,
         remision      TYPE zneaf,
         id_pedido     TYPE ebeln,
         pedido_sap    TYPE ebeln,
         placas        TYPE zplacas,
         operador      TYPE zoperador,
         peso_entrada  TYPE zbstmg2,
         peso_ofrecido TYPE zbstmg,
         num_pesada    TYPE znumpesada,
         tipo_doc      TYPE esart,
         fecha_ent     TYPE zdatum,
         hora_ent      TYPE zuzeit,
       END OF st_entrada_m.

TYPES: BEGIN OF st_entrada_b,
         ticket     TYPE ztick_vta,
         ticketf    TYPE ze_ticketf,
         vbeln      TYPE vbeln,
         placac     TYPE zplacac,
         pbas_ent   TYPE zntgew_ap1,
         f_proc_ent TYPE datum,
         h_proc_ent TYPE uzeit,
       END OF st_entrada_b .

DATA it_entrada_b TYPE STANDARD TABLE OF st_entrada_b.

DATA it_entrada_m TYPE STANDARD TABLE OF st_entrada_m.


DATA: twk              TYPE STANDARD TABLE OF zwk_bascula.
DATA: swk              TYPE zwk_bascula.
