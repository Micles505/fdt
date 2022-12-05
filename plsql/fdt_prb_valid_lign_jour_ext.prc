CREATE OR REPLACE PROCEDURE FDT_PRB_VALID_LIGN_JOUR_EXT (pro_rowid rowid)
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
-- Récupération des plages horaires obligatoires dans la base, conversion en minute
--vnu_h_plage_deb_am_obli number := utl_fnb_cnv_minute(pil_fnb_obt_param_global('H_PLAGE_DEB_AM_OBLI'));
--vnu_h_plage_fin_am_obli number := utl_fnb_cnv_minute(pil_fnb_obt_param_global('H_PLAGE_FIN_AM_OBLI'));
--vnu_h_plage_deb_pm_obli number := utl_fnb_cnv_minute(pil_fnb_obt_param_global('H_PLAGE_DEB_PM_OBLI'));
--vnu_h_plage_fin_pm_obli number := utl_fnb_cnv_minute(pil_fnb_obt_param_global('H_PLAGE_FIN_PM_OBLI'));
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
     vva_message := utl_pkb_message.fc_obt_message('FDT.000024', to_char(to_date(vda_dt_temps_jour), 'day DD'));
     raise_application_error(-20001, vva_message);     
  end if;
  if (vnu_debut_pm != 0 and vnu_fin_pm != 0) and (vnu_fin_pm < vnu_debut_pm) then
     -- L'heure de fin pm doit être plus grande que l'heure de debut pm
     vva_message := utl_pkb_message.fc_obt_message('FDT.000024', to_char(to_date(vda_dt_temps_jour), 'day DD'));
     raise_application_error(-20001, vva_message);          
  end if;
  --
  if (vnu_debut_am != 0 and vnu_fin_am = 0) or (vnu_debut_am = 0 and vnu_fin_am != 0) or (vnu_debut_pm != 0 and vnu_fin_pm =0)  or (vnu_debut_pm = 0 and vnu_fin_pm != 0) then
     -- On ne peut pas saisir une heure de début ou fin d'une période sans saisir les deux valeurs.
     vva_message := utl_pkb_message.fc_obt_message('FDT.000006', to_char(to_date(vda_dt_temps_jour), 'day DD'));
     raise_application_error(-20001, vva_message);
  end if;
  -- Validation processus n°6
  if vnu_debut_am != 0 and vnu_fin_am != 0 then
     vnu_total_temps_jour_avec_acti := vnu_total_temps_jour_avec_acti + (vnu_fin_am - vnu_debut_am);
  end if;
  if vnu_debut_pm != 0 and vnu_fin_pm != 0 then
     vnu_total_temps_jour_avec_acti := vnu_total_temps_jour_avec_acti + (vnu_fin_pm - vnu_debut_pm);
  end if;
  --if vnu_total_temps_jour_avec_acti > 585 then -- 9:45 = 585 minutes
	--   vva_message := utl_pkb_message.fc_obt_message('FDT.000007', to_char(to_date(vda_dt_temps_jour), 'day DD'));
  --   raise_application_error(-20001, vva_message);
  --end if;
END fdt_prb_valid_lign_jour_ext;
/
show errors