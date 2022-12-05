CREATE OR REPLACE TRIGGER FDT_TRB_FEUILLE_TEMPS_AUR 
 AFTER UPDATE
 ON FDTT_FEUILLE_TEMPS
 REFERENCING OLD AS OLD NEW AS NEW
 FOR EACH ROW
declare
  --
  -- Crée     : 29 janvier 2016
  -- Par      : Christian Grenier
  --
  -- Permet de créer la feuille de temps pour le prochain mois lors d'une transmission
  --
begin
   if upper(:new.ind_saisie_autorisee) = 'N' and upper(:old.ind_saisie_autorisee) = 'O' THEN
      utl_pkb_pile.p_empile(nvl(:new.rowid,:old.rowid));
   end if;
end FDT_TRB_FEUILLE_TEMPS_AUR;
/
show errors
