prompt PL/SQL Developer Export User Objects for user FDT2@DEV01
prompt Created by SHQIAR on 5 décembre 2022
set define off
spool fdt.log

prompt
prompt Creating function FDT_FNB_APX_OBT_NB_MINUTES_USAGER
prompt ===================================================
prompt
CREATE OR REPLACE FUNCTION FDT_FNB_APX_OBT_NB_MINUTES_USAGER(pnu_no_seq_ressource in number,
                                                             pdt_date_debut in date,
                                                             pdt_date_fin in date default null)
return number as
--
vnu_sum_minutes  number;
--
begin
   vnu_sum_minutes := 0;
   --
   select sum(nvl(att.nb_hmin_jour, res.nb_hmin_jour_ressr)) nb_minute into vnu_sum_minutes
   from fdtt_details_att    att,
        fdtt_ressource     res,
        fdtt_temps_jours    jou,
        fdtt_feuilles_temps fdt
   where res.no_seq_ressource   = pnu_no_seq_ressource
     and res.NO_SEQ_RESSOURCE   = att.NO_SEQ_RESSOURCE (+)
     and fdt.no_seq_ressource   = res.NO_SEQ_RESSOURCE
     and jou.no_seq_feuil_temps = fdt.no_seq_feuil_temps
     and jou.dt_temps_jour between nvl(att.dt_debut_att (+), jou.dt_temps_jour) and nvl(att.dt_fin_att (+), jou.dt_temps_jour)
     and jou.dt_temps_jour between pdt_date_debut and nvl(pdt_date_fin, pdt_date_debut)
     and jou.no_seq_activite is null;
   --
   return vnu_sum_minutes;
END fdt_fnb_apx_obt_nb_minutes_usager;
/

prompt
prompt Creating function FDT_FNB_APX_OBT_CRED_HOR_AN_USAGER
prompt ====================================================
prompt
create or replace function fdt_fnb_apx_obt_cred_hor_an_usager (pda_date_temps       in date,
                                                               pnu_no_seq_ressource in number)
return number as
--
vnu_sum_crd_hor_en_jour  number;
vda_date_debut date;
vda_date_fin date;
--
begin
   vnu_sum_crd_hor_en_jour := 0;
   --
   if pda_date_temps <  to_date(extract(year from pda_date_temps) ||'-04'|| '-01', 'yyyy-mm-dd') then
      vda_date_debut := to_date((extract(year from pda_date_temps)-1) ||'-04'|| '-01', 'yyyy-mm-dd');
      vda_date_fin   := to_date(extract(year from pda_date_temps) ||'-03'|| '-31', 'yyyy-mm-dd');
   else
      vda_date_debut := to_date(extract(year from pda_date_temps)||'-04'|| '-01', 'yyyy-mm-dd');
      vda_date_fin   := to_date((extract(year from pda_date_temps) + 1) ||'-03'|| '-31', 'yyyy-mm-dd');
   end if;
   --

   with act_credit_horaire as(select act.no_seq_activite
                              from fdtt_activites act
                              where act.acronyme = '122')
   select nvl(round(sum(tj.total_temps_min / fdt_fnb_apx_obt_nb_minutes_usager(pnu_no_seq_ressource,tj.dt_temps_jour)),2),0) journee_credit into vnu_sum_crd_hor_en_jour
   from fdtt_feuilles_temps ft,
        fdtt_temps_jours tj,
        act_credit_horaire ch
   where ft.no_seq_ressource   = pnu_no_seq_ressource
     and ft.an_mois_fdt BETWEEN to_char(vda_date_debut,'YYYYMM') and to_char(vda_date_fin,'YYYYMM')
     and tj.no_seq_feuil_temps = ft.no_seq_feuil_temps
     and tj.no_seq_activite    = ch.no_seq_activite;
   --
   return vnu_sum_crd_hor_en_jour;
end fdt_fnb_apx_obt_cred_hor_an_usager;
/

prompt
prompt Creating function FDT_FNB_APX_OBT_FCT_INTERV
prompt ============================================
prompt
CREATE OR REPLACE FUNCTION FDT_FNB_APX_OBT_FCT_INTERV(pnu_co_employe_shq_inter in number,
                                                      pnu_co_employe_shq_fdt   in number)
return varchar2 as
   --
   vva_co_typ_fonction  varchar2(50);
   -- Curseur
   cursor cur_obtenir_fonction_inter is
      select fct.co_typ_fonction
      from fdtt_fonct_intervenants fct,
           fdtt_assoc_employes_grp grp
      where fct.co_employe_shq = pnu_co_employe_shq_inter
        and utl_fnb_obt_dt_prodc('FDT', 'DA') between fct.dt_debut_fonction and nvl(fct.dt_fin_fonction,utl_fnb_obt_dt_prodc('FDT', 'DA'))
        and grp.no_seq_groupe       = fct.no_seq_groupe      
        and grp.co_employe_shq  = pnu_co_employe_shq_fdt
        and utl_fnb_obt_dt_prodc('FDT', 'DS') between grp.dt_debut_association and nvl(grp.dt_fin_association,utl_fnb_obt_dt_prodc('FDT', 'DS')); 
   --
begin  
--
   open  cur_obtenir_fonction_inter;
	    fetch cur_obtenir_fonction_inter into vva_co_typ_fonction;
	 close cur_obtenir_fonction_inter;
   --
   return vva_co_typ_fonction;
--
end fdt_fnb_apx_obt_fct_interv;
/

prompt
prompt Creating function FDT_FNB_APX_VERIF_ARTT_USAGER
prompt ===============================================
prompt
CREATE OR REPLACE FUNCTION FDT_FNB_APX_VERIF_ARTT_USAGER (pnu_no_seq_ressource in number,
                                                          pdt_date_debut       in date,
                                                          pdt_date_fin         in date default null)
return boolean as
--
vnu_nb_heure_jour  number;
vnu_nb_heure_usagr number;
--
begin
   --
   select max(att.nb_hmin_jour),
           max(res.nb_hmin_jour_ressr) into vnu_nb_heure_jour, vnu_nb_heure_usagr
   from fdtt_details_att    att,
        fdtt_ressource      res,
        fdtt_temps_jours    jou,
        fdtt_feuilles_temps fdt
   where res.no_seq_ressource   = pnu_no_seq_ressource
     and res.NO_SEQ_RESSOURCE   = att.NO_SEQ_RESSOURCE (+)
     and fdt.no_seq_ressource   = res.NO_SEQ_RESSOURCE
     and jou.no_seq_feuil_temps = fdt.no_seq_feuil_temps
     and jou.dt_temps_jour between nvl(att.dt_debut_att (+), jou.dt_temps_jour) and nvl(att.dt_fin_att (+), jou.dt_temps_jour)
     and jou.dt_temps_jour between pdt_date_debut and nvl(pdt_date_fin, pdt_date_debut)
     and jou.no_seq_activite is null;
   --
   if vnu_nb_heure_jour > 0  then
      return true;
   end if;
    if vnu_nb_heure_usagr > 0  then
      return false;
   end if;
  return null;
END FDT_FNB_APX_VERIF_ARTT_USAGER;
/

prompt
prompt Creating function FDT_FNB_INTERVENTION_SANS_EQUIVALENCE_SCP
prompt ===========================================================
prompt
CREATE OR REPLACE FUNCTION fdt_fnb_intervention_sans_equivalence_scp(pva_an_mois_fdt varchar2)
return BOOLEAN as
--
-- Déclaration de variables
--
-- Curseur
-- Va chercher les interventions du mois passée en paramètre pour s'assurer que chacune des interventions ,saisies
-- par les différentes ressources, sont dans la table de concordance de SCP2 (scp2.scpte_res_trav).
   cursor cur_obt_inter_sans_equivalence_scp is
   select count(*) as nombre_inter_sans_equivalence
   from fdtt_temps_intervention ti
   where ti.an_mois_fdt = pva_an_mois_fdt
     and ti.no_seq_aact_intrv_det not in (select trav.no_seq_aact_intrv_det
                                          from scp2.scpte_res_trav trav
                                          where trav.no_seq_aact_intrv_det = ti.no_seq_aact_intrv_det );
   --
   rec_obt_inter_sans_equivalence_scp   cur_obt_inter_sans_equivalence_scp%rowtype;
begin
   --
   open  cur_obt_inter_sans_equivalence_scp;
      fetch cur_obt_inter_sans_equivalence_scp into rec_obt_inter_sans_equivalence_scp;
   close cur_obt_inter_sans_equivalence_scp;
   --
   if rec_obt_inter_sans_equivalence_scp.nombre_inter_sans_equivalence > 0 then
      return true;
   else
      return false;
   end if;
--
end fdt_fnb_intervention_sans_equivalence_scp;
/

prompt
prompt Creating function FDT_FNB_INTERVENTION_SANS_EQUIVALENCE_SCP_COMPLET
prompt ===================================================================
prompt
CREATE OR REPLACE FUNCTION fdt_fnb_intervention_sans_equivalence_scp_complet
return BOOLEAN as
--
-- Déclaration de variables
--
-- Curseur
-- Va chercher les interventions du mois passée en paramètre pour s'assurer que chacune des interventions ,saisies
-- par les différentes ressources, sont dans la table de concordance de SCP2 (scp2.scpte_res_trav).
   cursor cur_obt_inter_sans_equivalence_scp is
   select count(*) as nombre_inter_sans_equivalence
   from fdtt_temps_intervention ti
   where ti.no_seq_aact_intrv_det not in (select trav.no_seq_aact_intrv_det
                                          from scp2.scpte_res_trav trav
                                          where no_seq_aact_intrv_det is not null );
   --
   rec_obt_inter_sans_equivalence_scp   cur_obt_inter_sans_equivalence_scp%rowtype;
begin
   --
   open  cur_obt_inter_sans_equivalence_scp;
      fetch cur_obt_inter_sans_equivalence_scp into rec_obt_inter_sans_equivalence_scp;
   close cur_obt_inter_sans_equivalence_scp;
   --
   if rec_obt_inter_sans_equivalence_scp.nombre_inter_sans_equivalence > 0 then
      return true;
   else
      return false;
   end if;
--
end fdt_fnb_intervention_sans_equivalence_scp_complet;
/

prompt
prompt Creating function FDT_FNB_RESSOURCE_SANS_CODE_EQUIVALENCE
prompt =========================================================
prompt
CREATE OR REPLACE FUNCTION fdt_fnb_ressource_sans_code_equivalence
return BOOLEAN as
--
-- Déclaration de variables
--
-- Curseur
-- Va chercher les ressources qui ne sont pas dans BUS, qui ont saisi au moins une intervention et
-- qui ne sont pas dans la table d'équivalence (ils soivent l'être absolument pour faire la concordance
-- avec le central.
   cursor cur_obt_ressource_sans_code_equivalence is
      select count(*) as nombre_ressource_sans_equivalence
      from fdtt_ressource res
      where res.co_employe_shq is null
        and res.no_seq_ressource in (select no_seq_ressource
                                     from fdtt_temps_intervention tinter
                                     where tinter.no_seq_ressource = res.no_seq_ressource)
        and res.no_seq_ressource not in (select equi.no_seq_ressource_equiv
                                         from fdtw_code_equivalence equi
                                         where equi.no_seq_ressource_equiv = res.no_seq_ressource);
   --
   rec_obt_ressource_sans_code_equivalence   cur_obt_ressource_sans_code_equivalence%rowtype;
begin
   --
   open  cur_obt_ressource_sans_code_equivalence;
      fetch cur_obt_ressource_sans_code_equivalence into rec_obt_ressource_sans_code_equivalence;
   close cur_obt_ressource_sans_code_equivalence;
   --
   if rec_obt_ressource_sans_code_equivalence.nombre_ressource_sans_equivalence > 0 then
      return true;
   else
      return false;
   end if;
--
end fdt_fnb_ressource_sans_code_equivalence;
/

prompt
prompt Creating procedure FDT_PRB_APX_CALCULER_TOTAUX_FEUILLE_TEMPS
prompt ============================================================
prompt
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

prompt
prompt Creating procedure FDT_PRB_APX_CREER_FEUILLE_TEMPS
prompt ==================================================
prompt
CREATE OR REPLACE PROCEDURE FDT_PRB_APX_CREER_FEUILLE_TEMPS (pnu_co_employe_shq   in number,
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

prompt
prompt Creating procedure FDT_PRB_APX_CREER_FEUILLE_TEMPS_INTER_FDT
prompt ============================================================
prompt
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

prompt
prompt Creating procedure FDT_PRB_APX_OBT_FCT_INTERV
prompt =============================================
prompt
CREATE OR REPLACE PROCEDURE FDT_PRB_APX_OBT_FCT_INTERV(pnu_co_employe_shq_inter in number,
                                                       pnu_co_employe_shq_fdt   in number,
                                                       pnu_NO_SEQ_FONCT_INTERVENANT out fdtt_fonct_intervenants.no_seq_fonct_intrv%type,
                                                       pva_co_typ_fonction out fdtt_fonct_intervenants.co_typ_fonction%type)
is
   --
   -- Curseur
   cursor cur_obtenir_fonction_inter is
      select fct.co_typ_fonction, fct.no_seq_fonct_intrv
      from fdtt_fonct_intervenants fct,
           fdtt_assoc_employes_grp grp
      where fct.co_employe_shq = pnu_co_employe_shq_inter
        and utl_fnb_obt_dt_prodc('FDT', 'DA') between fct.dt_debut_fonction and nvl(fct.dt_fin_fonction,utl_fnb_obt_dt_prodc('FDT', 'DA'))
        and grp.no_seq_groupe       = fct.no_seq_groupe
        and grp.co_employe_shq  = pnu_co_employe_shq_fdt
        and utl_fnb_obt_dt_prodc('FDT', 'DS') between grp.dt_debut_association and nvl(grp.dt_fin_association,utl_fnb_obt_dt_prodc('FDT', 'DS'));
   --
   rec_obtenir_fonction_inter cur_obtenir_fonction_inter%rowtype;
begin
--
   open  cur_obtenir_fonction_inter;
      fetch cur_obtenir_fonction_inter into rec_obtenir_fonction_inter;
   close cur_obtenir_fonction_inter;
   --
   pva_co_typ_fonction          := rec_obtenir_fonction_inter.co_typ_fonction;
   pnu_NO_SEQ_FONCT_INTERVENANT := rec_obtenir_fonction_inter.no_seq_fonct_intrv;
--
end FDT_PRB_APX_OBT_FCT_INTERV;
/

prompt
prompt Creating procedure FDT_PRB_TRANSFERT_INTERV_CENTRAL_VERS_FDT
prompt ============================================================
prompt
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

prompt
prompt Creating trigger FDT_TRB_ACTIVITES_BIUR
prompt =======================================
prompt
CREATE OR REPLACE TRIGGER FDT_TRB_ACTIVITES_BIUR before insert or update ON FDTT_ACTIVITES
 for each row
begin
  case
  
    when inserting then
      --
      -- Initialiser la séquence 
      if :new.no_seq_activite is null then
         :new.no_seq_activite := fdtactiv_seq.nextval;
      end if;

      --
      if :new.co_user_cre_enreg is null then
        :new.co_user_cre_enreg := coalesce(apex_application.g_user, user);
      end if;
      --
      :new.dh_cre_enreg := systimestamp;

    when updating then
      if :new.co_user_maj_enreg is null then
        :new.co_user_maj_enreg := coalesce(apex_application.g_user, user);
      end if;
      --
      :new.dh_maj_enreg := systimestamp;
    else
      null;
  end case;
end;
/

prompt
prompt Creating trigger FDT_TRB_ASS_ACTINTRV_BIUR
prompt ==========================================
prompt
CREATE OR REPLACE TRIGGER FDT_TRB_ASS_ACTINTRV_BIUR
 before insert or update on FDTT_ASS_ACT_INTRV_DET
 for each row
begin
  case
  
    when inserting then
      --
      -- Initialiser la séquence 
      if :new.no_seq_aact_intrv_det is null then
         :new.no_seq_aact_intrv_det := fdtaaintrvd_seq.nextval;
      end if;

      --
      if :new.co_user_cre_enreg is null then
        :new.co_user_cre_enreg := coalesce(apex_application.g_user, user);
      end if;
      --
      :new.dh_cre_enreg := systimestamp;

    when updating then
      if :new.co_user_maj_enreg is null then
        :new.co_user_maj_enreg := coalesce(apex_application.g_user, user);
      end if;
      --
      :new.dh_maj_enreg := systimestamp;
    else
      null;
  end case;
end;
/

prompt
prompt Creating trigger FDT_TRB_ASSOC_EMPLOYE_GRP_BIUR
prompt ===============================================
prompt
CREATE OR REPLACE TRIGGER FDT_TRB_ASSOC_EMPLOYE_GRP_BIUR
 before insert or update on "FDTT_ASSOC_EMPLOYES_GRP"
 for each row
begin
  case
    when inserting then
      --
      -- Initialiser la séquence
      if :new.no_seq_asso_empl_grp is null then
        :new.no_seq_asso_empl_grp := fdtassemplgrp_seq.nextval;
      end if;

      --
      if :new.co_user_cre_enreg is null then
        :new.co_user_cre_enreg := coalesce(apex_application.g_user, user);
      end if;
      --
      :new.dh_cre_enreg := systimestamp;

    when updating then
      if :new.co_user_maj_enreg is null then
        :new.co_user_maj_enreg := coalesce(apex_application.g_user, user);
      end if;
      --
      :new.dh_maj_enreg := systimestamp;
    else
      null;
  end case;
end;
/

prompt
prompt Creating trigger FDT_TRB_ASS_TINTRV_QUALF_BIUR
prompt ==============================================
prompt
CREATE OR REPLACE TRIGGER FDT_TRB_ASS_TINTRV_QUALF_BIUR before insert or update on FDTT_ASS_TYP_INTRV_QUALF
 for each row
begin
  case
  
    when inserting then
      -- Initialiser la séquence
     
      if :new.no_seq_ass_typ_intrv_qualf is null then
        :new.no_seq_ass_typ_intrv_qualf := fdtatintrvq_seq.nextval;
      end if;

      --
      if :new.co_user_cre_enreg is null then
        :new.co_user_cre_enreg := coalesce(apex_application.g_user, user);
      end if;
      --
      :new.dh_cre_enreg := systimestamp;

    when updating then
      if :new.co_user_maj_enreg is null then
        :new.co_user_maj_enreg := coalesce(apex_application.g_user, user);
      end if;
      --
      :new.dh_maj_enreg := systimestamp;
    else
      null;
  end case;
end;
/

prompt
prompt Creating trigger FDT_TRB_ASS_TSERV_QUALF_BIUR
prompt =============================================
prompt
CREATE OR REPLACE TRIGGER FDT_TRB_ASS_TSERV_QUALF_BIUR before insert or update on FDTT_ASS_TYP_SERV_QUALF
 for each row
begin
  case
  
    when inserting then
      -- Initialiser la séquence
     
      if :new.no_seq_ass_typ_serv_qualf is null then
        :new.no_seq_ass_typ_serv_qualf := fdtatservq_seq.nextval;
      end if;

      --
      if :new.co_user_cre_enreg is null then
        :new.co_user_cre_enreg := coalesce(apex_application.g_user, user);
      end if;
      --
      :new.dh_cre_enreg := systimestamp;

    when updating then
      if :new.co_user_maj_enreg is null then
        :new.co_user_maj_enreg := coalesce(apex_application.g_user, user);
      end if;
      --
      :new.dh_maj_enreg := systimestamp;
    else
      null;
  end case;
end;
/

prompt
prompt Creating trigger FDT_TRB_CALDR_ABS_BIUR
prompt =======================================
prompt
CREATE OR REPLACE TRIGGER FDT_TRB_CALDR_ABS_BIUR
 before insert or update on FDTT_CALENDRIER_ABSENCE
 for each row
begin
  case
  
    when inserting then
      --
      -- Initialiser la séquence 
      if :new.no_seq_calnd_absence is null then
         :new.no_seq_calnd_absence := fdtcalabs_seq.nextval;
      end if;

      --
      if :new.co_user_cre_enreg is null then
        :new.co_user_cre_enreg := coalesce(apex_application.g_user, user);
      end if;
      --
      :new.dh_cre_enreg := systimestamp;

    when updating then
      if :new.co_user_maj_enreg is null then
        :new.co_user_maj_enreg := coalesce(apex_application.g_user, user);
      end if;
      --
      :new.dh_maj_enreg := systimestamp;
    else
      null;
  end case;
end;
/

prompt
prompt Creating trigger FDT_TRB_CATEG_ACTIV_BIUR
prompt =========================================
prompt
CREATE OR REPLACE TRIGGER FDT_TRB_CATEG_ACTIV_BIUR
 before insert or update on "FDTT_CATEGORIE_ACTIVITES"
 for each row
begin
  case
  
    when inserting then
      --
      -- Initialiser la séquence 
      if :new.no_seq_categ_activ is null then
         :new.no_seq_categ_activ := fdtcatact_seq.nextval;
      end if;

      --
      if :new.co_user_cre_enreg is null then
        :new.co_user_cre_enreg := coalesce(apex_application.g_user, user);
      end if;
      --
      :new.dh_cre_enreg := systimestamp;

    when updating then
      if :new.co_user_maj_enreg is null then
        :new.co_user_maj_enreg := coalesce(apex_application.g_user, user);
      end if;
      --
      :new.dh_maj_enreg := systimestamp;
    else
      null;
  end case;
end;
/

prompt
prompt Creating trigger FDT_TRB_CATEG_COUT_BIUR
prompt ========================================
prompt
CREATE OR REPLACE TRIGGER FDT_TRB_CATEG_COUT_BIUR
 before insert or update on FDTT_CATEGORIE_COUT
 for each row
begin
  case
  
    when inserting then
      -- Initialiser la séquence
      if :new.no_seq_categorie_cout is null then
        :new.no_seq_categorie_cout := fdtccout_seq.nextval;
      end if;

      --
      if :new.co_user_cre_enreg is null then
        :new.co_user_cre_enreg := coalesce(apex_application.g_user, user);
      end if;
      --
      :new.dh_cre_enreg := systimestamp;

    when updating then
      if :new.co_user_maj_enreg is null then
        :new.co_user_maj_enreg := coalesce(apex_application.g_user, user);
      end if;
      --
      :new.dh_maj_enreg := systimestamp;
    else
      null;
  end case;
end;
/

prompt
prompt Creating trigger FDT_TRB_DETAILS_ATT_BIUR
prompt =========================================
prompt
CREATE OR REPLACE TRIGGER "FDT_TRB_DETAILS_ATT_BIUR" before insert or update on "FDTT_DETAILS_ATT"
 for each row
begin
  case
    when inserting then
      --
      -- Initialiser la séquence
      if :new.no_seq_detail_attrav  is null then
        :new.no_seq_detail_attrav := fdtamenttrav_seq.nextval;
      end if;

      --
      if :new.co_user_cre_enreg is null then
        :new.co_user_cre_enreg := coalesce(apex_application.g_user, user);
      end if;
      --
      :new.dh_cre_enreg := systimestamp;

    when updating then
      if :new.co_user_maj_enreg is null then
        :new.co_user_maj_enreg := coalesce(apex_application.g_user, user);
      end if;
      --
      :new.dh_maj_enreg := systimestamp;
    else
      null;
  end case;
end;
/

prompt
prompt Creating trigger FDT_TRB_DIRECTION_BIUR
prompt =======================================
prompt
CREATE OR REPLACE TRIGGER FDT_TRB_DIRECTION_BIUR
 before insert or update on "FDTT_DIRECTION"
 for each row
begin
  case
  
    when inserting then
      --
      -- Initialiser la séquence
      if :new.no_seq_direction is null then
        :new.no_seq_direction := fdtdirec_seq.nextval;
      end if;

      --
      if :new.co_user_cre_enreg is null then
        :new.co_user_cre_enreg := coalesce(apex_application.g_user, user);
      end if;
      --
      :new.dh_cre_enreg := systimestamp;

    when updating then
      if :new.co_user_maj_enreg is null then
        :new.co_user_maj_enreg := coalesce(apex_application.g_user, user);
      end if;
      --
      :new.dh_maj_enreg := systimestamp;
    else
      null;
  end case;
end;
/

prompt
prompt Creating trigger FDT_TRB_FEUILLE_TEMPS_BIUR
prompt ===========================================
prompt
CREATE OR REPLACE TRIGGER FDT_TRB_FEUILLE_TEMPS_BIUR
 before insert or update on "FDTT_FEUILLES_TEMPS"
 for each row
begin
  case
  
    when inserting then
      -- Initialiser la séquence
      if :new.no_seq_feuil_temps is null then
        :new.no_seq_feuil_temps := fdtfeuiltemps_seq.nextval;
      end if;
      --
      if :new.co_user_cre_enreg is null then
        :new.co_user_cre_enreg := coalesce(apex_application.g_user, user);
      end if;
      --
      :new.dh_cre_enreg := systimestamp;

    when updating then
      if :new.co_user_maj_enreg is null then
        :new.co_user_maj_enreg := coalesce(apex_application.g_user, user);
      end if;
      --
      :new.dh_maj_enreg := systimestamp;
    else
      null;
  end case;
end;
/

prompt
prompt Creating trigger FDT_TRB_FONCT_INTERVENANT_BIUR
prompt ===============================================
prompt
CREATE OR REPLACE TRIGGER FDT_TRB_FONCT_INTERVENANT_BIUR
 before insert or update on "FDTT_FONCT_INTERVENANTS"
 for each row
begin
  case
    when inserting then
      --
      -- Initialiser la séquence
      if :new.no_seq_fonct_intrv  is null then
        :new.no_seq_fonct_intrv := fdtfintrv_seq.nextval;
      end if;

      --
      if :new.co_user_cre_enreg is null then
        :new.co_user_cre_enreg := coalesce(apex_application.g_user, user);
      end if;
      --
      :new.dh_cre_enreg := systimestamp;

    when updating then
      if :new.co_user_maj_enreg is null then
        :new.co_user_maj_enreg := coalesce(apex_application.g_user, user);
      end if;
      --
      :new.dh_maj_enreg := systimestamp;
    else
      null;
  end case;
end;
/

prompt
prompt Creating trigger FDT_TRB_GROUPE_BIUR
prompt ====================================
prompt
CREATE OR REPLACE TRIGGER FDT_TRB_GROUPE_BIUR
 before insert or update on "FDTT_GROUPES"
 for each row
begin
  case
    when inserting then
      --
      -- Initialiser la séquence
      if :new.no_seq_groupe  is null then
        :new.no_seq_groupe := fdtgroup_seq.nextval;
      end if;

      --
      if :new.co_user_cre_enreg is null then
        :new.co_user_cre_enreg := coalesce(apex_application.g_user, user);
      end if;
      --
      :new.dh_cre_enreg := systimestamp;

    when updating then
      if :new.co_user_maj_enreg is null then
        :new.co_user_maj_enreg := coalesce(apex_application.g_user, user);
      end if;
      --
      :new.dh_maj_enreg := systimestamp;
    else
      null;
  end case;
end;
/

prompt
prompt Creating trigger FDT_TRB_INTERVENTION_BIUR
prompt ==========================================
prompt
CREATE OR REPLACE TRIGGER FDT_TRB_INTERVENTION_BIUR
 before insert or update on FDTT_INTERVENTION
 for each row
begin
  case
  
    when inserting then
      --
      -- Initialiser la séquence 
      if :new.no_seq_interv is null then
         :new.no_seq_interv := fdtintrv_seq.nextval;
      end if;

      --
      if :new.co_user_cre_enreg is null then
        :new.co_user_cre_enreg := coalesce(apex_application.g_user, user);
      end if;
      --
      :new.dh_cre_enreg := systimestamp;

    when updating then
      if :new.co_user_maj_enreg is null then
        :new.co_user_maj_enreg := coalesce(apex_application.g_user, user);
      end if;
      --
      :new.dh_maj_enreg := systimestamp;
    else
      null;
  end case;
end;
/

prompt
prompt Creating trigger FDT_TRB_INTRV_DETAIL_BIUR
prompt ==========================================
prompt
CREATE OR REPLACE TRIGGER FDT_TRB_INTRV_DETAIL_BIUR
 before insert or update on FDTT_INTERVENTION_DETAIL
 for each row
begin
  case
  
    when inserting then
      --
      -- Initialiser la séquence 
      if :new.no_seq_intrv_detail is null then
         :new.no_seq_intrv_detail := fdtintrvd_seq.nextval;
      end if;

      --
      if :new.co_user_cre_enreg is null then
        :new.co_user_cre_enreg := coalesce(apex_application.g_user, user);
      end if;
      --
      :new.dh_cre_enreg := systimestamp;

    when updating then
      if :new.co_user_maj_enreg is null then
        :new.co_user_maj_enreg := coalesce(apex_application.g_user, user);
      end if;
      --
      :new.dh_maj_enreg := systimestamp;
    else
      null;
  end case;
end;
/

prompt
prompt Creating trigger FDT_TRB_INTRVD_RESSR_BIUR
prompt ==========================================
prompt
CREATE OR REPLACE TRIGGER FDT_TRB_INTRVD_RESSR_BIUR
 before insert or update on FDTT_ASS_INTRVD_RESSR
 for each row
begin
  case
  
    when inserting then
      --
      -- Initialiser la séquence 
      if :new.no_seq_ass_intrvd_ressr is null then
         :new.no_seq_ass_intrvd_ressr := fdtaintrvdr_seq.nextval;
      end if;

      --
      if :new.co_user_cre_enreg is null then
        :new.co_user_cre_enreg := coalesce(apex_application.g_user, user);
      end if;
      --
      :new.dh_cre_enreg := systimestamp;

    when updating then
      if :new.co_user_maj_enreg is null then
        :new.co_user_maj_enreg := coalesce(apex_application.g_user, user);
      end if;
      --
      :new.dh_maj_enreg := systimestamp;
    else
      null;
  end case;
end;
/

prompt
prompt Creating trigger FDT_TRB_QUALIFICATION_BIUR
prompt ===========================================
prompt
CREATE OR REPLACE TRIGGER FDT_TRB_QUALIFICATION_BIUR
 before insert or update on FDTT_QUALIFICATION
 for each row
begin
  case
  
    when inserting then
      -- Initialiser la séquence
      if :new.no_seq_qualification is null then
        :new.no_seq_qualification := fdtqualf_seq.nextval;
      end if;

      --
      if :new.co_user_cre_enreg is null then
        :new.co_user_cre_enreg := coalesce(apex_application.g_user, user);
      end if;
      --
      :new.dh_cre_enreg := systimestamp;

    when updating then
      if :new.co_user_maj_enreg is null then
        :new.co_user_maj_enreg := coalesce(apex_application.g_user, user);
      end if;
      --
      :new.dh_maj_enreg := systimestamp;
    else
      null;
  end case;
end;
/

prompt
prompt Creating trigger FDT_TRB_RESSOURCE_BIUR
prompt =======================================
prompt
CREATE OR REPLACE TRIGGER FDT_TRB_RESSOURCE_BIUR
 before insert or update on FDTT_RESSOURCE
 for each row
begin
  case
    when inserting then
      --
      -- Initialiser la séquence
      if :new.no_seq_ressource  is null then
        :new.no_seq_ressource := fdtressr_seq.nextval;
      end if;

      --
      if :new.co_user_cre_enreg is null then
        :new.co_user_cre_enreg := coalesce(apex_application.g_user, user);
      end if;
      --
      :new.dh_cre_enreg := systimestamp;

    when updating then
      if :new.co_user_maj_enreg is null then
        :new.co_user_maj_enreg := coalesce(apex_application.g_user, user);
      end if;
      --
      :new.dh_maj_enreg := systimestamp;
    else
      null;
  end case;
end;
/

prompt
prompt Creating trigger FDT_TRB_RESSOURCE_INFO_SUPPL_BIUR
prompt ==================================================
prompt
CREATE OR REPLACE TRIGGER FDT_TRB_RESSOURCE_INFO_SUPPL_BIUR
 before insert or update on FDTT_RESSOURCE_INFO_SUPPL
 for each row
begin
  case
    when inserting then
      --
      -- Initialiser la séquence
      if :new.no_seq_ressr_info_suppl  is null then
        :new.no_seq_ressr_info_suppl := fdtressrinfosup_seq.nextval;
      end if;

      --
      if :new.co_user_cre_enreg is null then
        :new.co_user_cre_enreg := coalesce(apex_application.g_user, user);
      end if;
      --
      :new.dh_cre_enreg := systimestamp;

    when updating then
      if :new.co_user_maj_enreg is null then
        :new.co_user_maj_enreg := coalesce(apex_application.g_user, user);
      end if;
      --
      :new.dh_maj_enreg := systimestamp;
    else
      null;
  end case;
end;
/

prompt
prompt Creating trigger FDT_TRB_SFEUILLE_TEMPS_BIUR
prompt ============================================
prompt
CREATE OR REPLACE TRIGGER FDT_TRB_SFEUILLE_TEMPS_BIUR before insert or update on "FDTT_SUIVI_FEUILLES_TEMPS"
 for each row
begin
  case
  
    when inserting then
      --
      -- Initialiser la séquence
      if :new.no_seq_suivi_fdt is null then
        :new.no_seq_suivi_fdt := fdtsftemps_seq.nextval;
      end if;

      --
      if :new.co_user_cre_enreg is null then
        :new.co_user_cre_enreg := coalesce(apex_application.g_user, user);
      end if;
      --
      :new.dh_cre_enreg := systimestamp;

    when updating then
      if :new.co_user_maj_enreg is null then
        :new.co_user_maj_enreg := coalesce(apex_application.g_user, user);
      end if;
      --
      :new.dh_maj_enreg := systimestamp;
    else
      null;
  end case;
end;
/

prompt
prompt Creating trigger FDT_TRB_SPECIALITE_BIUR
prompt ========================================
prompt
CREATE OR REPLACE TRIGGER FDT_TRB_SPECIALITE_BIUR
 before insert or update on FDTT_SPECIALITE
 for each row
begin
  case
  
    when inserting then
      -- Initialiser la séquence
      if :new.no_seq_specialite is null then
        :new.no_seq_specialite := fdtspec_seq.nextval;
      end if;

      --
      if :new.co_user_cre_enreg is null then
        :new.co_user_cre_enreg := coalesce(apex_application.g_user, user);
      end if;
      --
      :new.dh_cre_enreg := systimestamp;

    when updating then
      if :new.co_user_maj_enreg is null then
        :new.co_user_maj_enreg := coalesce(apex_application.g_user, user);
      end if;
      --
      :new.dh_maj_enreg := systimestamp;
    else
      null;
  end case;
end;
/

prompt
prompt Creating trigger FDT_TRB_TEMPS_INTRV_BIUR
prompt =========================================
prompt
CREATE OR REPLACE TRIGGER FDT_TRB_TEMPS_INTRV_BIUR
 before insert or update on FDTT_TEMPS_INTERVENTION
 for each row
begin
  case
  
    when inserting then
      -- Initialiser la séquence
      if :new.no_seq_temps_intrv is null then
        :new.no_seq_temps_intrv := fdttintrv_seq.nextval;
      end if;

      --
      if :new.co_user_cre_enreg is null then
        :new.co_user_cre_enreg := coalesce(apex_application.g_user, user);
      end if;
      --
      :new.dh_cre_enreg := systimestamp;

    when updating then
      if :new.co_user_maj_enreg is null then
        :new.co_user_maj_enreg := coalesce(apex_application.g_user, user);
      end if;
      --
      :new.dh_maj_enreg := systimestamp;
    else
      null;
  end case;
end;


-- Create foreign keys (relationships) section -------------------------------------------------
/

prompt
prompt Creating trigger FDT_TRB_TEMPS_JOUR_BIUR
prompt ========================================
prompt
CREATE OR REPLACE TRIGGER FDT_TRB_TEMPS_JOUR_BIUR
 before insert or update on "FDTT_TEMPS_JOURS"
 for each row
begin
  case
  
    when inserting then
      -- Initialiser la séquence
      if :new.no_seq_temps_jour is null then
        :new.no_seq_temps_jour := fdttjour_seq.nextval;
      end if;

      --
      if :new.co_user_cre_enreg is null then
        :new.co_user_cre_enreg := coalesce(apex_application.g_user, user);
      end if;
      --
      :new.dh_cre_enreg := systimestamp;

    when updating then
      if :new.co_user_maj_enreg is null then
        :new.co_user_maj_enreg := coalesce(apex_application.g_user, user);
      end if;
      --
      :new.dh_maj_enreg := systimestamp;
    else
      null;
  end case;
end;


-- Create foreign keys (relationships) section -------------------------------------------------
/

prompt
prompt Creating trigger FDT_TRB_TYP_ATTRIBUT_BIUR
prompt ==========================================
prompt
CREATE OR REPLACE TRIGGER FDT_TRB_TYP_ATTRIBUT_BIUR
 before insert or update on "FDTT_TYP_INTERVENTION"
 for each row
begin
  case
  
    when inserting then
      -- Initialiser la séquence
      if :new.no_seq_typ_intervention is null then
        :new.no_seq_typ_intervention := fdttypintrv_seq.nextval;
      end if;

      --
      if :new.co_user_cre_enreg is null then
        :new.co_user_cre_enreg := coalesce(apex_application.g_user, user);
      end if;
      --
      :new.dh_cre_enreg := systimestamp;

    when updating then
      if :new.co_user_maj_enreg is null then
        :new.co_user_maj_enreg := coalesce(apex_application.g_user, user);
      end if;
      --
      :new.dh_maj_enreg := systimestamp;
    else
      null;
  end case;
end;
/

prompt
prompt Creating trigger FDT_TRB_TYP_COMPTE_BUDG_BIUR
prompt =============================================
prompt
CREATE OR REPLACE TRIGGER FDT_TRB_TYP_COMPTE_BUDG_BIUR
 before insert or update on FDTT_TYP_COMPTE_BUDG
 for each row
begin
  case
  
    when inserting then
      -- Initialiser la séquence
      if :new.no_seq_typ_compte_budg is null then
        :new.no_seq_typ_compte_budg := fdttcbudg_seq.nextval;
      end if;

      --
      if :new.co_user_cre_enreg is null then
        :new.co_user_cre_enreg := coalesce(apex_application.g_user, user);
      end if;
      --
      :new.dh_cre_enreg := systimestamp;

    when updating then
      if :new.co_user_maj_enreg is null then
        :new.co_user_maj_enreg := coalesce(apex_application.g_user, user);
      end if;
      --
      :new.dh_maj_enreg := systimestamp;
    else
      null;
  end case;
end;
/

prompt
prompt Creating trigger FDT_TRB_TYP_ETAPE_BIUR
prompt =======================================
prompt
CREATE OR REPLACE TRIGGER FDT_TRB_TYP_ETAPE_BIUR
 before insert or update on FDTT_TYP_ETAPE
 for each row
begin
  case
  
    when inserting then
      -- Initialiser la séquence
      if :new.no_seq_typ_etape is null then
        :new.no_seq_typ_etape := fdttetap_seq.nextval;
      end if;

      --
      if :new.co_user_cre_enreg is null then
        :new.co_user_cre_enreg := coalesce(apex_application.g_user, user);
      end if;
      --
      :new.dh_cre_enreg := systimestamp;

    when updating then
      if :new.co_user_maj_enreg is null then
        :new.co_user_maj_enreg := coalesce(apex_application.g_user, user);
      end if;
      --
      :new.dh_maj_enreg := systimestamp;
    else
      null;
  end case;
end;
/

prompt
prompt Creating trigger FDT_TRB_TYP_LIVRAISON_BIUR
prompt ===========================================
prompt
CREATE OR REPLACE TRIGGER FDT_TRB_TYP_LIVRAISON_BIUR
 before insert or update on FDTT_TYP_LIVRAISON
 for each row
begin
  case
  
    when inserting then
      -- Initialiser la séquence
      if :new.no_seq_typ_livraison is null then
        :new.no_seq_typ_livraison := fdttliv_seq.nextval;
      end if;

      --
      if :new.co_user_cre_enreg is null then
        :new.co_user_cre_enreg := coalesce(apex_application.g_user, user);
      end if;
      --
      :new.dh_cre_enreg := systimestamp;

    when updating then
      if :new.co_user_maj_enreg is null then
        :new.co_user_maj_enreg := coalesce(apex_application.g_user, user);
      end if;
      --
      :new.dh_maj_enreg := systimestamp;
    else
      null;
  end case;
end;
/

prompt
prompt Creating trigger FDT_TRB_TYP_SERVICE_BIUR
prompt =========================================
prompt
CREATE OR REPLACE TRIGGER FDT_TRB_TYP_SERVICE_BIUR
 before insert or update on "FDTT_TYP_SERVICE"
 for each row
begin
  case
  
    when inserting then
      -- Initialiser la séquence
      if :new.no_seq_typ_service is null then
        :new.no_seq_typ_service := fdttypserv_seq.nextval;
      end if;

      --
      if :new.co_user_cre_enreg is null then
        :new.co_user_cre_enreg := coalesce(apex_application.g_user, user);
      end if;
      --
      :new.dh_cre_enreg := systimestamp;

    when updating then
      if :new.co_user_maj_enreg is null then
        :new.co_user_maj_enreg := coalesce(apex_application.g_user, user);
      end if;
      --
      :new.dh_maj_enreg := systimestamp;
    else
      null;
  end case;
end;
/

prompt
prompt Creating trigger FDT_TRB_TYP_STRATEGIE_BIUR
prompt ===========================================
prompt
CREATE OR REPLACE TRIGGER FDT_TRB_TYP_STRATEGIE_BIUR
 before insert or update on FDTT_TYP_STRATEGIE
 for each row
begin
  case
  
    when inserting then
      -- Initialiser la séquence
      if :new.no_seq_typ_strategie is null then
        :new.no_seq_typ_strategie := fdttstrag_seq.nextval;
      end if;

      --
      if :new.co_user_cre_enreg is null then
        :new.co_user_cre_enreg := coalesce(apex_application.g_user, user);
      end if;
      --
      :new.dh_cre_enreg := systimestamp;

    when updating then
      if :new.co_user_maj_enreg is null then
        :new.co_user_maj_enreg := coalesce(apex_application.g_user, user);
      end if;
      --
      :new.dh_maj_enreg := systimestamp;
    else
      null;
  end case;
end;
/

prompt
prompt Creating trigger FDT_TRB_VRFDTES_BIUR
prompt =====================================
prompt
CREATE OR REPLACE TRIGGER "FDT_TRB_VRFDTES_BIUR" BEFORE INSERT OR UPDATE
  ON "FDTT_FONCT_INTERVENANTS"
 REFERENCING  OLD AS OLD NEW AS NEW
 FOR EACH ROW
DECLARE
  VBO_RESULTAT BOOLEAN;
  VVA_MESSAGE  VARCHAR2(4000);
  VVA_TYPE     VARCHAR2(1);
  VNU_RETOUR NUMBER(1);
  VDA_DT_ACTUELLE DATE;
BEGIN
   VDA_DT_ACTUELLE := UTL_FNB_OBT_DT_PRODC('FDT', 'DA');
   IF :NEW.DT_FIN_FONCTION < VDA_DT_ACTUELLE THEN
	  -- LA DATE DE FIN DOIT êTRE éGALE OU SUPéRIEURE à LA DATE DU JOUR.
	  VBO_RESULTAT := UTL_PKB_MESSAGE.LIRE_MESSAGE('FDT.000010', NULL, VVA_TYPE, VVA_MESSAGE);
      RAISE_APPLICATION_ERROR(-20001, VVA_MESSAGE);
   END IF;
   IF :NEW.DT_FIN_FONCTION < :NEW.DT_DEBUT_FONCTION THEN
	  -- LA DATE DE FIN DOIT êTRE éGALE OU SUPéRIEURE à LA DATE DéBUT
	  VBO_RESULTAT := UTL_PKB_MESSAGE.LIRE_MESSAGE('FDT.000011', NULL, VVA_TYPE, VVA_MESSAGE);
      RAISE_APPLICATION_ERROR(-20001, VVA_MESSAGE);
   END IF;
   IF INSERTING THEN
      IF :NEW.DT_DEBUT_FONCTION < VDA_DT_ACTUELLE THEN
         -- LA DATE DE DéBUT DOIT êTRE éGALE OU SUPéRIEURE à LA DATE DU JOUR
	     VBO_RESULTAT := UTL_PKB_MESSAGE.LIRE_MESSAGE('FDT.000009', NULL, VVA_TYPE, VVA_MESSAGE);
         RAISE_APPLICATION_ERROR(-20001, VVA_MESSAGE);
      END IF;
      -- VéRIFIER EN MODIFICATION S'IL Y A CHEVAUCHEMENT DE DATE POUR LE MêME INTERVENANT
      SELECT MAX(1) INTO VNU_RETOUR
      FROM FDTT_FONCT_INTERVENANTS INT
      WHERE INT.CO_EMPLOYE_SHQ = :NEW.CO_EMPLOYE_SHQ
	   AND  INT.NO_SEQ_GROUPE  = :NEW.NO_SEQ_GROUPE
       AND :NEW.DT_DEBUT_FONCTION BETWEEN INT.DT_DEBUT_FONCTION
	   AND NVL(INT.DT_FIN_FONCTION, VDA_DT_ACTUELLE + 36500);
      --
      IF VNU_RETOUR = 1 THEN
	     -- L'INTERVENANT EST DéJà ACTIF DANS CE GROUPE POUR CETTE DATE OU PéRIODE.
	     VBO_RESULTAT := UTL_PKB_MESSAGE.LIRE_MESSAGE('FDT.000012', NULL, VVA_TYPE, VVA_MESSAGE);
         RAISE_APPLICATION_ERROR(-20001, VVA_MESSAGE);
      END IF;
   END IF; -- INSERTING
END FDT_TRB_VRFDTE_BIUR;
/

prompt
prompt Creating trigger FDT_TRB_VRFDTES_UTIL_BIUR
prompt ==========================================
prompt
CREATE OR REPLACE TRIGGER "FDT_TRB_VRFDTES_UTIL_BIUR" BEFORE INSERT OR UPDATE
  ON "FDTT_DETAILS_ATT"
 REFERENCING  OLD AS OLD NEW AS NEW
 FOR EACH ROW
DECLARE
  VBO_RESULTAT BOOLEAN;
  VVA_MESSAGE  VARCHAR2(4000);
  VVA_TYPE     VARCHAR2(1);
  VNU_RETOUR   NUMBER(1);
  VDA_DT_ACTUELLE DATE;
  VVA_AN_MOIS_FDT VARCHAR2(6);
  
BEGIN
    VDA_DT_ACTUELLE := UTL_FNB_OBT_DT_PRODC('FDT', 'DA');

    IF :NEW.DT_FIN_ATT < :NEW.DT_DEBUT_ATT THEN
	   -- LA DATE DE FIN DOIT êTRE éGALE OU SUPéRIEURE à LA DATE DéBUT
	   VBO_RESULTAT := UTL_PKB_MESSAGE.LIRE_MESSAGE('FDT.000011', NULL, VVA_TYPE, VVA_MESSAGE);
       RAISE_APPLICATION_ERROR(-20001, VVA_MESSAGE);
    END IF;
    IF INSERTING THEN
	  --
	  SELECT MAX(AN_MOIS_FDT) INTO VVA_AN_MOIS_FDT
      FROM FDTT_FEUILLES_TEMPS
      WHERE IND_SAISIE_AUTORISEE = 'O'
       AND  NO_SEQ_RESSOURCE = :NEW.NO_SEQ_RESSOURCE;
--      AND  CO_EMPLOYE_SHQ =  :NEW.NO_SEQ_RESSOURCE;   -- LV 2021-02-25 :NEW.CO_EMPLOYE_SHQ;
	  --
      IF VVA_AN_MOIS_FDT IS NOT NULL THEN
         IF :NEW.DT_DEBUT_ATT < TO_DATE(VVA_AN_MOIS_FDT||'01','YYYYMMDD') THEN
	        -- LA DATE DE DéBUT ARTT EST PLUS PETITE QUE LA PREMIèRE JOURNéE DE LA FDT EN SAISIE ACTUELLEMENT POUR CET UTILISATEUR
		    -- DE LA FEUILLE DE TEMPS EN SAISIE POUR CET UTILISATEUR
		    --VVA_MESSAGE := 'LA DATE DéBUT DE ARTT DOIT êTRE PLUS GRANDE OU éGALE à LA PREMIèRE JOURNéE DE LA FDT EN SAISIE POUR CET UTILISATEUR';
			VBO_RESULTAT := UTL_PKB_MESSAGE.LIRE_MESSAGE('FDT.000027', NULL, VVA_TYPE, VVA_MESSAGE);
		    RAISE_APPLICATION_ERROR(-20001, VVA_MESSAGE);
	     END IF;
	  ELSE
	     -- AUCUNE FEUILLE DE TEMPS EN SAISIE POUR CET EMPLOYé, IMPOSSIBLE DE CRéER UN AMéNAGEMENT DE TEMPS DE TRAVAIL
		 --VVA_MESSAGE := 'AUCUNE FEUILLE DE TEMPS EN SAISIE POUR CET EMPLOYé, IMPOSSIBLE DE CRéER UN AMéNAGEMENT DE TEMPS DE TRAVAIL';
		 VBO_RESULTAT := UTL_PKB_MESSAGE.LIRE_MESSAGE('FDT.000028', NULL, VVA_TYPE, VVA_MESSAGE);
		 RAISE_APPLICATION_ERROR(-20001, VVA_MESSAGE);
	  END IF;
	  --
	  SELECT MAX(1) INTO VNU_RETOUR
      FROM FDTT_DETAILS_ATT INT
      WHERE INT.NO_SEQ_RESSOURCE = :NEW.NO_SEQ_RESSOURCE   -- LV 2021-02-25 INT.CO_EMPLOYE_SHQ = :NEW.NO_SEQ_RESSOURCE
	   AND :NEW.DT_DEBUT_ATT <= INT.DT_FIN_ATT;
      --
	  IF VNU_RETOUR = 1 THEN
	     -- LA DATE DE DéBUT ARTT DOIT êTRE PLUS GRANDE QUE LA DATE DE FIN DE L'ARTT PRéCéDENTE.
		 --VVA_MESSAGE := 'LA DATE DE DéBUT DE L'ARTT DOIT êTRE PLUS GRANDE QUE LA DATE DE FIN DE L'ARTT PRéCéDENTE';
         VBO_RESULTAT := UTL_PKB_MESSAGE.LIRE_MESSAGE('FDT.000029', NULL, VVA_TYPE, VVA_MESSAGE);
		 RAISE_APPLICATION_ERROR(-20001, VVA_MESSAGE);
      END IF;
      --
      -- VéRIFIER EN MODIFICATION S'IL Y A CHEVAUCHEMENT DE DATE POUR LE MêME AMéNAGEMENT
      SELECT MAX(1) INTO VNU_RETOUR
      FROM FDTT_DETAILS_ATT INT
      WHERE INT.NO_SEQ_RESSOURCE = :NEW.NO_SEQ_RESSOURCE         -- LV 2021-02-25 INT.CO_EMPLOYE_SHQ = :NEW.CO_EMPLOYE_SHQ
       AND :NEW.DT_DEBUT_ATT BETWEEN INT.DT_DEBUT_ATT
	   AND NVL(INT.DT_FIN_ATT, VDA_DT_ACTUELLE + 36500);
       --
       IF VNU_RETOUR = 1 THEN
           VBO_RESULTAT := UTL_PKB_MESSAGE.LIRE_MESSAGE('FDT.000008', NULL, VVA_TYPE, VVA_MESSAGE);
           RAISE_APPLICATION_ERROR(-20001, VVA_MESSAGE);
       END IF;
    END IF; -- INSERTING
END FDT_TRB_VRFDTE_UTIL_BIUR;
/


prompt Done
spool off
set define on
