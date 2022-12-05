CREATE OR REPLACE PROCEDURE FDT_PRB_APX_CREER_FEUILLE_TEMPS_INTER_FDT (pnu_co_employe_shq   in number,
                                                                       pva_an_mois_fdt_prec in varchar2,
                                                                       pnu_solde_reporte    in number default 0) IS
   vda_fdt_prec           date;
   vda_fdt_a_creer        date;
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
   -- Aller chercher aménamgent de temps dans FDT 1.0
   --
   cursor cur_amenagment_temps is
      select CO_EMPLOYE_SHQ ,
             DT_DEBUT_ATT ,
             DT_FIN_ATT ,
             NB_HEURE_JOUR ,
             NB_HEURE_SEM ,
             NB_JOUR_SEM ,
             NOTE 
      from fdtt_detail_att att

      where att.co_employe_shq = pnu_co_employe_shq
        and (att.dt_fin_att is null  or (to_char(att.dt_fin_att,'YYYYMM') = to_char(vda_fdt_a_creer,'YYYYMM'))) ;
   rec_cur_amenagment_temps     cur_amenagment_temps%rowtype;
   --
   vnu_no_seq_ressource     fdtt_ressource.no_seq_ressource%type;
   vnu_NO_SEQ_FEUIL_TEMPS   fdtt_feuilles_temps.NO_SEQ_FEUIL_TEMPS%type;
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
    vda_fdt_prec           := to_date(pva_an_mois_fdt_prec||'01','YYYYMMDD');
    vda_fdt_a_creer        := add_months(vda_fdt_prec,1);
      --vda_fdt_der_jour_mois  := last_day(vda_fdt_a_creer);
    --
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
      --
      -- On crée la feuille de temps suivante
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
      -- Aller chercher Aménagement de temps de travail dans FDT 1.0
      --
      open cur_amenagment_temps;
         fetch cur_amenagment_temps into rec_cur_amenagment_temps;
            while (cur_amenagment_temps%found) loop
            -- S'il y en a on ajoute le ou les aménagements de temps à la ressource.
            -- no_seq_detail_attrav,
            insert into fdtt_details_att (no_seq_ressource,
                                          dt_debut_att,
                                          dt_fin_att,
                                          nb_hmin_jour,
                                          nb_hmin_sem,
                                          nb_jour_sem,
                                          note)
            values (vnu_no_seq_ressource,
--                    rec_cur_amenagment_temps.dt_debut_att,
                    to_date('2022-06-01','YYYY-MM-DD'),
                    rec_cur_amenagment_temps.dt_fin_att,
                    rec_cur_amenagment_temps.nb_heure_jour,
                    rec_cur_amenagment_temps.nb_heure_sem,
                    rec_cur_amenagment_temps.nb_jour_sem,
                    rec_cur_amenagment_temps.note);
            fetch cur_amenagment_temps
               into rec_cur_amenagment_temps;
         end loop;
      close cur_amenagment_temps;
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
      -- On traite les journées fériés du mois
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
     and UTL_PKB_DATE_OUVRABLE.fva_est_ferie(to_date(to_char(vda_fdt_a_creer,'yyyymm') || to_char(lig.jour, '00'), 'yyyymmdd')) = 'O';
    end if;
--
exception
  when dup_val_on_index then
       return;
       -- On fait quoi return ?
       -- il s'agit d'une "ancienne feuille retransmise", on a déjà  créer cette fdt.
     -- Donc, on a rien à  faire.
end FDT_PRB_APX_CREER_FEUILLE_TEMPS_INTER_FDT;
/
