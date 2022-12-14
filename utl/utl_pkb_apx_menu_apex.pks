create or replace package utl.utl_pkb_apx_menu_apex is
   -- ====================================================================================================
   -- Date        : 2019-07-09
   -- Par         : SHQIAR
   -- Description : Gestion des menus dynamique APEX
   -- ====================================================================================================
   -- Date        : 2019-11-07
   -- Par         : Yves Marcotte
   -- Description : Déplacement d'une fonction de validation vers utl_pkb_apx_item_menu_apex
   -- ====================================================================================================
   -- Ce package est utilisé uniquement par le portail de la SHQ.
   -- ====================================================================================================
   --
   -- =================================================================================================
   -- Obtenir le Type Application APEX
   -- =================================================================================================
   function f_obtenir_typ_appli_apex return varchar2 deterministic;
   --
   -- =================================================================================================
   -- Obtenir le Type Application FORMS
   -- =================================================================================================
   function f_obtenir_typ_appli_forms return varchar2 deterministic;
   --
   -- =================================================================================================
   -- Obtenir le Type Application GROUPE
   -- =================================================================================================
   function f_obtenir_typ_appli_group return varchar2 deterministic;
   --
   -- =================================================================================================
   -- Obtenir le Type Application URL
   -- =================================================================================================
   function f_obtenir_typ_appli_url return varchar2 deterministic;
   --
   -- =================================================================================================
   -- Obtenir le nom du menu
   --
   --    pnu_no_seq_menu_apx in  - séquence du menu APEX
   -- =================================================================================================
   function f_obtenir_nom_menu (pnu_no_seq_menu_apx in utlt_item_menu_apex.no_seq_menu_apx%type)
                                return varchar2 result_cache;
   --
   -- =================================================================================================
   -- Obtenir le titre de l'application
   -- =================================================================================================
   function f_obtenir_titre_application return varchar2 deterministic;
   --
   --
   -- =================================================================================================
   -- Obtenir le CO_ITEM_APX suivant dans la table UTL_ITEM_MENU_APEX
   -- =================================================================================================
   function f_obt_co_menu_apex_suivant (pva_systeme in varchar2)
                                        return varchar2;
   --
end utl_pkb_apx_menu_apex;
/

