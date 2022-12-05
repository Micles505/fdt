PROMPT CREATING VIEW 'FDTV_LIST_INTRV_GRP_UNITE'
CREATE OR REPLACE VIEW FDTV_LIST_INTRV_GRP_UNITE
  AS
select grp.no_seq_groupe, grp.nom_groupe, nvl(max(uni_int.co_unite_organ), max(uni_emp.co_unite_organ)) co_unite_organ,max(uni_emp.co_employe_shq) co_employe_shq
  from fdtt_groupe grp,
       fdtt_fonct_intervenant int,
       fdtt_assoc_employe_grp emp,
       busv_info_employe uni_int, 
       busv_info_employe uni_emp 
 where emp.no_groupe (+) = grp.no_seq_groupe
   and int.no_groupe (+) = grp.no_seq_groupe
   and utl_fnb_obt_dt_prodc('FDT', 'DA') between int.dt_debut_fonction (+) and nvl(int.dt_fin_fonction (+), utl_fnb_obt_dt_prodc('FDT', 'DA'))
   and utl_fnb_obt_dt_prodc('FDT', 'DA') between emp.dt_debut_association (+) and nvl(emp.dt_fin_association (+), utl_fnb_obt_dt_prodc('FDT', 'DA'))
   and uni_emp.co_employe_shq (+) = emp.co_employe_shq
   and uni_int.co_employe_shq (+) = int.co_employe_shq
   group by grp.no_seq_groupe, grp.nom_groupe;  