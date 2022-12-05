PROMPT Creating Function 'FDT_FNB_VERIF_ARTT_USAGER'
CREATE OR REPLACE FUNCTION FDT_FNB_VERIF_ARTT_USAGER (pnu_co_employe_shq in number,
                                                      pdt_date_debut in date,
                                                      pdt_date_fin in date default null)
return boolean as
--
vnu_nb_heure_jour  number;
vnu_nb_heure_usagr number;
--
begin
 -- Renvoie 1 (true) si l'employé est en aménagement de temps de travail sinon 0 et 2 si rien n'est défini
   select max(att.nb_heure_jour),  
           max(usa.nb_heure_usagr) into vnu_nb_heure_jour, vnu_nb_heure_usagr
   from fdtt_detail_att att,
        fdtt_usager usa,
        fdtt_temps_jour jou
    where jou.co_employe_shq = att.co_employe_shq (+)
     and jou.co_employe_shq = usa.co_employe_shq
     and jou.co_employe_shq = pnu_co_employe_shq
     and jou.dt_temps_jour between nvl(att.dt_debut_att (+), jou.dt_temps_jour) and nvl(att.dt_fin_att (+), jou.dt_temps_jour)
     and jou.dt_temps_jour between pdt_date_debut and nvl(pdt_date_fin, pdt_date_debut);
   --  
   if vnu_nb_heure_jour > 0  then
      return true;
   end if;
    if vnu_nb_heure_usagr > 0  then
      return false;
   end if;
  return null;
END FDT_FNB_VERIF_ARTT_USAGER;
/
show errors