/* global apex */

var shq = shq || {};
shq.page = {};

(function (shq, page, ut, $) {
   "use strict";
   // 
   // Permet d'afficher une boite de confimation avec des libellés différent sur les boutons.
   //
   shq.page.confirm = function (pMessage, pCallback, pOkLabel, pCancelLabel) {
      //
      // Valeur original des boutons
      //
      var l_original_boutons = {
         "APEX.DIALOG.OK": apex.lang.getMessage("APEX.DIALOG.OK"),
         "APEX.DIALOG.CANCEL": apex.lang.getMessage("APEX.DIALOG.CANCEL")
      };
      //
      //change les libellés des bouton 
      //      
      apex.lang.addMessages({ "APEX.DIALOG.OK": pOkLabel });
      apex.lang.addMessages({ "APEX.DIALOG.CANCEL": pCancelLabel });
      //
      // Affiche la boite de dialogue
      //
      apex.message.confirm(pMessage, pCallback);
      //
      //the timeout is required since APEX 19.2 due to a change in the apex.message.confirm
      //
      setTimeout(function () {
         // Remet les boutons à leur valeur ortiginal
         apex.lang.addMessages({ "APEX.DIALOG.OK": l_original_boutons["APEX.DIALOG.OK"] });
         apex.lang.addMessages({ "APEX.DIALOG.CANCEL": l_original_boutons["APEX.DIALOG.CANCEL"] });
      }, 0);
   };
   shq.page.alert = function (pMessage, pCallback, pOkLabel) {
      //
      // Valeur original des boutons
      //
      var l_original_boutons = {
         "APEX.DIALOG.OK": apex.lang.getMessage("APEX.DIALOG.OK"),
      };
      //
      //change les libellés des bouton 
      //      
      apex.lang.addMessages({ "APEX.DIALOG.OK": pOkLabel });      
      //
      // Affiche la boite de dialogue
      //
      apex.message.alert(pMessage, pCallback);
       //
      //the timeout is required since APEX 19.2 due to a change in the apex.message.confirm
      //
      setTimeout(function () {
         // Remet les boutons à leur valeur ortiginal
         apex.lang.addMessages({ "APEX.DIALOG.OK": l_original_boutons["APEX.DIALOG.OK"] });
      }, 0);
   };
})(shq, shq.page, apex.util, apex.jQuery);