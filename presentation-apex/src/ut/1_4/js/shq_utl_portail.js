/* global apex */

var shq = shq || {};
shq.utl_portail = {};
//
// fonction pour le menu shq
//
(function (utl_portail, shq, $) {
   "use strict";
   //
   // Évenement "binder"  pour l'ouverture et fermeture des applications affectées au messages
   // 
   utl_portail.expandCollapseMessagePortail = function () {
      var target = 'li.t-shq-portail-message';      
      var addRemoveClassMessage = function (event) {
         var currentExpand = 'is-current is-expanded';
         var liTarget = event.currentTarget;

         $(target).not(liTarget).each(function (index, element) {
            $(element).removeClass(currentExpand);
         });

         var bidon =
            $(liTarget).hasClass(currentExpand) ? $(liTarget).removeClass(currentExpand) : $(liTarget).addClass(currentExpand);

      };
     
      $(target).on('click', function (event) {
         addRemoveClassMessage(event);
      });
   };
})(shq.utl_portail, shq, apex.jQuery);