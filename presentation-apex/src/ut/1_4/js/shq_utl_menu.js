/* global apex */

var shq = shq || {};
shq.utl_menu = {};
//
// fonction pour le menu shq
//
(function (utl_menu, shq, $) {
   "use strict";
   //
   // Gestion de l'autoration DEV pour APEX
   // 
   utl_menu.appliquerCssAutorisationDev = function (autoration) {
      var codeOui = 'O';
      var codeNon = 'N';
      var classAutoBg = 'u-warning',
         classeAutoTexte = 'u-normal-text';
      var selAutorisationDev = $('.t-NavigationBar a.t-Button.t-Button--icon.t-Button--header.t-Button--navBar .fa-user-secret').parent();
      
      if (selAutorisationDev.length) {
         switch (autoration) {
            case codeOui:
               $(selAutorisationDev).removeClass(classAutoBg)
                  .removeClass(classeAutoTexte);
               break;
            case codeNon:
               $(selAutorisationDev).addClass(classAutoBg)
                  .addClass(classeAutoTexte);
               break;
            default:
               $(selAutorisationDev).removeClass(classAutoBg)
                  .removeClass(classeAutoTexte);
               break;
         }
      }
   };
   utl_menu.initialiserAutorisationDev = function () {
      var processAutorisationDev = 'APX - Recuperer Autorisation DEV';
      var messageErreurAjax = '"ERREUR_MESSAGE_AJAX"';

      apex.server.process(processAutorisationDev)
         .done(function (data) {
            apex.debug.info(data);
            utl_menu.appliquerCssAutorisationDev(data.autorisation_dev.valeur);
         })
         .fail(function () {
            messageErreurAjax = messageErreurAjax.replace('%1', 'processAutorisationDev');
            apex.message.showErrors(messageErreurAjax);
            apex.debug.error(messageErreurAjax);
         });
   };
   utl_menu.appliquerAutorisationDev = function () {
      var processAutorisationDev = 'APX - MAJ Autorisation DEV';
      var messageErreurAjax = '"ERREUR_MESSAGE_AJAX"';

      apex.server.process(processAutorisationDev)
         .done(function (data) {
            apex.debug.info(data);
            utl_menu.appliquerCssAutorisationDev(data.autorisation_dev.valeur);
            apex.message.showPageSuccess(data.autorisation_dev.message);
         })
         .fail(function () {
            messageErreurAjax = messageErreurAjax.replace('%1', 'processAutorisationDev');
            apex.message.showErrors(messageErreurAjax);
            apex.debug.error(messageErreurAjax);
         });
   };
   //
   // Contrôle le libellé du champs NOM_FONCT_PLSQL_LIBEL
   // 
   utl_menu.controlerLibelleFonctExpression = function (codeTypeLibelle) {
      var libellePlsql = 'Nom de la fonction PL/SQL';
      var libelleExpressionSql = 'Expression SQL';
      var codePLSQL = 'PLSQL';
      var codeExpre = 'EXPRE';
      var libelle;
      var nomItemApex = 'P9_NOM_FONCT_PLSQL_LIBEL';

      switch (codeTypeLibelle) {
         case codePLSQL:
            libelle = libellePlsql;
            break;
         case codeExpre:
            libelle = libelleExpressionSql;
            break;
         default:
            libelle = libellePlsql;
      }
      shq.item.changerLibelle(nomItemApex, libelle);
   };
   //
   // Contrôle le libellé du champs NO_SEQ_PORTAIL_APPLI
   // 
   utl_menu.controlerLibellePortailAppli = function (TypeAppli) {
      var libelleApex = 'Application APEX';
      var libelleForms = 'Application FORMS';
      var codeApex = 'APEX';
      var codeForms = 'FORMS';
      var libelle;
      var nomItemApex = 'P9_NO_SEQ_PORTAIL_APPLI';

      switch (TypeAppli) {
         case codeApex:
            libelle = libelleApex;
            break;
         case codeForms:
            libelle = libelleForms;
            break;
         default:
            libelle = libelleApex;
      }
      shq.item.changerLibelle(nomItemApex, libelle);
   };
   shq.utl_menu.ouvrirLiensUrlFichier = function (fileUrl) {
      var messageFichierUrl = apex.lang.formatMessageNoEscape("SHQ.MENU.OUVERTURE_FICHIER_URL", fileUrl);
      if (shq.isNavigateurIexplorer11()) {
         var tampon = apex.navigation.openInNewWindow(fileUrl, '', { favorTabbedBrowsing: true });
      } else {
         apex.message.alert(messageFichierUrl);
      }
   };
   shq.utl_menu.ouvrirLiensForms = function (formUrl, nomApplication) {
      var messageFormsUrl = apex.lang.formatMessageNoEscape("SHQ.MENU.OUVERTURE_FORMS", nomApplication);
      /* 
       * Permet d'ouvrir plusieurs fenêtres pour une même application form
       * Si même nom de nom d'application il récupère la fenêtre.
      */
      var dateOnglet = new Date();
      var nombreMiliSecondeEcoule = dateOnglet.getTime();
      nomApplication = typeof nomApplication === "undefined" ? "" : nomApplication;
      nomApplication = $nvl(nomApplication, true) ? nomApplication.concat('_').concat(nombreMiliSecondeEcoule) : nombreMiliSecondeEcoule;

      if (shq.isNavigateurIexplorer11() ||
          shq.isNavigateurEdge() ) {
         var width_win = Math.ceil(screen.width * 0.85);
         var height_win = Math.ceil(screen.height * 0.75);
         var tampon = apex.navigation.popup({ url: formUrl, name: nomApplication, width: width_win, height: height_win, menubar: "yes", statusbar: "yes" });
      } else {
         apex.message.alert(messageFormsUrl);
      }
   };
   shq.utl_menu.ouvrirLiensIexplorer = function (Url, nomApplication) {
      var messageFormsUrl = apex.lang.formatMessage("SHQ.MENU.OUVERTURE_URL_IEXPLORER");
      /* 
       * Permet d'ouvrir plusieurs fenêtres pour une même application form
       * Si même nom de nom d'application il récupère la fenêtre.
      */
      var dateOnglet = new Date();
      var nombreMiliSecondeEcoule = dateOnglet.getTime();
      nomApplication = typeof nomApplication === "undefined" ? "" : nomApplication;
      nomApplication = $nvl(nomApplication, true) ? nomApplication.concat('_').concat(nombreMiliSecondeEcoule) : nombreMiliSecondeEcoule;

      if (shq.isNavigateurIexplorer11() ||      
          shq.isNavigateurEdge()) {
         var width_win = Math.ceil(screen.width * 0.85);
         var height_win = Math.ceil(screen.height * 0.75);
         var tampon = apex.navigation.popup({ url: Url, name: nomApplication, width: width_win, height: height_win, menubar: "yes", statusbar: "yes" });
      } else {
         apex.message.alert(messageFormsUrl);
      }
   };
})(shq.utl_menu, shq, apex.jQuery);