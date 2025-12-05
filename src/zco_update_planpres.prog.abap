*&---------------------------------------------------------------------*
*& Report ZCO_UPDATE_PLANPRES
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZCO_UPDATE_PLANPRES.
DATA: ZGPRF TYPE LGORT_D,
      ZAZRF TYPE LGORT_D.

ZGPRF = 'GPRF'.
ZAZRF = 'AZRF'.

update zco_tt_planpres set lgort = ZGPRF
WHERE KOKRS = 'SA00' and tipo = 'MATERIAL'.

IF sy-subrc eq 0.
  WRITE:/ 'actualizado SA00'.
ELSE.
  WRITE:/ 'NO actualizado SA00'.
ENDIF.
update zco_tt_planpres set lgort = ZAZRF
WHERE KOKRS = 'GA00' and tipo = 'MATERIAL'.

IF sy-subrc eq 0.
  WRITE:/ 'actualizado GA00'.
ELSE.
  WRITE:/ 'NO actualizado GA00'.
ENDIF.
