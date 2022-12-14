create or replace package utl.utl_pkb_apx_gen_mess_portail is
   --
   -- ======================================================================
   -- Auteur      : Yves Marcotte
   -- Créé le     : 2019-10-01
   -- Description : Générer les messages du portail SHQ
   -- ======================================================================
   --
   -- ----------------------------------------------------------------------
   -- Structure des enregistrements retournés
   -- ----------------------------------------------------------------------
   type rec_mess_sys_portail is record (level_menu            apex_application_list_entries.display_sequence%type,
                                        label_menu            apex_application_list_entries.entry_text%type,
                                        target_menu           apex_application_list_entries.entry_target%type,
                                        is_current_list_entry apex_application_list_entries.current_for_pages_type%type,
                                        image                 apex_application_list_entries.entry_image%type,
                                        image_attribute       apex_application_list_entries.entry_image_attributes%type,
                                        image_alt_attribute   apex_application_list_entries.entry_image_alt_attribute%type,
                                        attribute1            apex_application_list_entries.entry_attribute_01%type,
                                        attribute2            apex_application_list_entries.entry_attribute_02%type,
                                        attribute3            apex_application_list_entries.entry_attribute_03%type,
                                        attribute4            apex_application_list_entries.entry_attribute_04%type,
                                        attribute5            apex_application_list_entries.entry_attribute_05%type,
                                        attribute6            apex_application_list_entries.entry_attribute_06%type,
                                        attribute7            apex_application_list_entries.entry_attribute_07%type,
                                        attribute8            apex_application_list_entries.entry_attribute_08%type,
                                        attribute9            apex_application_list_entries.entry_attribute_09%type,
                                        attribute10           apex_application_list_entries.entry_attribute_10%type);
   --
   type tab_mess_sys_portail is table of rec_mess_sys_portail;
   --
   -- ======================================================================
   -- Cette procédure remplie la table d'association des systèmes concernés
   -- en lien avec un message du portail "UTLT_MESSAGE_PORTAIL"
   -- ======================================================================
   procedure p_remplir_tab_assoc_mess_sys (pnu_no_seq_messa_portail in utlt_message_portail.no_seq_messa_portail%type,
                                           pva_liste_systemes       in varchar2);
   --
   -- ======================================================================
   -- Cette fonction permet d'obtenir les systèmes concernés par un
   -- message
   --
   -- À partir du no_seq_messa_portail, retourner les codes de systèmes
   -- séparés par le caractère ':'
   -- ======================================================================
   function f_obtenir_liste_sys_mess (pnu_no_seq_messa_portail in utlt_message_portail.no_seq_messa_portail%type)
                                      return varchar2;
   --
   -- =================================================================================================
   -- Gestion des messages en provenance du ServiceMix
   --
   -- Paramètres :
   --    --> pnu_id_mess_serv_mix     ---> Identifiant du message en provenance du ServiceMix
   --    --> pva_liste_systemes       ---> Liste des systèmes concernés par le message (Séparé par ':')
   --    --> pva_typ_message          ---> 'INFOR' (Information)
   --                                      'AVERT' (Avertissement)
   --                                      'URGEN' (Urgence)
   --    --> pva_dh_debut_affichage   ---> Date de début de l'affichage du message au portail
   --                                      Format 'YYYY-MM-DD HH24:MI:SS'
   --    --> pva_dh_debut_effectivite ---> Date de début d'effectivité
   --                                      Format 'YYYY-MM-DD HH24:MI:SS'
   --    --> pva_dh_fin_effectivite   ---> Date de fin d'effectivité
   --                                      Format 'YYYY-MM-DD HH24:MI:SS'
   --    --> pva_etat_message         ---> 0 (Insertion)
   --                                      1 (Modification)
   --                                      9 (Le message ne doit plus être effectif)
   --    --> pva_message              ---> Message à afficher
   -- =================================================================================================
   procedure p_gestion_mess_prov_servicemix (pnu_id_mess_serv_mix     in number,
	                                         pva_liste_systemes       in varchar2,
                                             pva_typ_message          in varchar2,
                                             pva_dh_debut_affichage   in varchar2,
                                             pva_dh_debut_effectivite in varchar2,
                                             pva_dh_fin_effectivite   in varchar2,
	                                         pva_etat_message         in number,
	                                         pva_message              in clob);
   --
   -- ======================================================================
   -- Cette procédure supprime un message 'UTLT_MESSAGE_PORTAIL' et ses
   -- associations à certains systèmes 'UTLT_ASSOC_MES_PORT_SYS'
   -- ======================================================================
   procedure p_supp_mess_et_assoc_sys (pnu_no_seq_messa_portail in utlt_message_portail.no_seq_messa_portail%type);
   --
   -- ======================================================================
   -- Cette fonction permet de dire s'il y a au moins un message à afficher
   -- selon le type de message et les droits de l'utilisateur en cours
   --
   -- Retourne True  ==> Il y a au moins un message affiché
   --          False ==> Pas de message à afficher
   -- ======================================================================
   Function f_presence_mess_portail (pva_co_typ_message   in varchar2,
                                     pva_co_utilisateur   in varchar2,
								     pva_autorisation_dev in varchar2)
								     return boolean;
   --
   -- ======================================================================
   -- Cette fonction retourne les messages au portail SHQ qui concerne
   -- l'utilisateur passé en paramètre
   -- ======================================================================
   function f_obt_messages_portail (pva_co_typ_message   in varchar2,
                                    pva_co_utilisateur   in varchar2,
									pva_autorisation_dev in varchar2)
									return tab_mess_sys_portail pipelined;
end utl_pkb_apx_gen_mess_portail;
/

