PROMPT Creating Function 'FDT_FNB_APX_OBT_FCT_INTERV'
CREATE OR REPLACE FUNCTION FDT_FNB_APX_OBT_FCT_INTERV(pnu_co_employe_shq_inter in number,
                                                      pnu_co_employe_shq_fdt   in number)
return varchar2 as
   --
   vva_co_typ_fonction  varchar2(50);
   -- Curseur
   cursor cur_obtenir_fonction_inter is
      select fct.co_typ_fonction
      from fdtt_fonct_intervenants fct,
           fdtt_assoc_employes_grp grp
      where fct.co_employe_shq = pnu_co_employe_shq_inter
        and utl_fnb_obt_dt_prodc('FDT', 'DA') between fct.dt_debut_fonction and nvl(fct.dt_fin_fonction,utl_fnb_obt_dt_prodc('FDT', 'DA'))
        and grp.no_seq_groupe       = fct.no_seq_groupe      
        and grp.co_employe_shq  = pnu_co_employe_shq_fdt
        and utl_fnb_obt_dt_prodc('FDT', 'DS') between grp.dt_debut_association and nvl(grp.dt_fin_association,utl_fnb_obt_dt_prodc('FDT', 'DS')); 
   --
begin  
--
   open  cur_obtenir_fonction_inter;
	    fetch cur_obtenir_fonction_inter into vva_co_typ_fonction;
	 close cur_obtenir_fonction_inter;
   --
   return vva_co_typ_fonction;
--
end fdt_fnb_apx_obt_fct_interv;
/
