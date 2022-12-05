create or replace package fdt_pkb_apx_010206 is
   -- ====================================================================================================
   -- Date        : 2021-09-14
   -- Par         : SHQCGE
   -- Description : Gérer la page de retour d'un employé
   -- ====================================================================================================
   -- Date        :
   -- Par         :
   -- Description :
   -- ====================================================================================================
   -- ===========================================================================================
   -- Procédure qui permet de gérer le retour d'un employe
   -- ===========================================================================================
   --
   procedure p_gerer_retour_employe(pnu_no_seq_ressource in fdtt_feuilles_temps.no_seq_ressource%type,
                                    pva_an_mois_fdt      in fdtt_feuilles_temps.an_mois_fdt%type,
                                    vva_transferer_solde in varchar2);
   --
end fdt_pkb_apx_010206;
/

