create or replace package utl.utl_pkb_apx_ig_selection is

  -- Author  : SHQIAR
  -- Created : 2022-10-26 20:14:20
  -- Purpose : 

  -- Public type declarations

  -- Public constant declarations

  -- Public variable declarations

  -- Public function and procedure declarations

  --
  -- Procedure qui enregistre les enregistrements dans la collection
  -- 
  procedure p_enregistrer_ig_selection(pva_nom_collection in apex_application.g_x01%type,
                                       pta_elements       in apex_application.g_f01%type);

  --
  -- Fonction qui retourne les enregistrements de la collection
  -- 
  function f_obtenir_elements_ig_selection(pva_nom_collection in apex_application.g_x01%type)
    return apex_t_varchar2;
  --
  -- Fonction qui retourne vrai si il y a au moins un élément dans la collection sinon false.
  -- 
  function f_obtenir_si_element_selectionne(pva_nom_collection in apex_application.g_x01%type) return boolean;
  function f_obtenir_si_element_selectionne_o_n(pva_nom_collection in apex_application.g_x01%type)
    return varchar2;
    
end utl_pkb_apx_ig_selection;
/

