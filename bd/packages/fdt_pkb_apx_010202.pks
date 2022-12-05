create or replace package fdt_pkb_apx_010202 is
   -- ====================================================================================================
   -- Date        : 2021-11-10
   -- Par         : SHQYMR
   -- Description : Gérer les groupes FDT
   -- ====================================================================================================
   -- Date        :
   -- Par         :
   -- Description :
   -- ====================================================================================================
   --
   --
   -- =========================================================================
   -- Valider les dates des interventions détail
   -- =========================================================================
   procedure p_traiter_ressources (pva_liste_empl_grp in varchar2,
                                   pnu_no_seq_groupe  in number);
   --
   --
   -- =========================================================================
   -- Valider les dates des interventions détail
   -- =========================================================================
   function f_obt_liste_emp_grp (pnu_no_seq_groupe in fdtt_assoc_employes_grp.no_seq_groupe%type) return varchar2;
   --
   --
   -- =========================================================================
   -- Valider les dates des interventions détail
   -- =========================================================================
   function f_obt_liste_unite_organ (pnu_no_seq_groupe in fdtt_assoc_employes_grp.no_seq_groupe%type) return varchar2;
   --
end fdt_pkb_apx_010202;
/

