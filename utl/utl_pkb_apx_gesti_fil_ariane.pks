create or replace package utl.utl_pkb_apx_gesti_fil_ariane is

  -- Author  : SHQIAR
  -- Created : 2019-06-19 08:55:08
  -- Purpose : Gestion dynamique du fil d'ariane

  -- Public type declarations

  -- Public constant declarations
  cva_collection_fil_ariane constant apex_collections.collection_name%type := 'FIL_ARIANE';
  --
  type rec_fil_ariane_courant is record(
    app_id      apex_application.g_flow_id%type,
    app_page_id apex_application.g_flow_step_id%type);

  -- Public variable declarations

  -- Public function and procedure declarations
  function f_obtenir_nom_fil_ariane return varchar2 deterministic;
  --
  function f_obternir_url_page_apex return varchar2;
  --
  procedure p_empiler_fil_ariane(pva_app_id                 in apex_applications.application_id%type,
                                 pva_app_page_id            in apex_application_pages.page_id%type,
                                 pva_titre_fil_ariane       in out nocopy apex_application_pages.page_title%type,
                                 pva_ind_affic_libel_fa     in varchar2 default utl_pkb_apx_constantes.f_obtenir_co_oui,
                                 pva_ind_affiche_fil_ariane in out nocopy varchar2,
                                 pva_url_page_precedente    in out nocopy varchar2,
                                 pva_request                in varchar2 default null);
  --
  function f_obtenir_url_page_precedente(pva_app_id      in apex_applications.application_id%type,
                                         pva_app_page_id in apex_application_pages.page_id%type)
    return varchar2;
  --   
  procedure p_init_variable_fil_ariane(
                                       --
                                       -- Procedure qui remet les variables du fil d'ariane à leur valeur par défault
                                       --
                                       pva_libl_fil_ariane        out nocopy varchar2,
                                       pva_ind_affiche_fil_ariane out nocopy varchar2,
                                       pva_url_page_source        out nocopy varchar2,
                                       pva_ind_affic_libel_fa     out nocopy varchar2);
  --
  procedure p_reinitialiser_fil_ariane;
  --
  function f_obtenir_app_page_courant return rec_fil_ariane_courant;
  --
  function f_obtenir_fil_ariane(pnu_app_id      apex_application.g_flow_id%type,
                                pnu_app_page_id apex_application.g_flow_step_id%type)
    return utl_pkb_apx_generer_menu.tab_pipe_menu_item_apex
    pipelined;

end utl_pkb_apx_gesti_fil_ariane;
/

