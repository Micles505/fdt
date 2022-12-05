
/*******************************************************************************
 *                Registre des modifications
 * Date           Nom                     Description
 * 2018-05-22     Michel Lessard          Création initiale
 ******************************************************************************/

/*******************************************************************************
 * Initialiser la variable de namespace shq
 ******************************************************************************/

/* global apex */

var shq = shq || {};


//
//
//

(function (shq, apex, util, $) {
   "use strict";


   //Permettre de définir le titre d'une page modal
   //Le code doit être exécuté par la page modal
   shq.definirTitreModal = function (pTitre) {
      util.getTopApex().$(".ui-dialog-content").dialog("option", "title", pTitre);
   };

   //Permet d'afficher les sous-éléments d'un menu sur le click de clui-ci
   function _initNavMenuAccordion() {
      //
      //Accordion-Like Navigation Menu: Menu avec lien égal à '#'
      //
      $('#t_Body_nav #t_TreeNav').on('click', 'ul li.a-TreeView-node div.a-TreeView-content:has(a[href="#"])', function () {
         $(this).prev('span.a-TreeView-toggle').click();
      });
      //
      //Accordion-Like Navigation Menu: Menu sans lien
      //
      $('#t_Body_nav #t_TreeNav').on('click', 'ul li.a-TreeView-node div.a-TreeView-content:not(:has(a))', function () {
         $(this).prev('span.a-TreeView-toggle').click();
      });
      // 
      // Permet de mettre un title sur les items de menu.
      // 
      if ($("#t_TreeNav").treeView !== undefined) {
         $("#t_TreeNav").treeView({
            tooltip: {
               show: { delay: 1000, effect: "blind", duration: 800 },
               content: function (callback, node) {
                  return node.label;
               }
            }
         });
      }
   }
   //
   function _fixMessageClose() {
      var APEX_SUCCESS_MESSAGE = "#APEX_SUCCESS_MESSAGE",
         C_BTN_FERMR_MESG = 't-Button--closeAlert',
         S_BTN_FERMR_MESG = '.' + C_BTN_FERMR_MESG;

      var msg$ = $(APEX_SUCCESS_MESSAGE);

      msg$.find(S_BTN_FERMR_MESG).click(function () {
         apex.message.hidePageSuccess();
      });
   }
   //
   function _autoDismissMessage() {
      var opt = {
         autoDismiss: true,
         duration: 4000
      };
      //
      // this only applys configuration when base page has a process success message ready to display
      //
      apex.theme42.configureSuccessMessages(opt);
      _fixMessageClose();

      apex.message.setThemeHooks({
         beforeShow: function (pMsgType) {
            if (pMsgType === apex.message.TYPE.SUCCESS) {
               apex.theme42.configureSuccessMessages(opt);
               _fixMessageClose();
            }
         }
      });
   }
   //
   // Détection du browser 
   //   
   // Chrome
   shq.isNavigateurChrome = function () {
      var userAgent = navigator.userAgent;
      var blBrowser = false;
      if (userAgent.search("Chrome") > 0) {
         blBrowser = true;
      }
      return blBrowser;
   };
   //
   // Iexplorer 11
   //
   shq.isNavigateurIexplorer11 = function () {
      var userAgent = navigator.userAgent;
      var blBrowser = false;
      if (userAgent.search("/MSIE|Trident/") > 0) {
         blBrowser = true;
      }
      return blBrowser;
   };
   //
   // firefox
   //   
   shq.isNavigateurFirefox = function () {
      var userAgent = navigator.userAgent;
      var blBrowser = false;
      if (userAgent.search("Firefox") > 0) {
         blBrowser = true;
      }
      return blBrowser;
   };
   //
   // Safari
   //
   shq.isNavigateurSafari = function () {

      var isSafari = /constructor/i.test(window.HTMLElement) ||
         (function (p) {
            return p.toString() === "[object SafariRemoteNotification]";
         })
            (!window.safari ||
               (typeof safari !== 'undefined' && safari.pushNotification));

      return isSafari;
   };
   //
   // Edge
   //
   shq.isNavigateurEdge = function () {
      var userAgent = navigator.userAgent;
      var blBrowser = false;
      if (userAgent.search("Edg/") > 0) {
         blBrowser = true;
      }
      return blBrowser;
   };
   //
   //Execution au Chargement de la page
   //
   $(document).ready(function () {
       _initNavMenuAccordion();
       _autoDismissMessage();
    }); 

})(shq, apex, apex.util, apex.jQuery);