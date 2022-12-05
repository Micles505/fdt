PROMPT Creating Function 'FDT_FNB_OBT_FCT_INTERV'
CREATE OR REPLACE FUNCTION FDT_FNB_OBT_FCT_INTERV(pnu_co_employe_shq_inter in number,
                                                  pnu_co_employe_shq_fdt   in number)
return varchar2 as
--
vva_co_typ_fonction  varchar2(50);
--
begin
   select max(fct.co_typ_fonction) 
     into vva_co_typ_fonction 
  from fdtt_fonct_intervenant fct,
       fdtt_assoc_employe_grp grp
  where fct.co_employe_shq    = pnu_co_employe_shq_inter
   and utl_fnb_obt_dt_prodc('FDT', 'DA') between fct.dt_debut_fonction and nvl(fct.dt_fin_fonction,utl_fnb_obt_dt_prodc('FDT', 'DA'))
   and grp.no_groupe      = fct.no_groupe      
   and grp.co_employe_shq = pnu_co_employe_shq_fdt
   and utl_fnb_obt_dt_prodc('FDT', 'DS') between grp.dt_debut_association and nvl(grp.dt_fin_association,utl_fnb_obt_dt_prodc('FDT', 'DS'));                               
--
   return vva_co_typ_fonction;
--
end fdt_fnb_obt_fct_interv;
/
show errors
