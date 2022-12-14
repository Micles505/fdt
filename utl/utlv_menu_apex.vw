create or replace force view utl.utlv_menu_apex as
select level as niveau_menu,
       map.co_menu_apx,
       map.nom_menu_apx,
       map.co_sta_menu_apx,
       ima.no_seq_item_apx,
       ima.no_seq_item_parent,
       ima.no_seq_application,
       bap.co_application,
			 bap.no_seq_parametre,
			 bap.co_status,
			 bap.date_effective,
       ima.co_item_apx,
       ima.co_sta_item_apx,
       ima.typ_application,
       poa.no_appli_apex  as no_appli_apex,
       poa.co_dispo_appli,
       poa.co_systeme,
       poa.co_traitement,
       ima.no_page_apex ,
       ima.nom_req_soum ,
       ima.ind_reinit_page,
       ima.ind_net_rapp_interact,
       ima.ind_reinit_rap_interact,
       ima.ind_duplicat_session,
       ima.enonce_reinit_rap_interac,
       ima.url_applicat,
       ima.co_typ_libel_item_apx,
       ima.val_typ_item_apx,
       ima.nom_fonct_plsql_libel,
       ima.ind_cond_affich,
       ima.nom_fonct_plsql_cond_affich,
       ico.nom_icone_apex as nom_icone_apex,
       ima.ord_pres_item_apx,
       ima.co_typ_affich
  from utlt_menu_apex map
 inner join utlt_item_menu_apex ima
    on ima.no_seq_menu_apx = map.no_seq_menu_apx
 left join utlt_portail_appli poa on ima.no_seq_portail_appli = poa.no_seq_portail_appli
 left join utlt_icone_apex ico on ima.no_seq_icone_apx = ico.no_seq_icone_apex
 left join bust_application bap on bap.no_seq_application = ima.no_seq_application  and bap.co_status = 'A'
 start with   ima.no_seq_item_parent is null
 connect by prior ima.no_seq_item_apx = ima.no_seq_item_parent
 order SIBLINGS  by co_menu_apx , ima.ord_pres_item_apx;

