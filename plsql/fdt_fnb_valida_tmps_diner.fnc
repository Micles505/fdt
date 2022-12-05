PROMPT Creating Function 'FDT_FNB_VALIDA_TMPS_DINER'
CREATE OR REPLACE FUNCTION FDT_FNB_VALIDA_TMPS_DINER (pnu_temps_diner in number default 0, 
                                                      pnu_temps_diner_effect in number)
return number as 
vnu_result number;
begin
   if pnu_temps_diner < pnu_temps_diner_effect and pnu_temps_diner !=0 then
      vnu_result := pnu_temps_diner_effect - pnu_temps_diner  ;
   else
      vnu_result := 0;
   end if;
   --
   return vnu_result;
end fdt_fnb_valida_tmps_diner;
/
show errors