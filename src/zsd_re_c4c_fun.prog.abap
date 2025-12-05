*&---------------------------------------------------------------------*
*& Include zsd_re_c4c_fun
*&---------------------------------------------------------------------*

FORM get_data_simple.

  DATA vl_index TYPE sy-tabix.
  DATA: vl_vbeln     TYPE vbeln, vl_kunag TYPE kunag, vl_vkorg TYPE vkorg,
        vl_vtweg     TYPE vtweg, vl_fkdat TYPE fkdat, vl_bzirk TYPE bzirk,
        vl_spart     TYPE spart, vl_imp_fact TYPE dmbtr, vl_moneda TYPE waers,
        vl_tipcambio TYPE dmbtr.

  DATA vl_fecha TYPE sy-datum.

  vl_fecha = sy-datum - 1.

  REFRESH rg_kschl.
  CLEAR wa_rgkschl.

  wa_rgkschl-option = 'EQ'.
  wa_rgkschl-sign = 'I'.
  wa_rgkschl-low = 'ZS01'.
  APPEND wa_rgkschl TO rg_kschl.
  wa_rgkschl-option = 'EQ'.
  wa_rgkschl-sign = 'I'.
  wa_rgkschl-low = 'ZS02'.
  APPEND wa_rgkschl TO rg_kschl.
  wa_rgkschl-option = 'EQ'.
  wa_rgkschl-sign = 'I'.
  wa_rgkschl-low = 'ZD01'.
  APPEND wa_rgkschl TO rg_kschl.
  wa_rgkschl-option = 'EQ'.
  wa_rgkschl-sign = 'I'.
  wa_rgkschl-low = 'ZD02'.
  APPEND wa_rgkschl TO rg_kschl.
  wa_rgkschl-option = 'EQ'.
  wa_rgkschl-sign = 'I'.
  wa_rgkschl-low = 'ZF02'.
  APPEND wa_rgkschl TO rg_kschl.
  wa_rgkschl-option = 'EQ'.
  wa_rgkschl-sign = 'I'.
  wa_rgkschl-low = 'ZF04'.
  APPEND wa_rgkschl TO rg_kschl.
  wa_rgkschl-option = 'EQ'.
  wa_rgkschl-sign = 'I'.
  wa_rgkschl-low = 'ZF05'.
  APPEND wa_rgkschl TO rg_kschl.


  SELECT DISTINCT   vbrk~vkorg, vbrk~vtweg, vbrk~spart,
                    vbrp~vkbur, vbrp~vkgrp, vbrp~aubel,
                    vbrk~vbeln, vbrp~posnr, vbrk~fkdat, vbrk~kunag,
                    kna1~name1 AS name1_sol,
                    vbrp~kunwe_ana,
                    k2~name1 AS name1_dest,
                    vbrk~bzirk, vbrk~knumv,
                    vbrp~matnr,vbrp~arktx,
                    vbrp~werks, vbrp~charg, vbrp~prodh,
                    vbrp~fkimg, vbrp~vrkme, vbrp~ntgew,
                    vbrp~gewei, vbrk~netwr AS netwr_vbrk,vbrp~netwr AS netwr_vbrp,
                    CASE WHEN vbrp~kzwi1 EQ 0 THEN vbrp~kzwi2 ELSE vbrp~kzwi1 END AS kzwi1,
                    vbrp~kzwi6,
                    vbrk~waerk, vbrk~kurrf,
                     CAST( 0 AS QUAN( 13,2 ) ) AS zs01zs02,
                     CAST( 0 AS DEC( 13,2 )  ) AS zf02,
                     CAST( 0 AS DEC( 13,2 )  ) AS zd01,
                     CAST( 0 AS DEC( 13,2 )  ) AS zd02,
                     CAST( 0 AS DEC( 13,2 )  ) AS zs01,
                     CAST( 0 AS DEC( 13,2 )  ) AS zs02,
                     CAST( 0 AS DEC( 13,2 )  ) AS zf04,
                     CAST( 0 AS DEC( 13,2 )  ) AS zf05
      INTO TABLE @it_outtable
      FROM vbrk
      INNER JOIN kna1 ON kna1~kunnr = vbrk~kunag
      INNER JOIN vbrp ON vbrk~vbeln = vbrp~vbeln
      INNER JOIN kna1 AS k2 ON vbrp~kunwe_ana = k2~kunnr
      WHERE
       vbrk~vkorg IN ( 'AV02','AZ01','AZ02','AZ03','AZ04','AZ05' ) AND
       vbrk~fkdat EQ @vl_fecha
       .

  SORT it_outtable BY vbeln posnr.

  IF it_outtable[] IS NOT INITIAL.

    SELECT vkorg, vtweg, spart, vkbur, vkgrp, aubel, vbeln, posnr, fkdat
    INTO CORRESPONDING FIELDS OF TABLE @it_zsd_tt_c4c
    FROM zsd_tt_c4c
    WHERE fkdat EQ @vl_fecha.

  ENDIF.

  it_outtable = FILTER #( it_outtable EXCEPT IN it_zsd_tt_c4c USING KEY pk WHERE vkorg = vkorg AND vtweg = vtweg AND
                             spart = spart AND vkbur = vkbur AND vkgrp = vkgrp AND aubel = aubel AND vbeln = vbeln
                             AND posnr = posnr  AND fkdat = fkdat ).

  IF it_outtable[] IS NOT INITIAL.
    SELECT knumv, kposn, kschl, kwert
     INTO TABLE @DATA(it_elements)
    FROM prcd_elements
    FOR ALL ENTRIES IN @it_outtable
    WHERE knumv = @it_outtable-knumv AND kposn = @it_outtable-posnr AND
    kschl IN  @rg_kschl.
  ENDIF.

  IF it_outtable[] IS NOT INITIAL.




    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    TRY.
        CREATE OBJECT gv_cl_wsc4c
          EXPORTING
            logical_port_name = 'ZLP_CPI'.
      CATCH cx_ai_system_fault .
    ENDTRY.
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    "actualización de descuentos en pedido.
    LOOP AT it_outtable INTO wa_outtable.

      vl_index = sy-tabix.
      "ajuste""""""""""""""""""""""""""""""""""""""""""""""""""""""
      LOOP AT rg_kschl INTO wa_rgkschl.
        READ TABLE it_elements INTO DATA(wa_elements) WITH KEY knumv = wa_outtable-knumv kposn = wa_outtable-posnr kschl = wa_rgkschl-low.
        IF sy-subrc EQ 0.
          CASE wa_elements-kschl.
            WHEN 'ZF02'.
              wa_outtable-zf02 = wa_elements-kwert.
            WHEN 'ZD01'.
              wa_outtable-zd01 = wa_elements-kwert.
            WHEN 'ZD02'.
              wa_outtable-zd02 = wa_elements-kwert.
            WHEN 'ZS01'.
              wa_outtable-zs01 = wa_elements-kwert.
            WHEN 'ZS02'.
              wa_outtable-zs02 = wa_elements-kwert.
            WHEN 'ZF04'.
              wa_outtable-zf04 = wa_elements-kwert.
            WHEN 'ZF05'.
              wa_outtable-zf05 = wa_elements-kwert.
          ENDCASE.
          MODIFY it_outtable FROM wa_outtable INDEX vl_index.
        ENDIF.
      ENDLOOP.
    ENDLOOP.
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    CLEAR vl_index.
    vl_index = 1.

    DATA(it_outtable_vbeln) = it_outtable[].
    SORT it_outtable_vbeln BY vbeln.
    DELETE ADJACENT DUPLICATES FROM it_outtable_vbeln COMPARING vbeln.

    LOOP AT it_outtable_vbeln INTO wa_outtable.
      CLEAR vl_index.
*      ENDIF.
      """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
      vl_vbeln = wa_outtable-vbeln.
      vl_kunag = wa_outtable-kunag.
      vl_vkorg = wa_outtable-vkorg.
      vl_vtweg = wa_outtable-vtweg.
      vl_fkdat = wa_outtable-fkdat.
      vl_bzirk = wa_outtable-bzirk. "zona de ventas
      vl_spart = wa_outtable-spart.
      vl_imp_fact = wa_outtable-netwr_vbrk.
      vl_moneda = wa_outtable-waerk.
      vl_tipcambio = wa_outtable-kurrf.
      """""""""""""""se envia la factura a C4C.""""""""""""""""""""""""""""""""""""""""""""""""
      vl_posicion = VALUE #( FOR ls_outtable IN it_outtable INDEX INTO lv_index
                             WHERE ( vbeln = wa_outtable-vbeln )
                           (
                              z_centro_suministro_id = ls_outtable-werks
                              z_producto_id-content = ls_outtable-matnr
                              z_categoria_producto_id = ls_outtable-prodh
                              z_oficina_ventas_id = ls_outtable-vkbur "oficina de ventas
                              z_grupo_vendedor_id = ls_outtable-vkgrp
                              "nuevos campos añadidos wdsl.
                              z_numero_pedido = ls_outtable-aubel
                              z_numero_posicion = ls_outtable-posnr
                              z_destino_id = ls_outtable-name1_dest
                              z_lote = ls_outtable-charg
                              z_cantidad = ls_outtable-fkimg "cantidad facturada
                              z_cantidad_unidad_medida = ls_outtable-vrkme "unidad de medida venta
                              z_cantidad_base = ls_outtable-ntgew
                              z_cantidad_base_unidad_medida = ls_outtable-gewei
                              z_importe_unitario = ls_outtable-kzwi1 "wa_outtable-netwr_vbrp. (este importe ya contiene descuentos)
                              z_apoyo_flete_ab_zf02-content = ls_outtable-zf02
                              z_descuento_dist_clie_ab_zd01-content = ls_outtable-zd01
                              z_distribuidor_mascota_ab_zd02-content = ls_outtable-zd02
                              z_cargo_segu_cr_ab_zs01-content = ls_outtable-zs01
                              z_cargo_segu_cr_ab_zs02-content = ls_outtable-zs02
                              z_flete_ingenio_zf04-content = ls_outtable-zf04
                              z_flete_maniobra_ingenio_zf05-content = ls_outtable-zf05
                              z_ventas_brutas_ab_zs01_zs02-content = ls_outtable-netwr_vbrp
                              z_importe_producto_ingenio-content = ls_outtable-kzwi1 + ls_outtable-kzwi6
                           )
                     ).

      """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
      """"""""""""""para guardar en la tabla interna
      it_zsd_tt_c4c = VALUE #( FOR ls_outtable IN it_outtable INDEX INTO lv_index
                        WHERE ( vbeln = wa_outtable-vbeln )
                      (
                         vkorg = ls_outtable-vkorg
                         vtweg = ls_outtable-vtweg
                         spart = ls_outtable-spart
                         vkbur = ls_outtable-vkbur
                         vkgrp = ls_outtable-vkgrp
                         aubel = ls_outtable-aubel
                         vbeln = ls_outtable-vbeln
                         posnr = ls_outtable-posnr
                         fkdat = ls_outtable-fkdat
                         kunag = ls_outtable-kunag
                         name1_sol = ls_outtable-name1_sol
                         kunwe_ana = ls_outtable-kunwe_ana
                         name1_dest = ls_outtable-name1_dest
                         bzirk = ls_outtable-bzirk
                         knumv = ls_outtable-knumv
                         matnr = ls_outtable-matnr
                         arktx = ls_outtable-arktx
                         werks = ls_outtable-werks
                         charg = ls_outtable-charg
                         prodh = ls_outtable-prodh
                         fkimg = ls_outtable-fkimg
                         vrkme = ls_outtable-vrkme
                         ntgew = ls_outtable-ntgew
                         gewei = ls_outtable-ntgew
                         netwr_vbrk = ls_outtable-netwr_vbrk
                         netwr_vbrp = ls_outtable-netwr_vbrp
                         kzwi1 = ls_outtable-kzwi1
                         kzwi6 = ls_outtable-kzwi6
                         waerk = ls_outtable-waerk
                         kurrf = ls_outtable-kurrf
                         zs01zs02 = ls_outtable-zs01zs02
                         zf02 = ls_outtable-zf02
                         zd01 = ls_outtable-zd01
                         zd02 = ls_outtable-zd02
                         zs01 = ls_outtable-zs01
                         zs02 = ls_outtable-zs02
                         zf04 = ls_outtable-zf04
                         zf05 = ls_outtable-zf05
                         enviado = abap_false

                      )
                ).

      vl_input-bo_facturas_create_request_syn-bo_facturas-z_documento_facturacion = vl_vbeln.
      vl_input-bo_facturas_create_request_syn-bo_facturas-z_solicitante_id = vl_kunag.
      vl_input-bo_facturas_create_request_syn-bo_facturas-z_organizacion_ventas_id = vl_vkorg.
      vl_input-bo_facturas_create_request_syn-bo_facturas-z_canal_distribucion-content = vl_vtweg.
      vl_input-bo_facturas_create_request_syn-bo_facturas-z_fecha_facturacion = vl_fkdat.
      vl_input-bo_facturas_create_request_syn-bo_facturas-z_zona_ventas_id = vl_bzirk.
      vl_input-bo_facturas_create_request_syn-bo_facturas-z_sector-content = vl_spart.
      vl_input-bo_facturas_create_request_syn-bo_facturas-z_importe_factura = vl_imp_fact.
      vl_input-bo_facturas_create_request_syn-bo_facturas-z_moneda = vl_moneda.
      vl_input-bo_facturas_create_request_syn-bo_facturas-z_tipo_cambio = vl_tipcambio.
      vl_input-bo_facturas_create_request_syn-bo_facturas-posicion = vl_posicion.

      TRY.
          CALL METHOD gv_cl_wsc4c->create
            EXPORTING
              input  = vl_input
            IMPORTING
              output = vl_output.
        CATCH cx_ai_system_fault.
        CATCH zcpicx_standard_fault_message.
          .
      ENDTRY.


      """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
      DATA(vl_result) = vl_output-bo_facturas_create_confirmatio-log-item[].

      READ TABLE vl_result INTO DATA(wa_result) INDEX 1.
      IF sy-subrc EQ 0.
        IF wa_result-severity_code EQ 1.
          LOOP AT it_zsd_tt_c4c INTO wa_zsd_tt_c4c.
            wa_zsd_tt_c4c-enviado = abap_true.
            MODIFY it_zsd_tt_c4c FROM wa_zsd_tt_c4c INDEX sy-tabix.
          ENDLOOP.

          """"""""""""""""""""""""""""""""""""""""""""""""""""""""""
          TRY.
              INSERT zsd_tt_c4c FROM TABLE it_zsd_tt_c4c.
            CATCH cx_sy_open_sql_db.
          ENDTRY.
          """"""""""""""""""""""""""""""""""""""""""""""""""""""""""

        ENDIF.
      ENDIF.


      REFRESH: vl_posicion, it_zsd_tt_c4c.
      CLEAR: vl_vbeln, vl_kunag, vl_vkorg,
      vl_vtweg, vl_fkdat, vl_bzirk,
      vl_spart.

*      ENDAT.
    ENDLOOP.

  ENDIF.
ENDFORM.
