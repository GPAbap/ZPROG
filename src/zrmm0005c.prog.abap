*&---------------------------------------------------------------------*
*& Report ZRMM0005C
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZRMM0005C.

INCLUDE: ZRMM0005C_DAT,
         ZRMM0005C_F01,
         ZRMM0005C_PBO,
         ZRMM0005C_PAI.


************************************************************************
* INICIA PROGRAMA PRINCIPAL.
************************************************************************
*Lee el documento de traspaso (datos básicos)
START-OF-SELECTION.
  REFRESH rec.
*Modif 18/MAyo/2016 GCS Proceti
  select * from mvke
    where matnr in matnr_p
      and vkorg in vkorg_p.
    if sy-subrc = 0 and mvke-lvorm = ' '.
        SELECT single * from mara
    where matnr = mvke-matnr.

check sy-subrc eq 0 and mara-spart in spart_p.
*Modif 18/MAyo/2016 GCS Proceti
  SELECT * FROM mard
*Modif 18/MAyo/2016 GCS Proceti
*    WHERE werks = werks_p
*    AND   lgort IN lgort_p
*    AND   matnr IN matnr_p.
    where matnr = mvke-matnr
      and werks = werks_p
      and lgort in lgort_p.
*Modif 18/MAyo/2016 GCS Proceti
*    AND   labst <> 0.
    IF sy-subrc = 0.
      MOVE-CORRESPONDING mard TO rec.
* Obtiene el Stock por Almacén
      SELECT SINGLE * FROM mbew
      WHERE bwkey = mard-werks
      AND   matnr = mard-matnr.
      MOVE-CORRESPONDING mbew TO rec.
* Obtiene Descripción del Material.
      SELECT SINGLE * FROM makt
      WHERE matnr = mard-matnr.
      IF sy-subrc = 0.
        MOVE-CORRESPONDING makt TO rec.
      ENDIF.
      APPEND rec.
    ELSE.
      WRITE:/10 'NO EXISTEN MOVIMIENTOS REGISTRADOS'.
    ENDIF.
  endselect.
*Modif 18/MAyo/2016 GCS Proceti
  endif.
  endselect.
*Modif 18/MAyo/2016 GCS Proceti
************************************************************************
* IMPRESION DEL REPORTE
************************************************************************
* Datos de Cabecera
  SELECT SINGLE * FROM t001w
  WHERE werks = werks_p.
*  INI PROCETI CJTC
  PERFORM f_obtiene_mara.

  PERFORM f_obtiene_vbfa.

  SORT rec BY lgort matnr.
  CALL SCREEN 100.
  EXIT.
* FIN PROCETI CJTC
*
*  SKIP.
*  FORMAT COLOR COL_HEADING.
*  WRITE 5 sy-datum.
*  WRITE 35 'ANALISIS DE STOCK'.
*  WRITE 88 sy-uzeit.
*  WRITE 99 ' '.
*  WRITE:/35 t001w-name1,
*        99 ' '.
*  WRITE:/35 t001w-name2,
*        99 ' '.
**format color off.
*  SKIP.
**ULINE.
*  SKIP.
**sort rec by matnr.
*  SORT rec BY lgort matnr.
*
*  LOOP AT rec.
*    AT NEW lgort.
*      SELECT SINGLE * FROM t001l
*      WHERE werks = rec-werks
*      AND   lgort = rec-lgort.
*      FORMAT COLOR COL_TOTAL.
*      WRITE:/15 t001l-lgobe,
*            99 ' '.
*      ULINE.
*      SKIP.
*      WRITE:/ 'MATERIAL',
*           15 'DESCRIPCION',
*           47 'PRECIO ACT.',
*           67 'STOCK ACT.',
*           86 'VALOR ACT.'.
**     102 'PRECIO ANT.',
**     122 'STOCK ANT.',
**     141 'VALOR ANT.'.
*      SKIP.
*      ULINE.
*      SKIP.
*    ENDAT.
*    precio = rec-salk3 / rec-lbkum.
** stock = rec-labst + rec-umlme + rec-insme.
*    stock = rec-labst.
** valor = rec-verpr * stock.
*    valor = precio * stock.
*    FORMAT COLOR COL_NORMAL.
*    WRITE:/2 rec-matnr,
*          10 rec-maktx,
**       44 rec-verpr,
*          44 precio DECIMALS 7,
*          60 stock,
*          79 valor.
**       99 rec-vmver,
**      115 rec-vmkum,
**      134 rec-vmsal.
*  ENDLOOP.
*  FORMAT COLOR 1 ON.
*  SKIP 3.
