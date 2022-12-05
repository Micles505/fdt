create or replace package fdt_pkb_apx_060210 is
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
   -- =========================================================================
   -- Valider si un traitement doit être affiché dans le menu burger dans
   -- intervention détail
   -- =========================================================================
   function valider_activite (pre_no_seq_activite fdtt_activites%rowtype) return varchar2;
   --
end fdt_pkb_apx_060210;
/
