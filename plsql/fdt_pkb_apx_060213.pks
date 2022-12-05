create or replace package fdt_pkb_apx_060213 is
   --
   -- @Author  SHQYMR 2021-12-23
   -- @usage   Page 060213 (Associations type service / qualification)
   --
   --
   -- Modifié par : 
   -- Le          : 
   --
   -- ------------------------------------------------------------------------------------------
   -- Type et variables pour la collection des associations types interventions / qualifications
   -- ------------------------------------------------------------------------------------------
   type rec_ass_typ_serv_qualf is record(no_seq_ass_typ_serv_qualf fdtt_ass_typ_serv_qualf.no_seq_ass_typ_serv_qualf%type,
                                         no_seq_typ_service        fdtt_ass_typ_serv_qualf.no_seq_typ_service%type,
                                         typ_service_desc          fdtt_typ_intervention.description%type,
                                         no_seq_qualification      fdtt_ass_typ_serv_qualf.no_seq_qualification%type,
                                         qualification_desc        fdtt_qualification.description%type,
                                         dt_debut                  fdtt_ass_typ_serv_qualf.dt_debut%type,
                                         dt_fin                    fdtt_ass_typ_serv_qualf.dt_fin%type,
                                         apex_row_status           varchar2(3));
   type tab_rec_ass_typ_serv_qualf is table of rec_ass_typ_serv_qualf index by pls_integer;
   --
   vta_rec_ass_typ_serv_qualf tab_rec_ass_typ_serv_qualf;
   --
   -- ---------------------------------------------------------
   -- Supprimer la collection
   -- ---------------------------------------------------------
   procedure p_supprimer_collection;
   --
   -- ---------------------------------------------------------
   -- Remplir la collection
   -- ---------------------------------------------------------
   procedure p_ajouter_enreg_collection(pre_enreg            in fdtt_ass_typ_serv_qualf%rowtype,
                                        pva_apex$row_status  in varchar2);
   --
   -- ---------------------------------------------------------
   -- Valider la cohérence
   -- ---------------------------------------------------------
   procedure p_valider_coherence (pnu_no_seq_direction     in number,
                                  pnu_no_seq_typ_service   in number,
                                  pnu_no_seq_qualification in number);
   --
end fdt_pkb_apx_060213;
/
