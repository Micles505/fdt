create or replace package fdt_pkb_apx_config is

   -- Author  : SHQIAR
   -- Created : 2020-12-11 13:14:11
   -- Purpose : Configuration du système FDT

   -- @return Le code de systeme FDT
   function f_obtenir_code_systeme_fdt return varchar2 deterministic;

   -- @return Le nom de l'application APEX pour FDT
   function f_obtenir_nom_application return varchar2 result_cache;
   
end fdt_pkb_apx_config;
/
