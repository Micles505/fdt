PROMPT CREATING VIEW 'FDTV_HORAIRE_VARIABLE_MAJ'
CREATE OR REPLACE VIEW FDTV_HORAIRE_VARIABLE_MAJ
  AS
 select tj.co_employe_shq,
       to_char(tj.dt_temps_jour, 'yyyymm') periode,
       tj.dt_temps_jour,
       tj.dh_debut_am_temps,
       tj.dh_fin_am_temps,
       tj.dh_debut_pm_temps,
       tj.dh_fin_pm_temps,
       null absence_heures,
       null absence_code,
       null credit_122_heures,
       tj.total_temps,
       tj.diffr_temps,
       case when (select corr_mois_preced from fdtt_feuille_temps ft 
			           where tj.co_employe_shq = ft.co_employe_shq and to_char(tj.dt_temps_jour, 'yyyymm') = ft.an_mois_fdt) is null then null else
            (select case when corr_mois_preced < 0 then '-' end from fdtt_feuille_temps ft 
			           where tj.co_employe_shq = ft.co_employe_shq and to_char(tj.dt_temps_jour, 'yyyymm') = ft.an_mois_fdt)||
            lpad(trunc((select abs(corr_mois_preced) from fdtt_feuille_temps ft 
			           where tj.co_employe_shq = ft.co_employe_shq and to_char(tj.dt_temps_jour, 'yyyymm') = ft.an_mois_fdt)/60),2,'0')||':'||lpad(mod((select abs(corr_mois_preced) from fdtt_feuille_temps ft 
			           where tj.co_employe_shq = ft.co_employe_shq and to_char(tj.dt_temps_jour, 'yyyymm') = ft.an_mois_fdt),60),2,'0') end correction,
       remarque ,
       case when to_char(tj.dh_fin_am_temps,'HH24:MI')!='00:00' and  to_char(tj.dh_debut_am_temps,'HH24:MI')!='00:00' then
                 greatest(round((tj.dh_fin_am_temps - tj.dh_debut_am_temps) * 24 * 60),0)
            else 0 end temps_am,
       case when to_char(tj.dh_fin_pm_temps,'HH24:MI')!='00:00' and  to_char(tj.dh_debut_pm_temps,'HH24:MI')!='00:00' then
                 greatest(round((tj.dh_fin_pm_temps - tj.dh_debut_pm_temps) * 24 * 60),0)
            else 0 end temps_pm,
       case when (TO_CHAR(tj.dh_debut_pm_temps,'HH24:MI')='00:00' OR TO_CHAR(tj.dh_fin_am_temps,'HH24:MI')='00:00') OR tj.dh_debut_pm_temps - tj.dh_fin_am_temps < 0 then 0 
             else round((tj.dh_debut_pm_temps - tj.dh_fin_am_temps) * 24 * 60)
        END temps_diner,
	     round((case when to_char(tj.dh_fin_am_temps,'HH24:MI')!='00:00' and  to_char(tj.dh_debut_am_temps,'HH24:MI')!='00:00' then
                     greatest(round((tj.dh_fin_am_temps - tj.dh_debut_am_temps) * 24 * 60),0)
                else 0 end
               + 
               case when to_char(tj.dh_fin_pm_temps,'HH24:MI')!='00:00' and  to_char(tj.dh_debut_pm_temps,'HH24:MI')!='00:00' then
                     greatest(round((tj.dh_fin_pm_temps - tj.dh_debut_pm_temps) * 24 * 60),0)
                else 0 end)) cumul_jour,
       sum((case when to_char(tj.dh_fin_am_temps,'HH24:MI')!='00:00' and  to_char(tj.dh_debut_am_temps,'HH24:MI')!='00:00' then
                     greatest(round((tj.dh_fin_am_temps - tj.dh_debut_am_temps) * 24 * 60),0)
                else 0 end
               + 
               case when to_char(tj.dh_fin_pm_temps,'HH24:MI')!='00:00' and  to_char(tj.dh_debut_pm_temps,'HH24:MI')!='00:00' then
                     greatest(round((tj.dh_fin_pm_temps - tj.dh_debut_pm_temps) * 24 * 60),0)
                else 0 end))
          over (partition by co_employe_shq, to_char(tj.dt_temps_jour, 'yyyymm') order by tj.dt_temps_jour range between unbounded preceding and current row) temps_jour_cumul,
       nvl((SELECT sum(TOTAL_TEMPS)
          FROM FDTT_ACTIVITE_TEMPS at,
               FDTT_ACTIVITE a
         WHERE at.ID_ACTIVITE = a.NO_SEQ_ACTIVITE
           and a.ind_cumul_scp = 'O'
           AND at.co_employe_shq = tj.co_employe_shq
           and at.an_mois_fdt = to_char(tj.dt_temps_jour, 'yyyymm')
           AND DT_ACTIVITE_TEMPS <=tj.dt_temps_jour),0)as temp_absnc_compt_scp,
       (row_number() over (partition by co_employe_shq, to_char(tj.dt_temps_jour, 'yyyymm') order by co_employe_shq, to_char(tj.dt_temps_jour, 'yyyymm'), tj.dt_temps_jour) * fdt_fnb_obt_nb_minutes_usager(co_employe_shq,tj.dt_temps_jour)  * 60) temps_prevue_cumul,
       (sum(round(((tj.dh_fin_am_temps - tj.dh_debut_am_temps) * 24 * 60)
               + ((tj.dh_debut_am_temps - tj.dh_debut_pm_temps) * 24 * 60)))
          over (partition by tj.co_employe_shq, to_char(dt_temps_jour, 'yyyymm') order by dt_temps_jour range between unbounded preceding and current row))
       - (row_number() over (partition by co_employe_shq, to_char(dt_temps_jour, 'yyyymm') order by co_employe_shq, dt_temps_jour) *  fdt_fnb_obt_nb_minutes_usager(co_employe_shq,tj.dt_temps_jour) * 60)
 --      + (select nvl(min(per.solde_credit_122), 0)
 --           from rht_to_char(dt_temps_jour, 'yyyymm') per
 --          where (per.co_employe_shq, per.to_char(dt_temps_jour, 'yyyymm')) = (select per_prec.co_employe_shq, max(per_prec.to_char(dt_temps_jour, 'yyyymm'))
 --                                                         from rht_to_char(dt_temps_jour, 'yyyymm') per_prec
 --                                                        where per_prec.co_employe_shq = hor.co_employe_shq
 --                                                          and per_prec.to_char(dt_temps_jour, 'yyyymm') < hor.to_char(dt_temps_jour, 'yyyymm')
 --                                                          and per.statut_to_char(dt_temps_jour, 'yyyymm') = 'T'
 --                                                        group by per_prec.co_employe_shq))
            credit_horaire,
            (select NOTE_CORR_MOIS_PRECED from fdtt_feuille_temps ft 
			           where tj.co_employe_shq = ft.co_employe_shq and to_char(tj.dt_temps_jour, 'yyyymm') = ft.an_mois_fdt)NOTE_CORR_MOIS_PRECED
  from fdtt_temps_jour tj
  --where to_char(dt_temps_jour, 'yyyymm') = '201504' --:p3_periode
-- where co_employe_shq = 'SHQDMN' --:p3_co_employe_shq
 order by tj.dt_temps_jour asc;