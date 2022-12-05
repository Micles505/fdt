create or replace package body fdt_pkb_apx_040102 is
   -- ====================================================================================================
   -- Date        : 2021-11-25
   -- Par         : SHQYMR
   -- Description : G�rer le calendrier des absences
   -- ====================================================================================================
   -- Date        : 
   -- Par         : 
   -- Description : 
   -- ====================================================================================================
   --
   -- Private type declarations
   --
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
   -- Pour voir le r�sultat de la trace, il faut aller dans plsql_developeur et faire ce select :
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
   -- Valider la ressource
   -- =========================================================================
   Function f_valider_ressource (pre_calendrier_absence in fdtt_calendrier_absence%rowtype) return varchar2 is
      --
      vva_desc_message    varchar2(200);
      vva_type_messa      utlt_message_trait.typ_message%type;
	  --
	  --
      -- -------------------------------------------------------------------------------------------------
      --                                           logger
      -- -------------------------------------------------------------------------------------------------
      vva_scope logger_logs.scope%type := cva_scope_prefix || 'f_valider_ressource';
      vta_params logger.tab_param;
	  --
   begin
	  --
      -- -------------------------------------------------------------------------------------------------
      --                                           logger
      -- -------------------------------------------------------------------------------------------------
      logger.append_param(p_params => vta_params, 
	                      p_name   => 'D�but',
                          p_val    => 'f_valider_ressource');
	  --
      -------------------------------------------------------------------------
	  -- La ressource interne ou la ressource externe doit �tre inscrite
	  --
	  -- *** C'est un champ ou l'autre, pas les deux
      -------------------------------------------------------------------------
	  if (pre_calendrier_absence.no_seq_ressource is not null and pre_calendrier_absence.co_employe_shq is not null) or 
         (pre_calendrier_absence.no_seq_ressource is null and pre_calendrier_absence.co_employe_shq is null)	     then
         vva_desc_message := utl_pkb_apx_message.f_obt_message (pva_code_systeme => 'FDT',
                                                                pva_code_messa   => '000130',
                                                                -- pva_param_1      => null,
                                                                -- pva_param_2      => null,
                                                                pva_type_messa   => vva_type_messa);
      end if;
	  --
      -- -------------------------------------------------------------------------------------------------
      --                                           logger
      -- -------------------------------------------------------------------------------------------------
      logger.log_info(p_text   => 'Fin f_valider_ressource ', 
	                  p_scope  => vva_scope,
                      p_params => vta_params);
	  --
	  return vva_desc_message;
      --
	  exception when others then 
	                 apex_debug.info ('Exception f_valider_ressource %s', sqlerrm);
					 raise;
	  --
   end f_valider_ressource;
   --
   --
   -- =========================================================================
   -- Valider les dates 
   -- =========================================================================
   Function f_valider_date_contexte (pre_calendrier_absence in fdtt_calendrier_absence%rowtype) return varchar2 is
      --
      vva_desc_message    varchar2(200);    
      vva_type_messa      utlt_message_trait.typ_message%type;
	  vnu_nb_conflit      number;
	  --
	  cursor cur_obt_plage_en_conflit is
	     select count(*)
         from   fdtt_calendrier_absence calen
         where  calen.no_seq_calnd_absence <> coalesce (pre_calendrier_absence.no_seq_calnd_absence, -1)
		 and    decode (pre_calendrier_absence.no_seq_ressource, null, -1, calen.no_seq_ressource) = decode (pre_calendrier_absence.no_seq_ressource, null, -1, pre_calendrier_absence.no_seq_ressource)
		 and    decode (pre_calendrier_absence.co_employe_shq,   null, -1, calen.co_employe_shq)   = decode (pre_calendrier_absence.co_employe_shq,   null, -1, pre_calendrier_absence.co_employe_shq)
         and    ((calen.dt_debut >= pre_calendrier_absence.dt_debut and
                  calen.dt_debut <= pre_calendrier_absence.dt_fin)
         or      (calen.dt_fin   >= pre_calendrier_absence.dt_debut and
                  calen.dt_fin   <= pre_calendrier_absence.dt_fin));
	  --
	  --
      -- -------------------------------------------------------------------------------------------------
      --                                           logger
      -- -------------------------------------------------------------------------------------------------
      vva_scope logger_logs.scope%type := cva_scope_prefix || 'f_valider_date_contexte';
      vta_params logger.tab_param;
	  --
   begin
	  --
      -- -------------------------------------------------------------------------------------------------
      --                                           logger
      -- -------------------------------------------------------------------------------------------------
      logger.append_param(p_params => vta_params, 
	                      p_name   => 'D�but',
                          p_val    => 'f_valider_date_contexte');
	  --
      -------------------------------------------------------------------------
	  -- La date de retour d'absence doit �tre sup�rieure ou �gale � la date 
	  -- de d�but d'absence
      -------------------------------------------------------------------------
      if pre_calendrier_absence.dt_debut is not null and pre_calendrier_absence.dt_fin is not null then
         vva_desc_message := utl_pkb_apx_date.f_valider_date2_gte_date1 (pda_date1      => pre_calendrier_absence.dt_debut,
                                                                         pva_date1_desc => 'd�but r�elle',
                                                                         pda_date2      => pre_calendrier_absence.dt_fin, 
                                                                         pva_date2_desc => 'fin r�elle');
	  end if;
	  --
      -------------------------------------------------------------------------
	  -- Lorsque la date de d�but d'absence et la date de retour d'absence est
	  -- la m�me et que co_typ_ampm_debut est 'PM', le co_typ_ampm_fin ne peut
	  -- pas avoir la valeur 'AM' ... ce n'est pas logique
      -------------------------------------------------------------------------
	  if (pre_calendrier_absence.dt_debut is not null and pre_calendrier_absence.dt_fin is not null) and 
         (pre_calendrier_absence.dt_debut = pre_calendrier_absence.dt_fin)	                         then
	     if pre_calendrier_absence.co_typ_ampm_debut = 'PM' and pre_calendrier_absence.co_typ_ampm_fin = 'AM' then
            vva_desc_message := utl_pkb_apx_message.f_obt_message (pva_code_systeme => 'FDT',
                                                                   pva_code_messa   => '000129',
                                                                   -- pva_param_1      => null,
                                                                   -- pva_param_2      => null,
                                                                   pva_type_messa   => vva_type_messa);
		 end if;
      end if;
	  --
      -------------------------------------------------------------------------
	  -- La date de d�but d'absence et la date de retour d'absence doivent
	  -- �tres des jours ouvrables
      -------------------------------------------------------------------------
	  if pre_calendrier_absence.dt_debut is not null and pre_calendrier_absence.dt_fin is not null then
	     if not utl_pkb_date_ouvrable.est_ouvrable(pda_date => pre_calendrier_absence.dt_debut) or not utl_pkb_date_ouvrable.est_ouvrable(pda_date => pre_calendrier_absence.dt_fin) then
            vva_desc_message := utl_pkb_apx_message.f_obt_message (pva_code_systeme => 'FDT',
                                                                   pva_code_messa   => '000128',
                                                                   -- pva_param_1      => null,
                                                                   -- pva_param_2      => null,
                                                                   pva_type_messa   => vva_type_messa);
		 end if;
      end if;
	  --
      -------------------------------------------------------------------------
	  -- La plage d'absence en cours ne doit pas rentrer en conflit avec une
	  -- plage d'absence d�j� inscrite pour une m�me personne
      -------------------------------------------------------------------------
      if pre_calendrier_absence.dt_debut is not null and pre_calendrier_absence.dt_fin is not null then
	     open  cur_obt_plage_en_conflit;
		 fetch cur_obt_plage_en_conflit into vnu_nb_conflit;
		 close cur_obt_plage_en_conflit;
		 --
		 if vnu_nb_conflit > 0 then
            vva_desc_message := utl_pkb_apx_message.f_obt_message (pva_code_systeme => 'FDT',
                                                                   pva_code_messa   => '000131',
                                                                   -- pva_param_1      => null,
                                                                   -- pva_param_2      => null,
                                                                   pva_type_messa   => vva_type_messa);
		 end if;
	  end if;
	  --
      -- -------------------------------------------------------------------------------------------------
      --                                           logger
      -- -------------------------------------------------------------------------------------------------
      logger.log_info(p_text   => 'Fin f_valider_date_contexte ', 
	                  p_scope  => vva_scope,
                      p_params => vta_params);
	  --
	  return vva_desc_message;
      --
	  exception when others then 
	                 apex_debug.info ('Exception f_valider_date_contexte %s', sqlerrm);
					 raise;
	  --
   end f_valider_date_contexte;
   --
   --
   -- =========================================================================
   -- Calculer la dur�� entre la date de d�but d'absence et la date de retour
   -- d'absence
   -- =========================================================================
   Function f_calculer_duree (pre_calendrier_absence in fdtt_calendrier_absence%rowtype) return varchar2 is
	  --
	  --
      -- -------------------------------------------------------------------------------------------------
      --                                           Variables
      -- -------------------------------------------------------------------------------------------------
	  vva_nb_jour_ouvrable  varchar2(20);
	  vnu_nb_jours          number;
	  vva_duree_jhm         varchar2(20); 
	  vva_heures_minutes    varchar2(20);
	  --
	  --
      -- -------------------------------------------------------------------------------------------------
      --                                           logger
      -- -------------------------------------------------------------------------------------------------
      vva_scope logger_logs.scope%type := cva_scope_prefix || 'f_calculer_duree';
      vta_params logger.tab_param;
	  --
   begin
	  --
      -- -------------------------------------------------------------------------------------------------
      --                                           logger
      -- -------------------------------------------------------------------------------------------------
      logger.append_param(p_params => vta_params, 
	                      p_name   => 'D�but',
                          p_val    => 'f_calculer_duree');
	  --
      -------------------------------------------------------------------------
	  -- Calculer la dur�e de l'absence en cours
	  --
	  -- Il faut savoir qu'il existe des validations qui emp�che certaines 
	  -- situations.
	  --   --> la date de d�but d'absence et la date de retour d'absences 
	  --       doivent �tre des jours ouvrables
	  --   --> La date de retour d'absence ne peut �tre inf�rieure � la 
	  --       date de d�but d'absence
	  --   --> Lorsque la date de d�but d'absence est �gale � la date de 
	  --       retour d'absence, la date de retour ne peut �tre en AM lorsque
	  --       la date de d�but est en PM
      -------------------------------------------------------------------------
	  vva_nb_jour_ouvrable := utl_pkb_date_ouvrable.f_calc_jhms_ouvra(pre_calendrier_absence.dt_debut, pre_calendrier_absence.dt_fin);
	  vnu_nb_jours := substr (vva_nb_jour_ouvrable, 1, instr(vva_nb_jour_ouvrable, ':') - 1);
	  --
	  if pre_calendrier_absence.co_typ_ampm_debut = 'AM' then
	     if pre_calendrier_absence.co_typ_ampm_fin = 'AM' then
		    -- De AM � AM ... donc '00:00'
			--
		    vva_heures_minutes := '00:00';
		 elsif pre_calendrier_absence.co_typ_ampm_fin = 'PM' then
		    -- De AM � PM ... donc '03:30'
			--
			vva_heures_minutes := '03:30';
         end if;		 
	  elsif pre_calendrier_absence.co_typ_ampm_debut = 'PM' then
	     if pre_calendrier_absence.co_typ_ampm_fin = 'AM' then
            if pre_calendrier_absence.dt_debut <> pre_calendrier_absence.dt_fin then
			   --
			   -- Lorsque la journ�e du d�but de l'absence et la journ�e du retour de l'absence
			   -- sont diff�rentes, que l'absence commence le 'PM' de la journ�e de d�but et que
               -- le retour de l'absence est en 'AM, il faut soustraire une journ�e du calcul de 
			   -- nombre de jour car il y a une journ�e non compl�te dans le calcul avec la 
			   -- fonction "calc_jour_ouvra"	
   	           vnu_nb_jours       := vnu_nb_jours - 1;
			   --
		       -- De PM � AM ... donc '03:30'
			   --
		       vva_heures_minutes := '03:30';
			end if;
		 elsif pre_calendrier_absence.co_typ_ampm_fin = 'PM' then
		    -- De PM � PM ... donc '00:00'
			--
		    vva_heures_minutes := '00:00';
         end if;		 
	  end if;
	  vva_duree_jhm := lpad (trim (to_char (vnu_nb_jours)), 3, '0') || ':' || vva_heures_minutes;
	  --
      -- -------------------------------------------------------------------------------------------------
      --                                           logger
      -- -------------------------------------------------------------------------------------------------
      logger.log_info(p_text   => 'Fin f_calculer_duree ', 
	                  p_scope  => vva_scope,
                      p_params => vta_params);
	  --
	  return vva_duree_jhm;
      --
	  exception when others then 
	                 apex_debug.info ('Exception f_calculer_duree %s', sqlerrm);
					 raise;
	  --
   end f_calculer_duree;
   --
end fdt_pkb_apx_040102;
/
