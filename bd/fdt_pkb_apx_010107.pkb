create or replace package body fdt_pkb_apx_010107 is
  -- ====================================================================================================
  -- Date        : 2022-05-10
  -- Par         : SHQYMR
  -- Description : Saisie des efforts (Sans feuille de temps)
  -- ====================================================================================================
  -- Date        :
  -- Par         :
  -- Description :
  -- ====================================================================================================
  --
  -- Private type declarations
  --
  -- Private constant declarations
  --
  -- Private variable declarations
  --
  cva_update_row_status constant varchar2(3) := 'U';
  cva_create_row_status constant varchar2(3) := 'C';
  --   cva_delete_row_status constant varchar2(3) := 'D';
  --
  cva_nom_collection constant varchar2(30) := 'COL_010107';
  --
  --
  --Variables pour utl_pkb_apx_message.f_obt_message
  vva_message     varchar2(4000) := null;
  vva_typ_message utlt_message_trait.typ_message%type := null;
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
  ----------------------------------------------------------------------------------------------
  -- Permet de faire la maj ou l'insertion dans FDTT_TEMPS_INTERVENTION
  ----------------------------------------------------------------------------------------------
  procedure p_gerer_temps_intervention(pva_apex_row_status       in varchar2,
                                       pnu_no_seq_temps_intrv    in fdtt_temps_intervention.no_seq_temps_intrv%type,
                                       pnu_no_seq_feuil_temps    in fdtt_temps_intervention.no_seq_feuil_temps%type,
                                       pnu_no_seq_aact_intrv_det in fdtt_temps_intervention.no_seq_aact_intrv_det%type,
                                       pva_an_mois_fdt           in fdtt_temps_intervention.an_mois_fdt%type,
                                       pva_periode               in varchar2,
                                       pva_nbr_minute_trav_aff   in varchar2,
                                       pva_commentaire           in fdtt_temps_intervention.commentaire%type,
                                       pnu_no_seq_specialite     in fdtt_temps_intervention.no_seq_specialite%type) is
    -- déclaration de variables
    vnu_nb_minute_trav number(4);
  vdt_debut_periode  date;
  vdt_fin_periode    date;
  --
  begin
    --
    vnu_nb_minute_trav := utl_fnb_cnv_minute(pva_nbr_minute_trav_aff);
  --
  vdt_debut_periode := to_date (substr (pva_periode, 1, 10),  'YYYY-MM-DD');
  vdt_fin_periode   := to_date (substr (pva_periode, 15, 10), 'YYYY-MM-DD');
    --
    if pva_apex_row_status = 'C' then
      -- On est en création
      insert into fdtt_temps_intervention
        (no_seq_feuil_temps,
     no_seq_ressource,
         no_seq_aact_intrv_det,
         an_mois_fdt,
         debut_periode,
         fin_periode,
         nbr_minute_trav,
         commentaire,
         no_seq_specialite)
      VALUES
        (pnu_no_seq_feuil_temps,
     null,
         pnu_no_seq_aact_intrv_det,
         pva_an_mois_fdt,
         vdt_debut_periode,
         vdt_fin_periode,
         vnu_nb_minute_trav,
         pva_commentaire,
         pnu_no_seq_specialite);
    else
      if pva_apex_row_status = 'U' then
        -- On est en maj
        update fdtt_temps_intervention
           set nbr_minute_trav       = vnu_nb_minute_trav,
               commentaire           = pva_commentaire,
               no_seq_specialite     = pnu_no_seq_specialite,
               no_seq_aact_intrv_det = pnu_no_seq_aact_intrv_det
         where no_seq_temps_intrv = pnu_no_seq_temps_intrv;
      else
        -- on est en destruction
        delete from fdtt_temps_intervention
         where no_seq_temps_intrv = pnu_no_seq_temps_intrv;
      end if;
    end if;
  end p_gerer_temps_intervention;
  -- ---------------------------------------------------------
  -- Supprimer la collection
  -- ---------------------------------------------------------
  procedure p_supprimer_collection is
    pragma autonomous_transaction;
  begin
    if apex_collection.collection_exists(cva_nom_collection) Then
      apex_collection.delete_collection(cva_nom_collection);
    end if;
    --
    commit;
  end p_supprimer_collection;
  -- ---------------------------------------------------------
  -- Remplir la collection
  -- ---------------------------------------------------------
  procedure p_ajouter_enreg_collection(pre_enreg               in fdtt_temps_intervention%rowtype,
                                       pva_nbr_minute_trav_aff in varchar2,
                                       pva_apex$row_status     in varchar2) is
    pragma autonomous_transaction;
    vnu_nb_minute_trav number(4);
  begin
    if not apex_collection.collection_exists(cva_nom_collection) Then
      apex_collection.create_collection(cva_nom_collection);
    end if;
    -- On convertit l'heure saisie en minutes
    vnu_nb_minute_trav := utl_fnb_cnv_minute(pva_nbr_minute_trav_aff);
    --
    apex_collection.add_member(p_collection_name => cva_nom_collection,
                               p_n001            => pre_enreg.NO_SEQ_TEMPS_INTRV,
                               p_n002            => pre_enreg.NO_SEQ_FEUIL_TEMPS,
                               p_n003            => pre_enreg.NO_SEQ_AACT_INTRV_DET,
                               p_n004            => vnu_nb_minute_trav,
                               p_d001            => pre_enreg.DEBUT_PERIODE,
                               p_d002            => pre_enreg.FIN_PERIODE,
                               p_c010            => pva_apex$row_status);
    --
    commit;
  end p_ajouter_enreg_collection;
  -- ---------------------------------------------------------
  -- Valider la cohérence
  -- ---------------------------------------------------------
  procedure p_valider_coherence(pnu_no_seq_feuil_temps in fdtt_temps_intervention.no_seq_feuil_temps%type,
                                pdt_debut_periode      in date,
                pdt_fin_periode        in date) is
    --
    --
    -- Variables utilisées pour le logger
    --
    vta_params logger.tab_param;
    --
    -- Avoir une image complète des données BD + Apex
    --
    cursor cur_test is
      select n001 as no_seq_temps_intrv,
             n002 as no_seq_feuil_temps,
             n003 as no_seq_aact_intrv_det,
             n004 as nbr_minute_trav,
             d001 as debut_periode,
             d002 as fin_periode,
             c010 as apex_row_status
        from apex_collections
       where collection_name = cva_nom_collection
         and c010 in (cva_create_row_status, cva_update_row_status);
    rec_test cur_test%rowtype;
    --
    cursor cur_test_bd is
      select tinter.no_seq_temps_intrv,
             tinter.no_seq_feuil_temps,
             tinter.no_seq_aact_intrv_det,
             tinter.nbr_minute_trav,
             tinter.debut_periode,
             tinter.fin_periode,
             cva_update_row_status as apex_row_status
        from fdtt_temps_intervention tinter
       where tinter.no_seq_temps_intrv not in
             (select n001 as no_seq_temps_intrv
                from apex_collections
               where collection_name = cva_nom_collection
                 and c010 in (cva_update_row_status))
         and tinter.no_seq_feuil_temps = pnu_no_seq_feuil_temps
         and debut_periode = pdt_debut_periode
         and fin_periode   = pdt_fin_periode;
    rec_test_bd cur_test_bd%rowtype;

    cursor cur_tous_temps_intervention is
    --
    -- On prend les insertions et modifications APEX
    --
      select n001 as no_seq_temps_intrv,
             n002 as no_seq_feuil_temps,
             n003 as no_seq_aact_intrv_det,
             n004 as nbr_minute_trav,
             d001 as debut_periode,
             d002 as fin_periode,
             c010 as apex_row_status
        from apex_collections
       where collection_name = cva_nom_collection
         and c010 in (cva_create_row_status, cva_update_row_status)
      union
      select tinter.no_seq_temps_intrv,
             tinter.no_seq_feuil_temps,
             tinter.no_seq_aact_intrv_det,
             tinter.nbr_minute_trav,
             tinter.debut_periode,
             tinter.fin_periode,
             cva_update_row_status as apex_row_status
        from fdtt_temps_intervention tinter
       where tinter.no_seq_temps_intrv not in
             (select n001 as no_seq_temps_intrv
                from apex_collections
               where collection_name = cva_nom_collection
                 and c010 in (cva_update_row_status))
         and tinter.no_seq_feuil_temps = pnu_no_seq_feuil_temps
         and debut_periode = pdt_debut_periode
         and fin_periode   = pdt_fin_periode;
    --
    --
    --
    -- Valider qu'il n'y a pas deux interventions pareils pour cette période
    --
    procedure p_valider_doublons_intervention is
      --
      cva_code_message utlt_message_trait.co_message%type := '000146';
      --
      cursor cur_valider_doublons_intervention is
        select count(tab.no_seq_aact_intrv_det) as nbr_intervention,
           tab.no_seq_aact_intrv_det,
         tab.debut_periode,
         tab.fin_periode
          from table(vta_rec_temps_intervention) tab
         group by tab.no_seq_aact_intrv_det,
              tab.debut_periode,
                  tab.fin_periode;
      rec_valider_doublons_intervention cur_valider_doublons_intervention%rowtype;
      --
      cursor cur_obtenir_description is
        select inter.description as description
          from fdtt_ass_act_intrv_det inter
         where inter.no_seq_aact_intrv_det = rec_valider_doublons_intervention.no_seq_aact_intrv_det;
      rec_obtenir_description cur_obtenir_description%rowtype;
      --
    begin
      --
      for rec_valider_doublons_intervention in cur_valider_doublons_intervention loop
        --
        if rec_valider_doublons_intervention.nbr_intervention > 1 then
          -- On va chercher la description de l'intervention en double
          open cur_obtenir_description;
          fetch cur_obtenir_description
            into rec_obtenir_description;
          close cur_obtenir_description;
          --
          vva_message := utl_pkb_apx_message.f_obt_message(pva_code_systeme => fdt_pkb_apx_config.f_obtenir_code_systeme_fdt,
                                                           pva_code_messa   => cva_code_message,
                                                           pva_param_1      => rec_obtenir_description.description,
                                                           pva_type_messa   => vva_typ_message);
          --
          apex_error.add_error(p_message          => vva_message,
                               p_display_location => apex_error.c_inline_in_notification);
        end if;
      end loop;
    end p_valider_doublons_intervention;
    --
  begin
    --
    logger.append_param(p_params => vta_params,
                        p_name   => '======================================================Paramètres fonction',
                        p_val    => ' ');
    logger.append_param(p_params => vta_params,
                        p_name   => 'pnu_no_seq_feuil_temps',
                        p_val    => pnu_no_seq_feuil_temps);
    logger.append_param(p_params => vta_params, p_name => 'pdt_debut_periode', p_val => pdt_debut_periode);
    logger.append_param(p_params => vta_params, p_name => 'pdt_fin_periode', p_val => pdt_fin_periode);
    --
    if not apex_collection.collection_exists(cva_nom_collection) Then
      --
      -- S'il y a eu plusieurs lignes modifiées dans la IG (création, modification, supression), cette fonction de cohérence est appelée autant de fois.
      -- Les validations de cohérence ont besoin d'être faites seulement une fois, donc pour les appels de cette fonction 2+ on ne les refait pas.
      --
      logger.append_param(p_params => vta_params,
                          p_name   => '======================================================Informations',
                          p_val    => ' ');
      logger.append_param(p_params => vta_params,
                          p_name   => 'Collection ' || cva_nom_collection ||
                                      ' vide - Les validations ont déjà été effectuées, on ne les refait pas.',
                          p_val    => ' ');
    else
      --
      --
      -- Récupération des données de la table fdtt_ass_typ_intrv_qualf
      --
      open cur_tous_temps_intervention;
      fetch cur_tous_temps_intervention bulk collect
        into vta_rec_temps_intervention;
      close cur_tous_temps_intervention;
      --
      for rec_temps_intervention in cur_tous_temps_intervention loop
        logger.append_param(p_params => vta_params,
                            p_name   => '======================================================Enreg',
                            p_val    => ' ');
        logger.append_param(p_params => vta_params,
                            p_name   => 'NO_SEQ_TEMPS_INTRV',
                            p_val    => rec_temps_intervention.NO_SEQ_TEMPS_INTRV);
        logger.append_param(p_params => vta_params,
                            p_name   => 'NO_SEQ_FEUIL_TEMPS',
                            p_val    => rec_temps_intervention.NO_SEQ_FEUIL_TEMPS);
        logger.append_param(p_params => vta_params,
                            p_name   => 'nbr_minute_trav',
                            p_val    => rec_temps_intervention.nbr_minute_trav);
        logger.append_param(p_params => vta_params,
                            p_name   => 'Début période',
                            p_val    => to_char(rec_temps_intervention.DEBUT_PERIODE, 'yyyy-mm-dd'));
        logger.append_param(p_params => vta_params,
                            p_name   => 'Date fin',
                            p_val    => to_char(rec_temps_intervention.FIN_PERIODE, 'yyyy-mm-dd'));
        logger.append_param(p_params => vta_params,
                            p_name   => 'apex_row_status',
                            p_val    => rec_temps_intervention.apex_row_status);
      end loop;
      --
      open cur_test;
      fetch cur_test
        into rec_test;

      WHILE (cur_test%FOUND) LOOP
        --
        FETCH cur_test
          INTO rec_test;
      END LOOP;
      close cur_test;
      --
      open cur_test_bd;
      fetch cur_test_bd
        into rec_test_bd;
      --
      WHILE (cur_test_bd%FOUND) LOOP
        --
        FETCH cur_test_bd
          INTO rec_test_bd;
      END LOOP;
      close cur_test_bd;

      --
      p_supprimer_collection;
      --
      --if vta_rec_temps_intervention.count > 1 Then
      p_valider_doublons_intervention;
      --end if;
    end if;
    --
    logger.log_error(p_text   => cva_scope_prefix || 'p_valider_coherence',
                     p_scope  => cva_scope_prefix || 'p_valider_coherence',
                     p_params => vta_params);
  end p_valider_coherence;
  -----------------------------------------------------------------------------------------------------------
  -- Permet de savoir si l'activite en est une générique.  Dans ce cas, la ligne est non modifiable.
  -----------------------------------------------------------------------------------------------------------
  function f_est_acti_generique_non_accessible(pnu_no_seq_aact_intrv_det in fdtt_temps_intervention.no_seq_aact_intrv_det%type)
    return varchar2 is
    --
    vva_type_activite_generique varchar2(1);
    --
    cursor cur_obt_activite_temps_avant is
      select acti.no_seq_activite as no_seq_activite
        from fdtt_temps_intervention  tinter,
             fdtt_ass_act_intrv_det   asso_inter,
             fdtt_activites           acti,
             fdtt_categorie_activites cat
       where tinter.no_seq_aact_intrv_det = pnu_no_seq_aact_intrv_det
         and asso_inter.no_seq_aact_intrv_det = tinter.no_seq_aact_intrv_det
         and acti.no_seq_activite = asso_inter.no_seq_activite_decoupage
         and cat.no_seq_categ_activ = acti.no_seq_categ_activ
         and cat.co_type_categorie = 'GENRQ';
    rec_obt_activite_temps_avant cur_obt_activite_temps_avant%rowtype;
    --
  begin
    open cur_obt_activite_temps_avant;
    fetch cur_obt_activite_temps_avant
      into rec_obt_activite_temps_avant;
    close cur_obt_activite_temps_avant;
    --
    if rec_obt_activite_temps_avant.no_seq_activite is null then
      vva_type_activite_generique := 'N';
    else
      vva_type_activite_generique := 'O';
    end if;
    --
    return vva_type_activite_generique;
    --
  end f_est_acti_generique_non_accessible;
  ------------------------------------------------------------------------------------------------------------
  -- Permet d'obtenir les records pour la lov des interventions dans la liste des interventions.
  ------------------------------------------------------------------------------------------------------------
  function f_obtenir_items_lov_intervention(pnu_no_seq_ressource         in fdtt_ressource.no_seq_ressource%type,
                                            pdt_date_debut_periode       in date,
                                            pdt_date_fin_periode         in date,
                                            pnu_no_seq_activite_generaux in fdtt_activites.no_seq_activite%type,
                                            pnu_no_seq_temps_interv      in fdtt_temps_intervention.no_seq_temps_intrv%type)
    return tab_pipe_item_lov_intervention
    pipelined is
    -- Déclaration des variables
    cursor cur_obtenir_ressource_intervention is
      with intervention as (select adet.no_seq_aact_intrv_det,
                                   adet.description,
                                   adet.no_seq_intrv_detail,
                                   t1.nombre_intervention_asso,
                                   adet.no_seq_activite_decoupage
                            from   fdtt_ass_act_intrv_det              adet
                                   inner join fdtt_activites           acti  on  acti.no_seq_activite = adet.no_seq_activite_decoupage
                                   inner join fdtt_categorie_activites cat   on  cat.no_seq_categ_activ = acti.no_seq_categ_activ
                                                                             and cat.co_type_categorie <> 'GENRQ'
                                   inner join fdtt_intervention_detail inter on  inter.no_seq_intrv_detail = adet.no_seq_intrv_detail
                                                                             and (inter.dt_deb_reelle < pdt_date_debut_periode or
                                                                                  inter.dt_deb_reelle between pdt_date_debut_periode and pdt_date_fin_periode)
                                                                             and (inter.dt_fin_reelle is null or inter.dt_fin_reelle > pdt_date_debut_periode)
                                                                             and inter.indic_visibilite_fdt = 'O'
                                   inner join (select assinter.no_seq_intrv_detail,
                                                      count(*) as nombre_intervention_asso
                                               from   fdtt_ass_act_intrv_det assinter
                                               group by assinter.no_seq_intrv_detail) t1 on adet.no_seq_intrv_detail = t1.no_seq_intrv_detail)
      select inter.description as d,
             inter.no_seq_aact_intrv_det as r
      from   fdtt_ass_intrvd_ressr   res
             inner join intervention inter on res.no_seq_intrv_detail = inter.no_seq_intrv_detail
--                                           and inter.nombre_intervention_asso = 1
      where  res.no_seq_ressource = pnu_no_seq_ressource
      and    (res.dt_debut        < pdt_date_debut_periode or
              res.dt_debut between pdt_date_debut_periode and pdt_date_fin_periode)
      and    (res.dt_fin is null or res.dt_fin > pdt_date_debut_periode)
      --
--      union all
      --
--      select inter.description as d,
--             inter.no_seq_aact_intrv_det as r
--      from   fdtt_ass_intrvd_ressr   res
--             inner join intervention inter on  res.no_seq_intrv_detail = inter.no_seq_intrv_detail
--                                           and inter.nombre_intervention_asso  > 1
--                                           and inter.no_seq_activite_decoupage <> pnu_no_seq_activite_generaux
--      where  res.no_seq_ressource = pnu_no_seq_ressource
--      and    (res.dt_debut        < pdt_date_debut_periode or
--              res.dt_debut between pdt_date_debut_periode and pdt_date_fin_periode)
--      and    (res.dt_fin is null or res.dt_fin > pdt_date_debut_periode)
      --
      order by 1;
    --
    --
    vta_pipe_item_lov_intervention fdt_pkb_apx_010107.tab_pipe_item_lov_intervention;
    --
    -- logger
    --
    vva_scope  logger_logs.scope%type := cva_scope_prefix || 'f_obtenir_items_lov_intervention';
    vta_params logger.tab_param;
    --
    procedure p_log_parametre is
    begin
      --
      logger.append_param(p_params => vta_params,
                          p_name   => 'pnu_no_seq_ressource',
                          p_val    => pnu_no_seq_ressource);
      logger.append_param(p_params => vta_params,
                          p_name   => 'pdt_date_debut_periode',
                          p_val    => pdt_date_debut_periode);
      logger.append_param(p_params => vta_params,
                          p_name   => 'pdt_date_fin_periode',
                          p_val    => pdt_date_fin_periode);
      logger.append_param(p_params => vta_params,
                          p_name   => 'pnu_no_seq_activite_generaux',
                          p_val    => pnu_no_seq_activite_generaux);
      logger.append_param(p_params => vta_params,
                          p_name   => 'pnu_no_seq_temps_interv',
                          p_val    => pnu_no_seq_temps_interv);
      logger.log_info(p_params => vta_params, p_scope => vva_scope, p_text => 'log paramametre');
    end p_log_parametre;
    --
  begin
    --
    p_log_parametre;
    --
    open cur_obtenir_ressource_intervention;
    fetch cur_obtenir_ressource_intervention bulk collect
      into vta_pipe_item_lov_intervention;
    close cur_obtenir_ressource_intervention;
    --
    <<retourner_interventions>>
    if vta_pipe_item_lov_intervention.count > 0 Then
      for indx in vta_pipe_item_lov_intervention.first .. vta_pipe_item_lov_intervention.last loop
        --
        pipe row(vta_pipe_item_lov_intervention(indx));
        --
      end loop retourner_interventions;
    end if;
  end f_obtenir_items_lov_intervention;
  -- ---------------------------------------------------------
  -- Sélectionner la spécialité d'une ressource
  -- ---------------------------------------------------------
  function f_obt_seq_feuil_temps (pnu_no_seq_ressource in fdtt_ressource.no_seq_ressource%type,
                                  pva_an_mois_fdt      in fdtt_temps_intervention.an_mois_fdt%type) return number is
      --
    vnu_no_seq_feuil_temps  number;
    vva_last_day            varchar2(2);
    vdt_debut_periode       date;
    vdt_fin_periode         date;
    --
    cursor cur_obt_last_day is
       select to_char (last_day (to_date (pva_an_mois_fdt, 'YYYYMM')), 'DD')
         from dual;
    --
    cursor cur_obt_seq_feuil_temps (pdt_debut_periode in date,
                                    pdt_fin_periode   in date) is
       select tint.no_seq_feuil_temps
         from   fdtt_temps_intervention        tint
                inner join fdtt_feuilles_temps fdt  on tint.no_seq_feuil_temps = fdt.no_seq_feuil_temps
                inner join fdtt_ressource      ress on fdt.no_seq_ressource    = ress.no_seq_ressource
         where  ress.no_seq_ressource = pnu_no_seq_ressource
         and    tint.debut_periode >= pdt_debut_periode
         and    tint.fin_periode   <= pdt_fin_periode;
    --
    --
      -- -------------------------------------------------------------------------------------------------
      --                                           logger
      -- -------------------------------------------------------------------------------------------------
      vva_scope logger_logs.scope%type := cva_scope_prefix || 'f_obt_seq_feuil_temps';
      vta_params logger.tab_param;
    --
   begin
    --
      -- -------------------------------------------------------------------------------------------------
      --                                           logger
      -- -------------------------------------------------------------------------------------------------
      logger.append_param(p_params => vta_params,
                        p_name   => 'Début',
                          p_val    => 'f_obt_seq_feuil_temps');
      logger.append_param(p_params => vta_params,
                        p_name   => 'pnu_no_seq_ressource ',
                          p_val    => pnu_no_seq_ressource);
    --
      -- -------------------------------------------------------------------------------------------------
      -- Obtenir la spécialité de la ressource
      -- -------------------------------------------------------------------------------------------------
    --
    open  cur_obt_last_day;
    fetch cur_obt_last_day into vva_last_day;
    close cur_obt_last_day;
    --
    vdt_debut_periode := to_date (substr (pva_an_mois_fdt, 1, 6) || '01',         'YYYYMMDD');
    vdt_fin_periode   := to_date (substr (pva_an_mois_fdt, 1, 6) || vva_last_day, 'YYYYMMDD');
    --
    open  cur_obt_seq_feuil_temps (vdt_debut_periode,
                                   vdt_fin_periode);
    fetch cur_obt_seq_feuil_temps into vnu_no_seq_feuil_temps;
    close cur_obt_seq_feuil_temps;
      logger.append_param(p_params => vta_params,
                        p_name   => 'vnu_no_seq_feuil_temps ',
                          p_val    => vnu_no_seq_feuil_temps);
    --
      --
      -- -------------------------------------------------------------------------------------------------
      --                                           logger
      -- -------------------------------------------------------------------------------------------------
      logger.log_info(p_text   => 'Fin f_obt_seq_feuil_temps ',
                    p_scope  => vva_scope,
                      p_params => vta_params);
    --
    return vnu_no_seq_feuil_temps;
      --
    exception when others then
                   apex_debug.info ('Exception f_obt_seq_feuil_temps %s', sqlerrm);
           raise;
    --
  end f_obt_seq_feuil_temps;
  -- ---------------------------------------------------------
  -- Sélectionner la spécialité d'une ressource
  -- ---------------------------------------------------------
  function f_obt_specialite (pnu_no_seq_ressource in fdtt_ressource.no_seq_ressource%type) return number is
      --
    vnu_no_seq_specialite  number;
    --
    cursor cur_obt_specialite is
       select info.no_seq_specialite
         from   fdtt_ressource_info_suppl info
         where  info.no_seq_ressource   = pnu_no_seq_ressource
         and    info.dt_debut <= sysdate
         and    (info.dt_fin is null or info.dt_fin >= sysdate)
         group by info.no_seq_specialite;
    --
    --
      -- -------------------------------------------------------------------------------------------------
      --                                           logger
      -- -------------------------------------------------------------------------------------------------
      vva_scope logger_logs.scope%type := cva_scope_prefix || 'f_obt_specialite';
      vta_params logger.tab_param;
    --
   begin
    --
      -- -------------------------------------------------------------------------------------------------
      --                                           logger
      -- -------------------------------------------------------------------------------------------------
      logger.append_param(p_params => vta_params,
                        p_name   => 'Début',
                          p_val    => 'f_obt_specialite');
      logger.append_param(p_params => vta_params,
                        p_name   => 'pnu_no_seq_ressource ',
                          p_val    => pnu_no_seq_ressource);
    --
      -- -------------------------------------------------------------------------------------------------
      -- Obtenir la spécialité de la ressource
      -- -------------------------------------------------------------------------------------------------
    open  cur_obt_specialite;
    fetch cur_obt_specialite into vnu_no_seq_specialite;
    close cur_obt_specialite;
      logger.append_param(p_params => vta_params,
                        p_name   => 'vnu_no_seq_specialite ',
                          p_val    => vnu_no_seq_specialite);
    --
      --
      -- -------------------------------------------------------------------------------------------------
      --                                           logger
      -- -------------------------------------------------------------------------------------------------
      logger.log_info(p_text   => 'Fin f_obt_specialite ',
                    p_scope  => vva_scope,
                      p_params => vta_params);
    --
    return vnu_no_seq_specialite;
      --
    exception when others then
                   apex_debug.info ('Exception f_obt_specialite %s', sqlerrm);
           raise;
    --
  end f_obt_specialite;
  -- ---------------------------------------------------------
  -- Vérifier l'accès à ce traitement
  -- ---------------------------------------------------------
  function f_acces_traitement (pva_co_utilisateur in varchar2) return boolean is
      --
    vva_acces_trait      varchar2(10);
    vbo_valeur_retourne  boolean;
    --
    cursor cur_verifier_acces is
       select 'O'
         from   bust_utilisateur uti
         where  uti.co_utilisateur = pva_co_utilisateur
         and    (bus_fnb_verif_role_2 ('FDT', uti.co_utilisateur, 'PILOTE_INTERVENTION') = 1 or
                 bus_fnb_verif_role_2 ('FDT', uti.co_utilisateur, 'EMPLOYE') = 0);
    --
      -- -------------------------------------------------------------------------------------------------
      --                                           logger
      -- -------------------------------------------------------------------------------------------------
      vva_scope logger_logs.scope%type := cva_scope_prefix || 'f_acces_traitement';
      vta_params logger.tab_param;
    --
   begin
    --
      -- -------------------------------------------------------------------------------------------------
      --                                           logger
      -- -------------------------------------------------------------------------------------------------
      logger.append_param(p_params => vta_params,
                        p_name   => 'Début',
                          p_val    => 'f_acces_traitement');
    --
      -- -------------------------------------------------------------------------------------------------
      -- Vérifier si la ressource en cours doit avoir accès à ce traitement
      -- -------------------------------------------------------------------------------------------------
    vva_acces_trait := null;
    --
    open  cur_verifier_acces;
    fetch cur_verifier_acces into vva_acces_trait;
    close cur_verifier_acces;
    --
    if coalesce (vva_acces_trait, 'N') = 'O' then
       vbo_valeur_retourne := true;
      else
       vbo_valeur_retourne := false;
    end if;
    --
    return vbo_valeur_retourne;
    --
      --
      -- -------------------------------------------------------------------------------------------------
      --                                           logger
      -- -------------------------------------------------------------------------------------------------
      logger.log_info(p_text   => 'Fin f_acces_traitement ',
                    p_scope  => vva_scope,
                      p_params => vta_params);
      --
    exception when others then
                   apex_debug.info ('Exception f_acces_traitement %s', sqlerrm);
           raise;
    --
  end f_acces_traitement;
  ------------------------------------------------------------------------------------------------------------
  -- Permet d'obtenir les records pour la lov des périodes.
  ------------------------------------------------------------------------------------------------------------
  function f_obtenir_items_lov_periodes (pdt_date in date)
    return tab_pipe_item_lov_periodes
    pipelined is
    -- Déclaration des variables
    cursor cur_obtenir_periodes is
      select resultat.periode,
             resultat.valeur_retourne
      from   (select to_char (pdt_date, 'YYYY') || '04' as periode,
                     to_char (pdt_date, 'YYYY') || '04' as valeur_retourne
              from dual
              where to_number (to_char (pdt_date, 'MM')) >= 4
              union
              select to_char (pdt_date, 'YYYY') || '05' as periode,
                     to_char (pdt_date, 'YYYY') || '05' as valeur_retourne
              from dual
              where to_number (to_char (pdt_date, 'MM')) >= 5
              union
              select to_char (pdt_date, 'YYYY') || '06' as periode,
                     to_char (pdt_date, 'YYYY') || '06' as valeur_retourne
              from dual
              where to_number (to_char (pdt_date, 'MM')) >= 6
              union
              select to_char (pdt_date, 'YYYY') || '07' as periode,
                     to_char (pdt_date, 'YYYY') || '07' as valeur_retourne
              from dual
              where to_number (to_char (pdt_date, 'MM')) >= 7
              union
              select to_char (pdt_date, 'YYYY') || '08' as periode,
                     to_char (pdt_date, 'YYYY') || '08' as valeur_retourne
              from dual
              where to_number (to_char (pdt_date, 'MM')) >= 8
              union
              select to_char (pdt_date, 'YYYY') || '09' as periode,
                     to_char (pdt_date, 'YYYY') || '09' as valeur_retourne
              from dual
              where to_number (to_char (pdt_date, 'MM')) >= 9
              union
              select to_char (pdt_date, 'YYYY') || '10' as periode,
                     to_char (pdt_date, 'YYYY') || '10' as valeur_retourne
              from dual
              where to_number (to_char (pdt_date, 'MM')) >= 10
              union
              select to_char (pdt_date, 'YYYY') || '11' as periode,
                     to_char (pdt_date, 'YYYY') || '11' as valeur_retourne
              from dual
              where to_number (to_char (pdt_date, 'MM')) >= 11
              union
              select to_char (pdt_date, 'YYYY') || '12' as periode,
                     to_char (pdt_date, 'YYYY') || '12' as valeur_retourne
              from dual
              where to_number (to_char (pdt_date, 'MM')) = 12
              union
              select to_char (pdt_date, 'YYYY') || '01' as periode,
                     to_char (pdt_date, 'YYYY') || '01' as valeur_retourne
              from dual
              where to_number (to_char (pdt_date, 'MM')) in (1, 2, 3)
              union
              select to_char (pdt_date, 'YYYY') || '02' as periode,
                     to_char (pdt_date, 'YYYY') || '02' as valeur_retourne
              from dual
              where to_number (to_char (pdt_date, 'MM')) in (2, 3)
              union
              select to_char (pdt_date, 'YYYY') || '03' as periode,
                     to_char (pdt_date, 'YYYY') || '03' as valeur_retourne
              from dual
              where to_number (to_char (pdt_date, 'MM')) = 3
              union
              select to_char (to_number (to_char (pdt_date, 'YYYY') - 1)) || '04' as periode,
                     to_char (to_number (to_char (pdt_date, 'YYYY') - 1)) || '04' as valeur_retourne
              from dual
              where to_number (to_char (pdt_date, 'MM')) in (1, 2, 3)
              union
              select to_char (to_number (to_char (pdt_date, 'YYYY') - 1)) || '05' as periode,
                     to_char (to_number (to_char (pdt_date, 'YYYY') - 1)) || '05' as valeur_retourne
              from dual
              where to_number (to_char (pdt_date, 'MM')) in (1, 2, 3)
              union
              select to_char (to_number (to_char (pdt_date, 'YYYY') - 1)) || '06' as periode,
                     to_char (to_number (to_char (pdt_date, 'YYYY') - 1)) || '06' as valeur_retourne
              from dual
              where to_number (to_char (pdt_date, 'MM')) in (1, 2, 3)
              union
              select to_char (to_number (to_char (pdt_date, 'YYYY') - 1)) || '07' as periode,
                     to_char (to_number (to_char (pdt_date, 'YYYY') - 1)) || '07' as valeur_retourne
              from dual
              where to_number (to_char (pdt_date, 'MM')) in (1, 2, 3)
              union
              select to_char (to_number (to_char (pdt_date, 'YYYY') - 1)) || '08' as periode,
                     to_char (to_number (to_char (pdt_date, 'YYYY') - 1)) || '08' as valeur_retourne
              from dual
              where to_number (to_char (pdt_date, 'MM')) in (1, 2, 3)
              union
              select to_char (to_number (to_char (pdt_date, 'YYYY') - 1)) || '09' as periode,
                     to_char (to_number (to_char (pdt_date, 'YYYY') - 1)) || '09' as valeur_retourne
              from dual
              where to_number (to_char (pdt_date, 'MM')) in (1, 2, 3)
              union
              select to_char (to_number (to_char (pdt_date, 'YYYY') - 1)) || '10' as periode,
                     to_char (to_number (to_char (pdt_date, 'YYYY') - 1)) || '10' as valeur_retourne
              from dual
              where to_number (to_char (pdt_date, 'MM')) in (1, 2, 3)
              union
              select to_char (to_number (to_char (pdt_date, 'YYYY') - 1)) || '11' as periode,
                     to_char (to_number (to_char (pdt_date, 'YYYY') - 1)) || '11' as valeur_retourne
              from dual
              where to_number (to_char (pdt_date, 'MM')) in (1, 2, 3)
              union
              select to_char (to_number (to_char (pdt_date, 'YYYY') - 1)) || '12' as periode,
                     to_char (to_number (to_char (pdt_date, 'YYYY') - 1)) || '12' as valeur_retourne
              from dual
              where to_number (to_char (pdt_date, 'MM')) in (1, 2, 3)) resultat
      order by resultat.periode;
    --
    --
    vta_pipe_item_lov_periodes fdt_pkb_apx_010107.tab_pipe_item_lov_periodes;
    --
    -- logger
    --
    vva_scope  logger_logs.scope%type := cva_scope_prefix || 'f_obtenir_items_lov_periodes';
    vta_params logger.tab_param;
    --
    procedure p_log_parametre is
    begin
      --
      logger.append_param(p_params => vta_params,
                          p_name   => 'pdt_date',
                          p_val    => pdt_date);
      logger.log_info(p_params => vta_params, p_scope => vva_scope, p_text => 'log paramametre');
    end p_log_parametre;
    --
  begin
    --
    p_log_parametre;
    --
    open cur_obtenir_periodes;
    fetch cur_obtenir_periodes bulk collect
      into vta_pipe_item_lov_periodes;
    close cur_obtenir_periodes;
    --
    <<retourner_periodes>>
    if vta_pipe_item_lov_periodes.count > 0 Then
      for indx in vta_pipe_item_lov_periodes.first .. vta_pipe_item_lov_periodes.last loop
        --
        pipe row(vta_pipe_item_lov_periodes(indx));
        --
      end loop retourner_periodes;
    end if;
  end f_obtenir_items_lov_periodes;
  --
end fdt_pkb_apx_010107;
/

