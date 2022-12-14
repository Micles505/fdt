create or replace package utl.utl_pkb_apx_gerer_langues is
  /**
  Package pour changer la langue de la session en cours.
  
  --====================================================================================================
  -- Date : 2020-06-04
  -- Par : Christian Grenier
  -- Description : Création initiale du package
  --====================================================================================================
  -- Date : 
  -- Par : 
  -- Description : 
  --====================================================================================================
  */

  procedure p_definir_contexte_lang_apex(pva_code_lang_apex in apex_application_translations.language_code%type default apex_util.get_session_lang);
  --
  function f_obtenir_contexte_lang_apex return varchar2;
  --
  function f_obt_contexte_lang_apex_f_a return varchar2;
  --  
  /** Changer langue des éléments chargés lors de la création de la session
  */
  procedure p_changer_langue_session;
  --
  function f_obtenir_code_lang_apex_en return varchar2 deterministic;
  --
  function f_obtenir_code_lang_a return varchar2 deterministic;
  --
  function f_obtenir_code_lang_apex_fr return varchar2 deterministic;
  --
  function f_obtenir_code_lang_f return varchar2 deterministic;
  --

end utl_pkb_apx_gerer_langues;
/

