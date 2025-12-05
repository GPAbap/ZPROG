*&---------------------------------------------------------------------*
*& Report ZSDFICO_RE_FACTS_CONT_JOB_JHV
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zsdfico_re_facts_cont_job_jhv.

INCLUDE zsdfico_re_facts_job_jhv_top.
INCLUDE zsdfico_re_facts_job_jhv_fun.

START-OF-SELECTION.

PERFORM show_data_ida.
