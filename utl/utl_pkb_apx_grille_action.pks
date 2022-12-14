create or replace package utl.utl_pkb_apx_grille_action is
  --
  -- @author  SHQIAR
  --          2020-02-23 13:11:30
  -- @usage   Gestion des actions pour les enregistrements d'un grille interactive
  --
  -- Public type declarations
  -- type <TypeName> is <Datatype>;
  --
  -- Public constant declarations
  -- <ConstantName> constant <Datatype> := <Value>;
  --
  -- Public variable declarations
  --<VariableName> <Datatype>;
  --
  -- Public function and procedure declarations
  --
  -- @usage  Procedure qui permet d'obtenir les actions d'une grille interactive 
  -- 
  procedure p_obtenir_action_ig(pva_co_gril_action in apex_application.g_x01%type,
                                pva_id             in apex_application.g_x02%type default null);
  --  
  -- =================================================================================================
  -- Validations de la table grille action items associé à l'application UTL_APEX
  --  
  -- Paramètres entrants : 
  --    --> vtp_grille_action_item  --> Ensemble des champs de la table UTLT_GRILLE_ACTION_ITEM
  --    --> p_type_operation        --> REQUEST de la page Apex 
  -- 
  -- Paramètres sortants : Aucun
  -- =================================================================================================
  procedure p_valdt_apx_grille_action_item(p_grille_action_item in utlt_grille_action_item%rowtype,
                                           p_type_operation     in varchar2);
  --  
  -- @usage fonction qui retourne la prochaine id_clef_affaire pour le table pilt_valeur_parametre 
  -- @param pnu_no_seq_parametre Séquence de parametre système.
  -- 
  function f_obtenir_clef_affaire_grille_action_item(pnu_no_seq_gril_action in utlt_grille_action.no_seq_gril_action%type)
    return varchar2;
  --
  -- Procedure pour la mise à jour de la table pilt_valeur code de la page 2 
  -- 
  -- @param pva_row_status Le statut de l'enregistrement 
  -- @param pnu_no_seq_valeur_code la sequence de l'enregistrement 
  -- @param et les autres champs de la table
  -- 
  -- @raise On laisse les erreurs remonter au niveau de l'application APEX.
  -- 
  procedure p_process_dml_action_item(p_type_operation                in varchar2,
                                      pnu_NO_SEQ_GRIL_ACT_ITEM        in out utlt_grille_action_item.NO_SEQ_GRIL_ACT_ITEM%type,
                                      pnu_NO_SEQ_GRIL_ACTION          in utlt_grille_action_item.NO_SEQ_GRIL_ACTION%type,
                                      pnu_NO_SEQ_GRIL_ACT_ITEM_PARENT in utlt_grille_action_item.NO_SEQ_GRIL_ACT_ITEM_PARENT%type,
                                      pva_id_cle_affaire              in utlt_grille_action_item.id_cle_affaire%type,
                                      pnu_NO_SEQ_ICONE_APEX           in utlt_grille_action_item.NO_SEQ_ICONE_APEX%type,
                                      pva_CO_STA_ACT_ITEM             in utlt_grille_action_item.CO_STA_ACT_ITEM%type,
                                      pva_CO_TYP_GRIL_ACT_ITEM        in utlt_grille_action_item.CO_TYP_GRIL_ACT_ITEM%type,
                                      pva_CO_ACT_JSC_GRILLE           in utlt_grille_action_item.CO_ACT_JSC_GRILLE%type,
                                      pva_LIBELLE_GRIL_ACT_ITEM       in utlt_grille_action_item.LIBELLE_GRIL_ACT_ITEM%type,
                                      pva_URL_GRIL_ACT_ITEM           in utlt_grille_action_item.URL_GRIL_ACT_ITEM%type,
                                      pva_CJS_GRIL_ACT_ITEM           in utlt_grille_action_item.CJS_GRIL_ACT_ITEM%type,
                                      pva_CO_PRECIS_GRIL_ACT_ITEM     in utlt_grille_action_item.CO_PRECIS_GRIL_ACT_ITEM%type,
                                      pva_CO_TYP_POSITION             in utlt_grille_action_item.CO_TYP_POSITION%type,
                                      pnu_ID_APP_APEX_LISTE           in utlt_grille_action_item.ID_APP_APEX_LISTE%type,
                                      pnu_ID_PAGE_APEX_LISTE          in utlt_grille_action_item.ID_PAGE_APEX_LISTE%type,
                                      pva_NOM_ITEM_PAGE_RECEPT_FORMU  in utlt_grille_action_item.NOM_ITEM_PAGE_RECEPT_FORMU%type,
                                      pva_NOM_TABLE_FORMULAIRE        in utlt_grille_action_item.NOM_TABLE_FORMULAIRE%type,
                                      pva_NOM_COLONNE_FORMULAIRE      in utlt_grille_action_item.NOM_COLONNE_FORMULAIRE%type,
                                      pva_NOM_COLONNE_LISTE           in utlt_grille_action_item.NOM_COLONNE_LISTE%type,
                                      pnu_ID_APP_APEX_FORMULAIRE      in utlt_grille_action_item.ID_APP_APEX_FORMULAIRE%type,
                                      pnu_ID_PAGE_APEX_FORMULAIRE     in utlt_grille_action_item.ID_PAGE_APEX_FORMULAIRE%type,
                                      pva_IND_AFFICH_ACT_ITEM         in utlt_grille_action_item.IND_AFFICH_ACT_ITEM%type,
                                      pva_NOM_AUTHORISAT_SCHEMA       in utlt_grille_action_item.NOM_AUTHORISAT_SCHEMA%type,
                                      pva_NOM_FONCT_AUTHORISAT        in utlt_grille_action_item.NOM_FONCT_AUTHORISAT%type,
                                      pva_CO_TYP_MENU_ACT_ITEM        in utlt_grille_action_item.CO_TYP_MENU_ACT_ITEM%type,
                                      pva_NOM_COLONE_VERIF            in utlt_grille_action_item.NOM_COLONE_VERIF%type,
                                      pva_NOM_ITEM_PAGE_RECEPT_LISTE  in utlt_grille_action_item.NOM_ITEM_PAGE_RECEPT_LISTE%type,
                                      pva_NOM_TABLE_LISTE             in utlt_grille_action_item.NOM_TABLE_LISTE%type,
                                      pva_NOM_TABLE_VERIF             in utlt_grille_action_item.NOM_TABLE_VERIF%type,
                                      pnu_NO_ORD_GRIL_ACT_ITEM        in utlt_grille_action_item.NO_ORD_GRIL_ACT_ITEM%type,
                                      pnu_NO_POSITION_INDEX           in utlt_grille_action_item.NO_POSITION_INDEX%type);
end utl_pkb_apx_grille_action;
/

