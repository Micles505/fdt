create or replace package body fdt_pkb_apx_060207 is
   --
   -- @Author  SHQYMR 2021-12-16
   -- @usage   Page 060207 (Associations types services / qualifications)
   --
   --
   -- Modifié par : 
   -- Le          : 
   --
   cva_update_row_status constant varchar2(3) := 'U';
   cva_create_row_status constant varchar2(3) := 'C';
   cva_delete_row_status constant varchar2(3) := 'D';
   --
   cva_nom_collection    constant varchar2(30) := 'COL_060207';
   --
   vbo_min_1erreur       boolean := false;
   --
   --Variables utilisées pour le logger
   cva_scope_prefix constant varchar2(31) := lower($$plsql_unit) || '.';
   --
   --Variables pour utl_pkb_apx_message.f_obt_message
   vva_message      varchar2(4000)                       := null;
   vva_typ_message  utlt_message_trait.typ_message%type  := null;
   --
   --==================================================
   -- Procédures et fonctions
   --==================================================
   procedure p_supprimer_collection is
      pragma autonomous_transaction;
   begin
      if apex_collection.collection_exists(cva_nom_collection) Then
         apex_collection.delete_collection(cva_nom_collection);
      end if;
      --     
      commit;
   end p_supprimer_collection;
   --
   procedure p_ajouter_enreg_collection(pre_enreg            in fdtt_ass_typ_serv_qualf%rowtype,
                                        pva_apex$row_status  in varchar2) is
      pragma autonomous_transaction;
   begin
      if not apex_collection.collection_exists(cva_nom_collection) Then
         apex_collection.create_collection(cva_nom_collection);
      end if;
      --   
      apex_collection.add_member (p_collection_name => cva_nom_collection,
                                  p_n001            => pre_enreg.no_seq_ass_typ_serv_qualf,
                                  p_n002            => pre_enreg.no_seq_typ_service,
                                  p_n003            => pre_enreg.no_seq_qualification,
                                  p_d001            => pre_enreg.dt_debut,
                                  p_d002            => pre_enreg.dt_fin,
                                  p_c010            => pva_apex$row_status);
      commit;
   end p_ajouter_enreg_collection;
   --
   procedure p_valider_coherence (pnu_no_seq_typ_service    in number,
                                  pnu_no_seq_qualification  in number) is
      --
      -- Variables utilisées pour le logger
      vta_params logger.tab_param;
      --
      --Avoir une image complète des données BD + Apex
      cursor cur_ass_typ_serv_qualf is
         with apex_et_bd as
            (
            --On prend les insertions et modifications APEX
            select n001 as no_seq_ass_typ_serv_qualf,
                   n002 as no_seq_typ_service,
                   n003 as no_seq_qualification,
                   d001 as dt_debut,
                   d002 as dt_fin,
                   c010 as apex_row_status
            from   apex_collections
            where  collection_name = cva_nom_collection
              and  c010 in (cva_create_row_status, cva_update_row_status)
            union all
            --On prend de la BD les enregs qui n'ont pas été modifiés ou détruits dans APEX
            select no_seq_ass_typ_serv_qualf,
                   no_seq_typ_service,
                   no_seq_qualification,
                   dt_debut,
                   dt_fin,
                   'BD' as apex_row_status
            from   fdtt_ass_typ_serv_qualf
            where  no_seq_typ_service    = coalesce (pnu_no_seq_typ_service, no_seq_typ_service)
              and  no_seq_qualification  = coalesce (pnu_no_seq_qualification, no_seq_qualification)
              and  no_seq_ass_typ_serv_qualf not in (select n001
                                                     from   apex_collections apc
                                                     where collection_name = cva_nom_collection
                                                     and (n001 is not null or
                                                          c010 = cva_delete_row_status))
            )
         select apex_et_bd.no_seq_ass_typ_serv_qualf,
                apex_et_bd.no_seq_typ_service,
                ftyat.description                   typ_service_desc,
                apex_et_bd.no_seq_qualification,
                felquat.description                 qualification_desc,
                apex_et_bd.dt_debut,
                apex_et_bd.dt_fin,
                apex_et_bd.apex_row_status
         from   apex_et_bd
                left join fdtt_typ_service     ftyat    on ftyat.no_seq_typ_service      = apex_et_bd.no_seq_typ_service
                left join fdtt_qualification   felquat  on felquat.no_seq_qualification  = apex_et_bd.no_seq_qualification;
      --
      --==================================================Procédures et fonctions
      procedure p_valider_nombre_date_fin_gt1 is
         --
         cva_code_message utlt_message_trait.co_message%type := '000110';
         --
         cursor cur_liste_dt_fin_nulle_gt1 is
            select tab.no_seq_typ_service,
                   tab.typ_service_desc,
                   tab.no_seq_qualification,
                   tab.qualification_desc,
                   count(1)
            from   table(vta_rec_ass_typ_serv_qualf) tab
            where  tab.dt_fin is null
            having count(1) > 1
            group by tab.no_seq_typ_service,
                     tab.typ_service_desc,
                     tab.no_seq_qualification,
                     tab.qualification_desc;
         rec_liste_dt_fin_nulle_gt1   cur_liste_dt_fin_nulle_gt1%rowtype;
         --
      begin
         --         
         for rec_liste_dt_fin_nulle_gt1 in cur_liste_dt_fin_nulle_gt1 loop
            vbo_min_1erreur := true;
            --
            vva_message := utl_pkb_apx_message.f_obt_message (pva_code_systeme => fdt_pkb_apx_config.f_obtenir_code_systeme_fdt,
                                                              pva_code_messa   => cva_code_message,
                                                              pva_param_1      => 'Type service "'      || rec_liste_dt_fin_nulle_gt1.typ_service_desc
                                                                                  || '", Qualification "'  || rec_liste_dt_fin_nulle_gt1.qualification_desc
                                                                                  || '"'
                                                                                  ,
                                                              pva_type_messa   => vva_typ_message);
            --
            apex_error.add_error(p_message            => vva_message,
                                 p_display_location   => apex_error.c_inline_in_notification);
         end loop;
      end p_valider_nombre_date_fin_gt1;
      --
      procedure p_valider_chevauchement_date is
         --
         cva_code_message utlt_message_trait.co_message%type := '000111';
         --
         --Cursor qui vérifie si il y a un overlap sur les date de debut et de fin.
         cursor cur_overlap_date is
            with 
               groupe_dates as
                 (select tab.no_seq_typ_service,
                         tab.typ_service_desc,
                         tab.no_seq_qualification,
                         tab.qualification_desc,
                         tab.dt_debut,
                         tab.dt_fin,
                         case
                            when tab.dt_debut <= max (tab.dt_fin)
                                 over (partition by
                                       tab.no_seq_typ_service,
                                       tab.no_seq_qualification
                                       order by tab.no_seq_typ_service,
                                                tab.no_seq_qualification,
                                                tab.dt_debut,
                                                tab.dt_fin
                                       rows between unbounded preceding and 1 preceding) then
                                 utl_pkb_apx_constantes.f_obtenir_co_oui
                            else
                                 utl_pkb_apx_constantes.f_obtenir_co_non
                         end group_date_debut
                  from table(vta_rec_ass_typ_serv_qualf) tab
                 )
            select grd.no_seq_typ_service,
                   grd.typ_service_desc,
                   grd.no_seq_qualification,
                   grd.qualification_desc,
                   grd.dt_debut,
                   grd.group_date_debut
            from   groupe_dates grd
            where  group_date_debut = utl_pkb_apx_constantes.f_obtenir_co_oui;
         --   
      begin
         -- valider si il y a les chevauchemnents entre les dates de debut et de fin
         for rec_cur_overlap_date in cur_overlap_date loop
            vbo_min_1erreur := true;
            --
            vva_message := utl_pkb_apx_message.f_obt_message (pva_code_systeme => fdt_pkb_apx_config.f_obtenir_code_systeme_fdt,
                                                              pva_code_messa   => cva_code_message,
                                                              pva_param_1      => 'Type service "'      || rec_cur_overlap_date.typ_service_desc
                                                                                  || '", Qualification "'  || rec_cur_overlap_date.qualification_desc
                                                                                  || '"'
                                                                                  ,
                                                              pva_type_messa   => vva_typ_message);
            --
            apex_error.add_error(p_message            => vva_message,
                                 p_display_location   => apex_error.c_inline_in_notification);
         end loop;
      end p_valider_chevauchement_date;
      --
   begin
      --
      logger.append_param(p_params => vta_params, p_name => '======================================================Paramètres fonction', p_val => ' ');
      logger.append_param(p_params => vta_params, p_name => 'pnu_no_seq_typ_service',    p_val => pnu_no_seq_typ_service);
      logger.append_param(p_params => vta_params, p_name => 'pnu_no_seq_qualification',  p_val => pnu_no_seq_qualification);
      --
      if not apex_collection.collection_exists(cva_nom_collection) Then
         --S'il y a eu plusieurs lignes modifiées dans la IG (création, modification, supression), cette fonction de cohérence est appelée autant de fois.
         --Les validations de cohérence ont besoin d'être faites seulement une fois, donc pour les appels de cette fonction 2+ on ne les refait pas.
         logger.append_param(p_params => vta_params, p_name => '======================================================Informations', p_val => ' ');
         logger.append_param(p_params => vta_params, p_name => 'Collection ' || cva_nom_collection || ' vide - Les validations ont déjà été effectuées, on ne les refait pas.', p_val => ' ');
      else
         --Récupération des données de la table fdtt_ass_attribut
         open cur_ass_typ_serv_qualf;
         fetch cur_ass_typ_serv_qualf bulk collect into vta_rec_ass_typ_serv_qualf;
         close cur_ass_typ_serv_qualf;
         -- 
         for rec_ass_typ_serv_qualf in cur_ass_typ_serv_qualf loop
            logger.append_param(p_params => vta_params, p_name => '======================================================Enreg', p_val => ' ');
            logger.append_param(p_params => vta_params, p_name => 'no_seq_typ_service',    p_val => rec_ass_typ_serv_qualf.no_seq_typ_service);
            logger.append_param(p_params => vta_params, p_name => 'no_seq_qualification',  p_val => rec_ass_typ_serv_qualf.no_seq_qualification);
            logger.append_param(p_params => vta_params, p_name => 'dt_debut',              p_val => to_char (rec_ass_typ_serv_qualf.dt_debut, 'yyyy-mm-dd'));
            logger.append_param(p_params => vta_params, p_name => 'dt_fin',                p_val => to_char (rec_ass_typ_serv_qualf.dt_fin, 'yyyy-mm-dd'));
            logger.append_param(p_params => vta_params, p_name => 'apex_row_status',       p_val => rec_ass_typ_serv_qualf.apex_row_status);
         end loop;
         --
         p_supprimer_collection;
         --
         p_valider_nombre_date_fin_gt1;
         --
         p_valider_chevauchement_date;
      end if;
      --
      logger.log_error(p_text => cva_scope_prefix || 'p_valider_coherence', p_scope => cva_scope_prefix || 'p_valider_coherence', p_params => vta_params);
   end p_valider_coherence;
   --
begin
   --
   null;
   --
end fdt_pkb_apx_060207;
/
