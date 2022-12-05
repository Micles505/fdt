create or replace TRIGGER FDT_TRB_FDTACTIVITETEMPS_BIUDR 
before delete or insert or update 
on fdtt_activite_temps 
FOR EACH ROW
begin
 if inserting then
  if (:new.total_temps is null )
      and (:new.id_activite is not null ) then
     raise_application_error(-20022,
                                  'Vous devez saisir un temps pour cette absence');
  end if;
  if (:new.total_temps is not null )
     and (:new.id_activite is null ) then
     raise_application_error(-20022,
                                  'Vous devez choisir le type d''absence');
  end if;
end if;
if updating then
    if (:old.total_temps is null )
      and (:old.id_activite is not null ) then
     raise_application_error(-20022,
                                  'Vous devez saisir un temps pour cette absence');
  end if;
  if (:new.total_temps is not null )
     and (:new.id_activite is null ) then
     raise_application_error(-20022,
                                  'Vous devez choisir le type d''absence');
  end if;
end if;
END;
/
show errors