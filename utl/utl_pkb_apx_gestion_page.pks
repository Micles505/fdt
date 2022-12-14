create or replace package utl.utl_pkb_apx_gestion_page as
  /**
  Outils de gestion des pages APEX.

  --====================================================================================================
  -- Date : 2019-06-20
  -- Par : Stéphane Baribeau
  -- Description : Création initiale du package
  --====================================================================================================
  -- Date :
  -- Par :
  -- Description :
  --====================================================================================================
  */
  function f_condition_process_row(pva_request in varchar2) return boolean deterministic;
  --------------------------------
  -- Obtenir l'alias de la page
  --------------------------------
  function f_obtenir_alias_page(pnu_app_id  in apex_application_pages.application_id%type,
                                pnu_page_id in apex_application_pages.page_id%type) return apex_application_pages.page_alias%type result_cache;
  --
  function f_obtenir_page_titre(pnu_app_id  in apex_application_pages.application_id%type,
                                pnu_page_id in apex_application_pages.page_id%type) return varchar2 result_cache;
  --
  /**
  Fonction qui test si le request est DELETE CREATE_ADD et SAVE_ADD
  */
  function f_est_condition_reset_bl(pva_request in varchar2 default null) return boolean result_cache;
  /**
  Fonction qui test si le request est DELETE CREATE_ADD et SAVE_ADD
  */
  function f_est_condition_reset(pva_request in varchar2 default null) return varchar2 result_cache;
  --
end utl_pkb_apx_gestion_page;
/

