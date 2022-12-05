create or replace package body fdt_pkb_apx_010206 is
   -- ====================================================================================================
   -- Date        : 2021-11-02
   -- Par         : SHQCGE
   -- Description : Gérer la retour d'un employé
   -- ====================================================================================================
   -- Date        :
   -- Par         :
   -- Description :
   -- ====================================================================================================
   --
   -- Private type declarations
   --
   -- Private constant declarations
   --cdt_da_systeme_fdt date := utl_fnb_obt_dt_prodc(pva_co_systeme => 'FDT', pva_form_date => 'DA');
   vva_message    varchar2(4000);
   --
   -- Private variable declarations
   --
   -- -------------------------------------------------------------------------------------------------
   --                                           logger
   -- -------------------------------------------------------------------------------------------------
   -- Pour voir le résultat de la trace, il faut aller dans plsql_developeur et faire ce select :
   --                               select *
   --                               from   logger_logs_5_min
   --                               order by id desc
   -- -------------------------------------------------------------------------------------------------
--   cva_scope_prefix constant varchar2(31) := lower($$plsql_unit) || '.';
   -- Procédure qui permet de gérer le retour d'un employe
   ----------------------------------------------------------------------
   procedure p_gerer_retour_employe(pnu_no_seq_ressource in fdtt_feuilles_temps.no_seq_ressource%type,
                                    pva_an_mois_fdt      in fdtt_feuilles_temps.an_mois_fdt%type,
                                    vva_transferer_solde in varchar2) is
      --
      vnu_no_seq_feuil_temps fdtt_feuilles_temps.no_seq_feuil_temps%type;
      vnu_fdt_non_vide  number(5);
      vnu_solde_reporte number(5);
      --
      -- Aller chercher la séquence de l'activité férié dans la table activité
      cursor cur_activite_ferie is
         select no_seq_activite
         from fdtt_Activites act
             ,fdtt_categorie_activites cat
         where cat.co_type_categorie  = 'GENRQ'
           and act.no_seq_categ_activ = cat.no_seq_categ_activ
           and act.ACRONYME = '100';
      rec_cur_activite_ferie     cur_activite_ferie%rowtype;
      --
      vnu_co_employe_shq fdtt_ressource.co_employe_shq%type;
      --
      cursor cur_obtenir_co_employe is
         select res.co_employe_shq
         from fdtt_ressource res
         where res.no_seq_ressource = pnu_no_seq_ressource;
      --
   begin
      -- On va chercher la séquence pour l'activité férié dans la table activité
      open cur_obtenir_co_employe;
         fetch cur_obtenir_co_employe into vnu_co_employe_shq;
      close cur_obtenir_co_employe;
      -- On va chercher la séquence pour l'activité férié dans la table activité
      open cur_activite_ferie;
         fetch cur_activite_ferie into rec_cur_activite_ferie;
      close cur_activite_ferie;
      -- On va voir si la personne a une fdt à détruire (cette fdt est créee lors de la transmission de sa dernière fdt).
      select max(fmax.no_seq_feuil_temps) into vnu_no_seq_feuil_temps
      from fdtt_feuilles_temps fmax
      where fmax.no_seq_ressource = pnu_no_seq_ressource;
      --
      select count(dt_temps_jour) into vnu_fdt_non_vide
      from  fdtt_temps_jours tj
      where tj.no_seq_feuil_temps =  vnu_no_seq_feuil_temps
        and (tj.total_temps_min   <> 0 and tj.no_seq_activite is null or
             tj.total_temps_min   <> 0 and tj.no_seq_activite != rec_cur_activite_ferie.no_seq_activite);
      --
      vnu_solde_reporte := 0;
      if vnu_fdt_non_vide = 0 then
         -- La fdt n'a eu aucune saisie par l'employé.
         -- On garde le solde reporté si coché par l'utilisateur
         if vva_transferer_solde = 'O' then
             select fdr.solde_reporte into vnu_solde_reporte
             from fdtt_feuilles_temps fdr
             where no_seq_feuil_temps = vnu_no_seq_feuil_temps;

         end if;
         --
         -- On peut maintenant détruire cette fdt qui ne sert pas
         --
         delete from fdtt_temps_jours
         where no_seq_feuil_temps = vnu_no_seq_feuil_temps;
         --
         delete from fdtt_feuilles_temps
         where no_seq_feuil_temps = vnu_no_seq_feuil_temps;
         --
         FDT_PRB_APX_CREER_FEUILLE_TEMPS
             (vnu_co_employe_shq,
              to_char(add_months(to_date(pva_an_mois_fdt, 'YYYY-MM'), -1), 'YYYYMM'),
              vnu_solde_reporte
             );
       else
          vva_message := utl_pkb_message.fc_obt_message('FDT.000127');
          apex_error.add_error(vva_message,null,apex_error.c_inline_in_notification);
       end if;
  end p_gerer_retour_employe;
  --
end fdt_pkb_apx_010206;
/

