PROMPT Creating Function 'FDT_FNB_APX_VERIF_ARTT_USAGER'
CREATE OR REPLACE FUNCTION FDT_FNB_APX_VERIF_ARTT_USAGER (pnu_no_seq_ressource in number,
                                                          pdt_date_debut       in date,
                                                          pdt_date_fin         in date default null)
return boolean as
--
vnu_nb_heure_jour  number;
vnu_nb_heure_usagr number;
--
begin
   --
   select max(att.nb_hmin_jour),  
           max(res.nb_hmin_jour_ressr) into vnu_nb_heure_jour, vnu_nb_heure_usagr 
   from fdtt_details_att    att,
        fdtt_ressource      res,
        fdtt_temps_jours    jou,
        fdtt_feuilles_temps fdt
   where res.no_seq_ressource   = pnu_no_seq_ressource
     and res.NO_SEQ_RESSOURCE   = att.NO_SEQ_RESSOURCE (+)
     and fdt.no_seq_ressource   = res.NO_SEQ_RESSOURCE
     and jou.no_seq_feuil_temps = fdt.no_seq_feuil_temps 
     and jou.dt_temps_jour between nvl(att.dt_debut_att (+), jou.dt_temps_jour) and nvl(att.dt_fin_att (+), jou.dt_temps_jour)
     and jou.dt_temps_jour between pdt_date_debut and nvl(pdt_date_fin, pdt_date_debut)
     and jou.no_seq_activite is null;
   --  
   if vnu_nb_heure_jour > 0  then
      return true;
   end if;
    if vnu_nb_heure_usagr > 0  then
      return false;
   end if;
  return null;
END FDT_FNB_APX_VERIF_ARTT_USAGER;
/
show errors
