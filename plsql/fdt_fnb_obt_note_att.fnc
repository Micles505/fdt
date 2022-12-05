PROMPT Creating Function 'FDT_FNB_OBT_NOTE_ATT'
create or replace FUNCTION FDT_FNB_OBT_NOTE_ATT (pnu_co_employe_shq in number,
                                                 pnu_periode in varchar2)
return varchar2 as
--
vva_note  varchar2(400);
--
begin
 select listagg (date_note, '<br> ') within group (order by date_note) into  vva_note
  from (select to_char (att.dt_debut_att, 'yyyy-mm-dd : ') || att.note date_note
          from fdtt_detail_att att,
               fdtt_temps_jour jou
         where jou.co_employe_shq = att.co_employe_shq
           and jou.dt_temps_jour between att.dt_debut_att and nvl (att.dt_fin_att, jou.dt_temps_jour)
           and jou.dt_temps_jour between to_date (pnu_periode, 'yyyymm') and last_day (to_date (pnu_periode, 'yyyymm'))
           and att.co_employe_shq = pnu_co_employe_shq
         group by att.dt_debut_att, att.note);
return vva_note;
  exception when no_data_found then
    return null;
end fdt_fnb_obt_note_att;
/
show errors
