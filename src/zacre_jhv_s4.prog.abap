*&---------------------------------------------------------------------*
*& Report zacre_jhv_s4
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zacre_jhv_s4.
tabLES lfa1.

TYPES: BEGIN OF ty_resumen,
         lifnr         TYPE lifnr,
         name1         TYPE lfa1-name1,
         importe       TYPE bsik-dmbtr,
         primera_fecha TYPE bsik-budat,
         dolares_usd   TYPE bsik-wrbtr,
         dolares_usdn  TYPE bsik-wrbtr,
         dolares       TYPE bsik-wrbtr,
       END OF ty_resumen.

TYPES: BEGIN OF ty_detalle,
         lifnr TYPE lifnr,
         belnr TYPE belnr_d,
         budat TYPE budat,
         dmbtr TYPE dmbtr,
         shkzg TYPE shkzg,
         sgtxt TYPE sgtxt,
         waers TYPE waers,
         blart TYPE blart,
         bschl TYPE bschl,
       END OF ty_detalle.

DATA: gt_resumen TYPE STANDARD TABLE OF ty_resumen,
      gt_detalle TYPE STANDARD TABLE OF ty_detalle.

SELECT-OPTIONS s_lifnr FOR lfa1-lifnr.
PARAMETERS: p_bukrs TYPE bukrs OBLIGATORY,
            p_ktokk TYPE lfa1-ktokk,
            p_antic AS CHECKBOX.

START-OF-SELECTION.

  IF s_lifnr[] IS NOT INITIAL.
    PERFORM get_by_vendor.
  ELSE.
    PERFORM get_by_vendor_group.
  ENDIF.

  PERFORM show_alv.

FORM get_by_vendor.

  SELECT
      b~lifnr,
      l~name1,
      SUM(
        CASE b~shkzg
          WHEN 'S' THEN b~dmbtr
          ELSE - b~dmbtr
        END
      ) AS importe,
      MIN( b~budat ) AS primera_fecha,
      SUM(
  CASE
    WHEN b~waers = 'USD'
      THEN b~wrbtr
    ELSE 0
  END
) AS dolares_usd,

SUM(
  CASE
    WHEN b~waers = 'USDN'
      THEN b~wrbtr
    ELSE 0
  END
) AS dolares_usdn
    FROM bsik AS b
    INNER JOIN lfa1 AS l
      ON l~lifnr = b~lifnr
    WHERE b~bukrs = @p_bukrs
      AND b~lifnr IN @s_lifnr
      AND (
           ( @p_antic = 'X' AND b~umskz <> '' AND b~umskz <> 'F' )
        OR ( @p_antic = ''  AND b~umskz =  '' )
      )
    GROUP BY b~lifnr, l~name1
    HAVING SUM(
        CASE b~shkzg
          WHEN 'S' THEN b~dmbtr
          ELSE - b~dmbtr
        END
      ) <> 0
    INTO TABLE @gt_resumen.

ENDFORM.

FORM get_by_vendor_group.

  SELECT
      b~lifnr,
      l~name1,
      SUM(
        CASE b~shkzg
          WHEN 'S' THEN b~dmbtr
          ELSE - b~dmbtr
        END
      ) AS importe,
      MIN( b~budat ) AS primera_fecha,
      SUM(
        CASE
          WHEN b~waers = 'USD' OR b~waers = 'USDN'
          THEN b~wrbtr
          ELSE 0
        END
      ) AS dolares
    FROM lfa1 AS l
    INNER JOIN bsik AS b
      ON b~lifnr = l~lifnr
    WHERE b~bukrs = @p_bukrs
      AND l~ktokk = @p_ktokk
    GROUP BY b~lifnr, l~name1
    HAVING SUM(
        CASE b~shkzg
          WHEN 'S' THEN b~dmbtr
          ELSE - b~dmbtr
        END
      ) <> 0
    INTO TABLE @gt_resumen.

LOOP AT gt_resumen ASSIGNING FIELD-SYMBOL(<ls_resumen>).
  <ls_resumen>-dolares = <ls_resumen>-dolares_usd
                       + ( <ls_resumen>-dolares_usdn / 1000 ).
ENDLOOP.



ENDFORM.

FORM show_alv.

  DATA lo_alv TYPE REF TO cl_salv_table.

  IF gt_resumen IS INITIAL.
    MESSAGE 'No se encontraron partidas abiertas' TYPE 'S'.
    RETURN.
  ENDIF.

  cl_salv_table=>factory(
    IMPORTING
      r_salv_table = lo_alv
    CHANGING
      t_table      = gt_resumen ).

  lo_alv->get_functions( )->set_all( abap_true ).
  lo_alv->get_columns( )->set_optimize( abap_true ).
  lo_alv->display( ).

ENDFORM.
