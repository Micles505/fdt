CREATE OR REPLACE PROCEDURE FDT_PRB_APX_CALCULER_TOTAUX_FEUILLE_TEMPS (pnu_no_seq_ressource     in  fdtt_feuilles_temps.no_seq_ressource%type,
                                                                       pva_an_mois_fdt          in  fdtt_feuilles_temps.an_mois_fdt%type,
                                     pnu_no_seq_feuil_temps                 out fdtt_feuilles_temps.no_seq_feuil_temps%type,
                                                         pnu_co_employe_shq                     out busv_info_employe.co_employe_shq%type,
                                     pva_co_interne_exter                   out busv_info_employe.co_interne_exter%type,
                                     pnu_solde_reporte                      out fdtt_feuilles_temps.solde_reporte%type,
                                     pnu_corr_mois_preced                   out fdtt_feuilles_temps.corr_mois_preced%type,
                                     pnu_total_temps_saisi                  out fdtt_feuilles_temps.heure_reglr%type,
                                                                       pnu_total_credit_horaire               out fdtt_feuilles_temps.credt_utls%type,
                                                                       pnu_total_activite_sauf_credit_horaire out fdtt_feuilles_temps.heure_autre_absence%type,
                                                                       pnu_norme                              out fdtt_feuilles_temps.norme%type,
                                                                       pnu_ecart                              out fdtt_feuilles_temps.ecart%type,
                                     pnu_solde_periode_calc                 out fdtt_feuilles_temps.solde_periode%type) IS
   --
   -- Déclaration variables, curseurs, etc.
   --
   cursor cur_fdt_actuelle_et_employe (p_no_seq_ressource in fdtt_feuilles_temps.no_seq_ressource%type,
                                       p_an_mois_fdt      in fdtt_feuilles_temps.an_mois_fdt%type) is
      select fdt.no_seq_feuil_temps, emp.co_employe_shq, emp.co_interne_exter, fdt.solde_reporte, fdt.corr_mois_preced
      from fdtt_feuilles_temps   fdt,
           fdtt_ressource       res,
           busv_info_employe    emp
      where fdt.no_seq_ressource = p_no_seq_ressource
        and fdt.an_mois_fdt      = p_an_mois_fdt
        and res.no_seq_ressource = fdt.no_seq_ressource
        and emp.co_employe_shq   = res.co_employe_shq;
     rec_fdt_actuelle_et_employe   cur_fdt_actuelle_et_employe%rowtype;
   --
   cursor cur_total_credit_horaire (p_no_seq_feuil_temps in fdtt_feuilles_temps.no_seq_feuil_temps%type) is
   with act_credit_horaire as(select act.no_seq_activite
                                from fdtt_activites act
                                where act.acronyme = '122')
          select coalesce(sum(act_jour.total_temps_min),0) as total_credit_horaire
          from fdtt_temps_jours    act_jour,
               act_credit_horaire ch
          where act_jour.no_seq_feuil_temps = p_no_seq_feuil_temps
            and act_jour.no_seq_activite    = ch.no_seq_activite;
   rec_total_credit_horaire  cur_total_credit_horaire%rowtype;
   --
   cursor cur_total_activite_sauf_credit_horaire (p_no_seq_feuil_temps in fdtt_feuilles_temps.no_seq_feuil_temps%type) is
     with act_credit_horaire as(select act.no_seq_activite
                                from fdtt_activites act
                                where act.acronyme = '122')
          select sum(act_jour.total_temps_min) as total_autres_absences
          from fdtt_temps_jours    act_jour,
               act_credit_horaire ch
          where act_jour.no_seq_feuil_temps = p_no_seq_feuil_temps
            and act_jour.no_seq_activite    != ch.no_seq_activite
      and act_jour.no_seq_activite    is not null;
   rec_somme_activite_sauf_credit_horaire  cur_total_activite_sauf_credit_horaire%rowtype;
   --
   cursor cur_total_temps_saisi (p_no_seq_feuil_temps in fdtt_feuilles_temps.no_seq_feuil_temps%type) is
      select coalesce(sum(act_tj.total_temps_min),0) as total_temps_saisi
      from fdtt_temps_jours act_tj
      where act_tj.no_seq_feuil_temps = p_no_seq_feuil_temps
        and act_tj.no_seq_activite    is null;
   rec_total_temps_saisi cur_total_temps_saisi%rowtype;
   --
   cursor cur_norme (p_no_seq_ressource in fdtt_feuilles_temps.no_seq_ressource%type,
                              p_an_mois_fdt      in fdtt_feuilles_temps.an_mois_fdt%type) is
      select nvl(fdt_fnb_apx_obt_nb_minutes_usager(p_no_seq_ressource, to_date(p_an_mois_fdt||'01','yyyymmdd'),LAST_DAY(to_date(p_an_mois_fdt, 'yyyymm'))),0) as norme
      from dual;
   rec_norme cur_norme%rowtype;
--
begin
      --
   -- Récupére le solde reporté, co_interne_exter (BUS), la correction du mois précédent
   -- et la séquence de la fdt qui est transmise.
   --  l_solde_reporte_base
   --
   open cur_fdt_actuelle_et_employe(pnu_no_seq_ressource, pva_an_mois_fdt);
      fetch cur_fdt_actuelle_et_employe into rec_fdt_actuelle_et_employe;
   close cur_fdt_actuelle_et_employe;
   --
   pnu_no_seq_feuil_temps := rec_fdt_actuelle_et_employe.no_seq_feuil_temps;
   pnu_co_employe_shq     := rec_fdt_actuelle_et_employe.co_employe_shq;
   pva_co_interne_exter   := rec_fdt_actuelle_et_employe.co_interne_exter;
   pnu_solde_reporte      := rec_fdt_actuelle_et_employe.solde_reporte;
   pnu_corr_mois_preced   := rec_fdt_actuelle_et_employe.corr_mois_preced;
   --
   -- Récupére les heures régulières saisies (exlu toutes les absences liés aux activités (vacances, crédit horaire, férié, etc.)
   -- l_heure_reguliere
   --
   open cur_total_temps_saisi(rec_fdt_actuelle_et_employe.no_seq_feuil_temps);
      fetch cur_total_temps_saisi into rec_total_temps_saisi;
   close cur_total_temps_saisi;
   pnu_total_temps_saisi := coalesce(rec_total_temps_saisi.total_temps_saisi,0);
   --
   -- Calcule la somme des activités 122
   --
   -- l_credt_utls
   --
   open cur_total_credit_horaire(rec_fdt_actuelle_et_employe.no_seq_feuil_temps);
      fetch cur_total_credit_horaire into rec_total_credit_horaire;
   close cur_total_credit_horaire;
   pnu_total_credit_horaire := coalesce(rec_total_credit_horaire.total_credit_horaire,0);
   --
   -- Calcule la somme des autres activités != 122 de la fdt transmise
   --
   -- l_heure_autre_absence
   --
   open cur_total_activite_sauf_credit_horaire(rec_fdt_actuelle_et_employe.no_seq_feuil_temps);
      fetch cur_total_activite_sauf_credit_horaire into rec_somme_activite_sauf_credit_horaire;
   close cur_total_activite_sauf_credit_horaire;
   pnu_total_activite_sauf_credit_horaire := coalesce(rec_somme_activite_sauf_credit_horaire.total_autres_absences,0);
   --
   -- Calcule de la norme pour le mois
   -- l_norme
   --
   open cur_norme(pnu_no_seq_ressource, pva_an_mois_fdt);
      fetch cur_norme into rec_norme;
   close cur_norme;
   pnu_norme := coalesce(rec_norme.norme,0);
   --
   if rec_fdt_actuelle_et_employe.co_interne_exter = 'I' then
      pnu_solde_periode_calc := pnu_solde_reporte + pnu_total_temps_saisi + pnu_total_activite_sauf_credit_horaire + pnu_corr_mois_preced - pnu_norme;
   else
      pnu_solde_periode_calc := 0;
   end if;
   --
   -- calcul de l'écart
   --
   pnu_ecart := pnu_total_temps_saisi + pnu_total_activite_sauf_credit_horaire - pnu_norme;
   --
end FDT_PRB_APX_CALCULER_TOTAUX_FEUILLE_TEMPS;
/

