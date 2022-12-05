create or replace package body fdt_pkb_apx_010103 is
   -- ====================================================================================================
   -- Date        : 2021-09-24
   -- Par         : SHQYMR
   -- Description : Suivi des feuilles de temps
   -- ====================================================================================================
   -- Date        : 2021-12-20
   -- Par         : Christian Grenier
   -- Description : Modification procédure  p_ajouter_suivi_fdt et ajout procédure p_ajouter_suivi_a_corriger
   -- ====================================================================================================
   --
   -- Private type declarations
   --
      -- Curseur qui permet d'Aller chercher le co_employe_shq a qui appartient la fdt validé.
      cursor cur_obtenir_co_employe_fdt(pnu_no_seq_feuil_temps fdtt_suivi_feuilles_temps.no_seq_feuil_temps%type) is
      select res.co_employe_shq
      from fdtt_feuilles_temps fdt
         inner join fdtt_ressource res on res.no_seq_ressource  = fdt.no_seq_ressource
      where fdt.no_seq_feuil_temps = pnu_no_seq_feuil_temps; 
   --
   -- Private constant declarations
   --
   --
   -- Private variable declarations
   --
   --
   -- -------------------------------------------------------------------------------------------------
   --                                           logger
   -- -------------------------------------------------------------------------------------------------
   -- Pour voir le résultat de la trace, il faut aller dans plsql_developeur et faire ce select :
   --                               select * 
   --                               from   logger_logs_5_min
   --                               order by id desc
   -- -------------------------------------------------------------------------------------------------
   cva_scope_prefix constant varchar2(31) := lower($$plsql_unit) || '.';
   --
   -- -------------------------------------------------------------------------------------------------
   -- Function and procedure implementations
   -- -------------------------------------------------------------------------------------------------
   --
   --
   -- =========================================================================
   -- Ajouter un suivi de feuille de temps
   --
   --    *** Ajouter une validation ou approbation sur une feuille de temps
   -- =========================================================================
   procedure p_ajouter_suivi_fdt (pre_suivi_fdt            in fdtt_suivi_feuilles_temps%rowtype, 
                                  pnu_co_employe_shq_inter in fdtt_ressource.co_employe_shq%type) is
	  --
	  --
      -- -------------------------------------------------------------------------------------------------
      --                                           logger
      -- -------------------------------------------------------------------------------------------------
      vva_scope logger_logs.scope%type := cva_scope_prefix || 'p_ajouter_suivi_fdt';
      vta_params logger.tab_param;
      vnu_co_employe_shq_fdt        fdtt_ressource.co_employe_shq%type;
    	--
      vnu_no_seq_fonct_intervenant fdtt_fonct_intervenants.no_seq_fonct_intrv%type;
      vva_co_typ_fonction          fdtt_fonct_intervenants.co_typ_fonction%type;
   begin
	    --
      -- -------------------------------------------------------------------------------------------------
      --                                           logger
      -- -------------------------------------------------------------------------------------------------
      logger.append_param(p_params => vta_params, 
	                      p_name   => 'Début',
                          p_val    => 'p_ajouter_suivi_fdt');
      --       
	    -- Il faut aller chercher l'employé qui est concerné par cette FDT.
      --
      vnu_co_employe_shq_fdt := 0;
      open  cur_obtenir_co_employe_fdt(pre_suivi_fdt.no_seq_feuil_temps);
	       fetch cur_obtenir_co_employe_fdt into vnu_co_employe_shq_fdt;
	     close cur_obtenir_co_employe_fdt;  
      -- 
      fdt_prb_apx_obt_fct_interv(pnu_co_employe_shq_inter => pnu_co_employe_shq_inter,
                                 pnu_co_employe_shq_fdt   => vnu_co_employe_shq_fdt,
                                 pnu_no_seq_fonct_intervenant => vnu_no_seq_fonct_intervenant,
                                 pva_co_typ_fonction          => vva_co_typ_fonction);                                                                       
      -------------------------------------------------------------------------
	    -- Insérer un suivi de feuille de temps (Ajouter une validation ou
	    -- une approbation)
      -------------------------------------------------------------------------
	    insert into fdtt_suivi_feuilles_temps (no_seq_suivi_fdt,
                                            no_seq_fonct_intervenant,
                                            no_seq_feuil_temps,
                                            an_mois_fdt,
                                            co_typ_suivi_fdt,
                                            dh_suivi_fdt,
                                            commentaire,
                                            co_user_cre_enreg,
                                            co_user_maj_enreg,
                                            dh_cre_enreg,
                                            dh_maj_enreg)
             values (null,
			               vnu_no_seq_fonct_intervenant,
                     pre_suivi_fdt.no_seq_feuil_temps,
                     pre_suivi_fdt.an_mois_fdt,
                     case vva_co_typ_fonction        
                        when 'RESP_ASSI' then 
                           'VERI_RESP_ASSI'
                        when 'VALIDEUR'  then 
                           'VERI_VALIDA'            
                        when 'APPROB'    then 
                           'APPR_GESTI'                       
                     end,
                     utl_fnb_obt_dt_prodc('FDT','DH'),
                     pre_suivi_fdt.commentaire,
                     pre_suivi_fdt.co_user_cre_enreg,
                     pre_suivi_fdt.co_user_maj_enreg,
                     pre_suivi_fdt.dh_cre_enreg,
                     pre_suivi_fdt.dh_maj_enreg);
      -- On va mettre à jour la fdt pour ne pas que l'employé puisse saisir des données si elle est à Oui
      update fdtt_feuilles_temps
         set ind_saisie_autorisee  = 'N'--Feuille transmis valeur N, approuvé valeur N, valeur 'O' si feuille est à corriger
      where no_seq_feuil_temps = pre_suivi_fdt.no_seq_feuil_temps
        and ind_saisie_autorisee = 'O';   
      --	
	  --
      -- -------------------------------------------------------------------------------------------------
      --                                           logger
      -- -------------------------------------------------------------------------------------------------
      logger.log_info(p_text   => 'Fin p_ajouter_suivi_fdt ', 
	                  p_scope  => vva_scope,
                      p_params => vta_params);
	  --
	  exception when others then 
	                 apex_debug.info ('Exception p_ajouter_suivi_fdt %s', sqlerrm);
					 raise;
	  --
   end p_ajouter_suivi_fdt;
   --
   --
   -- =========================================================================
   -- Valider les interventions
   -- =========================================================================
   function f_valider_suivi_fdt (pre_suivi_fdt in fdtt_suivi_feuilles_temps%rowtype) return varchar2 is
      --
      vva_desc_message    varchar2(200);
	  vva_type_message    utlt_message_trait.typ_message%type;
	  vnu_nbr_enreg       number := 0;
	  --
	  cursor cur_verif_suivi_fdt is
	     select 1
         from   fdtt_suivi_feuilles_temps suivi_fdt
		 where  decode (pre_suivi_fdt.no_seq_fonct_intervenant, null, -1, suivi_fdt.no_seq_fonct_intervenant) = decode (pre_suivi_fdt.no_seq_fonct_intervenant, null, -1, pre_suivi_fdt.no_seq_fonct_intervenant)
         and    suivi_fdt.no_seq_feuil_temps       = pre_suivi_fdt.no_seq_feuil_temps
         and    suivi_fdt.an_mois_fdt              = pre_suivi_fdt.an_mois_fdt
         and    suivi_fdt.co_typ_suivi_fdt         = pre_suivi_fdt.co_typ_suivi_fdt;
	  --
	  --
      -- -------------------------------------------------------------------------------------------------
      --                                           logger
      -- -------------------------------------------------------------------------------------------------
      vva_scope logger_logs.scope%type := cva_scope_prefix || 'f_valider_suivi_fdt';
      vta_params logger.tab_param;
	  --
   begin
	  --
      -- -------------------------------------------------------------------------------------------------
      --                                           logger
      -- -------------------------------------------------------------------------------------------------
      logger.append_param(p_params => vta_params, 
	                      p_name   => 'Début',
                          p_val    => 'f_valider_suivi_fdt');
	  --
      -------------------------------------------------------------------------
	  -- Valider qu'il n'existe pas déjà un suivi avec le même type de suivi
	  -- pour la même personne et la même période
      -------------------------------------------------------------------------
	  open  cur_verif_suivi_fdt;
	  fetch cur_verif_suivi_fdt into vnu_nbr_enreg;
	  close cur_verif_suivi_fdt;
	  --
   	  if vnu_nbr_enreg > 0 then
         vva_desc_message := utl_pkb_apx_message.f_obt_message (pva_code_systeme => 'FDT',
                                                                pva_code_messa   => '000125',
                                                                pva_param_1      => pre_suivi_fdt.co_typ_suivi_fdt,
                                                                pva_type_messa   => vva_type_message);
	  end if;
	  --
      -- -------------------------------------------------------------------------------------------------
      --                                           logger
      -- -------------------------------------------------------------------------------------------------
      logger.log_info(p_text   => 'Fin f_valider_suivi_fdt ', 
	                  p_scope  => vva_scope,
                      p_params => vta_params);
	  --
	  return vva_desc_message;
      --
	  exception when others then 
	                 apex_debug.info ('Exception f_valider_suivi_fdt %s', sqlerrm);
					 raise;
	  --
   end f_valider_suivi_fdt;
   --
   procedure p_ajouter_suivi_a_corriger(pre_suivi_fdt in fdtt_suivi_feuilles_temps%rowtype, 
                                        pnu_co_employe_shq_inter in fdtt_ressource.co_employe_shq%type) is
      -- -------------------------------------------------------------------------------------------------
      --                                           logger
      -- -------------------------------------------------------------------------------------------------
      vva_scope logger_logs.scope%type := cva_scope_prefix || 'p_ajouter_suivi_a_corriger';
      vta_params logger.tab_param;
      vnu_co_employe_shq_fdt        fdtt_ressource.co_employe_shq%type;
      --
      vnu_no_seq_fonct_intervenant fdtt_fonct_intervenants.no_seq_fonct_intrv%type;
      vva_co_typ_fonction          fdtt_fonct_intervenants.co_typ_fonction%type;
      --vva_type_validation          varchar2(15);
      vvc_Adrs_expdt varchar2(1000);
      vvc_Adrs_destn varchar2(1000);
      -- 
      cursor cur_obtenir_adr_courriel(pnu_co_employe number) is
         select adr_courriel_employe 
         from busv_info_employe
         where CO_EMPLOYE_SHQ = pnu_co_employe;   
   begin
      --
      -- -------------------------------------------------------------------------------------------------
      --                                           logger
      -- -------------------------------------------------------------------------------------------------
      logger.append_param(p_params => vta_params, 
                          p_name   => 'Début',
                          p_val    => 'p_ajouter_suivi_a_corriger');
      --       
      -- Il faut aller chercher l'employé qui est concerné par cette FDT.
      --
      vnu_co_employe_shq_fdt := 0;
      open  cur_obtenir_co_employe_fdt(pre_suivi_fdt.no_seq_feuil_temps);
         fetch cur_obtenir_co_employe_fdt into vnu_co_employe_shq_fdt;
       close cur_obtenir_co_employe_fdt;  
      -- 
      fdt_prb_apx_obt_fct_interv(pnu_co_employe_shq_inter => pnu_co_employe_shq_inter,
                                 pnu_co_employe_shq_fdt   => vnu_co_employe_shq_fdt,
                                 pnu_no_seq_fonct_intervenant => vnu_no_seq_fonct_intervenant,
                                 pva_co_typ_fonction          => vva_co_typ_fonction);                                                                       
      -- On va mettre à jour la fdt pour que l'employé puisse saisir ses modifications dans sa FDT
      update fdtt_feuilles_temps
         set ind_saisie_autorisee  = 'O'
      where no_seq_feuil_temps = pre_suivi_fdt.no_seq_feuil_temps;   
      -------------------------------------------------------------------------
      -- Insérer un suivi de feuille de temps (Ajouter une validation ou
      -- une approbation)
      -------------------------------------------------------------------------
      insert into fdtt_suivi_feuilles_temps (no_seq_suivi_fdt,
                                            no_seq_fonct_intervenant,
                                            no_seq_feuil_temps,
                                            an_mois_fdt,
                                            co_typ_suivi_fdt,
                                            dh_suivi_fdt,
                                            commentaire,
                                            co_user_cre_enreg,
                                            co_user_maj_enreg,
                                            dh_cre_enreg,
                                            dh_maj_enreg)
             values (null,
                     vnu_no_seq_fonct_intervenant,
                     pre_suivi_fdt.no_seq_feuil_temps,
                     pre_suivi_fdt.an_mois_fdt,
                     'A_CORRIGER',
                     utl_fnb_obt_dt_prodc('FDT','DH'),
                     pre_suivi_fdt.commentaire,
                     pre_suivi_fdt.co_user_cre_enreg,
                     pre_suivi_fdt.co_user_maj_enreg,
                     pre_suivi_fdt.dh_cre_enreg,
                     pre_suivi_fdt.dh_maj_enreg);
      --
      -- On va envoyer un courriel à l'employé pour l'avertir qu'il a une correction à faire dans sa FDT.
      open  cur_obtenir_adr_courriel(vnu_co_employe_shq_fdt);
         fetch cur_obtenir_adr_courriel into vvc_Adrs_destn;
      close cur_obtenir_adr_courriel;
      -- Maintenant celle de l'intervenant     
      open  cur_obtenir_adr_courriel(pnu_co_employe_shq_inter);
         fetch cur_obtenir_adr_courriel into vvc_Adrs_expdt;
      close cur_obtenir_adr_courriel; 
      -- On envoit le courriel
      begin
         UTL_PKB_COURRIEL.ENVOIE_MESSAGE(PVA_EXPEDITEUR =>vvc_Adrs_expdt,
                                         PVA_DESTINATAIRE =>vvc_Adrs_destn,
                                         PVA_SUJET =>'Feuille de temps à corriger',
                                         PVA_MESSAGE =>'Bonjour,
                             Votre feuille de temps (période : '|| to_char(to_date(pre_suivi_fdt.an_mois_fdt,'yyyymm'),'month yyyy')||') doit être corrigée.
                             Commentaire de l''approbateur : '|| pre_suivi_fdt.commentaire);

      EXCEPTION
         --WHEN mauvaise_adresse_courriel THEN
         --    apex_debug.message('Erreur MAUVAISE ADRESSE COURRIEL');            
         WHEN OTHERS THEN
            apex_debug.message('Erreur lors de envoit : ' ||SQLERRM );
            null;
      end;     
      -- -------------------------------------------------------------------------------------------------
      --                                           logger
      -- -------------------------------------------------------------------------------------------------
      logger.log_info(p_text   => 'Fin p_ajouter_suivi_a_corriger ', 
                      p_scope  => vva_scope,
                      p_params => vta_params);
      --
   exception when others then 
                   apex_debug.info ('Exception p_ajouter_suivi_a_corriger %s', sqlerrm);
           raise;
    --
   end p_ajouter_suivi_a_corriger; 
   -- =========================================================================
   -- Permet de savoir si un intervenant avec le même rôle à approuver la fdt en cours de suivi.
   -- Retourne vrai si c'est le cas et faux si la fdt n'a pas été approuvée par ce type d'intervenant.
   -- =========================================================================  
   procedure p_verif_suivi_effectue_par_inter(pnu_no_seq_feuil_temps   in fdtt_suivi_feuilles_temps.no_seq_feuil_temps%type,
                                              pnu_co_employe_shq_inter in fdtt_ressource.co_employe_shq%type,
                                              pva_verif_suivi_effectue out varchar2,
                                              pva_co_typ_fonction      out varchar2) is
      -- Déclaration des variables
      vnu_co_employe_shq_fdt        fdtt_ressource.co_employe_shq%type;
      vnu_no_seq_fonct_intervenant  fdtt_fonct_intervenants.no_seq_fonct_intrv%type;
      --vva_co_typ_fonction           fdtt_fonct_intervenants.co_typ_fonction%type;
      vva_co_typ_suivi_a_rechercher fdtt_suivi_feuilles_temps.co_typ_suivi_fdt%type;
      vva_no_seq_suivi_rechercher   varchar2(20);   
      -- Curseur qui permet d'aller voir si la fdt a déjà été approuvée par cet intervnant ou un autre du même type
      cursor cur_obtenir_suivi_type_inter(pva_co_typ_suivi_a_rechercher fdtt_suivi_feuilles_temps.co_typ_suivi_fdt%type) is
      select to_char(suivi.no_seq_suivi_fdt)
      from  fdtt_suivi_feuilles_temps suivi
      where suivi.no_seq_feuil_temps = pnu_no_seq_feuil_temps
        and suivi.co_typ_suivi_fdt   = pva_co_typ_suivi_a_rechercher; 
      -- -------------------------------------------------------------------------------------------------
      --                                           logger
      -- -------------------------------------------------------------------------------------------------
      vva_scope logger_logs.scope%type := cva_scope_prefix || 'f_verif_suivi_effectue_par_inter';
      vta_params logger.tab_param;
    --
   begin
      --
      -- -------------------------------------------------------------------------------------------------
      --                                           logger
      -- -------------------------------------------------------------------------------------------------
      logger.append_param(p_params => vta_params, 
                        p_name   => 'Début',
                          p_val    => 'p_verif_suivi_effectue_par_inter');
      --       
      -- Il faut aller chercher l'employé qui est concerné par cette FDT.
      --
      vnu_co_employe_shq_fdt := 0;
      open  cur_obtenir_co_employe_fdt(pnu_no_seq_feuil_temps);
         fetch cur_obtenir_co_employe_fdt into vnu_co_employe_shq_fdt;
       close cur_obtenir_co_employe_fdt; 
      -- On va chercher le type de l'intervenant qui fait le suivi actuellement
      fdt_prb_apx_obt_fct_interv(pnu_co_employe_shq_inter => pnu_co_employe_shq_inter,
                                 pnu_co_employe_shq_fdt   => vnu_co_employe_shq_fdt,
                                 pnu_no_seq_fonct_intervenant => vnu_no_seq_fonct_intervenant,
                                 pva_co_typ_fonction          => pva_co_typ_fonction); 
      case         
         when pva_co_typ_fonction = 'RESP_ASSI' then 
            vva_co_typ_suivi_a_rechercher := 'VERI_RESP_ASSI';
         when pva_co_typ_fonction = 'VALIDEUR'  then 
            vva_co_typ_suivi_a_rechercher := 'VERI_VALIDA';            
         when pva_co_typ_fonction = 'APPROB'    then 
            vva_co_typ_suivi_a_rechercher := 'APPR_GESTI';                       
      end case;  
      --
      vva_no_seq_suivi_rechercher := null;
      open  cur_obtenir_suivi_type_inter(vva_co_typ_suivi_a_rechercher);
         fetch cur_obtenir_suivi_type_inter into vva_no_seq_suivi_rechercher;
      close cur_obtenir_suivi_type_inter;     
      --
      -- -------------------------------------------------------------------------------------------------
      --                                           logger
      -- -------------------------------------------------------------------------------------------------
      logger.log_info(p_text   => 'Fin f_valider_suivi_fdt ', 
                    p_scope  => vva_scope,
                      p_params => vta_params);
      --
      if vva_no_seq_suivi_rechercher is null then
         pva_verif_suivi_effectue := 'N';
      else
         pva_verif_suivi_effectue := 'O';
      end if; 
      --
      --
    exception when others then 
                   apex_debug.info ('Exception p_verif_suivi_effectue_par_inter %s', sqlerrm);
           raise;
    --
   end p_verif_suivi_effectue_par_inter;
   -- =========================================================================
   -- Permet de savoir si on affiche le bouton en paramètre ou non
   -- 2 boutons possibles : APPROUVER et CORRIGER
   -- ========================================================================= 
   function f_determiner_si_affiche_bouton (pnu_no_seq_feuil_temps   in fdtt_suivi_feuilles_temps.no_seq_feuil_temps%type,
                                            pva_co_typ_fonction_inter in varchar2,
                                            pva_bouton in varchar2) return varchar2 is
      -- Déclaration de variables
      -- Curseur qui permet d'aller chercher le dernier suivi sur la FDT
      cursor cur_obtenir_dernier_suivi_fdt is
      select suivi.no_seq_feuil_temps, suivi.co_typ_suivi_fdt, suivi.an_mois_fdt as an_mois_fdt_suivi, fdt.no_seq_ressource
      from  fdtt_suivi_feuilles_temps suivi,
            fdtt_feuilles_temps       fdt
      where suivi.no_seq_feuil_temps = pnu_no_seq_feuil_temps
        and fdt.no_seq_feuil_temps   = pnu_no_seq_feuil_temps
        and suivi.no_seq_suivi_fdt = (select max(sfdt.no_seq_suivi_fdt)
                                        from fdtt_suivi_feuilles_temps sfdt
                                        where sfdt.no_seq_feuil_temps = pnu_no_seq_feuil_temps);
      rec_obtenir_dernier_suivi_fdt   cur_obtenir_dernier_suivi_fdt%rowtype; 
      --
      cursor cur_obtenir_fdt_actuelle is
         select coalesce(max(to_char(to_date(an_mois_fdt,'yyyymm'), 'yyyymm')),to_char(utl_fnb_obt_dt_prodc('FDT', 'DS'),'yyyymm')) as an_mois_fdt_actuel
         from fdtt_feuilles_temps
         where NO_SEQ_RESSOURCE = rec_obtenir_dernier_suivi_fdt.no_seq_ressource;
      rec_obtenir_fdt_actuelle cur_obtenir_fdt_actuelle%rowtype;
      --
      vva_afficher_bouton varchar2(1); 
      --  
      vva_an_mois_fdt_prec varchar2(6);                  
   begin
      vva_afficher_bouton := null;
      -- On regarde si la fdt est approuvée par le gestionnaire.
      open  cur_obtenir_dernier_suivi_fdt;
         fetch cur_obtenir_dernier_suivi_fdt into rec_obtenir_dernier_suivi_fdt;
      close cur_obtenir_dernier_suivi_fdt;    
      --
      if rec_obtenir_dernier_suivi_fdt.co_typ_suivi_fdt = 'APPR_GESTI' then
         if upper(pva_bouton) = 'APPROUVER' then
            vva_afficher_bouton := 'N';
         else
            -- Le bouton À corriger pourrait apparaître pour un gestionnaire si c'est un suivi qui concerne
            -- la fdt précédente à celle qui est en cours pour l'employé.  Ex: L'employé fait la saisie de décembre, sa fdt de 
            -- novembre pourrrait être mise à corriger même si elle est approuvée (seulement pas le gestionnaire)
            if pva_co_typ_fonction_inter = 'APPROB' then
               -- On va chercher la fdt actuelle de l'employé
               open  cur_obtenir_fdt_actuelle;
                  fetch cur_obtenir_fdt_actuelle into rec_obtenir_fdt_actuelle;
               close cur_obtenir_fdt_actuelle;
               --
               vva_an_mois_fdt_prec := to_char(ADD_MONTHS(to_date(rec_obtenir_fdt_actuelle.an_mois_fdt_actuel || '01','YYYYMMDD'),-1),'YYYYMM');
               if rec_obtenir_dernier_suivi_fdt.an_mois_fdt_suivi = vva_an_mois_fdt_prec then
                  vva_afficher_bouton := 'O';
               else
                  vva_afficher_bouton := 'N';
               end if;                                                             
            else
               vva_afficher_bouton := 'N';              
            end if;   
         end if;
      else
         vva_afficher_bouton := 'O';        
      end if; 
      --
      return vva_afficher_bouton;   
   end f_determiner_si_affiche_bouton; 
   -- =========================================================================
   -- Fontion qui renvoit une requête sql pour obtenir la liste des absences 
   -- SAGIR d'une ressources pour un mois.
   -- =========================================================================
   function f_retourner_requete_sagir_suivi return varchar2 is
      -- Déclaration des variables
      vva_requete_sql varchar2(4000);
   begin
      -- 
      vva_requete_sql := q'~
          select emp.NOM_EMPLOYE || ' ,' || emp.PRE_EMPLOYE as nom_employe,
                 sabs.absence_attendance_type_id,
                 sabs.person_id,
                 sabs.date_creation,
                 sabs.absence_hours,
                 sabs.date_start || ' ' || sabs.time_start,
                 sabs.date_end || ' ' || sabs.time_end,
                 sabs.attribute1  as date_retour,
                 sabs.attribute7  as journee,
                 sabs.attribute8  as heure,
                 sabs.attribute10 as minutes,
                 sabs.attribute14,
                 typa.attribute1  as code_absence,
                 typa.attribute2  as precision_code_absence,
                 typa.attribute1 || '-' || typa.name        as description_absence 
          from  fdtt_ressource res
                    inner join bust_employe   emp  on emp.co_employe_shq = res.co_employe_shq
                    inner join SAGIR_ABSENCES sabs on sabs.person_id = res.id_personne_sagir,
                SAGIR_TYPES_ABSENCES typa 
          where res.no_seq_ressource = :P38_NO_SEQ_RESSOURCE   
            and sabs.absence_attendance_type_id not in (7086)
            and (sabs.date_start between to_date(:P38_AN_MOIS_FDT||'01','yyyymmdd') and to_date(last_day(to_date(:P38_AN_MOIS_FDT,'yyyymm'))) or
                 sabs.date_end   between to_date(:P38_AN_MOIS_FDT||'01','yyyymmdd') and to_date(last_day(to_date(:P38_AN_MOIS_FDT,'yyyymm'))))
            and typa.absence_attendance_type_id = sabs.absence_attendance_type_id
          order by 6~'; 
      -- 
      return vva_requete_sql;       
      --                                 
   end f_retourner_requete_sagir_suivi;                                                                                
end fdt_pkb_apx_010103;
/

