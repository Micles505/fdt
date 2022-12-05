  CREATE OR REPLACE PACKAGE BODY "FDT_PKB_VALDT_TEMPS" as
  procedure p_ajout_message (p_vc_message in varchar2,
                             p_vcmode in varchar2,
                             p_date_jour in date default null) is
  begin
    if p_vcmode = 'AVERTISSEMENT' then
      vtp_avertissement.extend;
      vtp_avertissement(vtp_avertissement.count):=case when p_date_jour is not null then to_char(p_date_jour, 'day DD')||' : 'end||p_vc_message;
    else
      apex_error.add_error( case when p_date_jour is not null then to_char(p_date_jour, 'day DD')||' : 'end||p_vc_message,null,apex_error.c_inline_in_notification);
   end if;
  end;
  procedure p_ajout_mise_evidence(pda_date_jour in date,
                                  pvc_nom_champs in varchar2,
                                  pvc_co_couleur in varchar2) is
    vtp_champs_evidence tp_champs_evidence;
  begin
    vtp_champs_evidence.date_ligne :=pda_date_jour;
    vtp_champs_evidence.nom_champs :=pvc_nom_champs;
    vtp_champs_evidence.couleur :=pvc_co_couleur;
    vtp_evidence.extend;
    vtp_evidence(vtp_evidence.count):=vtp_champs_evidence;
  end;

  procedure p_valid_lign_jour (pro_rowid rowid,
                               p_vcmode in varchar2) as
    vnu_som_total_temps_activite number;
    vda_dh_debut_pm_temps date;
    vda_dh_fin_am_temps date;
    vda_dh_debut_am_temps date;
    vda_dh_fin_pm_temps date;
    vnu_co_employe_shq number;
    vnu_an_mois_fdt number;
    vda_dt_temps_jour date;
    vda_dt_activite_temps date;
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
  begin
    -- Validation processus n°1 : Recherche des informations dans les tables FDTT_TEMPS_JOUR et FDTT_ACTIVITE_TEMPS
    select  max(tmp_jour.dh_debut_pm_temps),
            max(tmp_jour.dh_fin_am_temps),
            max(tmp_jour.dh_debut_am_temps),
            max(tmp_jour.dh_fin_pm_temps),
            max(tmp_jour.an_mois_fdt),
            max(tmp_jour.co_employe_shq),
            max(tmp_jour.dt_temps_jour)
      into  vda_dh_debut_pm_temps,
            vda_dh_fin_am_temps ,
            vda_dh_debut_am_temps ,
            vda_dh_fin_pm_temps ,
            vnu_an_mois_fdt,
            vnu_co_employe_shq,
            vda_dt_temps_jour
    from fdtt_temps_jour tmp_jour
    where tmp_jour.rowid  = pro_rowid;
	-- Calcul du dernière jour de la période à valider
	vdt_dern_jour_mois := last_day(vda_dt_temps_jour);	
    -- Conversion des heures saisies en minutes
    vnu_debut_am := utl_fnb_cnv_minute(to_char(vda_dh_debut_am_temps, 'HH24:MI'));
    vnu_fin_am   := utl_fnb_cnv_minute(to_char(vda_dh_fin_am_temps, 'HH24:MI'));
    vnu_debut_pm := utl_fnb_cnv_minute(to_char(vda_dh_debut_pm_temps, 'HH24:MI'));
    vnu_fin_pm   := utl_fnb_cnv_minute(to_char(vda_dh_fin_pm_temps, 'HH24:MI'));
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
    select nvl(sum(act_jour.total_temps),0) into vnu_som_total_temps_activite
    from fdtt_activite_temps act_jour
    where act_jour.an_mois_fdt       = vnu_an_mois_fdt
     and  act_jour.co_employe_shq    = vnu_co_employe_shq
     and  act_jour.dt_activite_temps = vda_dt_temps_jour;
    --
    select nvl(sum(act_jour.total_temps),0) into vnu_tot_temps_acti_vacances
    from fdtt_activite_temps act_jour
    where act_jour.an_mois_fdt       = vnu_an_mois_fdt
     and  act_jour.co_employe_shq    = vnu_co_employe_shq
     and  act_jour.dt_activite_temps = vda_dt_temps_jour
     and  act_jour.id_activite = 110;
    --
    if (vnu_debut_am = 0 and vnu_fin_am = 0 and vnu_debut_pm = 0 and vnu_fin_pm = 0 and vnu_som_total_temps_activite = 0) then
       -- Il n'y a aucune saisie pour cette journée, on sort de la procédure
       return;
    end if;
    if (vnu_debut_am != 0 and vnu_fin_am != 0) and (vnu_fin_am < vnu_debut_am) then
       -- L'heure de fin am doit être plus grande que l'heure de debut am
       vva_message := utl_pkb_message.fc_obt_message('FDT.000024');
       p_ajout_message ( vva_message,p_vcmode,vda_dt_temps_jour);
    end if;
    if (vnu_debut_pm != 0 and vnu_fin_pm != 0) and (vnu_fin_pm < vnu_debut_pm) then
       -- L'heure de fin pm doit être plus grande que l'heure de debut pm
       vva_message := utl_pkb_message.fc_obt_message('FDT.000024');
       p_ajout_message ( vva_message,p_vcmode,vda_dt_temps_jour);
    end if;
    --
    -- Validation processus n°5
    if (vnu_debut_am != 0 and vnu_fin_am = 0) or (vnu_debut_am = 0 and vnu_fin_am != 0) or (vnu_debut_pm != 0 and vnu_fin_pm =0)  or (vnu_debut_pm = 0 and vnu_fin_pm != 0) then
       -- On ne peut pas saisir une heure de début ou fin d'une période sans saisir les deux valeurs.
       vva_message := utl_pkb_message.fc_obt_message('FDT.000006');
       p_ajout_message (  vva_message,p_vcmode,vda_dt_temps_jour);
    end if;
    if vnu_fin_am !=0 and vnu_debut_pm != 0 then
       -- Il faut prendre un minimum de 45 minutes pour diner
       if (vnu_debut_pm - vnu_fin_am) < 45 then
          vva_message := utl_pkb_message.fc_obt_message('FDT.000013');
          p_ajout_message (  vva_message,p_vcmode,vda_dt_temps_jour);
       end if;
    end if;
    -- Validation qui permet de valider des vacances en 1/2 ou journée entière
    if vnu_tot_temps_acti_vacances > 0 then
       if  fdt_fnb_obt_nb_minutes_usager(vnu_co_employe_shq, vda_dt_temps_jour) != vnu_tot_temps_acti_vacances then
          -- La personne n'a pas pris une journée de vancance complète
          if fdt_fnb_verif_artt_usager(vnu_co_employe_shq, vda_dt_temps_jour) then
              -- Personne en aménagement de temps de travail
             if (vnu_tot_temps_acti_vacances < utl_fnb_cnv_minute('3:00') or vnu_tot_temps_acti_vacances > utl_fnb_cnv_minute('4:45'))  then
                vva_message := utl_pkb_message.fc_obt_message('FDT.000023');
                p_ajout_message (  vva_message,p_vcmode,vda_dt_temps_jour);
             end if;
          else
             -- Personne sans aménagement de temps de travail
             if vnu_tot_temps_acti_vacances != (fdt_fnb_obt_nb_minutes_usager(vnu_co_employe_shq, vda_dt_temps_jour) / 2)  then
                vva_message := utl_pkb_message.fc_obt_message('FDT.000023');
                p_ajout_message (  vva_message,p_vcmode,vda_dt_temps_jour);
             end if;
          end if;
       end if;
    end if;
    -- Validation processus n°2
    -- cas ou l'employé vient en retard
    if vnu_debut_am != 0 then
        if vnu_debut_am > vnu_h_plage_deb_am_obli  then
           vnu_absence_am_deb := abs(vnu_debut_am - vnu_h_debut_am_shq);
           p_ajout_mise_evidence(pda_date_jour =>vda_dt_temps_jour,
                                  pvc_nom_champs =>'AM_DEB',
                                  pvc_co_couleur =>'#ED7F10');
           vnu_absencett    := vnu_absencett + vnu_absence_am_deb;
        end if;
    end if;
    -- Cas ou l'employé part avant dîner
    if vnu_fin_am != 0 then
       if (vnu_fin_am < vnu_h_plage_fin_am_obli)   then
          vnu_absence_am_fin := abs(vnu_h_fin_am_shq - vnu_fin_am);
           p_ajout_mise_evidence(pda_date_jour =>vda_dt_temps_jour,
                                  pvc_nom_champs =>'AM_FIN',
                                  pvc_co_couleur =>'#ED7F10');
          vnu_absencett    := vnu_absencett + vnu_absence_am_fin;
       end if;
    end if;
    -- Cas ou l'employé est en retard retour dîner
    if  vnu_debut_pm != 0 then
       if (vnu_debut_pm  > vnu_h_plage_deb_pm_obli) then
           vnu_absence_pm_deb  := abs(vnu_debut_pm - vnu_h_debut_pm_shq);
           p_ajout_mise_evidence(pda_date_jour =>vda_dt_temps_jour,
                                  pvc_nom_champs =>'PM_DEB',
                                  pvc_co_couleur =>'#ED7F10');
           vnu_absencett     := vnu_absencett + vnu_absence_pm_deb;
       end if;
    end if;
    -- Cas ou l'employé part avant la descente
    if vnu_fin_pm != 0 then
       if (vnu_fin_pm < vnu_h_plage_fin_pm_obli) then
          vnu_absence_pm_fin  := abs(vnu_fin_pm - vnu_h_fin_pm_shq);
           p_ajout_mise_evidence(pda_date_jour =>vda_dt_temps_jour,
                                  pvc_nom_champs =>'PM_FIN',
                                  pvc_co_couleur =>'#ED7F10');
          vnu_absencett := vnu_absencett + vnu_absence_pm_fin;
       end if;
    end if;
    --
    -- Validation processus n°4
    if (vnu_debut_am = 0 and vnu_fin_am = 0 and vnu_debut_pm = 0 and vnu_fin_pm = 0) then
       -- Aucune saisie n'est enregistrée pour la journée
       -- Pour les horaires spéciales 7h47
       if fdt_fnb_obt_nb_minutes_usager(vnu_co_employe_shq, vda_dt_temps_jour) != vnu_som_total_temps_activite then
             vva_message := utl_pkb_message.fc_obt_message('FDT.000004',null, FDT_PKB_UTIL_TEMPS.convert_format_heure(fdt_fnb_obt_nb_minutes_usager(vnu_co_employe_shq, vda_dt_temps_jour)));
             p_ajout_message (  vva_message,p_vcmode,vda_dt_temps_jour);
       end if;
    else
       -- Processus de validation 3
       if (vnu_debut_am = 0 and vnu_fin_am = 0) or (vnu_debut_pm = 0 and vnu_fin_pm = 0) then
          if vnu_som_total_temps_activite = 0 then
             vva_message := utl_pkb_message.fc_obt_message('FDT.000026');
             p_ajout_message (  vva_message,p_vcmode,vda_dt_temps_jour);
          else
             if fdt_fnb_verif_artt_usager(vnu_co_employe_shq, vda_dt_temps_jour) then
                -- Personne avec aménagement de temps de travail
                if (vnu_som_total_temps_activite < utl_fnb_cnv_minute('3:00') +  vnu_absencett)  then
                   vva_message := utl_pkb_message.fc_obt_message('FDT.000005');
                   p_ajout_message (  vva_message,p_vcmode,vda_dt_temps_jour);
                end if;
             else
                -- Personne sans aménagement de temps de travail
                if vnu_som_total_temps_activite != (fdt_fnb_obt_nb_minutes_usager(vnu_co_employe_shq, vda_dt_temps_jour) / 2) +  vnu_absencett  then
                   vva_message := utl_pkb_message.fc_obt_message('FDT.000005');
                   p_ajout_message (  vva_message,p_vcmode,vda_dt_temps_jour);
                end if;
             end if;
          end if;
          if (vnu_debut_am != 0 and vnu_fin_am != 0) and vnu_som_total_temps_activite >= utl_fnb_cnv_minute('3:00') then
             -- ajout à faire ici shqcge
	         if vnu_fin_am > vnu_h_plage_fin_am_si_conge_pm then
                vva_message := utl_pkb_message.fc_obt_message('FDT.000032',pil_fnb_obt_param_global('H_PLAGE_FIN_AM_SI_CONGE_PM'));
                p_ajout_message (  vva_message,p_vcmode,vda_dt_temps_jour);
             end if;
          end if; 
       else
           -- La personne a saisi du temps en avant midi et en après midi, mais a une absence sur plage fixe.
           if vnu_absencett != 0 then
              if fdt_fnb_verif_artt_usager(vnu_co_employe_shq,vda_dt_temps_jour) is null then
                  vbo_resultat := utl_pkb_message.lire_message ('ZZZ.000017', null, vva_type, vva_message); --paramètre usager inexistant
                  p_ajout_message (  vva_message,p_vcmode,vda_dt_temps_jour);
              else
                 if fdt_fnb_verif_artt_usager(vnu_co_employe_shq, vda_dt_temps_jour) then
                 -- Personne avec aménagement de temps de travail
                    if not( vnu_som_total_temps_activite >= vnu_absencett) then
                       vva_message := utl_pkb_message.fc_obt_message('FDT.000001');
                       p_ajout_message ( vva_message,p_vcmode,vda_dt_temps_jour);
                    end if;
                 else
                    if vnu_som_total_temps_activite != vnu_absencett then
                       vva_message := utl_pkb_message.fc_obt_message('FDT.000001');
                       p_ajout_message (  vva_message,p_vcmode,vda_dt_temps_jour);
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
       --vbo_resultat := utl_pkb_message.lire_message ('FDT.000007', null, vva_type, vva_message);
       vva_message := utl_pkb_message.fc_obt_message('FDT.000007');
       p_ajout_message (  vva_message,p_vcmode,vda_dt_temps_jour);
    end if;
    --Validation processus n°7
    select sum(actt.total_temps / fdt_fnb_obt_nb_minutes_usager(actt.co_employe_shq,actt.dt_activite_temps)) journee_credit ,
          sum(case when vda_dt_temps_jour = DT_ACTIVITE_TEMPS then actt.total_temps end)
      into vnu_sum_crd_hor_en_jour,vnu_sum_crd_hor_en_jour_cour
    from fdtt_activite_temps actt
    where actt.co_employe_shq  = vnu_co_employe_shq
     and  actt.id_activite = 122
     and  actt.an_mois_fdt = vnu_an_mois_fdt;
    --
    if vnu_sum_crd_hor_en_jour > 2 and  vnu_sum_crd_hor_en_jour_cour > 0 then
       -- Pas le droit dfe prendre plus de 2 crédits horaires dans le mois.
       vbo_resultat := utl_pkb_message.lire_message ('FDT.000002', null, vva_type, vva_message);
       p_ajout_message ( vva_message,p_vcmode,vda_dt_temps_jour);
    end if;
    --Validation processus n°7.2
    --if (fdt_fnb_obt_cred_hor_an_usager(utl_fnb_obt_dt_prodc('FDT', 'DA') , vnu_co_employe_shq) > 18) then
    --   -- Pas le droit de prendre plus de 18 crédits horaires dans l'année.
    --   vbo_resultat := utl_pkb_message.lire_message ('FDT.000003', null, vva_type, vva_message);
    --   p_ajout_message (vva_message,p_vcmode,vda_dt_temps_jour);
    --end if;
  END P_VALID_LIGN_JOUR;


  procedure p_valid_lign_jour_ext (pro_rowid rowid,
                                   p_vcmode in varchar2)
  as
  vda_dh_debut_pm_temps date;
  vda_dh_fin_am_temps date;
  vda_dh_debut_am_temps date;
  vda_dh_fin_pm_temps date;
  vnu_co_employe_shq number;
  vnu_an_mois_fdt number;
  vda_dt_temps_jour date;
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
    -- Validation processus n°1 : Recherche des informations dans les tables FDTT_TEMPS_JOUR et FDTT_ACTIVITE_TEMPS
    select  max(tmp_jour.dh_debut_pm_temps),
            max(tmp_jour.dh_fin_am_temps),
            max(tmp_jour.dh_debut_am_temps),
            max(tmp_jour.dh_fin_pm_temps),
            max(tmp_jour.an_mois_fdt),
            max(tmp_jour.co_employe_shq),
            max(tmp_jour.dt_temps_jour) into  vda_dh_debut_pm_temps, vda_dh_fin_am_temps ,vda_dh_debut_am_temps ,vda_dh_fin_pm_temps , vnu_an_mois_fdt, vnu_co_employe_shq, vda_dt_temps_jour
    from fdtt_temps_jour tmp_jour
    where tmp_jour.rowid  = pro_rowid;
    -- Conversion des heures saisies en minutes
    vnu_debut_am := utl_fnb_cnv_minute(to_char(vda_dh_debut_am_temps, 'HH24:MI'));
    vnu_fin_am   := utl_fnb_cnv_minute(to_char(vda_dh_fin_am_temps, 'HH24:MI'));
    vnu_debut_pm := utl_fnb_cnv_minute(to_char(vda_dh_debut_pm_temps, 'HH24:MI'));
    vnu_fin_pm   := utl_fnb_cnv_minute(to_char(vda_dh_fin_pm_temps, 'HH24:MI'));
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
       p_ajout_message ( vva_message,p_vcmode,vda_dt_temps_jour);
    end if;
    --
    if (vnu_debut_am != 0 and vnu_fin_am = 0) or (vnu_debut_am = 0 and vnu_fin_am != 0) or (vnu_debut_pm != 0 and vnu_fin_pm =0)  or (vnu_debut_pm = 0 and vnu_fin_pm != 0) then
       -- On ne peut pas saisir une heure de début ou fin d'une pÃ©riode sans saisir les deux valeurs.
       vva_message := utl_pkb_message.fc_obt_message('FDT.000006');
       p_ajout_message ( vva_message,p_vcmode,vda_dt_temps_jour);
    end if;
    if vnu_fin_am !=0 and vnu_debut_pm != 0 then
       -- Il faut prendre un minimum de 45 minutes pour diner
       if (vnu_debut_pm - vnu_fin_am) < 45 then
          vva_message := utl_pkb_message.fc_obt_message('FDT.000013');
          p_ajout_message (  vva_message,p_vcmode,vda_dt_temps_jour);
       end if;
    end if;
  --
  END p_valid_lign_jour_ext;
  --
  procedure p_valdt_infrm_temps(p_vcco_employe_shq in fdtt_feuille_temps.co_employe_shq%type,
                                p_vcan_mois_fdt    in fdtt_feuille_temps.an_mois_fdt%type,
                                p_vcmode in varchar2 default 'AVERTISSEMENT') is
	 -- On calcul la dernière journée de la période pour aller chercher les différents paramètres.
       vdt_dernier_jour_mois   date         := last_day(to_date(p_vcan_mois_fdt||'01','yyyymmdd')); 	 
     -- Récupération des plages horaires dans la base
       vchr_H_PLAGE_DEB_AM_MIN varchar2(10) := pil_fnb_obt_param_global('H_PLAGE_DEB_AM_MIN',vdt_dernier_jour_mois);
       vchr_H_PLAGE_DEB_AM_MAX varchar2(10) := pil_fnb_obt_param_global('H_PLAGE_DEB_AM_MAX',vdt_dernier_jour_mois);
       vchr_H_PLAGE_FIN_AM_MIN varchar2(10) := pil_fnb_obt_param_global('H_PLAGE_FIN_AM_MIN',vdt_dernier_jour_mois);
       vchr_H_PLAGE_FIN_AM_MAX varchar2(10) := pil_fnb_obt_param_global('H_PLAGE_FIN_AM_MAX',vdt_dernier_jour_mois);
       vchr_H_PLAGE_DEB_PM_MIN varchar2(10) := pil_fnb_obt_param_global('H_PLAGE_DEB_PM_MIN',vdt_dernier_jour_mois);
       vchr_H_PLAGE_DEB_PM_MAX varchar2(10) := pil_fnb_obt_param_global('H_PLAGE_DEB_PM_MAX',vdt_dernier_jour_mois);
       vchr_H_PLAGE_FIN_PM_MIN varchar2(10) := pil_fnb_obt_param_global('H_PLAGE_FIN_PM_MIN',vdt_dernier_jour_mois);
       vchr_H_PLAGE_FIN_PM_MAX varchar2(10) := pil_fnb_obt_param_global('H_PLAGE_FIN_PM_MAX',vdt_dernier_jour_mois);
     -- Récupération des plages horaires obligatioires, conversion en minute
       vnum_H_PLAGE_DEB_AM_MIN number := utl_fnb_cnv_minute(pil_fnb_obt_param_global('H_PLAGE_DEB_AM_MIN',vdt_dernier_jour_mois));
       vnum_H_PLAGE_DEB_AM_MAX number := utl_fnb_cnv_minute(pil_fnb_obt_param_global('H_PLAGE_DEB_AM_MAX',vdt_dernier_jour_mois));
       vnum_H_PLAGE_FIN_AM_MIN number := utl_fnb_cnv_minute(pil_fnb_obt_param_global('H_PLAGE_FIN_AM_MIN',vdt_dernier_jour_mois));
       vnum_H_PLAGE_FIN_AM_MAX number := utl_fnb_cnv_minute(pil_fnb_obt_param_global('H_PLAGE_FIN_AM_MAX',vdt_dernier_jour_mois));
       vnum_H_PLAGE_DEB_PM_MIN number := utl_fnb_cnv_minute(pil_fnb_obt_param_global('H_PLAGE_DEB_PM_MIN',vdt_dernier_jour_mois));
       vnum_H_PLAGE_DEB_PM_MAX number := utl_fnb_cnv_minute(pil_fnb_obt_param_global('H_PLAGE_DEB_PM_MAX',vdt_dernier_jour_mois));
       vnum_H_PLAGE_FIN_PM_MIN number := utl_fnb_cnv_minute(pil_fnb_obt_param_global('H_PLAGE_FIN_PM_MIN',vdt_dernier_jour_mois));
       vnum_H_PLAGE_FIN_PM_MAX number := utl_fnb_cnv_minute(pil_fnb_obt_param_global('H_PLAGE_FIN_PM_MAX',vdt_dernier_jour_mois));
     -- Récupération des plages horaires obligatoires dans la base de données
       vchr_H_PLAGE_DEB_AM_OBLI varchar2(10) := pil_fnb_obt_param_global('H_PLAGE_DEB_AM_OBLI',vdt_dernier_jour_mois);
       vchr_H_PLAGE_FIN_AM_OBLI varchar2(10) := pil_fnb_obt_param_global('H_PLAGE_FIN_AM_OBLI',vdt_dernier_jour_mois);
       vchr_H_PLAGE_DEB_PM_OBLI varchar2(10) := pil_fnb_obt_param_global('H_PLAGE_DEB_PM_OBLI',vdt_dernier_jour_mois);
       vchr_H_PLAGE_FIN_PM_OBLI varchar2(10) := pil_fnb_obt_param_global('H_PLAGE_FIN_PM_OBLI',vdt_dernier_jour_mois);
     -- Récupération des plages horaires obligatoires dans la base, conversion en minute
       vnum_H_PLAGE_DEB_AM_OBLI number := utl_fnb_cnv_minute(pil_fnb_obt_param_global('H_PLAGE_DEB_AM_OBLI',vdt_dernier_jour_mois));
       vnum_H_PLAGE_FIN_AM_OBLI number := utl_fnb_cnv_minute(pil_fnb_obt_param_global('H_PLAGE_FIN_AM_OBLI',vdt_dernier_jour_mois));
       vnum_H_PLAGE_DEB_PM_OBLI number := utl_fnb_cnv_minute(pil_fnb_obt_param_global('H_PLAGE_DEB_PM_OBLI',vdt_dernier_jour_mois));
       vnum_H_PLAGE_FIN_PM_OBLI number := utl_fnb_cnv_minute(pil_fnb_obt_param_global('H_PLAGE_FIN_PM_OBLI',vdt_dernier_jour_mois));
     -- Récupération des heures SHQ dans la base, conversion en minute
       vnum_H_DEBUT_AM_SHQ number := utl_fnb_cnv_minute(pil_fnb_obt_param_global('H_DEBUT_AM_SHQ',vdt_dernier_jour_mois));
       vnum_H_FIN_AM_SHQ   number := utl_fnb_cnv_minute(pil_fnb_obt_param_global('H_FIN_AM_SHQ',vdt_dernier_jour_mois));
       vnum_H_DEBUT_PM_SHQ number := utl_fnb_cnv_minute(pil_fnb_obt_param_global('H_DEBUT_PM_SHQ',vdt_dernier_jour_mois));
       vnum_h_fin_pm_shq   number := utl_fnb_cnv_minute(pil_fnb_obt_param_global('H_FIN_PM_SHQ',vdt_dernier_jour_mois));
     --
       vva_co_interne_exter varchar2(1);
  begin
   vtp_evidence :=new tp_evidence();
   vtp_avertissement :=new tp_avertissement();
  --Vérifier qu'aucune feuille antérieur n'est à corriger
   FOR V_RT_ERREUR IN(select  to_char(to_date(ft.an_mois_fdt,'yyyymm'), 'Month YYYY') valeur
                      from fdtt_suivi_feuille_temps ft,
                           fdtt_feuille_temps fdt
                      where ft.co_employe_shq_fdt = p_vcco_employe_shq             
                        and ft.co_typ_suivi_fdt IN ('A_CORRIGER')  
                        and ft.co_employe_shq_fdt = fdt.co_employe_shq
                        and ft.an_mois_fdt = fdt.an_mois_fdt
                        and fdt.ind_saisie_autorisee = 'O'
                        and ft.an_mois_fdt < p_vcan_mois_fdt
						and ft.no_seq_suivi_fdt = (select max(sui.no_seq_suivi_fdt)
                                                   from fdtt_suivi_feuille_temps sui 
                                                   where ft.co_employe_shq_fdt = sui.co_employe_shq_fdt
                                                     and ft.an_mois_fdt        = sui.an_mois_fdt))
	   loop
          p_ajout_message(utl_pkb_message.fc_obt_message('FDT.000030', V_RT_ERREUR.valeur),p_vcmode,null);
       end loop;
    --
    --Validation des différentes journées
    for v_rt_jour in (select dt_temps_jour,rowid,
                             to_char(dh_debut_am_temps,'hh24:mi')dh_debut_am_temps,
                             to_char(dh_fin_am_temps,'hh24:mi')dh_fin_am_temps,
                             to_char(dh_debut_pm_temps,'hh24:mi')dh_debut_pm_temps,
                             to_char(dh_fin_pm_temps,'hh24:mi')dh_fin_pm_temps,
                             nvl(utl_fnb_cnv_minute(to_char(dh_debut_am_temps,'hh24:mi')), 0) num_debutam,
                             nvl(utl_fnb_cnv_minute(to_char(dh_fin_am_temps,'hh24:mi')), 0) num_finAM,
                             nvl(utl_fnb_cnv_minute(to_char(dh_debut_pm_temps,'hh24:mi')), 0) num_debutPM,
                             nvl(utl_fnb_cnv_minute(to_char(dh_fin_pm_temps,'hh24:mi')), 0) num_finpm

                       from fdtt_temps_jour
                      where co_employe_shq = p_vcco_employe_shq
                        and an_mois_fdt = p_vcan_mois_fdt
                      order by dt_temps_jour)loop
       select max(i.co_interne_exter)
          into vva_co_interne_exter
          from busv_info_employe i,
               fdtt_temps_jour u
          where u.rowid = v_rt_jour.rowid
          and   u.co_employe_shq = i.co_employe_shq;
      --
      if vva_co_interne_exter = 'I' then
        --
        --VALIDATION DES PLAGES ARRIVÉ / DÉPART
        --
        if v_rt_jour.num_debutam != 0 then
           if v_rt_jour.num_debutam not between vnum_h_plage_deb_am_min and vnum_h_plage_deb_am_max then
                 p_ajout_message(utl_pkb_message.fc_obt_message('FDT.000014', vchr_H_PLAGE_DEB_AM_MIN, vchr_H_PLAGE_DEB_AM_MAX),p_vcmode,v_rt_jour.dt_temps_jour);
                 p_ajout_mise_evidence(pda_date_jour =>v_rt_jour.dt_temps_jour,
                                            pvc_nom_champs =>'AM_DEB',
                                            pvc_co_couleur =>'red');
           end if;
        end if;
        --
         if v_rt_jour.num_finam != 0  then
          if v_rt_jour.num_finAM not between vnum_H_PLAGE_FIN_AM_MIN and vnum_H_PLAGE_FIN_AM_MAX then
              p_ajout_message( utl_pkb_message.fc_obt_message('FDT.000015', vchr_h_plage_fin_am_min, vchr_h_plage_fin_am_max),p_vcmode,v_rt_jour.dt_temps_jour);
              p_ajout_mise_evidence(pda_date_jour =>v_rt_jour.dt_temps_jour,
                                            pvc_nom_champs =>'AM_FIN',
                                            pvc_co_couleur =>'red');
          end if;
         end if;
        --
         if v_rt_jour.num_debutPM != 0 then
           if v_rt_jour.num_debutPM not between vnum_H_PLAGE_DEB_PM_MIN and vnum_H_PLAGE_DEB_PM_MAX then
              p_ajout_message( utl_pkb_message.fc_obt_message('FDT.000016', vchr_h_plage_deb_pm_min, vchr_h_plage_deb_pm_max),p_vcmode,v_rt_jour.dt_temps_jour);
              p_ajout_mise_evidence(pda_date_jour =>v_rt_jour.dt_temps_jour,
                                            pvc_nom_champs =>'PM_DEB',
                                            pvc_co_couleur =>'red');
          end if;
         end if;
          --
        if v_rt_jour.num_finPM != 0 then
          if v_rt_jour.num_finPM not between vnum_H_PLAGE_FIN_PM_MIN and vnum_H_PLAGE_FIN_PM_MAX then
             p_ajout_message( utl_pkb_message.fc_obt_message('FDT.000017', vchr_H_PLAGE_FIN_PM_MIN, vchr_H_PLAGE_FIN_PM_MAX),p_vcmode,v_rt_jour.dt_temps_jour);
             p_ajout_mise_evidence(pda_date_jour =>v_rt_jour.dt_temps_jour,
                                            pvc_nom_champs =>'PM_FIN',
                                            pvc_co_couleur =>'red');
          end if;
        end if;
        --
         p_valid_lign_jour(v_rt_jour.rowid,p_vcmode);
      else
         p_valid_lign_jour_ext(v_rt_jour.rowid,p_vcmode);
      end if;
    end loop;
   end;
  --
  function f_obten_evdnc(pda_date_ligne in date,
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
  end;
end fdt_pkb_valdt_temps;
/
