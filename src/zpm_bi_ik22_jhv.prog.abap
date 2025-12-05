************************************************************************
* Grupo Pecuario San Antonio, S.A. de C.V.
* Autor: María del Carmen Ocotlán Guzmán Medina
* programa: zbipm0002
* Descripción: Batch Input para cargar registrar datos de la estación
*              de combustible de Fletera
* Transacción IFCU
* Fecha: Julio 28 del 2009
************************************************************************
REPORT zpm_bi_ik22_jhv MESSAGE-ID zm NO STANDARD PAGE HEADING.

INCLUDE ZPM_BI_IK22_JHV_DAT.
*INCLUDE: zbipm0005b_dat,
INCLUDE ZPM_BI_IK22_JHV_F01.
*         zbipm0005b_f01.
*-----------  P R O G.    P R I N C I P A L   -----------------*
*carga archivos a tabla internas
*Llena tabla rec1
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.
  PERFORM f_value_reques.


START-OF-SELECTION.
  PERFORM f_carga_archivo.
*    perform open_group.
*    perform valida_registros.
  PERFORM f_ejecuta_batch.
*    perform close_group.
END-OF-SELECTION.

INCLUDE ZPM_BI_IK22_JHV_PBO.
*  INCLUDE zbipm0005b_pbo.

INCLUDE ZPM_BI_IK22_JHV_PAI.
*  INCLUDE zbipm0005b_pai.
