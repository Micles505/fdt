PROMPT Creating PROCEDURE 'FDT_PKB_APX_VALDT_TEMPS'
CREATE OR REPLACE PACKAGE BODY "FDT_PKB_APX_VALDT_TEMPS" as
  --
  cursor cur_journee_saisissable(p_no_seq_feuil_temps in fdtt_feuilles_temps.no_seq_feuil_temps%type) is
     select tj.rowid,
            tj.dt_temps_jour,
	        tj.no_seq_feuil_temps,
            to_char(tj.dh_debut_am_temps,'hh24:mi') dh_debut_am_temps,
            to_char(tj.dh_fin_am_temps,'hh24:mi')   dh_fin_am_temps,
            to_char(tj.dh_debut_pm_temps,'hh24:mi') dh_debut_pm_temps,
            to_char(tj.dh_fin_pm_temps,'hh24:mi')   dh_fin_pm_temps,
            nvl(utl_fnb_cnv_minute(to_char(tj.dh_debut_am_temps,'hh24:mi')), 0) num_debutam,
            nvl(utl_fnb_cnv_minute(to_char(tj.dh_fin_am_temps,'hh24:mi')), 0)   num_finAM,
            nvl(utl_fnb_cnv_minute(to_char(tj.dh_debut_pm_temps,'hh24:mi')), 0) num_debutPM,
            nvl(utl_fnb_cnv_minute(to_char(tj.dh_fin_pm_temps,'hh24:mi')), 0)   num_finpm
     from fdtt_temps_jours tj
     where tj.no_seq_feuil_temps = p_no_seq_feuil_temps
       and tj.no_seq_activite is null
     order by tj.dt_temps_jour;
  rec_journee_saisissable  cur_journee_saisissable%rowtype;
  -- -------------------------------------------------------------------------------------------------
  --                                           logger
  -- -------------------------------------------------------------------------------------------------
  -- Pour voir le résultat de la trace, il faut aller dans plsql_developeur et faire ce select :
  --                               select * 
  --                               from   logger_logs_5_min
  --                               order by id desc
  -- -------------------------------------------------------------------------------------------------
  cva_scope_prefix constant varchar2(31) := lower($$plsql_unit) || '.';
  --
  --
  procedure p_ajout_message (p_vc_message in varchar2,
                             pva_mode_affichage_erreur in varchar2,
                             p_date_jour in date default null) is
  begin
     if pva_mode_affichage_erreur = 'AVERTISSEMENT' then
        vtp_avertissement.extend;
        vtp_avertissement(vtp_avertissement.count):=case when p_date_jour is not null then to_char(p_date_jour, 'day DD')||' : 'end||p_vc_message;
     else
        apex_error.add_error( case when p_date_jour is not null then to_char(p_date_jour, 'day DD')||' : 'end||p_vc_message,null,apex_error.c_inline_in_notification);
     end if;
  end;
  /*  procedure p_ajout_mise_evidence(pda_date_jour in date,
                                  pvc_nom_champs in varchar2,
                                  pvc_co_couleur in varchar2) is
     vtp_champs_evidence tp_champs_evidence;
  begin
     vtp_champs_evidence.date_ligne :=pda_date_jour;
     vtp_champs_evidence.nom_champs :=pvc_nom_champs;
     vtp_champs_evidence.couleur :=pvc_co_couleur;
     vtp_evidence.extend;
     vtp_evidence(vtp_evidence.count):=vtp_champs_evidence;
  end;*/
  --
  -- Procédure qui valide les jours pour les internes.
  --
  procedure p_valid_ligne_jour_interne (p_rec_journee_saisissable   in rec_journee_saisissable%type,
                                        p_no_seq_feuil_temps        in fdtt_feuilles_temps.no_seq_feuil_temps%type,
										p_no_seq_ressource          in fdtt_feuilles_temps.no_seq_ressource%type,
                                        pva_mode_affichage_erreur   in varchar2,
                                        pva_message_info            in varchar2) as
     vnu_som_total_temps_activite number;
     --
     vnu_debut_am  number := 0;
     vnu_fin_am    number := 0;
     vnu_debut_pm  number := 0;
     vnu_fin_pm    number := 0;
     vnu_absence   number := 0;
     vnu_total_temps_jour_avec_acti number :=0;
     --
     vnu_absence_pm_fin number:=0;
     vnu_absence_pm_deb number:=0;
     vnu_absence_am_fin number:=0;
     vnu_absence_am_deb number:=0;
     vnu_absencett      number:=0;
     vnu_nb_minutes_usager number:=0;
     vnu_tot_temps_acti_vacances number := 0;
     -- Récupération des plages horaires obligatoires dans la base, conversion en minute
     vnu_h_plage_deb_am_obli        number;
     vnu_h_plage_fin_am_obli        number;
     vnu_h_plage_fin_am_si_conge_pm number;
 	 vnu_h_plage_deb_pm_obli        number;
     vnu_h_plage_fin_pm_obli        number;
     -- Récupération des heures SHQ dans la base, conversion en minute
     vnu_h_debut_am_shq number;
     vnu_h_fin_am_shq   number;
     vnu_h_debut_pm_shq number;
     vnu_h_fin_pm_shq   number;
     vdt_dern_jour_mois date;
     --
     vbo_resultat   boolean;
     vva_message    varchar2(4000);
     vva_type       varchar2(1);
     vnu_sum_crd_hor_en_jour number;
     vbo_test boolean;
     vnu_sum_crd_hor_en_jour_cour number;
	 --
     cursor cur_somme_total_temps_activite is
        select nvl(sum(act_tj.total_temps_min),0) as somme_total_temps_activite
        from fdtt_temps_jours act_tj
        where act_tj.no_seq_feuil_temps = p_no_seq_feuil_temps
          and act_tj.dt_temps_jour      = p_rec_journee_saisissable.dt_temps_jour
	      and act_tj.no_seq_activite    is not null; 
     --
	 cursor cur_somme_total_temps_activite_vacance is
        with act_vacances as(select act.no_seq_activite
                             from fdtt_activites act
                             where act.acronyme = '110')
        select nvl(sum(act_jour.total_temps_min),0) 
        from fdtt_temps_jours act_jour,
             act_vacances    vac
        where act_jour.no_seq_feuil_temps = p_no_seq_feuil_temps
         and  act_jour.dt_temps_jour      = p_rec_journee_saisissable.dt_temps_jour
         and  act_jour.no_seq_activite    = vac.no_seq_activite; 
     --
	 cursor cur_credit_horaire is
	 with act_credit_horaire as(select act.no_seq_activite
                           from fdtt_activites act
                           where act.acronyme = '122')
          select sum(act_jour.total_temps_min / fdt_fnb_apx_obt_nb_minutes_usager(p_no_seq_ressource,act_jour.dt_temps_jour)) as journee_credit_mois_actuel ,
                 sum(case when p_rec_journee_saisissable.dt_temps_jour = dt_temps_jour then act_jour.total_temps_min end) as nb_min_credit_horaire_jour_actuel
          from fdtt_temps_jours    act_jour,
               act_credit_horaire ch
          where act_jour.no_seq_feuil_temps = p_no_seq_feuil_temps
            and act_jour.dt_temps_jour      = p_rec_journee_saisissable.dt_temps_jour
            and act_jour.no_seq_activite    = ch.no_seq_activite;
      rec_credit_horaire  cur_credit_horaire%rowtype;
  begin
     -- Validation processus n°1 : 
	 -- Calcul du dernière jour de la période à valider 
	 vdt_dern_jour_mois := last_day(p_rec_journee_saisissable.dt_temps_jour);	
     -- Conversion des heures saisies en minutes
     vnu_debut_am := utl_fnb_cnv_minute(p_rec_journee_saisissable.dh_debut_am_temps);
     vnu_fin_am   := utl_fnb_cnv_minute(p_rec_journee_saisissable.dh_fin_am_temps);
     vnu_debut_pm := utl_fnb_cnv_minute(p_rec_journee_saisissable.dh_debut_pm_temps);
     vnu_fin_pm   := utl_fnb_cnv_minute(p_rec_journee_saisissable.dh_fin_pm_temps);	 
     --
     -- Récupération des plages horaires obligatoires dans la base, conversion en minute
     vnu_h_plage_deb_am_obli        := utl_fnb_cnv_minute(pil_fnb_obt_param_global('H_PLAGE_DEB_AM_OBLI',vdt_dern_jour_mois));
     vnu_h_plage_fin_am_obli        := utl_fnb_cnv_minute(pil_fnb_obt_param_global('H_PLAGE_FIN_AM_OBLI',vdt_dern_jour_mois));
     vnu_h_plage_fin_am_si_conge_pm := utl_fnb_cnv_minute(pil_fnb_obt_param_global('H_PLAGE_FIN_AM_SI_CONGE_PM',vdt_dern_jour_mois));
     vnu_h_plage_deb_pm_obli        := utl_fnb_cnv_minute(pil_fnb_obt_param_global('H_PLAGE_DEB_PM_OBLI',vdt_dern_jour_mois));
     vnu_h_plage_fin_pm_obli        := utl_fnb_cnv_minute(pil_fnb_obt_param_global('H_PLAGE_FIN_PM_OBLI',vdt_dern_jour_mois));
	 -- Récupération des heures SHQ dans la base, conversion en minute
     vnu_h_debut_am_shq := utl_fnb_cnv_minute(pil_fnb_obt_param_global('H_DEBUT_AM_SHQ',vdt_dern_jour_mois));
     vnu_h_fin_am_shq   := utl_fnb_cnv_minute(pil_fnb_obt_param_global('H_FIN_AM_SHQ',vdt_dern_jour_mois));
     vnu_h_debut_pm_shq := utl_fnb_cnv_minute(pil_fnb_obt_param_global('H_DEBUT_PM_SHQ',vdt_dern_jour_mois));
     vnu_h_fin_pm_shq   := utl_fnb_cnv_minute(pil_fnb_obt_param_global('H_FIN_PM_SHQ',vdt_dern_jour_mois));
	 --
     -- On va chercher la somme de toutes les activités de la journée
	 --
     open cur_somme_total_temps_activite;
        fetch cur_somme_total_temps_activite into vnu_som_total_temps_activite;
     close cur_somme_total_temps_activite;	  
	 --
     -- On va chercher la somme des activités vacances pour la journée
	 --
     open cur_somme_total_temps_activite_vacance;
        fetch cur_somme_total_temps_activite_vacance into vnu_tot_temps_acti_vacances;
     close cur_somme_total_temps_activite_vacance;	     
     --
     if (vnu_debut_am = 0 and vnu_fin_am = 0 and vnu_debut_pm = 0 and vnu_fin_pm = 0 and vnu_som_total_temps_activite = 0) then
        -- Il n'y a aucune saisie pour cette journée, on sort de la procédure
        if pva_mode_affichage_erreur <> 'AVERTISSEMENT' or pva_message_info = 'INFO_BOUTON_TRANSMETTRE' then
           -- La personne a transmise sa fdt.  On s'assure que tous les champs en saisis sont remplis.
           vva_message := utl_pkb_message.fc_obt_message('FDT.000034');
            p_ajout_message ( vva_message,pva_mode_affichage_erreur,p_rec_journee_saisissable.dt_temps_jour);
        else
           return;
        end if;
     end if;
     if (vnu_debut_am != 0 and vnu_fin_am != 0) and (vnu_fin_am < vnu_debut_am) then
        -- L'heure de fin am doit être plus grande que l'heure de debut am
        vva_message := utl_pkb_message.fc_obt_message('FDT.000024');
        p_ajout_message ( vva_message,pva_mode_affichage_erreur,p_rec_journee_saisissable.dt_temps_jour);
     end if;
     if (vnu_debut_pm != 0 and vnu_fin_pm != 0) and (vnu_fin_pm < vnu_debut_pm) then
        -- L'heure de fin pm doit être plus grande que l'heure de debut pm
        vva_message := utl_pkb_message.fc_obt_message('FDT.000024');
        p_ajout_message ( vva_message,pva_mode_affichage_erreur,p_rec_journee_saisissable.dt_temps_jour);
     end if;
     --
     -- Validation processus n°5
     if (vnu_debut_am != 0 and vnu_fin_am = 0) or (vnu_debut_am = 0 and vnu_fin_am != 0) or (vnu_debut_pm != 0 and vnu_fin_pm =0)  or (vnu_debut_pm = 0 and vnu_fin_pm != 0) then
        -- On ne peut pas saisir une heure de début ou fin d'une période sans saisir les deux valeurs.
        vva_message := utl_pkb_message.fc_obt_message('FDT.000006');
        p_ajout_message (  vva_message,pva_mode_affichage_erreur,p_rec_journee_saisissable.dt_temps_jour);
     end if;
     if vnu_fin_am !=0 and vnu_debut_pm != 0 then
        -- Il faut prendre un minimum de 45 minutes pour diner
        if (vnu_debut_pm - vnu_fin_am) < 45 then
           vva_message := utl_pkb_message.fc_obt_message('FDT.000013');
           p_ajout_message (  vva_message,pva_mode_affichage_erreur,p_rec_journee_saisissable.dt_temps_jour);
        end if;
     end if;
     -- Validation qui permet de valider des vacances en 1/2 ou journée entière
     if vnu_tot_temps_acti_vacances > 0 then
        if  fdt_fnb_apx_obt_nb_minutes_usager(p_no_seq_ressource, p_rec_journee_saisissable.dt_temps_jour) != vnu_tot_temps_acti_vacances then
           -- La personne n'a pas pris une journée de vancance complète
           if fdt_fnb_apx_verif_artt_usager(p_no_seq_ressource, p_rec_journee_saisissable.dt_temps_jour) then
              -- Personne en aménagement de temps de travail
              if (vnu_tot_temps_acti_vacances < utl_fnb_cnv_minute('3:00') or vnu_tot_temps_acti_vacances > utl_fnb_cnv_minute('4:45'))  then
                 vva_message := utl_pkb_message.fc_obt_message('FDT.000023');
                 p_ajout_message (  vva_message,pva_mode_affichage_erreur,p_rec_journee_saisissable.dt_temps_jour);
              end if;
           else
              -- Personne sans aménagement de temps de travail
              if vnu_tot_temps_acti_vacances != (fdt_fnb_apx_obt_nb_minutes_usager(p_no_seq_ressource, p_rec_journee_saisissable.dt_temps_jour) / 2)  then
                 vva_message := utl_pkb_message.fc_obt_message('FDT.000023');
                 p_ajout_message (  vva_message,pva_mode_affichage_erreur,p_rec_journee_saisissable.dt_temps_jour);
              end if;
           end if;
        end if;
     end if;
     -- Validation processus n°2
     -- cas ou l'employé vient en retard
     if vnu_debut_am != 0 then
         if vnu_debut_am > vnu_h_plage_deb_am_obli  then
            vnu_absence_am_deb := abs(vnu_debut_am - vnu_h_debut_am_shq);
            --p_ajout_mise_evidence(pda_date_jour =>p_rec_journee_saisissable.dt_temps_jour,
            --                       pvc_nom_champs =>'AM_DEB',
            --                       pvc_co_couleur =>'#ED7F10');
            vnu_absencett    := vnu_absencett + vnu_absence_am_deb;
         end if;
     end if;
     -- Cas ou l'employé part avant dîner
     if vnu_fin_am != 0 then
        if (vnu_fin_am < vnu_h_plage_fin_am_obli)   then
           vnu_absence_am_fin := abs(vnu_h_fin_am_shq - vnu_fin_am);
           --p_ajout_mise_evidence(pda_date_jour =>p_rec_journee_saisissable.dt_temps_jour,
           --                        pvc_nom_champs =>'AM_FIN',
           --                        pvc_co_couleur =>'#ED7F10');
           vnu_absencett    := vnu_absencett + vnu_absence_am_fin;
        end if;
     end if;
     -- Cas ou l'employé est en retard retour dîner
     if  vnu_debut_pm != 0 then
        if (vnu_debut_pm  > vnu_h_plage_deb_pm_obli) then
            vnu_absence_pm_deb  := abs(vnu_debut_pm - vnu_h_debut_pm_shq);
            --p_ajout_mise_evidence(pda_date_jour =>p_rec_journee_saisissable.dt_temps_jour,
            --                       pvc_nom_champs =>'PM_DEB',
            --                       pvc_co_couleur =>'#ED7F10');
            vnu_absencett     := vnu_absencett + vnu_absence_pm_deb;
        end if;
     end if;
     -- Cas ou l'employé part avant la descente
     if  vnu_fin_pm != 0 then
        if (vnu_fin_pm < vnu_h_plage_fin_pm_obli) then
           vnu_absence_pm_fin  := abs(vnu_fin_pm - vnu_h_fin_pm_shq);
           --p_ajout_mise_evidence(pda_date_jour =>p_rec_journee_saisissable.dt_temps_jour,
           --                        pvc_nom_champs =>'PM_FIN',
           --                        pvc_co_couleur =>'#ED7F10');
           vnu_absencett := vnu_absencett + vnu_absence_pm_fin;
        end if;
     end if;
     --
     -- Validation processus n°4
     if (vnu_debut_am = 0 and vnu_fin_am = 0 and vnu_debut_pm = 0 and vnu_fin_pm = 0) then
        -- Aucune saisie n'est enregistrée pour la journée
        -- Pour les horaires spéciales 7h47
        if fdt_fnb_apx_obt_nb_minutes_usager(p_no_seq_ressource, p_rec_journee_saisissable.dt_temps_jour) != vnu_som_total_temps_activite then
           if pva_message_info = 'AVERTISSEMENT' then
              vva_message := utl_pkb_message.fc_obt_message('FDT.000004',null, FDT_PKB_APX_UTIL_TEMPS.convert_format_heure(fdt_fnb_apx_obt_nb_minutes_usager(p_no_seq_ressource, p_rec_journee_saisissable.dt_temps_jour)));
              p_ajout_message (  vva_message,pva_mode_affichage_erreur,p_rec_journee_saisissable.dt_temps_jour);
           end if;       
        end if;
     else
        -- Processus de validation 3
        if (vnu_debut_am = 0 and vnu_fin_am = 0) or (vnu_debut_pm = 0 and vnu_fin_pm = 0) then
           if vnu_som_total_temps_activite = 0 then
              vva_message := utl_pkb_message.fc_obt_message('FDT.000026');
              p_ajout_message (  vva_message,pva_mode_affichage_erreur,p_rec_journee_saisissable.dt_temps_jour);
           else
              if fdt_fnb_apx_verif_artt_usager(p_no_seq_ressource, p_rec_journee_saisissable.dt_temps_jour) then
                 -- Personne avec aménagement de temps de travail
                 if (vnu_som_total_temps_activite < utl_fnb_cnv_minute('3:00') +  vnu_absencett)  then
                    vva_message := utl_pkb_message.fc_obt_message('FDT.000005');
                    p_ajout_message (  vva_message,pva_mode_affichage_erreur,p_rec_journee_saisissable.dt_temps_jour);
                 end if;
              else
                 -- Personne sans aménagement de temps de travail
                 if vnu_som_total_temps_activite != (fdt_fnb_apx_obt_nb_minutes_usager(p_no_seq_ressource, p_rec_journee_saisissable.dt_temps_jour) / 2) +  vnu_absencett  then
                    vva_message := utl_pkb_message.fc_obt_message('FDT.000005');
                    p_ajout_message (  vva_message,pva_mode_affichage_erreur,p_rec_journee_saisissable.dt_temps_jour);
                 end if;
              end if;
           end if;
           if (vnu_debut_am != 0 and vnu_fin_am != 0) and vnu_som_total_temps_activite >= utl_fnb_cnv_minute('3:00') then
              -- ajout à faire ici shqcge
	          if vnu_fin_am > vnu_h_plage_fin_am_si_conge_pm then
                 vva_message := utl_pkb_message.fc_obt_message('FDT.000032',pil_fnb_obt_param_global('H_PLAGE_FIN_AM_SI_CONGE_PM'));
                 p_ajout_message (  vva_message,pva_mode_affichage_erreur,p_rec_journee_saisissable.dt_temps_jour);
              end if;
           end if; 
        else
           -- La personne a saisi du temps en avant midi et en après midi, mais a une absence sur plage fixe.
           if vnu_absencett != 0 then
              if fdt_fnb_apx_verif_artt_usager(p_no_seq_ressource,p_rec_journee_saisissable.dt_temps_jour) is null then
                 vbo_resultat := utl_pkb_message.lire_message ('ZZZ.000017', null, vva_type, vva_message); --paramètre usager inexistant
                 p_ajout_message (  vva_message,pva_mode_affichage_erreur,p_rec_journee_saisissable.dt_temps_jour);
              else
                 apex_debug.message('ligne 300');
                 if fdt_fnb_apx_verif_artt_usager(p_no_seq_ressource, p_rec_journee_saisissable.dt_temps_jour) then
                 -- Personne avec aménagement de temps de travail
                    if not( vnu_som_total_temps_activite >= vnu_absencett) then
                       vva_message := utl_pkb_message.fc_obt_message('FDT.000001');
                       p_ajout_message ( vva_message,pva_mode_affichage_erreur,p_rec_journee_saisissable.dt_temps_jour);
                    end if;
                 else
                    if vnu_som_total_temps_activite != vnu_absencett then
                       vva_message := utl_pkb_message.fc_obt_message('FDT.000001');
                       p_ajout_message (  vva_message,pva_mode_affichage_erreur,p_rec_journee_saisissable.dt_temps_jour);                 
                    end if;
                 end if;
              end if;
           end if;
           --
        end if;
     end if;
     -- Validation processus n°6
     if vnu_debut_am != 0 and vnu_fin_am != 0 then
        vnu_total_temps_jour_avec_acti := vnu_total_temps_jour_avec_acti + (vnu_fin_am - vnu_debut_am);
     end if;
     if vnu_debut_pm != 0 and vnu_fin_pm != 0 then
        vnu_total_temps_jour_avec_acti := vnu_total_temps_jour_avec_acti + (vnu_fin_pm - vnu_debut_pm);
     end if;
     vnu_total_temps_jour_avec_acti := vnu_total_temps_jour_avec_acti + vnu_som_total_temps_activite;
     if vnu_total_temps_jour_avec_acti > 585 then -- 9:45 = 585 minutes
        vva_message := utl_pkb_message.fc_obt_message('FDT.000007');
        p_ajout_message (  vva_message,pva_mode_affichage_erreur,p_rec_journee_saisissable.dt_temps_jour);
     end if;
	 --
     --Validation processus n°7
     --
     open cur_credit_horaire;
        fetch cur_credit_horaire into rec_credit_horaire;
     close cur_credit_horaire;		           
     --
	 -- Validation pour crédit horaire dans un mois.
	 -- 
	 if rec_credit_horaire.journee_credit_mois_actuel > 2 and rec_credit_horaire.nb_min_credit_horaire_jour_actuel > 0 then
        -- Pas le droit dfe prendre plus de 2 crédits horaires dans le mois.
        vbo_resultat := utl_pkb_message.lire_message ('FDT.000002', null, vva_type, vva_message);
        p_ajout_message ( vva_message,pva_mode_affichage_erreur,p_rec_journee_saisissable.dt_temps_jour);
     end if;
  END P_VALID_LIGNE_JOUR_INTERNE; 
  --
  -- Procédure qui valide 
  --
  procedure p_valid_ligne_jour_externe (p_rec_journee_saisissable in rec_journee_saisissable%type,
                                        pva_mode_affichage_erreur in varchar2)
  as
     --
     vnu_debut_am  number := 0;
     vnu_fin_am    number := 0;
     vnu_debut_pm  number := 0;
     vnu_fin_pm    number := 0;
     vnu_total_temps_jour_avec_acti number :=0;
     --
     vbo_resultat   boolean;
     vva_message    varchar2(4000);
     vva_type       varchar2(1);
     vbo_test boolean;
     --
  begin
     -- Validation processus n°1 
     -- Conversion des heures saisies en minutes
     vnu_debut_am := utl_fnb_cnv_minute(p_rec_journee_saisissable.dh_debut_am_temps);
     vnu_fin_am   := utl_fnb_cnv_minute(p_rec_journee_saisissable.dh_fin_am_temps);
     vnu_debut_pm := utl_fnb_cnv_minute(p_rec_journee_saisissable.dh_debut_pm_temps);
     vnu_fin_pm   := utl_fnb_cnv_minute(p_rec_journee_saisissable.dh_fin_pm_temps);
     --
     if (vnu_debut_am = 0 and vnu_fin_am = 0 and vnu_debut_pm = 0 and vnu_fin_pm = 0) then
        -- Il n'y a aucune saisie pour cette journée, on sort de la procédure
        return;
     end if;
     if (vnu_debut_am != 0 and vnu_fin_am != 0) and (vnu_fin_am < vnu_debut_am) then
        -- L'heure de fin am doit être plus grande que l'heure de debut am
        vva_message := utl_pkb_message.fc_obt_message('FDT.000024');
     end if;
     if (vnu_debut_pm != 0 and vnu_fin_pm != 0) and (vnu_fin_pm < vnu_debut_pm) then
        -- L'heure de fin pm doit être plus grande que l'heure de debut pm
        vva_message := utl_pkb_message.fc_obt_message('FDT.000024');
        p_ajout_message ( vva_message,pva_mode_affichage_erreur,p_rec_journee_saisissable.dt_temps_jour);
     end if;
     --
     if (vnu_debut_am != 0 and vnu_fin_am = 0) or (vnu_debut_am = 0 and vnu_fin_am != 0) or (vnu_debut_pm != 0 and vnu_fin_pm =0)  or (vnu_debut_pm = 0 and vnu_fin_pm != 0) then
        -- On ne peut pas saisir une heure de début ou fin d'une période sans saisir les deux valeurs.
        vva_message := utl_pkb_message.fc_obt_message('FDT.000006');
        p_ajout_message ( vva_message,pva_mode_affichage_erreur,p_rec_journee_saisissable.dt_temps_jour);
     end if;
     if vnu_fin_am !=0 and vnu_debut_pm != 0 then
        -- Il faut prendre un minimum de 45 minutes pour diner
        if (vnu_debut_pm - vnu_fin_am) < 45 then
           vva_message := utl_pkb_message.fc_obt_message('FDT.000013');
           p_ajout_message (  vva_message,pva_mode_affichage_erreur,p_rec_journee_saisissable.dt_temps_jour);
        end if;
     end if;
     --
  END p_valid_ligne_jour_externe;
  --
  procedure p_valdt_infrm_temps(pnu_no_seq_ressource in fdtt_feuilles_temps.no_seq_ressource%type,
                                pva_an_mois_fdt      in fdtt_feuilles_temps.an_mois_fdt%type,
                                pva_mode_affichage_erreur in varchar2 default 'AVERTISSEMENT',
                                pva_message_info          in varchar2 default 'AVERTISSEMENT') is
     -- On calcul la dernière journée de la période pour aller chercher les différents paramètres.
     vdt_dernier_jour_mois   date         := last_day(to_date(pva_an_mois_fdt||'01','yyyymmdd')); 	 
     -- Récupération des plages horaires dans la base
     --vva_H_PLAGE_DEB_AM_MIN pilt_valeur_parametre_global.VAL_PARAMETRE_G%type := pil_fnb_obt_param_global('H_PLAGE_DEB_AM_MIN',vdt_dernier_jour_mois);
     --vva_H_PLAGE_DEB_AM_MAX pilt_valeur_parametre_global.VAL_PARAMETRE_G%type := pil_fnb_obt_param_global('H_PLAGE_DEB_AM_MAX',vdt_dernier_jour_mois);
     --vva_H_PLAGE_FIN_AM_MIN pilt_valeur_parametre_global.VAL_PARAMETRE_G%type := pil_fnb_obt_param_global('H_PLAGE_FIN_AM_MIN',vdt_dernier_jour_mois);
     --vva_H_PLAGE_FIN_AM_MAX pilt_valeur_parametre_global.VAL_PARAMETRE_G%type := pil_fnb_obt_param_global('H_PLAGE_FIN_AM_MAX',vdt_dernier_jour_mois);
     --vva_H_PLAGE_DEB_PM_MIN pilt_valeur_parametre_global.VAL_PARAMETRE_G%type := pil_fnb_obt_param_global('H_PLAGE_DEB_PM_MIN',vdt_dernier_jour_mois);
     --vva_H_PLAGE_DEB_PM_MAX pilt_valeur_parametre_global.VAL_PARAMETRE_G%type := pil_fnb_obt_param_global('H_PLAGE_DEB_PM_MAX',vdt_dernier_jour_mois);
     --vva_H_PLAGE_FIN_PM_MIN pilt_valeur_parametre_global.VAL_PARAMETRE_G%type := pil_fnb_obt_param_global('H_PLAGE_FIN_PM_MIN',vdt_dernier_jour_mois);
     --vva_H_PLAGE_FIN_PM_MAX pilt_valeur_parametre_global.VAL_PARAMETRE_G%type := pil_fnb_obt_param_global('H_PLAGE_FIN_PM_MAX',vdt_dernier_jour_mois);
	 vva_H_PLAGE_DEB_AM_MIN varchar2(200) := pil_fnb_obt_param_global('H_PLAGE_DEB_AM_MIN',vdt_dernier_jour_mois);
     vva_H_PLAGE_DEB_AM_MAX varchar2(200) := pil_fnb_obt_param_global('H_PLAGE_DEB_AM_MAX',vdt_dernier_jour_mois);
     vva_H_PLAGE_FIN_AM_MIN varchar2(200) := pil_fnb_obt_param_global('H_PLAGE_FIN_AM_MIN',vdt_dernier_jour_mois);
     vva_H_PLAGE_FIN_AM_MAX varchar2(200) := pil_fnb_obt_param_global('H_PLAGE_FIN_AM_MAX',vdt_dernier_jour_mois);
     vva_H_PLAGE_DEB_PM_MIN varchar2(200) := pil_fnb_obt_param_global('H_PLAGE_DEB_PM_MIN',vdt_dernier_jour_mois);
     vva_H_PLAGE_DEB_PM_MAX varchar2(200) := pil_fnb_obt_param_global('H_PLAGE_DEB_PM_MAX',vdt_dernier_jour_mois);
     vva_H_PLAGE_FIN_PM_MIN varchar2(200) := pil_fnb_obt_param_global('H_PLAGE_FIN_PM_MIN',vdt_dernier_jour_mois);
     vva_H_PLAGE_FIN_PM_MAX varchar2(200) := pil_fnb_obt_param_global('H_PLAGE_FIN_PM_MAX',vdt_dernier_jour_mois);
     -- Récupération des plages horaires obligatioires, conversion en minute
     vnu_H_PLAGE_DEB_AM_MIN number := utl_fnb_cnv_minute(pil_fnb_obt_param_global('H_PLAGE_DEB_AM_MIN',vdt_dernier_jour_mois));
     vnu_H_PLAGE_DEB_AM_MAX number := utl_fnb_cnv_minute(pil_fnb_obt_param_global('H_PLAGE_DEB_AM_MAX',vdt_dernier_jour_mois));
     vnu_H_PLAGE_FIN_AM_MIN number := utl_fnb_cnv_minute(pil_fnb_obt_param_global('H_PLAGE_FIN_AM_MIN',vdt_dernier_jour_mois));
     vnu_H_PLAGE_FIN_AM_MAX number := utl_fnb_cnv_minute(pil_fnb_obt_param_global('H_PLAGE_FIN_AM_MAX',vdt_dernier_jour_mois));
     vnu_H_PLAGE_DEB_PM_MIN number := utl_fnb_cnv_minute(pil_fnb_obt_param_global('H_PLAGE_DEB_PM_MIN',vdt_dernier_jour_mois));
     vnu_H_PLAGE_DEB_PM_MAX number := utl_fnb_cnv_minute(pil_fnb_obt_param_global('H_PLAGE_DEB_PM_MAX',vdt_dernier_jour_mois));
     vnu_H_PLAGE_FIN_PM_MIN number := utl_fnb_cnv_minute(pil_fnb_obt_param_global('H_PLAGE_FIN_PM_MIN',vdt_dernier_jour_mois));
     vnu_H_PLAGE_FIN_PM_MAX number := utl_fnb_cnv_minute(pil_fnb_obt_param_global('H_PLAGE_FIN_PM_MAX',vdt_dernier_jour_mois));
     --
     vva_co_interne_exter varchar2(1);
	 --
     --
     cursor cur_feuille_anterieur_a_corriger is
        select  to_char(to_date(sft.an_mois_fdt,'yyyymm'), 'Month YYYY') valeur
        from fdtt_feuilles_temps fdt
            ,fdtt_suivi_feuilles_temps sft
        where fdt.no_seq_ressource   = pnu_no_seq_ressource
          and fdt.no_seq_feuil_temps = sft.no_seq_feuil_temps
          and fdt.ind_saisie_autorisee = 'O'
          and sft.co_typ_suivi_fdt IN ('A_CORRIGER')  
          and sft.an_mois_fdt < pva_an_mois_fdt
          and sft.no_seq_suivi_fdt = (select max(sui.no_seq_suivi_fdt)
                                      from fdtt_suivi_feuilles_temps sui 
                                      where sft.no_seq_feuil_temps = sui.no_seq_feuil_temps
                                        and sft.an_mois_fdt        = sui.an_mois_fdt); 
     rec_feuille_anterieur_a_corriger   cur_feuille_anterieur_a_corriger%rowtype;
     --
     cursor cur_fdt_actuelle_et_employe is
        select fdt.no_seq_feuil_temps, emp.co_employe_shq, emp.co_interne_exter
        from fdtt_feuilles_temps   fdt,
             fdtt_ressource       res,
             busv_info_employe    emp
        where fdt.no_seq_ressource = pnu_no_seq_ressource
          and fdt.an_mois_fdt      = pva_an_mois_fdt
          and res.no_seq_ressource = fdt.no_seq_ressource
          and emp.co_employe_shq   = res.co_employe_shq;
     rec_fdt_actuelle_et_employe   cur_fdt_actuelle_et_employe%rowtype;
  begin
     --vtp_evidence :=new tp_evidence();
     --vtp_avertissement :=new tp_avertissement();
     --
     -- On va chercher la fdt qu'on traite actuellement
     open cur_fdt_actuelle_et_employe;
        fetch cur_fdt_actuelle_et_employe into rec_fdt_actuelle_et_employe;
     close cur_fdt_actuelle_et_employe;	 
     --
     -- Vérifier qu'aucune feuille antérieur n'est à corriger, sinon on met un message en ce sens.
     --
     for rec_feuille_anterieur_a_corriger in cur_feuille_anterieur_a_corriger
     loop
           p_ajout_message(utl_pkb_message.fc_obt_message('FDT.000030', rec_feuille_anterieur_a_corriger.valeur),pva_mode_affichage_erreur,null);
        end loop;
     --
     --Validation des différentes journées
     for rec_journee_saisissable in cur_journee_saisissable(rec_fdt_actuelle_et_employe.no_seq_feuil_temps)
     loop
        --
        if rec_fdt_actuelle_et_employe.co_interne_exter = 'I' then
           --
           --VALIDATION DES PLAGES ARRIVÉ / DÉPART
           --
           if rec_journee_saisissable.num_debutam != 0 then
              if rec_journee_saisissable.num_debutam not between vnu_H_PLAGE_DEB_AM_MIN and vnu_H_PLAGE_DEB_AM_MAX then
                 p_ajout_message(utl_pkb_message.fc_obt_message('FDT.000014', vva_H_PLAGE_DEB_AM_MIN, vva_H_PLAGE_DEB_AM_MAX),pva_mode_affichage_erreur,rec_journee_saisissable.dt_temps_jour);
                 --p_ajout_mise_evidence(pda_date_jour =>rec_journee_saisissable.dt_temps_jour,
                 --                           pvc_nom_champs =>'AM_DEB',
                 --                           pvc_co_couleur =>'red');
              end if;
           end if;
           --
           if rec_journee_saisissable.num_finam != 0  then
              if rec_journee_saisissable.num_finAM not between vnu_H_PLAGE_FIN_AM_MIN and vnu_H_PLAGE_FIN_AM_MAX then
                 p_ajout_message( utl_pkb_message.fc_obt_message('FDT.000015', vva_H_PLAGE_FIN_AM_MIN, vva_H_PLAGE_FIN_AM_MAX),pva_mode_affichage_erreur,rec_journee_saisissable.dt_temps_jour);
                 --p_ajout_mise_evidence(pda_date_jour =>rec_journee_saisissable.dt_temps_jour,
                 --                              pvc_nom_champs =>'AM_FIN',
                 --                              pvc_co_couleur =>'red');
              end if;
           end if;
           --
           if rec_journee_saisissable.num_debutPM != 0 then
              if rec_journee_saisissable.num_debutPM not between vnu_H_PLAGE_DEB_PM_MIN and vnu_H_PLAGE_DEB_PM_MAX then
                 p_ajout_message( utl_pkb_message.fc_obt_message('FDT.000016', vva_H_PLAGE_DEB_PM_MIN, vva_H_PLAGE_DEB_PM_MAX),pva_mode_affichage_erreur,rec_journee_saisissable.dt_temps_jour);
                 --p_ajout_mise_evidence(pda_date_jour =>rec_journee_saisissable.dt_temps_jour,
                 --                              pvc_nom_champs =>'PM_DEB',
                 --                              pvc_co_couleur =>'red');
              end if;
           end if;
           --
           if rec_journee_saisissable.num_finPM != 0 then
              if rec_journee_saisissable.num_finPM not between vnu_H_PLAGE_FIN_PM_MIN and vnu_H_PLAGE_FIN_PM_MAX then
                 p_ajout_message( utl_pkb_message.fc_obt_message('FDT.000017', vva_H_PLAGE_FIN_PM_MIN, vva_H_PLAGE_FIN_PM_MAX),pva_mode_affichage_erreur,rec_journee_saisissable.dt_temps_jour);
                 --p_ajout_mise_evidence(pda_date_jour =>rec_journee_saisissable.dt_temps_jour,
                 --                               pvc_nom_champs =>'PM_FIN',
                 --                               pvc_co_couleur =>'red');
              end if;
           end if;
           --
           p_valid_ligne_jour_interne(rec_journee_saisissable,rec_fdt_actuelle_et_employe.no_seq_feuil_temps,pnu_no_seq_ressource,pva_mode_affichage_erreur,pva_message_info);
        else
           p_valid_ligne_jour_externe(rec_journee_saisissable,pva_mode_affichage_erreur);
        end if;
     end loop;
     -- À enlever après les tests
     --if vtp_avertissement.count > 0 then
     --   for i in 1..vtp_avertissement.count loop
     --      dbms_output.put_line(vtp_avertissement(i));
     --   end loop;
     --else 
     --   dbms_output.put_line('Pas de messsage');   
     --end if;
--
	 --exception when others then 
	 --                apex_debug.info ('Exception p_valdt_infrm_temps %s', sqlerrm);
	 --				 raise;
  end;
  --
  /*function f_obten_evdnc(pda_date_ligne in date,
                         pvc_nom_champs in varchar2)return varchar2 is
    vvc_retour varchar2(1000);
  begin
    for i in 1..vtp_evidence.count loop
      if vtp_evidence(i).date_ligne = pda_date_ligne
         and vtp_evidence(i).nom_champs = pvc_nom_champs then
         vvc_retour:=vvc_retour||case when vtp_evidence(i).couleur like '#%' then 'background-color:'||vtp_evidence(i).couleur||';'
                                                                                 else 'border-color:'||vtp_evidence(i).couleur||';' end;

      end if;
    end loop;
    return case when vvc_retour is not null then 'style="'||vvc_retour||'"' end;
  end;*/
      ------------------------------------------------------------------------------------------------------------
  -- Permet d'envoyer en pipeline la liste des messages d'erreurs.
  ------------------------------------------------------------------------------------------------------------ 
  function f_obtenir_message_fdt(pnu_no_seq_ressource      in fdtt_feuilles_temps.no_seq_ressource%type,
                                 pva_an_mois_fdt           in fdtt_feuilles_temps.an_mois_fdt%type,
                                 pva_mode_affichage_erreur in varchar2 default 'AVERTISSEMENT',
                                 pva_message_info          in varchar2 default 'AVERTISSEMENT')
    return tp_avertissement
    pipelined is
    --
    vta_pipe_message_fdt FDT_PKB_APX_VALDT_TEMPS.tp_avertissement;
    --vta_pipe_message_fdt apex_t_varchar2;
    --
    -- logger
    --
    vva_scope  logger_logs.scope%type := cva_scope_prefix || 'f_obtenir_message_fdt';
    vta_params logger.tab_param;
    --
    --  
  begin
    
    -- On valide 
    fdt_pkb_apx_valdt_temps.p_valdt_infrm_temps(pnu_no_seq_ressource => pnu_no_seq_ressource,
                                                pva_an_mois_fdt      => pva_an_mois_fdt,
                                                pva_mode_affichage_erreur => pva_mode_affichage_erreur,
                                                pva_message_info          => pva_message_info);
    --   
    --if fdt_pkb_apx_valdt_temps.vtp_avertissement.count > 0 then
    --  for i in fdt_pkb_apx_valdt_temps.vtp_avertissement.first .. fdt_pkb_apx_valdt_temps.vtp_avertissement.last loop
    --     vta_pipe_message_fdt.extend(1);
    --     vta_pipe_message_fdt(i) := fdt_pkb_apx_valdt_temps.vtp_avertissement(i);    
    --  end loop;
   --end if;
   vta_pipe_message_fdt := fdt_pkb_apx_valdt_temps.vtp_avertissement;
    -- 
    <<retourner_messages_fdt>>
    if fdt_pkb_apx_valdt_temps.vtp_avertissement.count > 0 Then
      for indx in vta_pipe_message_fdt.first .. vta_pipe_message_fdt.last loop
        --
        pipe row(vta_pipe_message_fdt(indx));
        --
      end loop retourner_messages_fdt;
    end if;      
  end f_obtenir_message_fdt;
end FDT_PKB_APX_VALDT_TEMPS;
/
