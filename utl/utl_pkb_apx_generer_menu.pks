create or replace package utl.utl_pkb_apx_generer_menu is

  -- Author  : SHQIAR
  -- Created : 2019-09-05 15:15:31
  -- Purpose : Package qui genere le menu dynamique

  -- Public type declarations
  type rec_menu_item_apex is record(
    level_menu            apex_application_list_entries.display_sequence%type,
    label_menu            apex_application_list_entries.entry_text%type,
    target_menu           apex_application_list_entries.entry_target%type,
    is_current_list_entry apex_application_list_entries.current_for_pages_type%type,
    image                 apex_application_list_entries.entry_image%type,
    image_attribute       apex_application_list_entries.entry_image_attributes%type,
    image_alt_attribute   apex_application_list_entries.entry_image_alt_attribute%type,
    attribute1            apex_application_list_entries.entry_attribute_01%type,
    attribute2            apex_application_list_entries.entry_attribute_02%type,
    attribute3            apex_application_list_entries.entry_attribute_03%type,
    attribute4            apex_application_list_entries.entry_attribute_04%type,
    attribute5            apex_application_list_entries.entry_attribute_05%type,
    attribute6            apex_application_list_entries.entry_attribute_06%type,
    attribute7            apex_application_list_entries.entry_attribute_07%type,
    attribute8            apex_application_list_entries.entry_attribute_08%type,
    attribute9            apex_application_list_entries.entry_attribute_09%type,
    attribute10           apex_application_list_entries.entry_attribute_10%type);
  --
  type tab_pipe_menu_item_apex is table of rec_menu_item_apex;
  --
  type rec_item_menu_supp is record(
    level_menu         utlv_menu_apex.niveau_menu%type,
    no_seq_item_apx    utlv_menu_apex.no_seq_item_apx%type,
    no_seq_item_parent utlv_menu_apex.no_seq_item_parent%type,
    indice_table       number,
    co_menu_apx        utlv_menu_apex.co_menu_apx%type,
    co_item_apx        utlv_menu_apex.co_item_apx%type,
    typ_application    utlv_menu_apex.typ_application%type,
    ord_pres_item_apx  utlv_menu_apex.ord_pres_item_apx%type);
  --
  type tab_item_menu_supp is table of rec_item_menu_supp;
  --
  -- Public function and procedure declarations
  --
  function f_obtenir_item_menu_apex(pva_co_menu_apx in utlt_menu_apex.co_menu_apx%type,
                                    pnu_app_id      in apex_application.g_flow_id%type default apex_application.g_flow_id,
                                    pnu_page_id     in apex_application.g_flow_step_id%type default apex_application.g_flow_step_id)
    return tab_pipe_menu_item_apex
    pipelined;
  --
  function f_obtenir_menu return tab_item_menu_supp
    pipelined;
  --
end utl_pkb_apx_generer_menu;
/

