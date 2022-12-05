CREATE OR REPLACE FUNCTION fdt_fnb_intervention_sans_equivalence_scp_complet
return BOOLEAN as
--
-- Déclaration de variables
--
-- Curseur
-- Va chercher les interventions du mois passée en paramètre pour s'assurer que chacune des interventions ,saisies
-- par les différentes ressources, sont dans la table de concordance de SCP2 (scp2.scpte_res_trav).
   cursor cur_obt_inter_sans_equivalence_scp is
   select count(*) as nombre_inter_sans_equivalence
   from fdtt_temps_intervention ti
   where ti.no_seq_aact_intrv_det not in (select trav.no_seq_aact_intrv_det
                                          from scp2.scpte_res_trav trav
                                          where no_seq_aact_intrv_det is not null );
   --
   rec_obt_inter_sans_equivalence_scp   cur_obt_inter_sans_equivalence_scp%rowtype;
begin
   --
   open  cur_obt_inter_sans_equivalence_scp;
      fetch cur_obt_inter_sans_equivalence_scp into rec_obt_inter_sans_equivalence_scp;
   close cur_obt_inter_sans_equivalence_scp;
   --
   if rec_obt_inter_sans_equivalence_scp.nombre_inter_sans_equivalence > 0 then
      return true;
   else
      return false;
   end if;
--
end fdt_fnb_intervention_sans_equivalence_scp_complet;
/

