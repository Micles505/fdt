/* global apex */
/* global moment */

var shq = shq || {};
shq.pil = {};

(function (shq, pil, util, $) {
   "use strict";

   var C_GRID = "grid",
      C_SET = "set";

   pil.calculerNombrejour = function (model, recordId) {

      var C_DAYS = "days";
      var meta = model.getRecordMetadata(recordId);
      var rec = model.getRecord(recordId);

      if (meta.inserted || meta.updated) {
         /*
          * Force un objet moment à null pour qu'il soit volontairement invalide 
          */
         var dtDebut = model.getValue(rec, "DT_DEBUT_AN").lenght === 0 ? moment(null) : moment(model.getValue(rec, "DT_DEBUT_AN"));
         var dtFin = model.getValue(rec, "DT_FIN_AN").lenght === 0 ? moment(null) : moment(model.getValue(rec, "DT_FIN_AN"));

         if (dtDebut.isValid() && dtFin.isValid() && dtDebut.isBefore(dtFin)) {
            dtFin.add(1, C_DAYS);
            /*
             * Le setValue prends une valeur en sting seulement, corrigé dans les versions supérieurs
             */
            var nbjour = dtFin.diff(dtDebut, C_DAYS).toString();
            model.setValue(rec, "NB_JOUR", nbjour);
         }
      }

   };

   pil.gridCalendrierPil = function () {

      $("#calendrierPil").on("interactivegridviewmodelcreate", function (event, ui) {
         // eslint-disable-next-line no-unused-vars
         var sid,
            model = ui.model;
         
         if (ui.viewId === C_GRID) {
            sid = model.subscribe({
               /* 
                * Bind l'événement change au model de la grid 
                */
               onChange: function (type, change) {

                  var dateColonnes = ['DT_DEBUT_AN', 'DT_FIN_AN'];

                  if (type === C_SET) {
                     if (dateColonnes.indexOf(change.field) > -1) {
                        setTimeout(function () {
                           pil.calculerNombrejour(model, change.recordId);
                        }, 0);
                     }
                  }
               }
            });
         }
      });
   };
})(shq, shq.pil, apex.util, apex.jQuery);