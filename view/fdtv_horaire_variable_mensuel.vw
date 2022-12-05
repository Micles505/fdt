PROMPT CREATING VIEW 'FDTV_HORAIRE_VARIABLE_MENSUEL'
CREATE OR REPLACE VIEW FDTV_HORAIRE_VARIABLE_MENSUEL
  AS
  select hv.co_employe_shq,
       hv.periode,
       hv.dt_temps_jour,
       hv.dh_debut_am_temps,
       hv.dh_fin_am_temps,
       hv.dh_debut_pm_temps,
       hv.dh_fin_pm_temps,
       /*rtrim(extract(hour from numtodsinterval(act.absence_heures, 'MINUTE')) ||':'|| lpad(extract(minute from numtodsinterval(act.absence_heures, 'MINUTE')), 2, '0'), ':') absence_heures,
       act.absence_code,
      */ hv.credit_122_heures,
       hv.correction,
       hv.remarque,
       hv.cumul_jour,
       hv.diffr_temps,
       hv.total_temps,
       lpad(extract(hour from numtodsinterval(hv.temps_am, 'MINUTE')) ,2,'0')||':'|| lpad(extract(minute from numtodsinterval(hv.temps_am, 'MINUTE')), 2, '0') temps_am,
       lpad(extract(hour from numtodsinterval(hv.temps_pm, 'MINUTE')),2,'0') ||':'|| lpad(extract(minute from numtodsinterval(hv.temps_pm, 'MINUTE')), 2, '0') temps_pm,
       lpad(extract(hour from numtodsinterval(hv.temps_diner, 'MINUTE')),2,'0') ||':'|| lpad(extract(minute from numtodsinterval(hv.temps_diner, 'MINUTE')), 2, '0') temps_diner,
       lpad((extract(day  from numtodsinterval(hv.temps_jour_cumul, 'MINUTE')) * 24) + extract(hour from numtodsinterval(hv.temps_jour_cumul, 'MINUTE')),2,'0') ||':'|| lpad(extract(minute from numtodsinterval(hv.temps_jour_cumul, 'MINUTE')), 2, '0') temps_jour_cumul,
       lpad((extract(day  from numtodsinterval(hv.temps_prevue_cumul, 'MINUTE')) * 24) + extract(hour from numtodsinterval(hv.temps_prevue_cumul, 'MINUTE')),2,'0') ||':'|| lpad(extract(minute from numtodsinterval(hv.temps_prevue_cumul, 'MINUTE')), 2, '0') temps_prevue_cumul,
       decode(sign(hv.temps_jour_cumul - hv.temps_prevue_cumul), -1, '-', null) ||
       lpad(extract(hour from numtodsinterval(abs(hv.temps_jour_cumul - hv.temps_prevue_cumul), 'MINUTE')),2,'0') ||':'|| lpad(extract(minute from numtodsinterval(abs(hv.temps_jour_cumul - hv.temps_prevue_cumul), 'MINUTE')), 2, '0') credit_horaire,
       lpad(extract(hour from numtodsinterval(hv.temps_am + hv.temps_pm, 'MINUTE')),2,'0') ||':'|| lpad(extract(minute from numtodsinterval(hv.temps_am + hv.temps_pm, 'MINUTE')), 2, '0') temps_jour,
       rtrim((extract(day  from numtodsinterval((select (hv.temps_jour_cumul+hv.temp_absnc_compt_scp) - nvl(to_number(substr(to_char(max(hvm.dt_temps_jour), 'yyyymmdd') || max((hvm.temps_jour_cumul+hvm.temp_absnc_compt_scp)), 9)), 0) temps_ven_prec
                                                                  from fdtv_horaire_variable_maj hvm
                                                                 where to_char(hvm.dt_temps_jour, 'd') = 6
                                                                   and hvm.co_employe_shq = hv.co_employe_shq
                                                                   and hvm.periode    = hv.periode
                                                                   and hvm.dt_temps_jour < hv.dt_temps_jour), 'MINUTE')) * 24) + extract(hour from numtodsinterval( (select (hv.temps_jour_cumul+hv.temp_absnc_compt_scp) - nvl(to_number(substr(to_char(max(hvm.dt_temps_jour), 'yyyymmdd') || max((hvm.temps_jour_cumul+hvm.temp_absnc_compt_scp)), 9)), 0) temps_ven_prec
                                                                  from fdtv_horaire_variable_maj hvm
                                                                 where to_char(hvm.dt_temps_jour, 'd') = 6
                                                                   and hvm.co_employe_shq = hv.co_employe_shq
                                                                   and hvm.periode    = hv.periode
                                                                   and hvm.dt_temps_jour < hv.dt_temps_jour)
                                         , 'MINUTE'))
         ||':'|| lpad(extract(minute from numtodsinterval((hv.temps_jour_cumul+hv.temp_absnc_compt_scp) - (select nvl(to_number(substr(to_char(max(hvm.dt_temps_jour), 'yyyymmdd') || max((hvm.temps_jour_cumul+hvm.temp_absnc_compt_scp)), 9)), 0) temps_ven_prec
                                                                                   from fdtv_horaire_variable_maj hvm
                                                                                  where to_char(hvm.dt_temps_jour, 'd') = 6
                                                                                    and hvm.co_employe_shq = hv.co_employe_shq
                                                                                    and hvm.periode    = hv.periode
                                                                                    and hvm.dt_temps_jour < hv.dt_temps_jour)
                                                          , 'MINUTE')), 2, '0'), ':')
           temps_sem_cumul,
           NOTE_CORR_MOIS_PRECED
  from fdtv_horaire_variable_maj hv;