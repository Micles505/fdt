create or replace package utl.utl_pkb_apx_item_menu_apex as
  -- ====================================================================================================
  -- Date        : 2019-11-07
  -- Par         : Yves Marcotte
  -- Description : Création initiale du package
  -- ====================================================================================================
  -- Date        : 
  -- Par         : 
  -- Description : 
  -- ====================================================================================================
  -- Ce package est utilisé uniquement par le portail de la SHQ.
  -- ====================================================================================================
  --
  --
  -- =================================================================================================
  -- Obtenir la valeur par défaut pour le Type Application
  -- =================================================================================================
  function f_obtenir_defaut_typ_appl return varchar2 deterministic;
  --
  -- =================================================================================================
  -- Validations de la table des applications du portail dans le Portail SHQ
  --  
  -- Paramètres entrants : 
  --    --> p_portail_appli  --> Ensemble des champs de la table UTLT_PORTAIL_APPLI
  --    --> p_type_operation --> REQUEST de la page Apex 
  -- 
  -- Paramètres sortants : Aucun
  -- =================================================================================================
  procedure p_valdt_item_menu_apex(p_item_menu_apex in utlt_item_menu_apex%rowtype, p_type_operation in varchar2);
  --
  -- =================================================================================================
  -- Obtenir le code libellé TEXTE
  -- =================================================================================================
  function f_obternir_cod_libel_texte return varchar2 deterministic;
  --
  -- =================================================================================================
  -- Obtenir la valeur par défaut de placeholder condition d'affichage
  -- =================================================================================================
  function f_obtenir_placeholder_cond_af return varchar2 result_cache;
  --
  -- =================================================================================================
  -- Établir l'intégrité selon le type d'application
  --
  -- *** Procedure qui met à null les champs nécessaires selon le type d'application appelé
  -- =================================================================================================
  procedure p_integriter_typ_appli_menu(pva_typ_aplication       in utlt_item_menu_apex.typ_application%type,
                                        pva_url                  in out nocopy utlt_item_menu_apex.url_applicat%type,
                                        pnu_no_seq_portail_appli in out nocopy utlt_item_menu_apex.no_seq_portail_appli%type,
                                        pva_no_page_apex         in out nocopy utlt_item_menu_apex.no_page_apex%type,
                                        pva_nom_req_soum         in out nocopy utlt_item_menu_apex.nom_req_soum%type,
                                        pva_no_seq_application   in out nocopy utlt_item_menu_apex.no_seq_application%type);
  --
  --
  -- =================================================================================================
  -- Obtenir le libellé du fil d'Ariane pour les items de menu
  -- =================================================================================================
  function f_obtenir_fa_item_menu(pnu_no_seq_menu_apx in utlt_item_menu_apex.no_seq_menu_apx%type) return varchar2;
  --
  --
  -- =================================================================================================
  -- Obtenir le CO_ITEM_APX suivant dans la table UTL_ITEM_MENU_APEX
  -- =================================================================================================
  function f_obt_co_item_apex_suivant(pnu_no_seq_menu_apx in utlt_item_menu_apex.no_seq_menu_apx%type,
                                      pva_typ_application in utlt_item_menu_apex.typ_application%type) return varchar2;
  --
  -- @usage Fonction qui retourne la valeur de l'application SHQ.
  -- @param la sequence de l'application SHQ
  -- @return la valeur du parametre systeme 
  -- 
  function f_obt_valeur_application_shq(pnu_no_seq_application in bust_application.no_seq_application%type)
    return varchar2;
  --
	--
end utl_pkb_apx_item_menu_apex;
/

