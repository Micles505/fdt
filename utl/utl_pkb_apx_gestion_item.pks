create or replace package utl.utl_pkb_apx_gestion_item is

   -- Author  : SHQIAR
   -- Created : 2019-08-20 08:07:27
   -- Purpose : Package utilitaire pour les items apex.

   -- Public type declarations

   -- Public constant declarations

   -- Public variable declarations

   -- Public function and procedure declarations

   procedure p_assigner_libl_aucune_select;
   --
   -- Fonction qui retourne le libellé pour le placeholder des items selectlist.
   --
   function f_obtenir_libl_aucune_select
   
    return varchar2 result_cache;
   --
   -- Procedure qui assigne le place holder de recherhce pour les lov item shq 
   --
   procedure p_assigner_libl_ph_lov_item;
   --
   -- Fonction qui retourne le placeholder pour la recherche pour les lov item shq
   --
   function f_obtenir_libl_ph_lov_item return varchar2 result_cache;
   -- 
   -- Procedure qui assigne le format de la date d'audit
   --
   procedure p_assigner_format_date_audit;
   -- 
   -- Procedure qui assigne le texte dans la zone de recherche d'une adresse
   --
   procedure p_assigner_zone_rech_adresse;
   --
   -- fonction qui retourne le format de la date d'audit
   --
   function f_obtenir_format_date_audit return varchar2 deterministic;
   --
   -- Procedure qui assigne le place holder de date (AAAA-MM-JJ)
   --
   procedure p_assigner_libl_ph_date;
   --
   procedure p_assigner_libl_piece_jointe;
   --
   procedure p_assigner_libl_suivant;
   --
   procedure p_assigner_libl_precedent;
   --
   procedure p_assigner_libl_transmettre;
   --
   procedure p_assigner_libl_confirmer;
   --
end utl_pkb_apx_gestion_item;
/

