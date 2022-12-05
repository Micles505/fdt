create or replace package fdt_pkb_apx_pilotage is
   --
   -- Author  : SHQSBB
   -- Created : 2021-03-12
   -- Purpose : Fonctions utilisées par la facette pilotage
   --
   -- Modifié par : Yves Marcotte
   -- Le          : 2021-12-13
   --
   -- Type créé pour retourner infos fdtt_typ_intervention + description direction
   type rec_typ_intervention is record(no_seq_typ_intervention    fdtt_typ_intervention.no_seq_typ_intervention%type,
                                       no_seq_direction           fdtt_typ_intervention.no_seq_direction%type,
                                       co_typ_intervention        fdtt_typ_intervention.co_typ_intervention%type,
                                       description                varchar2(200), --Description type intervention
                                       co_sta_typ_intervention    fdtt_typ_intervention.co_sta_typ_intervention%type,
                                       co_user_cre_enreg          fdtt_typ_intervention.co_user_cre_enreg%type,
                                       co_user_maj_enreg          fdtt_typ_intervention.co_user_maj_enreg%type,
                                       dh_cre_enreg               fdtt_typ_intervention.dh_cre_enreg%type,
                                       dh_maj_enreg               fdtt_typ_intervention.dh_maj_enreg%type);
   --
   -- Type créé pour retourner infos fdtt_typ_service + description direction
   type rec_typ_service is record(no_seq_typ_service    fdtt_typ_intervention.no_seq_typ_intervention%type,
                                  no_seq_direction           fdtt_typ_intervention.no_seq_direction%type,
                                  co_typ_service        fdtt_typ_intervention.co_typ_intervention%type,
                                  description                varchar2(200), --Description type service
                                  co_sta_typ_service    fdtt_typ_intervention.co_sta_typ_intervention%type,
                                  co_user_cre_enreg          fdtt_typ_intervention.co_user_cre_enreg%type,
                                  co_user_maj_enreg          fdtt_typ_intervention.co_user_maj_enreg%type,
                                  dh_cre_enreg               fdtt_typ_intervention.dh_cre_enreg%type,
                                  dh_maj_enreg               fdtt_typ_intervention.dh_maj_enreg%type);
   --
   -- @return Code statut direction
   function f_obt_code_sta_direction (pnu_no_seq_direction in number) return varchar2;
   --
   -- @return Données table fdtt_typ_intervention
   function f_obt_data_typ_intervention (pnu_no_seq in number) return rec_typ_intervention;
   --
   -- @return Données table fdtt_typ_intervention
   function f_obt_data_typ_service (pnu_no_seq in number) return rec_typ_service;
   --
   -- @return Données table fdtt_attrb_typ_intervention
--   function f_obt_data_attrb_typ_interv (pnu_no_seq in number) return fdtt_attrb_typ_intervention%rowtype;
   --
   -- @return Données table fdtt_qualification_attribut
   function f_obt_data_qualification (pnu_no_seq in number) return fdtt_qualification%rowtype;

end fdt_pkb_apx_pilotage;
/

