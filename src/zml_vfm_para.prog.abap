*&---------------------------------------------------------------------*
*&  Include           ML_VFM_PARA                                      *
*&---------------------------------------------------------------------*
*6.00
*SLEE5K000417  101008 see note 1260581
*SLP7EK020963  080906 see note 975447
*SLP7EK018564  140806 see note 963263
*SLP7EK007998  290506 see note 912984
*SLP7EK000606  050106 see note 878365
*HOMXENK013946 230805 Accessibility
*SLXENK001374  270705 see note 861709
*SLPENK028589  160605 see note 783347
*SLXENK005582  270705 see note 770270
*SLXENK004152  220705 see note 755401
*HOMAENK054689 040405 Checkman-Fehler
*4.70 Extensions 2.00
*HOMPLNK060557 080703 See note 621340
*4.70
*HOMALNK005514 171001 Retrofit XBA

SELECTION-SCREEN SKIP 2.

PARAMETERS: p_bukrs LIKE mlkey-bukrs_ml_productive MEMORY ID buk.
SELECT-OPTIONS: r_matnr FOR mlkey-matnr MEMORY ID mat,
*               r_bukrs FOR mlkey-bukrs MEMORY ID buk,
                r_werks FOR mlkey-werks MEMORY ID wrk,
                r_bwtar FOR mlkey-bwtar MEMORY ID bwt.

SELECTION-SCREEN SKIP.

SELECTION-SCREEN PUSHBUTTON /1(30) expan USER-COMMAND expan.
SELECTION-SCREEN BEGIN OF BLOCK extra WITH FRAME TITLE text-002.
PARAMETERS: p_mlast LIKE ckmlhd-mlast DEFAULT '' MODIF ID puk.
SELECT-OPTIONS: r_vbeln FOR ckmlhd-vbeln MEMORY ID aun MODIF ID puk,
                r_posnr FOR ckmlhd-posnr MEMORY ID apo MODIF ID puk,
                r_sobkz FOR ckmlhd-sobkz MEMORY ID sob MODIF ID sbz MATCHCODE OBJECT h_t148,
                r_pspnr FOR ckmlhd-pspnr MEMORY ID pro MODIF ID puk,
                r_bklas FOR mbew-bklas   MEMORY ID bkl MODIF ID puk,
                r_mtart FOR mara-mtart   MEMORY ID mta MODIF ID puk,
                r_matkl FOR mara-matkl   MEMORY ID mkl MODIF ID puk,
                r_spart FOR mara-spart   MEMORY ID spa MODIF ID puk,
                r_prctr FOR marc-prctr   MEMORY ID prc MODIF ID puk.
SELECTION-SCREEN END OF BLOCK extra.

SELECTION-SCREEN BEGIN OF BLOCK sele WITH FRAME TITLE text-016.
* Lauf
SELECTION-SCREEN BEGIN OF BLOCK lauf WITH FRAME TITLE text-001.
PARAMETERS: p_lauf LIKE ckmlrunperiod-run_type
                        MEMORY ID ckml_run_type MODIF ID lau.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(29) text-007 FOR FIELD p_lpop MODIF ID lau.
PARAMETERS: p_lpop LIKE ckmlrunperiod-poper MEMORY ID mlp MODIF ID lau,
            p_lgja LIKE ckmlrunperiod-gjahr MEMORY ID mlj MODIF ID lau.
SELECTION-SCREEN COMMENT 40(1) text-008 FOR FIELD p_lpop MODIF ID lau.
PARAMETERS: p_appl LIKE ckmlrunperiod-appl MEMORY ID ckml_run_appl MODIF
 ID lau.
SELECTION-SCREEN END OF LINE.
PARAMETERS: p_lday LIKE ckmlrunperiod-last_day NO-DISPLAY MODIF ID lau.
SELECTION-SCREEN END OF BLOCK lauf.
* Periode
SELECTION-SCREEN BEGIN OF BLOCK periode WITH FRAME TITLE text-003.
PARAMETERS: p_poper LIKE cki_doc_ml-sl_periode MEMORY ID mlp
                                               MODIF ID per,
            p_bdatj LIKE mlkey-bdatj MEMORY ID mlj MODIF ID per.
SELECTION-SCREEN END OF BLOCK periode.
SELECTION-SCREEN PUSHBUTTON /1(25) knopf USER-COMMAND sele.
SELECTION-SCREEN END OF BLOCK sele.

SELECTION-SCREEN BEGIN OF BLOCK radio WITH FRAME TITLE text-004.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(50) text-020 FOR FIELD p_all.
PARAMETERS: p_all RADIOBUTTON GROUP radi.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(50) text-019 FOR FIELD p_limit.
PARAMETERS: p_limit RADIOBUTTON GROUP radi DEFAULT 'X'.
SELECTION-SCREEN END OF LINE.
*SELECTION-SCREEN BEGIN OF LINE.
*SELECTION-SCREEN COMMENT 1(50) text-029 FOR FIELD p_no_0.
*PARAMETERS: p_no_0 RADIOBUTTON GROUP radi.
*SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF BLOCK limit WITH FRAME TITLE text-006.
PARAMETERS: p_limndi LIKE ckml_vfm_tree-diff_ndi,
            p_limnin LIKE ckml_vfm_tree-diff_nin.
SELECTION-SCREEN END OF BLOCK limit.
PARAMETERS: p_2s TYPE c NO-DISPLAY.
SELECTION-SCREEN END OF BLOCK radio.

SELECTION-SCREEN BEGIN OF BLOCK fiacc WITH FRAME TITLE text-021.
PARAMETERS: p_fiacc TYPE c AS CHECKBOX MODIF ID fia.
PARAMETERS: p_finom TYPE c AS CHECKBOX MODIF ID fia.
PARAMETERS: p_finor TYPE c AS CHECKBOX MODIF ID fia.     "note 1377333
*SELECT-OPTIONS: r_hkont FOR bseg-hkont.
SELECTION-SCREEN END OF BLOCK fiacc.



SELECTION-SCREEN BEGIN OF BLOCK extract WITH FRAME TITLE text-024.
*SELECTION-SCREEN BEGIN OF LINE.
*SELECTION-SCREEN COMMENT 1(31) text-025 FOR FIELD p_exrea MODIF ID fia.
PARAMETERS: p_exrea RADIOBUTTON GROUP extr MODIF ID fia.
SELECTION-SCREEN COMMENT 35(40) text-026 MODIF ID fia.
*SELECTION-SCREEN END OF LINE.
PARAMETERS: p_exwri RADIOBUTTON GROUP extr DEFAULT 'X' MODIF ID fia,
            p_exnam LIKE ckmvfm_extract-exnam MEMORY ID exnam
                                              MODIF ID fia OBLIGATORY.
SELECTION-SCREEN END OF BLOCK extract.
