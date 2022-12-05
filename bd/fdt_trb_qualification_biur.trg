CREATE OR REPLACE TRIGGER FDT_TRB_QUALIFICATION_BIUR
 before insert or update on FDTT_QUALIFICATION
 for each row
begin
  case
  
    when inserting then
      -- Initialiser la séquence
      if :new.no_seq_qualification is null then
        :new.no_seq_qualification := fdtqualf_seq.nextval;
      end if;

      --
      if :new.co_user_cre_enreg is null then
        :new.co_user_cre_enreg := coalesce(apex_application.g_user, user);
      end if;
      --
      :new.dh_cre_enreg := systimestamp;

    when updating then
      if :new.co_user_maj_enreg is null then
        :new.co_user_maj_enreg := coalesce(apex_application.g_user, user);
      end if;
      --
      :new.dh_maj_enreg := systimestamp;
    else
      null;
  end case;
end;
/

