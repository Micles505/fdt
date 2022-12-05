CREATE OR REPLACE TRIGGER FDT_TRB_VRFDTE_BIUR 
before insert or update on fdtt_fonct_intervenant
for each row
declare
  vbo_resultat boolean;
  vva_message  varchar2(4000);
  vva_type     varchar2(1);
  vnu_retour number(1);
  vda_dt_actuelle date;
begin
   vda_dt_actuelle := utl_fnb_obt_dt_prodc('FDT', 'DA');
   if :new.dt_fin_fonction < vda_dt_actuelle then
	  -- La date de fin doit être égale ou supérieure à la date du jour.
	  vbo_resultat := utl_pkb_message.lire_message('FDT_Backup.000010', NULL, vva_type, vva_message);
      raise_application_error(-20001, vva_message);
   end if;
   if :new.dt_fin_fonction < :new.dt_debut_fonction then
	  -- La date de fin doit être égale ou supérieure à la date début
	  vbo_resultat := utl_pkb_message.lire_message('FDT_Backup.000011', NULL, vva_type, vva_message);
      raise_application_error(-20001, vva_message);
   end if;
   if inserting then
      if :new.dt_debut_fonction < vda_dt_actuelle then
         -- La date de début doit être égale ou supérieure à la date du jour
	     vbo_resultat := utl_pkb_message.lire_message('FDT_Backup.000009', NULL, vva_type, vva_message);
         raise_application_error(-20001, vva_message);
      end if;
      -- Vérifier en modification s'il y a chevauchement de date pour le même intervenant
      select max(1) into vnu_retour
      from fdtt_fonct_intervenant int
      where int.co_employe_shq = :new.co_employe_shq
	   and  int.no_groupe      = :new.no_groupe
       and :new.dt_debut_fonction between int.dt_debut_fonction
	   and nvl(int.dt_fin_fonction, vda_dt_actuelle + 36500);
      --
      if vnu_retour = 1 then
	     -- L'intervenant est déjà actif dans ce groupe pour cette date ou période.
	     vbo_resultat := utl_pkb_message.lire_message('FDT_Backup.000012', NULL, vva_type, vva_message);
         raise_application_error(-20001, vva_message);
      end if;
   end if; -- inserting
end FDT_TRB_VRFDTE_BIUR;
/
