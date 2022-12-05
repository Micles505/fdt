PROMPT Creating Package 'FDT_PKB_VALDT_TEMPS'
create or replace package fdt_pkb_valdt_temps as
  type tp_avertissement is table of varchar(32767) ;
  vtp_avertissement tp_avertissement :=new tp_avertissement();
  
  type tp_champs_evidence is record(date_ligne  date,
                                    nom_champs  varchar2(10),
                                    couleur     varchar2(10));
  type tp_evidence is table of tp_champs_evidence;
  vtp_evidence tp_evidence :=new tp_evidence();
  
  procedure p_valdt_infrm_temps(p_vcco_employe_shq in fdtt_feuille_temps.co_employe_shq%type,
                                p_vcan_mois_fdt    in fdtt_feuille_temps.an_mois_fdt%type,
                                p_vcmode in varchar2 default 'AVERTISSEMENT');
  function f_obten_evdnc(pda_date_ligne in date,
                         pvc_nom_champs in varchar2)return varchar2;
end fdt_pkb_valdt_temps;
/
