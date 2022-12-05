PROMPT Creating Function 'fdt_fnb_apx_obt_cred_hor_an_usager'
create or replace function fdt_fnb_apx_obt_cred_hor_an_usager (pda_date_temps       in date,
                                                               pnu_no_seq_ressource in number)
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
   
   with act_credit_horaire as(select act.no_seq_activite
                              from fdtt_activites act
                              where act.acronyme = '122')
   select nvl(round(sum(tj.total_temps_min / fdt_fnb_apx_obt_nb_minutes_usager(pnu_no_seq_ressource,tj.dt_temps_jour)),2),0) journee_credit into vnu_sum_crd_hor_en_jour
   from fdtt_feuilles_temps ft,
        fdtt_temps_jours tj,
        act_credit_horaire ch
   where ft.no_seq_ressource   = pnu_no_seq_ressource
     and ft.an_mois_fdt BETWEEN to_char(vda_date_debut,'YYYYMM') and to_char(vda_date_fin,'YYYYMM')
     and tj.no_seq_feuil_temps = ft.no_seq_feuil_temps
     and tj.no_seq_activite    = ch.no_seq_activite;
   --
   return vnu_sum_crd_hor_en_jour;
end fdt_fnb_apx_obt_cred_hor_an_usager;
/
show errors
