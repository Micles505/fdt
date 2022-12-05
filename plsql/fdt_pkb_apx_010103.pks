create or replace package fdt_pkb_apx_010103 is
   -- ====================================================================================================
   -- Date        : 2021-09-24
   -- Par         : SHQYMR
   -- Description : Suivi des feuilles de temps
   -- ====================================================================================================
   -- Date        : 
   -- Par         : 
   -- Description : 
   -- ====================================================================================================
   --
   --
   -- =========================================================================
   -- Ajouter un suivi de feuille de temps
   -- =========================================================================
   procedure p_ajouter_suivi_fdt (pre_suivi_fdt in fdtt_suivi_feuilles_temps%rowtype, 
                                  pnu_co_employe_shq_inter in fdtt_ressource.co_employe_shq%type);
   --
   --
   -- =========================================================================
   -- Valider les interventions
   -- =========================================================================
   function f_valider_suivi_fdt (pre_suivi_fdt in fdtt_suivi_feuilles_temps%rowtype) return varchar2;
   -- =========================================================================
   -- Ajouter un suivi de type À corriger à une fdt
   -- =========================================================================
   procedure p_ajouter_suivi_a_corriger(pre_suivi_fdt in fdtt_suivi_feuilles_temps%rowtype, 
                                        pnu_co_employe_shq_inter in fdtt_ressource.co_employe_shq%type);
   -- =========================================================================
   -- Permet de savoir si un intervenant avec le même rôle à approuver la fdt en cours de suivi.
   -- Retourne vrai si c'est le cas et faux si la fdt n'a pas été approuvée par ce type d'intervenant.
   -- =========================================================================
   procedure p_verif_suivi_effectue_par_inter(pnu_no_seq_feuil_temps   in fdtt_suivi_feuilles_temps.no_seq_feuil_temps%type,
                                              pnu_co_employe_shq_inter in fdtt_ressource.co_employe_shq%type,
                                              pva_verif_suivi_effectue out varchar2,
                                              pva_co_typ_fonction      out varchar2); 
   -- =========================================================================
   -- Permet de savoir si on affiche le bouton en paramètre ou non
   -- 2 boutons possibles : APPROUVER et CORRIGER
   -- =========================================================================
   function f_determiner_si_affiche_bouton (pnu_no_seq_feuil_temps   in fdtt_suivi_feuilles_temps.no_seq_feuil_temps%type,
                                            pva_co_typ_fonction_inter in varchar2,
                                            pva_bouton in varchar2) return varchar2;
   -- =========================================================================
   -- Fontion qui renvoit une requête sql pour obtenir la liste des absences 
   -- SAGIR d'une ressources pour un mois.
   -- =========================================================================
   function f_retourner_requete_sagir_suivi  return varchar2;
end fdt_pkb_apx_010103;
/
