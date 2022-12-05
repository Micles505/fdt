CREATE OR REPLACE PROCEDURE fdt_prb_transfert_interv_central_vers_fdt
is
   --
   -- Déclaration de variables
   --
begin
   --
   --delete scp2.scptr_resti res
   --where res.scpch_an_plan = '2022-2023';
   --COMMIT;
   -- 
   insert into fdtt_temps_intervention(no_seq_ressource,
                                       no_seq_aact_intrv_det,
                                       no_seq_specialite,
                                       an_mois_fdt,
                                       debut_periode,
                                       fin_periode,
                                       nbr_minute_trav)
   select tinter.no_seq_ressource, 
          restrav.no_seq_aact_intrv_det,
          tinter.no_seq_specialite,
          tinter.an_mois_periode,
          tinter.debut_periode,
          tinter.fin_periode,
          tinter.total_temps
from (

        with temps_scp as (select res.scpch_sig_sys as systeme,
                                  res.scpch_cod_prod as production,
                                  res.scpch_cod_act  as activite,
                                  res.scpch_cod_trav as travail,
                                  res.scpch_cod_ind  as code_individu,
                                  substr(res.scpch_per_rest,1,6) as an_mois_periode,
                                  sum(res.scpch_ri_co_r_h) as total_heure,
                                  sum(res.scpch_ri_co_r_m) as total_minutes,
                                  (sum(res.scpch_ri_co_r_h) * 60) + sum(res.scpch_ri_co_r_m) as total_temps 
                           from scp.scptr_resti res
                           where res.scpch_an_plan = '2022-2023' 
                             and substr(res.scpch_per_rest,1,6) in ('202204','202205') 
                             --and res.scpch_cod_ind = 'CGE' -- À enlever permet de tester pour un seul individu.
                           group by res.scpch_sig_sys,
                                    res.scpch_cod_prod,
                                    res.scpch_cod_act,
                                    res.scpch_cod_trav,
                                    res.scpch_cod_ind,
                                    substr(res.scpch_per_rest,1,6)
                          ) 
        select resf.no_seq_ressource,
               uti.CO_UTILISATEUR, 
               uti.CO_EMPLOYE_SHQ, 
               uti.PRE_EMPLOYE, 
               uti.NOM_EMPLOYE,
               scp.systeme, 
               scp.production, 
               scp.activite, 
               scp.travail, 
               scp.code_individu, 
               to_date(scp.an_mois_periode || '-01','YYYY-MM-DD') as debut_periode,
               last_day(to_date(scp.an_mois_periode || '-01','YYYY-MM-DD')) as fin_periode,
               scp.total_temps,
               null as code_dans_scp,
               sup.no_seq_specialite as no_seq_specialite,
               scp.an_mois_periode as an_mois_periode
        from busv_utilisateur_int uti,
             temps_scp            scp,
             fdtt_ressource       resf,
             fdtt_ressource_info_suppl sup 
        where uti.CO_UTILISATEUR = 'SHQ' || scp.code_individu
          and scp.code_individu <> 'MXT'  -- On ne traite pas Maxime Tremblay qui est un fournisseur maintenant dans FDT 2.0
          and resf.co_employe_shq = uti.CO_EMPLOYE_SHQ
          and sup.no_seq_ressource = resf.no_seq_ressource
          and sup.dt_fin is null 
        union all
        select resfd.no_seq_ressource,
               uti.CO_UTILISATEUR, 
               uti.CO_EMPLOYE_SHQ, 
               uti.PRE_EMPLOYE, 
               uti.NOM_EMPLOYE,
               scp.systeme, 
               scp.production,
               scp.activite, 
               scp.travail, 
               scp.code_individu, 
               to_date(scp.an_mois_periode || '-01','YYYY-MM-DD') as debut_periode,
               last_day(to_date(scp.an_mois_periode || '-01','YYYY-MM-DD')) as fin_periode,
               scp.total_temps,
               cutic.valeur_applicable as code_dans_scp,
               supp.no_seq_specialite as no_seq_specialite,
               scp.an_mois_periode as an_mois_periode
        from busv_utilisateur_int uti,
             temps_scp            scp,
             pilt_valeur_tab_1_nivea cutic,
             fdtt_ressource       resfd,
             fdtt_ressource_info_suppl supp
        where cutic.valeur_applicable  = 'SHQ' || scp.code_individu
          and uti.CO_UTILISATEUR       = cutic.val_niveau
          and resfd.co_employe_shq     = uti.CO_EMPLOYE_SHQ
          and supp.no_seq_ressource    = resfd.no_seq_ressource
          and (supp.dt_fin is null or supp.dt_fin > to_date('2022-05-01','yyyy-mm-dd')) 
        union all
        select resfdt.no_seq_ressource,
               null, 
               null,
               resfdt.prenom || resfdt.nom,
               resfdt.nom_firme,
               scp.systeme, 
               scp.production,
               scp.activite, 
               scp.travail, 
               scp.code_individu, 
               to_date(scp.an_mois_periode || '-01','YYYY-MM-DD') as debut_periode,
               last_day(to_date(scp.an_mois_periode || '-01','YYYY-MM-DD')) as fin_periode,
               scp.total_temps,
               equi.code_ressource_source as code_dans_scp,
               suppl.no_seq_specialite as no_seq_specialite,
               scp.an_mois_periode as an_mois_periode  
        from fdtt_ressource resfdt,
             fdtw_code_equivalence equi,
             temps_scp scp,
             fdtt_ressource_info_suppl suppl
        where resfdt.co_employe_shq is null
          and equi.no_seq_ressource_equiv = resfdt.no_seq_ressource
          and scp.code_individu           = equi.code_ressource_source
          and suppl.no_seq_ressource      = resfdt.no_seq_ressource
          and (suppl.dt_fin is null or suppl.dt_fin > sysdate)  
          order by 2,6,7,8,9,1
        ) tinter,
scp2.scpte_res_trav restrav 
where restrav.scpch_sig_sys  = tinter.systeme
  and restrav.scpch_cod_prod = tinter.production 
  and restrav.scpch_cod_act  = tinter.activite
  and restrav.scpch_cod_trav = tinter.travail  
  and restrav.scpch_an_plan  = '2022-2023';
   --
end fdt_prb_transfert_interv_central_vers_fdt;
/

