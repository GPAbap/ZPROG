*&---------------------------------------------------------------------*
*& Include ztm_re_rendcomve_fun
*&---------------------------------------------------------------------*

FORM get_data.

  FIELD-SYMBOLS <fs_tab> TYPE tab.

  DATA e_char_field LIKE cha_class_view-sollwert.
  DATA i_fltp_value LIKE cha_class_data-sollwert.
  DATA wa_output TYPE p DECIMALS 2.


  SELECT equi~objnr AS objnr1, equz~iwerk,equz~ingrp, fleet~fleet_cat, fleet~fuel_pri,t~type_text, fleet~objnr,
       equi~equnr, k~eqktx
 INTO CORRESPONDING FIELDS OF TABLE @it_rec
FROM fleet
INNER JOIN equi ON  fleet~objnr = equi~objnr
INNER JOIN equz ON equi~equnr = equz~equnr
LEFT JOIN t370fld_t AS t ON t~fluid_type = fleet~fuel_pri
INNER JOIN eqkt AS k ON k~equnr = equi~equnr
WHERE  equi~equnr       IN @equnr_p
AND    fleet~fleet_cat  IN @fleetcap
AND    fleet~fuel_pri   IN @fuelprip.

  DELETE it_rec WHERE iwerk NOT IN iwerk_p.
  DELETE it_rec WHERE ingrp NOT IN ingrp_p.


  LOOP AT it_rec INTO DATA(wa_rec).
    REFRESH et_rihimrg.
    PERFORM get_measuring_documents USING wa_rec-equnr.

    SORT et_rihimrg BY mdocm.

    IF et_rihimrg[] IS NOT INITIAL.
      LOOP AT et_rihimrg INTO DATA(detalle) WHERE idate IN idate_p .
        APPEND INITIAL LINE TO it_tab ASSIGNING <fs_tab>.
        MOVE-CORRESPONDING wa_rec TO <fs_tab>.
        CONCATENATE <fs_tab>-equnr <fs_tab>-eqktx INTO <fs_tab>-equtx SEPARATED BY space.
        CONCATENATE <fs_tab>-fuel_pri <fs_tab>-type_text INTO <fs_tab>-fueltx SEPARATED BY space.
        "IF detalle-psort EQ 'DISTANCE'.
        IF detalle-unitm EQ 'KM'.
          i_fltp_value = detalle-cdifc.
          CALL FUNCTION 'QSS0_FLTP_TO_CHAR_CONVERSION'
            EXPORTING
              i_number_of_digits       = 0
              i_fltp_value             = i_fltp_value
              i_value_not_initial_flag = 'X'
              i_screen_fieldlength     = 16
            IMPORTING
              e_char_field             = e_char_field.

          <fs_tab>-distance = e_char_field.
          <fs_tab>-idate    = detalle-idate.
          <fs_tab>-itime    = detalle-itime.

          "READ TABLE et_rihimrg INTO DATA(wa) WITH KEY psort = 'FUEL' eruhr = detalle-eruhr.
          READ TABLE et_rihimrg INTO DATA(wa) WITH KEY unitm = 'L' eruhr = detalle-eruhr itime = detalle-itime
                                                       idate = detalle-idate.                     .
          IF sy-subrc EQ 0.

            i_fltp_value = wa-cdifc.
            CALL FUNCTION 'QSS0_FLTP_TO_CHAR_CONVERSION'
              EXPORTING
                i_number_of_digits       = 2
                i_fltp_value             = i_fltp_value
                i_value_not_initial_flag = 'X'
                i_screen_fieldlength     = 16
              IMPORTING
                e_char_field             = e_char_field.


            IF  e_char_field EQ 0 OR e_char_field IS INITIAL.
              i_fltp_value = wa-recdc. "litros.
              CALL FUNCTION 'QSS0_FLTP_TO_CHAR_CONVERSION'
                EXPORTING
                  i_number_of_digits       = 2
                  i_fltp_value             = i_fltp_value
                  i_value_not_initial_flag = 'X'
                  i_screen_fieldlength     = 16
                IMPORTING
                  e_char_field             = e_char_field.



              CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
                EXPORTING
                  input  = wa-mdocm
                IMPORTING
                  output = <fs_tab>-mdocm.

              <fs_tab>-fuel     = e_char_field.
              <fs_tab>-idate    = wa-idate.
              <fs_tab>-itime    = wa-itime.
           else.
             <fs_tab>-fuel     = e_char_field.

           ENDIF.
          ENDIF.


        ELSEIF detalle-unitm EQ 'H'.

          i_fltp_value = detalle-cdifc.
          CALL FUNCTION 'QSS0_FLTP_TO_CHAR_CONVERSION'
            EXPORTING
              i_number_of_digits       = 2
              i_fltp_value             = i_fltp_value
              i_value_not_initial_flag = 'X'
              i_screen_fieldlength     = 16
            IMPORTING
              e_char_field             = e_char_field.


          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
            EXPORTING
              input  = detalle-mdocm
            IMPORTING
              output = <fs_tab>-mdocm.

          <fs_tab>-time = e_char_field.
          <fs_tab>-idate    = detalle-idate.
          <fs_tab>-itime    = detalle-itime.


          "fuel
          "i_fltp_value = detalle-recdc.
          READ TABLE et_rihimrg INTO wa WITH KEY unitm = 'L' eruhr = detalle-eruhr itime = detalle-itime
                                                       idate = detalle-idate.
          IF sy-subrc EQ 0.
            i_fltp_value = wa-cdifc.
            CALL FUNCTION 'QSS0_FLTP_TO_CHAR_CONVERSION'
              EXPORTING
                i_number_of_digits       = 2
                i_fltp_value             = i_fltp_value
                i_value_not_initial_flag = 'X'
                i_screen_fieldlength     = 16
              IMPORTING
                e_char_field             = e_char_field.

            <fs_tab>-fuel     = e_char_field.
          ENDIF.

          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
            EXPORTING
              input  = detalle-mdocm
            IMPORTING
              output = <fs_tab>-mdocm.


        ENDIF.

        IF <fs_tab>-fuel > 0 AND <fs_tab>-distance > 0.
          <fs_tab>-rend = <fs_tab>-distance / <fs_tab>-fuel.
          wa_output = <fs_tab>-rend.
          CALL FUNCTION 'ROUND'
            EXPORTING
              decimals = 2
              input    = wa_output
*             SIGN     = ' '
            IMPORTING
              output   = wa_output.


*          IF detalle-recdc EQ detalle-cdifc.
*            <fs_tab>-rend = 1.
*          ELSE.
          <fs_tab>-rend = wa_output.
*          ENDIF.
        ENDIF.
        "horas
        IF <fs_tab>-fuel > 0 AND <fs_tab>-time > 0.
          <fs_tab>-rend = <fs_tab>-time / <fs_tab>-fuel.
          wa_output = <fs_tab>-rend.
          CALL FUNCTION 'ROUND'
            EXPORTING
              decimals = 2
              input    = wa_output
*             SIGN     = ' '
            IMPORTING
              output   = wa_output.


*          IF detalle-recdc EQ detalle-cdifc.
*            <fs_tab>-rend = 1.
*          ELSE.
          <fs_tab>-rend = wa_output.
*          ENDIF.
        ENDIF.


      ENDLOOP.

      DELETE it_tab WHERE idate IS INITIAL.
    ENDIF.

  ENDLOOP.



ENDFORM.


FORM create_fieldcat.

  CLEAR wa_fieldcat.

  wa_fieldcat-fieldname = 'fleet_cat'.
  wa_fieldcat-seltext_m = 'Cl. Vehiculo'.
  APPEND wa_fieldcat TO gt_fieldcat. CLEAR wa_fieldcat.

  wa_fieldcat-fieldname = 'fueltx'.
  wa_fieldcat-seltext_m = 'Tipo Comb.'.
  APPEND wa_fieldcat TO gt_fieldcat. CLEAR wa_fieldcat.

*  wa_fieldcat-fieldname = 'TYPE_TEXT'.
*  wa_fieldcat-seltext_m = 'Descripción'.
*  APPEND wa_fieldcat TO gt_fieldcat. CLEAR wa_fieldcat.

*  wa_fieldcat-fieldname = 'EQUNR'.
*  wa_fieldcat-seltext_m = 'Equipo'.
*  APPEND wa_fieldcat TO gt_fieldcat. CLEAR wa_fieldcat.

  wa_fieldcat-fieldname = 'EQUTX'.
  wa_fieldcat-seltext_m = 'Equipo'.
  APPEND wa_fieldcat TO gt_fieldcat. CLEAR wa_fieldcat.

  wa_fieldcat-fieldname = 'idate'.
  wa_fieldcat-seltext_m = 'Fecha'.
  APPEND wa_fieldcat TO gt_fieldcat. CLEAR wa_fieldcat.

  wa_fieldcat-fieldname = 'itime'.
  wa_fieldcat-seltext_m = 'Hora'.
  APPEND wa_fieldcat TO gt_fieldcat. CLEAR wa_fieldcat.

  wa_fieldcat-fieldname = 'mdocm'.
  wa_fieldcat-seltext_m = 'Doc. Medición'.
  APPEND wa_fieldcat TO gt_fieldcat. CLEAR wa_fieldcat.

  wa_fieldcat-fieldname = 'distance'.
  wa_fieldcat-seltext_m = 'Distancia Kms.'.
  wa_fieldcat-do_sum    = 'X'.
  APPEND wa_fieldcat TO gt_fieldcat. CLEAR wa_fieldcat.

  wa_fieldcat-fieldname = 'time'.
  wa_fieldcat-seltext_m = 'Horas Trab.'.
  wa_fieldcat-do_sum    = 'X'.
  APPEND wa_fieldcat TO gt_fieldcat. CLEAR wa_fieldcat.

  wa_fieldcat-fieldname = 'fuel'.
  wa_fieldcat-seltext_m = 'Combustible Lts'.
  wa_fieldcat-do_sum    = 'X'.
  APPEND wa_fieldcat TO gt_fieldcat. CLEAR wa_fieldcat.

  wa_fieldcat-fieldname = 'rend'.
  wa_fieldcat-seltext_m = 'Rendimiento (KM/HR)/Lt.'.
*  wa_fieldcat-do_sum    = 'X'.
  APPEND wa_fieldcat TO gt_fieldcat. CLEAR wa_fieldcat.



ENDFORM.

FORM show_alv.

  lf_layout-zebra = 'X'.
  lf_layout-colwidth_optimize = 'X'.

  CLEAR st_sort.
  st_sort-spos = 1.
  st_sort-fieldname = 'fleet_cat'.
  st_sort-group = '*'.     "-->ADD THIS
  st_sort-subtot = 'X'.
  APPEND st_sort TO ti_sort.

*  CLEAR st_sort.
*  st_sort-spos = 1.
*  st_sort-fieldname = 'rend'.
*  st_sort-group = '*'.     "-->ADD THIS
**  st_sort-up = 'X'.
*  st_sort-subtot = 'X'.
**  st_sort-expa = 'X'.
*  APPEND st_sort TO ti_sort.


  CLEAR st_sort.
  st_sort-spos = 1.
  st_sort-fieldname = 'fueltx'.
  st_sort-group = '*'.     "-->ADD THIS
  st_sort-subtot = 'X'.
  APPEND st_sort TO ti_sort.

  CLEAR st_sort.
  st_sort-spos = 1.
  st_sort-fieldname = 'EQUTX'.
  st_sort-group = '*'.     "-->ADD THIS
  st_sort-subtot = 'X'.
  APPEND st_sort TO ti_sort.


  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program = sy-repid
      is_layout          = lf_layout
      it_fieldcat        = gt_fieldcat
      it_sort            = ti_sort
    TABLES
      t_outtab           = it_tab.

ENDFORM..
*&---------------------------------------------------------------------*
*& Form GET_MEASURING_DOCUMENTS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_measuring_documents USING p_equnr TYPE rihimrg-equnr.

  TYPES:
    typ_rt_equnr TYPE RANGE OF rihimrg-equnr.

  DATA:
    rt_equnr  TYPE typ_rt_equnr,
    ls_equnr  TYPE LINE OF typ_rt_equnr,
    ind_empty TYPE xflag.
  DATA: BEGIN OF sel_tab OCCURS 500.
          INCLUDE STRUCTURE rihimrg.
  DATA: END OF sel_tab.

  ls_equnr-low    = p_equnr.
  ls_equnr-sign   = 'I'.
  ls_equnr-option = 'EQ'.
  APPEND ls_equnr TO rt_equnr.

  SUBMIT
  riimr020
    WITH dy_selm  = 'D'
    WITH dy_tcode = 'IQ17'
    WITH equnr    IN rt_equnr
    WITH selcount = '500'
  AND RETURN.
  ind_empty = 'X'.
  IMPORT ind_empty FROM MEMORY ID 'RIIMR020'.
  IF ind_empty IS INITIAL.
    IMPORT sel_tab FROM MEMORY ID 'RIIMR020'.
  ENDIF.

  INSERT LINES OF sel_tab INTO TABLE et_rihimrg.

ENDFORM.
