/*
*  Mettre ce fichier après la déclaration du fichier js de poste canada.
*  Ne pas mettre ce code dans la page load, car l'execution est trop tard dans le ready de la page.
*/

(function ($) {
  "use strict";

  addressComplete.listen("ready", function () {
    console.log("ready");
    addressComplete.setCulture("fr-CA");
  });    
  
    addressComplete.listen("load", function (control) {
    console.log("load");
    console.log(control);
    control.listen("populate", function (address) {
      var l_selector = "#".concat(this.autocomplete.field.id);
      var selector$ = $(l_selector);
      var cancelEvent = apex.event.trigger(
        selector$,
        "populatePosteCanada",
        address
      );
    });
  });

})(apex.jQuery);
