*&---------------------------------------------------------------------*
*& Include          ZRFCHKN00_FUN
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form get_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_data .
  SELECT payr~chect, payr~checf, payr~vblnr, payr~zaldt,payr~waers, abs( payr~rwbtr ) AS rwbtr, payr~rzawe,
          payr~xmanu, lfa1~lifnr,lfa1~name1, payr~znme1, payr~znme2,
          CASE WHEN lfa1~stcd1 IS INITIAL THEN lfa1~stcd3 ELSE lfa1~stcd1 END AS stcd1 , t042z~text1,
          payr~pernr, payr~voidr, payr~zort1, payr~zpfor, payr~zregi,
          payr~xbanc, payr~bancd, payr~voidd, payr~voidu, tvoit~voidt,
          bnka~banka, bnka~ort01, payr~hbkid, payr~hktid,t012~bankl, t012k~bankn

      FROM payr
      INNER JOIN t012 ON t012~bukrs = payr~zbukr AND t012~hbkid EQ payr~hbkid
      INNER JOIN t012k ON t012k~bukrs = payr~zbukr AND t012k~hbkid EQ payr~hbkid
                          AND t012k~hktid EQ payr~hktid
      INNER JOIN bnka ON bnka~banks EQ t012~banks  AND bnka~bankl EQ t012~bankl
      INNER JOIN t001 ON t001~bukrs EQ payr~zbukr
      INNER JOIN t042z ON t042z~land1 EQ t001~land1  AND t042z~zlsch EQ payr~rzawe
      LEFT JOIN lfa1 ON lfa1~lifnr EQ payr~lifnr
      LEFT JOIN tvoit ON tvoit~voidr EQ payr~voidr AND tvoit~langu EQ @sy-langu
      WHERE   ichec EQ @space
        AND   zbukr EQ @par_zbuk
        AND   payr~hbkid IN @sel_hbki
        AND   zaldt IN @sel_zald
      INTO TABLE @it_zpayr
     .

  SORT it_zpayr BY chect.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form process_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM process_data .
  DATA vl_cadena TYPE string.

  LOOP AT it_zpayr ASSIGNING <fs_wa>.

    IF <fs_wa>-xmanu EQ space AND <fs_wa>-rzawe EQ space.
      <fs_wa>-text1 = TEXT-010.
    ELSE.
      <fs_wa>-text1 = TEXT-011.
    ENDIF.

    IF <fs_wa>-voidr NE space.
      IF <fs_wa>-checf NE <fs_wa>-chect.
        CONCATENATE <fs_wa>-checf '-0' <fs_wa>-chect INTO vl_cadena.
        CONDENSE vl_cadena NO-GAPS.
        <fs_wa>-text1 = vl_cadena.
      ELSE.

        <fs_wa>-text1 = TEXT-004.
        REPLACE:
           '&VOIDU' WITH <fs_wa>-voidu  INTO <fs_wa>-text1,
           '&VOIDD' WITH <fs_wa>-voidd INTO <fs_wa>-text1,
           '&VOIDT' WITH <fs_wa>-voidt INTO   <fs_wa>-text1.

      ENDIF.
    ENDIF.


  ENDLOOP.




ENDFORM.
*&---------------------------------------------------------------------*
*& Form create_fieldcat
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM create_fieldcat .
  CLEAR wa_fieldcat.
  REFRESH gt_fieldcat.

  wa_fieldcat-fieldname = 'CHECT'.
  wa_fieldcat-seltext_m = 'Nº de cheque'.
  wa_fieldcat-seltext_l = 'Nº de cheque'.
  APPEND wa_fieldcat TO gt_fieldcat.CLEAR wa_fieldcat.

  wa_fieldcat-fieldname = 'VBLNR'.
  wa_fieldcat-seltext_m = 'Doc. de Pago'.
  wa_fieldcat-seltext_l = 'Doc. de Pago'.
  APPEND wa_fieldcat TO gt_fieldcat.CLEAR wa_fieldcat.


  wa_fieldcat-fieldname = 'ZALDT'.
  wa_fieldcat-seltext_m = 'Fec. Pago'.
  wa_fieldcat-seltext_l = 'Fec. Pago'.
  APPEND wa_fieldcat TO gt_fieldcat.CLEAR wa_fieldcat.


  wa_fieldcat-fieldname = 'WAERS'.
  wa_fieldcat-seltext_m = 'Moneda'.
  wa_fieldcat-seltext_l = 'Moneda'.
  APPEND wa_fieldcat TO gt_fieldcat.CLEAR wa_fieldcat.


  wa_fieldcat-fieldname = 'RWBTR'.
  wa_fieldcat-seltext_m = 'Importe'.
  wa_fieldcat-seltext_l = 'Importe'.
  wa_fieldcat-do_sum    = 'X'.
  APPEND wa_fieldcat TO gt_fieldcat.CLEAR wa_fieldcat.

  wa_fieldcat-fieldname = 'ZNME1'.
  wa_fieldcat-seltext_m = 'Receptor'.
  wa_fieldcat-seltext_l = 'Receptor'.
  APPEND wa_fieldcat TO gt_fieldcat.CLEAR wa_fieldcat.

  wa_fieldcat-fieldname = 'STCD1'.
  wa_fieldcat-seltext_m = 'R.F.C.'.
  wa_fieldcat-seltext_l = 'R.F.C.'.
  APPEND wa_fieldcat TO gt_fieldcat.CLEAR wa_fieldcat.

  wa_fieldcat-fieldname = 'BANCD'.
  wa_fieldcat-seltext_m = 'Cobrado el...'.
  wa_fieldcat-seltext_l = 'Cobrado el...'.
  APPEND wa_fieldcat TO gt_fieldcat.CLEAR wa_fieldcat.

  wa_fieldcat-fieldname = 'TEXT1'.
  wa_fieldcat-seltext_m = 'Descrip. Pago'.
  wa_fieldcat-seltext_l = 'Descrip. Pago'.
  APPEND wa_fieldcat TO gt_fieldcat.CLEAR wa_fieldcat.



ENDFORM.
*&---------------------------------------------------------------------*
*& Form show_alv
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM show_alv .
  gl_layout-zebra = 'X'.
  gl_layout-colwidth_optimize = 'X'.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program     = sy-repid
*     I_CALLBACK_PF_STATUS_SET          = ' '
*     I_CALLBACK_USER_COMMAND           = ' '
      i_callback_top_of_page = 'TOP_OF_PAGE'
      is_layout              = gl_layout
      it_fieldcat            = gt_fieldcat
*     IT_SORT                =
    TABLES
      t_outtab               = it_zpayr
    EXCEPTIONS
      program_error          = 1
      OTHERS                 = 2.
ENDFORM.

FORM top_of_page.
refresh gt_header[].
  DATA vl_cadena TYPE string.

  DATA: BEGIN OF x001.
          INCLUDE STRUCTURE t001_bf.
  DATA: END OF x001.
  DATA: x001z LIKE t001z_bf OCCURS 0 WITH HEADER LINE.


  bhdgd-inifl   = 0.
  bhdgd-lines   = sy-linsz.
  bhdgd-uname   = sy-uname.
  bhdgd-repid   = sy-repid.
  bhdgd-line1   = sy-title.
  bhdgd-line2   = TEXT-014.
  bhdgd-miffl   = ''.
  bhdgd-separ   = ''.
  bhdgd-domai   = 'BUKRS'.
  bhdgd-bukrs   = par_zbuk.
  bhdgd-werte   = par_zbuk.
  REPLACE '&BUKRS' WITH par_zbuk INTO bhdgd-line2.

  CALL FUNCTION 'FI_COMPANYCODE_GETDETAIL'
    EXPORTING
      bukrs_int                  = bhdgd-bukrs
      authority_check            = space
    IMPORTING
      t001_int                   = x001
    TABLES
      t001z_int                  = x001z
    EXCEPTIONS
      bukrs_not_found            = 1
      no_authority_display_bukrs = 2
      OTHERS                     = 3.
* Titulo
  CONCATENATE x001-butxt
              bhdgd-line1
              INTO wa_header-info SEPARATED BY space.
  wa_header-typ  = 'H'.
  APPEND wa_header TO gt_header.
  CLEAR wa_header.

  CONCATENATE x001-ort01 '.'  bhdgd-line2 INTO wa_header-info SEPARATED BY space.
  wa_header-typ  = 'S'.
  APPEND wa_header TO gt_header.
  CLEAR wa_header.

  wa_header-typ = 'S'.
  CONCATENATE 'Fecha: ' sy-datum+6(2) '.'
              sy-datum+4(2) '.'
              sy-datum(4) INTO wa_header-info.
  APPEND wa_header TO gt_header.
  CLEAR wa_header.

  wa_header-typ = 'S'.
  wa_header-info = ''.
  APPEND wa_header TO gt_header.
  CLEAR wa_header.


  READ TABLE it_zpayr INTO DATA(wa) INDEX 1.
  wa_header-typ = 'S'.
  wa_header-info = TEXT-007.
  REPLACE:
    '&HBKID' WITH wa-hbkid  INTO wa_header-info,
    '&BANKA' WITH wa-banka  INTO wa_header-info,
    '&ORT01' WITH wa-ort01  INTO wa_header-info.
  APPEND wa_header TO gt_header.
  CLEAR wa_header.

  wa_header-typ = 'S'.
  wa_header-info = TEXT-008.
  REPLACE:
    '&BANKL' WITH wa-bankl  INTO wa_header-info.
  APPEND wa_header TO gt_header.
  CLEAR wa_header.

   wa_header-typ = 'S'.
  wa_header-info = TEXT-009.
  REPLACE:
    '&HKTID' WITH wa-HKTID  INTO wa_header-info,
    '&BANKN' WITH wa-BANKN INTO wa_header-info.
  APPEND wa_header TO gt_header.
  CLEAR wa_header.


  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      it_list_commentary = gt_header
*     i_logo             = 'LOGO_CHICKY'
    .

ENDFORM.
