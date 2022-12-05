CREATE OR REPLACE TRIGGER FDT_TRB_FDTFIN_BIR
before insert on fdtt_fonct_intervenant 
for each row
begin
   if :new.no_seq_fonct_intervenant is null then
      select fdtfin_seq.nextval into :new.no_seq_fonct_intervenant from dual;
   end if;
end;
/
show errors
