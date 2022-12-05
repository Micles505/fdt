PROMPT Creating Function 'FDT_FNB_OBT_NB_MINUTES_USAGER'
CREATE OR REPLACE FUNCTION FDT_FNB_OBT_NB_MINUTES_USAGER(pnu_co_employe_shq in number,
                                                         pdt_date_debut in date,
                                                         pdt_date_fin in date default null)
return number as
--
   vnu_sum_minutes  number;
--
begin
   vnu_sum_minutes := 0;
   --
   select sum(nvl(att.nb_hmin_jour, res.nb_hmin_jour_ressr)) nb_minute into vnu_sum_minutes
   from fdtt_detail_att    att,
        fdtt_ressource     res,
        fdtt_temps_jour    jou,
        fdtt_feuille_temps fdt
   where res.co_employe_shq     = pnu_co_employe_shq
     and res.NO_SEQ_RESSOURCE   = att.NO_SEQ_RESSOURCE (+)
     and fdt.no_seq_ressource   = res.NO_SEQ_RESSOURCE
     and jou.no_seq_feuil_temps = fdt.no_seq_feuil_temps 
     and jou.dt_temps_jour between nvl(att.dt_debut_att (+), jou.dt_temps_jour) and nvl(att.dt_fin_att (+), jou.dt_temps_jour)
     and jou.dt_temps_jour between pdt_date_debut and nvl(pdt_date_fin, pdt_date_debut);
   --
   return vnu_sum_minutes;
END fdt_fnb_obt_nb_minutes_usager;
/
show error




   