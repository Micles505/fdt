CREATE OR REPLACE PROCEDURE FDT_PRB_APX_OBT_FCT_INTERV(pnu_co_employe_shq_inter in number,
                                                       pnu_co_employe_shq_fdt   in number,
                                                       pnu_NO_SEQ_FONCT_INTERVENANT out fdtt_fonct_intervenants.no_seq_fonct_intrv%type,
                                                       pva_co_typ_fonction out fdtt_fonct_intervenants.co_typ_fonction%type)
is
   --
   -- Curseur
   cursor cur_obtenir_fonction_inter is
      select fct.co_typ_fonction, fct.no_seq_fonct_intrv
      from fdtt_fonct_intervenants fct,
           fdtt_assoc_employes_grp grp
      where fct.co_employe_shq = pnu_co_employe_shq_inter
        and utl_fnb_obt_dt_prodc('FDT', 'DA') between fct.dt_debut_fonction and nvl(fct.dt_fin_fonction,utl_fnb_obt_dt_prodc('FDT', 'DA'))
        and grp.no_seq_groupe       = fct.no_seq_groupe
        and grp.co_employe_shq  = pnu_co_employe_shq_fdt
        and utl_fnb_obt_dt_prodc('FDT', 'DS') between grp.dt_debut_association and nvl(grp.dt_fin_association,utl_fnb_obt_dt_prodc('FDT', 'DS'));
   --
   rec_obtenir_fonction_inter cur_obtenir_fonction_inter%rowtype;
begin
--
   open  cur_obtenir_fonction_inter;
      fetch cur_obtenir_fonction_inter into rec_obtenir_fonction_inter;
   close cur_obtenir_fonction_inter;
   --
   pva_co_typ_fonction          := rec_obtenir_fonction_inter.co_typ_fonction;
   pnu_NO_SEQ_FONCT_INTERVENANT := rec_obtenir_fonction_inter.no_seq_fonct_intrv;
--
end FDT_PRB_APX_OBT_FCT_INTERV;
/

