create or replace package body fdt_pkb_apx_060210 is
   -- ====================================================================================================
   -- Date        : 2022-02-10
   -- Par         : SHQYMR
   -- Description : Gérer les catégories activités / activités
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
   -- Valider si un traitement doit être affiché dans le menu burger dans
   -- intervention détail
   -- =========================================================================
   function valider_activite (pre_no_seq_activite fdtt_activites%rowtype) return varchar2 is
      --
      vva_desc_message      varchar2(400)                        := null;
      vva_typ_messa         utlt_message_trait.typ_message%type  := null;
    vnu_nbr_enreg         number := 0;
    --
    cursor cur_obt_nbr_generaux is
       select count(*) as nbr_enreg
         from   fdtt_activites act
         where  upper (act.co_typ_activite) = 'GENERAUX';
      --
    --
    --
      -- -------------------------------------------------------------------------------------------------
      --                                           logger
      -- -------------------------------------------------------------------------------------------------
      vva_scope logger_logs.scope%type := cva_scope_prefix || 'valider_activite';
      vta_params logger.tab_param;
    --
   begin
    --
      -- -------------------------------------------------------------------------------------------------
      --                                           logger
      -- -------------------------------------------------------------------------------------------------
      logger.append_param(p_params => vta_params,
                        p_name   => 'Début',
                          p_val    => 'valider_activite');
    --
      -- -------------------------------------------------------------------------------------------------
      -- Il ne peut y avoir une seule activité avec le type 'GENERAUX'
      -- -------------------------------------------------------------------------------------------------
    --
    open  cur_obt_nbr_generaux;
    fetch cur_obt_nbr_generaux into vnu_nbr_enreg;
    close cur_obt_nbr_generaux;
    --
    if upper (pre_no_seq_activite.co_typ_activite) = 'GENERAUX' then
       if pre_no_seq_activite.no_seq_activite is null and vnu_nbr_enreg = 1 then
        --
            vva_desc_message := utl_pkb_apx_message.f_obt_message (pva_code_systeme => 'FDT',
                                                                   pva_code_messa   => '000136',
                                                                   -- pva_param_1      => null,
                                                                   -- pva_param_2      => null,
                                                                   pva_type_messa   => vva_typ_messa);
     end if;
    end if;
    --
      -- -------------------------------------------------------------------------------------------------
      --                                           logger
      -- -------------------------------------------------------------------------------------------------
      logger.log_info(p_text   => 'Fin valider_activite ',
                    p_scope  => vva_scope,
                      p_params => vta_params);
    --
    return vva_desc_message;
      --
    exception when others then
                   apex_debug.info ('Exception valider_activite %s', sqlerrm);
           raise;
    --
   end valider_activite;
   --
end fdt_pkb_apx_060210;
/

