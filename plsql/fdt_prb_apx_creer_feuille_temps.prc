create or replace PROCEDURE FDT_PRB_APX_CREER_FEUILLE_TEMPS (pnu_co_employe_shq   in number,
                                                             pva_an_mois_fdt_prec in varchar2,
							                                 pnu_solde_reporte    in number default 0) IS
   vda_fdt_prec           date;
   vda_fdt_a_creer        date;
   vda_fdt_der_jour_mois  date;
   vda_date_a_traiter     date;
   vnu_journee            number(2);
   vnu_solde_reporte_cal  number;
   vnu_h_min_fin_mois_hv  number;
   vnu_h_max_fin_mois_hv  number;
   vnu_nb                 number;
   -- Aller chercher infos dans BUS
   cursor cur_info_employe is
      select co_interne_exter
      from busv_info_employe
      where co_employe_shq = pnu_co_employe_shq;
   rec_cur_info_employe     cur_info_employe%rowtype;
   --
   cursor cur_activation_employe(pdt_fdt_a_creer date) is
      select dt_activation
      from busv_utilisateur_int
      where co_employe_shq = pnu_co_employe_shq
	    and to_char(dt_activation,'yyyymm') = to_char(pdt_fdt_a_creer,'yyyymm');
   rec_cur_activation_employe     cur_activation_employe%rowtype;
   --
   -- Aller chercher la séquence de l'activité férié dans la table activité
   cursor cur_activite_ferie is
      select no_seq_activite
      from fdtt_activites act
          ,fdtt_categorie_activites cat
      where cat.co_type_categorie  = 'GENRQ'
        and act.no_seq_categ_activ = cat.no_seq_categ_activ
        and act.ACRONYME = '100';
   rec_cur_activite_ferie     cur_activite_ferie%rowtype;
   --
   -- Aller chercher la séquence de l'activité journée non travaillé nouvel employé dans la table activité
   cursor cur_activite_nouvel_employe is
      select no_seq_activite
      from fdtt_Activites act
          ,fdtt_categorie_activites cat
      where cat.co_type_categorie  = 'GENRQ'
        and act.no_seq_categ_activ = cat.no_seq_categ_activ
        and act.ACRONYME = '0';
   rec_cur_activite_nouvel_employe     cur_activite_nouvel_employe%rowtype;   
   --
   vnu_no_seq_ressource     fdtt_ressource.no_seq_ressource%type;
   vnu_NO_SEQ_FEUIL_TEMPS   fdtt_feuilles_temps.NO_SEQ_FEUIL_TEMPS%type; 
   -- Aller chercher le no_seq_ressource lorsqu'il est existant
   cursor cur_ressource is
      select no_seq_ressource
      from fdtt_ressource res
      where res.co_employe_shq = pnu_co_employe_shq;
   rec_ressource    cur_ressource%rowtype;
begin
   select count(*)
     into vnu_nb
     from fdtt_ressource
    where co_employe_shq = pnu_co_employe_shq;
    --
    -- On va chercher dans BUS pour voir si l'employé est interne ou externe
    open cur_info_employe;
       fetch cur_info_employe into rec_cur_info_employe;
    close cur_info_employe;
    --
	-- On va chercher la date d'activation de l'employé dans BUS pour voir si c'est un nouvel employé pour le mois demandé.
	--
    if vnu_nb = 0 then
       insert into fdtt_ressource(co_employe_shq,
        --                          ind_horaire_var,
        --                          ind_saisie_assiduite,
        --                          IND_SAISIE_INTRV,
                                  CO_INTERNE_EXTER,
                                  NB_HMIN_JOUR_RESSR,
                                  NB_HMIN_SEMN_RESSR)
       values(pnu_co_employe_shq,
 --             'O',
 --             'O',
 --             'N',
              rec_cur_info_employe.CO_INTERNE_EXTER,
              420,
			  2100)
       returning no_seq_ressource into vnu_no_seq_ressource;
    else
       -- On va chercher le no_seq_ressource
       open cur_ressource;
          fetch cur_ressource into rec_ressource;
       close cur_ressource;
       vnu_no_seq_ressource := rec_ressource.no_seq_ressource;
    end if;
      -- On crée la feuille de temps suivante
      vda_fdt_prec           := to_date(pva_an_mois_fdt_prec||'01','YYYYMMDD');
      vda_fdt_a_creer        := add_months(vda_fdt_prec,1);
      --vda_fdt_der_jour_mois  := last_day(vda_fdt_a_creer);
      vda_date_a_traiter     := vda_fdt_a_creer;
      vnu_journee            := 0;
      --
      vnu_h_min_fin_mois_hv := utl_fnb_cnv_minute(pil_fnb_obt_param_global('H_MIN_FIN_MOIS_HV',last_day(vda_fdt_prec)));
      vnu_h_max_fin_mois_hv := utl_fnb_cnv_minute(pil_fnb_obt_param_global('H_MAX_FIN_MOIS_HV',last_day(vda_fdt_prec)));
      --	  
      if pnu_solde_reporte >= vnu_h_min_fin_mois_hv and pnu_solde_reporte <= vnu_h_max_fin_mois_hv then
         vnu_solde_reporte_cal  := pnu_solde_reporte;
      else
         if pnu_solde_reporte < vnu_h_min_fin_mois_hv then
            vnu_solde_reporte_cal  := vnu_h_min_fin_mois_hv;
         else
            vnu_solde_reporte_cal  := vnu_h_max_fin_mois_hv;
         end if;
      end if;
      --
      insert into fdtt_feuilles_temps(no_seq_ressource,
                                     an_mois_fdt,
                                     ind_saisie_autorisee,
                                     solde_reporte,
                                     heure_reglr,
                                     credt_utls,
                                     ecart,
                                     norme,
                                     solde_periode,
                                     heure_autre_absence,
                                     corr_mois_preced,
									 nb_min_coupure) 
              values (vnu_no_seq_ressource,
                      to_char(vda_fdt_a_creer,'yyyymm'),
                      'O' ,
                      vnu_solde_reporte_cal,
                      0,
                      0,
			          0,
                      0,
			          0,
                      0,
                      0,
					  0)
         returning NO_SEQ_FEUIL_TEMPS into vnu_NO_SEQ_FEUIL_TEMPS;
      -- 
	  -- On va chercher la date activation de l'employé pour voir si l'employé vient d'arriver.
	  -- À noter que cette date doit être dans le mois de la fdt à créer.
	  --
      open cur_activation_employe(vda_fdt_a_creer);
         fetch cur_activation_employe into rec_cur_activation_employe;
      close cur_activation_employe;
      --
	  --
	  -- On va chercher la séquence pour l'activité férié dans la table activité
      open cur_activite_ferie;
         fetch cur_activite_ferie into rec_cur_activite_ferie;
      close cur_activite_ferie;	  
	  --
      -- On crée maintenant toutes les journées ouvrables dans FDTT_TEMPS_JOUR du mois 
      insert into fdtt_temps_jours(NO_SEQ_FEUIL_TEMPS,
                                  an_mois_fdt,
                                  dt_temps_jour,
                                  total_temps_min)
         select vnu_NO_SEQ_FEUIL_TEMPS,
                to_char(vda_fdt_a_creer,'yyyymm'),
                to_date(to_char(vda_fdt_a_creer,'yyyymm') || to_char(lig.jour, '00'), 'yyyymmdd'),
                0 
         from (select rownum jour from busv_info_employe where rownum <= to_number(to_char(last_day(to_date(to_char(vda_fdt_a_creer,'yyyymm'), 'yyyymm')), 'dd'))) lig
              ,busv_info_employe emp
         WHERE to_number(to_char(to_date(to_char(vda_fdt_a_creer,'yyyymm') || to_char(lig.jour, '00'), 'yyyymmdd'), 'd')) BETWEEN 2 AND 6
         and emp.co_employe_shq = pnu_co_employe_shq;
      --
      -- On traite les journées fériés du mois si elles sont après la date d'arrivé d'un employé (nouvel employé seulement)
      --
      insert into fdtt_temps_jours(NO_SEQ_FEUIL_TEMPS,
                                  an_mois_fdt,
                                  dt_temps_jour,
                                  total_temps_min,
								                  no_seq_activite)
         select vnu_NO_SEQ_FEUIL_TEMPS,
                to_char(vda_fdt_a_creer,'yyyymm'),
                to_date(to_char(vda_fdt_a_creer,'yyyymm') || to_char(lig.jour, '00'), 'yyyymmdd'),
                coalesce(decode(emp.co_interne_exter, 'I',
                                                         (select coalesce(att.NB_HMIN_JOUR, usa.NB_HMIN_JOUR_RESSR) nb_minute
                                                          from fdtt_details_att att,
                                                               fdtt_ressource usa
                                                          where usa.no_seq_ressource = att.no_seq_ressource(+)
                                                            and usa.co_employe_shq = pnu_co_employe_shq
                                                            and to_date(to_char(vda_fdt_a_creer,'yyyymm') || to_char(lig.jour, '00'), 'yyyymmdd') between att.dt_debut_att (+) 
															                                                                                          and coalesce(att.dt_fin_att (+),to_date('39990101','yyyymmdd')))
                                ,0)
                        ,0) minute_ferie,
				        rec_cur_activite_ferie.no_seq_activite
         from (select rownum jour from busv_info_employe where rownum <= to_number(to_char(last_day(to_date(to_char(vda_fdt_a_creer,'yyyymm'), 'yyyymm')), 'dd'))) lig
              ,busv_info_employe emp
         WHERE to_number(to_char(to_date(to_char(vda_fdt_a_creer,'yyyymm') || to_char(lig.jour, '00'), 'yyyymmdd'), 'd')) BETWEEN 2 AND 6
         and emp.co_employe_shq = pnu_co_employe_shq
		 and UTL_PKB_DATE_OUVRABLE.fva_est_ferie(to_date(to_char(vda_fdt_a_creer,'yyyymm') || to_char(lig.jour, '00'), 'yyyymmdd')) = 'O'
		 and to_number(to_char(lig.jour, '00')) >= coalesce(to_number(to_char(rec_cur_activation_employe.dt_activation,'dd')),0);
      --
      -- On traite maintenant les nouveaux employés.
	  --
      if rec_cur_activation_employe.dt_activation is not null then
	     -- On va chercher la séquence de l'activité : Nouvel employé dans la table activité
	     -- On va chercher la séquence pour l'activité férié dans la table activité
         open cur_activite_nouvel_employe;
            fetch cur_activite_nouvel_employe into rec_cur_activite_nouvel_employe;
         close cur_activite_nouvel_employe;	 		 
		 --
         vda_date_a_traiter := vda_fdt_a_creer;
         while vda_date_a_traiter < rec_cur_activation_employe.dt_activation
         loop
            vnu_journee := to_char(vda_date_a_traiter, 'd');
            if vnu_journee >= 2 and vnu_journee <= 6 then            
			   insert into fdtt_temps_jours(NO_SEQ_FEUIL_TEMPS,
                                      an_mois_fdt,
                                      dt_temps_jour,
                                      total_temps_min,
										                  no_seq_activite)
                      values(vnu_NO_SEQ_FEUIL_TEMPS,
                             to_char(vda_fdt_a_creer,'yyyymm'),
                             vda_date_a_traiter,
                             fdt_fnb_apx_obt_nb_minutes_usager(vnu_no_seq_ressource, vda_date_a_traiter),
							               rec_cur_activite_nouvel_employe.no_seq_activite);
            end if;
            vda_date_a_traiter := vda_date_a_traiter + 1;
         END loop;
      end if;
--
exception
  when dup_val_on_index then
       return;
       -- On fait quoi return ?
       -- il s'agit d'une "ancienne feuille retransmise", on a déjà  créer cette fdt.
	   -- Donc, on a rien à  faire.
end FDT_PRB_APX_CREER_FEUILLE_TEMPS;
/
