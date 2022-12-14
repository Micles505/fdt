create or replace package utl.utl_pkb_apx_standard as
  --
  function f_obt_standard_apex(pva_co_std_apex in varchar2)

    /*
    * Fonction qui retourne la valeur du code standard APEX
    *
    * In       pva_code_std_apex     Code du standard APEX
    * Out      varchar2              Valeur du standard APEX
    */
   return varchar2  ;
  --
    function f_obt_standard_apex(pva_co_std_apex in varchar2, pva_co_lang in varchar2 )

    /*
    * Fonction qui retourne la valeur du code standard APEX
    *
    * In       pva_code_std_apex     Code du standard APEX
    *          pva_co_langue         Code
    * Out      varchar2              Valeur du standard APEX
    */
   return varchar2  ;
  --
end utl_pkb_apx_standard;
/

