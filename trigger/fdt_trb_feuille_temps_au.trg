CREATE OR REPLACE TRIGGER FDT_TRB_FEUILLE_TEMPS_AU 
 AFTER UPDATE
 ON FDTT_FEUILLE_TEMPS
DECLARE

  --
  -- CrÃ©e     : 8 février 2016
  -- Par      : Christian Grenier
  --
  -- Permet de 'dépiler' et d'appeller la procédure de craétion de feuille de temps
  --PL/SQL Block
  vro_feuille_temps rowid;
  vnu_co_employe_shq   number(5);
  vva_an_mois_fdt      varchar2(6);
  vnu_solde_periode    number(5);
BEGIN
   vro_feuille_temps := utl_pkb_pile.fr_depile;
   ---
   while vro_feuille_temps is not null loop
      select co_employe_shq, an_mois_fdt, solde_periode
		        INTO vnu_co_employe_shq, vva_an_mois_fdt, vnu_solde_periode
      from fdtt_feuille_temps
      where rowid = vro_feuille_temps;
      --
      fdt_prb_creer_feuille_temps(vnu_co_employe_shq,
	                              vva_an_mois_fdt,
								  vnu_solde_periode);
      -- Procédure 								  
	  if vva_an_mois_fdt = '202205' then
	     fdt_prb_apx_creer_feuille_temps_inter_fdt(vnu_co_employe_shq,
	                                               vva_an_mois_fdt,
								                   vnu_solde_periode);
	  end if;										   
      --
      vro_feuille_temps := utl_pkb_pile.fr_depile;
   end loop;
   --
   utl_pkb_pile.p_fin_enonc;
END FDT_TRB_FEUILLE_TEMPS_AU;
/
show errors
