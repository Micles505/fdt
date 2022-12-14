create or replace package utl.utl_pkb_apx_config_theme_shq is
  --
  -- @usage Fonction qui retounr le path des fichier css et js sur le serveur web
  -- @return le path des fichiers
  --
  function f_obtenir_rep_fichier_shq return varchar2;
  --
    -- @usage procedure qui assigne le répertoire des fichiers js, images pour le thème de SHQ
    -- @value EA_PATH_SHQ_APX   Item global dans APEX
    --
  procedure p_assigner_rep_fichier_shq;
  --
  -- @usage procedure qui assigne le libellé et le lien gouvernement du Québec
  -- @value EA_LIEN_GOUVR_QUEBEC Item global dans APEX
  -- @value EA_ALT_LOGO_QUEBEC   Item global dans APEX
  --
  procedure p_assigner_gouvr_quebec;
  --
  -- @usage procedure qui assigne le libellé des droit d'auteur
  -- @value EA_DROIT_AUTEUR_LIEN_QC Item global dans APEX
  -- @value EA_DROIT_AUTEUR_QC      Item global dans APEX
  --
  procedure p_assigner_droit_auteur;
  --
  -- @usage procedure qui assigne le lien nous joindre
  -- @value EA_NOUS_JOINDRE_LIEN   Item global dans APEX
  --
  procedure p_assigner_nous_joindre;
  --
  -- @usage procedure qui assigne le lien accessibilité
  -- @value EA_LIEN_ACCESSIBILITE   Item global dans APEX
  --
  procedure p_assigner_accessibilite;
  --
  -- @usage procedure qui assigne le lien plan du site
  -- @value EA_LIEN_PLAN_SITE   Item global dans APEX
  --  
  procedure p_assigner_plan_site;
  --
  -- @usage procedure qui assigne le lien pour accès à l'information
  -- @value EA_LIEN_ACCES_INFORMATION   Item global dans APEX
  --
  procedure p_assigner_acces_information;
  --
  -- @usage procedure qui assigne le lien politique de confidentialité
  -- @value EA_LIEN_POLITIQUE_CONFDNTL   Item global dans APEX
  --  
  procedure p_assigner_politique_confdntl;
  --
  -- @usage procedure qui assigne le lien à propos
  -- @value EA_LIEN_A_PROPOS   Item global dans APEX
  --  
  procedure p_assigner_a_propos;
  --
  -- @usage procedure qui assigne le lien edition rapport
  -- @value EA_LIEN_EDITION_ENREG   Item global dans APEX <i class="fa fa-pencil" data-edition-shq="true" aria-hidden="true" alt="Éditer l''enregristrement en cours"></i>
  --    
  procedure p_assigner_lien_edit_rapport;
  --
  -- @usage procedure qui assigne le lien logout
  -- @value EA_LOGOUT_URL   Item global dans APEX 
  --    
  procedure p_assigner_lien_logout;
  --   
  -- @usage procedure qui applique le css pour l'envrionnement integré
  --      
  procedure p_assigner_theme_shq_int;
  --   
  -- @usage procedure qui applique le css pour l'envrionnement acceptation, le header en vert 
  --      
  procedure p_assigner_theme_shq_acc;
  --
  -- @usage procedure qui applique le css pour l'envrionnement acceptation, le header en vert pour les applications en apex 4.2
  --      
  procedure p_assigner_theme4_shq_acc;
  --
  -- @usage procedure qui assigne la version du css et du js à appliquer
  -- @value EA_VERSION_JS_CSS
  procedure p_assigner_version_js_css;
  --
  -- @usage fonction qui retourne le numéro de version à appliquer pour le rafraîchissement de la cache
  -- @return le numero de version ex. 1.1.1     
  function f_obternir_version_js_css return varchar2 result_cache;
  --
  -- @usage retourne le bas de page SHQ
  -- 
  procedure p_afficher_bas_page_piv;

  procedure p_afficher_bas_page_piv(pva_ea_lien_accessibilite      in varchar2,
                                    pva_ea_lien_politique_confdntl in varchar2,
                                    pva_ea_lien_acces_information  in varchar2,
                                    pva_ea_lien_gouvr_quebec       in varchar2,
                                    pva_ea_alt_logo_quebec         in varchar2,
                                    pva_ea_path_shq_apx            in varchar2,
                                    pva_ea_droit_auteur_lien_qc    in varchar2,
                                    pva_ea_droit_auteur_qc         in varchar2);
  --
  -- @usage  Fonction qui retourne le code de menu de l'application 
  -- @param  L'identifiant de l'application APEX 
  -- @return Le code de menu de l'application APEX.
  --
  function f_obtenir_code_menu_appli(pnu_apex_application_id in number default nv('APP_ID')) return varchar2;

end utl_pkb_apx_config_theme_shq;
/

