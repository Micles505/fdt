  CREATE OR REPLACE PACKAGE BODY "FDT_PKB_UTIL_TEMPS" AS
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
--
  procedure ajuster_temp_emplo(pnu_co_employe_shq in number,
                               pda_dt_debut_recalcul in date) is
  begin
    for v_rt_feuille in (SELECT fdtt.co_employe_shq,
                                fdtt.an_mois_fdt,
                                fdtt.ind_saisie_autorisee
                           from fdtt_feuille_temps fdtt
                          where fdtt.co_employe_shq = pnu_co_employe_shq
                            and fdtt.an_mois_fdt >= to_char(pda_dt_debut_recalcul,'yyyymm'))loop
      --if v_rt_feuille.an_mois_fdt = '202206' and  then
	    if v_rt_feuille.ind_saisie_autorisee = 'N' then
           if v_rt_feuille.an_mois_fdt = '202206' then
               raise_application_error(-20000, 'Utiliser la nouvelle application FDT 2.0 disponible via votre portail (maison bleue dans le menu ZENWorks)');
	       else
		       raise_application_error(-20000, 'Le traitement demandé touche des feuilles de temps non modifiables, il est impossible de poursuivre.');
           end if;
        end if;
        for v_rt_jour in (select tj.dt_temps_jour,
                               (select decode(emp.co_interne_exter, 'I',nvl(att.nb_heure_jour, usa.nb_heure_usagr),0) 
                                from fdtt_detail_att att,
                                      fdtt_usager usa
                                where att.co_employe_shq(+) = usa.co_employe_shq
                                  and usa.co_employe_shq    = v_rt_feuille.co_employe_shq
                                  and tj.dt_temps_jour between att.dt_debut_att (+) and nvl(att.dt_fin_att (+), to_date('39990101','yyyymmdd')))nb_minute,
                                nvl((select 'O'
                                   from pilv_valeur_code fer
                                  where fer.co_repertoire = 'FERIE'
                                    and fer.co_systeme = 'PIL'
                                    and to_date(fer.co_valeur,'yyyymmdd') = tj.dt_temps_jour),'N') as in_ferie,
                                cumul_jour-(fdt_fnb_valida_tmps_diner(temps_diner , 45) )+
                                nvl((select sum(TOTAL_TEMPS)
                                     from fdtt_activite_temps
                                     where co_employe_shq = tj.co_employe_shq
                                     and dt_activite_temps = tj.dt_temps_jour
                                     and ID_ACTIVITE != '122'),0) as temp_total,
                                cumul_jour-(fdt_fnb_valida_tmps_diner(temps_diner , 45) )+
                                nvl((select sum(TOTAL_TEMPS)
                                     from fdtt_activite_temps
                                     where co_employe_shq = tj.co_employe_shq
                                     and dt_activite_temps = tj.dt_temps_jour),0) as temp_tout
                           from fdtt_temps_jour tj,
                                busv_info_employe emp,
                                FDTV_HORAIRE_VARIABLE_MAJ v
                          where v_rt_feuille.co_employe_shq = tj.co_employe_shq
                            and v_rt_feuille.an_mois_fdt = tj.an_mois_fdt
                            and tj.dt_temps_jour >= nvl(pda_dt_debut_recalcul,tj.dt_temps_jour)
                            and emp.co_employe_shq = v_rt_feuille.co_employe_shq
                            and v.co_employe_shq = tj.co_employe_shq
                            and v.dt_temps_jour = tj.dt_temps_jour)loop
            if v_rt_jour.in_ferie = 'O' then
            --dbms_output.
               update fdtt_activite_temps
                  set total_temps = v_rt_jour.nb_minute
               where co_employe_shq = pnu_co_employe_shq
                  and dt_activite_temps = v_rt_jour.dt_temps_jour
                  and id_activite = '100';
               update fdtt_temps_jour
                  set total_temps = v_rt_jour.nb_minute,
                      diffr_temps = 0
               where co_employe_shq = pnu_co_employe_shq
                  and dt_temps_jour = v_rt_jour.dt_temps_jour;
            else 
               update fdtt_temps_jour
                  set total_temps = v_rt_jour.temp_total,
                      diffr_temps = case when v_rt_jour.temp_tout =0 or v_rt_jour.nb_minute = 0 then 0 else  v_rt_jour.temp_total-v_rt_jour.nb_minute end
                where co_employe_shq = pnu_co_employe_shq
                  and dt_temps_jour = v_rt_jour.dt_temps_jour;
           end if;
         end loop;
       --end if;
	end loop;
  end ajuster_temp_emplo;
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
END FDT_PKB_UTIL_TEMPS;

/
