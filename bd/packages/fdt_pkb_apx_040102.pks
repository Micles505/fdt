create or replace package fdt_pkb_apx_040102 is
   -- ====================================================================================================
   -- Date        : 2021-11-25
   -- Par         : SHQYMR
   -- Description : Gérer le calendrier des absences
   -- ====================================================================================================
   -- Date        :
   -- Par         :
   -- Description :
   -- ====================================================================================================
   --
   --
   -- =========================================================================
   -- Valider la ressource
   -- =========================================================================
   Function f_valider_ressource (pre_calendrier_absence in fdtt_calendrier_absence%rowtype) return varchar2;
   --
   --
   -- =========================================================================
   -- Valider les dates
   -- =========================================================================
   Function f_valider_date_contexte (pre_calendrier_absence in fdtt_calendrier_absence%rowtype) return varchar2;
   --
   --
   -- =========================================================================
   -- Calculer la duréé entre la date de début d'absence et la date de retour
   -- d'absence
   -- =========================================================================
   Function f_calculer_duree (pre_calendrier_absence in fdtt_calendrier_absence%rowtype) return varchar2;
   --
end fdt_pkb_apx_040102;
/

