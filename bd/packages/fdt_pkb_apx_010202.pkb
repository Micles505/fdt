create or replace package body fdt_pkb_apx_010202 is
   -- ====================================================================================================
   -- Date        : 2021-11-10
   -- Par         : SHQYMR
   -- Description : Gérer les groupes FDT
   -- ====================================================================================================
   -- Date        :
   -- Par         :
   -- Description :
   -- ====================================================================================================
   --
   -- Private type declarations
   --
   --
   -- Private constant declarations
   --
   --
   -- Private variable declarations
   --
   --
   -- -------------------------------------------------------------------------------------------------
   --                                           logger
   -- -------------------------------------------------------------------------------------------------
   -- Pour voir le résultat de la trace, il faut aller dans plsql_developeur et faire ce select :
   --                               select *
   --                               from   logger_logs_5_min
   --                               order by id desc
   -- -------------------------------------------------------------------------------------------------
   cva_scope_prefix constant varchar2(31) := lower($$plsql_unit) || '.';
   --
   -- -------------------------------------------------------------------------------------------------
   -- Function and procedure implementations
   -- -------------------------------------------------------------------------------------------------
   --
   --
   -- =========================================================================
   -- Valider les dates des interventions détail
   -- =========================================================================
   procedure p_traiter_ressources (pva_liste_empl_grp in varchar2,
                                   pnu_no_seq_groupe  in number) is
    --
    --
      -- -------------------------------------------------------------------------------------------------
      --                                           Variables
      -- -------------------------------------------------------------------------------------------------
    vnu_nbr_enreg  number;
    --
    --
      -- -------------------------------------------------------------------------------------------------
      --                                           Curseurs
      -- -------------------------------------------------------------------------------------------------
    cursor cur_obt_empl_grp is
       select emp.column_value as co_employe_shq
         from   Table ( apex_string.split(pva_liste_empl_grp, ':') ) emp
         where  emp.column_value is not null;
    --
    cursor cur_dt_fin_association_null (pnu_co_employe_shq in number) is
       select count(*)
         from   fdtt_assoc_employes_grp ass_grp
         where  ass_grp.co_employe_shq = pnu_co_employe_shq
         and    ass_grp.dt_fin_association is null;
    --
    --
      -- -------------------------------------------------------------------------------------------------
      --                                           logger
      -- -------------------------------------------------------------------------------------------------
      vva_scope logger_logs.scope%type := cva_scope_prefix || 'p_traiter_ressources';
      vta_params logger.tab_param;
    --
   begin
    --
      -- -------------------------------------------------------------------------------------------------
      --                                           logger
      -- -------------------------------------------------------------------------------------------------
      logger.append_param(p_params => vta_params,
                        p_name   => 'Début',
                          p_val    => 'p_traiter_ressources');
    --
      -------------------------------------------------------------------------
    -- Mettre une date de fin aux membres du groupe actuel qui ne figure
    -- plus dans le groupe actuel remanier
      -------------------------------------------------------------------------
    update fdtt_assoc_employes_grp
     set    dt_fin_association = utl_fnb_obt_dt_prodc ('FDT')
     where  co_employe_shq not in (select emp.column_value as co_employe_shq
                                       from   Table ( apex_string.split(pva_liste_empl_grp, ':') ) emp
                                       where  emp.column_value is not null)
     and    no_seq_groupe = pnu_no_seq_groupe
     and    dt_fin_association is null;
    --
      -------------------------------------------------------------------------
    -- Mettre une date de fin aux membres qui sont dans un autre groupe et
    -- figure dans le groupe actuel remanier
      -------------------------------------------------------------------------
    update fdtt_assoc_employes_grp
     set    dt_fin_association = utl_fnb_obt_dt_prodc ('FDT') - 1
     where  co_employe_shq in (select emp.column_value as co_employe_shq
                                   from   Table ( apex_string.split(pva_liste_empl_grp, ':') ) emp
                                   where  emp.column_value is not null)
     and    no_seq_groupe <> pnu_no_seq_groupe
     and    dt_fin_association is null;
    --
      -------------------------------------------------------------------------
    -- Supprimer les membres inscrits avec le problème de date
    --
    -- *** Lorsqu'une personne change de groupe deux fois dans la même
    --     journée, la date de début risque d'être supérieure à la date de
    --     fin que l'on veut mettre (À cause de la date + 1 que l'on met
    --     dans la date de début d'association lorsque l'on inscrit un membre
    --     à un groupe).  Dans ce cas on doit supprimer l'enregistrement et
    --     non lui mettre une date de fin qui serait inférieure à la date de
    --     début
    --
    --     Note : ce cas ne devrait plus arriver car on met maintenant la
    --            de fin  à '-1' à la place de mettre la date de début à
    --            '+1'.  Mais on ne risque rien à laisser le delete.
      -------------------------------------------------------------------------
    delete fdtt_assoc_employes_grp
    where  dt_debut_association > dt_fin_association;
    --
      -------------------------------------------------------------------------
    -- Insérer les nouvelles ressources au groupe en cours
    --
    -- *** La personne devient véritablement dans le groupe le lendemain
      -------------------------------------------------------------------------
    for emp in cur_obt_empl_grp loop
       --
     -- Inscrire que les nouveau membres dans le groupe
     --
     -- *** Le membre n'existe pas déjà avec une date de fin à null
     --
     open  cur_dt_fin_association_null (emp.co_employe_shq);
     fetch cur_dt_fin_association_null into vnu_nbr_enreg;
     close cur_dt_fin_association_null;
     --
     if vnu_nbr_enreg = 0 then
          insert into fdtt_assoc_employes_grp (no_seq_asso_empl_grp,
                                                no_seq_groupe,
                                                co_employe_shq,
                                                dt_debut_association,
                                                dt_fin_association,
                                                co_user_cre_enreg,
                                                co_user_maj_enreg,
                                                dh_cre_enreg,
                                                dh_maj_enreg)
                   values (null,
                     pnu_no_seq_groupe,
                   emp.co_employe_shq,
                 utl_fnb_obt_dt_prodc ('FDT'),
                 null,
                       null,
                       null,
                       null,
                       null);
     end if;
      end loop;
    --
      -- -------------------------------------------------------------------------------------------------
      --                                           logger
      -- -------------------------------------------------------------------------------------------------
      logger.log_info(p_text   => 'Fin p_traiter_ressources ',
                    p_scope  => vva_scope,
                      p_params => vta_params);
      --
    exception when others then
                   apex_debug.info ('Exception p_traiter_ressources %s', sqlerrm);
           raise;
    --
   end p_traiter_ressources;
   --
   --
   -- =========================================================================
   -- Valider les dates des interventions détail
   -- =========================================================================
   function f_obt_liste_emp_grp (pnu_no_seq_groupe in fdtt_assoc_employes_grp.no_seq_groupe%type) return varchar2 is
      --
    vva_liste_emp_grp   varchar2(4000);
    --
    --
      -- -------------------------------------------------------------------------------------------------
      --                                           Curseurs
      -- -------------------------------------------------------------------------------------------------
    cursor cur_obt_empl_grp is
       select listagg (distinct emp_grp.co_employe_shq, ':') within group (order by emp_grp.co_employe_shq)
         from   fdtt_assoc_employes_grp emp_grp
         where  emp_grp.no_seq_groupe = pnu_no_seq_groupe
     and    (emp_grp.dt_fin_association is null or
             emp_grp.dt_fin_association >= sysdate);
    --
    --
      -- -------------------------------------------------------------------------------------------------
      --                                           logger
      -- -------------------------------------------------------------------------------------------------
      vva_scope logger_logs.scope%type := cva_scope_prefix || 'f_obt_liste_emp_grp';
      vta_params logger.tab_param;
    --
   begin
    --
      -- -------------------------------------------------------------------------------------------------
      --                                           logger
      -- -------------------------------------------------------------------------------------------------
      logger.append_param(p_params => vta_params,
                        p_name   => 'Début',
                          p_val    => 'f_obt_liste_emp_grp');
    --
      -------------------------------------------------------------------------
    -- Obtenir la liste des employés du groupe en cours
    --
    --   *** Va servir à remplir la navette employés du groupe
      -------------------------------------------------------------------------
    open  cur_obt_empl_grp;
    fetch cur_obt_empl_grp into vva_liste_emp_grp;
    close cur_obt_empl_grp;
    --
    --
      -- -------------------------------------------------------------------------------------------------
      --                                           logger
      -- -------------------------------------------------------------------------------------------------
      logger.log_info(p_text   => 'Fin f_obt_liste_emp_grp ',
                    p_scope  => vva_scope,
                      p_params => vta_params);
      --
    return vva_liste_emp_grp;
    --
    exception when others then
                   apex_debug.info ('Exception f_obt_liste_emp_grp %s', sqlerrm);
           raise;
    --
   end f_obt_liste_emp_grp;
   --
   --
   -- =========================================================================
   -- Valider les dates des interventions détail
   -- =========================================================================
   function f_obt_liste_unite_organ (pnu_no_seq_groupe in fdtt_assoc_employes_grp.no_seq_groupe%type) return varchar2 is
      --
    vva_liste_unite_organ   varchar2(4000);
    --
    --
      -- -------------------------------------------------------------------------------------------------
      --                                           Curseurs
      -- -------------------------------------------------------------------------------------------------
    cursor cur_obt_empl_grp is
       select listagg (distinct resultat.co_unite_organ, ':') within group (order by resultat.co_unite_organ)
         from   (select emp.co_unite_organ
                 from   fdtt_assoc_employes_grp            emp_grp
                        inner join fdtt_groupes            grp     on emp_grp.no_seq_groupe  = grp.no_seq_groupe
                        inner join bust_employe            emp     on emp_grp.co_employe_shq = emp.co_employe_shq
                 where  emp_grp.no_seq_groupe = pnu_no_seq_groupe
                 union
                 select emp.co_unite_organ
                 from   fdtt_fonct_intervenants interv
                        inner join fdtt_groupes            grp     on interv.no_seq_groupe  = grp.no_seq_groupe
                        inner join bust_employe            emp     on interv.co_employe_shq = emp.co_employe_shq
                 where  interv.no_seq_groupe = pnu_no_seq_groupe) resultat
       where   length (resultat.co_unite_organ) = 4;
    --
    --
      -- -------------------------------------------------------------------------------------------------
      --                                           logger
      -- -------------------------------------------------------------------------------------------------
      vva_scope logger_logs.scope%type := cva_scope_prefix || 'f_obt_liste_unite_organ';
      vta_params logger.tab_param;
    --
   begin
    --
      -- -------------------------------------------------------------------------------------------------
      --                                           logger
      -- -------------------------------------------------------------------------------------------------
      logger.append_param(p_params => vta_params,
                        p_name   => 'Début',
                          p_val    => 'f_obt_liste_unite_organ');
    --
      -------------------------------------------------------------------------
    -- Obtenir la liste des employés du groupe en cours
    --
    --   *** Va servir à remplir la navette employés du groupe
      -------------------------------------------------------------------------
    open  cur_obt_empl_grp;
    fetch cur_obt_empl_grp into vva_liste_unite_organ;
    close cur_obt_empl_grp;
    --
    --
      -- -------------------------------------------------------------------------------------------------
      --                                           logger
      -- -------------------------------------------------------------------------------------------------
      logger.log_info(p_text   => 'Fin f_obt_liste_unite_organ ',
                    p_scope  => vva_scope,
                      p_params => vta_params);
      --
    return vva_liste_unite_organ;
    --
    exception when others then
                   apex_debug.info ('Exception f_obt_liste_unite_organ %s', sqlerrm);
           raise;
    --
   end f_obt_liste_unite_organ;
   --
end fdt_pkb_apx_010202;
/

