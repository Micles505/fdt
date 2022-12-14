prompt PL/SQL Developer Export User Objects for user UTL@DEV01
prompt Created by SHQIAR on 14 décembre 2022
set define off
spool table.log

prompt
prompt Creating table UTLT_ERREUR_ORACLE
prompt =================================
prompt
@@utlt_erreur_oracle.tab
prompt
prompt Creating table UTLT_GRILLE_ACTION
prompt =================================
prompt
@@utlt_grille_action.tab
prompt
prompt Creating table UTLT_ICONE_APEX
prompt ==============================
prompt
@@utlt_icone_apex.tab
prompt
prompt Creating table UTLT_GRILLE_ACTION_ITEM
prompt ======================================
prompt
@@utlt_grille_action_item.tab
prompt
prompt Creating table UTLT_ITEM_MENU_APEX
prompt ==================================
prompt
@@utlt_item_menu_apex.tab
prompt
prompt Creating table UTLT_MENU_APEX
prompt =============================
prompt
@@utlt_menu_apex.tab
prompt
prompt Creating table UTLT_MESSAGE_TRAIT
prompt =================================
prompt
@@utlt_message_trait.tab
prompt
prompt Creating table UTLT_STANDARD_APEX
prompt =================================
prompt
@@utlt_standard_apex.tab

prompt Done
spool off
set define on
