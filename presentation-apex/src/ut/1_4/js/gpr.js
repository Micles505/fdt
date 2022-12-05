/* global apex */

var shq = shq || {};
shq.gpr = {};

(function (shq, gpr, util, $) {
   "use strict";

   gpr.ajusterFocusContactClient =  function(itemContactClient)  {
      var coTypClient = apex.item(itemContactClient).getValue();
      var idFocusNombre;
      var selectorJq = "label[for=\"".concat(itemContactClient).concat("_idFocusNombre\"");

      switch (coTypClient) {
         case 'DOMIC':
            // code block
            idFocusNombre = '0';
            break;
         case 'BURE':
            // code block
            idFocusNombre = '1';
            break;
         case 'CELL':
            // code block
            idFocusNombre = '2';
            break;
         case 'TELEA':
            // code block
            idFocusNombre = '3';
            break;
         case 'FAX':
            // code block
            idFocusNombre = '4';
            break;
         default:
            // code block
            // Autre
            idFocusNombre = '5';
      }
      selectorJq = selectorJq.replace('idFocusNombre', idFocusNombre);
      $(selectorJq).focus();
   };
   //
   // Ajuster le focus sur le pills buttons de l'adresse
   //
   gpr.ajusterFocueTypClient = function (itemTypClient) {
      var coTypClient = apex.item(itemTypClient).getValue();
      var idFocusNombre;
      var selectorJq = "label[for=\"P18_CO_TYP_CLIENT_idFocusNombre\"";

      switch (coTypClient) {
         case 'COPR':
            // code block
            idFocusNombre = '1';
            break;
         case 'REPO':
            // code block
            idFocusNombre = '2';
            break;
         default:
            // code block
            // Propriétaire
            idFocusNombre = '0';
      }
      selectorJq = selectorJq.replace('idFocusNombre', idFocusNombre);
      $(selectorJq).focus();
   };
})(shq, shq.gpr, apex.util, apex.jQuery);