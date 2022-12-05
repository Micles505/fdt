prompt PL/SQL Developer Export User Objects for user FDT2@DEV01
prompt Created by SHQIAR on 5 décembre 2022
set define off
spool fdt_procedures.log

prompt
prompt Creating procedure FDT_PRB_APX_CALCULER_TOTAUX_FEUILLE_TEMPS
prompt ============================================================
prompt
@@fdt_prb_apx_calculer_totaux_feuille_temps.prc
prompt
prompt Creating procedure FDT_PRB_APX_CREER_FEUILLE_TEMPS
prompt ==================================================
prompt
@@fdt_prb_apx_creer_feuille_temps.prc
prompt
prompt Creating procedure FDT_PRB_APX_CREER_FEUILLE_TEMPS_INTER_FDT
prompt ============================================================
prompt
@@fdt_prb_apx_creer_feuille_temps_inter_fdt.prc
prompt
prompt Creating procedure FDT_PRB_APX_OBT_FCT_INTERV
prompt =============================================
prompt
@@fdt_prb_apx_obt_fct_interv.prc
prompt
prompt Creating procedure FDT_PRB_TRANSFERT_INTERV_CENTRAL_VERS_FDT
prompt ============================================================
prompt
@@fdt_prb_transfert_interv_central_vers_fdt.prc

prompt Done
spool off
set define on
