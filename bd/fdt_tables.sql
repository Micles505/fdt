prompt PL/SQL Developer Export User Objects for user FDT2@DEV01
prompt Created by SHQIAR on 5 décembre 2022
set define off
spool fdt.log

prompt
prompt Creating table FDTT_CATEGORIE_ACTIVITES
prompt =======================================
prompt
@@fdtt_categorie_activites.tab
prompt
prompt Creating table FDTT_ACTIVITES
prompt =============================
prompt
@@fdtt_activites.tab
prompt
prompt Creating table FDTT_RESSOURCE
prompt =============================
prompt
@@fdtt_ressource.tab
prompt
prompt Creating table FDTT_DIRECTION
prompt =============================
prompt
@@fdtt_direction.tab
prompt
prompt Creating table FDTT_TYP_COMPTE_BUDG
prompt ===================================
prompt
@@fdtt_typ_compte_budg.tab
prompt
prompt Creating table FDTT_TYP_ETAPE
prompt =============================
prompt
@@fdtt_typ_etape.tab
prompt
prompt Creating table FDTT_TYP_LIVRAISON
prompt =================================
prompt
@@fdtt_typ_livraison.tab
prompt
prompt Creating table FDTT_TYP_STRATEGIE
prompt =================================
prompt
@@fdtt_typ_strategie.tab
prompt
prompt Creating table FDTT_CATEGORIE_COUT
prompt ==================================
prompt
@@fdtt_categorie_cout.tab
prompt
prompt Creating table FDTT_INTERVENTION
prompt ================================
prompt
@@fdtt_intervention.tab
prompt
prompt Creating table FDTT_INTERVENTION_DETAIL
prompt =======================================
prompt
@@fdtt_intervention_detail.tab
prompt
prompt Creating table FDTT_ASS_ACT_INTRV_DET
prompt =====================================
prompt
@@fdtt_ass_act_intrv_det.tab
prompt
prompt Creating table FDTT_ASS_INTRVD_RESSR
prompt ====================================
prompt
@@fdtt_ass_intrvd_ressr.tab
prompt
prompt Creating table FDTT_GROUPES
prompt ===========================
prompt
@@fdtt_groupes.tab
prompt
prompt Creating table FDTT_ASSOC_EMPLOYES_GRP
prompt ======================================
prompt
@@fdtt_assoc_employes_grp.tab
prompt
prompt Creating table FDTT_TYP_INTERVENTION
prompt ====================================
prompt
@@fdtt_typ_intervention.tab
prompt
prompt Creating table FDTT_ASS_TYP_INTRV_QUALF
prompt =======================================
prompt
@@fdtt_ass_typ_intrv_qualf.tab
prompt
prompt Creating table FDTT_TYP_SERVICE
prompt ===============================
prompt
@@fdtt_typ_service.tab
prompt
prompt Creating table FDTT_ASS_TYP_SERV_QUALF
prompt ======================================
prompt
@@fdtt_ass_typ_serv_qualf.tab
prompt
prompt Creating table FDTT_CALENDRIER_ABSENCE
prompt ======================================
prompt
@@fdtt_calendrier_absence.tab
prompt
prompt Creating table FDTT_DETAILS_ATT
prompt ===============================
prompt
@@fdtt_details_att.tab
prompt
prompt Creating table FDTT_FEUILLES_TEMPS
prompt ==================================
prompt
@@fdtt_feuilles_temps.tab
prompt
prompt Creating table FDTT_FONCT_INTERVENANTS
prompt ======================================
prompt
@@fdtt_fonct_intervenants.tab
prompt
prompt Creating table FDTT_QUALIFICATION
prompt =================================
prompt
@@fdtt_qualification.tab
prompt
prompt Creating table FDTT_SPECIALITE
prompt ==============================
prompt
@@fdtt_specialite.tab
prompt
prompt Creating table FDTT_RESSOURCE_INFO_SUPPL
prompt ========================================
prompt
@@fdtt_ressource_info_suppl.tab
prompt
prompt Creating table FDTT_SUIVI_FEUILLES_TEMPS
prompt ========================================
prompt
@@fdtt_suivi_feuilles_temps.tab
prompt
prompt Creating table FDTT_TEMPS_INTERVENTION
prompt ======================================
prompt
@@fdtt_temps_intervention.tab
prompt
prompt Creating table FDTT_TEMPS_JOURS
prompt ===============================
prompt
@@fdtt_temps_jours.tab
prompt
prompt Creating table FDTW_CODE_EQUIVALENCE
prompt ====================================
prompt
@@fdtw_code_equivalence.tab

prompt Done
spool off
set define on
