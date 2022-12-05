create or replace package body fdt_pkb_apx_060209 is
   --
   -- Modifié par : Yves Marcotte
   -- Le          : 2021-12-15
   --
   cva_update_row_status constant varchar2(3) := 'U';
   cva_create_row_status constant varchar2(3) := 'C';
--   cva_delete_row_status constant varchar2(3) := 'D';
   --
   cva_nom_collection    constant varchar2(30) := 'COL_060209';
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
   --================================================================================
   --                           Procédures et fonctions
   --================================================================================
   --
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
   --
   -- ---------------------------------------------------------
   -- Remplir la collection
   -- ---------------------------------------------------------
   procedure p_ajouter_enreg_collection(pre_enreg            in fdtt_ass_typ_intrv_qualf%rowtype,
                                        pva_apex$row_status  in varchar2) is
      pragma autonomous_transaction;
   begin
      if not apex_collection.collection_exists(cva_nom_collection) Then
         apex_collection.create_collection(cva_nom_collection);
      end if;
      --   
      apex_collection.add_member (p_collection_name => cva_nom_collection,
                                  p_n001            => pre_enreg.no_seq_ass_typ_intrv_qualf,
                                  p_n002            => pre_enreg.no_seq_typ_intervention,
                                  p_n003            => pre_enreg.no_seq_qualification,
                                  p_d001            => pre_enreg.dt_debut,
                                  p_d002            => pre_enreg.dt_fin,
                                  p_c010            => pva_apex$row_status);
      commit;
   end p_ajouter_enreg_collection;
   --
   -- ---------------------------------------------------------
   -- Valider la cohérence
   -- ---------------------------------------------------------
   procedure p_valider_coherence (pnu_no_seq_direction        in number,
                                  pnu_no_seq_typ_intervention in number,
                                  pnu_no_seq_qualification    in number) is
      --
      -- Variables utilisées pour le logger
	  --
      vta_params logger.tab_param;
      --
      -- Avoir une image complète des données BD + Apex
	  --
      cursor cur_ass_typ_intrv_qualf is
         with apex_et_bd as (
		                     --
                             -- On prend les insertions et modifications APEX
							 --
                             select n001 as no_seq_ass_typ_intrv_qualf,
                                    n002 as no_seq_typ_intervention,
                                    n003 as no_seq_qualification,
                                    d001 as dt_debut,
                                    d002 as dt_fin,
                                    c010 as apex_row_status
                             from   apex_collections
                             where  collection_name = cva_nom_collection
                             and    c010 in (cva_create_row_status, cva_update_row_status)
                            )
         select apex_et_bd.no_seq_ass_typ_intrv_qualf,
                apex_et_bd.no_seq_typ_intervention,
                typ_intrv.description             typ_intervention_desc,
                apex_et_bd.no_seq_qualification,
                qualf.description                 qualification_desc,
                apex_et_bd.dt_debut,
                apex_et_bd.dt_fin,
                apex_et_bd.apex_row_status
         from   apex_et_bd                          apex_et_bd 
                left join fdtt_typ_intervention     typ_intrv  on typ_intrv.no_seq_typ_intervention = apex_et_bd.no_seq_typ_intervention
                left join fdtt_qualification        qualf      on qualf.no_seq_qualification        = apex_et_bd.no_seq_qualification
	     where  apex_et_bd.no_seq_typ_intervention    = pnu_no_seq_typ_intervention
		 and    apex_et_bd.no_seq_qualification       = pnu_no_seq_qualification
	     union
		 select ass.no_seq_ass_typ_intrv_qualf,
		        ass.no_seq_typ_intervention,
                typ_intrv.description             typ_intervention_desc,
				ass.no_seq_qualification,
                qualf.description                 qualification_desc,
				ass.dt_debut,
				ass.dt_fin,
				cva_update_row_status as apex_row_status
         from   fdtt_ass_typ_intrv_qualf ass
                left join fdtt_typ_intervention     typ_intrv  on typ_intrv.no_seq_typ_intervention = ass.no_seq_typ_intervention
				                                                  and typ_intrv.no_seq_direction    = pnu_no_seq_direction
                left join fdtt_qualification        qualf      on qualf.no_seq_qualification        = ass.no_seq_qualification
				                                                  and qualf.no_seq_direction        = pnu_no_seq_direction
	     where  ass.no_seq_typ_intervention    = pnu_no_seq_typ_intervention
		 and    ass.no_seq_qualification       = pnu_no_seq_qualification
		 and    ass.no_seq_ass_typ_intrv_qualf not in (select apex_et_bd.no_seq_ass_typ_intrv_qualf
				                                       from   apex_et_bd);
      --
      --
	  -- Valider s'il y a plus qu'une date de fin à null
	  --
      procedure p_valider_nbr_date_fin_null is
         --
         cva_code_message utlt_message_trait.co_message%type := '000110';
         --
         cursor cur_liste_dt_fin_nulle_gt1 is
            select tab.no_seq_typ_intervention,
                   tab.typ_intervention_desc,
                   tab.no_seq_qualification,
                   tab.qualification_desc,
                   count(1)
            from   table(vta_rec_ass_typ_intrv_qualf) tab
            where  tab.dt_fin is null
            having count(1) > 1
            group by tab.no_seq_typ_intervention,
                     tab.typ_intervention_desc,
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
                                                              pva_param_1      => 'Type intervention "'   || rec_liste_dt_fin_nulle_gt1.typ_intervention_desc
                                                                                  || '", Qualification "' || rec_liste_dt_fin_nulle_gt1.qualification_desc
                                                                                  || '"'
                                                                                  ,
                                                              pva_type_messa   => vva_typ_message);
            --
            apex_error.add_error(p_message            => vva_message,
                                 p_display_location   => apex_error.c_inline_in_notification);
         end loop;
      end p_valider_nbr_date_fin_null;
      --
      --
	  -- Valider s'il y a un chevauchement dans les date
	  -- selon le type intervention / qualification
	  --
      procedure p_valider_chevauchement_date is
         --
         cva_code_message utlt_message_trait.co_message%type := '000111';
         --
         --Cursor qui vérifie si il y a un overlap sur les date de debut et de fin.
         cursor cur_overlap_date is
            with 
               groupe_dates as
                 (select tab.no_seq_typ_intervention,
                         tab.typ_intervention_desc,
                         tab.no_seq_qualification,
                         tab.qualification_desc,
                         tab.dt_debut,
                         tab.dt_fin,
                         case
                            when tab.dt_debut <= max (tab.dt_fin)
                                 over (partition by
                                       tab.no_seq_typ_intervention,
                                       tab.no_seq_qualification
                                 order by tab.no_seq_typ_intervention,
                                          tab.no_seq_qualification,
                                          tab.dt_debut,
                                          tab.dt_fin
                                 rows between unbounded preceding and 1 preceding) then
                                 utl_pkb_apx_constantes.f_obtenir_co_oui
                            else
                                 utl_pkb_apx_constantes.f_obtenir_co_non
                         end group_date_debut
                  from table(vta_rec_ass_typ_intrv_qualf) tab
                 )
            select grd.no_seq_typ_intervention,
                   grd.typ_intervention_desc,
                   grd.no_seq_qualification,
                   grd.qualification_desc,
                   grd.dt_debut,
                   grd.group_date_debut
            from   groupe_dates grd
            where  group_date_debut = utl_pkb_apx_constantes.f_obtenir_co_oui;
         --   
      begin
	     --
         -- valider si il y a les chevauchemnents entre les dates de debut et de fin
		 --
         for rec_cur_overlap_date in cur_overlap_date loop
            vbo_min_1erreur := true;
            --
            vva_message := utl_pkb_apx_message.f_obt_message (pva_code_systeme => fdt_pkb_apx_config.f_obtenir_code_systeme_fdt,
                                                              pva_code_messa   => cva_code_message,
                                                              pva_param_1      => 'Type intervention "'   || rec_cur_overlap_date.typ_intervention_desc
                                                                                  || '", Qualification "' || rec_cur_overlap_date.qualification_desc
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
      logger.append_param(p_params => vta_params, p_name => 'pnu_no_seq_typ_intervention',    p_val => pnu_no_seq_typ_intervention);
      logger.append_param(p_params => vta_params, p_name => 'pnu_no_seq_qualification',       p_val => pnu_no_seq_qualification);
      --
      if not apex_collection.collection_exists(cva_nom_collection) Then
	     --
         -- S'il y a eu plusieurs lignes modifiées dans la IG (création, modification, supression), cette fonction de cohérence est appelée autant de fois.
         -- Les validations de cohérence ont besoin d'être faites seulement une fois, donc pour les appels de cette fonction 2+ on ne les refait pas.
		 --
         logger.append_param(p_params => vta_params, p_name => '======================================================Informations', p_val => ' ');
         logger.append_param(p_params => vta_params, p_name => 'Collection ' || cva_nom_collection || ' vide - Les validations ont déjà été effectuées, on ne les refait pas.', p_val => ' ');
      else
	     --
         -- Récupération des données de la table fdtt_ass_typ_intrv_qualf
		 --
         open cur_ass_typ_intrv_qualf;
         fetch cur_ass_typ_intrv_qualf bulk collect into vta_rec_ass_typ_intrv_qualf;
         close cur_ass_typ_intrv_qualf;
         -- 
         for rec_ass_typ_intrv_qualf in cur_ass_typ_intrv_qualf loop
            logger.append_param(p_params => vta_params, p_name => '======================================================Enreg', p_val => ' ');
            logger.append_param(p_params => vta_params, p_name => 'no_seq_typ_intervention',    p_val => rec_ass_typ_intrv_qualf.no_seq_typ_intervention);
            logger.append_param(p_params => vta_params, p_name => 'no_seq_qualification',       p_val => rec_ass_typ_intrv_qualf.no_seq_qualification);
            logger.append_param(p_params => vta_params, p_name => 'dt_debut',                   p_val => to_char (rec_ass_typ_intrv_qualf.dt_debut, 'yyyy-mm-dd'));
            logger.append_param(p_params => vta_params, p_name => 'dt_fin',                     p_val => to_char (rec_ass_typ_intrv_qualf.dt_fin, 'yyyy-mm-dd'));
            logger.append_param(p_params => vta_params, p_name => 'apex_row_status',            p_val => rec_ass_typ_intrv_qualf.apex_row_status);
         end loop;
         --
         p_supprimer_collection;
         --
		 if vta_rec_ass_typ_intrv_qualf.count > 1 Then
           p_valider_nbr_date_fin_null;
           --
           p_valider_chevauchement_date;
		 end if;
      end if;
      --
      logger.log_error(p_text => cva_scope_prefix || 'p_valider_coherence', p_scope => cva_scope_prefix || 'p_valider_coherence', p_params => vta_params);
   end p_valider_coherence;
   --
end fdt_pkb_apx_060209;
/

