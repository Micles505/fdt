create or replace package utl.utl_pkb_apx_navigation_enreg_ig is

  -- Author  : SHQIAR
  -- Created : 2021-11-10 13:15:49
  -- Purpose : Package pour la gestion de la navigation des enregistrements selon une grille interactive.

  gva_nom_collection varchar2(255) := 'SHQ-NAVGT-COL';
  gnu_app_id         number := v('APP_ID');
  gnu_page_id        number := v('APP_PAGE_ID');
  gva_grid_name      varchar2(255) := v('PN_NAVGT_GRID_ID');
  gva_p_id       constant char(01) := 'P';
  gva_underscore constant char(01) := '_';

  procedure obtenir_donnees_navigation;

  ----******** Verifier que l'enregistrement courante fait parti de la naviagation' ************------------
  function f_verifier_navigation_exist return boolean;

  ----******** enregistre un nouvel enregistrement dans la navigation ************------------
  procedure p_ajouter_navigation;

  ----******** Obtenir les données de navigation courante ************------------
  procedure p_obtenir_json_navgt(p_json_navgt     out clob,
                                 p_cles_navgt     out varchar2,
                                 p_col_seq        out number,
                                 p_grid_name      in varchar2 default null);

  ----******** Verifier que nous sommes en mode création d'enregirstement ou pas ************------------
  ----****** si l'ensemble des clés primaires est null alors retourner false sinon true *******--------
  function f_verifier_enrg_exist return boolean;

  ----******** Enregistre les données de naviagtion ************------------
  procedure enregistrer_nvgt_data;

  ----******** Retourne le nom de la navigation de la page courante ************------------
  function f_obtenir_page_courante_navigation return varchar2;

end utl_pkb_apx_navigation_enreg_ig;
/

