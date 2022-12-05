CREATE OR REPLACE PACKAGE FDT_PKB_APX_UTIL_TEMPS AS
  --
  -- Constantes publiques
  --
  -- Types de durées pouvant être validés
  C_DUREE CONSTANT BINARY_INTEGER := 1;
  C_DUREE_CREDIT_HORAIRE CONSTANT BINARY_INTEGER := 2;
  C_DUREE_MOINS_24_HEURES CONSTANT BINARY_INTEGER := 3;
  C_HEURE_JOUR CONSTANT BINARY_INTEGER := 4;
  C_HEURE_ENTREE_AM CONSTANT BINARY_INTEGER := 5;
  C_HEURE_SORTIE_AM CONSTANT BINARY_INTEGER := 6;
  C_HEURE_ENTREE_PM CONSTANT BINARY_INTEGER := 7;
  C_HEURE_SORTIE_PM CONSTANT BINARY_INTEGER := 8;
  C_DERNIER_TYPE_DUREE CONSTANT BINARY_INTEGER := 8;
  -- Types de validations de durées
  -- (On peut additionner plusieurs types de validations pour
  --  définir l'étendue des validations à  effectuer.  On peut ainsi
  --  réaliser plusieurs validations lors d'un seul appel à  la validation)
  C_VALIDER_PRESENCE CONSTANT BINARY_INTEGER := 1;
  C_VALIDER_FORMAT CONSTANT BINARY_INTEGER := 2;
  C_VALIDER_VALEUR CONSTANT BINARY_INTEGER := 4;
  C_SOMME_TYPE_ETENDUE_VAL CONSTANT BINARY_INTEGER := 7;
  --
  -- Déclaration des procÃ©dures et fonctions publiques
  --
  -- Déterminer si une durÃ©e exprimée sous forme de chaîne de caractères
  -- est valide (présente, bon format et/ou valeur permise).
  --
  -- Paramètres:
  -- - P_DURÃ‰E - Durée exprimée dans une chaîne de caractères.
  -- - P_TYPE_DUREE - Type de durée (Utiliser une des constantes C_DUREE_* ou C_HEURE_*
  --     définies ci-dessus).
  -- - P_ETENDUE_VALIDATION - Validations à  effectuer (Additionner 1 ou plusieurs des
  --     constantes C_VALIDER_* définies ci-dessus).
  --
  -- Résultat:
  --   Vrai/faux sous forme de booléen.
  --
  FUNCTION IS_DUREE_VALIDE(P_DUREE IN VARCHAR2,
                           P_TYPE_DUREE IN BINARY_INTEGER := C_DUREE_MOINS_24_HEURES,
                           P_ETENDUE_VALIDATION IN BINARY_INTEGER := C_VALIDER_PRESENCE + C_VALIDER_FORMAT + C_VALIDER_VALEUR
                          ) RETURN BOOLEAN;
  --
  -- Fonction identique Ã  la précédente, mais qui peut Ãªtre appelÃ©e dans un
  -- énoncé SQL.
  --
  -- Résultat:
  --   'VRAI'/'FAUX' sous forme de chaîne de caractîres.
  --
  -- ATTENTION!
  -- - Les constantes ne peuvent être utilisées en SQL.  Il faut
  --   utiliser les valeurs directement.
  --
  FUNCTION IS_DUREE_VALIDE_SQL(P_DUREE IN VARCHAR2,
                               P_TYPE_DUREE IN BINARY_INTEGER := C_DUREE_MOINS_24_HEURES,
                               P_ETENDUE_VALIDATION IN BINARY_INTEGER := C_VALIDER_PRESENCE + C_VALIDER_FORMAT + C_VALIDER_VALEUR
                              ) RETURN VARCHAR2;
  --
  FUNCTION test_date(l_dte IN VARCHAR2, l_format IN VARCHAR2
                   ) RETURN BOOLEAN;
  --
  FUNCTION is_number (p_string IN VARCHAR2
                   )RETURN INT;
  --
  FUNCTION convert_format_heure (p_number IN number default 0)
     return varchar2; 
  --
  procedure gerer_att_et_ajuster_temps_res(pnu_no_seq_ressource     in number,
                                           pnu_no_seq_detail_attrav in fdtt_details_att.no_seq_detail_attrav%type,
                                           pda_dt_debut_att         in date,
                                           pda_dt_fin_att           in date,
                                           pnu_nb_hmin_jour         in fdtt_details_att.nb_hmin_jour%type,
                                           pnu_nb_hmin_sem          in fdtt_details_att.nb_hmin_sem%type,
                                           pnu_nb_jour_sem          in fdtt_details_att.nb_jour_sem%type,
                                           pva_note                 in fdtt_details_att.note%type,
                                           pva_request              in varchar2) ;
 
  end fdt_pkb_apx_util_temps;
/

