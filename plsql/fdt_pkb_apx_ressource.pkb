create or replace package body fdt_pkb_apx_ressource is

  -- Private type declarations
  -- type < typename > is < datatype >;
  --
  -- Private constant declarations
  cva_reset_page         constant varchar2(02) := 'RP';
  cva_update_row_status constant character(01) := 'U';
  cva_create_row_status constant character(01) := 'C';
  cva_delete_row_status constant character(01) := 'D';
    -- Private constant declarations
  cva_co_systeme constant busv_systeme.CO_SYSTEME%type default fdt_pkb_apx_config.f_obtenir_code_systeme_fdt;
  -- logger
  cva_scope_prefix constant varchar2(31) := lower($$plsql_unit) || '.';
  --
  cdt_fdt_systeme_da constant date default utl_fnb_obt_dt_prodc(pva_co_systeme => cva_co_systeme,
                                                                pva_form_date  => 'DA');
  cva_co_message_sql_inj constant utlt_message_trait.co_message%type default '000083';
  -- logger
  cva_scope_prefix constant varchar2(31) := lower($$plsql_unit) || '.';

  --
  -- =================================================================================================
   -- Validations de la table aménagement de temps de travail associé à l'application FDT
   --  
   -- Paramètres entrants : 
   --    --> vtp_detail_att    --> Ensemble des champs de la table FDTT_DETAIL_ATT
   --    --> p_type_operation  --> REQUEST de la page Apex 
   -- 
   -- Paramètres sortants : Aucun
   -- =================================================================================================
   procedure p_valdt_apx_detail_att(vtp_detail_att   in fdtt_details_att%rowtype,
									p_type_operation in varchar2) IS
      --
      --vbo_valide       boolean := false;
      vva_desc_message utlt_message_trait.description_long%type;
      --
      vva_typ_msg utlt_message_trait.typ_message%type;
      --
      vva_message  varchar2(4000);
      vva_type     varchar2(1);
      vnu_retour   number(1);
      vda_dt_actuelle date;
      vva_an_mois_fdt fdtt_feuilles_temps.AN_MOIS_FDT%type;
	  --
	  cursor cur_obt_fdt_en_saisie is
         select max(an_mois_fdt)
         from fdtt_feuilles_temps
         where ind_saisie_autorisee = 'O'
          and  NO_SEQ_RESSOURCE = vtp_detail_att.NO_SEQ_RESSOURCE;
   begin
      --
      vda_dt_actuelle := utl_fnb_obt_dt_prodc('FDT', 'DA');
	  if p_type_operation in (utl_pkb_apx_securite.f_obtenir_request_create, utl_pkb_apx_securite.f_obtenir_request_create_add,
                              utl_pkb_apx_securite.f_obtenir_request_save  , utl_pkb_apx_securite.f_obtenir_request_save_add) then
         --
		 vva_an_mois_fdt := null;
		 open cur_obt_fdt_en_saisie;
            fetch cur_obt_fdt_en_saisie into vva_an_mois_fdt;
         close cur_obt_fdt_en_saisie;
		 -- 
		 if vtp_detail_att.dt_fin_att < vtp_detail_att.dt_debut_att then
	        -- La date de fin doit être égale ou supérieure à la date début
			vva_message := utl_pkb_apx_message.f_obt_message(pva_code_messa => 'FDT.000118',
                                                                pva_type_messa => vva_type);
            apex_error.add_error(p_message => vva_message, p_display_location => apex_error.c_inline_in_notification); 
         end if;
		 -- La date de fin doit être plus grande que la date de la fdt actuelle de la ressource
		 if  vtp_detail_att.DT_FIN_ATT is not null then  
			if vtp_detail_att.DT_FIN_ATT < to_date(vva_an_mois_fdt||'01','yyyymmdd') then
               vva_message := utl_pkb_apx_message.f_obt_message(pva_code_messa => 'FDT.000117',
                                                                pva_type_messa => vva_type);
		       apex_error.add_error(p_message => vva_message, p_display_location => apex_error.c_inline_in_notification);                               			
			end if;
         end if;		 
		 --
		 -- En création seulement
         if p_type_operation in (utl_pkb_apx_securite.f_obtenir_request_create, utl_pkb_apx_securite.f_obtenir_request_create_add) then
		    -- shqcge
			vva_an_mois_fdt := null;
			open cur_obt_fdt_en_saisie;
               fetch cur_obt_fdt_en_saisie into vva_an_mois_fdt;
            close cur_obt_fdt_en_saisie;
	        --
            if vva_an_mois_fdt is not null then       
               if vtp_detail_att.dt_debut_att < to_date(vva_an_mois_fdt||'01','yyyymmdd') then
	              -- La date de début artt est plus petite que la première journée de la fdt en saisie actuellement pour cet utilisateur 
		          -- de la feuille de temps en saisie pour cet utilisateur
				  vva_message := utl_pkb_apx_message.f_obt_message(pva_code_messa => 'FDT.000119',
                                                                   pva_type_messa => vva_type);
		          apex_error.add_error(p_message => vva_message, p_display_location => apex_error.c_inline_in_notification); 
	           end if;
	        else
	           -- Aucune feuille de temps en saisie pour cet employé, impossible de créer un aménagement de temps de travail
               vva_message := utl_pkb_apx_message.f_obt_message(pva_code_messa => 'FDT.000120',
                                                                pva_type_messa => vva_type);			   
		       apex_error.add_error(p_message => vva_message, p_display_location => apex_error.c_inline_in_notification);         	  
	        end if;
	        -- 
	        select max(1) into vnu_retour
            from fdtt_details_att int
            where int.no_seq_ressource = vtp_detail_att.no_seq_ressource
	          and vtp_detail_att.dt_debut_att <= int.dt_fin_att;
            --
	        if vnu_retour = 1 then
	           -- La date de début artt doit être plus grande que la date de fin de l'ARTT précédente.
			   vva_message := utl_pkb_apx_message.f_obt_message(pva_code_messa => 'FDT.000121',
                                                                pva_type_messa => vva_type);
	           apex_error.add_error(p_message => vva_message, p_display_location => apex_error.c_inline_in_notification);  
            else 
               -- Vérifier en création s'il y a chevauchement de date pour le même aménagement
               select max(1) into vnu_retour
               from fdtt_details_att int
               where int.no_seq_ressource = vtp_detail_att.no_seq_ressource
                 and vtp_detail_att.dt_debut_att between int.dt_debut_att 
        	     and nvl(int.dt_fin_att, vda_dt_actuelle + 36500);
               --
               if vnu_retour = 1 then
			      vva_message := utl_pkb_apx_message.f_obt_message(pva_code_messa => 'FDT.000122',
                                                                   pva_type_messa => vva_type);
                  apex_error.add_error(p_message => vva_message, p_display_location => apex_error.c_inline_in_notification); 
               end if;            			
            end if;
            --	  

		 end if;
         --
      end if;
   end p_valdt_apx_detail_att;	
   --
   -- Validations de la table aménagement de temps de travail associé à l'application FDT
   --  
   -- Paramètres entrants : 
   --    --> vtp_ressource_info_suppl    --> Ensemble des champs de la table FDTT_RESSOURCE_INFO_SUPPL
   --    --> p_type_operation  --> REQUEST de la page Apex 
   -- 
   -- Paramètres sortants : Aucun
   --
   procedure p_valdt_apx_ressource_info_suppl(vtp_ressource_info_suppl in fdtt_ressource_info_suppl%rowtype,
									          p_type_operation in varchar2) IS
   --
      vva_desc_message utlt_message_trait.description_long%type;
      --
      vva_typ_msg utlt_message_trait.typ_message%type;
      --
      vda_dt_actuelle date;
	  vbo_resultat boolean;
      vva_message  varchar2(4000);
      vva_type     varchar2(1);
      vnu_retour   number(1);
   begin
      vda_dt_actuelle := utl_fnb_obt_dt_prodc('FDT', 'DA');
      -- En création et en modification
	  if vtp_ressource_info_suppl.dt_fin < vtp_ressource_info_suppl.dt_debut then
	     -- La date de fin doit être égale ou supérieure à la date début
         vva_message := utl_pkb_apx_message.f_obt_message(pva_code_messa => 'FDT.000118',
                                                          pva_type_messa => vva_type);
         apex_error.add_error(p_message => vva_message, p_display_location => apex_error.c_inline_in_notification); 
      end if;
	  --En création seulement
      if p_type_operation in (utl_pkb_apx_securite.f_obtenir_request_create, utl_pkb_apx_securite.f_obtenir_request_create_add) then
         -- On regarde s'il y a un chevauchement
         -- 
	     select max(1) into vnu_retour
         from fdtt_ressource_info_suppl ires
         where ires.no_seq_ressource  = vtp_ressource_info_suppl.no_seq_ressource
		   and ires.co_unite_organ    = vtp_ressource_info_suppl.co_unite_organ
		   and ires.no_seq_specialite = vtp_ressource_info_suppl.no_seq_specialite
	       and vtp_ressource_info_suppl.dt_debut <= ires.dt_fin;
         --
	     if vnu_retour = 1 then
	        -- La date de début de l'info suppléementaire doit être plus grande que la date de fin de l'info supplémentaire précédente.
			vva_message := utl_pkb_apx_message.f_obt_message(pva_code_messa => 'FDT.000123',
                                                             pva_type_messa => vva_type);
	        apex_error.add_error(p_message => vva_message, p_display_location => apex_error.c_inline_in_notification); 
         else
            -- Vérifier en création s'il y a chevauchement de dates
            select max(1) into vnu_retour
            from fdtt_ressource_info_suppl ires
            where ires.no_seq_ressource  = vtp_ressource_info_suppl.no_seq_ressource
		      and ires.co_unite_organ    = vtp_ressource_info_suppl.co_unite_organ
		      and ires.no_seq_specialite = vtp_ressource_info_suppl.no_seq_specialite
              and vtp_ressource_info_suppl.dt_debut between ires.dt_debut 
              and nvl(ires.dt_fin, vda_dt_actuelle + 36500);
            --
            if vnu_retour = 1 then
               vva_message := utl_pkb_apx_message.f_obt_message(pva_code_messa => 'FDT.000124',
                                                                pva_type_messa => vva_type);
               apex_error.add_error(p_message => vva_message, p_display_location => apex_error.c_inline_in_notification); 
            end if;		 
         end if;
         --	  
      end if;	  
   end p_valdt_apx_ressource_info_suppl;
begin
  -- Initialization
  null;
end fdt_pkb_apx_ressource;
/
