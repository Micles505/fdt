create or replace package fdt_pkb_apx_010106 is
  -- ====================================================================================================
  -- Date        : 2022-05-10
  -- Par         : SHQYMR
  -- Description : Saisie des efforts (Sans feuille de temps)
  -- ====================================================================================================
  -- Date        :
  -- Par         :
  -- Description :
  -- ====================================================================================================
  --
  -- Public type declarations
  --
  -- Table qui permet de contenir les messages pour la validation des interventions.
  type tp_message_interv_aver is table of varchar(32767);
  vtp_message_interv_aver tp_message_interv_aver := new tp_message_interv_aver();
  --
  -- Variable servant à la fonction qui alimente la Lov intervention
  --
  type rec_item_lov_intervention is record(
    description           fdtt_ass_act_intrv_det.description%type,
    no_seq_aact_intrv_det fdtt_ass_act_intrv_det.no_seq_aact_intrv_det%type);
  --
  type tab_pipe_item_lov_intervention is table of rec_item_lov_intervention;
  --
  --
  -- Variable servant à la fonction qui alimente la Lov périodes (AN_MOIS_FDT)
  --
  type rec_item_lov_periodes is record(
    affichage             varchar2(6),
    periode               varchar2(6));
  --
  type tab_pipe_item_lov_periodes is table of rec_item_lov_periodes;
  --
  -- ------------------------------------------------------------------------------------------
  -- Type et variables pour la collection des associations types interventions / qualifications
  -- ------------------------------------------------------------------------------------------
  type rec_temps_intervention is record(
    no_seq_temps_intrv    fdtt_temps_intervention.no_seq_temps_intrv%type,
    no_seq_ressource      fdtt_temps_intervention.no_seq_ressource%type,
    no_seq_aact_intrv_det fdtt_temps_intervention.no_seq_aact_intrv_det%type,
    nbr_minute_trav       fdtt_temps_intervention.nbr_minute_trav%type,
    debut_periode         fdtt_temps_intervention.debut_periode%type,
    fin_periode           fdtt_temps_intervention.fin_periode%type,
    apex_row_status       varchar2(3));
  --
  type tab_rec_temps_intervention is table of rec_temps_intervention index by pls_integer;
  --
  vta_rec_temps_intervention tab_rec_temps_intervention;
  ----------------------------------------------------------------------------------------------
  -- Permet de faire la maj ou l'insertion dans FDTT_TEMPS_INTERVENTION
  ----------------------------------------------------------------------------------------------
  procedure p_gerer_temps_intervention(pva_apex_row_status       in varchar2,
                                       pnu_no_seq_temps_intrv    in fdtt_temps_intervention.no_seq_temps_intrv%type,
                                       pnu_no_seq_ressource      in fdtt_temps_intervention.no_seq_ressource%type,
                                       pnu_no_seq_aact_intrv_det in fdtt_temps_intervention.no_seq_aact_intrv_det%type,
                                       pva_an_mois_fdt           in fdtt_temps_intervention.an_mois_fdt%type,
                                       pdt_debut_periode         in fdtt_temps_intervention.debut_periode%type,
                                       pdt_fin_periode           in fdtt_temps_intervention.fin_periode%type,
                                       pva_nbr_minute_trav_aff   in varchar2,
                                       pva_commentaire           in fdtt_temps_intervention.commentaire%type,
                                       pnu_no_seq_specialite     in fdtt_temps_intervention.no_seq_specialite%type);
  -- ---------------------------------------------------------
  -- Supprimer la collection
  -- ---------------------------------------------------------
  procedure p_supprimer_collection;
  --
  -- ---------------------------------------------------------
  -- Remplir la collection
  -- ---------------------------------------------------------
  procedure p_ajouter_enreg_collection(pre_enreg               in fdtt_temps_intervention%rowtype,
                                       pva_nbr_minute_trav_aff in varchar2,
                                       pva_apex$row_status     in varchar2);
  -- ---------------------------------------------------------
  -- Valider la cohérence
  -- ---------------------------------------------------------
  procedure p_valider_coherence(pnu_no_seq_ressource   in fdtt_temps_intervention.no_seq_ressource%type,
                                pdt_debut_periode      in fdtt_temps_intervention.debut_periode%type,
                                pdt_fin_periode        in fdtt_temps_intervention.fin_periode%type);
  -----------------------------------------------------------------------------------------------------------
  -- Permet de savoir si l'activite en est une générique.  Dans ce cas, la ligne est non modifiable.
  -----------------------------------------------------------------------------------------------------------
  function f_est_acti_generique_non_accessible(pnu_no_seq_aact_intrv_det in fdtt_temps_intervention.no_seq_aact_intrv_det%type)
    return varchar2;
  -- ----------------------------------------------------------------------------------------------------------
  -- Permet d'obtenir les records pour la lov des interventions dans la liste des interventions.
  -- ----------------------------------------------------------------------------------------------------------
  function f_obtenir_items_lov_intervention(pnu_no_seq_ressource         in fdtt_ressource.no_seq_ressource%type,
                                            pdt_date_debut_periode       in date,
                                            pdt_date_fin_periode         in date,
                                            pnu_no_seq_activite_generaux in fdtt_activites.no_seq_activite%type,
                                            pnu_no_seq_temps_interv      in fdtt_temps_intervention.no_seq_temps_intrv%type)
    return tab_pipe_item_lov_intervention
    pipelined;
  -- ---------------------------------------------------------
  -- Sélectionner la spécialité d'une ressource
  -- ---------------------------------------------------------
  function f_obt_specialite (pnu_no_seq_ressource in fdtt_ressource.no_seq_ressource%type) return number;
  -- ---------------------------------------------------------
  -- Vérifier l'accès à ce traitement
  -- ---------------------------------------------------------
  function f_acces_traitement (pva_co_utilisateur in varchar2) return boolean;
  --
  -- ----------------------------------------------------------------------------------------------------------
  -- Permet d'obtenir les records pour la lov des périodes.
  -- ----------------------------------------------------------------------------------------------------------
  function f_obtenir_items_lov_periodes(pdt_date in date)
    return tab_pipe_item_lov_periodes
    pipelined;
  --
end fdt_pkb_apx_010106;
/

