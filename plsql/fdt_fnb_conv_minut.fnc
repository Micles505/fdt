PROMPT Creating Function 'FDT_FNB_CONV_MINUT'
create or replace FUNCTION "FDT_FNB_CONV_MINUT" (pva_hour in varchar2 ) return varchar2 as
vva_hour varchar2(10);
begin
   vva_hour := pva_hour;
   if pva_hour is not null then
     if substr(trim(pva_hour),1,1) = '-' then
        vva_hour := substr(pva_hour,2);
        return  ((to_number(substr(to_char(to_date(lpad(replace(vva_hour,':',''),4,'0'),'hh24:mi'),'hh24:mi'),1,2))*60)
        + to_number(substr(to_char(to_date(lpad(replace(vva_hour,':',''),4,'0'),'hh24:mi'),'hh24:mi'), 4, 2)))*-1;
      else
        return (to_number(substr(to_char(to_date(lpad(replace(pva_hour,':',''),4,'0'),'hh24:mi'),'hh24:mi'),1,2))*60)
        + to_number(substr(to_char(to_date(lpad(replace(pva_hour,':',''),4,'0'),'hh24:mi'),'hh24:mi'), 4, 2));
      end if;
   else
    return 0;
   end if;
end fdt_fnb_conv_minut;
/
show errors
