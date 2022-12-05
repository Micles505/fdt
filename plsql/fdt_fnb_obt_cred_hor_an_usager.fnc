PROMPT Creating Function 'fdt_fnb_obt_cred_hor_an_usager'
create or replace function fdt_fnb_obt_cred_hor_an_usager (pda_date_temps in date,
                                                           pnu_co_employe_shq in number)
return number as
--
vnu_sum_crd_hor_en_jour  number;
vda_date_debut date;
vda_date_fin date;
--
begin
   vnu_sum_crd_hor_en_jour := 0;   
   --
   if pda_date_temps <  to_date(extract(year from pda_date_temps) ||'-04'|| '-01', 'yyyy-mm-dd') then
      vda_date_debut := to_date((extract(year from pda_date_temps)-1) ||'-04'|| '-01', 'yyyy-mm-dd');
	    vda_date_fin   := to_date(extract(year from pda_date_temps) ||'-03'|| '-31', 'yyyy-mm-dd');
   else   
      vda_date_debut := to_date(extract(year from pda_date_temps)||'-04'|| '-01', 'yyyy-mm-dd');
	    vda_date_fin   := to_date((extract(year from pda_date_temps) + 1) ||'-03'|| '-31', 'yyyy-mm-dd');
   end if;
   --
   select nvl(sum(actt.total_temps / fdt_fnb_obt_nb_minutes_usager(actt.co_employe_shq,actt.dt_activite_temps)),0) journee_credit into vnu_sum_crd_hor_en_jour
   from fdtt_activite_temps actt        
   where actt.co_employe_shq  = pnu_co_employe_shq
    and  actt.id_activite = 122
    and  actt.dt_activite_temps between vda_date_debut and vda_date_fin;
   --
   return vnu_sum_crd_hor_en_jour;
end fdt_fnb_obt_cred_hor_an_usager;
/
show errors