create or replace package body fdt_pkb_apx_010201 is
   -- ====================================================================================================
   -- Date        : 2022-05-24
   -- Par         : SHQCGE
   -- Description : Gérer les ressources
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
   -- =========================================================================
   -- Obtenir la provenance de l'employé (code indicateur interne/externe)
   -- =========================================================================
   function f_obt_code_interne_externe(pnu_co_employe_shq in fdtt_ressource.co_employe_shq%type) return varchar2 is
      --
	  vva_co_interne_exter   bust_employe.co_interne_exter%type;
	  --
	  --
      -- -------------------------------------------------------------------------------------------------
      --                                           Curseurs
      -- -------------------------------------------------------------------------------------------------
	  cursor cur_obt_code_interne_externe is
	     select emp.co_interne_exter
       from bust_employe emp 
       where emp.co_employe_shq = pnu_co_employe_shq;
	  --
	  --
      -- -------------------------------------------------------------------------------------------------
      --                                           logger
      -- -------------------------------------------------------------------------------------------------
      vva_scope logger_logs.scope%type := cva_scope_prefix || 'f_obt_code_interne_externe';
      vta_params logger.tab_param;
	  --
   begin
	  --
      -- -------------------------------------------------------------------------------------------------
      --                                           logger
      -- -------------------------------------------------------------------------------------------------
      logger.append_param(p_params => vta_params, 
	                      p_name   => 'Début',
                          p_val    => 'f_obt_code_interne_externe');
	    --
      -------------------------------------------------------------------------
	    -- Obtenir la provenance de l'employé
      -------------------------------------------------------------------------
	    open  cur_obt_code_interne_externe;
	       fetch cur_obt_code_interne_externe into vva_co_interne_exter;
	    close cur_obt_code_interne_externe;
	    --
	    --
      -- -------------------------------------------------------------------------------------------------
      --                                           logger
      -- -------------------------------------------------------------------------------------------------
      logger.log_info(p_text   => 'Fin f_obt_code_interne_externe ', 
	                  p_scope  => vva_scope,
                      p_params => vta_params);
      --
	    return vva_co_interne_exter;
	  --
	  exception when others then 
	                 apex_debug.info ('Exception f_obt_code_interne_externe %s', sqlerrm);
					 raise;
	  --
   end f_obt_code_interne_externe;
   --
      -- =========================================================================
   -- Obtenir le no_seq_ressource de l'employé
   -- =========================================================================
   function f_obt_pk_ressource(pnu_co_employe_shq in fdtt_ressource.co_employe_shq%type) return number is
      --
    vnu_no_seq_ressource   fdtt_ressource.no_seq_ressource%type;
    --
    --
      -- -------------------------------------------------------------------------------------------------
      --                                           Curseurs
      -- -------------------------------------------------------------------------------------------------
    cursor cur_obt_no_seq_ressource is
       select res.no_seq_ressource 
       from fdtt_ressource res
       where res.co_employe_shq = pnu_co_employe_shq;
    --
    --
      -- -------------------------------------------------------------------------------------------------
      --                                           logger
      -- -------------------------------------------------------------------------------------------------
      vva_scope logger_logs.scope%type := cva_scope_prefix || 'f_obt_pk_ressource';
      vta_params logger.tab_param;
    --
   begin
    --
      -- -------------------------------------------------------------------------------------------------
      --                                           logger
      -- -------------------------------------------------------------------------------------------------
      logger.append_param(p_params => vta_params, 
                        p_name   => 'Début',
                          p_val    => 'f_obt_pk_ressource');
      --
      -------------------------------------------------------------------------
      -- Obtenir la liste des employés du groupe en cours
      --
      -------------------------------------------------------------------------
    open  cur_obt_no_seq_ressource;
       fetch cur_obt_no_seq_ressource into vnu_no_seq_ressource;
    close cur_obt_no_seq_ressource;
    --
    --
      -- -------------------------------------------------------------------------------------------------
      --                                           logger
      -- -------------------------------------------------------------------------------------------------
      logger.log_info(p_text   => 'Fin f_obt_pk_ressource ', 
                    p_scope  => vva_scope,
                      p_params => vta_params);
      --
      return vnu_no_seq_ressource;
	 --
	 exception when others then 
	    apex_debug.info ('Exception f_obt_pk_ressource %s', sqlerrm);
		  raise;   
   end f_obt_pk_ressource;
   --
   --
   --
   -- =========================================================================
   -- Valider l'ajout d'une ressource
   -- =========================================================================
   function f_valider_ajout_ressource (pre_ressource in fdtt_ressource%rowtype) return varchar2 is
      --
      vva_desc_message    varchar2(400);
      vva_type_messa      utlt_message_trait.typ_message%type;
	  --
	  --
      -- -------------------------------------------------------------------------------------------------
      --                                           logger
      -- -------------------------------------------------------------------------------------------------
      vva_scope logger_logs.scope%type := cva_scope_prefix || 'f_valider_ajout_ressource';
      vta_params logger.tab_param;
	  --
   begin
	  --
      -- -------------------------------------------------------------------------------------------------
      --                                           logger
      -- -------------------------------------------------------------------------------------------------
      logger.append_param(p_params => vta_params, 
	                      p_name   => 'Début',
                          p_val    => 'f_valider_ajout_ressource');
	  --
      -- -------------------------------------------------------------------------------------------------
      -- Validation de l'ajout d'une ressource	  
      -- -------------------------------------------------------------------------------------------------
	  --
	  if ((pre_ressource.co_employe_shq is not null and (pre_ressource.nom is not null or pre_ressource.prenom is not null or pre_ressource.nom_firme is not null)) or
	      (pre_ressource.co_employe_shq is null and pre_ressource.nom is null and pre_ressource.prenom is null and pre_ressource.nom_firme is null))then
		 --
         vva_desc_message := utl_pkb_apx_message.f_obt_message (pva_code_systeme => 'FDT',
                                                                pva_code_messa   => '000156',
                                                                -- pva_param_1      => null,
                                                                -- pva_param_2      => null,
                                                                pva_type_messa   => vva_type_messa);
	  end if;
      --
      -- -------------------------------------------------------------------------------------------------
      --                                           logger
      -- -------------------------------------------------------------------------------------------------
      logger.log_info(p_text   => 'Fin f_valider_ajout_ressource ', 
	                  p_scope  => vva_scope,
                      p_params => vta_params);
	  --
	  return vva_desc_message;
      --
	  exception when others then 
	                 apex_debug.info ('Exception f_valider_ajout_ressource %s', sqlerrm);
					 raise;
	  --
   end f_valider_ajout_ressource;
end fdt_pkb_apx_010201;
/
