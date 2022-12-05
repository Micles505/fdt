create or replace package body fdt_pkb_apx_config is
   --====================================================================================================
   -- Date        : 2021-02-10
   -- Par         : Stéphane Baribeau
   -- Description : Création initiale du package
   --====================================================================================================
   -- Date        : 
   -- Par         : 
   -- Description : 
   --====================================================================================================

   cva_ea_systeme_fdt constant varchar2(03) default 'FDT';
   cdt_activation     constant busv_util_exter_ins.autor_dt_activation%type default utl_fnb_obt_dt_prodc(pva_co_systeme => cva_ea_systeme_fdt,
                                                                                                         pva_form_date  => 'DA');

   -- logger
   cva_scope_prefix constant varchar2(31) := lower($$plsql_unit) || '.';
   
   -- @return Le code de systeme FDT
   function f_obtenir_code_systeme_fdt return varchar2 deterministic is
   begin
      return cva_ea_systeme_fdt;
   end f_obtenir_code_systeme_fdt;

   -- @return Le nom de l'application APEX pour FDT
   function f_obtenir_nom_application return varchar2 result_cache is
      cva_titre_app_fdt   pilv_valeur_parametre.val_parametre%type default 'TITRE_APPLI_APX_FDT';
   
      -- logger
      vva_scope  logger_logs.scope%type := cva_scope_prefix || 'f_obtenir_nom_application';
      vta_params logger.tab_param;
   begin
      -- NoFormat Start  
      return pil_pkb_parametre.obt_char(pva_co_parametre => cva_titre_app_fdt,
                                        pdt_dt_sys       => cdt_activation,
                                        pva_co_systeme   => cva_ea_systeme_fdt,
                                        pva_co_programme => null, 
                                        pva_co_volet     => null);
      -- NoFormat End                                
   end f_obtenir_nom_application;
end fdt_pkb_apx_config;
/
