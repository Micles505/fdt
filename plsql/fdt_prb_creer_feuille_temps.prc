PROMPT Creating PROCEDURE 'FDT_PRB_CREER_FEUILLE_TEMPS'
create or replace PROCEDURE FDT_PRB_CREER_FEUILLE_TEMPS (pnu_co_employe_shq   in number,
                                                         pva_an_mois_fdt_prec in varchar2,
							                             pnu_solde_reporte    in number default 0,
							                             pda_dt_debut_emp     in date default null) IS
   vda_fdt_prec           date;
   vda_fdt_a_creer        date;
   vda_fdt_der_jour_mois  date;
   vda_date_a_traiter     date;
   vnu_journee            number(2);
   vnu_solde_reporte_cal  number;
   vnu_h_min_fin_mois_hv  number;
   vnu_h_max_fin_mois_hv  number;
   vnu_nb                 number;
begin
   select count(*)
     into vnu_nb
     from fdtt_usager
    where co_employe_shq = pnu_co_employe_shq;

    if vnu_nb = 0 then
      insert into fdtt_usager
      (co_employe_shq,ind_horaire_var)
      values(pnu_co_employe_shq,'O');
    end if;
      -- On cr?e la feuille de temps suivante
      vda_fdt_prec           := null;
      vda_fdt_a_creer        := null;
      vda_fdt_der_jour_mois  := null;
      vda_date_a_traiter     := null;
      vda_fdt_prec           := to_date(pva_an_mois_fdt_prec||'01','YYYYMMDD');
      vda_fdt_a_creer        := add_months(vda_fdt_prec,1);
      vda_fdt_der_jour_mois  := last_day(vda_fdt_a_creer);
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
      insert into fdtt_feuille_temps(co_employe_shq,
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
              values (pnu_co_employe_shq,
                      to_char(vda_fdt_a_creer,'yyyymm'),
                      decode(pva_an_mois_fdt_prec,'202205','N','O'),
                      vnu_solde_reporte_cal,
                      0,
                      0,
			          0,
                      0,
			          0,
                      0,
                      0,
					  0);
      --
      -- On cr?e maintenant toutes les journ?es ouvrables dans FDTT_TEMPS_JOUR du mois en
      -- tenant compte des journ?es f?ri?s auxquelles il faut mettre du temps.
      insert into fdtt_temps_jour(co_employe_shq,
                                  an_mois_fdt,
                                  dt_temps_jour,
                                  total_temps,
                                  diffr_temps)
         select pnu_co_employe_shq,
                to_char(vda_fdt_a_creer,'yyyymm'),
                to_date(to_char(vda_fdt_a_creer,'yyyymm') || to_char(lig.jour, '00'), 'yyyymmdd'),
                nvl(decode(emp.co_interne_exter, 'I',
                          (select nvl(att.nb_heure_jour, usa.nb_heure_usagr) nb_minute
                           from fdtt_detail_att att,
                                fdtt_usager usa,
                                pilv_valeur_code fer
                           where usa.co_employe_shq = att.co_employe_shq(+)
                             and usa.co_employe_shq = pnu_co_employe_shq
                             and to_date(to_char(vda_fdt_a_creer,'yyyymm') || to_char(lig.jour, '00'), 'yyyymmdd') between att.dt_debut_att (+) and nvl(att.dt_fin_att (+),to_date('39990101','yyyymmdd'))
                             and fer.co_valeur = to_date(to_char(vda_fdt_a_creer,'yyyymm') || to_char(lig.jour, '00'), 'yyyymmdd')
                             and to_date(fer.co_valeur,'yyyymmdd') >= nvl(pda_dt_debut_emp,to_date(fer.co_valeur,'yyyymmdd'))
                             and fer.co_repertoire = 'FERIE'
                             AND fer.co_systeme = 'PIL'),0),0) minute_ferie,
                             0
         from (select rownum jour from busv_info_employe where rownum <= to_number(to_char(last_day(to_date(to_char(vda_fdt_a_creer,'yyyymm'), 'yyyymm')), 'dd'))) lig
              ,busv_info_employe emp
         WHERE to_number(to_char(to_date(to_char(vda_fdt_a_creer,'yyyymm') || to_char(lig.jour, '00'), 'yyyymmdd'), 'd')) BETWEEN 2 AND 6
         and emp.co_employe_shq = pnu_co_employe_shq
		 and to_number(to_char(lig.jour, '00')) >= nvl(to_number(to_char(pda_dt_debut_emp,'dd')),0);
	  -- 
	  -- On va cr?er les cong?s f?ri?s dans la table des fdtt_activite_temps
      insert into fdtt_activite_temps(id_activite_temps,
                                      co_employe_shq,
                                      an_mois_fdt,
                                      id_activite,
                                      dt_activite_temps,
                                      total_temps)
         select fdtatp_seq.nextval,
                pnu_co_employe_shq,
                to_char(vda_fdt_a_creer,'yyyymm'),
                100,
                to_date(fer.co_valeur,'yyyymmdd'),
                decode(emp.co_interne_exter, 'I',nvl(att.nb_heure_jour, usa.nb_heure_usagr),0) nb_minute
         from fdtt_detail_att att,
              fdtt_usager usa,
              pilv_valeur_code fer,
              busv_info_employe emp
         where att.co_employe_shq(+) = pnu_co_employe_shq
           and usa.co_employe_shq    = pnu_co_employe_shq
           and to_date(fer.co_valeur,'yyyymmdd') between att.dt_debut_att (+) and nvl(att.dt_fin_att (+), to_date('39990101','yyyymmdd'))
           and to_date(fer.co_valeur,'yyyymmdd') between vda_fdt_a_creer and last_day(vda_fdt_a_creer)
           and to_date(fer.co_valeur,'yyyymmdd') >= nvl(pda_dt_debut_emp,to_date(fer.co_valeur,'yyyymmdd'))
           and fer.co_repertoire = 'FERIE'
           and fer.co_systeme = 'PIL'
           and emp.co_employe_shq = pnu_co_employe_shq;
      --
      -- On traite maintenant les nouveaux employ?s.
      if pda_dt_debut_emp is not null then
         vda_date_a_traiter := vda_fdt_a_creer;
         while vda_date_a_traiter < pda_dt_debut_emp
         loop
            vnu_journee := to_char(vda_date_a_traiter, 'd');
            if vnu_journee >= 2 and vnu_journee <= 6 then
               insert into fdtt_activite_temps(id_activite_temps,
                                               co_employe_shq,
                                               an_mois_fdt,
                                               id_activite,
                                               dt_activite_temps,
                                               total_temps)
               values (fdtatp_seq.nextval,
                       pnu_co_employe_shq,
                       to_char(vda_fdt_a_creer,'yyyymm'),
                       0,
                       vda_date_a_traiter,
                       fdt_fnb_obt_nb_minutes_usager(pnu_co_employe_shq , last_day(vda_date_a_traiter)));
               --              
			   insert into fdtt_temps_jour(co_employe_shq,
                                  an_mois_fdt,
                                  dt_temps_jour,
                                  total_temps,
                                  diffr_temps)
               values( pnu_co_employe_shq,
                to_char(vda_fdt_a_creer,'yyyymm'),
                vda_date_a_traiter,
                fdt_fnb_obt_nb_minutes_usager(pnu_co_employe_shq , last_day(vda_date_a_traiter)),
                0);
            end if;
            vda_date_a_traiter := vda_date_a_traiter + 1;
         END loop;
      end if;
exception
  when dup_val_on_index then
       return;
       -- On fait quoi return ?
       -- il s'agit d'une "ancienne feuille retransmise", on a d?j? cr?er cette fdt.
	   -- Donc, on a rien ? faire.
end FDT_PRB_CREER_FEUILLE_TEMPS;
/
show errors