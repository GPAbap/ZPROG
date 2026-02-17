*&---------------------------------------------------------------------*
*& Include zsd_re_traza_docs_fun
*&---------------------------------------------------------------------*


FORM get_data.

  DATA: vl_name    LIKE thead-tdname,
        vl_it_line TYPE STANDARD TABLE OF tline.

  SELECT v~vbeln,z1~uuid AS uuid_refac, v~fkdat AS fkdat_refac,v~kunrg AS kungrg_refac, k~name1 AS name1_refac, v~netwr AS netwr_refac, v~waerk AS waerk_refact, v~fksto,
  f~vbeln AS vbeln_aj, z2~uuid AS uuid_aj,
  CASE WHEN f~vbtyp_n = 'O' THEN 'NOTA DE CREDITO' ELSE CASE WHEN  f~vbtyp_n = 'N'
            THEN 'CANCELACION DE FACTURA' END END AS vbtyp_n, v2~netwr AS netwr_aj,
  z1~mot_canc, p~aubel, va~abgru, t~bezei
  INTO TABLE @it_outtable
  FROM vbrk AS v
  INNER JOIN vbrp AS p ON p~vbeln = v~vbeln
  INNER JOIN kna1 AS k ON k~kunnr = v~kunrg
  LEFT JOIN vbfa AS f ON f~vbelv = v~vbeln AND f~vbtyp_n IN ( 'O', 'N' )
  INNER JOIN zsd_cfdi_timbre AS z1 ON z1~vbeln = v~vbeln
  LEFT JOIN zsd_cfdi_timbre AS z2 ON z2~vbeln = f~vbeln
  LEFT JOIN vbrk AS v2 ON v2~vbeln = f~vbeln
  LEFT JOIN vbap AS va ON va~vbeln = p~aubel
  LEFT JOIN tvagt AS t ON t~abgru = va~abgru

   WHERE v~bukrs IN @s_bukrs
  AND v~vkorg IN @s_vkorg
  AND v~fkdat IN @s_fkdat
  AND v~kunrg IN @s_kunrg
  AND v~vbtyp IN @s_vbtyp
  AND v~spart IN @s_spart
  AND v~vtweg IN @s_vtweg
  AND v~vbeln IN @s_vbeln
  AND v~fksto EQ ''.


  SORT it_outtable BY vbeln.
  DELETE it_outtable WHERE vbtyp_n = 'NOTA DE CREDITO' AND netwr_aj = 0.

  DELETE ADJACENT DUPLICATES FROM it_outtable COMPARING vbeln.


  LOOP AT it_outtable ASSIGNING FIELD-SYMBOL(<fs_outtable>).

    vl_name = <fs_outtable>-aubel.

    SELECT t~augru, t~bezei
       INTO TABLE @DATA(it_augru)
       FROM vbak AS v
      INNER JOIN tvaut AS t ON t~augru = v~augru
     WHERE vbeln = @vl_name.

    READ TABLE it_augru INTO DATA(wa_augru) INDEX 1.
    IF sy-subrc EQ 0.
      <fs_outtable>-augru = wa_augru-augru.
      <fs_outtable>-bezei_ref = wa_augru-bezei.
    ENDIF.

    CALL FUNCTION 'READ_TEXT'
      EXPORTING
*       client                  = SY-MANDT
        id                      = 'ZS06'
        language                = 'S'
        name                    = vl_name
        object                  = 'VBBK'
      TABLES
        lines                   = vl_it_line
      EXCEPTIONS
        id                      = 1
        language                = 2
        name                    = 3
        not_found               = 4
        object                  = 5
        reference_check         = 6
        wrong_access_to_archive = 7
        OTHERS                  = 8.


    READ TABLE vl_it_line INTO DATA(wa_line) INDEX 1.
    IF sy-subrc EQ 0.
      <fs_outtable>-vbeln_frefac = wa_line-tdline.

      <fs_outtable>-vbeln_frefac = |{ <fs_outtable>-vbeln_frefac ALPHA = IN }|.

      IF <fs_outtable>-vbeln_frefac IS NOT INITIAL.


        SELECT v~vbeln,z1~uuid AS uuid_fo, p2~erdat ,v~kunrg, k~name1, v~netwr AS netwr, v~waerk AS waerk,
        z2~uuid AS uuid_aj,p~shkzg,t~abgru, t~bezei,v~fksto, z2~mot_canc, z2~comentario, f~vbeln AS doc_can,
        z2~erdat AS fec_vbeln_c
        INTO TABLE @DATA(it_fact_canc)
        FROM vbrk AS v
        INNER JOIN vbrp AS p ON p~vbeln = v~vbeln
        INNER JOIN kna1 AS k ON k~kunnr = v~kunrg
        LEFT JOIN vbfa AS f ON f~vbelv = v~vbeln AND f~vbtyp_n IN ( 'O', 'N' )
        INNER JOIN zsd_cfdi_timbre AS z1 ON z1~vbeln = v~vbeln
        LEFT JOIN zsd_cfdi_timbre AS z2 ON z2~vbeln = p~vbeln
        LEFT JOIN vbrp AS p2 ON p2~vbeln = f~vbeln
        LEFT JOIN vbap AS va ON va~vbeln = p~aubel
        LEFT JOIN tvagt AS t ON t~abgru = va~abgru
        WHERE p~aubel = @<fs_outtable>-vbeln_frefac.



        IF sy-subrc EQ 0.
          LOOP AT it_fact_canc INTO DATA(wa_fact_canc).
            IF wa_fact_canc-shkzg = 'X'.
              <fs_outtable>-uuid_aj = wa_fact_canc-uuid_aj.
            ELSE.
              <fs_outtable>-vbeln_canc = wa_Fact_canc-vbeln.
              <fs_outtable>-uuid_fo = wa_Fact_canc-uuid_fo.
              <fs_outtable>-netwr = wa_fact_canc-netwr.
              <fs_outtable>-waerk = wa_fact_canc-waerk.
              <fs_outtable>-kunrg = wa_fact_canc-kunrg.
              <fs_outtable>-name1 = wa_fact_canc-name1.
              <fs_outtable>-fkdat = wa_fact_Canc-erdat.
              <fs_outtable>-fkdat_vbeln_c = wa_fact_Canc-fec_vbeln_c.
              <fs_outtable>-abgru = wa_fact_canc-abgru.
              <fs_outtable>-bezei = wa_fact_canc-bezei.
              <fs_outtable>-fksto = wa_fact_canc-fksto.
              <fs_outtable>-mot_canc = wa_fact_canc-mot_canc.
              <fs_outtable>-vbeln_doccan = wa_fact_canc-doc_can.

            ENDIF.
          ENDLOOP.
        ELSE.
          <fs_outtable>-vbeln_frefac = space.

          IF <fs_outtable>-vbeln_canc IS INITIAL.

            SELECT p~vbeln, sfakn_ana,kunrg_ana,fkdat_ana,z~mot_canc, z~comentario, z~uuid,
              z~netwr, z~waers, k~name1,lpad( v~sfakn, 10, '0' ) AS sfakn

            FROM vbrk AS v
            INNER JOIN vbrp AS p ON p~vbeln = v~vbeln
            INNER JOIN kna1 AS k ON k~kunnr = p~kunag_ana
            LEFT JOIN zsd_cfdi_timbre AS z  ON z~vbeln = p~sfakn_ana
             WHERE aubel = @<fs_outtable>-aubel
              AND shkzg = 'X'
               INTO TABLE @DATA(it_fact_ana)
              .

            IF sy-subrc EQ 0.
              READ TABLE it_fact_ana INTO DATA(wa_ana) INDEX 1.

              SELECT uuid, netwr, waers, mot_canc, erdat
                INTO TABLE @DATA(it_cfdi_ana)
              FROM zsd_cfdi_timbre
              WHERE vbeln = @wa_ana-sfakn.

              READ TABLE it_cfdi_ana INTO DATA(wa_cfdi_ana) INDEX 1.

              IF wa_ana-sfakn_ana IS INITIAL.
                <fs_outtable>-vbeln_canc = wa_ana-sfakn.
              ELSE.
                <fs_outtable>-vbeln_canc = wa_ana-sfakn_ana.
              ENDIF.

              <fs_outtable>-fkdat = wa_ana-fkdat_ana.
              <fs_outtable>-fkdat_vbeln_c = wa_cfdi_ana-erdat.
              <fs_outtable>-vbeln_doccan = wa_ana-vbeln.
              <fs_outtable>-kunrg = wa_ana-kunrg_ana.
              <fs_outtable>-fksto  = 'X'.
              IF  wa_ana-mot_canc IS INITIAL.
                <fs_outtable>-mot_canc = wa_cfdi_ana-mot_canc.
              ELSE.
                <fs_outtable>-mot_canc = wa_ana-mot_canc.
              ENDIF.

              IF wa_ana-uuid IS INITIAL.
                <fs_outtable>-uuid_fo = wa_cfdi_ana-uuid.
              ELSE.
                <fs_outtable>-uuid_fo = wa_ana-uuid.
              ENDIF.

              IF wa_ana-netwr IS INITIAL.
                <fs_outtable>-netwr = wa_cfdi_ana-netwr.
              ELSE.
                <fs_outtable>-netwr = wa_ana-netwr.
              ENDIF.

              IF wa_ana-waers IS INITIAL.
                <fs_outtable>-waerk = wa_cfdi_ana-waers.
              ELSE.
                <fs_outtable>-waerk = wa_ana-waers.
              ENDIF.


              <fs_outtable>-name1 = wa_ana-name1.

            ENDIF.

          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.

    IF <fs_outtable>-vbeln_canc IS NOT INITIAL.
      <fs_outtable>-vbtyp_n = 'REFACTURADO'.
    ENDIF.

  ENDLOOP.
*

ENDFORM.

FORM show_data.

  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_structure_name       = 'ZSD_ST_TRAZAFACTS'
    CHANGING
      ct_fieldcat            = gv_t_fieldcat
    EXCEPTIONS
      inconsistent_interface = 1
      program_error          = 2
      OTHERS                 = 3.



  LOOP AT gv_t_fieldcat ASSIGNING FIELD-SYMBOL(<fs_fcat>).
    IF <fs_fcat>-fieldname = 'VBELN' OR <fs_fcat>-fieldname = 'VBELN_AJ' OR <fs_fcat>-fieldname = 'VBELN_REFACT'
       OR <fs_fcat>-fieldname = 'AUBEL' OR <fs_fcat>-fieldname = 'VBELN_FREFAC' OR
          <fs_fcat>-fieldname = 'VBELN_CANC'.
      <fs_fcat>-hotspot = 'X'.
    ENDIF.
  ENDLOOP.




  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program      = sy-repid
      it_fieldcat             = gv_t_fieldcat
      i_callback_user_command = 'USER_COMMAND'
      i_save                  = 'X'
    TABLES
      t_outtab                = it_outtable
    EXCEPTIONS
      program_error           = 1
      OTHERS                  = 2.

ENDFORM.
FORM user_command USING r_ucomm     LIKE sy-ucomm
                        rs_selfield TYPE slis_selfield.

  CASE r_ucomm.
    WHEN '&IC1'. " Hotspot click event
      CASE rs_selfield-fieldname.
        WHEN 'VBELN' OR 'VBELN_AJ' OR 'VBELN_REFACT'.
          SET PARAMETER ID 'VF' FIELD rs_selfield-value .
          CALL TRANSACTION 'VF03' AND SKIP FIRST SCREEN.
        WHEN 'AUBEL'.
          SET PARAMETER ID 'AUN' FIELD rs_selfield-value .
          CALL TRANSACTION 'VA03' AND SKIP FIRST SCREEN.
        WHEN 'VBELN_CANC'.
          SET PARAMETER ID 'VF' FIELD rs_selfield-value .
          CALL TRANSACTION 'VF03' AND SKIP FIRST SCREEN.
        WHEN 'VBELN_FREFAC'.
          SET PARAMETER ID 'AUN' FIELD rs_selfield-value .
          CALL TRANSACTION 'VA03' AND SKIP FIRST SCREEN.

      ENDCASE.

  ENDCASE.
ENDFORM.
