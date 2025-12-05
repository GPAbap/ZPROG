class ZCL_PP_SUBCON definition
  public
  final
  create public .

public section.

  interfaces IF_AMDP_MARKER_HDB .

  class-methods GET_DATA
    for table function ZPP_TF_JHV_SUBCON .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_PP_SUBCON IMPLEMENTATION.


METHOD get_data
     BY DATABASE FUNCTION FOR HDB
         LANGUAGE SQLSCRIPT
         OPTIONS READ-ONLY
      USING matdoc mkpf makt
.

    lt_matdoc = APPLY_FILTER ( matdoc, :sel_opt );
    RETURN SELECT DISTINCT matdoc.mandt as clnt,
                  matdoc.werks,
                  matdoc.aufnr,
                  matdoc.matnr,
                  makt.maktx,
                  SUM (
                  CASE WHEN matdoc.bwart = '262' then matdoc.erfmg * -1
                  ELSE CASE WHEN matdoc.bwart = '544' THEN matdoc.erfmg * -1
                  ELSE CASE WHEN matdoc.bwart = '102' THEN matdoc.erfmg * -1
                  ELSE matdoc.erfmg END END END
                  ) AS erfmg,
                  matdoc.erfme,
*                  matdoc.bwart,
                  m2.werks as werks_s,
                   m2.ebeln as ebeln_s,
                  m2.matnr as matnr_s,
                  SUM (
                  CASE WHEN m2.bwart = '262' then m2.erfmg * -1
                  ELSE CASE WHEN m2.bwart = '544' THEN m2.erfmg * -1
                  ELSE CASE WHEN m2.bwart = '102' THEN m2.erfmg * -1
                  ELSE m2.erfmg END END END
                  ) AS erfmg_s,
                  m2.erfme as erfme_s,
                  m2.bwart as bwart_s,
                  matdoc.erfmg - m2.erfmg as Diferencia,
                  m2.budat
           from :lt_matdoc matdoc
           inner join makt on makt.matnr = matdoc.matnr and makt.spras = 'S'
           left join mkpf on RTRIM( mkpf.bktxt,' ' ) = RTRIM(matdoc.aufnr, ' ')
           left join matdoc as m2 on m2.mblnr = mkpf.mblnr
                and rtrim( replace( matdoc.matnr,'NV',' ' ), ' ' )
                     = ltrim( m2.matnr,'0' )
           where
             matdoc.mandt = :clnt
           GROUP BY matdoc.mandt, matdoc.erfmg,m2.erfmg,
                    matdoc.werks, matdoc.aufnr,matdoc.matnr,
                    makt.maktx,matdoc.erfme,
*                    matdoc.bwart,
                    m2.werks,m2.matnr,m2.erfme,
                    m2.bwart,
                    m2.ebeln, m2.budat
                    ;


  ENDMETHOD.
ENDCLASS.
