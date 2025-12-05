************************************************************************
* GRUPO PECUARIO SAN ANTONIO SA DE CV                                  *
* PROGRAMA:  ZRMM0004                                                  *
* DESCRIPCIÓN:  Stock de Almacen por centro, material, año y mes.      *
* AUTOR: María del Carmen Ocotlán Guzmán Medina                        *
* FECHA: Febrero del 2000                                              *
************************************************************************
REPORT ZRCO_TT_PLANPRES NO STANDARD PAGE HEADING LINE-SIZE 100 LINE-COUNT 65.
TABLES:
  ZCO_TT_PLANPRES.
* Parámetros de selección
SELECTION-SCREEN BEGIN OF BLOCK BLOCK1 WITH FRAME TITLE TEXT-001.
*  PARAMETERS:
*    WERKS_P LIKE MARD-WERKS OBLIGATORY.      " Centro
  SELECT-OPTIONS:
    IDPRES_P FOR ZCO_TT_PLANPRES-IDPRES,                  " Almacén
    KOKRS_P FOR  ZCO_TT_PLANPRES-KOKRS,                  " Material
    GJAHR_p for  ZCO_TT_PLANPRES-GJAHR,
    BUKRS_p for  ZCO_TT_PLANPRES-BUKRS,
    KOSTL_p for  ZCO_TT_PLANPRES-KOSTL,
    KSTAR_p for  ZCO_TT_PLANPRES-KSTAR.
SELECTION-SCREEN END OF BLOCK BLOCK1.
************************************************************************
* INICIA PROGRAMA PRINCIPAL.
************************************************************************
select * from  ZCO_TT_PLANPRES
  where IDPRES in IDPRES_P
  AND   KOKRS  in KOKRS_p                  " Material
  and   GJAHR  in GJAHR_p
  and   BUKRS  in BUKRS_p
  and   KOSTL  in KOSTL_p
  and   KSTAR  in KSTAR_p.
  if sy-subrc = 0.
    delete ZCO_TT_PLANPRES.
  endif.
  WRITE:/2 ZCO_TT_PLANPRES-IDPRES,                  " Almacén
    ' ', ZCO_TT_PLANPRES-KOKRS,                  " Material
    ' ', ZCO_TT_PLANPRES-GJAHR,
    ' ', ZCO_TT_PLANPRES-BUKRS,
    ' ', ZCO_TT_PLANPRES-KOSTL,
    ' ', ZCO_TT_PLANPRES-KSTAR,
    ' ', ZCO_TT_PLANPRES-matnr.
ENDSELECT.
