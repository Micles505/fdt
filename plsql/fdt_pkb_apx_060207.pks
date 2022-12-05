create or replace package fdt_pkb_apx_060207 is
   --
   -- @Author  SHQYMR 2021-12-16
   -- @usage   Page 060207 (Associations types services / qualifications)
   --
   --
   -- Modifié par : 
   -- Le          : 
   --
   -- Type et variables pour la collection des associations types services / qualifications
   type rec_ass_typ_serv_qualf is record(no_seq_ass_typ_serv_qualf fdtt_ass_typ_serv_qualf.no_seq_ass_typ_serv_qualf%type,
                                         no_seq_typ_service         fdtt_ass_typ_serv_qualf.no_seq_typ_service%type,
                                         typ_service_desc           fdtt_typ_service.description%type,
                                         no_seq_qualification       fdtt_ass_typ_serv_qualf.no_seq_qualification%type,
                                         qualification_desc         fdtt_qualification.description%type,
                                         dt_debut                   fdtt_ass_typ_serv_qualf.dt_debut%type,
                                         dt_fin                     fdtt_ass_typ_serv_qualf.dt_fin%type,
                                         apex_row_status            varchar2(3));
   type tab_rec_ass_typ_serv_qualf is table of rec_ass_typ_serv_qualf index by pls_integer;
   --
   vta_rec_ass_typ_serv_qualf tab_rec_ass_typ_serv_qualf;
   --
   -- @usage Supprimer la collection
   procedure p_supprimer_collection;
   --
   -- @usage Insère un enregistrement dans la collection
   -- @param pre_enreg              Enregristrement de type fdtt_ass_typ_serv_qualf
   -- @param pva_apex$row_status    Statut de l'enregistrement dans APEX
   procedure p_ajouter_enreg_collection(pre_enreg            in fdtt_ass_typ_serv_qualf%rowtype,
                                        pva_apex$row_status  in varchar2);
   --
   -- @usage : Fait deux types de validations sur les associations :
   --          Un seul enregistrement doit être actif (date de fin à "null") pour une association d'attribut.
   --          Il ne peut pas y avoir de chevauchement de dates pour une association d'attribut.
   --          La procedure ajoute des apex_error.add_error s'il y a des erreurs.
   procedure p_valider_coherence (pnu_no_seq_typ_service       in number,
                                  pnu_no_seq_qualification     in number);
   --
end fdt_pkb_apx_060207;
/
