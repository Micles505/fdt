create or replace package fdt_pkb_apx_010101 is
  -- ====================================================================================================
  -- Date        : 2021-09-14
  -- Par         : SHQCGE
  -- Description : Gérer la Saisie du temps et les efforts
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
  -- Variable servant à la fonction f_obtenir_item_onglet_saisie
  --
  type rec_item_onglet_saisie is record(
    level_menu            apex_application_list_entries.display_sequence%type,
    label_menu            apex_application_list_entries.entry_text%type,
    target_menu           apex_application_list_entries.entry_target%type,
    is_current_list_entry apex_application_list_entries.current_for_pages_type%type,
    image                 apex_application_list_entries.entry_image%type,
    image_attribute       apex_application_list_entries.entry_image_attributes%type,
    image_alt_attribute   apex_application_list_entries.entry_image_alt_attribute%type,
    attribute1            apex_application_list_entries.entry_attribute_01%type,
    attribute2            apex_application_list_entries.entry_attribute_02%type,
    attribute3            apex_application_list_entries.entry_attribute_03%type,
    attribute4            apex_application_list_entries.entry_attribute_04%type,
    attribute5            apex_application_list_entries.entry_attribute_05%type,
    attribute6            apex_application_list_entries.entry_attribute_06%type,
    attribute7            apex_application_list_entries.entry_attribute_07%type,
    attribute8            apex_application_list_entries.entry_attribute_08%type,
    attribute9            apex_application_list_entries.entry_attribute_09%type,
    attribute10           apex_application_list_entries.entry_attribute_10%type);
  --
  type tab_pipe_item_onglet_saisie is table of rec_item_onglet_saisie;
  --
  -- Variable servant à la fonction qui alimente la Lov intervention
  --
  type rec_item_lov_intervention is record(
    description           fdtt_ass_act_intrv_det.description%type,
    no_seq_aact_intrv_det fdtt_ass_act_intrv_det.no_seq_aact_intrv_det%type);
  --
  type tab_pipe_item_lov_intervention is table of rec_item_lov_intervention;
  -- ------------------------------------------------------------------------------------------
  -- Type et variables pour la collection des associations types interventions / qualifications
  -- ------------------------------------------------------------------------------------------
  type rec_temps_intervention is record(
    no_seq_temps_intrv    fdtt_temps_intervention.no_seq_temps_intrv%type,
    no_seq_feuil_temps    fdtt_temps_intervention.no_seq_feuil_temps%type,
    no_seq_aact_intrv_det fdtt_temps_intervention.no_seq_aact_intrv_det%type,
    nbr_minute_trav       fdtt_temps_intervention.nbr_minute_trav%type,
    debut_periode         fdtt_temps_intervention.debut_periode%type,
    fin_periode           fdtt_temps_intervention.fin_periode%type,
    apex_row_status       varchar2(3));
  --
  type tab_rec_temps_intervention is table of rec_temps_intervention index by pls_integer;
  --
  vta_rec_temps_intervention tab_rec_temps_intervention;
  -- ===========================================================================================
  -- Gérer les onglets périodes / SAGIR et Sommaire ou onglet pour utilisateur sans intervention
  -- ===========================================================================================
  function f_obtenir_item_onglet_saisie(pnu_no_seq_ressource in fdtt_ressource.no_seq_ressource%type,
                                        pva_an_mois_fdt      in fdtt_feuilles_temps.an_mois_fdt%type,
                                        pdt_dt_debut_periode in date,
                                        pdt_dt_fin_periode   in date) return tab_pipe_item_onglet_saisie
    pipelined;
  --
  procedure transmettre_fdt_et_creer_suivante(pnu_no_seq_ressource in fdtt_feuilles_temps.no_seq_ressource%type,
                                              pva_an_mois_fdt      in fdtt_feuilles_temps.an_mois_fdt%type);
  ----------------------------------------------------------------------
  -- Permet de récupérer les différentes plages pour la saisie des heures
  ----------------------------------------------------------------------
  procedure p_obtenir_plages_saisie_heures_ajax;
  ----------------------------------------------------------------------------------------------
  -- Permet de valider que la fdt précédente a été approuvée avant de transmettre celle en cours
  ----------------------------------------------------------------------------------------------
  procedure valider_si_fdt_precedente_approuvee(pnu_no_seq_ressource in fdtt_feuilles_temps.no_seq_ressource%type,
                                                pva_an_mois_fdt      in fdtt_feuilles_temps.an_mois_fdt%type);
  -------------------------------------------------------------------------------------------------
  -- Permet de calculer la différence de temps d'une journée pour une fdt (inclu la saisie du temps
  -- et les activités saisies)
  -------------------------------------------------------------------------------------------------
  function f_obtenir_difference_temps(pnu_no_seq_feuil_temps in fdtt_feuilles_temps.no_seq_feuil_temps%type,
                                      pdt_date_en_saisie     in date,
                                      pnu_no_seq_ressource   in fdtt_feuilles_temps.no_seq_ressource%type)
    return number;
  ----------------------------------------------------------------------------------------------
  -- Permet d'obtenir les différents données associées à la fdt en cours
  ----------------------------------------------------------------------------------------------
  procedure p_initialiser_champs_fdt(pnu_no_seq_ressource        in fdtt_feuilles_temps.no_seq_ressource%type,
                                     pva_an_mois_fdt             in fdtt_feuilles_temps.an_mois_fdt%type,
                                     pva_ressource_saisi_intrv   in varchar2,
                                     pnu_no_seq_feuil_temps      out fdtt_feuilles_temps.no_seq_feuil_temps%type,
                                     pva_corr_mois_preced        out varchar2,
                                     pva_note_corr_mois_preced   out fdtt_feuilles_temps.note_corr_mois_preced%type,
                                     pva_solde_reporte           out varchar2,
                                     pnu_credit_annuel122        out number,
                                     pva_solde_courant           out varchar2,
                                     pdt_date_debut_periode      in out date,
                                     pdt_date_fin_periode        in out date,
                                     pva_temps_absence_fdt       out varchar2,
                                     pva_temps_total_sagir       out varchar2,
                                     pva_total_periode           out varchar2,
                                     pva_ind_mois_complet_interv out varchar2,
                                     pva_statut                  out varchar2);
  ----------------------------------------------------------------------------------------------
  -- Permet d'obtenir la fdt courante de la ressource
  ----------------------------------------------------------------------------------------------
  procedure p_obtenir_fdt_actuelle(pnu_no_seq_ressource in fdtt_feuilles_temps.no_seq_ressource%type,
                                   pva_an_mois_fdt      out fdtt_feuilles_temps.an_mois_fdt%type);
  ----------------------------------------------------------------------------------------------
  -- Permet d'obtenir la fdt courante de la ressource
  ----------------------------------------------------------------------------------------------
  procedure p_creer_ou_maj_absence(pnu_no_seq_temps_jour     in fdtt_temps_jours.no_seq_temps_jour%type,
                                   pnu_no_seq_feuil_temps    in fdtt_temps_jours.no_seq_feuil_temps%type,
                                   pnu_no_seq_activite       in fdtt_temps_jours.no_seq_activite%type,
                                   pdt_dt_temps_jour         in fdtt_temps_jours.dt_temps_jour%type,
                                   pva_heure_absence         in varchar2,
                                   pva_request               in varchar2,
                                   pva_an_mois_fdt           in fdtt_temps_jours.an_mois_fdt%type,
                                   pva_ressource_saisi_intrv in varchar2,
                                   pdt_dt_debut_periode      in date,
                                   pdt_dt_fin_periode        in date,
                                   pva_remarque              in varchar2);
  ----------------------------------------------------------------------------------------------
  -- Permet de détruire une absence
  ----------------------------------------------------------------------------------------------
  procedure p_detruire_absence(pnu_no_seq_temps_jour  in fdtt_temps_jours.no_seq_temps_jour%type,
                               pnu_no_seq_feuil_temps in fdtt_feuilles_temps.no_seq_feuil_temps%type,
                               pnu_no_seq_activite    in fdtt_temps_jours.no_seq_activite%type,
                               pdt_dt_temps_jour      in fdtt_temps_jours.dt_temps_jour%type,
                               pva_an_mois_fdt        in fdtt_feuilles_temps.an_mois_fdt%type,
                               pdt_dt_debut_periode   in date,
                               pdt_dt_fin_periode     in date,
                               pva_heure_absence      in varchar2,
                               pva_request            in varchar2);
  ----------------------------------------------------------------------------------------------
  -- Permet de faire la maj de la grid de saisie
  ----------------------------------------------------------------------------------------------
  procedure p_maj_temps_jour(pnu_no_seq_temps_jour    in fdtt_temps_jours.no_seq_temps_jour%type,
                             pdt_dt_temps_jour        in fdtt_temps_jours.dt_temps_jour%type,
                             pva_heure_DEBUT_AM_TEMPS in varchar2,
                             pva_heure_FIN_AM_TEMPS   in varchar2,
                             pva_heure_DEBUT_PM_TEMPS in varchar2,
                             pva_heure_FIN_PM_TEMPS   in varchar2,
                             pva_REMARQUE             in fdtt_temps_jours.REMARQUE%type);
  -------------------------------------------------------------------------------------------------
  -- Permet de vérifier dans la grid de saisie de temps si la colonne est modifiable (toutes les activités
  -- sauf les congés fériés) dans le menu burger.
  -------------------------------------------------------------------------------------------------
  function f_verifier_si_activite_modifiable(pnu_NO_SEQ_ACTIVITE in fdtt_temps_jours.no_seq_activite%type)
    return boolean;
  ----------------------------------------------------------------------------------------------
  -- Permet de faire la maj ou l'insertion dans FDTT_TEMPS_INTERVENTION
  ----------------------------------------------------------------------------------------------
  procedure p_gerer_temps_intervention(pva_apex_row_status       in varchar2,
                                       pnu_no_seq_temps_intrv    in fdtt_temps_intervention.no_seq_temps_intrv%type,
                                       pnu_no_seq_feuil_temps    in fdtt_temps_intervention.no_seq_feuil_temps%type,
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
  procedure p_valider_coherence(pnu_no_seq_feuil_temps in fdtt_temps_intervention.no_seq_feuil_temps%type,
                                pdt_debut_periode      in fdtt_temps_intervention.debut_periode%type,
                                pdt_fin_periode        in fdtt_temps_intervention.fin_periode%type);
  --
  --------------------------------------------------------------------------------------------------------
  -- Permet de calculer le total du temps saisi pour une période dans la fdt
  -- (temps saisisable intervention seulement)
  --------------------------------------------------------------------------------------------------------
  function f_obtenir_temps_saisi_periode(pnu_no_seq_feuil_temps in fdtt_feuilles_temps.no_seq_feuil_temps%type,
                                         pdt_debut_periode      in date,
                                         pdt_fin_periode        in date) return number;
  ----------------------------------------------------------------------------------------------
  -- Permet d'obtenir les différents totaux pour permettre comparation fdt vs interventions
  ----------------------------------------------------------------------------------------------
  procedure p_obt_totaux_fdt_intervention_periode(pnu_no_seq_feuil_temps in fdtt_feuilles_temps.no_seq_feuil_temps%type,
                                                  pdt_debut_periode      in date,
                                                  pdt_fin_periode        in date,
                                                  pva_total_fdt_hrs      out varchar2,
                                                  pva_total_inter_hrs    out varchar2,
                                                  pva_diff_fdt_inter_hrs out varchar2);
  --------------------------------------------------------------------------------------------------------
  -- Permet de voir si on traite l'onglet mois complet
  --
  --------------------------------------------------------------------------------------------------------
  function f_obtenir_ind_mois_complet_intervention(pva_periodes      in fdtt_feuilles_temps.an_mois_fdt%type,
                                                   pdt_debut_periode in date,
                                                   pdt_fin_periode   in date) return varchar2;
  ----------------------------------------------------------------------------------------------
  -- Permet de faire la valisation des différents types d'intervention
  ----------------------------------------------------------------------------------------------
  procedure p_valider_intervention_fdt(pnu_no_seq_ressource      in fdtt_ressource.no_seq_ressource%type,
                                       pva_an_mois_fdt           in fdtt_feuilles_temps.an_mois_fdt%type,
                                       pnu_no_seq_feuil_temps    in fdtt_feuilles_temps.no_seq_feuil_temps%type,
                                       pva_interne_ou_externe    in varchar2,
                                       pva_mode_affichage_erreur in varchar2 default 'AVERTISSEMENT');
  ---------------------------------------------------------------------------------------------------------------
  --  Permet de gérer automatiquement les interventions qui concernent des activités saisies dans la fdt
  --  (ex: vacances, maladies, à noter que certaines activités génériques comme les crédits horaires ne sont pas saisies
  --  dans temps intervention.
  ---------------------------------------------------------------------------------------------------------------
  procedure p_gerer_temps_interv_generique(pnu_no_seq_temps_jour        in fdtt_temps_jours.no_seq_temps_jour%type,
                                           pnu_no_seq_feuil_temps       in fdtt_feuilles_temps.no_seq_feuil_temps%type,
                                           pnu_no_seq_activite          in fdtt_temps_jours.no_seq_activite%type,
                                           pdt_dt_temps_jour            in fdtt_temps_jours.dt_temps_jour%type,
                                           pva_an_mois_fdt              in fdtt_feuilles_temps.an_mois_fdt%type,
                                           pdt_dt_debut_periode         in date,
                                           pdt_dt_fin_periode           in date,
                                           pva_heure_absence            in varchar2,
                                           pnu_no_seq_specialite_defaut in number,
                                           pva_request                  in varchar2);
  -----------------------------------------------------------------------------------------------------------
  -- Permet de savoir si l'activite en est une générique.  Dans ce cas, la ligne est non modifiable.
  -----------------------------------------------------------------------------------------------------------
  function f_est_acti_generique_non_accessible(pnu_no_seq_aact_intrv_det in fdtt_temps_intervention.no_seq_aact_intrv_det%type)
    return varchar2;
  -----------------------------------------------------------------------------------------------------------
  -- Permet de retourner la spécialité minimale de la ressource pour créer les interventions génériques (FGE)
  -----------------------------------------------------------------------------------------------------------
  function f_obtenir_specialite_ressource_pour_inter(pnu_no_seq_feuil_temps in fdtt_feuilles_temps.no_seq_feuil_temps%type,
                                                     pdt_date_debut_periode in date,
                                                     pdt_date_fin_periode   in date) return number;
  -----------------------------------------------------------------------------------------------------------
  -- Permet d'initialiser les différents champs de la page des absences prolongées.
  -----------------------------------------------------------------------------------------------------------
  procedure p_init_champs_absences_prolongees(pnu_co_employe_shq     in fdtt_ressource.co_employe_shq%type,
                                              pdt_date_min_courn     out date,
                                              pdt_date_max_courn     out date,
                                              pnu_no_seq_feuil_temps out fdtt_feuilles_temps.no_seq_feuil_temps%type,
                                              pva_an_mois_fdt        out fdtt_feuilles_temps.an_mois_fdt%type,
                                              pnu_no_seq_ressource   out fdtt_feuilles_temps.no_seq_ressource%type,
                                              pva_ind_saisie_intrv   out fdtt_ressource.ind_saisie_intrv%type);
  -----------------------------------------------------------------------------------------------------------
  -- Permet de créer les absences prolongées (et les interventions correspondantes si requis)
  -----------------------------------------------------------------------------------------------------------
  procedure p_gerer_absences_prolongees(pnu_co_employe_shq          in fdtt_ressource.co_employe_shq%type,
                                        pnu_no_seq_ressource        in fdtt_feuilles_temps.no_seq_ressource%type,
                                        pnu_no_seq_feuil_temps      in fdtt_feuilles_temps.no_seq_feuil_temps%type,
                                        pva_an_mois_fdt             in fdtt_feuilles_temps.an_mois_fdt%type,
                                        pnu_no_seq_activite_absence in fdtt_feuilles_temps.no_seq_ressource%type,
                                        pva_ind_saisie_intrv        in fdtt_ressource.ind_saisie_intrv%type,
                                        pdt_date_debut_absence      in date,
                                        pdt_date_fin_absence        in date);
  ------------------------------------------------------------------------------------------------------------
  -- Permet d'obtenir les records pour la lov des interventions dans la liste des interventions.
  ------------------------------------------------------------------------------------------------------------
  function f_obtenir_items_lov_intervention(pnu_no_seq_ressource         in fdtt_ressource.no_seq_ressource%type,
                                            pnu_no_seq_feuil_temps       in fdtt_feuilles_temps.no_seq_feuil_temps%type,
                                            pdt_date_debut_periode       in date,
                                            pdt_date_fin_periode         in date,
                                            pnu_no_seq_activite_generaux in fdtt_activites.no_seq_activite%type,
                                            pnu_no_seq_temps_interv      in fdtt_temps_intervention.no_seq_temps_intrv%type)
    return tab_pipe_item_lov_intervention
    pipelined;
  ----------------------------------------------------------------------------------------------
  -- Permet de valider que la fdt précédente a été approuvée avant de transmettre celle en cours
  ----------------------------------------------------------------------------------------------
  procedure valider_si_journee_feriee(pdt_dt_temps_jour in fdtt_temps_jours.dt_temps_jour%type);
  --
  ----------------------------------------------------------------------------------------------
  -- Permet de valider que le champ correction et raison
  ----------------------------------------------------------------------------------------------
  procedure valider_champ_correction(pva_corr_mois_preced      in varchar2,
                                     pva_note_corr_mois_preced in fdtt_feuilles_temps.note_corr_mois_preced%type);
  -- =========================================================================
  -- Fontion qui renvoit une requête sql pour obtenir la liste des absences
  -- SAGIR d'une ressources pour un mois.
  -- =========================================================================
  function f_retourner_requete_sagir_fdt  return varchar2;
end fdt_pkb_apx_010101;
/

