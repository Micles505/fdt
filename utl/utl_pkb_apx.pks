create or replace package utl."UTL_PKB_APX" as
  function gestn_erreur_apx_fnc(p_error in apex_error.t_error) return apex_error.t_error_result;
  /*******************************************************************/
  /* Daniel Montminy & Dominic Caron (Momentum)                      */
  /* Mars 2015                                                       */
  /* But:        Obtenir un message d'erreur maison                  */
  /*             dans une application APEX                           */
  /* Paramètre:  Erreur obtenu dans une application APEX             */
  /* Retour:     Message d'erreur selon les tables de message de UTL */
  /*******************************************************************/
  --
  function obtnr_nom_utils(p_app_user in varchar2) return varchar2;
  /*******************************************************************/
  /* Daniel Montminy & Dominic Caron (Momentum)                      */
  /* Juin 2015                                                       */
  /* But:       Obtenir le nom et prénom de BUS pour l'utilisateur   */
  /*            connecté dans une application APEX                   */
  /* Paramètre: Code de l'utilisateur connecté dans APEX             */
  /* Retour:    Prénom, nom de BUS                                   */
  /*******************************************************************/
  --
  function action_autoriz_bus(pva_action           varchar2,
                              pva_alias_page_appel varchar2 default null) return varchar2;
  /*******************************************************************/
  /* Daniel Montminy                                                 */
  /* Juin 2015                                                       */
  /* But:       Obtenir l'autorisation du système BUS                */
  /*            Avec la BD de DEV, c'est selon le paramètre          */
  /*            d'autorisation                                       */
  /* Paramètre: - Action définit dans BUS. Ex.: BUT_CALCUL_TAXES     */
  /*            - NULL si la page courante                           */
  /*              ou l'alias de page, pour un droit de navigation    */
  /*              vers cette page                                    */
  /* Retour:    O : Si l'autorisation est permise                  */
  /*            N : Si l'autorisation n'est pas permise            */
  /*******************************************************************/
  --
  function verif_page_apex(pva_systeme        varchar2,
                           pva_alias_page     varchar2,
                           pva_espace_travail varchar2 default 'SHQ') return varchar2;
  /****************************************************************************************************************/
  /* Daniel Montminy                                                                                              */
  /* Novembre 2015                                                                                                */
  /* But:        Vérifier dans le référentiel d'APEX si une page d'un système existe                              */
  /* Paramètres: - pva_systeme : Code de 3 lettres identifiant le système                                         */
  /*             - pva_alias_page : Alias de la page, si les lettres 'UT' ne sont pas mentionnées,                */
  /*                 elle seront ajouté pour être selon notre nomenclature des alias de page                      */
  /*             - pva_espace_travail : L'espace de travail d'APEX, par défaut notre espace officiel , soit "SHQ" */
  /* Retour:     O : Si l'alias de page existe pour le système mentionné                                          */
  /*             N : Si l'alias de page N'existe PAS pour le système mentionné                                    */
  /****************************************************************************************************************/
  --
  function lectu_seule_autoriz_bus(pva_cle_verif_cre_mod varchar2,
                                   pva_alias_page_appel  varchar2 default null) return varchar2;
  /**********************************************************************************/
  /* Daniel Montminy                                                                */
  /* Août 2015                                                                      */
  /* But:       Est-ce en lecture seulement dans le système BUS                     */
  /*            Avec la BD de DEV, c'est selon le paramètre d'autorisation          */
  /* Paramètre: - Clé pour identifier si c'est en création ou en modification, ex. P4_NO_SEQ_ABC */
  /*            - NULL si la page courante                                          */
  /*                ou l'alias de page, pour un droit de navigation vers cette page
  /*                                             ex. : 010101_P01                   */
  /* Retour:    O : En lecture seulement                                            */
  /*            N : Création ou modification permise                                */
  /**********************************************************************************/
  --
  function fb_action_autoriz_bus(pva_action           varchar2,
                                 pva_alias_page_appel varchar2 default null) return boolean;
  /***********************************************************************************/
  /* Daniel Montminy                                                                 */
  /* Décembre 2015                                                                   */
  /* But:        Obtenir l'autorisation du système BUS                               */
  /*               Avec la BD de DEV, c'est selon le paramètre d'autorisation        */
  /* Paramètres: - Action définit dans BUS. Ex.: BUT_CALCUL_TAXES                    */
  /*             - NULL si la page courante                                          */
  /*                 ou l'alias de page, pour un droit de navigation vers cette page */
  /* Retour:     Vrai : Si l'autorisation est permise                                */
  /*             Faux : Si l'autorisation n'est pas permise                          */
  /***********************************************************************************/
  --
  function fc_action_autoriz_bus(pva_action           varchar2,
                                 pva_alias_page_appel varchar2 default null) return varchar2;
  /*********************************************************************************/
  /* Daniel Montminy                                                               */
  /* Décembre 2015                                                                 */
  /* But:        Obtenir l'autorisation du système BUS                             */
  /*               Avec la BD de DEV, c'est selon le paramètre d'autorisation      */
  /* Paramètres: - Action définit dans BUS. Ex.: BUT_CALCUL_TAXES                  */
  /*             - NULL si la page courante                                        */
  /*                 ou l'alias de page, pour un droit de navigation vers une page */
  /* Retour:     O : Si l'autorisation est permise                                 */
  /*             N : Si l'autorisation n'est pas permise                           */
  /*********************************************************************************/
  --
  function text_from_lov_query(p_value     in varchar2 default null,
                               p_query     in varchar2,
                               p_null_text in varchar2 default '%') return varchar2;
  /*****************************************************************************/
  /* Dominic Caron                                                             */
  /* Février 2017                                                              */
  /* But:        Modifier la session avec nls_comp="BINARY", puis appeller     */
  /*             la vraie fonction du package APEX_ITEM du même nom            */
  /* Paramètres: Les mêmes paramètres que la fonction originale sont utilisées */
  /* Retour:     Même retour que la fonction originale                         */
  /*****************************************************************************/
  --
  function popupkey_from_query(p_idx          in number,
                               p_value        in varchar2 default null,
                               p_lov_query    in varchar2,
                               p_width        in varchar2 default null,
                               p_max_length   in varchar2 default null,
                               p_form_index   in varchar2 default '0',
                               p_escape_html  in varchar2 default null,
                               p_max_elements in varchar2 default null,
                               p_attributes   in varchar2 default null,
                               p_ok_to_query  in varchar2 default 'YES',
                               p_item_id      in varchar2 default null,
                               p_item_label   in varchar2 default null) return varchar2
  /*****************************************************************************/
    /* Dominic Caron                                                             */
    /* Février 2017                                                              */
    /* But:        Modifier la session avec nls_comp="BINARY", puis appeller     */
    /*             la vraie fonction du package APEX_ITEM du même nom            */
    /* Paramètres: Les mêmes paramètres que la fonction originale sont utilisées */
    /* Retour:     Même retour que la fonction originale                         */
    /*****************************************************************************/
    --
  ;
  --
  function date_popup2(p_idx                 in number,
                       p_value               in date default null,
                       p_date_format         in varchar2 default null,
                       p_size                in number default 20,
                       p_maxlength           in number default 2000,
                       p_attributes          in varchar2 default null,
                       p_item_id             in varchar2 default null,
                       p_item_label          in varchar2 default null,
                       p_default_value       in varchar2 default null,
                       p_max_value           in varchar2 default null,
                       p_min_value           in varchar2 default null,
                       p_show_on             in varchar2 default 'button',
                       p_number_of_months    in varchar2 default null,
                       p_navigation_list_for in varchar2 default 'NONE',
                       p_year_range          in varchar2 default null,
                       p_validation_date     in varchar2 default null) return varchar2;
  /*****************************************************************************/
  /* Dominic Caron                                                             */
  /* Février 2017                                                              */
  /* But:        Modifier la session avec nls_comp="BINARY", puis appeller     */
  /*             la vraie fonction du package APEX_ITEM du même nom            */
  /* Paramètres: Les mêmes paramètres que la fonction originale sont utilisées */
  /* Retour:     Même retour que la fonction originale                         */
  /*****************************************************************************/
  --
  function select_list_from_query(p_idx        in number,
                                  p_value      in varchar2 default null,
                                  p_query      in varchar2,
                                  p_attributes in varchar2 default null,
                                  p_show_null  in varchar2 default 'YES',
                                  p_null_value in varchar2 default '%null%',
                                  p_null_text  in varchar2 default '%',
                                  p_item_id    in varchar2 default null,
                                  p_item_label in varchar2 default null,
                                  p_show_extra in varchar2 default 'YES') return varchar2;
  /*****************************************************************************/
  /* Dominic Caron                                                             */
  /* Février 2017                                                              */
  /* But:        Modifier la session avec nls_comp="BINARY", puis appeller     */
  /*             la vraie fonction du package APEX_ITEM du même nom            */
  /* Paramètres: Les mêmes paramètres que la fonction originale sont utilisées */
  /* Retour:     Même retour que la fonction originale                         */
  /*****************************************************************************/
  --
  function fb_lectu_seule_autoriz_bus(pva_cle_verif_cre_mod varchar2,
                                      pva_alias_page_appel  varchar2 default null) return boolean;
  /**********************************************************************************/
/* Daniel Montminy                                                                */
/* Août 2015                                                                      */
/* But:       Est-ce en lecture seulement dans le système BUS                     */
/*            Avec la BD de DEV, c'est selon le paramètre d'autorisation          */
/*          * Appel la fonction de ce package : lectu_seule_autoriz_bus           */
/* Paramètre: - Clé pour identifier si c'est en création ou en modification, ex. P4_NO_SEQ_ABC */
/*            - NULL si la page courante                                          */
/*                ou l'alias de page, pour un droit de navigation vers cette page
    /*                                             ex. : 010101_P01                   */
/* Retour:    true  : En lecture seulement                                        */
/*            false : Création ou modification permise                            */
/**********************************************************************************/
--
end;
/

