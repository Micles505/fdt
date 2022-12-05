/* global apex */

var shq = shq || {};
shq.dialog = {};

(function (dialog, shq, ut, $) {
   "use strict";
   dialog.confirmeFermetureDialog = function (event, ui) {
      var l_original_bouton_Ok = apex.lang.getMessage("APEX.DIALOG.OK");
      var l_nouveau_bouton_ok = apex.lang.getMessage("SHQ.DIALOG.WARNONSAVE.QUITTER");
      var message = apex.lang.getMessage("APEX.WARN_ON_UNSAVED_CHANGES");

      //change le libellé des boutons
      apex.lang.addMessages({ "APEX.DIALOG.OK": l_nouveau_bouton_ok });

      if (apex.page.isChanged()) {
         apex.message.confirm(message, function (okPressed) {
            if (okPressed) {
               apex.lang.addMessages({ "APEX.DIALOG.OK": l_original_bouton_Ok });
               apex.navigation.dialog.close(true);
            }
         });
      } else {
         apex.lang.addMessages({ "APEX.DIALOG.OK": l_original_bouton_Ok });
         apex.navigation.dialog.close(true);
      }

   };   
   dialog.validerFermetureDialogue = function (elementDialogue) {
      var uiDialogueNotification = 'ui-dialog--notification';
      var uiDialogueInline = 'ui-dialog--inline';
  
      var classList = elementDialogue.target.parentElement.classList;
  
      return $.inArray(uiDialogueNotification, classList) === -1 &&
        $.inArray(uiDialogueInline, classList) === -1;
    };    
})(shq.dialog, shq, apex.theme42, apex.jQuery);