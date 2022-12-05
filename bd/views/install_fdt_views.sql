prompt PL/SQL Developer Export User Objects for user FDT2@DEV01
prompt Created by SHQIAR on 5 décembre 2022
set define off
spool fdt_views.log

prompt
prompt Creating view FDTV_DIFF_SCPTE_RES_TRAV_SCP2_SCP
prompt ===============================================
prompt
@@fdtv_diff_scpte_res_trav_scp2_scp.vw
prompt
prompt Creating view FDTV_DIFF_SCPTE_RES_TRAV_SCP_SCP2
prompt ===============================================
prompt
@@fdtv_diff_scpte_res_trav_scp_scp2.vw

prompt Done
spool off
set define on
