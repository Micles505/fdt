CREATE OR REPLACE TRIGGER FDT_TRB_VRFDTE_UTIL_BIUR 
before insert or update on fdtt_detail_att
for each row
declare
  vbo_resultat boolean;
  vva_message  varchar2(4000);
  vva_type     varchar2(1);
  vnu_retour   number(1);
  vda_dt_actuelle date;
  vva_an_mois_fdt varchar2(6);
begin
    vda_dt_actuelle := utl_fnb_obt_dt_prodc('FDT', 'DA');
    --if :new.dt_fin_att< vda_dt_actuelle then
	--   -- La date de fin doit être égale ou supérieure à la date du jour.
	--   vbo_resultat := utl_pkb_message.lire_message('FDT_Backup.000010', NULL, vva_type, vva_message);
    --   raise_application_error(-20001, vva_message);
    --end if;
    if :new.dt_fin_att < :new.dt_debut_att then
	   -- La date de fin doit être égale ou supérieure à la date début
	   vbo_resultat := utl_pkb_message.lire_message('FDT_Backup.000011', NULL, vva_type, vva_message);
       raise_application_error(-20001, vva_message);
    end if;
    if inserting then
      --if :new.dt_debut_att < vda_dt_actuelle then
      --     -- La date de début doit être égale ou supérieure à la date du jour
      --     vbo_resultat := utl_pkb_message.lire_message('FDT_Backup.000009', NULL, vva_type, vva_message);
      --     raise_application_error(-20001, vva_message);
      --end if;
	  --
	  select max(an_mois_fdt) into vva_an_mois_fdt
      from fdtt_feuille_temps
      where ind_saisie_autorisee = 'O'
       and  co_employe_shq = :new.co_employe_shq;
	  --
      if vva_an_mois_fdt is not null then
         if :new.dt_debut_att < to_date(vva_an_mois_fdt||'01','yyyymmdd') then
	        -- La date de début artt est plus petite que la première journée de la fdt en saisie actuellement pour cet utilisateur
		    -- de la feuille de temps en saisie pour cet utilisateur
		    --vva_message := 'La date début de ARTT doit être plus grande ou égale à la première journée de la fdt en saisie pour cet utilisateur';
			vbo_resultat := utl_pkb_message.lire_message('FDT_Backup.000027', NULL, vva_type, vva_message);
		    raise_application_error(-20001, vva_message);
	     end if;
	  else
	     -- Aucune feuille de temps en saisie pour cet employé, impossible de créer un aménagement de temps de travail
		 --vva_message := 'Aucune feuille de temps en saisie pour cet employé, impossible de créer un aménagement de temps de travail';
		 vbo_resultat := utl_pkb_message.lire_message('FDT_Backup.000028', NULL, vva_type, vva_message);
		 raise_application_error(-20001, vva_message);
	  end if;
	  --
	  select max(1) into vnu_retour
      from fdtt_detail_att int
      where int.co_employe_shq = :new.co_employe_shq
	   and :new.dt_debut_att <= int.dt_fin_att;
      --
	  if vnu_retour = 1 then
	     -- La date de début artt doit être plus grande que la date de fin de l'ARTT précédente.
		 --vva_message := 'La date de début de l'artt doit être plus grande que la date de fin de l'artt précédente';
         vbo_resultat := utl_pkb_message.lire_message('FDT_Backup.000029', NULL, vva_type, vva_message);
		 raise_application_error(-20001, vva_message);
      end if;
      --
      -- Vérifier en modification s'il y a chevauchement de date pour le même aménagement
      select max(1) into vnu_retour
      from fdtt_detail_att int
      where int.co_employe_shq = :new.co_employe_shq
       and :new.dt_debut_att between int.dt_debut_att
	   and nvl(int.dt_fin_att, vda_dt_actuelle + 36500);
       --
       if vnu_retour = 1 then
           vbo_resultat := utl_pkb_message.lire_message('FDT_Backup.000008', NULL, vva_type, vva_message);
           raise_application_error(-20001, vva_message);
       end if;
    end if; -- inserting
end FDT_TRB_VRFDTE_UTIL_BIUR;
/
