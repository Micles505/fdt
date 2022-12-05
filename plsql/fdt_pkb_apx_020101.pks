create or replace package fdt_pkb_apx_020101 is
   -- ====================================================================================================
   -- Date        : 2021-06-10
   -- Par         : SHQYMR
   -- Description : Gérer les interventions
   -- ====================================================================================================
   -- Date        : 
   -- Par         : 
   -- Description : 
   -- ====================================================================================================
   --
   --
   -- =========================================================================
   -- Valider si un traitement doit être affiché dans le menu burger dans
   -- intervention détail
   -- =========================================================================
   function valider_affichage_menu_burger (pnu_no_seq_intrv_detail fdtt_intervention_detail.no_seq_intrv_detail%type) return boolean;
   --
   --
   -- =========================================================================
   -- Valider les dates des interventions détail
   -- =========================================================================
   function f_valider_date (pre_detail_intrv in fdtt_intervention_detail%rowtype) return varchar2;
   --
   --
   -- =========================================================================
   -- Valider le contexte des interventions détail
   -- =========================================================================
   function f_valider_contexte_intrv_detail (pre_detail_intrv in fdtt_intervention_detail%rowtype) return varchar2;
   --
   --
   -- =========================================================================
   -- Ajouter le premier enregistrement de découpage (GENERAUX) dans la
   -- table FDTT_ASS_ACT_INTRV_DET lors de l'ajout d'une nouvelle interventions
   -- détail
   --
   -- *** La feuille de temps va dans la table d'association pour présenter 
   --     les interventions ... donc pour une intervention qui n'a pas besoin 
   --     d'un découpage, il faut créer un enregistrement de découpage 
   --     général
   --
   -- *** En mise à jour, la description dans le découpage de l'intervention 
   --     en cours sera ajusté selon les informations inscrites
   -- =========================================================================
   procedure p_maj_decoupage (pre_detail_intrv in fdtt_intervention_detail%rowtype);
   --
   --
   -- =========================================================================
   -- Mise à jour de la description du découpage en cours via la fenêtre 
   -- gestion du découpage d'une intervention
   -- =========================================================================
   function f_maj_descr_decoupage (pre_ass_act_intrv_det in fdtt_ass_act_intrv_det%rowtype) return varchar2;
   --
   --
   -- =========================================================================
   -- Valider la suppression dans le découpage
   -- =========================================================================
   function f_valider_suppression_decoupage (pre_ass_act_intrv_det in fdtt_ass_act_intrv_det%rowtype) return varchar2;
   --
   --
   -- =========================================================================
   -- Valider les dates des découpage
   -- =========================================================================
   function f_valider_date_ressource (pre_ass_intrvd_ressr in fdtt_ass_intrvd_ressr%rowtype) return varchar2;
   --
end fdt_pkb_apx_020101;
/
