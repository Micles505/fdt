CREATE OR REPLACE FUNCTION fdt_fnb_ressource_sans_code_equivalence
return BOOLEAN as
--
-- Déclaration de variables
--
-- Curseur
-- Va chercher les ressources qui ne sont pas dans BUS, qui ont saisi au moins une intervention et
-- qui ne sont pas dans la table d'équivalence (ils soivent l'être absolument pour faire la concordance
-- avec le central.
   cursor cur_obt_ressource_sans_code_equivalence is
      select count(*) as nombre_ressource_sans_equivalence
      from fdtt_ressource res
      where res.co_employe_shq is null
        and res.no_seq_ressource in (select no_seq_ressource
                                     from fdtt_temps_intervention tinter
                                     where tinter.no_seq_ressource = res.no_seq_ressource)
        and res.no_seq_ressource not in (select equi.no_seq_ressource_equiv
                                         from fdtw_code_equivalence equi
                                         where equi.no_seq_ressource_equiv = res.no_seq_ressource);
   --
   rec_obt_ressource_sans_code_equivalence   cur_obt_ressource_sans_code_equivalence%rowtype;
begin
   --
   open  cur_obt_ressource_sans_code_equivalence;
      fetch cur_obt_ressource_sans_code_equivalence into rec_obt_ressource_sans_code_equivalence;
   close cur_obt_ressource_sans_code_equivalence;
   --
   if rec_obt_ressource_sans_code_equivalence.nombre_ressource_sans_equivalence > 0 then
      return true;
   else
      return false;
   end if;
--
end fdt_fnb_ressource_sans_code_equivalence;
/

