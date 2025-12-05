************************************************************************
*                                                                      *
*            ********************************************              *
*            *   Confidential and Proprietary           *              *
*            *   XAMAI S.A. de C.V.                     *              *
*            *   All Rights Reserved                    *              *
*            ********************************************              *
*                                                                      *
************************************************************************
* Programa principal  :  ZCOMPLEMENTO_PAGOS_CFDI_33                    *
* Titulo              :  Generación de XML con complemento de pagos    *
*                                                                      *
* Programador         : David Del Valle Mendoza                        *
* Fecha               : VII.2017                                       *
************************************************************************
*&---------------------------------------------------------------------*
*&  Include           ZCOMP_PAGOS_CFDI_33_F01_CUST
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  F_GENERA_XML
*&---------------------------------------------------------------------*
FORM F_GENERA_XML.

  DATA: V_MONTO         TYPE P DECIMALS 2,
        V_MTP           TYPE P DECIMALS 2,
        V_MONTO_S       TYPE STRING,
        V_NUM_OPERACION TYPE STRING.

****************************************************************************************************
***************** ENVIO EN FORMATO PARA PASAR A JSON ***********************************************
****************************************************************************************************
**** Inicio del procesamiento del xml **********************************************************************
  CLEAR IT_XML. REFRESH IT_XML.
  CLEAR I_OUTPUT.
  REFRESH: IT_XML[].

********************************************************************************************
***              ARMA LA ESTRUCTURA QUE ESPERA PI CON LA DEFINICION DEL SAT              ***
********************************************************************************************

*** Lee los datos de la tabla de cabecera de comprobante
  READ TABLE I_COMPROBANTE INDEX 1.

  IT_XML = '<root>'. APPEND IT_XML. CLEAR IT_XML.

  CLEAR V_NODO.
*** Indica que si se debe generar el pdf
  PERFORM F_OUTPUT USING V_NODO 'GENERA_PDF' '1'.

*** Valores de usuario y contraseña
  CLEAR:   I_ZPAC_DATOS_LOGON.
  REFRESH: I_ZPAC_DATOS_LOGON.

  SELECT *
    FROM ZPAC_DATOS_LOGON
    INTO TABLE I_ZPAC_DATOS_LOGON
    WHERE BUKRS = S_BUKRS-LOW.

  READ TABLE I_ZPAC_DATOS_LOGON INDEX 1.
  PERFORM F_OUTPUT USING V_NODO 'USUARIO'    I_ZPAC_DATOS_LOGON-USER_PAC.
  PERFORM F_OUTPUT USING V_NODO 'CONTRASENA' I_ZPAC_DATOS_LOGON-PASSWORD_PAC.

  CLEAR V_NODO.

*************************************************************************************
***                               NODO COMPROBANTE                                ***
*************************************************************************************
*** Se conservan todos los valores del xml original para poder descargarlo y revisar en caso de error
  V_NODO = 'COMPROBANTE'.

*** Version obligatorio
  PERFORM F_OUTPUT USING V_NODO 'VERSION' C_VERSION.

*** Serie OPCIONAL **********************************************************************

  IF I_COMPROBANTE-SERIE IS NOT INITIAL.
    PERFORM F_OUTPUT USING V_NODO 'SERIE' I_COMPROBANTE-SERIE.
  ENDIF.

**** Folio OPCIONAL **********************************************************************
  IF I_COMPROBANTE-SERIE IS NOT INITIAL.
    PERFORM F_OUTPUT USING V_NODO 'FOLIO' I_COMPROBANTE-SERIE.
  ENDIF.

*** Fecha REQUERIDO **********************************************************************
  PERFORM F_OUTPUT USING V_NODO 'FECHA' I_COMPROBANTE-FECHA.

*** Sello REQUERIDO (VACIO)

*** Forma de pago CONDICIONAL solo si se conoce **********************************************************************

*** No. de certificado REQUERIDO

*** Certificado REQUERIDO

*** Condiciones de pago CONDICIONAL **********************************************************************

*** Subtotal REQUERIDO
  WRITE I_COMPROBANTE-SUBTOTAL TO C_CADENA.
  PERFORM F_OUTPUT USING V_NODO 'SUB_TOTAL' C_CADENA.


*** Moneda REQUERIDO **********************************************************************
  PERFORM F_OUTPUT USING V_NODO 'MONEDA' I_COMPROBANTE-MONEDA.

**** Tipo de Cambio CONDICIONAL **********************************************************************
*  PERFORM F_OUTPUT USING V_NODO 'TIPO_CAMBIO' '1'.


***** Total REQUERIDO **********************************************************************
  CLEAR C_CADENA.
  WRITE I_COMPROBANTE-TOTAL TO C_CADENA.
  PERFORM F_OUTPUT USING V_NODO 'TOTAL' C_CADENA.


*** Tipo de comprobante REQUERIDO **********************************************************************
  PERFORM F_OUTPUT USING V_NODO 'TIPO_DE_COMPROBANTE' I_COMPROBANTE-TIPODECOMPROBANTE.

*** Metodo de pago CONDICIONAL **********************************************************************

**** Lugar de expedicion REQUERIDO **********************************************************************
  PERFORM F_OUTPUT USING V_NODO 'LUGAR_EXPEDICION' I_COMPROBANTE-LUGAREXPEDICION.

*** Exportacion
  PERFORM F_OUTPUT USING V_NODO 'EXPORTACION' '01'.

*** EXtrae la lista de régimenes para eliminarlos
  DATA: I_ZLISTA_REGIMEN TYPE ZLISTA_REGIMEN OCCURS 0 WITH HEADER LINE.
  CLEAR:   I_ZLISTA_REGIMEN.
  REFRESH: I_ZLISTA_REGIMEN.

  SELECT *
    FROM ZLISTA_REGIMEN
    INTO TABLE I_ZLISTA_REGIMEN.

***************************************************************************
***                               EMISOR                                ***
***************************************************************************

  MOVE '<Emisor>' TO IT_XML. SHIFT IT_XML BY 2 PLACES RIGHT. APPEND IT_XML. CLEAR IT_XML.
  V_NODO = 'COMPROBANTE-EMISOR'.

*** Rfc Obligatorio
  IF SY-SYSID = 'SPD' OR SY-SYSID = 'SPQ'.
*    I_COMPROBANTE-RFC_EMISOR = 'EWE1709045U0'.
*    I_COMPROBANTE-RFC_EMISOR = 'DDS100430FC1'.
*    I_COMPROBANTE-RFC_EMISOR = 'CDU161017EJA'.
  ENDIF.
  PERFORM F_OUTPUT USING V_NODO 'RFC' I_COMPROBANTE-RFC_EMISOR.

*** Nombre Emisor OPCIONAL
*** Codigo duro - eliminar!!!
  IF SY-SYSID = 'SPD' OR SY-SYSID = 'SPQ'.
*    I_COMPROBANTE-NOMBRE_EMISOR = 'ESCUELA WILSON ESQUIVEL S DE CV'.
*    I_COMPROBANTE-NOMBRE_EMISOR = 'ESCUELA WILSON ESQUIVEL'.
*    I_COMPROBANTE-NOMBRE_EMISOR = 'COMERCIALIZADORA DULCINEA'.
  ENDIF.

  C_CADENA = I_COMPROBANTE-NOMBRE_EMISOR.
  TRANSLATE C_CADENA TO UPPER CASE.
  LOOP AT I_ZLISTA_REGIMEN.
    REPLACE ALL OCCURRENCES OF I_ZLISTA_REGIMEN-REGIMEN IN C_CADENA WITH SPACE.
  ENDLOOP.

  PERFORM F_OUTPUT USING V_NODO 'NOMBRE' C_CADENA.

*** Regiman Fiscal OBLIGATORIO
  PERFORM F_OUTPUT USING V_NODO 'REGIMEN_FISCAL' I_COMPROBANTE-REGIMENFISCAL_EMISOR.

  MOVE '</Emisor>' TO IT_XML. SHIFT IT_XML BY 2 PLACES RIGHT. APPEND IT_XML. CLEAR IT_XML.



*****************************************************************************
***                               RECEPTOR                                ***
*****************************************************************************
  MOVE '<Receptor>' TO IT_XML. SHIFT IT_XML BY 2 PLACES RIGHT. APPEND IT_XML. CLEAR IT_XML.
  V_NODO = 'COMPROBANTE-RECEPTOR'.

*** RFC receptor OBLIGATORIO
  PERFORM F_OUTPUT USING V_NODO 'RFC' I_COMPROBANTE-RFC_RECEPTOR.

*** Nombre Receptor OPCIONAL
  C_CADENA = I_COMPROBANTE-NOMBRE_RECEPTOR.
  TRANSLATE C_CADENA TO UPPER CASE.
  LOOP AT I_ZLISTA_REGIMEN.
    REPLACE ALL OCCURRENCES OF I_ZLISTA_REGIMEN-REGIMEN IN C_CADENA WITH SPACE.
  ENDLOOP.

  REPLACE ALL OCCURRENCES OF  `  ` IN C_CADENA WITH  ` `.

  PERFORM F_OUTPUT USING V_NODO 'NOMBRE' C_CADENA.

  IF I_COMPROBANTE-RFC_RECEPTOR IS INITIAL AND I_KNA1-LAND1 = 'MX'.
    I_COMPROBANTE-RFC_RECEPTOR = 'XAXX010101000'.
  ENDIF.

*** Domicilio fiscal receptor (4.0)
  DATA: V_DOM_FISC_REC        TYPE STRING.
  CLEAR V_DOM_FISC_REC.

  SELECT SINGLE POST_CODE1
    FROM ADRC
    INTO V_DOM_FISC_REC
    WHERE ADDRNUMBER = I_KNA1-ADRNR.

  PERFORM F_OUTPUT USING V_NODO 'DOMICILIO_FISCAL_RECEPTOR' V_DOM_FISC_REC.

*** RegimenFiscalReceptor (4.0)
  DATA: V_REG_RECEPTOR TYPE STRING.
  CLEAR V_REG_RECEPTOR.

  SELECT SINGLE KVGR5
    FROM KNVV
    INTO V_REG_RECEPTOR
    WHERE KUNNR = I_KNA1-KUNNR
    AND   KVGR5 NE SPACE.

  PERFORM F_OUTPUT USING V_NODO 'REGIMEN_FISCAL_RECEPTOR' V_REG_RECEPTOR.

  IF I_KNA1-LAND1 NE 'MX'.
    I_COMPROBANTE-RFC_RECEPTOR = 'XEXX010101000'.

*** Datos adicoinales: Residencia Fiscal y NumRegIdTrib
    DATA: V_RES_FISC   TYPE STRING,
          V_NUM_REG_ID TYPE STRING.

    CLEAR: V_RES_FISC, V_NUM_REG_ID.

    SELECT SINGLE INTCA3
      FROM T005
      INTO V_RES_FISC
      WHERE LAND1 = I_KNA1-LAND1.


    IF I_KNA1-LAND1 NE 'MX'.
      V_NUM_REG_ID = I_KNA1-STCD1.
    ELSE.
      V_NUM_REG_ID = I_KNA1-STCEG.
    ENDIF.

    REPLACE ALL OCCURRENCES OF '-' IN V_NUM_REG_ID WITH SPACE.
    CONDENSE V_NUM_REG_ID.

*** Residencia Fiscal Receptor CONDICIONAL
    PERFORM F_OUTPUT USING V_NODO 'RESIDENCIA_FISCAL' V_RES_FISC.


*** Numero de registro de identidad fiscal del receptor CONDICIONAL
    PERFORM F_OUTPUT USING V_NODO 'NUM_REG_ID_TRIB' V_NUM_REG_ID.

  ENDIF.


*** Uso del CFDI OBLIGATORIO **********************************************************************
  I_COMPROBANTE-USOCFDI = 'CP01'.

  PERFORM F_OUTPUT USING V_NODO 'USO_CFDI' I_COMPROBANTE-USOCFDI.

  MOVE '</Receptor>' TO IT_XML. SHIFT IT_XML BY 2 PLACES RIGHT. APPEND IT_XML. CLEAR IT_XML.


*********************************************************************************************************************************
***                               CONCEPTOS                               *******************************************************
*********************************************************************************************************************************
  V_NODO = 'COMPROBANTE-CONCEPTOS'.

  CLEAR IT_XML.
*** Estructura para cada concepto

  CLEAR: ZREQ_CONCEP,I_OUTPUT-COMPROBANTE-CONCEPTOS-CONCEPTO.
  REFRESH: ZREQ_CONCEP.

*** ClaveProdServ REQUERIDO **********************************************************************
  PERFORM F_CADENA_XML USING 'CLAVE_PROD_SERV' I_COMPROBANTE-CLAVEPRODSERV.
  ZREQ_CONCEP-CLAVE_PROD_SERV   = I_COMPROBANTE-CLAVEPRODSERV.

**** NoIdentificacion OPCIONAL *********************************************************************************

*** Cantidad REQUERIDO *******************************************************************************************
  PERFORM F_CADENA_XML USING 'CANTIDAD' I_COMPROBANTE-CANTIDAD.
  ZREQ_CONCEP-CANTIDAD     = I_COMPROBANTE-CANTIDAD.

*** ClaveUnidad REQUERIDO ****************************************************************************************
  PERFORM F_CADENA_XML USING 'CLAVE_UNIDAD' I_COMPROBANTE-CLAVEUNIDAD.
  ZREQ_CONCEP-CLAVE_UNIDAD    = I_COMPROBANTE-CLAVEUNIDAD.

*** Descripcion REQUERIDO *******************************************************************************
  PERFORM F_CADENA_XML USING 'DESCRIPCION' I_COMPROBANTE-DESCRIPCION.
  ZREQ_CONCEP-DESCRIPCION     = I_COMPROBANTE-DESCRIPCION.

*** Valor Unitario REQUERIDO ***************************************************************************
  PERFORM F_CADENA_XML USING 'VALOR_UNITARIO' I_COMPROBANTE-VALORUNITARIO.
  ZREQ_CONCEP-VALOR_UNITARIO    = I_COMPROBANTE-VALORUNITARIO.

*** Importe REQUERIDO *********************************************************************************
  PERFORM F_CADENA_XML USING 'IMPORTE' I_COMPROBANTE-IMPORTE.
  ZREQ_CONCEP-IMPORTE     = I_COMPROBANTE-IMPORTE.

  PERFORM F_CADENA_XML USING 'OBJETO_IMP' '01'.
  ZREQ_CONCEP-OBJETO_IMP = '01'.

  APPEND ZREQ_CONCEP TO I_OUTPUT-COMPROBANTE-CONCEPTOS-CONCEPTO.
  CLEAR: ZREQ_CONCEP, Z_CONCEPTOS.
  REFRESH: ZREQ_CONCEP, Z_CONCEPTOS.

*** Valida si es un pago para factura USD pago en MXN
  READ TABLE I_PAGO10_DOCTORELACIONADO INDEX 1.
  READ TABLE I_PAGO10_PAGO INDEX 1.

  DATA: V_FLAG_USD TYPE C,
        I_BSEG_USD TYPE BSEG OCCURS 0 WITH HEADER LINE.
  CLEAR: V_FLAG_USD, I_BSEG_USD.
  REFRESH: I_BSEG_USD.

  IF I_PAGO10_DOCTORELACIONADO-MONEDADR = 'USD' AND
     I_PAGO10_PAGO-MONEDAP = 'MXN'.
    V_FLAG_USD = 'X'.

    DATA: I_DATA_ALV_USD LIKE I_DATA_ALV OCCURS 0 WITH HEADER LINE.
    CLEAR: I_DATA_ALV_USD.
    REFRESH: I_DATA_ALV_USD.

    I_DATA_ALV_USD[] = I_DATA_ALV[].
    READ TABLE I_DATA_ALV_USD WITH KEY
      LLAVE = I_PAGO10_PAGO-DOC_PAGO.

    SELECT *
      FROM BSEG
      INTO TABLE I_BSEG_USD
      WHERE BUKRS = S_BUKRS-LOW
      AND   BELNR = I_PAGO10_PAGO-DOC_PAGO
      AND   GJAHR = I_DATA_ALV_USD-BUDAT+6(4)
      AND   BSCHL = '40'
      AND   KOART = 'S'
      AND   KTOSL = SPACE
      and   kostl = space.
    READ TABLE I_BSEG_USD INDEX 1.
  ENDIF.

****************************************************************************************************
*** Nodo Complemento Cabecera **********************************************************************
****************************************************************************************************
*** Abreo nodo COMPLEMENTO
  CLEAR: IT_XML_COMP.
  REFRESH IT_XML_COMP.

*** Abre nodo PAGOS
  DATA: V_VERSION_PAGO TYPE STRING,
        V_NODO_PAGO    TYPE STRING.

  CLEAR:   V_VERSION_PAGO, V_NODO_PAGO.

  V_VERSION_PAGO = '2.0'.
  V_NODO_PAGO = 'pago20'.

  CONCATENATE '<' V_NODO_PAGO ':Pagos xmlns:pago20="http://www.sat.gob.mx/Pagos20" Version="'
                  V_VERSION_PAGO '">'
    INTO IT_XML_COMP.
  SHIFT IT_XML_COMP BY 4 PLACES RIGHT.
  APPEND IT_XML_COMP. CLEAR IT_XML_COMP.



*****************************************************************************************************
***                         Llena totales impuestos (2.0)                                         ***
*****************************************************************************************************
  CLEAR: V_TOTRETIVA, V_TOTRETISR, V_TOTRETIEPS, V_TRASLBASE16,
         V_TRASLIMP16, V_TRASLBASE8, V_TRASLIVA8, V_TRASLBASE0,
         V_TRASLIVA0, V_TRASLEX, V_MONTOTOTPAG.



*** Calcula el importe para cada nodo en base al indicador de IVA
*** y el importe pagado
  DELETE ADJACENT DUPLICATES FROM I_PAGO10_DOCTORELACIONADO.
  LOOP AT I_PAGO10_DOCTORELACIONADO.

    CLEAR:   I_Z33_IMPUESTOS, V_KNUMV_IMP, V_MWSK1, I_PRCD_ELEMENTS, V_RETEN_DOC, V_FLAG_CI.
    REFRESH: I_Z33_IMPUESTOS, I_PRCD_ELEMENTS.

*** Se extrae la tabla con todos los conceptos de impuestos a reportar
    SELECT *
      FROM Z33_IMPUESTOS
      INTO TABLE I_Z33_IMPUESTOS.

*** Extrae la clase de condicion
    SELECT SINGLE KNUMV
          FROM VBRK
          INTO V_KNUMV_IMP
          WHERE VBELN = I_PAGO10_DOCTORELACIONADO-FACTURA.

    IF V_KNUMV_IMP IS INITIAL.
      CLEAR V_MWSK1.

*** Primero busca en la bsad
      SELECT SINGLE MWSKZ
        FROM BSAD
        INTO V_MWSK1
        WHERE SGTXT = I_PAGO10_DOCTORELACIONADO-IDDOCUMENTO
        AND MWSKZ NE SPACE.
      IF V_MWSK1 IS NOT INITIAL.
        V_FLAG_CI = 'X'.
      ELSE.
*** Despues busca en la bsid
        SELECT SINGLE MWSKZ
          FROM BSID
          INTO V_MWSK1
          WHERE SGTXT = I_PAGO10_DOCTORELACIONADO-IDDOCUMENTO
          AND MWSKZ NE SPACE.
        IF V_MWSK1 IS NOT INITIAL.
          V_FLAG_CI = 'X'.
        ENDIF.
      ENDIF.
    ENDIF.


*** Extrae todas las clases de condicion
    SELECT * FROM PRCD_ELEMENTS
      INTO TABLE I_PRCD_ELEMENTS
      FOR ALL ENTRIES IN I_Z33_IMPUESTOS
      WHERE KNUMV = V_KNUMV_IMP
      AND   KSCHL = I_Z33_IMPUESTOS-KSCHL.
    DATA: BEGIN OF I_LISTA_COND OCCURS 0,
            MWSK1 TYPE MWSKZ.
    DATA: END OF I_LISTA_COND.
    DATA: V_CANT_IND   TYPE I.

    CLEAR: I_LISTA_COND, V_CANT_IND.
    REFRESH: I_LISTA_COND.

    LOOP AT I_Z33_IMPUESTOS WHERE Z33USOIMP = 'TRASL'.
      LOOP AT I_PRCD_ELEMENTS WHERE KSCHL = I_Z33_IMPUESTOS-KSCHL.
*        IF SY-SUBRC EQ 0.
        I_LISTA_COND-MWSK1 = I_PRCD_ELEMENTS-MWSK1.
        APPEND I_LISTA_COND.
*        ENDIF.
      ENDLOOP.
    ENDLOOP.

    DELETE ADJACENT DUPLICATES FROM I_LISTA_COND.
    DESCRIBE TABLE I_LISTA_COND LINES V_CANT_IND.

    IF V_FLAG_CI = 'X'.

      CLEAR: I_BSAD_INDIC.
      REFRESH: I_BSAD_INDIC.

      SELECT MWSKZ
             SGTXT
        FROM BSAD
        INTO TABLE I_BSAD_INDIC
        WHERE SGTXT = I_PAGO10_DOCTORELACIONADO-IDDOCUMENTO
        AND   MWSKZ NE SPACE.

      IF SY-SUBRC NE 0.
        SELECT MWSKZ
            SGTXT
       FROM BSID
       INTO TABLE I_BSAD_INDIC
       WHERE SGTXT = I_PAGO10_DOCTORELACIONADO-IDDOCUMENTO
          AND   MWSKZ NE SPACE.
      ENDIF.
      SORT I_BSAD_INDIC.
      DELETE ADJACENT DUPLICATES FROM I_BSAD_INDIC.
      CLEAR V_CANT_IND.
      DESCRIBE TABLE I_BSAD_INDIC LINES V_CANT_IND.

    ENDIF.

*** Para las retenciones **********************************************************************
*** Solo tienen retenciones de IVA
    LOOP AT I_Z33_IMPUESTOS WHERE Z33USOIMP = 'RETEN'.
      READ TABLE I_PRCD_ELEMENTS WITH KEY KSCHL = I_Z33_IMPUESTOS-KSCHL.
*** Si tiene impuesto retenido
      IF SY-SUBRC EQ 0.
*** Todas las retenciones son del 16, usar la misma logia que traslados
        PERFORM F_RETEN_A1 USING    'A1'
                                    I_PAGO10_DOCTORELACIONADO-IMPPAGADO
                           CHANGING V_TOTRETIVA.
      ENDIF.
    ENDLOOP.
    V_RETEN_DOC = V_TOTRETIVA.

    IF V_CANT_IND = 1.
*** Extrae el indicador de IVA
      READ TABLE I_PRCD_ELEMENTS WITH KEY KSCHL = 'MWST'.
      IF V_FLAG_CI NE 'X'.
        V_MWSK1 = I_PRCD_ELEMENTS-MWSK1.
      ENDIF.
      READ TABLE I_VBRK WITH KEY VBELN = I_PAGO10_DOCTORELACIONADO-FACTURA.

*** Tasa IVA 0%
      IF V_MWSK1 = 'A0' OR V_MWSK1 = 'B0' OR V_MWSK1 = 'Z0' OR V_MWSK1 = 'A3'.
        V_TRASLBASE0    = V_TRASLBASE0 + I_PAGO10_DOCTORELACIONADO-IMPPAGADO.
        V_TRASLIVA0     = '0.00'.

        IF V_FLAG_USD = 'X'.
          V_TRASLBASE0    =  I_BSEG_USD-DMBTR.
        ENDIF.

      ELSEIF V_MWSK1 = 'A1' OR V_MWSK1 = 'B1' OR V_MWSK1 = 'A4'.
        IF V_FLAG_USD = 'X'.
          PERFORM F_TRASL_A1 USING 'A1'
                                 I_BSEG_USD-DMBTR
                        CHANGING V_TRASLBASE16
                                 V_TRASLIMP16.
        ELSE.
          PERFORM F_TRASL_A1 USING 'A1'
                                   I_PAGO10_DOCTORELACIONADO-IMPPAGADO
                          CHANGING V_TRASLBASE16
                                   V_TRASLIMP16.
        ENDIF.
      ENDIF.
    ELSEIF V_CANT_IND = 2.

*** Cuando son facturas "normales"
      IF V_FLAG_CI NE 'X'.
        LOOP AT I_PRCD_ELEMENTS WHERE KSCHL = 'MWST'.
          V_MWSK1 = I_PRCD_ELEMENTS-MWSK1.
*        READ TABLE I_VBRK WITH KEY VBELN = I_PAGO10_DOCTORELACIONADO-FACTURA.


*** Tasa IVA 0%
          IF V_MWSK1 = 'A0' OR V_MWSK1 = 'B0' OR V_MWSK1 = 'Z0' OR V_MWSK1 = 'A3'.
            V_TRASLBASE0    = V_TRASLBASE0 + I_PRCD_ELEMENTS-KAWRT.
            "I_PAGO10_DOCTORELACIONADO-IMPPAGADO.
            V_TRASLIVA0     = '0.00'.

          ELSEIF V_MWSK1 = 'A1' OR V_MWSK1 = 'B1' OR V_MWSK1 = 'A4'.
            PERFORM F_TRASL_A1_MEZC USING 'A1'
                                          I_PRCD_ELEMENTS-KAWRT
                                     "I_PAGO10_DOCTORELACIONADO-IMPPAGADO
                            CHANGING V_TRASLBASE16
                                     V_TRASLIMP16.
          ENDIF.
        ENDLOOP.
*** Cuando son facturas de carga inicial.

      ELSE.
        DATA: BEGIN OF I_BSAD_CI OCCURS 0,
                AUGBL TYPE AUGBL,
                MWSKZ TYPE MWSKZ,
                SGTXT TYPE SGTXT.
        DATA: END OF I_BSAD_CI.

        CLEAR: I_BSAD_CI.
        REFRESH: I_BSAD_CI.

      ENDIF.
    ENDIF.


*** Guarda los totales para la seccion de resumen del pago
*** antes del tipo de cambio
    V_TOTRETIVA_TOT   = V_TOTRETIVA.
    V_TRASLBASE0_TOT  = V_TRASLBASE0.
    V_TRASLIVA0_TOT   = V_TRASLIVA0.
    V_TRASLBASE16_TOT = V_TRASLBASE16.
    V_TRASLIMP16_TOT  = V_TRASLIMP16.

    IF I_PAGO10_DOCTORELACIONADO-MONEDADR = 'USD'.
*      V_TRASLBASE0 = V_TRASLBASE0 / I_PAGO10_DOCTORELACIONADO-TIPOCAMBIODR.
    ENDIF.
*** Estos no se usan
*  V_TRASLBASE8    = 'TRASLBASE8'.
*  V_TRASLIVA8     = 'TRASLIVA8'.
*  V_TRASLEX       = 'TRASLEX'.

*** Este se llena mas abajo
*  V_MONTOTOTPAG   = 'MONTOTOTPAG'.


  ENDLOOP.

*** Arma la cadena con los strings que mas abajo se reemplazan
*** con los valores reales.

  CONCATENATE '<' V_NODO_PAGO
              ':Totales TotalRetencionesIVA="'    'TOTRETIVA'
              '" TotalRetencionesISR="'           'TOTRETISR'
              '" TotalRetencionesIEPS="'          'TOTRETIEPS'
              '" TotalTrasladosBaseIVA16="'       'TRASLBASE16'
              '" TotalTrasladosImpuestoIVA16="'   'TRASLIMP16'
              '" TotalTrasladosBaseIVA8="'        'TRASLBASE8'
              '" TotalTrasladosImpuestoIVA8="'    'TRASLIVA8'
              '" TotalTrasladosBaseIVA0="'        'TRASLBASE0'
              '" TotalTrasladosImpuestoIVA0="'    'TRASLIVA0'
              '" TotalTrasladosBaseIVAExento="'   'TRASLEX'
              '" MontoTotalPagos="'               'MONTOTOTPAG'
              '"/>'
   INTO IT_XML_COMP RESPECTING BLANKS.
  APPEND IT_XML_COMP. CLEAR IT_XML_COMP.

*** Lee los datos de la tabla de cabecera del pago
  READ TABLE I_PAGO10_PAGO INDEX 1.

*** Abre nodo PAGO
  CONCATENATE '<' V_NODO_PAGO ':Pago FechaPago="' INTO IT_XML_COMP.

*** Fecha Pago
  CLEAR C_CADENA.
  CONCATENATE I_PAGO10_PAGO-FECHAPAGO '"' INTO C_CADENA.
  CONCATENATE IT_XML_COMP C_CADENA INTO IT_XML_COMP.

*** Forma de Pago
  CLEAR C_CADENA.
  IF I_PAGO10_PAGO-FORMADEPAGOP IS INITIAL
    AND ( SY-UNAME = 'DVALLE' OR SY-UNAME = 'VALMAGUER' ).
    I_PAGO10_PAGO-FORMADEPAGOP = '01'.
  ENDIF.
  CONCATENATE 'FormaDePagoP="' I_PAGO10_PAGO-FORMADEPAGOP '"' INTO C_CADENA.
  CONCATENATE IT_XML_COMP C_CADENA INTO IT_XML_COMP SEPARATED BY SPACE.

*** Moneda
  CLEAR C_CADENA.
  CONCATENATE 'MonedaP="' I_PAGO10_PAGO-MONEDAP '"' INTO C_CADENA.
  CONCATENATE IT_XML_COMP C_CADENA INTO IT_XML_COMP SEPARATED BY SPACE.

*** Tipo de cambio del pago
  IF I_PAGO10_PAGO-TIPOCAMBIOP IS NOT INITIAL.

    CLEAR: V_TIPODECAMBIO, V_TIPODECAMBIO_S, C_CADENA2.

    V_TIPODECAMBIO = I_PAGO10_PAGO-TIPOCAMBIOP.
    V_TIPODECAMBIO_S = V_TIPODECAMBIO.

    CONDENSE V_TIPODECAMBIO_S NO-GAPS.
    CONCATENATE 'TipoCambioP="' V_TIPODECAMBIO_S '"' INTO C_CADENA2.
    CONDENSE C_CADENA2 NO-GAPS.
    CONCATENATE IT_XML_COMP C_CADENA2 INTO IT_XML_COMP SEPARATED BY SPACE.

  ENDIF.

  IF I_PAGO10_PAGO-MONEDAP = 'MXP' OR I_PAGO10_PAGO-MONEDAP = 'MXN'.
    CONCATENATE 'TipoCambioP="' '1' '"' INTO C_CADENA2.
    CONDENSE C_CADENA2 NO-GAPS.
    CONCATENATE IT_XML_COMP C_CADENA2 INTO IT_XML_COMP SEPARATED BY SPACE.
    I_PAGO10_PAGO-TIPOCAMBIOP = 1.
    MODIFY I_PAGO10_PAGO INDEX 1.
  ENDIF.

*** Monto
  CLEAR: V_MONTO, V_MONTO_S, C_CADENA2.

  V_MONTO = I_PAGO10_PAGO-MONTO.
  ADD I_PAGO10_PAGO-MONTO TO V_MONTOTOTPAG.
  V_MONTO_S = V_MONTO.

  IF V_FLAG_USD = 'X'.
    V_MONTO_S = I_BSEG_USD-DMBTR.
  ENDIF.

  CONCATENATE 'Monto="' V_MONTO_S '"' INTO C_CADENA2.
  CONDENSE C_CADENA2 NO-GAPS.
  CONCATENATE IT_XML_COMP C_CADENA2 INTO IT_XML_COMP SEPARATED BY SPACE.

*** Numero de operacion
  IF I_PAGO10_PAGO-NUMOPERACION IS NOT INITIAL.
*    CLEAR V_NUM_OPERACION.
*    V_NUM_OPERACION = I_PAGO10_PAGO-NUMOPERACION.
*    CLEAR C_CADENA.
*    CONCATENATE 'NumOperacion="' I_PAGO10_PAGO-NUMOPERACION '"' INTO C_CADENA.
*    CONCATENATE IT_XML_COMP C_CADENA INTO IT_XML_COMP SEPARATED BY SPACE.
  ENDIF.

*** Campos nuevos en nodo Pago para 2.0 **********************************************************************
*** RfcEmisorCtaOrd (Condicional)
  CLEAR V_RFCEMISORCTAORD.
  IF V_RFCEMISORCTAORD IS NOT INITIAL.
    CLEAR C_CADENA.
    CONCATENATE 'RfcEmisorCtaOrd="' V_RFCEMISORCTAORD '"' INTO C_CADENA.
    CONCATENATE IT_XML_COMP C_CADENA INTO IT_XML_COMP SEPARATED BY SPACE.
  ENDIF.

*** NomBancoOrdExt (Condicional)
  CLEAR V_NOMBANCOORDEXT.
  IF V_NOMBANCOORDEXT IS NOT INITIAL.
    CLEAR C_CADENA.
    CONCATENATE 'NomBancoOrdExt="' V_NOMBANCOORDEXT '"' INTO C_CADENA.
    CONCATENATE IT_XML_COMP C_CADENA INTO IT_XML_COMP SEPARATED BY SPACE.
  ENDIF.

*** CtaOrdenante
  CLEAR V_CTAORDENANTE.
  IF V_CTAORDENANTE IS NOT INITIAL.
    CLEAR C_CADENA.
    CONCATENATE 'CtaOrdenante="' V_CTAORDENANTE '"' INTO C_CADENA.
    CONCATENATE IT_XML_COMP C_CADENA INTO IT_XML_COMP SEPARATED BY SPACE.
  ENDIF.

*** RfcEmisorCtaBen
  CLEAR V_RFCEMISORCTABEN.
  IF V_RFCEMISORCTABEN IS NOT INITIAL.
    CLEAR C_CADENA.
    CONCATENATE 'RfcEmisorCtaBen="' V_RFCEMISORCTABEN '"' INTO C_CADENA.
    CONCATENATE IT_XML_COMP C_CADENA INTO IT_XML_COMP SEPARATED BY SPACE.
  ENDIF.

*** CtaBeneficiario
  CLEAR V_CTABENEFICIARIO.
  IF V_CTABENEFICIARIO IS NOT INITIAL.
    CLEAR C_CADENA.
    CONCATENATE 'CtaBeneficiario="' V_CTABENEFICIARIO '"' INTO C_CADENA.
    CONCATENATE IT_XML_COMP C_CADENA INTO IT_XML_COMP SEPARATED BY SPACE.
  ENDIF.

*** TipoCadPago
  CLEAR V_TIPOCADPAGO.
  IF V_TIPOCADPAGO IS NOT INITIAL.
    CLEAR C_CADENA.
    CONCATENATE 'TipoCadPago="' V_TIPOCADPAGO '"' INTO C_CADENA.
    CONCATENATE IT_XML_COMP C_CADENA INTO IT_XML_COMP SEPARATED BY SPACE.
  ENDIF.

*** CertPago
  CLEAR V_CERTPAGO.
  IF V_CERTPAGO IS NOT INITIAL.
    CLEAR C_CADENA.
    CONCATENATE 'CertPago="' V_CERTPAGO '"' INTO C_CADENA.
    CONCATENATE IT_XML_COMP C_CADENA INTO IT_XML_COMP SEPARATED BY SPACE.
  ENDIF.

*** CadPago
  CLEAR V_CADPAGO.
  IF V_CADPAGO IS NOT INITIAL.
    CLEAR C_CADENA.
    CONCATENATE 'CadPago="' V_CADPAGO '"' INTO C_CADENA.
    CONCATENATE IT_XML_COMP C_CADENA INTO IT_XML_COMP SEPARATED BY SPACE.
  ENDIF.

*** SelloPago
  CLEAR V_SELLOPAGO.
  IF V_SELLOPAGO IS NOT INITIAL.
    CLEAR C_CADENA.
    CONCATENATE 'SelloPago="' V_SELLOPAGO '"' INTO C_CADENA.
    CONCATENATE IT_XML_COMP C_CADENA INTO IT_XML_COMP SEPARATED BY SPACE.
  ENDIF.

  CONCATENATE IT_XML_COMP '>' INTO IT_XML_COMP.
  SHIFT IT_XML_COMP BY 6 PLACES RIGHT.
  APPEND IT_XML_COMP. CLEAR IT_XML_COMP.

*** Nodo(s) de facturas relacionadas ****************************************************************************+
  DELETE ADJACENT DUPLICATES FROM I_PAGO10_DOCTORELACIONADO.

*****************************************************************************************************************
********************************** PARA CADA DOCUMENTO RELACIONADO **********************************************
*****************************************************************************************************************
  LOOP AT I_PAGO10_DOCTORELACIONADO.
    CLEAR: V_FLAG_CI.
    CONCATENATE '<' V_NODO_PAGO ':DoctoRelacionado IdDocumento="'
      INTO IT_XML_COMP.

*** UUID
    CONCATENATE IT_XML_COMP I_PAGO10_DOCTORELACIONADO-IDDOCUMENTO '"' INTO IT_XML_COMP.

*** Serie

*** Folio

*** Moneda DR
    CLEAR C_CADENA.
    CONCATENATE 'Folio="' I_PAGO10_DOCTORELACIONADO-FOLIO '"' INTO C_CADENA.
    CONCATENATE IT_XML_COMP C_CADENA INTO IT_XML_COMP SEPARATED BY SPACE.

*** Moneda DR
    CLEAR C_CADENA.
    CONCATENATE 'MonedaDR="' I_PAGO10_DOCTORELACIONADO-MONEDADR '"' INTO C_CADENA.
    CONCATENATE IT_XML_COMP C_CADENA INTO IT_XML_COMP SEPARATED BY SPACE.

***  Tipo de cambio DR /  Equivalencia DR ( 2.0)
    CLEAR: V_TAG_TC_EQUIV.

    V_TAG_TC_EQUIV = 'EquivalenciaDR="'.

    IF I_PAGO10_DOCTORELACIONADO-TIPOCAMBIODR IS NOT INITIAL.
      CLEAR: V_TIPODECAMBIO, V_TIPODECAMBIO_S, C_CADENA2.
      V_TIPODECAMBIO = I_PAGO10_DOCTORELACIONADO-TIPOCAMBIODR.
      V_TIPODECAMBIO_S = V_TIPODECAMBIO.
      IF V_FLAG_USD = 'X'.
        V_TIPODECAMBIO = I_PAGO10_DOCTORELACIONADO-IMPPAGADO /
                         I_BSEG_USD-DMBTR.
        V_TIPODECAMBIO_S = V_TIPODECAMBIO.
      ENDIF.
      CONDENSE V_TIPODECAMBIO_S NO-GAPS.
      CONCATENATE V_TAG_TC_EQUIV V_TIPODECAMBIO_S '"' INTO C_CADENA2.
      CONDENSE C_CADENA2 NO-GAPS.
      CONCATENATE IT_XML_COMP C_CADENA2 INTO IT_XML_COMP SEPARATED BY SPACE.
    ENDIF.

    IF I_PAGO10_DOCTORELACIONADO-MONEDADR = I_PAGO10_PAGO-MONEDAP.
      CONCATENATE V_TAG_TC_EQUIV '1' '"' INTO C_CADENA2.
      CONDENSE C_CADENA2 NO-GAPS.
      CONCATENATE IT_XML_COMP C_CADENA2 INTO IT_XML_COMP SEPARATED BY SPACE.
    ENDIF.

*** Metodo de pago DR
*    IF V_NODO_PAGO = '2.0'.
*    ELSE.
*      CLEAR C_CADENA.
*      CONCATENATE 'MetodoDePagoDR="' I_PAGO10_DOCTORELACIONADO-METODODEPAGODR '"' INTO C_CADENA.
*      CONCATENATE IT_XML_COMP C_CADENA INTO IT_XML_COMP SEPARATED BY SPACE.
*    ENDIF.

*** Numero de parcialidad DR
    CLEAR C_CADENA.
    CONCATENATE 'NumParcialidad="' I_PAGO10_DOCTORELACIONADO-NUMPARCIALIDAD '"' INTO C_CADENA.
    CONCATENATE IT_XML_COMP C_CADENA INTO IT_XML_COMP SEPARATED BY SPACE.

*** Importe Saldo Anterior
    CLEAR: V_MONTO, V_MONTO_S, C_CADENA2.
    V_MONTO = I_PAGO10_DOCTORELACIONADO-IMPSALDOANT.
    V_MONTO_S = V_MONTO.
    CONDENSE V_MONTO_S NO-GAPS.
    CLEAR C_CADENA2.
    CONCATENATE 'ImpSaldoAnt="' V_MONTO_S '"' INTO C_CADENA2.
    CONDENSE C_CADENA2 NO-GAPS.
    CONCATENATE IT_XML_COMP C_CADENA2 INTO IT_XML_COMP SEPARATED BY SPACE.

*** Importe Pagado
    CLEAR: V_MONTO, V_MONTO_S, C_CADENA2.
    V_MONTO = I_PAGO10_DOCTORELACIONADO-IMPPAGADO.
    V_MONTO_S = V_MONTO.
    CONDENSE V_MONTO_S NO-GAPS.
    CLEAR C_CADENA2.
    CONCATENATE 'ImpPagado="' V_MONTO_S '"' INTO C_CADENA2.
    CONDENSE C_CADENA2 NO-GAPS.
    CONCATENATE IT_XML_COMP C_CADENA2 INTO IT_XML_COMP SEPARATED BY SPACE.

*** Importe Saldo Insoluto
    CLEAR: V_MONTO, V_MONTO_S, C_CADENA2.
    V_MONTO = I_PAGO10_DOCTORELACIONADO-IMPSALDOINSOLUTO.
    V_MONTO_S = V_MONTO.
    CONDENSE V_MONTO_S NO-GAPS.
    CLEAR C_CADENA2.
    CONCATENATE 'ImpSaldoInsoluto="' V_MONTO_S '"' INTO C_CADENA2.
    CONDENSE C_CADENA2 NO-GAPS.
    CONCATENATE IT_XML_COMP C_CADENA2 INTO IT_XML_COMP SEPARATED BY SPACE.


*** ObjetoImpDR
*** Atributo requerido para expresar si el pago del documento
*** relacionado es objeto o no de impuesto.
*** 01  No objeto de impuesto.
*** 02  Sí objeto de impuesto.
*** 03  Sí objeto del impuesto y no obligado al desglose.
    CLEAR V_OBJETOIMPDR.

*** Extrae todos los conceptos de impuestos de la factura relacionada
*** para ver si pone el nodo abajo
    PERFORM F_IMPUESTOS_CONCEPTO.

    IF I_IMPUESTOS_DR[] IS NOT INITIAL.
      V_OBJETOIMPDR = '02'.
    ELSE.
      V_OBJETOIMPDR = '01'.
    ENDIF.

    CLEAR C_CADENA.
    C_CADENA = V_OBJETOIMPDR.
    CONCATENATE 'ObjetoImpDR="' V_OBJETOIMPDR '"' INTO C_CADENA.
    CONCATENATE IT_XML_COMP C_CADENA INTO IT_XML_COMP SEPARATED BY SPACE.

    IF I_IMPUESTOS_DR[] IS NOT INITIAL.
      CONCATENATE IT_XML_COMP '>' INTO IT_XML_COMP.
      SHIFT IT_XML_COMP BY 10 PLACES RIGHT.
      APPEND IT_XML_COMP. CLEAR IT_XML_COMP.

      CONCATENATE '<' V_NODO_PAGO ':ImpuestosDR>' INTO IT_XML_COMP.
      APPEND IT_XML_COMP. CLEAR IT_XML_COMP.

      READ TABLE I_IMPUESTOS_DR WITH KEY V_TIPO = 'RETEN'.
      IF SY-SUBRC EQ 0.

        CONCATENATE '<' V_NODO_PAGO ':RetencionesDR>' INTO IT_XML_COMP.
        APPEND IT_XML_COMP. CLEAR IT_XML_COMP.

********************************************************************************
***                     RETENCIONES DE LA FACTURA                            ***
********************************************************************************
        LOOP AT I_IMPUESTOS_DR WHERE V_TIPO = 'RETEN'.

          CLEAR: V_TASAOCUOTADR, V_TASAOCUOTADR_S, V_BASEDR, V_BASEDR_S,
                 V_IMPUESTODR, V_IMPUESTODR_S, V_IMPORTEDR, V_IMPORTEDR_S.

*** Cuando es pago total, es el valor completo y directo
*** se puede usar el de la factura
          IF I_PAGO10_DOCTORELACIONADO-PARC_O_TOTAL = 'T'.

            V_TASAOCUOTADR    = ABS( I_IMPUESTOS_DR-V_TASAOCUOTADR ).
            V_TASAOCUOTADR_S  = V_TASAOCUOTADR.
            CONDENSE V_TASAOCUOTADR_S NO-GAPS.

            V_BASEDR    = I_IMPUESTOS_DR-V_BASEDR.
            V_BASEDR_S  = V_BASEDR.
            CONDENSE V_BASEDR_S NO-GAPS.

            V_IMPUESTODR_S  = I_IMPUESTOS_DR-V_IMPUESTODR.
            CONDENSE V_IMPUESTODR_S NO-GAPS.

            V_IMPORTEDR = ABS( I_IMPUESTOS_DR-V_IMPORTEDR ).
            V_IMPORTEDR_S = V_IMPORTEDR.
            CONDENSE V_IMPORTEDR_S.
            V_RET_POS = V_RET_POS + V_IMPORTEDR.

*** Cuando es pago total, es el valor completo y directo
*** se debe de calcular en base al pago parcial, no es el importe de la factura
          ELSEIF I_PAGO10_DOCTORELACIONADO-PARC_O_TOTAL = 'P'.

          ENDIF.

          CONCATENATE '<' V_NODO_PAGO
                      ':RetencionDR BaseDR="'   V_BASEDR_S
                      '" ImpuestoDR="'          V_IMPUESTODR_S
                      '" TipoFactorDR="'        I_IMPUESTOS_DR-V_TIPOFACTORDR
                      '" TasaOCuotaDR="'        V_TASAOCUOTADR_S
                      '" ImporteDR="'           V_IMPORTEDR_S
                      '"/>'
           INTO IT_XML_COMP.APPEND IT_XML_COMP. CLEAR IT_XML_COMP.

        ENDLOOP.

        CONCATENATE '</' V_NODO_PAGO ':RetencionesDR>' INTO IT_XML_COMP.
        APPEND IT_XML_COMP. CLEAR IT_XML_COMP.
      ENDIF.

********************************************************************************
***                       TRASLADOS DE LA FACTURA                            ***
********************************************************************************
      READ TABLE I_IMPUESTOS_DR WITH KEY V_TIPO = 'TRASL'.

      IF V_FLAG_CI = 'X'.
        CLEAR V_CANT_IND.
        CLEAR: I_BSAD_INDIC.
        REFRESH: I_BSAD_INDIC.

        SELECT MWSKZ
               SGTXT
          FROM BSAD
          INTO TABLE I_BSAD_INDIC
          WHERE SGTXT = I_PAGO10_DOCTORELACIONADO-IDDOCUMENTO
          AND   MWSKZ NE SPACE.
        IF SY-SUBRC NE 0.
          SELECT MWSKZ
              SGTXT
            FROM BSID
            INTO TABLE I_BSAD_INDIC
            WHERE SGTXT = I_PAGO10_DOCTORELACIONADO-IDDOCUMENTO
            AND   MWSKZ NE SPACE.
        ENDIF.
        SORT I_BSAD_INDIC.
        DELETE ADJACENT DUPLICATES FROM I_BSAD_INDIC.
        CLEAR V_CANT_IND.
        DESCRIBE TABLE I_BSAD_INDIC LINES V_CANT_IND.

      ELSE.
        DESCRIBE TABLE I_IMPUESTOS_DR LINES V_CANT_IND.
      ENDIF.

      IF V_CANT_IND > 0. "SY-SUBRC EQ 0.

        IF V_CANT_IND = 1.

          CONCATENATE '<' V_NODO_PAGO ':TrasladosDR>' INTO IT_XML_COMP.
          APPEND IT_XML_COMP. CLEAR IT_XML_COMP.


          LOOP AT I_IMPUESTOS_DR WHERE V_TIPO = 'TRASL'.

            CLEAR:  V_TASAOCUOTADR, V_TASAOCUOTADR_S,
                    V_BASEDR, V_BASEDR_S,
                    V_IMPUESTODR, V_IMPUESTODR_S,
                    V_IMPORTEDR, V_IMPORTEDR_S.

*** Extrae el indicador de IVA
            READ TABLE I_PRCD_ELEMENTS_IMP WITH KEY KSCHL = 'MWST'.
            V_MWSK1 = I_PRCD_ELEMENTS_IMP-MWSK1.

            IF V_FLAG_CI = 'X'.
              V_MWSK1 = V_MWSK1_POS.
            ENDIF.
*** Tasa IVA 0%
            IF V_MWSK1 = 'A0' OR V_MWSK1 = 'B0' OR V_MWSK1 = 'Z0' OR V_MWSK1 = 'A3'.

              V_BASEDR    = I_PAGO10_DOCTORELACIONADO-IMPPAGADO.
              V_BASEDR_S  = V_BASEDR.
              CONDENSE V_BASEDR_S NO-GAPS.

              V_IMPORTEDR = '0.00'.
              V_IMPORTEDR_S = V_IMPORTEDR.
              CONDENSE V_IMPORTEDR_S.

            ELSEIF V_MWSK1 = 'A1' OR V_MWSK1 = 'B1' OR V_MWSK1 = 'A4'.
              PERFORM F_TRASL_A1_POS CHANGING V_BASEDR
                                              V_IMPORTEDR.
              V_BASEDR_S  = V_BASEDR.
              CONDENSE V_BASEDR_S NO-GAPS.

              V_IMPORTEDR_S = V_IMPORTEDR.
              CONDENSE V_IMPORTEDR_S.
            ENDIF.

            " *** TasaoCuota
            V_TASAOCUOTADR    = I_IMPUESTOS_DR-V_TASAOCUOTADR.
            V_TASAOCUOTADR_S  = V_TASAOCUOTADR.
            CONDENSE V_TASAOCUOTADR_S NO-GAPS.

            " *** ImpuestoDR (002)
            V_IMPUESTODR_S  = I_IMPUESTOS_DR-V_IMPUESTODR.
            CONDENSE V_IMPUESTODR_S NO-GAPS.


            CONCATENATE '<' V_NODO_PAGO
                        ':TrasladoDR BaseDR="'  V_BASEDR_S
                        '" ImpuestoDR="'        V_IMPUESTODR_S
                        '" TipoFactorDR="'      I_IMPUESTOS_DR-V_TIPOFACTORDR
                        '" TasaOCuotaDR="'      V_TASAOCUOTADR_S
                        '" ImporteDR="'         V_IMPORTEDR_S
                        '"/>'
             INTO IT_XML_COMP.APPEND IT_XML_COMP. CLEAR IT_XML_COMP.

          ENDLOOP.

          CONCATENATE '</' V_NODO_PAGO ':TrasladosDR>' INTO IT_XML_COMP.
          APPEND IT_XML_COMP. CLEAR IT_XML_COMP.


        ELSEIF V_CANT_IND = 2.

*** IVA MEZCLADO!!! ***








          CONCATENATE '<' V_NODO_PAGO ':TrasladosDR>' INTO IT_XML_COMP.
          APPEND IT_XML_COMP. CLEAR IT_XML_COMP.


          LOOP AT I_IMPUESTOS_DR WHERE V_TIPO = 'TRASL'.

            CLEAR:  V_TASAOCUOTADR, V_TASAOCUOTADR_S,
                    V_BASEDR, V_BASEDR_S,
                    V_IMPUESTODR, V_IMPUESTODR_S,
                    V_IMPORTEDR, V_IMPORTEDR_S.

            V_BASEDR    = I_IMPUESTOS_DR-V_BASEDR.
            V_BASEDR_S  = V_BASEDR.
            CONDENSE V_BASEDR_S NO-GAPS.

            V_IMPORTEDR = I_IMPUESTOS_DR-V_IMPORTEDR.
            IF V_IMPORTEDR = 0.
              V_IMPORTEDR = '0.00'.
            ENDIF.
            V_IMPORTEDR_S = V_IMPORTEDR.
            CONDENSE V_IMPORTEDR_S.


            " *** TasaoCuota
            V_TASAOCUOTADR    = I_IMPUESTOS_DR-V_TASAOCUOTADR.
            V_TASAOCUOTADR_S  = V_TASAOCUOTADR.
            CONDENSE V_TASAOCUOTADR_S NO-GAPS.

            " *** ImpuestoDR (002)
            V_IMPUESTODR_S  = I_IMPUESTOS_DR-V_IMPUESTODR.
            CONDENSE V_IMPUESTODR_S NO-GAPS.


            CONCATENATE '<' V_NODO_PAGO
                        ':TrasladoDR BaseDR="'  V_BASEDR_S
                        '" ImpuestoDR="'        V_IMPUESTODR_S
                        '" TipoFactorDR="'      I_IMPUESTOS_DR-V_TIPOFACTORDR
                        '" TasaOCuotaDR="'      V_TASAOCUOTADR_S
                        '" ImporteDR="'         V_IMPORTEDR_S
                        '"/>'
             INTO IT_XML_COMP.APPEND IT_XML_COMP. CLEAR IT_XML_COMP.

          ENDLOOP.

          CONCATENATE '</' V_NODO_PAGO ':TrasladosDR>' INTO IT_XML_COMP.
          APPEND IT_XML_COMP. CLEAR IT_XML_COMP.









        ENDIF.

      ENDIF.

      CONCATENATE '</' V_NODO_PAGO ':ImpuestosDR>' INTO IT_XML_COMP.
      APPEND IT_XML_COMP. CLEAR IT_XML_COMP.

      CONCATENATE '</' V_NODO_PAGO ':DoctoRelacionado>' INTO IT_XML_COMP.
      APPEND IT_XML_COMP. CLEAR IT_XML_COMP.

    ELSE.
      CONCATENATE IT_XML_COMP '/>' INTO IT_XML_COMP.
      SHIFT IT_XML_COMP BY 10 PLACES RIGHT.
      APPEND IT_XML_COMP. CLEAR IT_XML_COMP.
    ENDIF.
  ENDLOOP.

************************************************************************************************
***                        NODO DE IMPUESTOS DEL PAGO                                        ***
************************************************************************************************
  IF NOT I_IMPUESTOS_DR[] IS INITIAL.
    CONCATENATE '<' V_NODO_PAGO ':ImpuestosP>' INTO IT_XML_COMP.
    APPEND IT_XML_COMP. CLEAR IT_XML_COMP.

    IF V_TOTRETIVA > 0.
      DATA: V_TOTRETIVA_S TYPE STRING.
      CLEAR V_TOTRETIVA_S.
      V_TOTRETIVA_S = V_TOTRETIVA_TOT.
      CONDENSE V_TOTRETIVA_S NO-GAPS.

      CONCATENATE '<' V_NODO_PAGO ':RetencionesP>' INTO IT_XML_COMP.
      APPEND IT_XML_COMP. CLEAR IT_XML_COMP.

      CONCATENATE '<pago20:RetencionP ImpuestoP="002" ImporteP="' V_TOTRETIVA_S '"/>'
      INTO IT_XML_COMP. APPEND IT_XML_COMP. CLEAR IT_XML_COMP.

      CONCATENATE '</' V_NODO_PAGO ':RetencionesP>' INTO IT_XML_COMP.
      APPEND IT_XML_COMP. CLEAR IT_XML_COMP.
    ENDIF.

    IF V_TRASLBASE0_TOT > 0 OR V_TRASLBASE16_TOT > 0.
      CONCATENATE '<' V_NODO_PAGO ':TrasladosP>' INTO IT_XML_COMP.
      APPEND IT_XML_COMP. CLEAR IT_XML_COMP.
      DATA: V_TB TYPE STRING,
            V_TI TYPE STRING.

      IF V_TRASLBASE0_TOT > 0.
        CLEAR: V_TB, V_TI.
        V_TB = V_TRASLBASE0_TOT.
        V_TI = V_TRASLIVA0_TOT.
        CONDENSE: V_TB, V_TI NO-GAPS.

        CONCATENATE '<pago20:TrasladoP BaseP="'   V_TB
                    '" ImpuestoP="'               '002'
                    '" TipoFactorP="'             'Tasa'
                    '" TasaOCuotaP="'             '0.000000'
                    '" ImporteP="'                V_TI
                    '"/>' INTO IT_XML_COMP.
        APPEND IT_XML_COMP. CLEAR IT_XML_COMP.
      ENDIF.


      IF V_TRASLBASE16_TOT > 0.
        CLEAR: V_TB, V_TI.
        V_TB = V_TRASLBASE16_TOT.
        V_TI = V_TRASLIMP16_TOT.
        CONDENSE: V_TB, V_TI NO-GAPS.

        CONCATENATE '<pago20:TrasladoP BaseP="'   V_TB
                    '" ImpuestoP="'               '002'
                    '" TipoFactorP="'             'Tasa'
                    '" TasaOCuotaP="'             '0.160000'
                    '" ImporteP="'                V_TI
                    '"/>' INTO IT_XML_COMP.
        APPEND IT_XML_COMP. CLEAR IT_XML_COMP.
      ENDIF.

*<TrasladoP BaseP="1" ImpuestoP="1" TipoFactorP="1" TasaOCuotaP="1" ImporteP="1"/>
      CONCATENATE '</' V_NODO_PAGO ':TrasladosP>' INTO IT_XML_COMP.
      APPEND IT_XML_COMP. CLEAR IT_XML_COMP.
    ENDIF.

    CONCATENATE '</' V_NODO_PAGO ':ImpuestosP>' INTO IT_XML_COMP.
    APPEND IT_XML_COMP. CLEAR IT_XML_COMP.

  ENDIF.

*** Cierro Nodo PAGO
  CONCATENATE '</' V_NODO_PAGO ':Pago>' INTO  IT_XML_COMP.
  SHIFT IT_XML_COMP BY 6 PLACES RIGHT.
  APPEND IT_XML_COMP. CLEAR IT_XML_COMP.

*** Cierro nodo PAGOS
  CONCATENATE '</' V_NODO_PAGO ':Pagos>' INTO  IT_XML_COMP.
  SHIFT IT_XML_COMP BY 4 PLACES RIGHT.
  APPEND IT_XML_COMP. CLEAR IT_XML_COMP.


*** Reemplaza los valores de impuestos calculados con el valor
*** o con cero


*** Modifica los importes en caso de que la moneda no sea MXN
  V_TOTRETIVA   = V_TOTRETIVA   * I_PAGO10_PAGO-TIPOCAMBIOP.
  V_TRASLBASE0  = V_TRASLBASE0  * I_PAGO10_PAGO-TIPOCAMBIOP.
  V_TRASLIVA0   = V_TRASLIVA0   * I_PAGO10_PAGO-TIPOCAMBIOP.
  V_TRASLBASE16 = V_TRASLBASE16 * I_PAGO10_PAGO-TIPOCAMBIOP.
  V_TRASLIMP16  = V_TRASLIMP16  * I_PAGO10_PAGO-TIPOCAMBIOP.


  LOOP AT IT_XML_COMP.
    IF V_TOTRETIVA_TOT > 0.
      PERFORM F_REPLACE USING V_TOTRETIVA_TOT    'TOTRETIVA'.
    ELSE.
      REPLACE 'TotalRetencionesIVA="TOTRETIVA"' IN IT_XML_COMP WITH SPACE.
    ENDIF.

    IF V_TOTRETISR > 0.
      PERFORM F_REPLACE USING V_TOTRETISR    'TOTRETISR'.
    ELSE.
      REPLACE 'TotalRetencionesISR="TOTRETISR"' IN IT_XML_COMP WITH SPACE.
    ENDIF.

    IF V_TOTRETIEPS > 0.
      PERFORM F_REPLACE USING V_TOTRETIEPS   'TOTRETIEPS'.
    ELSE.
      REPLACE 'TotalRetencionesIEPS="TOTRETIEPS"' IN IT_XML_COMP WITH SPACE.
    ENDIF.

    IF V_TRASLBASE16 > 0.
      PERFORM F_REPLACE USING V_TRASLBASE16  'TRASLBASE16'.
    ELSE.
      REPLACE 'TotalTrasladosBaseIVA16="TRASLBASE16"' IN IT_XML_COMP WITH SPACE.
    ENDIF.

    IF V_TRASLIMP16 > 0.
      PERFORM F_REPLACE USING V_TRASLIMP16   'TRASLIMP16'.
    ELSE.
      REPLACE 'TotalTrasladosImpuestoIVA16="TRASLIMP16"' IN IT_XML_COMP WITH SPACE.
    ENDIF.

    IF V_TRASLBASE8 > 0.
      PERFORM F_REPLACE USING V_TRASLBASE8   'TRASLBASE8'.
    ELSE.
      REPLACE 'TotalTrasladosBaseIVA8="TRASLBASE8"' IN IT_XML_COMP WITH SPACE.
    ENDIF.

    IF V_TRASLIVA8 > 0.
      PERFORM F_REPLACE USING V_TRASLIVA8    'TRASLIVA8'.
    ELSE.
      REPLACE 'TotalTrasladosImpuestoIVA8="TRASLIVA8"' IN IT_XML_COMP WITH SPACE.
    ENDIF.

    IF V_TRASLBASE0 > 0.
      PERFORM F_REPLACE USING V_TRASLBASE0   'TRASLBASE0'.
    ELSE.
      REPLACE 'TotalTrasladosBaseIVA0="TRASLBASE0"' IN IT_XML_COMP WITH SPACE.
    ENDIF.

    IF V_TRASLIVA0 >= 0 AND V_TRASLBASE0 > 0.
      PERFORM F_REPLACE USING V_TRASLIVA0    'TRASLIVA0'.
    ELSE.
      REPLACE 'TotalTrasladosImpuestoIVA0="TRASLIVA0"' IN IT_XML_COMP WITH SPACE.
    ENDIF.

    IF V_TRASLEX > 0.
      PERFORM F_REPLACE USING V_TRASLEX      'TRASLEX'.
    ELSE.
      REPLACE 'TotalTrasladosBaseIVAExento="TRASLEX"' IN IT_XML_COMP WITH SPACE.
    ENDIF.

*    V_MONTOTOTPAG  = V_MONTOTOTPAG * I_PAGO10_PAGO-TIPOCAMBIOP.
    IF I_PAGO10_PAGO-TIPOCAMBIOP > 1 OR V_FLAG_USD = 'X'.
      V_MONTOTOTPAG  = V_TOTRETIVA +
                       V_TRASLBASE0 +
                       V_TRASLIVA0 +
                       V_TRASLBASE16 +
                       V_TRASLIMP16.
    ENDIF.
*if i_bseg_usd = 'X'.



    PERFORM F_REPLACE USING V_MONTOTOTPAG  'MONTOTOTPAG'.

  ENDLOOP.

  DATA: V_SECCION_COMPLEMENTO TYPE STRING.

  CLEAR V_SECCION_COMPLEMENTO.

  LOOP AT IT_XML_COMP.
    CONCATENATE V_SECCION_COMPLEMENTO IT_XML_COMP INTO V_SECCION_COMPLEMENTO SEPARATED BY SPACE.
  ENDLOOP.

  DATA: I_ZDT_REQ_COMPLE TYPE ZDT_S4_CFDITIMBRADO_REQ_COMPLE OCCURS 0 WITH HEADER LINE.
  CLEAR:   I_ZDT_REQ_COMPLE.
  REFRESH: I_ZDT_REQ_COMPLE.

  I_ZDT_REQ_COMPLE-TIPO_COMPLEMENTO = '12'.
  I_ZDT_REQ_COMPLE-XML = V_SECCION_COMPLEMENTO.
  CLEAR I_OUTPUT-COMPLEMENTOS.
  REFRESH I_OUTPUT-COMPLEMENTOS..
  APPEND I_ZDT_REQ_COMPLE TO I_OUTPUT-COMPLEMENTOS.

  PERFORM F_CADENA_XML USING 'TIPOCOMPLEMENTO' '2'.
  PERFORM F_CADENA_XML USING 'XML' V_SECCION_COMPLEMENTO.


*** Carga addenda Pac Simple **********************************************************************
  CLEAR V_JS_AD_PAC.
  PERFORM F_ADDENDA_PS.
  CLEAR I_OUTPUT-JSONADENDA_PACSIMPLE.

  IF IT_XML_PS[] IS NOT INITIAL.
    LOOP AT IT_XML_PS.
      CONCATENATE V_JS_AD_PAC IT_XML_PS INTO V_JS_AD_PAC SEPARATED BY SPACE.
    ENDLOOP.
    MOVE V_JS_AD_PAC TO I_OUTPUT-JSONADENDA_PACSIMPLE.
    PERFORM F_CADENA_XML_CHECK USING 'JSONADENDA_PACSIMPLE' V_JS_AD_PAC.
  ENDIF.



*******************************************************************************************
***                               Nodo para envio correo                                ***
*******************************************************************************************
  V_NODO = 'CORREO'.
  DATA: V_RESPONDERA TYPE STRING,
        V_ASUNTO     TYPE STRING,
        V_MENSAJE    TYPE STRING,
        V_PARA       TYPE STRING,
        V_CC         TYPE STRING,
        V_BCC        TYPE STRING,
        V_ARCHADJ    TYPE STRING.

  CLEAR: V_RESPONDERA, V_ASUNTO, V_MENSAJE, V_PARA, V_CC, V_BCC, V_ARCHADJ.

  DATA: I_KNVK TYPE KNVK OCCURS 0 WITH HEADER LINE.
  CLEAR:   I_KNVK.
  REFRESH: I_KNVK.

*** Obligatorios
  DATA: LT_ADR6 TYPE TABLE OF ADR6,
        LS_ADR6 TYPE ADR6.
  .
  SELECT *
    FROM ADR6
    INTO TABLE LT_ADR6
        WHERE ADDRNUMBER = I_KNA1-ADRNR.

  LOOP AT LT_ADR6 INTO LS_ADR6.
    IF V_PARA IS INITIAL.
      V_PARA = LS_ADR6-SMTP_ADDR.
    ELSE.
      CONCATENATE V_PARA ', ' LS_ADR6-SMTP_ADDR INTO V_PARA RESPECTING BLANKS.
    ENDIF.
  ENDLOOP.

  IF SY-SYSID = 'SPD' OR SY-SYSID = 'SPQ'.
*    IF V_PARA IS NOT INITIAL.
*      CONCATENATE V_PARA ', ddelvalle@scanda.com.mx,  veronica.almaguer@scanda.com.mx' INTO V_PARA RESPECTING BLANKS.
*    ELSE.
    V_PARA = 'ddelvalle@scanda.com.mx, veronica.almaguer@scanda.com.mx'.
*    ENDIF.
  ENDIF.



*** Asunto
  CONCATENATE 'Pago No. ' I_PAGO10_PAGO-DOC_PAGO INTO V_ASUNTO SEPARATED BY SPACE.
  DATA: V_BUTXT  LIKE T001-BUTXT,
        V_CUERPO TYPE STRING.
  CLEAR: V_BUTXT, V_CUERPO.

  SELECT SINGLE BUTXT
    FROM T001
    INTO V_BUTXT
    WHERE BUKRS = I_VBRK-BUKRS.

  CONCATENATE 'Por este medio le notificamos su Complemento de Pago de la empresa' V_BUTXT
    INTO V_CUERPO SEPARATED BY SPACE.


*** Mensaje en formato HTML
  CONCATENATE V_MENSAJE '<body aria-readonly="false">Estimado Cliente:<br />' INTO V_MENSAJE.

  CONCATENATE V_MENSAJE '<br />' INTO V_MENSAJE.
  CONCATENATE V_MENSAJE V_CUERPO '<br />' INTO V_MENSAJE.
  CONCATENATE V_MENSAJE '</body>' INTO V_MENSAJE.




  V_ASUNTO = 'Complemento de pagos Grupo Porres'.

*** Mensaje en formato HTML
*  V_MENSAJE = '<html>'.
*  CONCATENATE V_MENSAJE '<body aria-readonly="false">Estimado Cliente,<br />' INTO V_MENSAJE.
*
*  CONCATENATE V_MENSAJE '<br />' INTO V_MENSAJE.
*  CONCATENATE V_MENSAJE 'Adjunto a este mensaje encontrará un Comprobante Fiscal Digital por Internet emitido a su empresa.<br />' INTO V_MENSAJE.
*  CONCATENATE V_MENSAJE '<br />' INTO V_MENSAJE.
*  CONCATENATE V_MENSAJE 'Cualquier duda al respecto, favor de comunicarse al siguiente correo.com<br />' INTO V_MENSAJE.
*  CONCATENATE V_MENSAJE 'Este es un correo generado automáticamente, favor de no replicar al remitente.<br />' INTO V_MENSAJE.
*  CONCATENATE V_MENSAJE '<br />' INTO V_MENSAJE.
*  CONCATENATE V_MENSAJE 'Atentamente,<br />' INTO V_MENSAJE.
*
*  CONCATENATE V_MENSAJE '</body>' INTO V_MENSAJE.

  IF V_PARA IS NOT INITIAL.
  ENDIF.

  PERFORM F_OUTPUT USING V_NODO 'RESPONDER_A' V_RESPONDERA.
  PERFORM F_OUTPUT USING V_NODO 'ASUNTO'  V_ASUNTO.
  PERFORM F_OUTPUT USING V_NODO 'MENSAJE' V_MENSAJE.
  PERFORM F_OUTPUT USING V_NODO 'PARA' V_PARA.
  PERFORM F_OUTPUT USING V_NODO 'CC' V_CC.
  PERFORM F_OUTPUT USING V_NODO 'BCC' V_BCC.
  PERFORM F_OUTPUT USING V_NODO 'ARCHIVOADJUNTO' '0'.

  MOVE '</root>' TO IT_XML.
  APPEND IT_XML.
  CLEAR IT_XML.

***Mueve la tabla que armo para la estrucutra del proxy

  I_OUT-MT_S4_CFDITIMBRADO_REQ = I_OUTPUT.

  PERFORM F_DESCARGA_XML_PAGOS .

ENDFORM.                    " F_GENERA_XML


**&---------------------------------------------------------------------*
**&      Form  F_DESCARGA_XML_PAGOS
**&---------------------------------------------------------------------*
FORM F_DESCARGA_XML_PAGOS .

*** Descarga el archivo a una ruta del servidor por ejemplo....

  DATA: C_FILENAME(128)       TYPE C.
  CLEAR C_FILENAME.

*** Se reemplaza el caracter especial "&" por su secuencia de escape
  LOOP AT IT_XML.
    REPLACE ALL OCCURRENCES OF '&' IN IT_XML WITH '&amp;'.
    MODIFY IT_XML.
  ENDLOOP.


  IF SY-UNAME = 'DVALLE' OR SY-UNAME = 'VALMAGUER'.

    DATA: DATATAB    TYPE TABLE_OF_STRINGS.
    LOOP AT IT_XML.
      APPEND IT_XML TO DATATAB.
    ENDLOOP.

    DATA: LD_FILE    TYPE STRING.


    READ TABLE I_PAGO10_DOCTORELACIONADO INDEX 1.
    CONCATENATE 'C:/Pagos_Porres/Pago_'
                I_DATA_ALV_GLOBAL-BUKRS
                '_'
                I_PAGO10_DOCTORELACIONADO-DOC_PAGO
                '_'
                I_FECHAS-LOW+0(4)
                '.XML'
      INTO LD_FILE.

    DATA: V_DESC TYPE C.
    CLEAR V_DESC.


    IF SY-SYSID = 'SPD' OR SY-SYSID = 'SPQ' OR V_DESC = 'X'.

      CALL METHOD CL_GUI_FRONTEND_SERVICES=>GUI_DOWNLOAD
        EXPORTING
          FILENAME                = LD_FILE
          CODEPAGE                = '4110'
*codepage = v_encoding
        CHANGING
          DATA_TAB                = DATATAB
        EXCEPTIONS
          FILE_WRITE_ERROR        = 1
          NO_BATCH                = 2
          GUI_REFUSE_FILETRANSFER = 3
          INVALID_TYPE            = 4
          NO_AUTHORITY            = 5
          UNKNOWN_ERROR           = 6
          HEADER_NOT_ALLOWED      = 7
          SEPARATOR_NOT_ALLOWED   = 8
          FILESIZE_NOT_ALLOWED    = 9
          HEADER_TOO_LONG         = 10
          DP_ERROR_CREATE         = 11
          DP_ERROR_SEND           = 12
          DP_ERROR_WRITE          = 13
          UNKNOWN_DP_ERROR        = 14
          ACCESS_DENIED           = 15
          DP_OUT_OF_MEMORY        = 16
          DISK_FULL               = 17
          DP_TIMEOUT              = 18
          FILE_NOT_FOUND          = 19
          DATAPROVIDER_EXCEPTION  = 20
          CONTROL_FLUSH_ERROR     = 21
          NOT_SUPPORTED_BY_GUI    = 22
          ERROR_NO_GUI            = 23
          OTHERS                  = 24.
      IF SY-SUBRC = 0.
*    WRITE: /'File downloaded successfully !!!'.
      ENDIF.
    ENDIF.

  ENDIF.

ENDFORM.                    " F_DESCARGA_XML_PAGOS
*
*&---------------------------------------------------------------------*
*&      Form  F_output
*&---------------------------------------------------------------------*
FORM F_OUTPUT USING NODO ELEMENTO VALOR.

  DATA V_NODO_COMPLETO TYPE STRING.
  CLEAR V_NODO_COMPLETO.

  IF NODO IS NOT INITIAL.
    CONCATENATE NODO '-'  ELEMENTO INTO V_NODO_COMPLETO.
  ELSE.
    V_NODO_COMPLETO = ELEMENTO.
  ENDIF.

  ASSIGN I_OUTPUT TO <TABLA>.
  IF <TABLA> IS ASSIGNED.
    ASSIGN COMPONENT V_NODO_COMPLETO OF STRUCTURE <TABLA> TO <TABLA2>.
    <TABLA2> = VALOR.
  ENDIF.

  PERFORM F_CADENA_XML USING ELEMENTO VALOR.

ENDFORM.                    "f_output

*&---------------------------------------------------------------------*
*&      Form  F_CADENA_XML
*&---------------------------------------------------------------------*
FORM F_CADENA_XML USING TAG VALOR.

  DATA: V_TAG   TYPE C LENGTH 50,
        V_TAG_S TYPE STRING.
  CLEAR: V_TAG, V_TAG_S.



  CALL FUNCTION 'STRING_UPPER_LOWER_CASE'
    EXPORTING
      DELIMITER = '_'
      STRING1   = TAG
    IMPORTING
      STRING    = V_TAG.

  IF SY-SUBRC <> 0.
* Implement suitable error handling here
  ENDIF.
  V_TAG_S = V_TAG.
  CONCATENATE '<' V_TAG_S '>' VALOR '</' V_TAG_S '>' INTO IT_XML.
  APPEND IT_XML. CLEAR IT_XML.
*  CLEAR: C_CADENA, C_CADENA2, V_STR_TMP.

ENDFORM.                    "f_cadena_xml

*&---------------------------------------------------------------------*
*& Form f_proxy_timbrado
*&---------------------------------------------------------------------*
FORM F_PROXY_TIMBRADO .

  CLEAR: L_ERRORTEXT, L_ERRORCODE, ZMT_S4_CFDITIMBRADO_RESP.

*** Crea el objeto del proxy de la factura
  TRY.
      CREATE OBJECT L_PROXY_SERV_FACT.

    CATCH CX_AI_SYSTEM_FAULT INTO LR_AI_SYSTEM_FAULT.
      L_ERRORTEXT = LR_AI_SYSTEM_FAULT->ERRORTEXT.
      L_ERRORCODE = LR_AI_SYSTEM_FAULT->CODE.
  ENDTRY.

*** Manda llamar el proxy
  TRY.
      TRY.

          CALL METHOD L_PROXY_SERV_FACT->SI_OS_S4_CFDITIMBRADO
            EXPORTING
              OUTPUT = I_OUT
            IMPORTING
              INPUT  = ZMT_S4_CFDITIMBRADO_RESP.

        CATCH CX_AI_SYSTEM_FAULT INTO LR_AI_SYSTEM_FAULT.
          L_ERRORTEXT = LR_AI_SYSTEM_FAULT->ERRORTEXT.
          L_ERRORCODE = LR_AI_SYSTEM_FAULT->CODE.
      ENDTRY.
    CATCH CX_AI_SYSTEM_FAULT INTO LR_AI_SYSTEM_FAULT.
      L_ERRORTEXT = LR_AI_SYSTEM_FAULT->ERRORTEXT.
      L_ERRORCODE = LR_AI_SYSTEM_FAULT->CODE.

  ENDTRY.

  IF L_ERRORTEXT IS NOT INITIAL AND SY-UNAME EQ 'DVALLE'.

    DATA: P_RUTA_FAC TYPE STRING.

    CONCATENATE 'C:\temp\error_llamada_proxy'
                    '.html'
                    INTO P_RUTA_FAC.

    CLEAR: IT_XML_ERR.
    REFRESH: IT_XML_ERR.

    IT_XML_ERR = L_ERRORTEXT.
    APPEND IT_XML_ERR.

    CALL FUNCTION 'GUI_DOWNLOAD'
      EXPORTING
        FILENAME                = P_RUTA_FAC
        FILETYPE                = 'ASC'
        CODEPAGE                = '4110'
      TABLES
        DATA_TAB                = IT_XML_ERR
      EXCEPTIONS
        FILE_WRITE_ERROR        = 1
        NO_BATCH                = 2
        GUI_REFUSE_FILETRANSFER = 3
        INVALID_TYPE            = 4
        NO_AUTHORITY            = 5
        UNKNOWN_ERROR           = 6
        HEADER_NOT_ALLOWED      = 7
        SEPARATOR_NOT_ALLOWED   = 8
        FILESIZE_NOT_ALLOWED    = 9
        HEADER_TOO_LONG         = 10
        DP_ERROR_CREATE         = 11
        DP_ERROR_SEND           = 12
        DP_ERROR_WRITE          = 13
        UNKNOWN_DP_ERROR        = 14
        ACCESS_DENIED           = 15
        DP_OUT_OF_MEMORY        = 16
        DISK_FULL               = 17
        DP_TIMEOUT              = 18
        FILE_NOT_FOUND          = 19
        DATAPROVIDER_EXCEPTION  = 20
        CONTROL_FLUSH_ERROR     = 21
        OTHERS                  = 22.
    IF SY-SUBRC <> 0.

    ENDIF.

  ENDIF.

  IF ZMT_S4_CFDITIMBRADO_RESP-MT_S4_CFDITIMBRADO_RESP-MESSAGE IS NOT INITIAL.
    PERFORM F_PROCESA_RESPUESTA_TIMBRADO.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form f_procesa_respuesta_timbrado
*&---------------------------------------------------------------------*
FORM F_PROCESA_RESPUESTA_TIMBRADO .

**********************************************************
***          Se procesa la respuesta del PAC           ***
**********************************************************
  DATA: V_RESULT           TYPE STRING,
        V_CODE             TYPE STRING,
        V_MESSAGE          TYPE STRING,
        V_UUID             TYPE STRING,
        V_FECHATIMBRADO    TYPE STRING,
        V_NOCERTIFICADOSAT TYPE STRING,
        V_RFCPROVCERTIF    TYPE STRING,
        V_SELLOCFD         TYPE STRING,
        V_SELLOSAT         TYPE STRING,
        V_URLXML           TYPE STRING,
        V_URLPDF           TYPE STRING,
        V_URLQR            TYPE STRING,
        V_ARCHIVO          TYPE STRING,
        V_ESTATUS          TYPE STRING.

  CLEAR: V_RESULT, V_CODE, V_MESSAGE, V_UUID, V_URLXML, V_URLQR,
         V_URLPDF, V_ARCHIVO, V_ESTATUS.

  V_RESULT    = ZMT_S4_CFDITIMBRADO_RESP-MT_S4_CFDITIMBRADO_RESP-RESULT.
  V_CODE      = ZMT_S4_CFDITIMBRADO_RESP-MT_S4_CFDITIMBRADO_RESP-CODE.
  V_MESSAGE   = ZMT_S4_CFDITIMBRADO_RESP-MT_S4_CFDITIMBRADO_RESP-MESSAGE.
  V_UUID      = ZMT_S4_CFDITIMBRADO_RESP-MT_S4_CFDITIMBRADO_RESP-UUID.
  V_URLXML    = ZMT_S4_CFDITIMBRADO_RESP-MT_S4_CFDITIMBRADO_RESP-URL_XML.
  V_URLPDF    = ZMT_S4_CFDITIMBRADO_RESP-MT_S4_CFDITIMBRADO_RESP-URL_PDF.
  V_URLQR     = ZMT_S4_CFDITIMBRADO_RESP-MT_S4_CFDITIMBRADO_RESP-URL_QR.
  V_ARCHIVO   = ZMT_S4_CFDITIMBRADO_RESP-MT_S4_CFDITIMBRADO_RESP-ARCHIVO.
  V_ESTATUS   = ZMT_S4_CFDITIMBRADO_RESP-MT_S4_CFDITIMBRADO_RESP-ESTATUS.

  REPLACE ALL OCCURRENCES OF 'Leer_Comprobante, LN 600,'                  IN V_MESSAGE WITH SPACE.
  REPLACE ALL OCCURRENCES OF '[FactureHoy] Error al timbrar documento.'   IN V_MESSAGE WITH SPACE.
  REPLACE ALL OCCURRENCES OF 'Descripción: CFDI40105 -'                   IN V_MESSAGE WITH SPACE.
  REPLACE ALL OCCURRENCES OF 'Descripción: CFDI33125 -'                   IN V_MESSAGE WITH SPACE.
  REPLACE ALL OCCURRENCES OF 'Codigo de error: 105.'                      IN V_MESSAGE WITH SPACE.
  REPLACE ALL OCCURRENCES OF 'Codigo de error: 125.'                      IN V_MESSAGE WITH SPACE.
  REPLACE ALL OCCURRENCES OF 'Codigo de error: 144.'                      IN V_MESSAGE WITH SPACE.
  REPLACE ALL OCCURRENCES OF 'Descripción: CFDI40144'                     IN V_MESSAGE WITH SPACE.
  REPLACE ALL OCCURRENCES OF ' - '                                        IN V_MESSAGE WITH SPACE.
  REPLACE ALL OCCURRENCES OF 'Codigo de error: 301.'                      IN V_MESSAGE WITH SPACE.
  REPLACE ALL OCCURRENCES OF '[Edicom]'                                   IN V_MESSAGE WITH SPACE.
  REPLACE ALL OCCURRENCES OF 'Error al timbrar documento.'                          IN V_MESSAGE WITH 'Error:'.
  REPLACE ALL OCCURRENCES OF ' Ex: com.edicom.ediwinws.service.cfdi.CFDiException:' IN V_MESSAGE WITH SPACE.
  REPLACE ALL OCCURRENCES OF ' CRP20248:'                                           IN V_MESSAGE WITH SPACE.

  DO 10 TIMES.
    SHIFT V_MESSAGE LEFT DELETING LEADING SPACE.
  ENDDO.

  IF V_UUID = '00000000-0000-0000-0000-000000000000'.
    CLEAR V_UUID.
  ENDIF.

  CLEAR:   I_ZALV_COMP_PAGO.
  REFRESH: I_ZALV_COMP_PAGO.

  SELECT *
    FROM ZALV_COMP_PAGO
    INTO TABLE I_ZALV_COMP_PAGO
    WHERE BUKRS = S_BUKRS-LOW
    AND   KUNNR = I_COMPROBANTE-KUNNR
    AND   DOC_PAGO = I_COMPROBANTE-DOC_PAGO.

  LOOP AT I_ZALV_COMP_PAGO.
    I_ZALV_COMP_PAGO-RESULT_PAC  = V_RESULT.
    I_ZALV_COMP_PAGO-CODE        = V_CODE.
    I_ZALV_COMP_PAGO-MESSAGE     = V_MESSAGE.
    I_ZALV_COMP_PAGO-COMENTARIO  = V_MESSAGE.
    I_ZALV_COMP_PAGO-UUID        = V_UUID.
    I_ZALV_COMP_PAGO-ARCHIVOXML  = V_URLXML.
    I_ZALV_COMP_PAGO-ARCHIVOPDF  = V_URLPDF.
    I_ZALV_COMP_PAGO-ARCHIVO     = V_ARCHIVO.
    I_ZALV_COMP_PAGO-ESTATUS     = V_ESTATUS.
    IF V_UUID = '00000000-0000-0000-0000-000000000000' OR
       V_UUID IS INITIAL.
      I_ZALV_COMP_PAGO-SEMAFORO    = 'E'.
    ELSEIF V_UUID IS NOT INITIAL.
      I_ZALV_COMP_PAGO-SEMAFORO    = 'S'.
    ENDIF.
    MODIFY I_ZALV_COMP_PAGO.
  ENDLOOP.
  LOOP AT I_ZALV_COMP_PAGO.
    MOVE-CORRESPONDING I_ZALV_COMP_PAGO
      TO I_ZALV_COMP_PAGO_REF.
    APPEND I_ZALV_COMP_PAGO_REF.
  ENDLOOP.


ENDFORM.

*&---------------------------------------------------------------------*
*& Form f_impuestos_concepto
*&---------------------------------------------------------------------*
FORM F_IMPUESTOS_CONCEPTO .

*** Extrae el numero de condicion para la factura
  CLEAR V_KNUMV_IMP.

  SELECT SINGLE KNUMV
    FROM VBRK
    INTO V_KNUMV_IMP
    WHERE VBELN = I_PAGO10_DOCTORELACIONADO-FACTURA.


  IF V_KNUMV_IMP IS INITIAL.

    SELECT SINGLE MWSKZ
      FROM BSAD
      INTO V_MWSK1_POS
      WHERE SGTXT = I_PAGO10_DOCTORELACIONADO-IDDOCUMENTO
      AND   MWSKZ NE SPACE.

    IF V_MWSK1_POS IS INITIAL.
      SELECT SINGLE MWSKZ
      FROM BSID
      INTO V_MWSK1_POS
      WHERE SGTXT = I_PAGO10_DOCTORELACIONADO-IDDOCUMENTO
      AND   MWSKZ NE SPACE.
    ENDIF.

    IF V_MWSK1_POS IS NOT INITIAL.
      V_FLAG_CI = 'X'.
    ENDIF.

  ENDIF.

*** Para facturas normales **********************************************************************
  IF V_FLAG_CI IS INITIAL.
*** Extrae todas las clases de condicion para la factura
    CLEAR:   I_PRCD_ELEMENTS_IMP.
    REFRESH: I_PRCD_ELEMENTS_IMP.

    SELECT *
      FROM PRCD_ELEMENTS
      INTO TABLE I_PRCD_ELEMENTS_IMP
      WHERE KNUMV = V_KNUMV_IMP.

*** Extrae las clases de condicion dadas de alta para impuestos
    CLEAR:   I_Z33_IMPUESTOS.
    REFRESH: I_Z33_IMPUESTOS.

    SELECT *
      FROM Z33_IMPUESTOS
      INTO TABLE I_Z33_IMPUESTOS.

    DELETE I_Z33_IMPUESTOS WHERE Z33IMPUESTO = '003'.

*** Tabla para almacenar los impuestos con los nodos del SAT
    CLEAR:   I_IMPUESTOS_DR.
    REFRESH: I_IMPUESTOS_DR.

*** Para cada clase de condicion registrada en el cluster
    LOOP AT I_Z33_IMPUESTOS.
      CLEAR: I_PRCD_ELEMENTS_IMP_BIS.
      REFRESH: I_PRCD_ELEMENTS_IMP_BIS.

      LOOP AT I_PRCD_ELEMENTS_IMP WHERE KSCHL = I_Z33_IMPUESTOS-KSCHL.
        I_PRCD_ELEMENTS_IMP_BIS = I_PRCD_ELEMENTS_IMP.
        APPEND I_PRCD_ELEMENTS_IMP_BIS.
      ENDLOOP.

      CLEAR: I_IMPUESTOS_DR_COL.
      REFRESH I_IMPUESTOS_DR_COL.

      LOOP AT I_PRCD_ELEMENTS_IMP_BIS WHERE KSCHL = I_Z33_IMPUESTOS-KSCHL.
        I_IMPUESTOS_DR_COL-V_TIPO         =   I_Z33_IMPUESTOS-Z33USOIMP.
        ADD I_PRCD_ELEMENTS_IMP_BIS-KAWRT     TO  I_IMPUESTOS_DR_COL-V_BASEDR.
        I_IMPUESTOS_DR_COL-V_IMPUESTODR   =   I_Z33_IMPUESTOS-Z33IMPUESTO.
        I_IMPUESTOS_DR_COL-V_TIPOFACTORDR =   I_Z33_IMPUESTOS-Z33FACTOR.
        I_IMPUESTOS_DR_COL-V_TASAOCUOTADR =   I_PRCD_ELEMENTS_IMP_BIS-KBETR / 100.
        ADD I_PRCD_ELEMENTS_IMP_BIS-KWERT     TO  I_IMPUESTOS_DR_COL-V_IMPORTEDR.
        COLLECT I_IMPUESTOS_DR_COL.
        CLEAR I_IMPUESTOS_DR_COL.
      ENDLOOP.

      LOOP AT I_IMPUESTOS_DR_COL.
        MOVE-CORRESPONDING I_IMPUESTOS_DR_COL TO I_IMPUESTOS_DR.
        I_IMPUESTOS_DR-V_IMPUESTODR   =   I_Z33_IMPUESTOS-Z33IMPUESTO.
        I_IMPUESTOS_DR-V_TIPOFACTORDR =   I_Z33_IMPUESTOS-Z33FACTOR.
        APPEND I_IMPUESTOS_DR.
        CLEAR I_IMPUESTOS_DR.
      ENDLOOP.

    ENDLOOP.
*** Para facturas de CI **********************************************************************
  ELSE.

*** Extrae las clases de condicion dadas de alta para impuestos
    CLEAR:   I_Z33_IMPUESTOS.
    REFRESH: I_Z33_IMPUESTOS.

    SELECT *
      FROM Z33_IMPUESTOS
      INTO TABLE I_Z33_IMPUESTOS
      WHERE KSCHL = 'MWST'.

*** Tabla para almacenar los impuestos con los nodos del SAT
    CLEAR:   I_IMPUESTOS_DR.
    REFRESH: I_IMPUESTOS_DR.

*** Para cada clase de condicion registrada en el cluster
    LOOP AT I_Z33_IMPUESTOS.

      CLEAR: I_IMPUESTOS_DR_COL.
      REFRESH I_IMPUESTOS_DR_COL.

      IF V_MWSK1_POS = 'A1'.

        CLEAR: V_TRASLBASE16_CI, V_TRASLIMP16_CI.
        PERFORM F_TRASL_A1_CI USING 'A1'
                                   I_PAGO10_DOCTORELACIONADO-IMPPAGADO
                          CHANGING V_TRASLBASE16_CI
                                   V_TRASLIMP16_CI.
      ELSEIF V_MWSK1_POS = 'A0'.
        V_TRASLBASE16_CI = I_PAGO10_DOCTORELACIONADO-IMPPAGADO.
        V_TRASLIMP16_CI = 0.
      ENDIF.

      I_IMPUESTOS_DR_COL-V_TIPO         =   I_Z33_IMPUESTOS-Z33USOIMP.
      I_IMPUESTOS_DR_COL-V_BASEDR = V_TRASLBASE16_CI.
      I_IMPUESTOS_DR_COL-V_IMPUESTODR   =   I_Z33_IMPUESTOS-Z33IMPUESTO.
      I_IMPUESTOS_DR_COL-V_TIPOFACTORDR =   I_Z33_IMPUESTOS-Z33FACTOR.
      IF V_MWSK1_POS = 'A1'.
        I_IMPUESTOS_DR_COL-V_TASAOCUOTADR =   '0.160000'.
      ELSEIF V_MWSK1_POS = 'A0'.
        I_IMPUESTOS_DR_COL-V_TASAOCUOTADR =   '0.000000'.
      ENDIF.
      I_IMPUESTOS_DR_COL-V_IMPORTEDR = V_TRASLIMP16_CI.

      COLLECT I_IMPUESTOS_DR_COL.
      CLEAR I_IMPUESTOS_DR_COL.

      LOOP AT I_IMPUESTOS_DR_COL.
        MOVE-CORRESPONDING I_IMPUESTOS_DR_COL TO I_IMPUESTOS_DR.
        I_IMPUESTOS_DR-V_IMPUESTODR   =   I_Z33_IMPUESTOS-Z33IMPUESTO.
        I_IMPUESTOS_DR-V_TIPOFACTORDR =   I_Z33_IMPUESTOS-Z33FACTOR.
        APPEND I_IMPUESTOS_DR.
        CLEAR I_IMPUESTOS_DR.
      ENDLOOP.

    ENDLOOP.

  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form f_Replace
*&---------------------------------------------------------------------*
FORM F_REPLACE  USING  VALOR
                       STRING.

  DATA: V_STRING_REPLACE TYPE STRING.
  CLEAR V_STRING_REPLACE.
  IF VALOR > 0.
    V_STRING_REPLACE = VALOR.
  ELSE.
    V_STRING_REPLACE = '0.00'.
  ENDIF.
  CONDENSE V_STRING_REPLACE NO-GAPS.
  REPLACE STRING WITH V_STRING_REPLACE INTO IT_XML_COMP.
  MODIFY IT_XML_COMP.

ENDFORM.


*&---------------------------------------------------------------------*
*& Form f_trasl_a1
*&---------------------------------------------------------------------*
FORM F_TRASL_A1 USING V_IND
                      V_MONTO
             CHANGING V_TRASLBASE16
                      V_TRASLIMP16.


  DATA: V_BASE_IMP TYPE NETWR.
  CLEAR V_BASE_IMP.
  V_BASE_IMP = ( I_PAGO10_DOCTORELACIONADO-IMPPAGADO + V_RETEN_DOC ).

*** Base para el calculo del iva
  V_TRASLBASE16   = V_TRASLBASE16 + ( V_BASE_IMP / '1.16' ).. "(KAWRT

*** Iva calculado
  V_TRASLIMP16    = V_TRASLIMP16 +
   ( V_BASE_IMP - ( V_BASE_IMP / '1.16' ) ). "1600.   "(WMWST

ENDFORM.


*&---------------------------------------------------------------------*
*& Form f_trasl_a1
*&---------------------------------------------------------------------*
FORM F_TRASL_A1_CI USING V_IND
                      V_MONTO
             CHANGING V_TRASLBASE16_CI
                      V_TRASLIMP16_CI.


  DATA: V_BASE_IMP_CI TYPE NETWR.
  CLEAR V_BASE_IMP_CI.
  V_BASE_IMP_CI = ( I_PAGO10_DOCTORELACIONADO-IMPPAGADO + V_RETEN_DOC ).

*** Base para el calculo del iva
  V_TRASLBASE16_CI   = V_TRASLBASE16_CI + ( V_BASE_IMP_CI / '1.16' ).. "(KAWRT

*** Iva calculado
  V_TRASLIMP16_CI    = V_TRASLIMP16_CI +
   ( V_BASE_IMP_CI - ( V_BASE_IMP_CI / '1.16' ) ). "1600.   "(WMWST

ENDFORM.

*&---------------------------------------------------------------------*
*& Form f_trasl_a1_mezc
*&---------------------------------------------------------------------*
FORM F_TRASL_A1_MEZC USING V_IND
                      V_MONTO
             CHANGING V_TRASLBASE16
                      V_TRASLIMP16.


  DATA: V_BASE_IMP TYPE NETWR.
  CLEAR V_BASE_IMP.
  V_BASE_IMP = V_MONTO.
  "( I_PAGO10_DOCTORELACIONADO-IMPPAGADO + V_RETEN_DOC ).

*** Base para el calculo del iva
  V_TRASLBASE16   = I_PRCD_ELEMENTS-KAWRT.  "V_TRASLBASE16 + ( V_BASE_IMP / '1.16' ).. "(KAWRT

*** Iva calculado
  V_TRASLIMP16    = I_PRCD_ELEMENTS-KWERT.
*  V_TRASLIMP16 +
*   ( V_BASE_IMP - ( V_BASE_IMP / '1.16' ) ). "1600.   "(WMWST

ENDFORM.

*&---------------------------------------------------------------------*
*& Form f_reten_a1
*&---------------------------------------------------------------------*
FORM F_RETEN_A1 USING V_IND
                      V_MONTO
             CHANGING V_TOTRETIVA.

  IF V_IND = 'A0' OR V_IND = 'Z0' OR V_IND = 'A3'.
    V_TOTRETIVA = 0.
  ELSEIF V_IND = 'A1' OR V_IND = 'A4'.
    V_TOTRETIVA = V_MONTO * '0.16'.
  ENDIF.



ENDFORM.

*&---------------------------------------------------------------------*
*& Form f_trasl_a1
*&---------------------------------------------------------------------*
FORM F_TRASL_A1_POS  CHANGING V_TRASLBASE16_POS
                              V_TRASLIMP16_POS.

*      READ TABLE I_T_MWDAT INDEX 1.

  DATA: V_BASE_IMP TYPE NETWR.
  CLEAR V_BASE_IMP.
  V_BASE_IMP = ( I_PAGO10_DOCTORELACIONADO-IMPPAGADO + V_RET_POS ).

*** Base para el calculo del iva
  V_TRASLBASE16_POS   = V_TRASLBASE16_POS + ( V_BASE_IMP / '1.16' ).. "(KAWRT

*** Iva calculado
  V_TRASLIMP16_POS    = V_TRASLIMP16_POS +
   ( V_BASE_IMP - ( V_BASE_IMP / '1.16' ) ). "1600.   "(WMWST

ENDFORM.




*&---------------------------------------------------------------------*
*& Form F_ADDENDA_PS
*&---------------------------------------------------------------------*
FORM F_ADDENDA_PS.

  CLEAR:   IT_XML_PS.
  REFRESH: IT_XML_PS.

  DATA: V_ENCABEZADO  TYPE STRING,
        V_LEYENDA     TYPE STRING,
        V_PEDIDO      TYPE STRING,
        V_DOCUMENTO   TYPE STRING,
        V_COMENTARIOS TYPE STRING,
        V_VENDEDOR    TYPE STRING,
        V_ADICIONAL1  TYPE STRING,
        V_ADICIONAL2  TYPE STRING,
        V_ADICIONAL3  TYPE STRING,
        V_ADICIONAL4  TYPE STRING,
        V_ADICIONAL5  TYPE STRING,
        V_ADRNR       LIKE TVBUR-ADRNR,
        I_ADRC        TYPE ADRC OCCURS 0 WITH HEADER LINE.


*** Schema Pac Simple **********************************************************************
  MOVE '<PS:PACSimple xmlns:PS="http://miportal.xamai.com.mx/" EnXML="N">' TO IT_XML_PS.
  APPEND IT_XML_PS.
  CLEAR IT_XML_PS.


*** Leyenda **********************************************************************
*** Importe con letra ************************************************************
  DATA: IT_SPELL   LIKE SPELL OCCURS 0 WITH HEADER LINE,
        V_WORD     LIKE SPELL-WORD,
        V_CURRENCY LIKE SY-WAERS.

  V_CURRENCY = I_PAGO10_PAGO-MONEDAP.

  CALL FUNCTION 'SPELL_AMOUNT'
    EXPORTING
      AMOUNT    = I_PAGO10_PAGO-MONTO
      CURRENCY  = V_CURRENCY
      FILLER    = SPACE
      LANGUAGE  = 'S'
    IMPORTING
      IN_WORDS  = IT_SPELL
    EXCEPTIONS
      NOT_FOUND = 1
      TOO_LARGE = 2
      OTHERS    = 3.

  IF SY-SUBRC EQ 0.
    IF  I_PAGO10_PAGO-MONEDAP = 'MXN'.
      CONCATENATE IT_SPELL-WORD
                  'PESOS'
                  IT_SPELL-DECIMAL(2)
             INTO V_WORD SEPARATED BY SPACE.
      CONCATENATE V_WORD
                  '/100 MN'
             INTO V_WORD.
    ELSEIF I_PAGO10_PAGO-MONEDAP = 'USD'.
      CONCATENATE IT_SPELL-WORD
                  'DOLARES'
                  IT_SPELL-DECIMAL(2)
             INTO V_WORD SEPARATED BY SPACE.
      CONCATENATE V_WORD
                  '/100 USD'
             INTO V_WORD.
    ELSEIF I_PAGO10_PAGO-MONEDAP = 'EUR'.
      CONCATENATE IT_SPELL-WORD
                  'EUROS'
                  IT_SPELL-DECIMAL(2)
             INTO V_WORD SEPARATED BY SPACE.
      CONCATENATE V_WORD
                  '/100 USD'
             INTO V_WORD.
    ENDIF.
  ENDIF.

*** Pedido **********************************************************************
  V_PEDIDO = ''.

*** Documento *******************************************************************
  V_DOCUMENTO = ''.

*** Comentarios *****************************************************************
  DATA: V_ID     LIKE  THEAD-TDID,
        V_SPRAS  LIKE SY-LANGU,
        V_NAME   LIKE  THEAD-TDNAME,
        V_OBJECT LIKE  THEAD-TDOBJECT,
        I_LINES  TYPE TLINE          OCCURS 0 WITH HEADER LINE.

  CLEAR: V_ID, V_SPRAS, V_NAME, V_OBJECT, I_LINES.
  REFRESH: I_LINES.
*
*  READ TABLE LT_XVBRP INDEX 1 INTO WA_LT_XVBRP.
*  V_NAME = WA_LT_XVBRP-AUBEL.
*
*  V_ID        = 'ZS03'.
*  V_SPRAS     = SY-LANGU.
*  V_OBJECT    = 'VBBK'.
*
*  CALL FUNCTION 'READ_TEXT'
*    EXPORTING
*      ID       = V_ID
*      LANGUAGE = V_SPRAS
*      NAME     = V_NAME
*      OBJECT   = V_OBJECT
*    TABLES
*      LINES    = I_LINES
*    EXCEPTIONS
*      NO_INIT  = 1
*      NO_SAVE  = 2
*      OTHERS   = 3.
*
*  LOOP AT I_LINES.
*    CONCATENATE V_COMENTARIOS I_LINES-TDLINE
*      INTO V_COMENTARIOS SEPARATED BY SPACE.
*  ENDLOOP.
*
*  REPLACE ALL OCCURRENCES OF '"' IN V_COMENTARIOS WITH '&quot;'.
*  REPLACE ALL OCCURRENCES OF '''' IN V_COMENTARIOS WITH '&apos;'.
*  REPLACE ALL OCCURRENCES OF '<' IN V_COMENTARIOS WITH    '&lt;'.
*  REPLACE ALL OCCURRENCES OF '>' IN V_COMENTARIOS WITH    '&gt;'.
*  REPLACE ALL OCCURRENCES OF '&' IN V_COMENTARIOS WITH    '&amp;'.
*
  V_COMENTARIOS = ''.

*** Vendedor ********************************************************************
  V_VENDEDOR = ''.

*** Adicional1 ******************************************************************
  V_ADICIONAL1  = ''."V_EMISOR_REGIMEN.

*** Adicional2 ******************************************************************
  V_ADICIONAL2 = ''."V_RECEPTOR_REGIMEN.

*** Adicional3 / Operador **********************************************************************
  CLEAR: V_ID, V_SPRAS, V_NAME, V_OBJECT, I_LINES, V_ADICIONAL3.
  REFRESH: I_LINES.

*  READ TABLE LT_XVBRP INDEX 1 INTO WA_LT_XVBRP.
*  V_NAME = WA_LT_XVBRP-AUBEL.
*
*  V_ID        = 'ZS01'.
*  V_SPRAS     = SY-LANGU.
*  V_OBJECT    = 'VBBK'.
*
*  CALL FUNCTION 'READ_TEXT'
*    EXPORTING
*      ID       = V_ID
*      LANGUAGE = V_SPRAS
*      NAME     = V_NAME
*      OBJECT   = V_OBJECT
*    TABLES
*      LINES    = I_LINES
*    EXCEPTIONS
*      NO_INIT  = 1
*      NO_SAVE  = 2
*      OTHERS   = 3.
*
*  LOOP AT I_LINES.
*    CONCATENATE V_ADICIONAL3 I_LINES-TDLINE
*      INTO V_ADICIONAL3 SEPARATED BY SPACE.
*  ENDLOOP.
*

*** Adicional4 / Placas **********************************************************************
  CLEAR: V_ID, V_SPRAS, V_NAME, V_OBJECT, I_LINES, V_ADICIONAL4.
  REFRESH: I_LINES.
*
*  READ TABLE LT_XVBRP INDEX 1 INTO WA_LT_XVBRP.
*  V_NAME = WA_LT_XVBRP-AUBEL.
*
*  V_ID        = 'ZS09'.
*  V_SPRAS     = SY-LANGU.
*  V_OBJECT    = 'VBBK'.
*
*  CALL FUNCTION 'READ_TEXT'
*    EXPORTING
*      ID       = V_ID
*      LANGUAGE = V_SPRAS
*      NAME     = V_NAME
*      OBJECT   = V_OBJECT
*    TABLES
*      LINES    = I_LINES
*    EXCEPTIONS
*      NO_INIT  = 1
*      NO_SAVE  = 2
*      OTHERS   = 3.
*
*  LOOP AT I_LINES.
*    CONCATENATE V_ADICIONAL4 I_LINES-TDLINE
*      INTO V_ADICIONAL4 SEPARATED BY SPACE.
*  ENDLOOP.

*** Adicional5 / Entrega **********************************************************************
  CLEAR: V_ADICIONAL4.
  V_ADICIONAL4 = ''."WA_LT_XVBRP-VGBEL.


  CONCATENATE '<PS:Encabezado Leyenda="'
              V_LEYENDA
              '" Pedido="'
              V_PEDIDO
              '" Documento="'
              V_DOCUMENTO
              '" Comentarios="'
              V_COMENTARIOS
              '" Vendedor="'
              V_VENDEDOR
              '" Adicional1="'
              V_ADICIONAL1
              '" Adicional2="'
              V_ADICIONAL2
              '" Adicional3="'
              V_ADICIONAL3
              '" Adicional4="'
              V_ADICIONAL4
              '" Adicional5="'
              V_ADICIONAL5
              '"/>'
              INTO V_ENCABEZADO.

  MOVE V_ENCABEZADO TO IT_XML_PS.
  SHIFT IT_XML_PS BY 2 PLACES RIGHT.
  APPEND IT_XML_PS.
  CLEAR IT_XML_PS.

*** Direccion Emisor **********************************************************************
  CLEAR:   V_ADRNR, I_ADRC.
  REFRESH: I_ADRC.

*  READ TABLE LT_XVBRP INTO WA_LT_XVBRP INDEX 1.

  SELECT SINGLE ADRNR
    FROM T001
    INTO V_ADRNR
    WHERE BUKRS = S_BUKRS-LOW.

  SELECT *
    FROM ADRC
    INTO TABLE I_ADRC
    WHERE ADDRNUMBER = V_ADRNR.

  READ TABLE I_ADRC INDEX 1.
  DATA: V_DIRECCION_EMISOR TYPE STRING.
  CLEAR V_DIRECCION_EMISOR.
  CONCATENATE I_ADRC-STREET
              SPACE
              I_ADRC-CITY1
              ', '
              I_ADRC-REGION
              ', MÉXICO, CP '
              I_ADRC-POST_CODE1
              ', Telefono: '
              I_ADRC-TEL_NUMBER
        INTO V_DIRECCION_EMISOR RESPECTING BLANKS.

  MOVE '<PS:Emisor' TO IT_XML_PS.
  CONCATENATE IT_XML_PS ' CalleEmisor="'         INTO IT_XML_PS RESPECTING BLANKS.
  CONCATENATE IT_XML_PS V_DIRECCION_EMISOR '"/>' INTO IT_XML_PS.
*  CONCATENATE IT_XML_PS ' CodigoPostal="' INTO IT_XML_PS RESPECTING BLANKS. CONCATENATE IT_XML_PS I_ADRC-POST_CODE1 '"' INTO IT_XML_PS.
*  CONCATENATE IT_XML_PS ' Colonia="'      INTO IT_XML_PS RESPECTING BLANKS. CONCATENATE IT_XML_PS I_ADRC-CITY1 '"' INTO IT_XML_PS.
*  CONCATENATE IT_XML_PS ' Estado="'       INTO IT_XML_PS RESPECTING BLANKS. CONCATENATE IT_XML_PS I_ADRC-REGION '"' INTO IT_XML_PS.
*  CONCATENATE IT_XML_PS ' Municipio="'    INTO IT_XML_PS RESPECTING BLANKS. CONCATENATE IT_XML_PS I_ADRC-CITY2 '"' INTO IT_XML_PS.
*  CONCATENATE IT_XML_PS ' NumInterior="'  INTO IT_XML_PS RESPECTING BLANKS. CONCATENATE IT_XML_PS I_ADRC-HOUSE_NUM2 '"' INTO IT_XML_PS.
*  CONCATENATE IT_XML_PS ' NumExterior="'  INTO IT_XML_PS RESPECTING BLANKS. CONCATENATE IT_XML_PS I_ADRC-HOUSE_NUM1 '"' INTO IT_XML_PS.
*  CONCATENATE IT_XML_PS ' Pais="'         INTO IT_XML_PS RESPECTING BLANKS. CONCATENATE IT_XML_PS I_ADRC-COUNTRY '"' INTO IT_XML_PS.
*  CONCATENATE IT_XML_PS ' Localidad="'    INTO IT_XML_PS RESPECTING BLANKS. CONCATENATE IT_XML_PS I_ADRC-HOME_CITY '"/>' INTO IT_XML_PS.
  SHIFT IT_XML_PS BY 2 PLACES RIGHT. APPEND IT_XML_PS. CLEAR IT_XML_PS.

*** Direcion Receptor **********************************************************************
  DATA: I_ADRC_REC   TYPE ADRC OCCURS 0 WITH HEADER LINE,
        V_ADRNR_REC  TYPE ADRNR,
        V_DIR_FISICA TYPE STRING.

  CLEAR: I_ADRC_REC,
         V_ADRNR_REC,
         V_DIR_FISICA.

  SELECT SINGLE ADRNR
    FROM KNA1
    INTO V_ADRNR_REC
    WHERE KUNNR = I_KNA1-KUNNR.

  SELECT *
      FROM ADRC
      INTO TABLE I_ADRC_REC
      WHERE ADDRNUMBER = V_ADRNR_REC.

  READ TABLE I_ADRC_REC INDEX 1.

  CONCATENATE I_ADRC_REC-STREET I_ADRC_REC-HOUSE_NUM1 I_ADRC_REC-HOUSE_NUM2
  INTO V_DIR_FISICA SEPARATED BY SPACE.


  DATA: V_KUNNR_ID_RES   TYPE KUNNR.
  DATA: I_ADRC_RES TYPE ADRC OCCURS 0 WITH HEADER LINE.

*** DireccionEntrega interlocutor WE
*  CLEAR: V_STR_TMP, V_KUNNR_ID_RES, V_ADRNR.
*
*  SELECT SINGLE KUNNR
*      FROM VBPA
*      INTO V_KUNNR_ID_RES
*      WHERE VBELN = I_VBRK_E-VBELN
*      AND   PARVW = 'WE'.
*
*  SELECT SINGLE ADRNR
*    FROM KNA1
*    INTO V_ADRNR
*    WHERE KUNNR = V_KUNNR_ID_RES.
*
*  SELECT *
*  FROM ADRC
*  INTO TABLE I_ADRC_RES
*  WHERE ADDRNUMBER = V_ADRNR.
*  READ TABLE I_ADRC_RES INDEX 1.
*
*  CONCATENATE I_ADRC_RES-NAME1 ', ' I_ADRC_RES-STREET I_ADRC_RES-HOUSE_NUM1 I_ADRC_RES-HOUSE_NUM2 ', ' I_ADRC_RES-CITY1 ', ' I_ADRC_RES-CITY2 ', '
*              I_ADRC_RES-POST_CODE1 ', ' I_ADRC_RES-REGION I_ADRC_RES-COUNTRY
*  INTO V_DIR_ENTREGA SEPARATED BY SPACE.
*
**** Direccion fisica, interlocutor AG
*  CLEAR: V_STR_TMP, V_KUNNR_ID_RES, V_ADRNR.
*
*  SELECT SINGLE KUNNR
*      FROM VBPA
*      INTO V_KUNNR_ID_RES
*      WHERE VBELN = I_VBRK_E-VBELN
*      AND   PARVW = 'AG'.
*
*  SELECT SINGLE ADRNR
*    FROM KNA1
*    INTO V_ADRNR
*    WHERE KUNNR = V_KUNNR_ID_RES.
*
*  SELECT *
*  FROM ADRC
*  INTO TABLE I_ADRC_RES
*  WHERE ADDRNUMBER = V_ADRNR.
*  READ TABLE I_ADRC_RES INDEX 1.
*
*  CONCATENATE I_ADRC_RES-NAME1 ', ' I_ADRC_RES-STREET I_ADRC_RES-HOUSE_NUM1 I_ADRC_RES-HOUSE_NUM2 ', ' I_ADRC_RES-CITY1 ', ' I_ADRC_RES-CITY2 ', '
*              I_ADRC_RES-POST_CODE1 ', ' I_ADRC_RES-REGION I_ADRC_RES-COUNTRY
*  INTO V_DIR_FISICA SEPARATED BY SPACE.
*
  MOVE '<PS:Receptor' TO IT_XML_PS.
*  CONCATENATE IT_XML_PS ' DireccionEntrega="' INTO IT_XML_PS RESPECTING BLANKS. CONCATENATE IT_XML_PS  V_DIR_ENTREGA '"' INTO IT_XML_PS.
  CONCATENATE IT_XML_PS ' DireccionFiscal="'  INTO IT_XML_PS RESPECTING BLANKS.  CONCATENATE IT_XML_PS V_DIR_FISICA '"/>' INTO IT_XML_PS.
  SHIFT IT_XML_PS BY 2 PLACES RIGHT. APPEND IT_XML_PS. CLEAR IT_XML_PS.



  DATA: V_LINEA          TYPE STRING.

*************************************************************************************
*** Posiciones **********************************************************************
*************************************************************************************
*  LOOP AT LT_XVBRP INTO WA_LT_XVBRP.
*
*    CLEAR: V_LINEA, V_ADICIONAL1, V_ADICIONAL2.
*
*    V_ADICIONAL1 = WA_LT_XVBRP-POSNR.       " Posicion
*    V_ADICIONAL2 = ''.      " Cantidad surtida
*
*    READ TABLE I_POSICIONES_PS WITH KEY POSNR = WA_LT_XVBRP-POSNR.
*
*    CONCATENATE '<PS:Linea IDC="'
*                I_POSICIONES_PS-IDC
*                '" ClaveProdServ="'
*                I_POSICIONES_PS-CLAVEPRODSERV
*                '" Identificacion="'
*                I_POSICIONES_PS-IDENTIFICACION
*                '" Cantidad="'
*                I_POSICIONES_PS-CANTIDAD
*                '" ClaveUnidad="'
*                I_POSICIONES_PS-CLAVEUNIDAD
*                '" Unidad="'
*                I_POSICIONES_PS-UNIDAD
*                '" Descripcion="'
*                I_POSICIONES_PS-DESCRIPCION
*                '" ValorUnitario="'
*                I_POSICIONES_PS-VALORUNITARIO
*                '" Importe="'
*                I_POSICIONES_PS-IMPORTE
*                '" Descuento="'
*                I_POSICIONES_PS-DESCUENTO
*                '" Adicional1="'
*                V_ADICIONAL1
*                '" Adicional2="'
*                V_ADICIONAL2
*                '">'
*    INTO V_LINEA RESPECTING BLANKS.
*    MOVE V_LINEA TO IT_XML_PS.
*    SHIFT IT_XML_PS RIGHT BY 2 PLACES.  APPEND IT_XML_PS.  CLEAR IT_XML_PS.
*
*    MOVE '<PS:Impuestos>' TO IT_XML_PS.
*    SHIFT IT_XML_PS RIGHT BY 2 PLACES.  APPEND IT_XML_PS.  CLEAR IT_XML_PS.
*
*    MOVE '<PS:Traslados>' TO IT_XML_PS.
*    SHIFT IT_XML_PS RIGHT BY 2 PLACES.  APPEND IT_XML_PS.  CLEAR IT_XML_PS.
*
*    LOOP AT I_IMPUESTOS_PS WHERE POSNR = WA_LT_XVBRP-POSNR.
*      CONCATENATE '<PS:Traslado Base="'
*                  I_IMPUESTOS_PS-BASE
*                  '" Impuesto="'
*                  I_IMPUESTOS_PS-IMPUESTO
*                  '" TipoFactor="'
*                  I_IMPUESTOS_PS-TIPOFACTOR
*                  '" TasaOCuota="'
*                  I_IMPUESTOS_PS-TASAOCUOTA
*                  '" Importe="'
*                  I_IMPUESTOS_PS-IMPORTE
*                  '"/>'
*       INTO IT_XML_PS RESPECTING BLANKS.
*      SHIFT IT_XML_PS RIGHT BY 2 PLACES.  APPEND IT_XML_PS.  CLEAR IT_XML_PS.
*
*
*    ENDLOOP.
*
*    MOVE '</PS:Traslados>' TO IT_XML_PS.
*    SHIFT IT_XML_PS RIGHT BY 2 PLACES.  APPEND IT_XML_PS.  CLEAR IT_XML_PS.
*
*    MOVE '</PS:Impuestos>' TO IT_XML_PS.
*    SHIFT IT_XML_PS RIGHT BY 2 PLACES.  APPEND IT_XML_PS.  CLEAR IT_XML_PS.
*
*    MOVE '</PS:Linea>' TO IT_XML_PS.
*    SHIFT IT_XML_PS RIGHT BY 2 PLACES.  APPEND IT_XML_PS.  CLEAR IT_XML_PS.
*
*
*  ENDLOOP.

  MOVE '</PS:PACSimple>' TO IT_XML_PS. APPEND IT_XML_PS. CLEAR IT_XML_PS.



ENDFORM.  " F_ADDENDA_PS

*&---------------------------------------------------------------------*
*&      Form  F_CADENA_XML_CHECK
*&---------------------------------------------------------------------*
FORM F_CADENA_XML_CHECK USING TAG VALOR.

  DATA: V_TAG   TYPE C LENGTH 50,
        V_TAG_S TYPE STRING.
  CLEAR: V_TAG, V_TAG_S.

  CALL FUNCTION 'STRING_UPPER_LOWER_CASE'
    EXPORTING
      DELIMITER = '_'
      STRING1   = TAG
    IMPORTING
      STRING    = V_TAG
    EXCEPTIONS
      NOT_VALID = 1
      TOO_LONG  = 2
      TOO_SMALL = 3
      OTHERS    = 4.

  IF SY-SUBRC <> 0.
  ENDIF.

  V_TAG_S = V_TAG.
  CONCATENATE '<' V_TAG_S '>' VALOR '</' V_TAG_S '>' INTO IT_XML.
  APPEND IT_XML. CLEAR IT_XML.


ENDFORM.                    "f_cadena_xml_check

*&---------------------------------------------------------------------*
*& Form f_update_tabla
*&---------------------------------------------------------------------*
FORM F_UPDATE_TABLA .

  LOOP AT I_ZALV_COMP_PAGO_REF.
    MODIFY ZALV_COMP_PAGO FROM I_ZALV_COMP_PAGO_REF.
  ENDLOOP.

  COMMIT WORK AND WAIT.
ENDFORM.
