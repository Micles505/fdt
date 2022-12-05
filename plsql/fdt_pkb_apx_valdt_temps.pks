PROMPT Creating Package 'FDT_PKB_APX_VALDT_TEMPS'
create or replace package fdt_pkb_apx_valdt_temps as
  type tp_avertissement is table of varchar(32767) ;
  vtp_avertissement tp_avertissement :=new tp_avertissement();
  
  type tp_champs_evidence is record(date_ligne  date,
                                    nom_champs  varchar2(10),
                                    couleur     varchar2(10));
  type tp_evidence is table of tp_champs_evidence;
  vtp_evidence tp_evidence :=new tp_evidence();
  
  procedure p_valdt_infrm_temps(pnu_no_seq_ressource      in fdtt_feuilles_temps.no_seq_ressource%type,
                                pva_an_mois_fdt           in fdtt_feuilles_temps.an_mois_fdt%type,
                                pva_mode_affichage_erreur in varchar2 default 'AVERTISSEMENT',
                                pva_message_info          in varchar2 default 'AVERTISSEMENT');
  --function f_obten_evdnc(pda_date_ligne in date,
  --                       pvc_nom_champs in varchar2)return varchar2;
    ------------------------------------------------------------------------------------------------------------
  -- Permet d'envoyer en pipeline la liste des messages d'erreurs.
  ------------------------------------------------------------------------------------------------------------ 
  function f_obtenir_message_fdt(pnu_no_seq_ressource      in fdtt_feuilles_temps.no_seq_ressource%type,
                                 pva_an_mois_fdt           in fdtt_feuilles_temps.an_mois_fdt%type,
                                 pva_mode_affichage_erreur in varchar2 default 'AVERTISSEMENT',
                                 pva_message_info          in varchar2 default 'AVERTISSEMENT')
    return tp_avertissement
    pipelined;
  --
end fdt_pkb_apx_valdt_temps;
/
