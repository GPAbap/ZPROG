*&---------------------------------------------------------------------*
*& Report ZCO_COCKPIT_PRESUPUESTO
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zco_cockpit_presupuesto.

INCLUDE zco_cockpit_presupuesto_top02.
INCLUDE zco_cockpit_presupuesto_cls.
INCLUDE zco_cockpit_presupuesto_top.
INCLUDE zco_cockpit_presupuesto_top01.
*
*
INCLUDE zco_cockpit_presupuesto_fun.
INCLUDE zco_cockpit_presupuesto_fun02.
INCLUDE zco_cockpit_presupuesto_alv.
INCLUDE zco_cockpit_presupuesto_alv02.
INCLUDE zco_cockpit_presupuesto_mod.
*
START-OF-SELECTION.
  CALL SCREEN 1000.

  INCLUDE zco_cockpit_presupuesto_mod01.

  INCLUDE zco_cockpit_presupuesto_fun01.
  INCLUDE zco_cockpit_presupuesto_fun03.

  INCLUDE zco_cockpit_presupuesto_mod02.



  INCLUDE zco_cockpit_presupuesto_mod03.

  INCLUDE zco_cockpit_presupuesto_mod04.

  INCLUDE zco_cockpit_presupuesto_fun04.
  "Presupuesto

INCLUDE zco_cockpit_presupuesto_mod05.
