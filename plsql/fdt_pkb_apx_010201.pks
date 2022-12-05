create or replace package fdt_pkb_apx_010201 is
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
   -- =========================================================================
   -- Obtenir la provenance de l'employé (code indicateur interne/externe)
   -- =========================================================================
   function f_obt_code_interne_externe(pnu_co_employe_shq in fdtt_ressource.co_employe_shq%type) return varchar2;
   --
   --
   -- =========================================================================
   -- Obtenir la provenance de l'employé (code indicateur interne/externe)
   -- =========================================================================
   function f_obt_pk_ressource(pnu_co_employe_shq in fdtt_ressource.co_employe_shq%type) return number;
   --
   -- =========================================================================
   -- Valider les ressources des interventions détail
   -- =========================================================================
   function f_valider_ajout_ressource (pre_ressource in fdtt_ressource%rowtype) return varchar2;
   --
end fdt_pkb_apx_010201;
/
