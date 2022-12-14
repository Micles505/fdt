create or replace package utl.utl_pkb_apx_constantes is
   function f_obtenir_rep_fichier_shq return varchar2 deterministic;
   --
   function f_obtenir_env_apex_nitro return varchar2 deterministic;
   --
   function f_obtenir_co_oui return varchar2 deterministic;
   --
   function f_obtenir_co_non return varchar2 deterministic;
   --
   function f_obtenir_co_systeme_utl return varchar2 deterministic;
   --
   function f_obtenir_co_systeme_pil return varchar2 deterministic;
   --
   -- retour A pour Actif
   --
   function f_obtenir_co_actif_a return varchar deterministic;
   --
   -- retour I pour Inactif
   --
   function f_obtenir_co_inactif_i return varchar deterministic;

end utl_pkb_apx_constantes;
/

