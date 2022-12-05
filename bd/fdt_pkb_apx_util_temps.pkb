CREATE OR REPLACE PACKAGE BODY "FDT_PKB_APX_UTIL_TEMPS" AS
  --
  -- Types privés
  --
   
  TYPE T_FORMAT_DUREE IS RECORD (
    FORMAT VARCHAR2(50),        -- Expression régulière permettant de valider le format de la durée
    VALEUR_MIN BINARY_INTEGER,  -- Valeur minimale permise (en minutes)
    VALEUR_MAX BINARY_INTEGER   -- Valeur maximale permise (en minutes)
  );
  TYPE T_LST_FORMAT_DUREE IS TABLE OF T_FORMAT_DUREE INDEX BY BINARY_INTEGER;
  --
  -- Constantes privées
  --
  C_FORMAT_HEURE VARCHAR2(50) := '^(\d+)(:([0-5][0-9])?)?$';
  C_FORMAT_HEURE_JOUR VARCHAR2(50) := '^([0-1]?[0-9]|2[0-3])(:([0-5][0-9])?)?$';
  C_FORMAT_HEURE_JOUR_POS_NEG VARCHAR2(50) := '^[\+\-]?([0-9]?[0-9])(:([0-5][0-9])?)?$';
  --
  -- Variables globales privées
  --
  G_LST_FORMAT_DUREE T_LST_FORMAT_DUREE;
  --
  -- Procédures et fonctions privées
  --
  PROCEDURE DEFINIR_FORMAT_DUREE(P_TYPE_DUREE IN BINARY_INTEGER,
                                 P_FORMAT IN VARCHAR2,
                                 P_VALEUR_MIN BINARY_INTEGER,
                                 P_VALEUR_MAX BINARY_INTEGER) IS
    L_FORMAT_DUREE T_FORMAT_DUREE;
  BEGIN
    L_FORMAT_DUREE.FORMAT     := P_FORMAT;
    L_FORMAT_DUREE.VALEUR_MIN := P_VALEUR_MIN;
    L_FORMAT_DUREE.VALEUR_MAX := P_VALEUR_MAX;
    G_LST_FORMAT_DUREE(P_TYPE_DUREE) := L_FORMAT_DUREE;
  END;
  --
  -- Implémentation des procédures et fonctions publiques
  --
  FUNCTION IS_DUREE_VALIDE(P_DUREE IN VARCHAR2,
                           P_TYPE_DUREE IN BINARY_INTEGER := C_DUREE_MOINS_24_HEURES,
                           P_ETENDUE_VALIDATION IN BINARY_INTEGER := C_VALIDER_PRESENCE + C_VALIDER_FORMAT + C_VALIDER_VALEUR
                          ) RETURN BOOLEAN IS
    L_SIGNE BINARY_INTEGER;
    L_NOMBRE_HEURES BINARY_INTEGER;
    L_NOMBRE_MINUTES BINARY_INTEGER;
    L_DUREE_EN_MINUTES BINARY_INTEGER;
  BEGIN
    IF P_TYPE_DUREE > C_DERNIER_TYPE_DUREE THEN
      RAISE_APPLICATION_ERROR(-20000,'Argument invalide: P_TYPE_DUREE');
    ELSIF P_ETENDUE_VALIDATION > C_SOMME_TYPE_ETENDUE_VAL THEN
      RAISE_APPLICATION_ERROR(-20000,'Argument invalide: P_ETENDUE_VALIDATION');
    END IF;
    -- Valider la présence
    IF BITAND(P_ETENDUE_VALIDATION,C_VALIDER_PRESENCE) = C_VALIDER_PRESENCE AND
       (P_DUREE IS NULL OR
        LENGTH(TRIM(P_DUREE)) = 0) THEN
      RETURN FALSE;
    END IF;
    --
    IF P_DUREE IS NOT NULL THEN
      -- Valider le format
      IF (BITAND(P_ETENDUE_VALIDATION,C_VALIDER_FORMAT) = C_VALIDER_FORMAT OR
          BITAND(P_ETENDUE_VALIDATION,C_VALIDER_VALEUR) = C_VALIDER_VALEUR) AND
         NOT REGEXP_LIKE(P_DUREE,G_LST_FORMAT_DUREE(P_TYPE_DUREE).FORMAT) THEN
        RETURN FALSE;
      END IF;
      -- Valider la valeur
      IF BITAND(P_ETENDUE_VALIDATION,C_VALIDER_VALEUR) = C_VALIDER_VALEUR THEN
         L_NOMBRE_HEURES := NVL(REGEXP_SUBSTR(P_DUREE,'^[^:]+'),0);
         IF L_NOMBRE_HEURES < 0 THEN
           L_SIGNE := -1;
           L_NOMBRE_HEURES := L_NOMBRE_HEURES * -1;
         ELSE
           L_SIGNE := 1;
         END IF;
         L_NOMBRE_MINUTES := NVL(SUBSTR(REGEXP_SUBSTR(P_DUREE,':[^:]+$'),2),0);
         L_DUREE_EN_MINUTES := (L_NOMBRE_HEURES * 60 +
                                L_NOMBRE_MINUTES) *
                               L_SIGNE;
         IF (G_LST_FORMAT_DUREE(P_TYPE_DUREE).VALEUR_MIN IS NOT NULL AND
             L_DUREE_EN_MINUTES < G_LST_FORMAT_DUREE(P_TYPE_DUREE).VALEUR_MIN) OR
            (G_LST_FORMAT_DUREE(P_TYPE_DUREE).VALEUR_MAX IS NOT NULL AND
             L_DUREE_EN_MINUTES > G_LST_FORMAT_DUREE(P_TYPE_DUREE).VALEUR_MAX) THEN
           RETURN FALSE;
         END IF  ;
      END IF;
    END IF;
    RETURN TRUE;
  END;
  --
  FUNCTION IS_DUREE_VALIDE_SQL(P_DUREE IN VARCHAR2,
                               P_TYPE_DUREE IN BINARY_INTEGER := C_DUREE_MOINS_24_HEURES,
                               P_ETENDUE_VALIDATION IN BINARY_INTEGER := C_VALIDER_PRESENCE + C_VALIDER_FORMAT + C_VALIDER_VALEUR
                              ) RETURN VARCHAR2 IS
    L_DUREE_VALIDE BOOLEAN;
  BEGIN
    L_DUREE_VALIDE := IS_DUREE_VALIDE(P_DUREE,P_TYPE_DUREE,P_ETENDUE_VALIDATION);
    IF L_DUREE_VALIDE IS NULL THEN
      RETURN 'TRUE';
    ELSIF L_DUREE_VALIDE THEN
      RETURN 'TRUE';
    ELSE
      RETURN 'FALSE';
    END IF;
  END;
  --
  FUNCTION test_date(l_dte IN VARCHAR2, l_format IN VARCHAR2) return BOOLEAN
is
  v_date date;
BEGIN
  select to_date(l_dte, l_format) into v_date from dual;
  return TRUE;
  exception when others then return FALSE;
END;
--
FUNCTION is_number (p_string IN VARCHAR2)
   RETURN INT
IS
   v_new_num NUMBER;
BEGIN
   v_new_num := TO_NUMBER(p_string);
   RETURN 1;
EXCEPTION
WHEN VALUE_ERROR THEN
   RETURN 0;
END is_number;
--
FUNCTION convert_format_heure (p_number IN number default 0)
   RETURN varchar2
IS
 l_reslt varchar2(10);
begin
  select case when length (trim(to_char(abs(trunc(p_number / 60)), '09'))) > 2 then 
                   trim(to_char(trunc(p_number / 60), '909')) 
			  else
                   trim(to_char(trunc(p_number / 60), '09')) end 
        || ':' ||trim(to_char(trunc(mod(abs(p_number), 60)), '09'))  into l_reslt from dual;
  if (sign(p_number) = -1 and substr(l_reslt,1,1) != '-') then
     l_reslt := '-'|| l_reslt;
  end if;
    return l_reslt;
  exception when no_data_found then
  return null;
END convert_format_heure;
-------------------------------------------------------------------------
-- Procédure qui corrige les journées fériés suite à un changement 
-- d'aménagement de temps de travail. 
-------------------------------------------------------------------------
  procedure gerer_att_et_ajuster_temps_res(pnu_no_seq_ressource     in number,
                                           pnu_no_seq_detail_attrav in fdtt_details_att.no_seq_detail_attrav%type,
                                           pda_dt_debut_att         in date,
                                           pda_dt_fin_att           in date,
                                           pnu_nb_hmin_jour         in fdtt_details_att.nb_hmin_jour%type,
                                           pnu_nb_hmin_sem          in fdtt_details_att.nb_hmin_sem%type,
                                           pnu_nb_jour_sem          in fdtt_details_att.nb_jour_sem%type,
                                           pva_note                 in fdtt_details_att.note%type,
                                           pva_request              in varchar2) is
      -- Curseur pour obtenir la ou les fdt à modifier
      cursor cur_obtenir_fdt_a_modifier_att(vnu_no_seq_activite in number) is
         SELECT fdtt.no_seq_ressource,
                fdtt.an_mois_fdt,
                fdtt.ind_saisie_autorisee,
                fdtt.no_seq_feuil_temps,
                tj.dt_temps_jour as date_activite_ferie,
                FDT_FNB_APX_OBT_NB_MINUTES_USAGER(fdtt.no_seq_ressource,
                                                  tj.dt_temps_jour,
                                                  tj.dt_temps_jour) as total_temps_journee
         from fdtt_feuilles_temps fdtt,
              fdtt_temps_jours    tj
         where fdtt.no_seq_ressource = pnu_no_seq_ressource 
           -- and fdtt.an_mois_fdt      >= to_char(pda_dt_debut_att,'yyyymm') 
           and fdtt.an_mois_fdt          >= (select min(fdt.an_mois_fdt)
                                             from fdtt_feuilles_temps fdt
                                             where fdt.no_seq_ressource = pnu_no_seq_ressource
                                               and fdt.ind_saisie_autorisee = 'O')           
           and tj.no_seq_feuil_temps = fdtt.no_seq_feuil_temps  
           and tj.no_seq_activite    = vnu_no_seq_activite;
      rec_obtenir_fdt_a_modifier_att cur_obtenir_fdt_a_modifier_att%rowtype; 
      -- Aller chercher le no_seq_activite des journées fériées.
      cursor cur_obt_seq_activite_ferie is
         select act.no_seq_activite
         from fdtt_activites act,
              fdtt_categorie_activites cat
         where cat.co_type_categorie = 'GENRQ'
           and act.no_seq_categ_activ = cat.no_seq_categ_activ
           and act.acronyme           = '100';
      vnu_no_seq_activite fdtt_activites.no_seq_activite%type;
      --
  begin
      -- On va chercher le no_seq_activite des journées fériées. 
     open cur_obt_seq_activite_ferie;
        fetch cur_obt_seq_activite_ferie into vnu_no_seq_activite;
     close cur_obt_seq_activite_ferie;
     --
     -- On fait l'insertion, la modification ou la destruction de l'aménagement de temps
     begin        
        if pva_request = utl_pkb_apx_securite.f_obtenir_request_create then
           -- Insertion
           insert into fdtt_details_att
                     (no_seq_ressource,
                      dt_debut_att,
                      dt_fin_att,
                      nb_hmin_jour,
                      nb_hmin_sem,
                      nb_jour_sem,
                      note)
              values (pnu_no_seq_ressource,
                      pda_dt_debut_att,
                      pda_dt_fin_att,
                      pnu_nb_hmin_jour,
                      pnu_nb_hmin_sem,
                      replace(pnu_nb_jour_sem,'.',','),
                      pva_note);
        else
           if pva_request = utl_pkb_apx_securite.f_obtenir_request_save then
             -- 
             update fdtt_details_att uatt
                set uatt.dt_debut_att = pda_dt_debut_att,
                    uatt.dt_fin_att   = pda_dt_fin_att,
                    uatt.nb_hmin_jour = pnu_nb_hmin_jour,
                    uatt.nb_hmin_sem  = pnu_nb_hmin_sem,
                    uatt.nb_jour_sem  = pnu_nb_jour_sem,
                    uatt.note         = pva_note    
             where uatt.no_seq_detail_attrav = pnu_no_seq_detail_attrav;
           else
              -- Destruction
              delete fdtt_details_att datt
              where datt.no_seq_detail_attrav = pnu_no_seq_detail_attrav;
           end if;     
        end if;
        --       

     end;
     -- On va mettre è jour les journées fériées de la ressource selon le ou les changements à son aménagement de temps.
     --begin           
        open cur_obtenir_fdt_a_modifier_att(vnu_no_seq_activite);
           fetch cur_obtenir_fdt_a_modifier_att into rec_obtenir_fdt_a_modifier_att;
              WHILE (cur_obtenir_fdt_a_modifier_att%FOUND) LOOP
                 if rec_obtenir_fdt_a_modifier_att.ind_saisie_autorisee = 'N' then
                    raise_application_error(-20000, 'Le traitement demandé touche des feuilles de temps non modifiables, il est impossible de poursuivre.');   
                 end if;
                 --
                 update fdtt_temps_jours tj
                    set tj.total_temps_min = rec_obtenir_fdt_a_modifier_att.total_temps_journee    
                 where tj.no_seq_feuil_temps = rec_obtenir_fdt_a_modifier_att.no_seq_feuil_temps
                   and tj.no_seq_activite    = vnu_no_seq_activite
                   and tj.dt_temps_jour      = rec_obtenir_fdt_a_modifier_att.date_activite_ferie;                           
              --
                 fetch cur_obtenir_fdt_a_modifier_att into rec_obtenir_fdt_a_modifier_att;             
              END LOOP;           
        close cur_obtenir_fdt_a_modifier_att; 
     --end;
  end gerer_att_et_ajuster_temps_res;
BEGIN
  -- Définition des formats et de leurs règles de validation
  -- (Pour que tout fonctionne, il faut qu'on permette seulement les chiffres,
  --  plus le «:» pour séparer les heures et les minutes)
  DEFINIR_FORMAT_DUREE(C_DUREE,C_FORMAT_HEURE,0,NULL);
  DEFINIR_FORMAT_DUREE(C_DUREE_CREDIT_HORAIRE,C_FORMAT_HEURE_JOUR_POS_NEG,NULL,NULL);
  DEFINIR_FORMAT_DUREE(C_DUREE_MOINS_24_HEURES,C_FORMAT_HEURE_JOUR,0,23 * 60 + 59);
  DEFINIR_FORMAT_DUREE(C_HEURE_ENTREE_AM,C_FORMAT_HEURE_JOUR, 7 * 60 + 30, 9 * 60 + 30);
  DEFINIR_FORMAT_DUREE(C_HEURE_SORTIE_AM,C_FORMAT_HEURE_JOUR,11 * 60 + 30,13 * 60 + 15);
  DEFINIR_FORMAT_DUREE(C_HEURE_ENTREE_PM,C_FORMAT_HEURE_JOUR,12 * 60 + 15,14 * 60 +  0);
  DEFINIR_FORMAT_DUREE(C_HEURE_SORTIE_PM,C_FORMAT_HEURE_JOUR,15 * 60 + 30,NULL);
END FDT_PKB_APX_UTIL_TEMPS;
/

