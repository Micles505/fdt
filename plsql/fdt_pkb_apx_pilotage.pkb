create or replace package body fdt_pkb_apx_pilotage is
   --
   -- Author  : SHQSBB
   -- Created : 2021-03-12
   -- Purpose : Fonctions utilisées par la facette pilotage
   --
   -- Modifié par : Yves Marcotte
   -- Le          : 2021-12-13
   --
   --logger
   cva_scope_prefix  constant varchar2(31) := lower($$plsql_unit) || '.';
   --
   --Variables pour messages d'erreurs
   cva_code_others   constant varchar2(10) default 'ZZZ.900039'; --Une erreur inattendue s'est produite, contacter le responsable informatique pour la consultation du journal d'événements.
   vva_type_message  utlt_message_trait.typ_message%type;
   vva_message       varchar2(4000);

   -- @return Code statut direction
   function f_obt_code_sta_direction (pnu_no_seq_direction in number) return varchar2 is
      --logger
      vva_scope  logger_logs.scope%type := cva_scope_prefix || 'f_obt_code_sta_direction';
      vta_params logger.tab_param;

      cursor cur_co_sta_direction is
         select co_sta_direction
         from fdtt_direction
         where no_seq_direction = pnu_no_seq_direction;
      rec_cur_co_sta_direction   cur_co_sta_direction%rowtype;
      --
   begin
	  --
      -- -------------------------------------------------------------------------------------------------
      --                                           logger
      -- -------------------------------------------------------------------------------------------------
      logger.append_param(p_params => vta_params, 
	                      p_name   => 'Début',
                          p_val    => 'f_obt_code_sta_direction');
      --
      if (pnu_no_seq_direction is not null) then
         open cur_co_sta_direction;
         fetch cur_co_sta_direction into rec_cur_co_sta_direction;
         if (cur_co_sta_direction%notfound) then
            raise no_data_found;
         end if;
         close cur_co_sta_direction;
      else
         return null;
      end if;
	  --
      -- -------------------------------------------------------------------------------------------------
      --                                           logger
      -- -------------------------------------------------------------------------------------------------
      logger.log_info(p_text   => 'Fin f_obt_code_sta_direction ', 
	                  p_scope  => vva_scope,
                      p_params => vta_params);
	  --
      return rec_cur_co_sta_direction.co_sta_direction;
      --
   exception
      when others Then
         vva_message := utl_pkb_apx_message.f_obt_message(pva_code_messa   => cva_code_others,
                                                          pva_type_messa   => vva_type_message);
         --
         logger.append_param(p_params => vta_params, p_name => 'pnu_no_seq_direction', p_val => to_char (pnu_no_seq_direction));
         --
         logger.log_error(p_text => vva_message, p_scope => vva_scope, p_params => vta_params);
         raise;
         --
   end f_obt_code_sta_direction;
   --
   -- @return Données table fdtt_typ_intervention
   function f_obt_data_typ_intervention (pnu_no_seq in number) return rec_typ_intervention is
      --logger
      vva_scope  logger_logs.scope%type := cva_scope_prefix || 'f_obt_data_typ_intervention';
      vta_params logger.tab_param;
      --
      cursor cur_data is
         select typintrv.no_seq_typ_intervention,
                typintrv.no_seq_direction,
                typintrv.co_typ_intervention,
                dir.description || ' / ' || typintrv.description,
                typintrv.co_sta_typ_intervention,
                typintrv.co_user_cre_enreg,
                typintrv.co_user_maj_enreg,
                typintrv.dh_cre_enreg,
                typintrv.dh_maj_enreg
         from   fdtt_direction         dir,
                fdtt_typ_intervention  typintrv
         where  typintrv.no_seq_direction         = dir.no_seq_direction
           and  typintrv.no_seq_typ_intervention  = pnu_no_seq;
      --
      rec_cur_data   cur_data%rowtype;
      --
   begin
      --
      if (pnu_no_seq is not null) then
         open cur_data;
         fetch cur_data into rec_cur_data;
         if (cur_data%notfound) then
            raise no_data_found;
         end if;
         close cur_data;
      else
         return null;
      end if;
      --
      return rec_cur_data;
      --
   exception
      when others Then
         vva_message := utl_pkb_apx_message.f_obt_message(pva_code_messa   => cva_code_others,
                                                          pva_type_messa   => vva_type_message);
         --
         logger.append_param(p_params => vta_params, p_name => 'pnu_no_seq', p_val => to_char (pnu_no_seq));
         --
         logger.log_error(p_text => vva_message, p_scope => vva_scope, p_params => vta_params);
         raise;
   end f_obt_data_typ_intervention;
   --
   -- @return Données table fdtt_typ_service
   function f_obt_data_typ_service (pnu_no_seq in number) return rec_typ_service is
      --logger
      vva_scope  logger_logs.scope%type := cva_scope_prefix || 'f_obt_data_typ_service';
      vta_params logger.tab_param;
      --
      cursor cur_data is
         select typserv.no_seq_typ_service,
                typserv.no_seq_direction,
                typserv.co_typ_service,
                dir.description || ' / ' || typserv.description,
                typserv.co_sta_typ_service,
                typserv.co_user_cre_enreg,
                typserv.co_user_maj_enreg,
                typserv.dh_cre_enreg,
                typserv.dh_maj_enreg
         from   fdtt_direction         dir,
                fdtt_typ_service       typserv
         where  typserv.no_seq_direction    = dir.no_seq_direction
           and  typserv.no_seq_typ_service  = pnu_no_seq;
      --
      rec_cur_data   cur_data%rowtype;
      --
   begin
      --
      if (pnu_no_seq is not null) then
         open cur_data;
         fetch cur_data into rec_cur_data;
         if (cur_data%notfound) then
            raise no_data_found;
         end if;
         close cur_data;
      else
         return null;
      end if;
      --
      return rec_cur_data;
      --
   exception
      when others Then
         vva_message := utl_pkb_apx_message.f_obt_message(pva_code_messa   => cva_code_others,
                                                          pva_type_messa   => vva_type_message);
         --
         logger.append_param(p_params => vta_params, p_name => 'pnu_no_seq', p_val => to_char (pnu_no_seq));
         --
         logger.log_error(p_text => vva_message, p_scope => vva_scope, p_params => vta_params);
         raise;
   end f_obt_data_typ_service;
   --
   -- @return Données table fdtt_attrb_typ_intervention
--   function f_obt_data_attrb_typ_interv (pnu_no_seq in number) return fdtt_attrb_typ_intervention%rowtype is
--      --logger
--      vva_scope  logger_logs.scope%type := cva_scope_prefix || 'f_obt_data_attrb_typ_interv';
--      vta_params logger.tab_param;
--      --
--      cursor cur_data is
--         select *
--         from fdtt_attrb_typ_intervention
--         where no_seq_attrb_typ_intrv = pnu_no_seq;
--      rec_cur_data   cur_data%rowtype;
--      --
--   begin
--      --
--      if (pnu_no_seq is not null) then
--         open cur_data;
--         fetch cur_data into rec_cur_data;
--         if (cur_data%notfound) then
--            raise no_data_found;
--         end if;
--         close cur_data;
--      else
--         return null;
--      end if;
--      --
--      return rec_cur_data;
--      --
--   exception
--      when others Then
--         vva_message := utl_pkb_apx_message.f_obt_message(pva_code_messa   => cva_code_others,
--                                                          pva_type_messa   => vva_type_message);
--
--         logger.append_param(p_params => vta_params, p_name => 'pnu_no_seq', p_val => to_char (pnu_no_seq));
--
--         logger.log_error(p_text => vva_message, p_scope => vva_scope, p_params => vta_params);
--         raise;
--   end f_obt_data_attrb_typ_interv; 
   --
   -- @return Données table fdtt_qualification_attribut
   function f_obt_data_qualification (pnu_no_seq in number) return fdtt_qualification%rowtype is
      --logger
      vva_scope  logger_logs.scope%type := cva_scope_prefix || 'f_obt_data_qualification';
      vta_params logger.tab_param;

      cursor cur_data is
         select *
         from fdtt_qualification
         where no_seq_qualification = pnu_no_seq;
      rec_cur_data   cur_data%rowtype;
      --
   begin
      --
      if (pnu_no_seq is not null) then
         open cur_data;
         fetch cur_data into rec_cur_data;
         if (cur_data%notfound) then
            raise no_data_found;
         end if;
         close cur_data;
      else
         return null;
      end if;
      --
      return rec_cur_data;
      --
   exception
      when others Then
         vva_message := utl_pkb_apx_message.f_obt_message(pva_code_messa   => cva_code_others,
                                                          pva_type_messa   => vva_type_message);

         logger.append_param(p_params => vta_params, p_name => 'pnu_no_seq', p_val => to_char (pnu_no_seq));

         logger.log_error(p_text => vva_message, p_scope => vva_scope, p_params => vta_params);
         raise;
   end f_obt_data_qualification;
   --
end fdt_pkb_apx_pilotage;
/
