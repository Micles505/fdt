create or replace package body fdt_pkb_apx_010101 is
  -- ====================================================================================================
  -- Date        : 2021-09-14
  -- Par         : SHQYMR
  -- Description : G?rer la Saisie du temps et les efforts
  -- ====================================================================================================
  -- Date        : 
  -- Par         : 
  -- Description : 
  -- ====================================================================================================
  --
  -- Private type declarations
  --
  -- Private constant declarations
  cdt_da_systeme_fdt date := utl_fnb_obt_dt_prodc(pva_co_systeme => 'FDT', pva_form_date => 'DA');
  --
  -- Private variable declarations
  --
  cva_update_row_status constant varchar2(3) := 'U';
  cva_create_row_status constant varchar2(3) := 'C';
  --   cva_delete_row_status constant varchar2(3) := 'D';
  --
  cva_nom_collection constant varchar2(30) := 'COL_010101';
  --
  --
  --Variables pour utl_pkb_apx_message.f_obt_message
  vva_message     varchar2(4000) := null;
  vva_typ_message utlt_message_trait.typ_message%type := null;
  -- -------------------------------------------------------------------------------------------------
  --                                           logger
  -- -------------------------------------------------------------------------------------------------
  -- Pour voir le r?sultat de la trace, il faut aller dans plsql_developeur et faire ce select :
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
  -- =========================================================================
  -- Valider les interventions
  -- =========================================================================
  function f_obtenir_item_onglet_saisie(pnu_no_seq_ressource in fdtt_ressource.NO_SEQ_RESSOURCE%type,
                                        pva_an_mois_fdt      in fdtt_feuilles_temps.AN_MOIS_FDT%type,
                                        pdt_dt_debut_periode in date,
                                        pdt_dt_fin_periode   in date) return tab_pipe_item_onglet_saisie
    pipelined is
    --
    --vva_desc_message    varchar2(200);
    --vva_type_messa      varchar2(20);
    --
    cva_yes constant varchar2(03) := 'YES';
    cva_no  constant varchar2(03) := 'NO';
    --
    --
    -- -------------------------------------------------------------------------------------------------
    --                                           logger
    -- -------------------------------------------------------------------------------------------------
    vva_scope  logger_logs.scope%type := cva_scope_prefix || 'f_obtenir_item_onglet_saisie';
    vta_params logger.tab_param;
    --
    vre_item_onglet_saisie_apex fdt_pkb_apx_010101.rec_item_onglet_saisie;
    vta_item_onglet_saisie_apex fdt_pkb_apx_010101.tab_pipe_item_onglet_saisie := fdt_pkb_apx_010101.tab_pipe_item_onglet_saisie();
    --
    cursor cur_periode_dans_mois_et_autre is
      with jour_ouvrable as
       (select to_date(pva_an_mois_fdt || to_char(journee.jour, '00'), 'yyyymmdd') as jo,
               TO_CHAR(to_date(pva_an_mois_fdt || to_char(journee.jour, '00'), 'yyyymmdd'), 'iw') as semaineAnnuelle
          from (select rownum as jour
                  from busv_info_employe
                 where rownum <=
                       to_number(to_char(last_day(to_date(to_char(to_date(pva_an_mois_fdt || '01', 'yyyymmdd'),
                                                                  'yyyymm'),
                                                          'yyyymm')),
                                         'dd'))) journee)
      select min(jourO.jo) as jour_debut_periode,
             max(jourO.jo) as jour_fin_periode,
             decode(jourO.semaineAnnuelle, '52', '00', jourO.semaineAnnuelle) as semaine_annuelle,
             min(to_char(jourO.jo, 'dd')) || ' au ' || max(to_char(jourO.jo, 'dd')) || ' ' ||
             max(to_char(jourO.jo, 'Month')) as libelle
        from jour_ouvrable jourO
       group by jourO.semaineAnnuelle
      --
      union all
      -- Ajouter l'onglet Tout le mois (tous les onglets p?riodes ensembles)
      select min(to_date(pva_an_mois_fdt || '01', 'yyyymmdd')) as jour_debut_periode,
             max(to_date(pva_an_mois_fdt || to_char(last_day(pva_an_mois_fdt || '01'), 'dd'), 'yyyymmdd')) as jour_fin_periode,
             '99' as semaine_annuelle,
             'Mois complet' as libelle
        from dual
      --
      --         union all
      -- Ajouter l'onglet Sagir
      --         select null,
      --                null,
      --                null,
      --               'Sagir' as libelle
      --         from dual
      --
      --         union all
      -- Ajouter l'onglet Sommaire 
      --         select null,
      --                null,
      --                null,
      --               'Sommaire' as libelle
      --         from dual
       order by 2, 1 desc;
    --
    --rec_periode_dans_mois_et_autre    cur_periode_dans_mois_et_autre%rowtype;
    type tab_periode_dans_mois_et_autre is table of cur_periode_dans_mois_et_autre%rowtype;
    vta_periode_dans_mois_et_autre tab_periode_dans_mois_et_autre;
    --
    -- Permet d'aller chercher les infos pour afficher qu'un onglet pour les utilisateurs 
    -- qui ne saisissent pas d'intervention.
    --
    cursor cur_une_seule_periode is
    -- Ajouter l'onglet Tout le mois (tous les onglets p?riodes ensembles)
      select 1 as level_menu,
             'Mois complet' as label_menu,
             '#' as target_menu,
             'YES' as is_current_list_entry,
             null as image,
             null as image_attribute,
             null as image_alt_attribute,
             min(to_date(pva_an_mois_fdt || '01', 'yyyymmdd')) as attribute1,
             max(to_date(pva_an_mois_fdt || to_char(last_day(pva_an_mois_fdt || '01'), 'dd'), 'yyyymmdd')) as attribute2,
             null as attribute3,
             null as attribute4,
             null as attribute5,
             null as attribute6,
             null as attribute7,
             null as attribute8,
             null as attribute9,
             null as attribute10
        from dual;
    --         union all
    -- Ajouter l'onglet Sagir
    --         select null as level_menu,
    --                'Sagir' as label_menu,
    --                '#'     as target_menu,
    --                'NO' as is_current_list_entry,
    --                null as image,
    --                null as image_attribute,
    --                null as image_alt_attribute,
    --                min(to_date(pva_an_mois_fdt || '01','yyyymmdd'))                                            as attribute1,
    --                max(to_date(pva_an_mois_fdt || to_char(last_day(pva_an_mois_fdt || '01'),'dd'),'yyyymmdd')) as attribute2 ,
    --                null as attribute3,
    --                null as attribute4,
    --                null as attribute5,
    --                null as attribute6,
    --                null as attribute7,
    --                null as attribute8,
    --                null as attribute9,
    --                null as attribute10
    --         from dual;
    --
    type tab_une_seule_periode is table of cur_une_seule_periode%rowtype;
    vta_une_seule_periode tab_une_seule_periode;
    --
    -- Permet de voir si la personne doit saisir des interventions 
    -- 
    --
    cursor cur_obtenir_ressource is
      select res.ind_saisie_intrv, res.ind_saisie_assiduite, res.co_interne_exter, res.co_categ_emploi
        from fdtt_ressource res
       where res.no_seq_ressource = pnu_no_seq_ressource;
    --
    rec_obtenir_ressource cur_obtenir_ressource%rowtype;
    --
    function formatter_url_onglet(pdt_date_debut in date, pdt_date_fin in date, pnu_indx in number)
      return varchar2 is
      --
      -- f?p=App:Page:Session:Request:Debug:ClearCache:itemNames:itemValues:PrinterFriendly
      --      0    1     2      3       4        5     <----     6     ---->      7
      --
      --cva_url_apex constant varchar2(4000) default 'f?p=%s:%s:%s:%s:%s:%s:%s:%s';
      cva_process constant varchar2(200) default 'javascript:shq.fdt.selectionPeriode(''idRegionSelecteurPeriode'',''%s'', ''P2_DATE_DEBUT_PERIODE'',''%s'',''P2_DATE_FIN_PERIODE'',''%s'');';
      vva_url varchar2(4000);
      --
      --  <a href="f?p=&APP_ID.:1:&APP_SESSION.:APPLICATION_PROCESS=GET_FILE:::FILE_ID:my_image.png">Download my_image.png</a>
      --
    begin
      vva_url := apex_string.format(p_message => cva_process,
                                    p0        => pnu_indx - 1,
                                    p1        => pdt_date_debut,
                                    p2        => pdt_date_fin);
      return vva_url;
    end; -- formatter_url_onglet                                                
    --   
    -- Traiter les onlget intervention
    --   
    function f_traiter_onglet_intervention(pre_periode_dans_mois_et_autre in cur_periode_dans_mois_et_autre%rowtype,
                                           pnu_indx                       number,
                                           pdt_dt_debut_periode           date,
                                           pdt_dt_fin_periode             date)
      return fdt_pkb_apx_010101.rec_item_onglet_saisie is
      --     
      vre_item_apx fdt_pkb_apx_010101.rec_item_onglet_saisie;
      --  
      -- logger
      --
      vva_scope logger_logs.scope%type := cva_scope_prefix || 'f_traiter_onglet_intervention';
    
    begin
      /*   -- Si la date du jour est en fds on enl?ve le nombre de jour selon qu'on est le samedi ou le dimanche
      if to_char(cdt_da_systeme_fdt,'D') = '6' or to_char(cdt_da_systeme_fdt,'D') = '7' then
         -- On enl?ve 2 jours ? la date du jour pour afficher les donn?es de la p?riode de cette semaine 
         if to_char(cdt_da_systeme_fdt,'D') = '6' then
            cdt_da_systeme_fdt := cdt_da_systeme_fdt - 1;
         end if;
         if to_char(cdt_da_systeme_fdt,'D') = '7' then
            cdt_da_systeme_fdt := cdt_da_systeme_fdt - 2;
         end if;
      end if;    */
      vre_item_apx.level_menu := 1;
      vre_item_apx.label_menu := pre_periode_dans_mois_et_autre.libelle;
      --
      vre_item_apx.target_menu := formatter_url_onglet(pre_periode_dans_mois_et_autre.jour_debut_periode,
                                                       pre_periode_dans_mois_et_autre.jour_fin_periode,
                                                       pnu_indx);
      /*          vre_item_apx.is_current_list_entry := case
      when pdt_dt_debut_periode BETWEEN pre_periode_dans_mois_et_autre.jour_debut_periode 
                                  and pre_periode_dans_mois_et_autre.jour_fin_periode 
           and pre_periode_dans_mois_et_autre.semaine_annuelle is not null then
          cva_yes
      when last_day(pre_periode_dans_mois_et_autre.jour_fin_periode) = pre_periode_dans_mois_et_autre.jour_fin_periode 
           and pdt_dt_debut_periode > pre_periode_dans_mois_et_autre.jour_fin_periode 
           and pre_periode_dans_mois_et_autre.semaine_annuelle is not null then
         cva_yes
      else
         cva_no
      end;*/
      --
      if pre_periode_dans_mois_et_autre.jour_debut_periode = pdt_dt_debut_periode and
         pre_periode_dans_mois_et_autre.jour_fin_periode = pdt_dt_fin_periode then
        -- 
        vre_item_apx.is_current_list_entry := cva_yes;
      else
        vre_item_apx.is_current_list_entry := cva_no;
      end if;
      --
      vre_item_apx.image               := null;
      vre_item_apx.image_attribute     := null;
      vre_item_apx.image_alt_attribute := null;
      vre_item_apx.attribute1          := pre_periode_dans_mois_et_autre.jour_debut_periode;
      vre_item_apx.attribute2          := pre_periode_dans_mois_et_autre.jour_fin_periode;
      vre_item_apx.attribute3          := pre_periode_dans_mois_et_autre.semaine_annuelle;
      vre_item_apx.attribute4          := null;
      vre_item_apx.attribute5          := null;
      vre_item_apx.attribute6          := null;
      vre_item_apx.attribute7          := null;
      vre_item_apx.attribute8          := null;
      vre_item_apx.attribute9          := null;
      vre_item_apx.attribute10         := null;
      --
      --
      return vre_item_apx;
    exception
      when others then
        logger.log_error('Exception others - f_traiter_menu_item',
                         vva_scope,
                         'f_traiter_onglet_intervention');
        raise;
    end f_traiter_onglet_intervention;
    --
  begin
    --
    -- -------------------------------------------------------------------------------------------------
    --                                           logger
    -- -------------------------------------------------------------------------------------------------
    logger.append_param(p_params => vta_params, p_name => 'D?but', p_val => 'f_obtenir_item_onglet_saisie');
    logger.append_param(p_params => vta_params,
                        p_name   => 'pnu_no_seq_ressource',
                        p_val    => pnu_no_seq_ressource);
    logger.append_param(p_params => vta_params, p_name => 'pva_an_mois_fdt', p_val => pva_an_mois_fdt);
    --
    --  
    open cur_obtenir_ressource;
    fetch cur_obtenir_ressource
      into rec_obtenir_ressource;
    close cur_obtenir_ressource;
    --
    if rec_obtenir_ressource.ind_saisie_intrv = 'N' then
      -- La personne ne saisit pas d'intervention, donc il ne va y avoir qu'un onglet pour la saisie FDT
      open cur_une_seule_periode;
      fetch cur_une_seule_periode bulk collect
        into vta_une_seule_periode;
      close cur_une_seule_periode;
      --    
      <<traiter_onglet_une_seule_periode>>
      if vta_une_seule_periode.count > 0 Then
        for indx in vta_une_seule_periode.first .. vta_une_seule_periode.last loop
          --       
          if vta_une_seule_periode.exists(indx) then
            vta_item_onglet_saisie_apex.extend;
            vre_item_onglet_saisie_apex.level_menu  := vta_une_seule_periode(indx).level_menu;
            vre_item_onglet_saisie_apex.label_menu  := vta_une_seule_periode(indx).label_menu;
            vre_item_onglet_saisie_apex.target_menu := vta_une_seule_periode(indx).target_menu;
            --vre_item_onglet_saisie_apex.target_menu           :=  formatter_url_onglet(vta_une_seule_periode(indx).attribute1,
            --                                                                           vta_une_seule_periode(indx).attribute2);
            vre_item_onglet_saisie_apex.is_current_list_entry := vta_une_seule_periode(indx).is_current_list_entry;
            vre_item_onglet_saisie_apex.attribute1            := vta_une_seule_periode(indx).attribute1;
            vre_item_onglet_saisie_apex.attribute2            := vta_une_seule_periode(indx).attribute2;
            --          
            vta_item_onglet_saisie_apex(vta_item_onglet_saisie_apex.last) := vre_item_onglet_saisie_apex;
          end if;
        end loop traiter_onglet_une_seule_periode;
      end if;
    else
      -- La personne fait la saisie d'intervention 
      open cur_periode_dans_mois_et_autre;
      fetch cur_periode_dans_mois_et_autre bulk collect
        into vta_periode_dans_mois_et_autre;
      close cur_periode_dans_mois_et_autre;
      <<traiter_onglet_intervention>>
      if vta_periode_dans_mois_et_autre.count > 0 Then
        for indx in vta_periode_dans_mois_et_autre.first .. vta_periode_dans_mois_et_autre.last loop
          --       
          if vta_periode_dans_mois_et_autre.exists(indx) then
            vta_item_onglet_saisie_apex.extend;
            vre_item_onglet_saisie_apex := f_traiter_onglet_intervention(vta_periode_dans_mois_et_autre(indx),
                                                                         indx,
                                                                         pdt_dt_debut_periode,
                                                                         pdt_dt_fin_periode);
            --          
            vta_item_onglet_saisie_apex(vta_item_onglet_saisie_apex.last) := vre_item_onglet_saisie_apex;
          end if;
        end loop traiter_onglet_intervention;
      end if;
    end if;
    --
    --
    --
    <<retourner_le_menu>>
    for indx in vta_item_onglet_saisie_apex.first .. vta_item_onglet_saisie_apex.last loop
      --
      pipe row(vta_item_onglet_saisie_apex(indx));
      --
    end loop retourner_le_menu;
    --   
    --
    -- -------------------------------------------------------------------------------------------------
    --                                           logger
    -- -------------------------------------------------------------------------------------------------
    logger.log_info(p_text   => 'Fin f_obtenir_item_onglet_saisie ',
                    p_scope  => vva_scope,
                    p_params => vta_params);
    --
    --
  exception
    when others then
      apex_debug.info('Exception f_obtenir_item_onglet_saisie %s', sqlerrm);
      raise;
      --
  end f_obtenir_item_onglet_saisie;
  --
  -- Proc?dure qui transmet la fdt
  --
  procedure transmettre_fdt_et_creer_suivante(pnu_no_seq_ressource in fdtt_feuilles_temps.no_seq_ressource%type,
                                              pva_an_mois_fdt      in fdtt_feuilles_temps.an_mois_fdt%type) is
    --
    cursor cur_suivi_existant(p_no_seq_feuil_temps in fdtt_feuilles_temps.no_seq_feuil_temps%type) is
      select max(suivi.no_seq_suivi_fdt) as no_seq_suivi_fdt
        from fdtt_suivi_feuilles_temps suivi
       where suivi.no_seq_feuil_temps = p_no_seq_feuil_temps;
    rec_suivi_existant cur_suivi_existant%rowtype;
    --
    vda_dern_jour_mois     date := last_day(to_date(pva_an_mois_fdt, 'yyyymm'));
    vnu_H_MIN_FIN_MOIS_HV  number := utl_fnb_cnv_minute(pil_fnb_obt_param_global('H_MIN_FIN_MOIS_HV',
                                                                                 vda_dern_jour_mois));
    vnu_H_MAX_FIN_MOIS_HV  number := utl_fnb_cnv_minute(pil_fnb_obt_param_global('H_MAX_FIN_MOIS_HV',
                                                                                 vda_dern_jour_mois));
    vva_co_coupure_traitee varchar2(1);
    -- Diff?rentes variable pour le retour de la proc?dure de calcul des totauz pour une fdt
    vnu_no_seq_feuil_temps                 fdtt_feuilles_temps.no_seq_feuil_temps%type;
    vnu_co_employe_shq                     busv_info_employe.co_employe_shq%type;
    vva_co_interne_exter                   busv_info_employe.co_interne_exter%type;
    vnu_solde_reporte                      fdtt_feuilles_temps.solde_reporte%type;
    vnu_corr_mois_preced                   fdtt_feuilles_temps.corr_mois_preced%type;
    vnu_total_temps_saisi                  fdtt_feuilles_temps.heure_reglr%type;
    vnu_total_credit_horaire               fdtt_feuilles_temps.credt_utls%type;
    vnu_total_activite_sauf_credit_horaire fdtt_feuilles_temps.heure_autre_absence%type;
    vnu_norme                              fdtt_feuilles_temps.norme%type;
    vnu_solde_periode_calc                 fdtt_feuilles_temps.solde_periode%type;
    vnu_in_coupure                         fdtt_feuilles_temps.nb_min_coupure%type;
    vnu_ecart                              fdtt_feuilles_temps.ecart%type;
    --
  begin
    --
    -- Appel proc?dure pour obtenir les diff?rents totaux pour la fdt
    fdt_prb_apx_calculer_totaux_feuille_temps(pnu_no_seq_ressource,
                                              pva_an_mois_fdt,
                                              vnu_no_seq_feuil_temps,
                                              vnu_co_employe_shq,
                                              vva_co_interne_exter,
                                              vnu_solde_reporte,
                                              vnu_corr_mois_preced,
                                              vnu_total_temps_saisi,
                                              vnu_total_credit_horaire,
                                              vnu_total_activite_sauf_credit_horaire,
                                              vnu_norme,
                                              vnu_ecart,
                                              vnu_solde_periode_calc);
    --
    vva_co_coupure_traitee := null;
    if vva_co_interne_exter = 'I' then
      if vnu_solde_periode_calc < utl_fnb_cnv_minute(pil_fnb_obt_param_global('H_MIN_FIN_MOIS_HV')) then
        vnu_in_coupure := vnu_solde_periode_calc -
                          utl_fnb_cnv_minute(pil_fnb_obt_param_global('H_MIN_FIN_MOIS_HV'));
        if vnu_in_coupure <> 0 then
          vva_co_coupure_traitee := 'N';
        end if;
      end if;
    end if;
    --
    -- Mettre ? jour la feuille de temps qu'on vient de transmettre
    update fdtt_feuilles_temps
       set ind_saisie_autorisee = 'N',
           heure_reglr          = vnu_total_temps_saisi,
           credt_utls           = decode(vva_co_interne_exter, 'I', vnu_total_credit_horaire, 0),
           heure_autre_absence  = decode(vva_co_interne_exter, 'I', vnu_total_activite_sauf_credit_horaire, 0),
           ecart                = decode(vva_co_interne_exter, 'I', vnu_ecart, 0),
           norme                = decode(vva_co_interne_exter, 'I', vnu_norme, 0),
           solde_periode        = vnu_solde_periode_calc,
           NB_MIN_COUPURE       = nvl(vnu_in_coupure, 0),
           co_coupure_traitee   = vva_co_coupure_traitee
     where NO_SEQ_FEUIL_TEMPS = vnu_no_seq_feuil_temps;
    -- 
    -- On regarde si la fdt suivante existe (dans le cas o? il y a eu une erreur et la fdt a ?t? mise en correction).  
    -- S'il y a un suivi existant, nous sommes dans cette situation.
    --
    open cur_suivi_existant(vnu_no_seq_feuil_temps);
    fetch cur_suivi_existant
      into rec_suivi_existant;
    close cur_suivi_existant;
    --
    -- Mettre ? jour le suivi feuille de temps pour ce mois.
    insert into fdtt_suivi_feuilles_temps
      (no_seq_suivi_fdt, NO_SEQ_FEUIL_TEMPS, an_mois_fdt, co_typ_suivi_fdt, dh_suivi_fdt)
    values
      (FDTSFTEMPS_SEQ.nextval,
       vnu_no_seq_feuil_temps,
       pva_an_mois_fdt,
       'TRANS',
       utl_fnb_obt_dt_prodc('FDT', 'DS'));
    --
    -- Si le total est plus plus petit ou plus grand que les plages d'heures permises, on met la valeur au minimum ou au maximum.
    -- Acuellement le minimum est -7 heures et le maximum est 14 heures.
    -- On va mettre le calcul dans le solde_reporte de la fdt du mois suivant.
    if vnu_solde_periode_calc > vnu_H_MAX_FIN_MOIS_HV then
      vnu_solde_periode_calc := vnu_H_MAX_FIN_MOIS_HV;
    else
      if vnu_solde_periode_calc < vnu_H_MIN_FIN_MOIS_HV then
        vnu_solde_periode_calc := vnu_H_MIN_FIN_MOIS_HV;
      end if;
    end if;
    --
    --
    --DBMS_OUTPUT.PUT_LINE('avant le if rec_suivi_existant.no_seq_suivi_fdt : '||rec_suivi_existant.no_seq_suivi_fdt);
    if rec_suivi_existant.no_seq_suivi_fdt is not null then
      -- On fait la maj du solde report? de la fdt suivant ce mois.
      update fdtt_feuilles_temps
         set solde_reporte = decode(vva_co_interne_exter, 'I', vnu_solde_periode_calc, 0)
       where no_seq_ressource = pnu_no_seq_ressource
         and an_mois_fdt = to_char(add_months(to_date(pva_an_mois_fdt, 'yyyymm'), 1), 'yyyymm')
         and solde_reporte <> vnu_solde_periode_calc;
    else
      -- Il n'y a aucun suivi, donc c'est la premi?re transmission de cette fdt.  Il faut donc cr?er la fdt suivante.
      FDT_PRB_APX_CREER_FEUILLE_TEMPS(vnu_co_employe_shq,
                                      pva_an_mois_fdt, -- La proc?dure ajoute un mois au param?tre pour cr?er la fdt suivante
                                      vnu_solde_periode_calc);
    end if;
    --                           
    --:P12_PERIODES := NULL;   -- ???? ? voir
    --                  
  end transmettre_fdt_et_creer_suivante;
  ---------------------------------------------------------------------- 
  -- Permet de r?cup?rer les diff?rentes plages pour la saisie des heures  
  ---------------------------------------------------------------------- 
  procedure p_obtenir_plages_saisie_heures_ajax is
    -- curseur pour aller chercher les diff?rents dates
    /*cursor cur_plage_heure is
       select pg.co_parametre_g, pg.val_parametre_g
       from pilt_valeur_parametre_global pg
       where pg.co_parametre_g in ('H_PLAGE_DEB_AM_MIN',
                                   'H_PLAGE_DEB_AM_MAX',
                                   'H_PLAGE_FIN_AM_MIN',
                                   'H_PLAGE_FIN_AM_MAX',
                                   'H_PLAGE_DEB_PM_MIN',
                                   'H_PLAGE_DEB_PM_MAX',
                                   'H_PLAGE_FIN_PM_MIN',
                                   'H_PLAGE_FIN_PM_MAX')
         and (pg.dt_fin_parametre_g is null or pg.dt_fin_parametre_g >= utl_fnb_obt_dt_prodc('FDT','DA'));
    rec_plage_heure cur_plage_heure%rowtype; */
    -- Nom du fichier Json
    cva_objet_saisie_heure constant varchar2(20) := 'plages_saisie_heure';
    vdt_date_jour date := utl_fnb_obt_dt_prodc('FDT', 'DA');
  begin
    apex_json.initialize_output;
    apex_json.open_object();
    apex_json.open_object(cva_objet_saisie_heure);
    apex_json.write('H_PLAGE_DEB_AM_MIN', pil_fnb_obt_param_global('H_PLAGE_DEB_AM_MIN', vdt_date_jour));
    apex_json.write('H_PLAGE_DEB_AM_MAX', pil_fnb_obt_param_global('H_PLAGE_DEB_AM_MAX', vdt_date_jour));
    apex_json.write('H_PLAGE_FIN_AM_MIN', pil_fnb_obt_param_global('H_PLAGE_FIN_AM_MIN', vdt_date_jour));
    apex_json.write('H_PLAGE_FIN_AM_MAX', pil_fnb_obt_param_global('H_PLAGE_FIN_AM_MAX', vdt_date_jour));
    apex_json.write('H_PLAGE_DEB_PM_MIN', pil_fnb_obt_param_global('H_PLAGE_DEB_PM_MIN', vdt_date_jour));
    apex_json.write('H_PLAGE_DEB_PM_MAX', pil_fnb_obt_param_global('H_PLAGE_DEB_PM_MAX', vdt_date_jour));
    apex_json.write('H_PLAGE_FIN_PM_MIN', pil_fnb_obt_param_global('H_PLAGE_FIN_PM_MIN', vdt_date_jour));
    apex_json.write('H_PLAGE_FIN_PM_MAX', pil_fnb_obt_param_global('H_PLAGE_FIN_PM_MAX', vdt_date_jour));
    apex_json.close_all;
    --  
  end p_obtenir_plages_saisie_heures_ajax;
  ---------------------------------------------------------------------------------------------- 
  -- Permet de valider que la fdt pr?c?dente a ?t? approuv?e avant de transmettre celle en cours  
  ---------------------------------------------------------------------------------------------- 
  procedure valider_si_fdt_precedente_approuvee(pnu_no_seq_ressource in fdtt_feuilles_temps.no_seq_ressource%type,
                                                pva_an_mois_fdt      in fdtt_feuilles_temps.an_mois_fdt%type) is
    -- D?claration de variables
    vnu_nombre number;
    --vva_message varchar2(4000);
  begin
    select count(*)
      into vnu_nombre
      from fdtt_feuilles_temps ft
     where ft.no_seq_ressource = pnu_no_seq_ressource
       and ft.an_mois_fdt < pva_an_mois_fdt
       and not exists (select fdt.no_seq_suivi_fdt
              from fdtt_suivi_feuilles_temps fdt
             where fdt.no_seq_feuil_temps = ft.no_seq_feuil_temps
               and fdt.co_typ_suivi_fdt in ('APPR_GESTI'));
    --
    if vnu_nombre > 0 then
      vva_message := utl_pkb_message.fc_obt_message('FDT.000031');
      apex_error.add_error(vva_message, null, apex_error.c_inline_in_notification);
      --return utl_pkb_message.fc_obt_message('FDT.000031');
    end if;
  end valider_si_fdt_precedente_approuvee;
  -------------------------------------------------------------------------------------------------
  -- Permet de calculer la diff?rence de temps d'une journ?e pour une fdt (inclu la saisie du temps
  -- et les activit?s saisies)
  -------------------------------------------------------------------------------------------------
  function f_obtenir_difference_temps(pnu_no_seq_feuil_temps in fdtt_feuilles_temps.no_seq_feuil_temps%type,
                                      pdt_date_en_saisie     in date,
                                      pnu_no_seq_ressource   in fdtt_feuilles_temps.no_seq_ressource%type)
    return number is
    -- Curseur pour aller chercher les heures saisies pour cette journ?e
    cursor cur_obtenir_temps_saisi is
      select tj.dh_debut_am_temps, tj.dh_fin_am_temps, tj.dh_debut_pm_temps, tj.dh_fin_pm_temps
        from fdtt_temps_jours tj
       where tj.no_seq_feuil_temps = pnu_no_seq_feuil_temps
         and tj.dt_temps_jour = pdt_date_en_saisie
         and tj.no_seq_activite is null;
    rec_obtenir_temps_saisi cur_obtenir_temps_saisi%rowtype;
    -- Curseur pour aller chercher les heures saisies pour cette journ?e
    cursor cur_obtenir_temps_activite_saisi is
      with act_credit_horaire as
       (select act.no_seq_activite
          from fdtt_activites act
         where act.acronyme = '122')
      select sum(tj.total_temps_min) as total_activite_temps_min
        from fdtt_temps_jours tj, act_credit_horaire
       where tj.no_seq_feuil_temps = pnu_no_seq_feuil_temps
         and tj.dt_temps_jour = pdt_date_en_saisie
         and (tj.no_seq_activite is not null and tj.no_seq_activite != act_credit_horaire.no_seq_activite);
    rec_obtenir_temps_activite_saisi cur_obtenir_temps_activite_saisi%rowtype;
    --
    -- Curseur obtenir total du temps cr?dit horaire pour cette journ?e 
    cursor cur_obt_temps_credit_horaire_jour is
      with act_credit as
       (select act.no_seq_activite
          from fdtt_activites act
         where act.acronyme = '122'),
      temps_saisi as
       (select tjo.dt_temps_jour, tjo.total_temps_min
          from fdtt_temps_jours tjo
         where tjo.no_seq_feuil_temps = pnu_no_seq_feuil_temps
           and tjo.dt_temps_jour = pdt_date_en_saisie
           and tjo.no_seq_activite is null)
      select tj.total_temps_min as total_temps_credit_horaire
        from fdtt_temps_jours tj, act_credit ac, temps_saisi sai
       where tj.no_seq_feuil_temps = pnu_no_seq_feuil_temps
         and tj.no_seq_activite = ac.no_seq_activite
         and tj.dt_temps_jour = pdt_date_en_saisie
         and sai.dt_temps_jour = tj.dt_temps_jour
         and sai.total_temps_min = 0;
    rec_obt_temps_credit_horaire_jour cur_obt_temps_credit_horaire_jour%rowtype;
    -- 
    vnu_debut_am_en_min           number(4);
    vnu_fin_am_en_min             number(4);
    vnu_nb_minutes_heure_saisi_am number(4);
    vnu_debut_pm_en_min           number(4);
    vnu_fin_pm_en_min             number(4);
    vnu_nb_minutes_heure_saisi_pm number(4);
    --
    vnu_total_temps_activite number(4);
    --    
    vnu_nb_minute_utilisateur number(4);
    vnu_nb_minute_jour_total  number(4);
    vnu_difference            number(4);
    --
  begin
    open cur_obtenir_temps_saisi;
    fetch cur_obtenir_temps_saisi
      into rec_obtenir_temps_saisi;
    close cur_obtenir_temps_saisi;
    -- 
    open cur_obtenir_temps_activite_saisi;
    fetch cur_obtenir_temps_activite_saisi
      into rec_obtenir_temps_activite_saisi;
    close cur_obtenir_temps_activite_saisi;
    vnu_nb_minutes_heure_saisi_am := 0;
    vnu_nb_minutes_heure_saisi_pm := 0;
    -- On fait le total pour la journ?e
    if rec_obtenir_temps_saisi.dh_debut_am_temps is not null and
       rec_obtenir_temps_saisi.dh_fin_am_temps is not null then
      -- Les 2 heures am saisies, on peut faire le calcul.
      vnu_debut_am_en_min           := utl_fnb_cnv_minute(to_char(rec_obtenir_temps_saisi.dh_debut_am_temps,
                                                                  'HH24:MI'));
      vnu_fin_am_en_min             := utl_fnb_cnv_minute(to_char(rec_obtenir_temps_saisi.dh_fin_am_temps,
                                                                  'HH24:MI'));
      vnu_nb_minutes_heure_saisi_am := vnu_fin_am_en_min - vnu_debut_am_en_min;
    end if;
    --
    if rec_obtenir_temps_saisi.dh_debut_pm_temps is not null and
       rec_obtenir_temps_saisi.dh_fin_pm_temps is not null then
      -- Les 2 heures am saisies, on peut faire le calcul.
      vnu_debut_pm_en_min           := utl_fnb_cnv_minute(to_char(rec_obtenir_temps_saisi.dh_debut_pm_temps,
                                                                  'HH24:MI'));
      vnu_fin_pm_en_min             := utl_fnb_cnv_minute(to_char(rec_obtenir_temps_saisi.dh_fin_pm_temps,
                                                                  'HH24:MI'));
      vnu_nb_minutes_heure_saisi_pm := vnu_fin_pm_en_min - vnu_debut_pm_en_min;
    end if;
    if rec_obtenir_temps_activite_saisi.total_activite_temps_min is not null then
      vnu_total_temps_activite := rec_obtenir_temps_activite_saisi.total_activite_temps_min;
    else
      vnu_total_temps_activite := 0;
    end if;
    --
    vnu_nb_minute_jour_total := vnu_nb_minutes_heure_saisi_am + vnu_nb_minutes_heure_saisi_pm +
                                vnu_total_temps_activite;
    --  On va chercher le nombre de minutes que doit faire l'utilisateur
    --vnu_nb_minute_utilisateur := fdt_fnb_apx_obt_nb_minutes_usager(pnu_no_seq_ressource, last_day(pdt_date_en_saisie));
    vnu_nb_minute_utilisateur := fdt_fnb_apx_obt_nb_minutes_usager(pnu_no_seq_ressource, pdt_date_en_saisie);
    -- S'il n'y a aucune saisie de temps ni activit? pour une journ?e on retourne null
    if coalesce(vnu_nb_minute_jour_total, 0) <> 0 then
      vnu_difference := vnu_nb_minute_jour_total - vnu_nb_minute_utilisateur;
    else
      -- On va voir si il y a seulement du cr?dit horaire de saisi pour cette journ?e
      open cur_obt_temps_credit_horaire_jour;
      fetch cur_obt_temps_credit_horaire_jour
        into rec_obt_temps_credit_horaire_jour;
      close cur_obt_temps_credit_horaire_jour;
      if coalesce(rec_obt_temps_credit_horaire_jour.total_temps_credit_horaire, 0) > 0 then
        --
        if rec_obt_temps_credit_horaire_jour.total_temps_credit_horaire = vnu_nb_minute_utilisateur then
          -- Journ?e compl?te cr?dit horaire
          vnu_difference := vnu_nb_minute_jour_total - vnu_nb_minute_utilisateur;
        else
          -- Journ?e avec un cr?dit horaire partiel sans heures de saisies.
          vnu_difference := rec_obt_temps_credit_horaire_jour.total_temps_credit_horaire -
                            vnu_nb_minute_utilisateur;
        end if;
      end if;
    end if;
    --
    return vnu_difference;
  end f_obtenir_difference_temps;
  ---------------------------------------------------------------------------------------------- 
  -- Permet d'obtenir les diff?rents donn?es associ?es ? la fdt en cours  
  ----------------------------------------------------------------------------------------------  
  procedure p_initialiser_champs_fdt(pnu_no_seq_ressource        in fdtt_feuilles_temps.no_seq_ressource%type,
                                     pva_an_mois_fdt             in fdtt_feuilles_temps.an_mois_fdt%type,
                                     pva_ressource_saisi_intrv   in varchar2,
                                     pnu_no_seq_feuil_temps      out fdtt_feuilles_temps.no_seq_feuil_temps%type,
                                     pva_corr_mois_preced        out varchar2,
                                     pva_note_corr_mois_preced   out fdtt_feuilles_temps.note_corr_mois_preced%type,
                                     pva_solde_reporte           out varchar2,
                                     pnu_credit_annuel122        out number,
                                     pva_solde_courant           out varchar2,
                                     pdt_date_debut_periode      in out date,
                                     pdt_date_fin_periode        in out date,
                                     pva_temps_absence_fdt       out varchar2,
                                     pva_temps_total_sagir       out varchar2,
                                     pva_total_periode           out varchar2,
                                     pva_ind_mois_complet_interv out varchar2,
                                     pva_statut                  out varchar2) is
    -- D?claration des variables
    cdt_da_systeme_fdt date := utl_fnb_obt_dt_prodc(pva_co_systeme => 'FDT', pva_form_date => 'DA');
    --
    cursor cur_obtenir_infos_fdt is
      with temps as
       (select max(tj.no_seq_feuil_temps) as no_seq_feuil_temps,
               sum(tj.total_temps_min) as total_temps_min_journee,
               max(FDT_FNB_APX_OBT_NB_MINUTES_USAGER(fdt.no_seq_ressource, tj.dt_temps_jour)) as temps_jour_normal,
               tj.dt_temps_jour as date_du_jour
          from fdtt_temps_jours tj,
               fdtt_feuilles_temps fdt,
               (select act.no_seq_activite
                  from fdtt_activites act
                 where act.acronyme = '122') act_credit
         where fdt.no_seq_ressource = pnu_no_seq_ressource
           and fdt.an_mois_fdt = pva_an_mois_fdt
           and tj.no_seq_feuil_temps = fdt.no_seq_feuil_temps
           and tj.total_temps_min > 0
           and (tj.no_seq_activite is null or tj.no_seq_activite != act_credit.no_seq_activite)
         group by tj.dt_temps_jour)
      select ft.no_seq_feuil_temps as no_seq_feuil_temps,
             decode(ft.CORR_MOIS_PRECED,
                    '0',
                    null,
                    fdt_pkb_apx_util_temps.convert_format_heure(ft.CORR_MOIS_PRECED)) as corr_mois_preced,
             ft.NOTE_CORR_MOIS_PRECED as NOTE_CORR_MOIS_PRECED,
             fdt_pkb_apx_util_temps.convert_format_heure(ft.SOLDE_REPORTE) as SOLDE_REPORTE,
             fdt_fnb_apx_obt_cred_hor_an_usager(last_day(to_date(ft.an_mois_fdt || '01', 'YYYYMMDD')),
                                                ft.no_seq_ressource) as CREDIT_ANNUEL122,
             --fdt_pkb_apx_util_temps.convert_format_heure(coalesce(t1.differenceTemps,0) + coalesce(ft.SOLDE_REPORTE,0) + coalesce(ft.CORR_MOIS_PRECED,0)) as solde_courant
             (coalesce(t1.differenceTemps, 0) + coalesce(ft.SOLDE_REPORTE, 0) +
             coalesce(ft.CORR_MOIS_PRECED, 0)) as solde_courant_minutes
        from fdtt_feuilles_temps ft,
             (select sum(temps.total_temps_min_journee) - sum(temps.temps_jour_normal) as differenceTemps,
                     max(temps.no_seq_feuil_temps) as no_seq_feuil_temps
                from temps) t1
       where ft.no_seq_ressource = pnu_no_seq_ressource
         and ft.an_mois_fdt = pva_an_mois_fdt
         and t1.no_seq_feuil_temps(+) = ft.no_seq_feuil_temps;
    rec_obtenir_infos_fdt cur_obtenir_infos_fdt%rowtype;
    --
      --
      /*cursor cur_periodes is
        with jour_ouvrable as (select tj.dt_temps_jour as jo, TO_CHAR(tj.dt_temps_jour,'iw') as semaineAnnuelle
                        from fdtt_temps_jours tj,
                             fdtt_feuilles_temps fdt   
                        where fdt.no_seq_ressource  = pnu_no_seq_ressource
                          and fdt.an_mois_fdt       = pva_an_mois_fdt
                          and tj.no_seq_feuil_temps = fdt.no_seq_feuil_temps)
         select jour_debut_periode, jour_fin_periode
         from (select min(jourO.jo) as jour_debut_periode,
                      max(jourO.jo) as jour_fin_periode 
               from jour_ouvrable jourO
               group by jourO.semaineAnnuelle
               order by 1) t1
         where cdt_da_systeme_fdt BETWEEN t1.jour_debut_periode and t1.jour_fin_periode
         union all
         select jour_debut_periode, jour_fin_periode
         from (select max(jour_debut_periode) as jour_debut_periode, max(jour_fin_periode) as jour_fin_periode 
               from (select min(jourO.jo) as jour_debut_periode,
                             max(jourO.jo) as jour_fin_periode 
                     from jour_ouvrable jourO
                     group by jourO.semaineAnnuelle
                     order by 1) t2
               where cdt_da_systeme_fdt > jour_fin_periode)
         where jour_debut_periode is not null;*/
      cursor cur_periodes is 
         select jour_debut_periode, jour_fin_periode, semaine_annuelle  
         from (
            with jour_ouvrable as (select to_date(pva_an_mois_fdt || to_char(journee.jour, '00') , 'yyyymmdd') as jo, 
                                          TO_CHAR(to_date(pva_an_mois_fdt || to_char(journee.jour, '00') , 'yyyymmdd'),'iw') as semaineAnnuelle
                                   from (select rownum as jour 
                                         from busv_info_employe 
                                         where rownum <= to_number(to_char(last_day(to_date(to_char(to_date(pva_an_mois_fdt || '01','yyyymmdd'),'yyyymm'), 'yyyymm')), 'dd'))) journee)
            select min(jourO.jo) as jour_debut_periode,
                   max(jourO.jo) as jour_fin_periode, 
                   decode(jourO.semaineAnnuelle,'52','00',jourO.semaineAnnuelle) as semaine_annuelle,
                   min(to_char(jourO.jo, 'dd')) || ' au ' || max(to_char(jourO.jo, 'dd')) || ' ' || max(to_char(jourO.jo, 'Month')) as libelle
            from jour_ouvrable jourO
            group by jourO.semaineAnnuelle)
        where  cdt_da_systeme_fdt   between jour_debut_periode and jour_fin_periode
        union all
        select jour_debut_periode, jour_fin_periode, semaine_annuelle 
        from (
              with jour_ouvrable as (select to_date(pva_an_mois_fdt || to_char(journee.jour, '00') , 'yyyymmdd') as jo, 
                                            TO_CHAR(to_date(pva_an_mois_fdt || to_char(journee.jour, '00') , 'yyyymmdd'),'iw') as semaineAnnuelle
                                     from (select rownum as jour 
                                           from busv_info_employe 
                                           where rownum <= to_number(to_char(last_day(to_date(to_char(to_date(pva_an_mois_fdt || '01','yyyymmdd'),'yyyymm'), 'yyyymm')), 'dd'))) journee)
              select min(jourO.jo) as jour_debut_periode,
                     max(jourO.jo) as jour_fin_periode, 
                     decode(jourO.semaineAnnuelle,'52','00',jourO.semaineAnnuelle) as semaine_annuelle,
                     min(to_char(jourO.jo, 'dd')) || ' au ' || max(to_char(jourO.jo, 'dd')) || ' ' || max(to_char(jourO.jo, 'Month')) as libelle
              from jour_ouvrable jourO
              group by jourO.semaineAnnuelle) 
        where cdt_da_systeme_fdt > last_day(to_date(to_char(to_date(pva_an_mois_fdt || '01','yyyymmdd'),'yyyymm'), 'yyyymm'))
          and jour_fin_periode = last_day(to_date(to_char(to_date(pva_an_mois_fdt || '01','yyyymmdd'),'yyyymm'), 'yyyymm'));
      vrec_periodes cur_periodes%rowtype;
    --
    -- Curseur pour aller chercher les heures activit?es saisies pour cette fdt (mois complet)
    cursor cur_obt_temps_activite_saisi_fdt is
      with act_ferie as
       (select act.no_seq_activite
          from fdtt_activites act
         where act.acronyme = '100')
      select sum(tj.total_temps_min) as total_temps_activite_mois
        from fdtt_temps_jours tj, act_ferie ferie
       where tj.no_seq_feuil_temps = pnu_no_seq_feuil_temps
         and (tj.no_seq_activite is not null and tj.no_seq_activite <> ferie.no_seq_activite);
    rec_obt_temps_activite_saisi_fdt cur_obt_temps_activite_saisi_fdt%rowtype;
    -- Curseur pour aller chercher le temps total pour cette fdt (mois complet)
    cursor cur_obt_total_temps_externe is
      select sum(tj.total_temps_min) as total_temps_periode_externe
        from fdtt_temps_jours tj
       where tj.no_seq_feuil_temps = pnu_no_seq_feuil_temps;
    rec_obt_total_temps_externe cur_obt_total_temps_externe%rowtype;
    --
    -- Curseur obtenir total du temps cr?dit horaire pour le mois 
    cursor cur_obt_temps_credit_horaire is
      with act_credit as
       (select act.no_seq_activite
          from fdtt_activites act
         where act.acronyme = '122'),
      temps_saisi as
       (select tjo.dt_temps_jour, tjo.total_temps_min
          from fdtt_temps_jours tjo
         where tjo.no_seq_feuil_temps = pnu_no_seq_feuil_temps
           and tjo.no_seq_activite is null)
      select sum(tj.total_temps_min) as total_temps_credit_horaire
        from fdtt_temps_jours tj, act_credit ac, temps_saisi sai
       where tj.no_seq_feuil_temps = pnu_no_seq_feuil_temps
         and tj.no_seq_activite = ac.no_seq_activite
         and sai.dt_temps_jour = tj.dt_temps_jour
         and sai.total_temps_min = 0;
    rec_obt_temps_credit_horaire cur_obt_temps_credit_horaire%rowtype;
    --
    cursor cur_obtenir_statut(pva_an_mois in varchar2) is
      select decode(suivi.co_typ_suivi_fdt, 'A_CORRIGER', '? corriger') as statutFdt
      from fdtt_suivi_feuilles_temps suivi, fdtt_feuilles_temps fdt
      where fdt.no_seq_ressource = pnu_no_seq_ressource
        and fdt.an_mois_fdt      = pva_an_mois_fdt
        and suivi.no_seq_feuil_temps = fdt.no_seq_feuil_temps
        and suivi.dh_suivi_fdt in (select max(sft.dh_suivi_fdt)
                                   from fdtt_suivi_feuilles_temps sft
                                   where sft.no_seq_feuil_temps = suivi.no_seq_feuil_temps
                                     and sft.an_mois_fdt = pva_an_mois_fdt);
    rec_obtenir_statut cur_obtenir_statut%rowtype;
    --
  begin
    --
    open cur_obtenir_infos_fdt;
    fetch cur_obtenir_infos_fdt
      into rec_obtenir_infos_fdt;
    close cur_obtenir_infos_fdt;
    --
    pnu_no_seq_feuil_temps    := rec_obtenir_infos_fdt.no_seq_feuil_temps;
    pva_corr_mois_preced      := rec_obtenir_infos_fdt.corr_mois_preced;
    pva_note_corr_mois_preced := rec_obtenir_infos_fdt.note_corr_mois_preced;
    pva_solde_reporte         := rec_obtenir_infos_fdt.solde_reporte; -- Solde report? sous forme de HH:MI
    pnu_credit_annuel122      := rec_obtenir_infos_fdt.credit_annuel122;
    -- On ajoute la corr_mois_preced dans le solde actuel
    --
    open cur_obt_temps_credit_horaire;
    fetch cur_obt_temps_credit_horaire
      into rec_obt_temps_credit_horaire;
    close cur_obt_temps_credit_horaire;
    --      
    pva_solde_courant := fdt_pkb_apx_util_temps.convert_format_heure(rec_obtenir_infos_fdt.solde_courant_minutes -
                                                                     coalesce(rec_obt_temps_credit_horaire.total_temps_credit_horaire,
                                                                              0));
    --pva_solde_courant         := rec_obtenir_infos_fdt.solde_courant;  -- Solde courant sous forme de HH:MI 
    -- Temps total par la p?riode 
    open cur_obt_total_temps_externe;
    fetch cur_obt_total_temps_externe
      into rec_obt_total_temps_externe;
    close cur_obt_total_temps_externe;
    pva_total_periode := fdt_pkb_apx_util_temps.convert_format_heure(coalesce(rec_obt_total_temps_externe.total_temps_periode_externe,
                                                                              0));
    -- 
    -- On va chercher les deux dates pour l'affichage des onglets dans la r?gion de la saisie FDT
    --apex_debug.message('shcge p_initialiser_champs_fdt');
    -- Si le nom de la date d?but de p?riode est diff?rente du an_mois_fdt, ?a veut dire que l'utilisateur
    -- a s?lectionn? une autre p?riode dans le select list de la page 2 (Pour corriger la fdt ant?rieure)
    if pdt_date_debut_periode is null  or to_char(pdt_date_debut_periode,'MM') <> substr(pva_an_mois_fdt,5,2) then
      if pva_ressource_saisi_intrv = 'O' then
        /*if to_char(cdt_da_systeme_fdt, 'D') = '6' or to_char(cdt_da_systeme_fdt, 'D') = '7' then
          -- On enl?ve 2 jours ? la date du jour pour afficher les donn?es de la p?riode de cette semaine 
          if to_char(cdt_da_systeme_fdt, 'D') = '6' then
            cdt_da_systeme_fdt := cdt_da_systeme_fdt - 1;
          end if;
          if to_char(cdt_da_systeme_fdt, 'D') = '7' then
            cdt_da_systeme_fdt := cdt_da_systeme_fdt - 2;
          end if;
        end if;*/
        open cur_periodes;
        fetch cur_periodes
          into vrec_periodes;
        close cur_periodes;
        --
        pdt_date_debut_periode := vrec_periodes.jour_debut_periode;
        pdt_date_fin_periode   := vrec_periodes.jour_fin_periode;
      else
        -- La personne ne saisi pas d'intervention, on affiche le mois au complet
        pdt_date_debut_periode := to_date(pva_an_mois_fdt || '01', 'YYYYMMDD');
        pdt_date_fin_periode   := last_day(to_date(pva_an_mois_fdt || '01', 'YYYYMMDD'));
      end if;
    end if;
    pva_ind_mois_complet_interv := f_obtenir_ind_mois_complet_intervention(pva_an_mois_fdt,
                                                                           pdt_date_debut_periode,
                                                                           pdt_date_fin_periode);
    -- On va chercher le total des activit?s saisies dans FDT.
    open cur_obt_temps_activite_saisi_fdt;
    fetch cur_obt_temps_activite_saisi_fdt
      into rec_obt_temps_activite_saisi_fdt;
    close cur_obt_temps_activite_saisi_fdt;
    pva_temps_absence_fdt := fdt_pkb_apx_util_temps.convert_format_heure(coalesce(rec_obt_temps_activite_saisi_fdt.total_temps_activite_mois,
                                                                                  0));
    -- Sagir ? venir ...
    pva_temps_total_sagir := '00:00';
    -- 
    open cur_obtenir_statut(pva_an_mois_fdt);
      fetch cur_obtenir_statut
        into rec_obtenir_statut;
      close cur_obtenir_statut;
      -- 
      pva_statut := rec_obtenir_statut.statutFdt;
    --                      
  end p_initialiser_champs_fdt;
  ---------------------------------------------------------------------------------------------- 
  -- Permet d'obtenir la fdt courante de la ressource 
  ----------------------------------------------------------------------------------------------  
  procedure p_obtenir_fdt_actuelle(pnu_no_seq_ressource in fdtt_feuilles_temps.no_seq_ressource%type,
                                   pva_an_mois_fdt      out fdtt_feuilles_temps.an_mois_fdt%type) is
    -- D?claration des variables
    cursor cur_obtenir_fdt_actuelle is
      select nvl(max(to_char(to_date(an_mois_fdt, 'yyyymm'), 'yyyymm')),
                 to_char(utl_fnb_obt_dt_prodc('FDT', 'DS'), 'yyyymm')) as an_mois_fdt_actuel
        from fdtt_feuilles_temps
       where NO_SEQ_RESSOURCE = pnu_no_seq_ressource;
    rec_obtenir_fdt_actuelle cur_obtenir_fdt_actuelle%rowtype;
    --
  begin
    --
    open cur_obtenir_fdt_actuelle;
    fetch cur_obtenir_fdt_actuelle
      into rec_obtenir_fdt_actuelle;
    close cur_obtenir_fdt_actuelle;
    pva_an_mois_fdt := rec_obtenir_fdt_actuelle.an_mois_fdt_actuel;
    --                                                
  end p_obtenir_fdt_actuelle;
  ---------------------------------------------------------------------------------------------- 
  -- Permet d'obtenir la fdt courante de la ressource 
  ---------------------------------------------------------------------------------------------- 
  procedure p_creer_ou_maj_absence(pnu_no_seq_temps_jour     in fdtt_temps_jours.no_seq_temps_jour%type,
                                   pnu_no_seq_feuil_temps    in fdtt_temps_jours.no_seq_feuil_temps%type,
                                   pnu_no_seq_activite       in fdtt_temps_jours.no_seq_activite%type,
                                   pdt_dt_temps_jour         in fdtt_temps_jours.dt_temps_jour%type,
                                   pva_heure_absence         in varchar2,
                                   pva_request               in varchar2,
                                   pva_an_mois_fdt           in fdtt_temps_jours.an_mois_fdt%type,
                                   pva_ressource_saisi_intrv in varchar2,
                                   pdt_dt_debut_periode      in date,
                                   pdt_dt_fin_periode        in date,
                                   pva_remarque              in varchar2) is
    -- D?claration des variables 
    vnu_no_seq_specialite_defaut fdtt_ressource_info_suppl.no_seq_specialite%type;
  begin
    --
    -- On traite l'insertion ou la maj du temps intervention associ? ? cette occurence
    -- On vient 
    vnu_no_seq_specialite_defaut := fdt_pkb_apx_010101.f_obtenir_specialite_ressource_pour_inter(pnu_no_seq_feuil_temps,
                                                                                                 pdt_dt_debut_periode,
                                                                                                 pdt_dt_fin_periode);
    if pva_ressource_saisi_intrv = 'O' then
      p_gerer_temps_interv_generique(pnu_no_seq_temps_jour,
                                     pnu_no_seq_feuil_temps,
                                     pnu_no_seq_activite,
                                     pdt_dt_temps_jour,
                                     pva_an_mois_fdt,
                                     pdt_dt_debut_periode,
                                     pdt_dt_fin_periode,
                                     pva_heure_absence,
                                     vnu_no_seq_specialite_defaut,
                                     pva_request);
    end if;
    --
    if pva_request = utl_pkb_apx_securite.f_obtenir_request_create or
       pva_request = utl_pkb_apx_securite.f_obtenir_request_create_add then
      -- On insert une nouvelles absences
      insert into fdtt_temps_jours
        (no_seq_temps_jour, no_seq_feuil_temps, no_seq_activite, dt_temps_jour, TOTAL_TEMPS_MIN, an_mois_fdt, remarque)
      VALUES
        (FDTTJOUR_SEQ.nextval,
         pnu_no_seq_feuil_temps,
         pnu_no_seq_activite,
         pdt_dt_temps_jour,
         utl_fnb_cnv_minute(pva_heure_absence),
         pva_an_mois_fdt,
         pva_remarque);
      --
    else
      if pva_request = utl_pkb_apx_securite.f_obtenir_request_save or
         pva_request = utl_pkb_apx_securite.f_obtenir_request_save_add then
        -- on fait la maj
        update fdtt_temps_jours
           set no_seq_activite = pnu_no_seq_activite,
               dt_temps_jour   = pdt_dt_temps_jour,
               TOTAL_TEMPS_MIN = utl_fnb_cnv_minute(pva_heure_absence),
               remarque        = pva_remarque
         where no_seq_temps_jour = pnu_no_seq_temps_jour;
      end if;
    end if;
  end p_creer_ou_maj_absence;
  ---------------------------------------------------------------------------------------------- 
  -- Permet de d?truire une absence
  ---------------------------------------------------------------------------------------------- 
  procedure p_detruire_absence(pnu_no_seq_temps_jour  in fdtt_temps_jours.no_seq_temps_jour%type,
                               pnu_no_seq_feuil_temps in fdtt_feuilles_temps.no_seq_feuil_temps%type,
                               pnu_no_seq_activite    in fdtt_temps_jours.no_seq_activite%type,
                               pdt_dt_temps_jour      in fdtt_temps_jours.dt_temps_jour%type,
                               pva_an_mois_fdt        in fdtt_feuilles_temps.an_mois_fdt%type,
                               pdt_dt_debut_periode   in date,
                               pdt_dt_fin_periode     in date,
                               pva_heure_absence      in varchar2,
                               pva_request            in varchar2) is
    -- D?claration des variables
    vnu_no_seq_specialite_defaut fdtt_ressource_info_suppl.no_seq_specialite%type;
  begin
    --
    if pva_request = utl_pkb_apx_securite.f_obtenir_request_delete then
      vnu_no_seq_specialite_defaut := fdt_pkb_apx_010101.f_obtenir_specialite_ressource_pour_inter(pnu_no_seq_feuil_temps,
                                                                                                   pdt_dt_debut_periode,
                                                                                                   pdt_dt_fin_periode);
      p_gerer_temps_interv_generique(pnu_no_seq_temps_jour,
                                     pnu_no_seq_feuil_temps,
                                     pnu_no_seq_activite,
                                     pdt_dt_temps_jour,
                                     pva_an_mois_fdt,
                                     pdt_dt_debut_periode,
                                     pdt_dt_fin_periode,
                                     pva_heure_absence,
                                     vnu_no_seq_specialite_defaut,
                                     pva_request);
      delete from fdtt_temps_jours tj
       where tj.no_seq_temps_jour = pnu_no_seq_temps_jour
         and tj.no_seq_activite is not null;
    end if;
  end p_detruire_absence;
  ---------------------------------------------------------------------------------------------- 
  -- Permet de faire la maj de la grid de saisie
  ---------------------------------------------------------------------------------------------- 
  procedure p_maj_temps_jour(pnu_no_seq_temps_jour    in fdtt_temps_jours.no_seq_temps_jour%type,
                             pdt_dt_temps_jour        in fdtt_temps_jours.dt_temps_jour%type,
                             pva_heure_debut_am_temps in varchar2,
                             pva_heure_fin_am_temps   in varchar2,
                             pva_heure_debut_pm_temps in varchar2,
                             pva_heure_fin_pm_temps   in varchar2,
                             pva_remarque             in fdtt_temps_jours.remarque%type) is
    -- d?claration de variables
    vnu_nb_min_totale       number(4);
    vnu_debut_am_en_minutes number(4);
    vnu_fin_am_en_minutes   number(4);
    vnu_debut_pm_en_minutes number(4);
    vnu_fin_pm_en_minutes   number(4);
    vva_dh_debut_am_temps   varchar2(20);
    vva_dh_fin_am_temps     varchar2(20);
    vva_dh_debut_pm_temps   varchar2(20);
    vva_dh_fin_pm_temps     varchar2(20);
  begin
    --     
    vnu_nb_min_totale := 0;
    if pva_heure_debut_am_temps is not null then
      vva_dh_debut_am_temps := to_char(pdt_dt_temps_jour, 'YYYY-MM-DD') || ' ' || pva_heure_debut_am_temps;
    end if;
    --
    if pva_heure_fin_am_temps is not null then
      vva_dh_fin_am_temps := to_char(pdt_dt_temps_jour, 'YYYY-MM-DD') || ' ' || pva_heure_fin_am_temps;
    end if;
    -- en pm
    if pva_heure_debut_pm_temps is not null then
      vva_dh_debut_pm_temps := to_char(pdt_dt_temps_jour, 'YYYY-MM-DD') || ' ' || pva_heure_debut_pm_temps;
    end if;
    if pva_heure_fin_pm_temps is not null then
      vva_dh_fin_pm_temps := to_char(pdt_dt_temps_jour, 'YYYY-MM-DD') || ' ' || pva_heure_fin_pm_temps;
    end if;
    -- on calcul le temps de la journ?e quand les deux heures am et/ou pm sont saisies.
    if pva_heure_debut_am_temps is not null and pva_heure_fin_am_temps is not null then
      -- 
      vnu_debut_am_en_minutes := utl_fnb_cnv_minute(pva_heure_debut_am_temps);
      vnu_fin_am_en_minutes   := utl_fnb_cnv_minute(pva_heure_fin_am_temps);
      vnu_nb_min_totale       := vnu_nb_min_totale + vnu_fin_am_en_minutes - vnu_debut_am_en_minutes;
    end if;
    if pva_heure_debut_pm_temps is not null and pva_heure_fin_pm_temps is not null then
      -- 
      vnu_debut_pm_en_minutes := utl_fnb_cnv_minute(pva_heure_debut_pm_temps);
      vnu_fin_pm_en_minutes   := utl_fnb_cnv_minute(pva_heure_fin_pm_temps);
      vnu_nb_min_totale       := vnu_nb_min_totale + vnu_fin_pm_en_minutes - vnu_debut_pm_en_minutes;
    end if; 
    --
    update fdtt_temps_jours
       set dh_debut_am_temps = to_date(vva_dh_debut_am_temps, 'YYYY-MM-DD HH24:MI'),
           dh_fin_am_temps   = to_date(vva_dh_fin_am_temps, 'YYYY-MM-DD HH24:MI'),
           dh_debut_pm_temps = to_date(vva_dh_debut_pm_temps, 'YYYY-MM-DD HH24:MI'),
           dh_fin_pm_temps   = to_date(vva_dh_fin_pm_temps, 'YYYY-MM-DD HH24:MI'),
           total_temps_min   = vnu_nb_min_totale,
           remarque          = pva_remarque
     where no_seq_temps_jour = pnu_no_seq_temps_jour;
    --
  end p_maj_temps_jour;
  -------------------------------------------------------------------------------------------------
  -- Permet de v?rifier dans la grid de saisie de temps si la colonne est modifiable (toutes les activit?s 
  -- sauf les cong?s f?ri?s) dans le menu burger.
  -------------------------------------------------------------------------------------------------
  function f_verifier_si_activite_modifiable(pnu_NO_SEQ_ACTIVITE in fdtt_temps_jours.no_seq_activite%type)
    return boolean is
    -- Curseur pour aller chercher les heures saisies pour cette journ?e
    cursor cur_obtenir_seq_activite_ferie is
      select act.no_seq_activite,
             act.nom,
             case act.acronyme
               when '100' then
                'O'
               else
                'N'
             end as indic_feriee
        from fdtt_activites act, 
             fdtt_categorie_activites cat
       where cat.co_type_categorie = 'GENRQ'
         and act.no_seq_categ_activ = cat.no_seq_categ_activ
         and act.no_seq_activite = pnu_NO_SEQ_ACTIVITE;
    rec_obtenir_seq_activite_ferie cur_obtenir_seq_activite_ferie%rowtype;
    --
    vbo_activite_modifiable boolean;
  begin
    if pnu_NO_SEQ_ACTIVITE is null then
      vbo_activite_modifiable := false;
    else
      open cur_obtenir_seq_activite_ferie;
      fetch cur_obtenir_seq_activite_ferie
        into rec_obtenir_seq_activite_ferie;
      close cur_obtenir_seq_activite_ferie;
      --
      if rec_obtenir_seq_activite_ferie.indic_feriee = 'N' then
        vbo_activite_modifiable := true;
      else
        vbo_activite_modifiable := false;
      end if;
    end if;
    --         
    return vbo_activite_modifiable;
  end f_verifier_si_activite_modifiable;
  ---------------------------------------------------------------------------------------------- 
  -- Permet de faire la maj ou l'insertion dans FDTT_TEMPS_INTERVENTION
  ---------------------------------------------------------------------------------------------- 
  procedure p_gerer_temps_intervention(pva_apex_row_status       in varchar2,
                                       pnu_no_seq_temps_intrv    in fdtt_temps_intervention.no_seq_temps_intrv%type,
                                       pnu_no_seq_feuil_temps    in fdtt_temps_intervention.no_seq_feuil_temps%type,
                                       pnu_no_seq_aact_intrv_det in fdtt_temps_intervention.no_seq_aact_intrv_det%type,
                                       pva_an_mois_fdt           in fdtt_temps_intervention.an_mois_fdt%type,
                                       pdt_debut_periode         in fdtt_temps_intervention.debut_periode%type,
                                       pdt_fin_periode           in fdtt_temps_intervention.fin_periode%type,
                                       pva_nbr_minute_trav_aff   in varchar2,
                                       pva_commentaire           in fdtt_temps_intervention.commentaire%type,
                                       pnu_no_seq_specialite     in fdtt_temps_intervention.no_seq_specialite%type) is
    -- d?claration de variables 
    vnu_nb_minute_trav number(4);
  begin
    --
    vnu_nb_minute_trav := utl_fnb_cnv_minute(pva_nbr_minute_trav_aff);
    --
    if pva_apex_row_status = 'C' then
      -- On est en cr?ation
      insert into fdtt_temps_intervention
        (no_seq_feuil_temps,
         no_seq_aact_intrv_det,
         an_mois_fdt,
         debut_periode,
         fin_periode,
         nbr_minute_trav,
         commentaire,
         no_seq_specialite)
      VALUES
        (pnu_no_seq_feuil_temps,
         pnu_no_seq_aact_intrv_det,
         pva_an_mois_fdt,
         pdt_debut_periode,
         pdt_fin_periode,
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
  -- Valider la coh?rence
  -- ---------------------------------------------------------
  procedure p_valider_coherence(pnu_no_seq_feuil_temps in fdtt_temps_intervention.no_seq_feuil_temps%type,
                                pdt_debut_periode      in fdtt_temps_intervention.debut_periode%type,
                                pdt_fin_periode        in fdtt_temps_intervention.fin_periode%type) is
    --
    --
    -- Variables utilis?es pour le logger
    --
    vta_params logger.tab_param;
    --
    -- Avoir une image compl?te des donn?es BD + Apex
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
         and fin_periode = pdt_fin_periode;
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
         and fin_periode = pdt_fin_periode;
    --
    --
    --
    -- Valider qu'il n'y a pas deux interventions pareils pour cette p?riode
    --
    procedure p_valider_doublons_intervention is
      --
      cva_code_message utlt_message_trait.co_message%type := '000146';
      --
      cursor cur_valider_doublons_intervention is
        select count(tab.no_seq_aact_intrv_det) as nbr_intervention, tab.no_seq_aact_intrv_det
          from table(vta_rec_temps_intervention) tab
         group by tab.no_seq_aact_intrv_det;
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
                        p_name   => '======================================================Param?tres fonction',
                        p_val    => ' ');
    logger.append_param(p_params => vta_params,
                        p_name   => 'pnu_no_seq_feuil_temps',
                        p_val    => pnu_no_seq_feuil_temps);
    logger.append_param(p_params => vta_params, p_name => 'pdt_debut_periode', p_val => pdt_debut_periode);
    logger.append_param(p_params => vta_params, p_name => 'pdt_fin_periode', p_val => pdt_fin_periode);
    --
    if not apex_collection.collection_exists(cva_nom_collection) Then
      --
      -- S'il y a eu plusieurs lignes modifi?es dans la IG (cr?ation, modification, supression), cette fonction de coh?rence est appel?e autant de fois.
      -- Les validations de coh?rence ont besoin d'?tre faites seulement une fois, donc pour les appels de cette fonction 2+ on ne les refait pas.
      --
      logger.append_param(p_params => vta_params,
                          p_name   => '======================================================Informations',
                          p_val    => ' ');
      logger.append_param(p_params => vta_params,
                          p_name   => 'Collection ' || cva_nom_collection ||
                                      ' vide - Les validations ont d?j? ?t? effectu?es, on ne les refait pas.',
                          p_val    => ' ');
    else
      --
      -- R?cup?ration des donn?es de la table fdtt_ass_typ_intrv_qualf
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
                            p_name   => 'D?but p?riode',
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
  --------------------------------------------------------------------------------------------------------
  -- Permet de calculer le total du temps saisi pour une p?riode dans la fdt 
  -- (temps saisisable intervention seulement)
  --------------------------------------------------------------------------------------------------------
  function f_obtenir_temps_saisi_periode(pnu_no_seq_feuil_temps in fdtt_feuilles_temps.no_seq_feuil_temps%type,
                                         pdt_debut_periode      in date,
                                         pdt_fin_periode        in date) return number is
    -- Curseur pour aller chercher les heures saisies pour cette p?riode
    cursor cur_obtenir_temps_saisi_periode is
      with fge_ressource as
       (select asso_actintrv.no_seq_aact_intrv_det,
               asso_actintrv.description,
               asso_actintrv.no_seq_activite_decoupage
          from fdtt_feuilles_temps       fdt,
               fdtt_ass_intrvd_ressr    inter_res,
               fdtt_intervention_detail detail,
               fdtt_ass_act_intrv_det   asso_actintrv
         where fdt.no_seq_feuil_temps = pnu_no_seq_feuil_temps
           and inter_res.no_seq_ressource = fdt.no_seq_ressource
           and detail.no_seq_intrv_detail = inter_res.no_seq_intrv_detail
           and detail.code_intrv = 'FGE'
           and asso_actintrv.no_seq_intrv_detail = detail.no_seq_intrv_detail)
      select sum(total_temps_min) as temps_total_saisi_min
        from ( -- On calcul le temps des activit?s saisi
              -- On calcul le temps saisi
              select sum(tj.total_temps_min) as total_temps_min
                from fdtt_temps_jours tj
               where tj.no_seq_feuil_temps = pnu_no_seq_feuil_temps
                 and tj.dt_temps_jour between pdt_debut_periode and pdt_fin_periode
                 and tj.no_seq_activite is null
              --
              union all
              --
              select sum(tji.total_temps_min)
                from fdtt_temps_jours tji, fge_ressource fger
               where tji.no_seq_feuil_temps = pnu_no_seq_feuil_temps
                 and tji.dt_temps_jour between pdt_debut_periode and pdt_fin_periode
                 and tji.no_seq_activite is not null
                 and tji.no_seq_activite = fger.no_seq_activite_decoupage);
    rec_obtenir_temps_saisi_periode cur_obtenir_temps_saisi_periode%rowtype;
    --
    vnu_temps_total_saisi_min number(5);
  begin
    open cur_obtenir_temps_saisi_periode;
    fetch cur_obtenir_temps_saisi_periode
      into rec_obtenir_temps_saisi_periode;
    close cur_obtenir_temps_saisi_periode;
    --
    if rec_obtenir_temps_saisi_periode.temps_total_saisi_min is null then
      vnu_temps_total_saisi_min := 0;
    else
      vnu_temps_total_saisi_min := rec_obtenir_temps_saisi_periode.temps_total_saisi_min;
    end if;
    --  
    return vnu_temps_total_saisi_min;
    --                                     
  end f_obtenir_temps_saisi_periode;
  ---------------------------------------------------------------------------------------------- 
  -- Permet d'obtenir les diff?rents totaux pour permettre comparation fdt vs interventions
  ----------------------------------------------------------------------------------------------  
  procedure p_obt_totaux_fdt_intervention_periode(pnu_no_seq_feuil_temps in fdtt_feuilles_temps.no_seq_feuil_temps%type,
                                                  pdt_debut_periode      in date,
                                                  pdt_fin_periode        in date,
                                                  pva_total_fdt_hrs      out varchar2,
                                                  pva_total_inter_hrs    out varchar2,
                                                  pva_diff_fdt_inter_hrs out varchar2) is
    -- Curseur pour aller chercher les heures intervention pour cette p?riode
    cursor cur_obtenir_temps_intervention_periode is
      select sum(ti.nbr_minute_trav) as total_temps_intervention_min
        from fdtt_temps_intervention ti
       where ti.no_seq_feuil_temps = pnu_no_seq_feuil_temps
         and ti.debut_periode = pdt_debut_periode
         and ti.fin_periode = pdt_fin_periode;
    -- D?claration des variables
    vnu_temps_fdt_periode          number(5);
    vnu_temps_intervention_periode number(5);
    vnu_diff_fdt_intervention      number(5);
    --
  begin
    -- On va chercher le temps saisi fdt pour cette p?riode
    vnu_temps_fdt_periode := f_obtenir_temps_saisi_periode(pnu_no_seq_feuil_temps,
                                                           pdt_debut_periode,
                                                           pdt_fin_periode);
    -- On va chercher le temps saisi interfvention pour cette p?riode 
    open cur_obtenir_temps_intervention_periode;
    fetch cur_obtenir_temps_intervention_periode
      into vnu_temps_intervention_periode;
    close cur_obtenir_temps_intervention_periode;
    -- 
    -- On calcul la diff?rence de temps
    vnu_diff_fdt_intervention := vnu_temps_fdt_periode - coalesce(vnu_temps_intervention_periode, 0);
    -- 
    vnu_temps_intervention_periode := coalesce(vnu_temps_intervention_periode, 0);
    pva_total_fdt_hrs              := fdt_pkb_apx_util_temps.convert_format_heure(vnu_temps_fdt_periode);
    pva_total_inter_hrs            := fdt_pkb_apx_util_temps.convert_format_heure(vnu_temps_intervention_periode);
    pva_diff_fdt_inter_hrs         := fdt_pkb_apx_util_temps.convert_format_heure(vnu_diff_fdt_intervention);
    --
  end p_obt_totaux_fdt_intervention_periode;
  ------------------------------------------------------------------------------------------------------------
  -- Permet de voir si on traite l'onglet mois complet (dans ce cas on cache la partie intervention de la page
  ------------------------------------------------------------------------------------------------------------
  function f_obtenir_ind_mois_complet_intervention(pva_periodes      in fdtt_feuilles_temps.an_mois_fdt%type,
                                                   pdt_debut_periode in date,
                                                   pdt_fin_periode   in date) return varchar2 is
    --
    vda_date_debut_periode     date;
    vva_ind_mois_complet_inter varchar2(1);
  begin
    vda_date_debut_periode := to_date(pva_periodes || '01', 'YYYYMMDD');
    if pdt_debut_periode = vda_date_debut_periode and pdt_fin_periode = last_day(vda_date_debut_periode) then
      vva_ind_mois_complet_inter := 'O';
    else
      vva_ind_mois_complet_inter := 'N';
    end if;
    return vva_ind_mois_complet_inter;
  end f_obtenir_ind_mois_complet_intervention;
  --
  -- Proc?dure qui ajoute les messages dans la table des messages avertissement intervention ou 
  -- ajouter une erreur apex selon le mode d'affichage d'erreur.
  -- 
  procedure p_ajout_message(p_vc_message                 in varchar2,
                            pva_mode_affichage_erreur    in varchar2,
                            pva_date_debut_periode_inter in date,
                            pva_date_fin_periode_inter   in date) is
    vva_periode varchar2(50);
  begin
    vva_periode := 'P?riode du ' || to_char(pva_date_debut_periode_inter, 'day DD') || ' au ' ||
                   to_char(pva_date_fin_periode_inter, 'day DD');
  
    if pva_mode_affichage_erreur = 'AVERTISSEMENT' then
      vtp_message_interv_aver.extend;
      vtp_message_interv_aver(vtp_message_interv_aver.count) := vva_periode || ' : ' || p_vc_message;
    else
      apex_error.add_error(vva_periode || ' : ' || p_vc_message, null, apex_error.c_inline_in_notification);
    end if;
  end;
  ---------------------------------------------------------------------------------------------- 
  -- Permet de faire la valisation des diff?rents types d'intervention
  ----------------------------------------------------------------------------------------------  
  procedure p_valider_intervention_fdt(pnu_no_seq_ressource      in fdtt_ressource.no_seq_ressource%type,
                                       pva_an_mois_fdt           in fdtt_feuilles_temps.an_mois_fdt%type,
                                       pnu_no_seq_feuil_temps    in fdtt_feuilles_temps.no_seq_feuil_temps%type,
                                       pva_interne_ou_externe    in varchar2,
                                       pva_mode_affichage_erreur in varchar2 default 'AVERTISSEMENT') is
    --
    --Curseur qui permet d'aller chercher les p?riodes intervention pour cette fdt.
    --
    /*
     ? mettre dans cur_obtenir_periode_interv
     with jour_mois as (select to_date(pva_an_mois_fdt || to_char(journee.jour, '00') , 'yyyymmdd') as jo, 
                                          TO_CHAR(to_date(pva_an_mois_fdt || to_char(journee.jour, '00') , 'yyyymmdd'),'iw') as semaineAnnuelle
                                   from (select rownum as jour 
                                         from busv_info_employe 
                                         where rownum <= to_number(to_char(last_day(to_date(to_char(to_date(pva_an_mois_fdt || '01','yyyymmdd'),'yyyymm'), 'yyyymm')), 'dd'))) journee)
            select min(jourM.jo) as jour_debut_periode,
                   max(jourM.jo) as jour_fin_periode
            from jour_mois jourM
            group by jourM.semaineAnnuelle
            order by 1    
    */
    cursor cur_obtenir_periode_interv is
      with jour_mois as (select to_date(pva_an_mois_fdt || to_char(journee.jour, '00') , 'yyyymmdd') as jo, 
                                          TO_CHAR(to_date(pva_an_mois_fdt || to_char(journee.jour, '00') , 'yyyymmdd'),'iw') as semaineAnnuelle
                                   from (select rownum as jour 
                                         from busv_info_employe 
                                         where rownum <= to_number(to_char(last_day(to_date(to_char(to_date(pva_an_mois_fdt || '01','yyyymmdd'),'yyyymm'), 'yyyymm')), 'dd'))) journee)
            select min(jourM.jo) as jour_debut_periode,
                   max(jourM.jo) as jour_fin_periode
            from jour_mois jourM
            group by jourM.semaineAnnuelle
            order by 1;       
      /*select level_menu, label_menu, attribute1, attribute2, attribute3
        from fdt_pkb_apx_010101.f_obtenir_item_onglet_saisie(pnu_no_seq_ressource => pnu_no_seq_ressource,
                                                             pva_an_mois_fdt      => pva_an_mois_fdt,
                                                             pdt_dt_debut_periode => null,
                                                             pdt_dt_fin_periode   => null)
       where attribute3 <> '99'
       order by attribute1;*/
    rec_obtenir_periode_interv cur_obtenir_periode_interv%rowtype;
    --
    -- Curseur qui va chercher si on valide les interventions pour cette ressource
    cursor cur_obtenir_ind_valid_interv is
      select res.ind_validation_intrv
        from fdtt_ressource res
       where res.no_seq_ressource = pnu_no_seq_ressource;
    -- 
    pva_total_fdt_hrs       varchar2(8);
    pva_total_inter_hrs     varchar2(8);
    pva_diff_fdt_inter_hrs  varchar2(8);
    vva_message             varchar2(4000);
    vva_valide_intervention fdtt_ressource.ind_validation_intrv%type;
  begin
    --
    open cur_obtenir_ind_valid_interv;
    fetch cur_obtenir_ind_valid_interv
      into vva_valide_intervention;
    close cur_obtenir_ind_valid_interv;
    -- 
    if vva_valide_intervention = 'O' then
      open cur_obtenir_periode_interv;
      fetch cur_obtenir_periode_interv
        into rec_obtenir_periode_interv;
      while (cur_obtenir_periode_interv%found) loop
        -- mettre validations ici
        -- On appelle la proc?dure pour obtenir les calculs temps fdt et intervention pour la p?riode
        pva_total_fdt_hrs      := null;
        pva_total_inter_hrs    := null;
        pva_diff_fdt_inter_hrs := null;
        --
        p_obt_totaux_fdt_intervention_periode(pnu_no_seq_feuil_temps,
                                              rec_obtenir_periode_interv.jour_debut_periode,
                                              rec_obtenir_periode_interv.jour_fin_periode,
                                              pva_total_fdt_hrs, --    out varchar2
                                              pva_total_inter_hrs, --    out varchar2
                                              pva_diff_fdt_inter_hrs); -- out varchar2
        --
        -- On regarde si les 2 totaux sont identiques
        if pva_total_fdt_hrs <> pva_total_inter_hrs then
          if instr(pva_diff_fdt_inter_hrs, '-') > 0 then
            -- Le temps intervention d?passe le temps saisi FDT
            if pva_mode_affichage_erreur = 'AVERTISSEMENT' or pva_interne_ou_externe = 'E' then
              --
              vva_message := utl_pkb_message.fc_obt_message('FDT.000137',
                                                            replace(pva_diff_fdt_inter_hrs, '-', ''));
              p_ajout_message(vva_message,
                              pva_mode_affichage_erreur,
                              rec_obtenir_periode_interv.jour_debut_periode,
                              rec_obtenir_periode_interv.jour_fin_periode);
            end if;
          else
            -- Le temps saisi FDT est plus grand que les intefventions pour la p?riode
            vva_message := utl_pkb_message.fc_obt_message('FDT.000138', pva_diff_fdt_inter_hrs);
            p_ajout_message(vva_message,
                            pva_mode_affichage_erreur,
                            rec_obtenir_periode_interv.jour_debut_periode,
                            rec_obtenir_periode_interv.jour_fin_periode);
          end if;
        end if;
        --
        fetch cur_obtenir_periode_interv
          into rec_obtenir_periode_interv;
      end loop;
      close cur_obtenir_periode_interv;
    end if;
    --apex_debug.message('vtp_onglet_periode.count : ' || vtp_onglet_periode.count);
    --vtp_onglet_periode :=new tab_pipe_item_onglet_saisie();
    --for i in 1..vtp_onglet_periode.count loop
    --   apex_debug.message('date d?but p?riode : ' || vtp_onglet_periode(i).attribute1);
    --   apex_debug.message('date fin p?riode : ' || vtp_onglet_periode(i).attribute2);
    --end loop;
  end p_valider_intervention_fdt;
  --------------------------------------------------------------------------------------------------------------- 
  --  Permet de g?rer automatiquement les interventions qui concernent des activit?s saisies dans la fdt 
  --  (ex: vacances, maladies, ? noter que certaines activit?s g?n?riques comme les cr?dits horaires ne sont pas saisies
  --  dans temps intervention.
  ---------------------------------------------------------------------------------------------------------------  
  procedure p_gerer_temps_interv_generique(pnu_no_seq_temps_jour        in fdtt_temps_jours.no_seq_temps_jour%type,
                                           pnu_no_seq_feuil_temps       in fdtt_feuilles_temps.no_seq_feuil_temps%type,
                                           pnu_no_seq_activite          in fdtt_temps_jours.no_seq_activite%type,
                                           pdt_dt_temps_jour            in fdtt_temps_jours.dt_temps_jour%type,
                                           pva_an_mois_fdt              in fdtt_feuilles_temps.an_mois_fdt%type,
                                           pdt_dt_debut_periode         in date,
                                           pdt_dt_fin_periode           in date,
                                           pva_heure_absence            in varchar2,
                                           pnu_no_seq_specialite_defaut in number,
                                           pva_request                  in varchar2) is
    --
    -- D?claration des variables
    cursor cur_obt_seq_asso_inter_act is
      select asso_actintrv.no_seq_aact_intrv_det
        from fdtt_feuilles_temps       fdt,
             fdtt_ass_intrvd_ressr    inter_res,
             fdtt_intervention_detail detail,
             fdtt_ass_act_intrv_det   asso_actintrv
       where fdt.no_seq_feuil_temps = pnu_no_seq_feuil_temps
         and inter_res.no_seq_ressource = fdt.no_seq_ressource
         and detail.no_seq_intrv_detail = inter_res.no_seq_intrv_detail
         and detail.code_intrv = 'FGE'
         and asso_actintrv.no_seq_intrv_detail = detail.no_seq_intrv_detail
         and asso_actintrv.no_seq_activite_decoupage = pnu_no_seq_activite;
    vnu_no_seq_aact_intrv_det number;
    --
    cursor cur_obt_activite_temps_avant is
      select tj.total_temps_min
        from fdtt_temps_jours tj
       where tj.no_seq_temps_jour = pnu_no_seq_temps_jour;
    vnu_temps_intervention_avant number;
    --
    cursor cur_obt_act_temps_intrv_periode_avant(pdt_dt_debut_periode_avant in date,
                                                 pdt_dt_fin_periode_avant in date) is
      select tmp_inter.nbr_minute_trav
        from fdtt_temps_intervention tmp_inter
       where tmp_inter.no_seq_feuil_temps = pnu_no_seq_feuil_temps
         and tmp_inter.no_seq_aact_intrv_det = vnu_no_seq_aact_intrv_det
         and tmp_inter.debut_periode = pdt_dt_debut_periode_avant
         and tmp_inter.fin_periode = pdt_dt_fin_periode_avant;
    vnu_temps_act_interv_periode_avant number;
    --       
    vnu_ecart number;
    --
    cursor cur_obtenir_periode_interv(pdt_date_absence_a_creer in date,
                                      pnu_no_seq_ressource in number) is
      select level_menu, label_menu, attribute1, attribute2, attribute3
        from fdt_pkb_apx_010101.f_obtenir_item_onglet_saisie(pnu_no_seq_ressource => pnu_no_seq_ressource,
                                                             pva_an_mois_fdt      => pva_an_mois_fdt,
                                                             pdt_dt_debut_periode => null,
                                                             pdt_dt_fin_periode   => null)
       where attribute3 <> '99'
         and pdt_date_absence_a_creer between to_date(attribute1, 'yy-mm-dd') and
             to_date(attribute2, 'yy-mm-dd')
       order by attribute1;
    rec_obtenir_periode_interv cur_obtenir_periode_interv%rowtype;
    --
    cursor cur_obt_ressource is
      select fdtr.no_seq_ressource
      from fdtt_feuilles_temps  fdtr
      where fdtr.no_seq_feuil_temps = pnu_no_seq_feuil_temps;
    --
    vda_date_debut_periode     date;
    vnu_no_seq_ressource   fdtt_feuilles_temps.no_seq_ressource%type;
    vdt_dt_debut_periode   date;
    vdt_dt_fin_periode     date;
    --
  begin
    --
    --
    vnu_no_seq_aact_intrv_det := 0;
    open cur_obt_seq_asso_inter_act;
    fetch cur_obt_seq_asso_inter_act
      into vnu_no_seq_aact_intrv_det;
    close cur_obt_seq_asso_inter_act;
    --
    if coalesce(vnu_no_seq_aact_intrv_det, 0) <> 0 then
      -- On vient ajuster la date d?but de p?riode et find de p?riode lorsque l'utilisateur est sur
      -- l'onglet mois complet.
      --
      vnu_no_seq_ressource := 0;
      open cur_obt_ressource;
         fetch cur_obt_ressource into vnu_no_seq_ressource;
      close cur_obt_ressource;
      vda_date_debut_periode := to_date(pva_an_mois_fdt || '01', 'YYYYMMDD');
      if pdt_dt_debut_periode = vda_date_debut_periode and pdt_dt_fin_periode = last_day(vda_date_debut_periode) then
         -- nous sommes dans l'onglet mois complet, il faut trouver la bonne p?riode selon la date de l'absence.
         -- On va chercher le no_seq_ressource associ? ? la fdt.
         
         open cur_obtenir_periode_interv(pdt_dt_temps_jour,
                                         vnu_no_seq_ressource);
            fetch cur_obtenir_periode_interv into rec_obtenir_periode_interv;
         close cur_obtenir_periode_interv;
         vdt_dt_debut_periode := to_date(rec_obtenir_periode_interv.attribute1, 'yy-mm-dd');
         vdt_dt_fin_periode   :=to_date(rec_obtenir_periode_interv.attribute2, 'yy-mm-dd');
      else
         vdt_dt_debut_periode := pdt_dt_debut_periode;
         vdt_dt_fin_periode   := pdt_dt_fin_periode;
      end if;   
      --
      -- Cette intervention concerne une activit? g?n?rique auquel est associ?e une intervention
      if pva_request = utl_pkb_apx_securite.f_obtenir_request_create then
        -- On doit mettre ce temps dans temps_intervention
        begin
          insert into fdtt_temps_intervention
            (no_seq_feuil_temps,
             no_seq_aact_intrv_det,
             no_seq_specialite,
             an_mois_fdt,
             debut_periode,
             fin_periode,
             nbr_minute_trav)
          values
            (pnu_no_seq_feuil_temps,
             vnu_no_seq_aact_intrv_det,
             pnu_no_seq_specialite_defaut,
             pva_an_mois_fdt,
             vdt_dt_debut_periode,
             vdt_dt_fin_periode,
             utl_fnb_cnv_minute(pva_heure_absence));
        exception
          when dup_val_on_index then
            --
            update fdtt_temps_intervention ti
               set ti.nbr_minute_trav = ti.nbr_minute_trav + utl_fnb_cnv_minute(pva_heure_absence)
             where ti.no_seq_feuil_temps = pnu_no_seq_feuil_temps
               and ti.no_seq_aact_intrv_det = vnu_no_seq_aact_intrv_det
               and ti.debut_periode = vdt_dt_debut_periode
               and ti.fin_periode = vdt_dt_fin_periode;
        end;
      
      else
        -- On va chercher le temps saisi pour cette activit? avant la modification ou la destruction de celle-ci
        vnu_temps_intervention_avant := 0;
        open cur_obt_activite_temps_avant;
        fetch cur_obt_activite_temps_avant
          into vnu_temps_intervention_avant;
        close cur_obt_activite_temps_avant;
        --
        if pva_request = utl_pkb_apx_securite.f_obtenir_request_save then
          -- Nous sommes en maj
          -- On fait la diff?rence de temps entre ce qu'il y a dans le pano et ce qu'il y avait avant dans la bd
          vnu_ecart := utl_fnb_cnv_minute(pva_heure_absence) - vnu_temps_intervention_avant;
          update fdtt_temps_intervention ti
             set ti.nbr_minute_trav = ti.nbr_minute_trav + vnu_ecart
           where ti.no_seq_feuil_temps = pnu_no_seq_feuil_temps
             and ti.no_seq_aact_intrv_det = vnu_no_seq_aact_intrv_det
             and ti.debut_periode = vdt_dt_debut_periode
             and ti.fin_periode = vdt_dt_fin_periode;
        else
          -- Nous sommes en destruction
          -- On va chercher le temps saisi pour cette activit? pour cette p?riode
          vnu_temps_act_interv_periode_avant := 0;
          open cur_obt_act_temps_intrv_periode_avant(vdt_dt_debut_periode,
                                                     vdt_dt_fin_periode);
          fetch cur_obt_act_temps_intrv_periode_avant
            into vnu_temps_act_interv_periode_avant;
          close cur_obt_act_temps_intrv_periode_avant;
          --             
          vnu_ecart := vnu_temps_intervention_avant - vnu_temps_act_interv_periode_avant;
          --vnu_ecart := utl_fnb_cnv_minute(pva_heure_absence) - vnu_temps_intervention_avant;
          if vnu_ecart = 0 then
            -- Le temps restant ?tant ? z?ro, on d?truit cette intervention
            delete from fdtt_temps_intervention ti
             where ti.no_seq_feuil_temps = pnu_no_seq_feuil_temps
               and ti.no_seq_aact_intrv_det = vnu_no_seq_aact_intrv_det
               and ti.debut_periode = vdt_dt_debut_periode
               and ti.fin_periode = vdt_dt_fin_periode;
          else
            update fdtt_temps_intervention ti
               set ti.nbr_minute_trav = ti.nbr_minute_trav - vnu_temps_intervention_avant
             where ti.no_seq_feuil_temps = pnu_no_seq_feuil_temps
               and ti.no_seq_aact_intrv_det = vnu_no_seq_aact_intrv_det
               and ti.debut_periode = vdt_dt_debut_periode
               and ti.fin_periode = vdt_dt_fin_periode;
          end if;
        end if;
      end if;
    end if;
    --
  end p_gerer_temps_interv_generique;
  -----------------------------------------------------------------------------------------------------------
  -- Permet de savoir si l'activite en est une g?n?rique.  Dans ce cas, la ligne est non modifiable.
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
  -----------------------------------------------------------------------------------------------------------
  -- Permet de retourner la sp?cialit? minimale de la ressource pour cr?er les interventions g?n?riques (FGE)
  -----------------------------------------------------------------------------------------------------------
  function f_obtenir_specialite_ressource_pour_inter(pnu_no_seq_feuil_temps in fdtt_feuilles_temps.no_seq_feuil_temps%type,
                                                     pdt_date_debut_periode in date,
                                                     pdt_date_fin_periode   in date) return number is
    -- variable
    cursor cur_obt_specialite_ressource_pour_inter is
      select min(spec.no_seq_specialite) as no_seq_specialite_min
        from fdtt_specialite spec, fdtt_feuilles_temps fdt, fdtt_ressource_info_suppl info
       where fdt.no_seq_feuil_temps = pnu_no_seq_feuil_temps
         and info.no_seq_ressource = fdt.no_seq_ressource
         and info.dt_debut <= pdt_date_debut_periode
         and (info.dt_fin is null or info.dt_fin >= pdt_date_fin_periode)
         and spec.no_seq_specialite = info.no_seq_specialite;
    rec_obt_specialite_ressource_pour_inter cur_obt_specialite_ressource_pour_inter%rowtype;
  begin
    --    
    open cur_obt_specialite_ressource_pour_inter;
    fetch cur_obt_specialite_ressource_pour_inter
      into rec_obt_specialite_ressource_pour_inter;
    close cur_obt_specialite_ressource_pour_inter;
    --
    if rec_obt_specialite_ressource_pour_inter.no_seq_specialite_min is null then
      return 0;
    else
      -- 
      return rec_obt_specialite_ressource_pour_inter.no_seq_specialite_min;
    end if;
    --
  end f_obtenir_specialite_ressource_pour_inter;
  -----------------------------------------------------------------------------------------------------------
  -- Permet de retourner la sp?cialit? minimale de la ressource pour cr?er les interventions g?n?riques (FGE)
  -----------------------------------------------------------------------------------------------------------
  procedure p_init_champs_absences_prolongees(pnu_co_employe_shq     in fdtt_ressource.co_employe_shq%type,
                                              pdt_date_min_courn     out date,
                                              pdt_date_max_courn     out date,
                                              pnu_no_seq_feuil_temps out fdtt_feuilles_temps.no_seq_feuil_temps%type,
                                              pva_an_mois_fdt        out fdtt_feuilles_temps.an_mois_fdt%type,
                                              pnu_no_seq_ressource   out fdtt_feuilles_temps.no_seq_ressource%type,
                                              pva_ind_saisie_intrv   out fdtt_ressource.ind_saisie_intrv%type) is
    -- D?claration de variables
    cursor cur_obt_champs_absences_prolongees is
      with maxdat as
       (select max(to_date(AN_MOIS_FDT, 'yyyymm')) dat,
               max(fdt.no_seq_feuil_temps) as no_seq_feuil_temps,
               max(fdt.an_mois_fdt) as an_mois_fdt,
               max(res.no_seq_ressource) as no_seq_ressource,
               max(res.ind_saisie_intrv) as ind_saisie_intrv
          from fdtt_feuilles_temps fdt, fdtt_ressource res
         where fdt.no_seq_ressource = res.no_seq_ressource
           and res.co_employe_shq = pnu_co_employe_shq
           and ind_saisie_autorisee = 'O')
      select dat as date_min_courn,
             add_months(dat, 1) - 1 as date_max_courn,
             no_seq_feuil_temps,
             an_mois_fdt,
             no_seq_ressource,
             ind_saisie_intrv
        from maxdat;
    rec_obt_champs_absences_prolongees cur_obt_champs_absences_prolongees%rowtype;
  begin
    --
    open cur_obt_champs_absences_prolongees;
    fetch cur_obt_champs_absences_prolongees
      into rec_obt_champs_absences_prolongees;
    close cur_obt_champs_absences_prolongees;
    --
    pdt_date_min_courn     := rec_obt_champs_absences_prolongees.date_min_courn;
    pdt_date_max_courn     := rec_obt_champs_absences_prolongees.date_max_courn;
    pnu_no_seq_feuil_temps := rec_obt_champs_absences_prolongees.no_seq_feuil_temps;
    pva_an_mois_fdt        := rec_obt_champs_absences_prolongees.an_mois_fdt;
    pnu_no_seq_ressource   := rec_obt_champs_absences_prolongees.no_seq_ressource;
    pva_ind_saisie_intrv   := rec_obt_champs_absences_prolongees.ind_saisie_intrv;
    --
  end p_init_champs_absences_prolongees;
  -----------------------------------------------------------------------------------------------------------
  -- Permet de cr?er les absences prolong?es (et les interventions correspondantes si requis)
  -----------------------------------------------------------------------------------------------------------
  procedure p_gerer_absences_prolongees(pnu_co_employe_shq          in fdtt_ressource.co_employe_shq%type,
                                        pnu_no_seq_ressource        in fdtt_feuilles_temps.no_seq_ressource%type,
                                        pnu_no_seq_feuil_temps      in fdtt_feuilles_temps.no_seq_feuil_temps%type,
                                        pva_an_mois_fdt             in fdtt_feuilles_temps.an_mois_fdt%type,
                                        pnu_no_seq_activite_absence in fdtt_feuilles_temps.no_seq_ressource%type,
                                        pva_ind_saisie_intrv        in fdtt_ressource.ind_saisie_intrv%type,
                                        pdt_date_debut_absence      in date,
                                        pdt_date_fin_absence        in date) is
    -- D?claration des variables
    --vda_date_debut date := to_datE(:P44_DATE_DEBUT,'yyyy-mm-dd');
    --vda_date_fin   date := to_datE(:P44_DATE_FIN,'yyyy-mm-dd');
   
    cursor cur_obtenir_periode_interv(pdt_date_absence_a_creer in date) is
      select level_menu, label_menu, attribute1, attribute2, attribute3
        from fdt_pkb_apx_010101.f_obtenir_item_onglet_saisie(pnu_no_seq_ressource => pnu_no_seq_ressource,
                                                             pva_an_mois_fdt      => pva_an_mois_fdt,
                                                             pdt_dt_debut_periode => null,
                                                             pdt_dt_fin_periode   => null)
       where attribute3 <> '99'
         and pdt_date_absence_a_creer between to_date(attribute1, 'yy-mm-dd') and
             to_date(attribute2, 'yy-mm-dd')
       order by attribute1;
    rec_obtenir_periode_interv cur_obtenir_periode_interv%rowtype;
    --
    --vnu_no_seq_specialite number(10);
    vva_heure_absence varchar2(10);
  begin
     --apex_debug.message('Il arrive dans proc '); 
     --apex_debug.message('shqcge pdt_date_debut_absence : '||to_char(pdt_date_debut_absence,'yyyy-mm-dd'));
     --apex_debug.message('shqcge pdt_date_fin_absence : '||to_char(pdt_date_fin_absence,'yyyy-mm-dd'));  
    -- 
    -- On va chercher les dates de cette FDT o? il n'y a aucune saisie.
    for vr_activ in (select sum_temps.dt_temps_jour as dt_temps_jour
                     from (select tj.dt_temps_jour, sum(tj.total_temps_min) as cumul_jour
                           from fdtt_temps_jours tj, 
                                fdtt_feuilles_temps feui
                           where feui.no_seq_feuil_temps = pnu_no_seq_feuil_temps 
                             and feui.no_seq_feuil_temps = tj.no_seq_feuil_temps
                             and dt_temps_jour between pdt_date_debut_absence and
                                                       pdt_date_fin_absence  
                           group by tj.dt_temps_jour
                           order by dt_temps_jour) sum_temps
                      where nvl(sum_temps.cumul_jour,0) = 0) loop
      -- and vr_activ.dt_temps_jour between to_date(attribute1,'yy-mm-dd') and to_date(attribute2,'yy-mm-dd')
      -- On va chercher la p?riode pour cette journ?e.
      --apex_debug.message('shqcge debut dans gerer absence vr_activ.dt_temps_jour : '||to_char(vr_activ.dt_temps_jour,'yyyy-mm-dd')); 
      --
      open cur_obtenir_periode_interv(vr_activ.dt_temps_jour);
      fetch cur_obtenir_periode_interv
        into rec_obtenir_periode_interv;
      close cur_obtenir_periode_interv;
      --   
      vva_heure_absence := fdt_pkb_apx_util_temps.convert_format_heure(fdt_fnb_apx_obt_nb_minutes_usager(pnu_no_seq_ressource,
                                                                                                         vr_activ.dt_temps_jour,
                                                                                                         vr_activ.dt_temps_jour));
      --
      -- Mettre proc?dure ici 
      p_creer_ou_maj_absence(null, -- Ne sert pas en cr?ation (pnu_no_seq_temps_jour)
                             pnu_no_seq_feuil_temps,
                             pnu_no_seq_activite_absence,
                             vr_activ.dt_temps_jour,
                             vva_heure_absence,
                             utl_pkb_apx_securite.f_obtenir_request_create,
                             pva_an_mois_fdt,
                             pva_ind_saisie_intrv,
                             to_date(rec_obtenir_periode_interv.attribute1, 'yy-mm-dd'),
                             to_date(rec_obtenir_periode_interv.attribute2, 'yy-mm-dd'),
                             null);
      --                                                                
    end loop;
    --
  end p_gerer_absences_prolongees;
  ------------------------------------------------------------------------------------------------------------
  -- Permet d'obtenir les records pour la lov des interventions dans la liste des interventions.
  ------------------------------------------------------------------------------------------------------------ 
  function f_obtenir_items_lov_intervention(pnu_no_seq_ressource         in fdtt_ressource.no_seq_ressource%type,
                                            pnu_no_seq_feuil_temps       in fdtt_feuilles_temps.no_seq_feuil_temps%type,
                                            pdt_date_debut_periode       in date,
                                            pdt_date_fin_periode         in date,
                                            pnu_no_seq_activite_generaux in fdtt_activites.no_seq_activite%type,
                                            pnu_no_seq_temps_interv      in fdtt_temps_intervention.no_seq_temps_intrv%type)
    return tab_pipe_item_lov_intervention
    pipelined is
    -- D?claration des variables
    cursor cur_obtenir_ressource_intervention is
      	  with intervention as
       (select adet.no_seq_aact_intrv_det,
               adet.description,
               adet.no_seq_intrv_detail,
               adet.no_seq_activite_decoupage
          from fdtt_ass_act_intrv_det adet,
               fdtt_activites acti,
               fdtt_categorie_activites cat,
               fdtt_intervention_detail inter
         where inter.no_seq_intrv_detail = adet.no_seq_intrv_detail
           and (inter.dt_deb_reelle < pdt_date_debut_periode or
               inter.dt_deb_reelle between pdt_date_debut_periode and pdt_date_fin_periode)
           and (inter.dt_fin_reelle is null or inter.dt_fin_reelle > pdt_date_debut_periode)
           and acti.no_seq_activite = adet.no_seq_activite_decoupage
           and cat.no_seq_categ_activ = acti.no_seq_categ_activ
           and cat.co_type_categorie <> 'GENRQ' 
           and inter.indic_visibilite_fdt = 'O'
           and adet.no_seq_aact_intrv_det not in (select assoDet.No_Seq_Aact_Intrv_Det
                                                  from fdtt_intervention_detail intD,
                                                       fdtt_ass_act_intrv_det assoDet
                                                  where intD.No_Seq_Intrv_Detail = assoDet.No_Seq_Intrv_Detail
                                                    and intD.Code_Intrv         = 'FGE'
                                                    and assoDEt.No_Seq_Activite_Decoupage = pnu_no_seq_activite_generaux)) 
      --
      select inter.description as d, inter.no_seq_aact_intrv_det as r
        from fdtt_ass_intrvd_ressr res
       inner join intervention inter
          on res.no_seq_intrv_detail = inter.no_seq_intrv_detail
       where res.no_seq_ressource = pnu_no_seq_ressource
         and (res.dt_debut < pdt_date_debut_periode or
             res.dt_debut between pdt_date_debut_periode and pdt_date_fin_periode)
         and (res.dt_fin is null or res.dt_fin > pdt_date_debut_periode)
      --
      --
      union all
      -- Permet d'afficher les frais g?n?raux non saisissable par l'utilisateur
      select aid.description as d, aid.no_seq_aact_intrv_det as r
      from fdtt_temps_intervention ti, fdtt_ass_act_intrv_det aid, fdtt_intervention_detail interv
      where ti.no_seq_feuil_temps = pnu_no_seq_feuil_temps 
        and ti.debut_periode = pdt_date_debut_periode 
        and ti.fin_periode = pdt_date_fin_periode 
        and aid.no_seq_aact_intrv_det = ti.no_seq_aact_intrv_det 
        and interv.no_seq_intrv_detail = aid.no_seq_intrv_detail 
        and (interv.code_intrv = 'FGE' or interv.indic_visibilite_fdt = 'N') 
        and ti.no_seq_temps_intrv = coalesce(pnu_no_seq_temps_interv, 0)
      --        
      order by 1;
  --and ti.no_seq_temps_intrv = coalesce(pnu_no_seq_temps_interv,'0');
    --
    --type tab_obtenir_ressource_intervention is table of cur_obtenir_ressource_intervention%rowtype;
    --vta_obtenir_ressource_intervention tab_obtenir_ressource_intervention;
    --
    --vre_item_item_lov_intervention fdt_pkb_apx_010101.rec_item_lov_intervention;
    vta_pipe_item_lov_intervention fdt_pkb_apx_010101.tab_pipe_item_lov_intervention;
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
                          p_name   => 'pnu_no_seq_feuil_temps',
                          p_val    => pnu_no_seq_feuil_temps);
    
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
  ---------------------------------------------------------------------------------------------- 
  -- Permet de valider que la fdt pr?c?dente a ?t? approuv?e avant de transmettre celle en cours  
  ----------------------------------------------------------------------------------------------  
  procedure valider_si_journee_feriee(pdt_dt_temps_jour in fdtt_temps_jours.dt_temps_jour%type) is
    -- D?claration de variables
    --vva_message varchar2(4000);
  begin
    --
    if UTL_PKB_DATE_OUVRABLE.fva_est_ferie(pdt_dt_temps_jour)= 'O' then
      vva_message := utl_pkb_message.fc_obt_message('FDT.000155');
      apex_error.add_error(vva_message, null, apex_error.c_inline_in_notification);
    end if;
  end valider_si_journee_feriee;
    ---------------------------------------------------------------------------------------------- 
  -- Permet de valider que la fdt pr?c?dente a ?t? approuv?e avant de transmettre celle en cours  
  ---------------------------------------------------------------------------------------------- 
  procedure valider_champ_correction(pva_corr_mois_preced      in varchar2,
                                     pva_note_corr_mois_preced in fdtt_feuilles_temps.note_corr_mois_preced%type) is
    -- D?claration de variables
    --vnu_nombre number;
    vnu_corr_mois_preced fdtt_feuilles_temps.corr_mois_preced%type;
    --vva_message varchar2(4000);
  begin
    vnu_corr_mois_preced := utl_fnb_cnv_minute(pva_corr_mois_preced);
    if vnu_corr_mois_preced != 0 and pva_note_corr_mois_preced is null then
       vva_message := utl_pkb_message.fc_obt_message('FDT.000025');
       apex_error.add_error(vva_message, null, apex_error.c_inline_in_notification);
    end if;
    --vnu_nombre := 1;
    --if vnu_nombre > 0 then
    --  vva_message := utl_pkb_message.fc_obt_message('FDT.0000??');
     -- apex_error.add_error(vva_message, null, apex_error.c_inline_in_notification);
      --return utl_pkb_message.fc_obt_message('FDT.000031');
    --end if;
    /*select count(*)
      into vnu_nombre
      from fdtt_feuilles_temps ft
     where ft.no_seq_ressource = pnu_no_seq_ressource
       and ft.an_mois_fdt < pva_an_mois_fdt
       and not exists (select fdt.no_seq_suivi_fdt
              from fdtt_suivi_feuilles_temps fdt
             where fdt.no_seq_feuil_temps = ft.no_seq_feuil_temps
               and fdt.co_typ_suivi_fdt in ('APPR_GESTI'));
    --
    if vnu_nombre > 0 then
      vva_message := utl_pkb_message.fc_obt_message('FDT.000031');
      apex_error.add_error(vva_message, null, apex_error.c_inline_in_notification);
      --return utl_pkb_message.fc_obt_message('FDT.000031');
    end if;*/
  end valider_champ_correction;
     -- =========================================================================
   -- Fontion qui renvoit une requ?te sql pour obtenir la liste des absences 
   -- SAGIR d'une ressources pour un mois.
   -- =========================================================================
   function f_retourner_requete_sagir_fdt return varchar2 is
      -- D?claration des variables
      vva_requete_sql varchar2(4000);
   begin
      -- 
      vva_requete_sql := q'~
          select emp.NOM_EMPLOYE || ' ,' || emp.PRE_EMPLOYE as nom_employe,
                 sabs.absence_attendance_type_id,
                 sabs.person_id,
                 sabs.date_creation,
                 sabs.absence_hours,
                 sabs.date_start || ' ' || sabs.time_start,
                 sabs.date_end || ' ' || sabs.time_end,
                 sabs.attribute1  as date_retour,
                 sabs.attribute7  as journee,
                 sabs.attribute8  as heure,
                 sabs.attribute10 as minutes,
                 sabs.attribute14,
                 typa.attribute1  as code_absence,
                 typa.attribute2  as precision_code_absence,
                 typa.attribute1 || '-' || typa.name        as description_absence 
          from  fdtt_ressource res
                    inner join bust_employe   emp  on emp.co_employe_shq = res.co_employe_shq
                    inner join SAGIR_ABSENCES sabs on sabs.person_id = res.id_personne_sagir,
                SAGIR_TYPES_ABSENCES typa 
          where res.no_seq_ressource = :P25_NO_SEQ_RESSOURCE   
            and sabs.absence_attendance_type_id not in (7086)
            and (sabs.date_start between to_date(:P25_AN_MOIS_FDT||'01','yyyymmdd') and to_date(last_day(to_date(:P25_AN_MOIS_FDT,'yyyymm'))) or
                 sabs.date_end   between to_date(:P25_AN_MOIS_FDT||'01','yyyymmdd') and to_date(last_day(to_date(:P25_AN_MOIS_FDT,'yyyymm'))))
            and typa.absence_attendance_type_id = sabs.absence_attendance_type_id
          order by 6~'; 
      -- 
      return vva_requete_sql;       
      --                                 
   end f_retourner_requete_sagir_fdt; 
end fdt_pkb_apx_010101;
/

