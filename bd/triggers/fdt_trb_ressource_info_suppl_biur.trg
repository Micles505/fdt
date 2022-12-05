CREATE OR REPLACE TRIGGER FDT_TRB_RESSOURCE_INFO_SUPPL_BIUR
 before insert or update on FDTT_RESSOURCE_INFO_SUPPL
 for each row
begin
  case
    when inserting then
      --
      -- Initialiser la séquence
      if :new.no_seq_ressr_info_suppl  is null then
        :new.no_seq_ressr_info_suppl := fdtressrinfosup_seq.nextval;
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

