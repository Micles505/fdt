create or replace package fdt_pkb_apx_ressource is
  --
  -- @author  SHQCGE
  --          2021-04-01 13:11:30
  -- @usage   Gestion des ressources (qui inclu aménagement de temps de travail et les informations supplémentaires)
  --
  -- Public type declarations
  -- type <TypeName> is <Datatype>;
  --
  -- Public constant declarations
  -- <ConstantName> constant <Datatype> := <Value>;
  --
  -- Public variable declarations
  --<VariableName> <Datatype>;
  --
  -- Public function and procedure declarations
  --  
  -- =================================================================================================
   -- Validations de la table aménagement de temps de travail associé à l'application FDT
   --  
   -- Paramètres entrants : 
   --    --> vtp_detail_att    --> Ensemble des champs de la table FDTT_DETAIL_ATT
   --    --> p_type_operation  --> REQUEST de la page Apex 
   -- 
   -- Paramètres sortants : Aucun
   -- =================================================================================================
   procedure p_valdt_apx_detail_att(vtp_detail_att   in fdtt_details_att%rowtype,
									p_type_operation in varchar2); 
   --
   --
  -- =================================================================================================
   -- Validations de la table ressource information supplémentaire associé à l'application FDT
   --  
   -- Paramètres entrants : 
   --    --> vtp_ressource_info_suppl --> Ensemble des champs de la table FDTT_RESSOURCE_INFO_SUPPL
   --    --> p_type_operation         --> REQUEST de la page Apex 
   -- 
   -- Paramètres sortants : Aucun
   -- =================================================================================================
   procedure p_valdt_apx_ressource_info_suppl(vtp_ressource_info_suppl in fdtt_ressource_info_suppl%rowtype,
									          p_type_operation in varchar2); 
      
   --
end fdt_pkb_apx_ressource;
/

