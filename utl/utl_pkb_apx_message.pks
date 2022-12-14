create or replace package utl.utl_pkb_apx_message as
   /**
   --====================================================================================================
   -- Date : 2019-05-29
   -- Par : St�phane Baribeau
   -- Description : Cr�ation initiale du package
   --====================================================================================================
   -- Date :
   -- Par :
   -- Description :
   --====================================================================================================
   */
   /** Lire un message en utilisant utl_pkb_message.lire_message.
       Si le message n'est pas trouv�, retourner un message construit de la mani�re : 'Le code de message XXX.999999 est absent.'
   * @param pva_code_messa    Code du message au format 'XXX.999999'
   * @param pva_param_1       Texte rempla�ant la valeur %1 dans le message
   * @param pva_param_2       Texte rempla�ant la valeur %2 dans le message
   * @param pva_param_3       Texte rempla�ant la valeur %3 dans le message
   * @param pva_param_4       Texte rempla�ant la valeur %4 dans le message
   * @param pva_param_5       Texte rempla�ant la valeur %5 dans le message
   * @param pva_type_messa    Type du message
   */
   function f_obt_message(pva_code_messa in varchar2,
                          pva_param_1    in varchar2 default null,
                          pva_param_2    in varchar2 default null,
                          pva_param_3    in varchar2 default null,
                          pva_param_4    in varchar2 default null,
                          pva_param_5    in varchar2 default null,
                          pva_type_messa out varchar2) return varchar2;
   --
   /** Lire un message en utilisant utl_pkb_message.lire_message.
       Si le message n'est pas trouv�, retourner un message construit de la mani�re
   * @param pva_code_systeme  Code du syst�me
   * @param pva_code_messa    Code du message au format '999999'
   * @param pva_param_1       Texte rempla�ant la valeur %1 dans le message
   * @param pva_param_2       Texte rempla�ant la valeur %2 dans le message
   * @param pva_param_3       Texte rempla�ant la valeur %3 dans le message
   * @param pva_param_4       Texte rempla�ant la valeur %4 dans le message
   * @param pva_param_5       Texte rempla�ant la valeur %5 dans le message
   * @param pva_type_messa    Type du message
   */
  --
   function f_obt_message(pva_code_systeme in varchar2,
                          pva_code_messa   in varchar2,
                          pva_param_1      in varchar2 default null,
                          pva_param_2      in varchar2 default null,
                          pva_param_3      in varchar2 default null,
                          pva_param_4      in varchar2 default null,
                          pva_param_5      in varchar2 default null,
                          pva_type_messa   out varchar2) return varchar2;
 --
 /** Lire un message en utilisant utl_pkb_message.lire_message.
       Si le message n'est pas trouv�, retourner un message construit de la mani�re
   * @param pva_code_systeme  Code du syst�me
   * @param pva_code_messa    Code du message au format '999999'
   * @param pva_co_lang       Code de langue
   * @param pva_param_1       Texte rempla�ant la valeur %1 dans le message
   * @param pva_param_2       Texte rempla�ant la valeur %2 dans le message
   * @param pva_param_3       Texte rempla�ant la valeur %3 dans le message
   * @param pva_param_4       Texte rempla�ant la valeur %4 dans le message
   * @param pva_param_5       Texte rempla�ant la valeur %5 dans le message
   * @param pva_type_messa    Type du message
   */
   --
   function f_obt_message(pva_code_systeme in varchar2,
                          pva_code_messa   in varchar2,
						  pva_co_lang      in apex_application_translations.language_code%type,
                          pva_param_1      in varchar2 default null,
                          pva_param_2      in varchar2 default null,
                          pva_param_3      in varchar2 default null,
                          pva_param_4      in varchar2 default null,
                          pva_param_5      in varchar2 default null,
                          pva_type_messa   out varchar2) return varchar2;
end utl_pkb_apx_message;
/

