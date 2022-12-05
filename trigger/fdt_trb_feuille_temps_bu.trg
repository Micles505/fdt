CREATE OR REPLACE TRIGGER FDT_TRB_FEUILLE_TEMPS_BU 
 BEFORE UPDATE
 ON FDTT_FEUILLE_TEMPS
DECLARE

  --
  -- Crée     : 8 février 2016
  -- Par      : Christian Grenier
  --
  -- Permet de commence la pile
  --PL/SQL Block
BEGIN
   utl_pkb_pile.p_debut_enonc('FDTT_FEUILLE_TEMPS');
END FDT_TRB_FEUILLE_TEMPS_BU;
/
show errors
