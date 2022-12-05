create or replace package body fdt_pkb_apx_020101 is
   -- ====================================================================================================
   -- Date        : 2021-06-10
   -- Par         : SHQYMR
   -- Description : G�rer les interventions
   -- ====================================================================================================
   -- Date        :
   -- Par         :
   -- Description :
   -- ====================================================================================================
   --
   --
   -- -------------------------------------------------------------------------------------------------
   --                                           logger
   -- -------------------------------------------------------------------------------------------------
   -- Pour voir le r�sultat de la trace, il faut aller dans plsql_developeur et faire ce select :
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
   -- Valider si un traitement doit �tre affich� dans le menu burger dans
   -- intervention d�tail
   -- =========================================================================
   function valider_affichage_menu_burger (pnu_no_seq_intrv_detail fdtt_intervention_detail.no_seq_intrv_detail%type) return boolean is
      --
      vva_indic_visibilite_fdt   fdtt_intervention_detail.indic_visibilite_fdt%type;
    vbo_valeur_retournee       boolean := false;
    --
    cursor cur_obt_intrv_detail is
       select intrv_det.indic_visibilite_fdt
         from   fdtt_intervention_detail intrv_det
         where  intrv_det.no_seq_intrv_detail = pnu_no_seq_intrv_detail;
    --
    --
      -- -------------------------------------------------------------------------------------------------
      --                                           logger
      -- -------------------------------------------------------------------------------------------------
      vva_scope logger_logs.scope%type := cva_scope_prefix || 'valider_affichage_menu_burger';
      vta_params logger.tab_param;
    --
   begin
    --
      -- -------------------------------------------------------------------------------------------------
      --                                           logger
      -- -------------------------------------------------------------------------------------------------
      logger.append_param(p_params => vta_params,
                        p_name   => 'D�but',
                          p_val    => 'valider_affichage_menu_burger');
    --
      -------------------------------------------------------------------------
    -- Lorsque l'indicateur de visibilit� restreint est � oui, le traitement
    -- ne doit pas �tre affich� ... donc valeur � false
      -------------------------------------------------------------------------
    open  cur_obt_intrv_detail;
    fetch cur_obt_intrv_detail into vva_indic_visibilite_fdt;
    close cur_obt_intrv_detail;
    --
      if coalesce (vva_indic_visibilite_fdt, 'O') = 'O' then
         vbo_valeur_retournee := true;
    else
         vbo_valeur_retournee := false;
    end if;
    --
      -- -------------------------------------------------------------------------------------------------
      --                                           logger
      -- -------------------------------------------------------------------------------------------------
      logger.log_info(p_text   => 'Fin valider_affichage_menu_burger ',
                    p_scope  => vva_scope,
                      p_params => vta_params);
    --
    return vbo_valeur_retournee;
      --
    exception when others then
                   apex_debug.info ('Exception valider_affichage_menu_burger %s', sqlerrm);
           raise;
    --
   end valider_affichage_menu_burger;
   --
   --
   -- =========================================================================
   -- Valider les dates des interventions d�tail
   -- =========================================================================
   function f_valider_date (pre_detail_intrv in fdtt_intervention_detail%rowtype) return varchar2 is
      --
      vva_desc_message    varchar2(200) := null;
      vva_type_messa      utlt_message_trait.typ_message%type;
    vda_dt_fin_mois     date;
    vva_jour_semaine    varchar2(100);
    --
    cursor cur_obt_last_day is
       select last_day(pre_detail_intrv.dt_fin_reelle)
     from   dual;
    --
    cursor cur_obt_jour_semaine is
       select trim (upper (substr (TO_CHAR(pre_detail_intrv.dt_fin_reelle, 'DL'), 1, instr (TO_CHAR(pre_detail_intrv.dt_fin_reelle, 'DL'), ' '))))
         from   dual;
    --
    --
      -- -------------------------------------------------------------------------------------------------
      --                                           logger
      -- -------------------------------------------------------------------------------------------------
      vva_scope logger_logs.scope%type := cva_scope_prefix || 'f_valider_date';
      vta_params logger.tab_param;
    --
   begin
    --
      -- -------------------------------------------------------------------------------------------------
      --                                           logger
      -- -------------------------------------------------------------------------------------------------
      logger.append_param(p_params => vta_params,
                        p_name   => 'D�but',
                          p_val    => 'f_valider_date');
    --
      -------------------------------------------------------------------------
    -- La date de d�but r�elle doit �tre inf�rieure ou �gale � la date de
    -- fin r�elle
      -------------------------------------------------------------------------
      if pre_detail_intrv.dt_deb_reelle is not null and pre_detail_intrv.dt_fin_reelle is not null then
       if pre_detail_intrv.dt_deb_reelle > pre_detail_intrv.dt_fin_reelle then
        vva_desc_message := utl_pkb_apx_message.f_obt_message (pva_code_systeme => 'ZZZ',
                                                                   pva_code_messa   => '900044',
                                                                   pva_param_1      => ' d�but r�elle',
                                                                   pva_param_2      => ' fin r�elle',
                                                                   pva_type_messa   => vva_type_messa);
       end if;
    end if;
    --
      -------------------------------------------------------------------------
    -- La date d�but planifi�e doit �tre inf�rieure ou �gale � la date de
    -- fin estim�e
      -------------------------------------------------------------------------
      if pre_detail_intrv.dt_deb_planifie is not null and pre_detail_intrv.dt_fin_estime is not null then
       if pre_detail_intrv.dt_deb_planifie > pre_detail_intrv.dt_fin_estime then
        vva_desc_message := utl_pkb_apx_message.f_obt_message (pva_code_systeme => 'ZZZ',
                                                                   pva_code_messa   => '900044',
                                                                   pva_param_1      => ' d�but planifi�e',
                                                                   pva_param_2      => ' fin estim�e',
                                                                   pva_type_messa   => vva_type_messa);
     end if;
    end if;
    --
      -------------------------------------------------------------------------
    -- La date de d�but autoris�e doit �tre inf�rieure ou �gale � la date de
    -- fin autoris�e
      -------------------------------------------------------------------------
      if pre_detail_intrv.dt_deb_autorise is not null and pre_detail_intrv.dt_fin_autorise is not null then
       if pre_detail_intrv.dt_deb_autorise > pre_detail_intrv.dt_fin_autorise then
        vva_desc_message := utl_pkb_apx_message.f_obt_message (pva_code_systeme => 'ZZZ',
                                                                   pva_code_messa   => '900044',
                                                                   pva_param_1      => ' d�but autoris�e',
                                                                   pva_param_2      => ' fin autoris�e',
                                                                   pva_type_messa   => vva_type_messa);
     end if;
    end if;
    --
      -------------------------------------------------------------------------
    -- La date de fin r�elle doit �tre un jour de fin de mois ou un dimanche
      -------------------------------------------------------------------------
      if pre_detail_intrv.dt_fin_reelle is not null then
       open  cur_obt_last_day;
     fetch cur_obt_last_day into vda_dt_fin_mois;
     close cur_obt_last_day;
     --
     open  cur_obt_jour_semaine;
     fetch cur_obt_jour_semaine into vva_jour_semaine;
     close cur_obt_jour_semaine;
     --
     if pre_detail_intrv.dt_fin_reelle <> vda_dt_fin_mois then
            if vva_jour_semaine <> 'DIMANCHE' then
               vva_desc_message := utl_pkb_apx_message.f_obt_message (pva_code_systeme => 'FDT',
                                                                      pva_code_messa   => '000134',
                                                                      -- pva_param_1      => null,
                                                                      -- pva_param_2      => null,
                                                                      pva_type_messa   => vva_type_messa);
      end if;
     end if;
    end if;
    --
      -- -------------------------------------------------------------------------------------------------
      --                                           logger
      -- -------------------------------------------------------------------------------------------------
      logger.log_info(p_text   => 'Fin f_valider_date ',
                    p_scope  => vva_scope,
                      p_params => vta_params);
    --
    return vva_desc_message;
      --
    exception when others then
                   apex_debug.info ('Exception f_valider_date %s', sqlerrm);
           raise;
    --
   end f_valider_date;
   --
   --
   -- =========================================================================
   -- Valider les ressources des interventions d�tail
   -- =========================================================================
   function f_valider_contexte_intrv_detail (pre_detail_intrv in fdtt_intervention_detail%rowtype) return varchar2 is
      --
      vva_desc_message    varchar2(400);
      vva_type_messa      utlt_message_trait.typ_message%type;
    --
    --
      -- -------------------------------------------------------------------------------------------------
      --                                           logger
      -- -------------------------------------------------------------------------------------------------
      vva_scope logger_logs.scope%type := cva_scope_prefix || 'f_valider_contexte_intrv_detail';
      vta_params logger.tab_param;
    --
   begin
    --
      -- -------------------------------------------------------------------------------------------------
      --                                           logger
      -- -------------------------------------------------------------------------------------------------
      logger.append_param(p_params => vta_params,
                        p_name   => 'D�but',
                          p_val    => 'f_valider_contexte_intrv_detail');
    --
      -- -------------------------------------------------------------------------------------------------
      -- Validation de contexte pour un d�tail intervention
      -- -------------------------------------------------------------------------------------------------
    --
    if ((pre_detail_intrv.co_systeme is not null and pre_detail_intrv.code_intrv is not null) or
          (pre_detail_intrv.co_systeme is null     and pre_detail_intrv.code_intrv is null))     then
     --
         vva_desc_message := utl_pkb_apx_message.f_obt_message (pva_code_systeme => 'FDT',
                                                                pva_code_messa   => '000132',
                                                                -- pva_param_1      => null,
                                                                -- pva_param_2      => null,
                                                                pva_type_messa   => vva_type_messa);
    end if;
      --
      -- -------------------------------------------------------------------------------------------------
      --                                           logger
      -- -------------------------------------------------------------------------------------------------
      logger.log_info(p_text   => 'Fin f_valider_contexte_intrv_detail ',
                    p_scope  => vva_scope,
                      p_params => vta_params);
    --
    return vva_desc_message;
      --
    exception when others then
                   apex_debug.info ('Exception f_valider_contexte_intrv_detail %s', sqlerrm);
           raise;
    --
   end f_valider_contexte_intrv_detail;
   --
   --
   -- =========================================================================
   -- Ajouter le premier enregistrement de d�coupage (GENERAUX) dans la
   -- table FDTT_ASS_ACT_INTRV_DET lors de l'ajout d'une nouvelle interventions
   -- d�tail
   --
   -- *** La feuille de temps va dans la table d'association pour pr�senter
   --     les interventions ... donc pour une intervention qui n'a pas besoin
   --     d'un d�coupage, il faut cr�er un enregistrement de d�coupage
   --     g�n�ral
   -- =========================================================================
   procedure p_maj_decoupage (pre_detail_intrv in fdtt_intervention_detail%rowtype) is
      --
    vva_description      varchar2(400);
    vnu_no_seq_activite  number;
    vva_desc_generaux    varchar2(100);
    vnu_nbr_enreg        number;
    --
    -- V�rifier si l'enregistrement de base (GENERAUX) existe d�j�
    --
    cursor cur_obt_decoupage_base is
       select count(*)
         from   fdtt_ass_act_intrv_det   ass_intrv_det
                inner join fdtt_activites actv          on ass_intrv_det.no_seq_activite_decoupage = actv.no_seq_activite
         where  actv.co_typ_activite = 'GENERAUX'
         and    ass_intrv_det.no_seq_intrv_detail = pre_detail_intrv.no_seq_intrv_detail;
    --
    -- Obtenir la s�quence de l'activit� qui repr�sente
      -- l'enregistrement du d�coupage de base
    --
    cursor cur_obt_seq_act_generale is
      select act.no_seq_activite,
               ' (' || act.acronyme || ' - ' || act.nom || ')' as desc_generaux
        from   fdtt_activites act
        where  act.co_typ_activite = 'GENERAUX';
    --
    -- Pr�parer la description qui sera affich�e dans le d�coupage
    -- de l'intervention en cours
    --
    cursor cur_obt_descr_decoupage is
       select coalesce (intrv_det.co_systeme, intrv_det.code_intrv) ||
            ' / ' || stra.description ||
        decode (eta.description, null, '', ' / ') || eta.description  ||
                decode (liv.description, null, '', ' / ') || liv.description ||
        decode (intrv_det.indic_capitalisable, 'O', ' / Capitalisable', '')  as description
         from   fdtt_intervention_detail     intrv_det
                left join fdtt_typ_strategie stra      on intrv_det.no_seq_typ_strategie = stra.no_seq_typ_strategie
        left  join fdtt_typ_etape           eta       on intrv_det.no_seq_typ_etape     = eta.no_seq_typ_etape
                left  join fdtt_typ_livraison       liv       on intrv_det.no_seq_typ_livraison = liv.no_seq_typ_livraison
         where  intrv_det.no_seq_intrv_detail = pre_detail_intrv.no_seq_intrv_detail;
    --
    --
      -- -------------------------------------------------------------------------------------------------
      --                                           logger
      -- -------------------------------------------------------------------------------------------------
      vva_scope logger_logs.scope%type := cva_scope_prefix || 'p_maj_decoupage';
      vta_params logger.tab_param;
    --
   begin
    --
      -- -------------------------------------------------------------------------------------------------
      --                                           logger
      -- -------------------------------------------------------------------------------------------------
      logger.append_param(p_params => vta_params,
                        p_name   => 'D�but',
                          p_val    => 'p_maj_decoupage');
    --
      -- -------------------------------------------------------------------------------------------------
      -- Insertion de l'enregistrement de base pour le d�coupage d'une nouvelle intervention
    -- ou
      -- mise � jour de la description du d�coupage de l'intervention en cours
      -- -------------------------------------------------------------------------------------------------
    --
    --
    -- V�rifier si l'enregistrement de base (GENERAUX) existe d�j�
    --
    -- S'il n'existe pas, il faut l'ins�rer
    --
    -- S'il existe, il faut le modifier
    --
    open  cur_obt_decoupage_base;
    fetch cur_obt_decoupage_base into vnu_nbr_enreg;
    close cur_obt_decoupage_base;
    --
    if vnu_nbr_enreg = 0 then
       --
       --
       -- Obtenir la s�quence de l'activit� qui repr�sente
         -- l'enregistrement du d�coupage de base
       --
       open  cur_obt_seq_act_generale;
       fetch cur_obt_seq_act_generale into vnu_no_seq_activite,
                                         vva_desc_generaux;
       close cur_obt_seq_act_generale;
       --
         --
         -- Pr�parer la description qui sera affich�e dans le d�coupage
       -- de l'intervention en cours
         --
       open  cur_obt_descr_decoupage;
       fetch cur_obt_descr_decoupage into vva_description;
       close cur_obt_descr_decoupage;
     --
     vva_description := vva_description || vva_desc_generaux;
       --
       --
       -- Insertion de l'enregistrement du d�coupage de base
       --
       insert into fdtt_ass_act_intrv_det (no_seq_aact_intrv_det,
                                             no_seq_intrv_detail,
                                             no_seq_activite_decoupage,
                                             description,
                                             co_user_cre_enreg,
                                             co_user_maj_enreg,
                                             dh_cre_enreg,
                                            dh_maj_enreg)
                               values (null,
                               pre_detail_intrv.no_seq_intrv_detail,
                             vnu_no_seq_activite,
                             vva_description,
                             null,
                             null,
                             null,
                           null);
    else
       --
       --
       -- Update de l'enregistrement du d�coupage
       --
       update fdtt_ass_act_intrv_det decoupage
     set    decoupage.description = (select coalesce (intrv_det.co_systeme, intrv_det.code_intrv) ||
                                                ' / ' || stra.description ||
                                                decode (eta.description, null, '', ' / ') || eta.description  ||
                                                decode (liv.description, null, '', ' / ') || liv.description  ||
                                        decode (intrv_det.indic_capitalisable, 'O', ' / Capitalisable', '') ||
                                                ' (' || act.acronyme || ' - ' || act.nom || ')'
                                         from   fdtt_ass_act_intrv_det              ass
                                                inner join fdtt_intervention_detail intrv_det on ass.no_seq_intrv_detail       = intrv_det.no_seq_intrv_detail
                                                inner join fdtt_activites           act       on ass.no_seq_activite_decoupage = act.no_seq_activite
                                                left  join fdtt_typ_strategie       stra      on intrv_det.no_seq_typ_strategie = stra.no_seq_typ_strategie
                                                left  join fdtt_typ_etape           eta       on intrv_det.no_seq_typ_etape     = eta.no_seq_typ_etape
                                                left  join fdtt_typ_livraison       liv       on intrv_det.no_seq_typ_livraison = liv.no_seq_typ_livraison
                                         where  ass.no_seq_aact_intrv_det = decoupage.no_seq_aact_intrv_det)
     where  decoupage.no_seq_intrv_detail = pre_detail_intrv.no_seq_intrv_detail;
    end if;
      --
      -- -------------------------------------------------------------------------------------------------
      --                                           logger
      -- -------------------------------------------------------------------------------------------------
      logger.log_info(p_text   => 'Fin p_maj_decoupage ',
                    p_scope  => vva_scope,
                      p_params => vta_params);
      --
    exception when others then
                   apex_debug.info ('Exception p_maj_decoupage %s', sqlerrm);
           raise;
    --
   end p_maj_decoupage;
   --
   --
   -- =========================================================================
   -- Mise � jour de la description du d�coupage en cours via la fen�tre
   -- gestion du d�coupage d'une intervention
   -- =========================================================================
   function f_maj_descr_decoupage (pre_ass_act_intrv_det in fdtt_ass_act_intrv_det%rowtype) return varchar2 is
      --
    vva_description      varchar2(400);
    vva_descr_partie_1   varchar2(400);
    vva_descr_partie_2   varchar2(400);
    --
    -- Obtenir certaines info de l'intervention d�tail afin de b�tir la
    -- description du d�coupage en cours
    --
    cursor cur_obt_info_intrv_det is
       select coalesce (intrv_det.co_systeme, intrv_det.code_intrv) ||
            ' / ' || stra.description ||
        decode (eta.description, null, '', ' / ') || eta.description  ||
                decode (liv.description, null, '', ' / ') || liv.description ||
        decode (intrv_det.indic_capitalisable, 'O', ' / Capitalisable', '')
         from   fdtt_intervention_detail intrv_det
            left join fdtt_typ_strategie       stra on intrv_det.no_seq_typ_strategie = stra.no_seq_typ_strategie
        left join fdtt_typ_etape           eta  on intrv_det.no_seq_typ_etape     = eta.no_seq_typ_etape
                left join fdtt_typ_livraison       liv  on intrv_det.no_seq_typ_livraison = liv.no_seq_typ_livraison
       where  intrv_det.no_seq_intrv_detail = pre_ass_act_intrv_det.no_seq_intrv_detail;
    --
    -- Obtenir certaines info du d�coupage en cours afin de b�tir la
    -- description du d�coupage en cours
    --
    cursor cur_obt_info_activite is
       select ' (' || act.acronyme || ' - ' || act.nom || ')'
         from   fdtt_activites act
       where  act.no_seq_activite = pre_ass_act_intrv_det.no_seq_activite_decoupage;
    --
    --
      -- -------------------------------------------------------------------------------------------------
      --                                           logger
      -- -------------------------------------------------------------------------------------------------
      vva_scope logger_logs.scope%type := cva_scope_prefix || 'f_maj_descr_decoupage';
      vta_params logger.tab_param;
    --
   begin
    --
      -- -------------------------------------------------------------------------------------------------
      --                                           logger
      -- -------------------------------------------------------------------------------------------------
      logger.append_param(p_params => vta_params,
                        p_name   => 'D�but',
                          p_val    => 'f_maj_descr_decoupage');
    --
      -- -------------------------------------------------------------------------------------------------
      -- Initialisation de la description du d�coupage en cours
      -- -------------------------------------------------------------------------------------------------
    --
    open  cur_obt_info_intrv_det;
    fetch cur_obt_info_intrv_det into vva_descr_partie_1;
    close cur_obt_info_intrv_det;
    --
    open  cur_obt_info_activite;
    fetch cur_obt_info_activite into vva_descr_partie_2;
    close cur_obt_info_activite;
    --
    vva_description := vva_descr_partie_1 || vva_descr_partie_2;
      --
      -- -------------------------------------------------------------------------------------------------
      --                                           logger
      -- -------------------------------------------------------------------------------------------------
      logger.log_info(p_text   => 'Fin f_maj_descr_decoupage ',
                    p_scope  => vva_scope,
                      p_params => vta_params);
      --
    return vva_description;
    --
    exception when others then
                   apex_debug.info ('Exception f_maj_descr_decoupage %s', sqlerrm);
           raise;
    --
   end f_maj_descr_decoupage;
   --
   --
   -- =========================================================================
   -- Valider la suppression dans le d�coupage
   -- =========================================================================
   function f_valider_suppression_decoupage (pre_ass_act_intrv_det in fdtt_ass_act_intrv_det%rowtype) return varchar2 is
      --
      vva_desc_message    varchar2(200) := null;
      vva_type_messa      utlt_message_trait.typ_message%type;
    vnu_nbr_enreg       number;
    --
    cursor cur_obt_nbr_frais_gen is
       select count(*) as nbr_enreg
         from   fdtt_ass_act_intrv_det decoupage
                inner join fdtt_activites act on decoupage.no_seq_activite_decoupage = act.no_seq_activite
         where  act.co_typ_activite = 'GENERAUX'
         and    decoupage.no_seq_aact_intrv_det = pre_ass_act_intrv_det.no_seq_aact_intrv_det;
    --
    --
      -- -------------------------------------------------------------------------------------------------
      --                                           logger
      -- -------------------------------------------------------------------------------------------------
      vva_scope logger_logs.scope%type := cva_scope_prefix || 'f_valider_suppression_decoupage';
      vta_params logger.tab_param;
    --
   begin
    --
      -- -------------------------------------------------------------------------------------------------
      --                                           logger
      -- -------------------------------------------------------------------------------------------------
      logger.append_param(p_params => vta_params,
                        p_name   => 'D�but',
                          p_val    => 'f_valider_suppression_decoupage');
    --
      -------------------------------------------------------------------------
    -- La date de d�but r�elle doit �tre inf�rieure ou �gale � la date de
    -- fin r�elle
      -------------------------------------------------------------------------
      if pre_ass_act_intrv_det.no_seq_aact_intrv_det is not null then
       open  cur_obt_nbr_frais_gen;
     fetch cur_obt_nbr_frais_gen into vnu_nbr_enreg;
     close cur_obt_nbr_frais_gen;
     --
     if vnu_nbr_enreg > 0 then
        vva_desc_message := utl_pkb_apx_message.f_obt_message (pva_code_systeme => 'FDT',
                                                                   pva_code_messa   => '000147',
--                                                                   pva_param_1      => null,
--                                                                   pva_param_2      => null,
                                                                   pva_type_messa   => vva_type_messa);
       end if;
    end if;
    --
      -- -------------------------------------------------------------------------------------------------
      --                                           logger
      -- -------------------------------------------------------------------------------------------------
      logger.log_info(p_text   => 'Fin f_valider_suppression_decoupage ',
                    p_scope  => vva_scope,
                      p_params => vta_params);
    --
    return vva_desc_message;
      --
    exception when others then
                   apex_debug.info ('Exception f_valider_suppression_decoupage %s', sqlerrm);
           raise;
    --
   end f_valider_suppression_decoupage;
   --
   --
   -- =========================================================================
   -- Valider les dates des interventions d�tail
   -- =========================================================================
   function f_valider_date_ressource (pre_ass_intrvd_ressr in fdtt_ass_intrvd_ressr%rowtype) return varchar2 is
      --
      --
      vva_desc_message    varchar2(400);
      vva_type_messa      utlt_message_trait.typ_message%type;
    --
    cursor cur_obt_dates_reelles_intrv is
       select intrv_det.dt_deb_reelle,
                intrv_det.dt_fin_reelle
         from   fdtt_intervention_detail intrv_det
         where  intrv_det.no_seq_intrv_detail = pre_ass_intrvd_ressr.no_seq_intrv_detail;
      --
    rec_obt_dates_reelles_intrv  cur_obt_dates_reelles_intrv%rowtype;
    --
    --
      -- -------------------------------------------------------------------------------------------------
      --                                           logger
      -- -------------------------------------------------------------------------------------------------
      vva_scope logger_logs.scope%type := cva_scope_prefix || 'f_valider_date_ressource';
      vta_params logger.tab_param;
    --
   begin
    --
      -- -------------------------------------------------------------------------------------------------
      --                                           logger
      -- -------------------------------------------------------------------------------------------------
      logger.append_param(p_params => vta_params,
                        p_name   => 'D�but',
                          p_val    => 'f_valider_date_ressource');
    --
      -------------------------------------------------------------------------
    -- La date de d�but doit �tre inf�rieure ou �gale � la date de fin
      -------------------------------------------------------------------------
      if pre_ass_intrvd_ressr.dt_debut is not null and pre_ass_intrvd_ressr.dt_fin is not null then
         vva_desc_message := utl_pkb_apx_date.f_valider_date2_gte_date1 (pda_date1      => pre_ass_intrvd_ressr.dt_debut,
                                                                         pva_date1_desc => 'd�but',
                                                                         pda_date2      => pre_ass_intrvd_ressr.dt_fin,
                                                                         pva_date2_desc => 'fin');
    end if;
    --
      -------------------------------------------------------------------------
    -- La date de d�but doit �tre comprise entre la date de d�but r�elle et
    -- la date de fin r�elle de l'intervention d�tail
      -------------------------------------------------------------------------
    open  cur_obt_dates_reelles_intrv;
    fetch cur_obt_dates_reelles_intrv into rec_obt_dates_reelles_intrv;
    close cur_obt_dates_reelles_intrv;
    --
      if pre_ass_intrvd_ressr.dt_debut is not null then
       if pre_ass_intrvd_ressr.dt_debut < rec_obt_dates_reelles_intrv.dt_deb_reelle or
        pre_ass_intrvd_ressr.dt_debut > coalesce (rec_obt_dates_reelles_intrv.dt_fin_reelle, pre_ass_intrvd_ressr.dt_debut) then
      --
            vva_desc_message := utl_pkb_apx_message.f_obt_message (pva_code_systeme => 'FDT',
                                                                   pva_code_messa   => '000135',
                                                                   pva_param_1      => rec_obt_dates_reelles_intrv.dt_deb_reelle,
                                                                   pva_param_2      => rec_obt_dates_reelles_intrv.dt_fin_reelle,
                                                                   pva_type_messa   => vva_type_messa);
     end if;
    end if;
    --
      -- -------------------------------------------------------------------------------------------------
      --                                           logger
      -- -------------------------------------------------------------------------------------------------
      logger.log_info(p_text   => 'Fin f_valider_date_ressource ',
                    p_scope  => vva_scope,
                      p_params => vta_params);
    --
    return vva_desc_message;
      --
    exception when others then
                   apex_debug.info ('Exception f_valider_date_ressource %s', sqlerrm);
           raise;
    --
   end f_valider_date_ressource;
   --
end fdt_pkb_apx_020101;
/

