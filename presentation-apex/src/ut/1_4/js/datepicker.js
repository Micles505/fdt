/* global apex */

var shq = shq || {};
shq.datePicker = {};

(function (shqDatePicker, shq, ut, $) {
    var diese = '#';
    /* 
     * Fonction qui affecte la date minimum de la composante jquery datepicker
     * 
     * Exemple d'appel
     * 
     * shq.datePicker.assignerDateMinimum(["NomDeMonItemApexJquery"],apex.item("MonItemApexDateValeur").getValue());
     * 
    */
    shqDatePicker.assignerDateMinimum = function (listApexItemName, valeurDate) {

        $.each(listApexItemName, function (indexInArray, valueOfElement) {
            var $apexItemName = $(valueOfElement.indexOf(diese, 0) === -1 ? diese.concat(valueOfElement) : valueOfElement);
            $apexItemName.datepicker("option", "minDate", valeurDate);
            //
            // Permet de remettre le bouton du datepicker comme APEX.
            //  
            $apexItemName.next('button').addClass('a-Button a-Button--calendar');
        });
    };
    /* 
     * Fonction qui affecte la date maximum de la composante jquery datepicker
     * Exemple d'appel
     * 
     * shq.datePicker.assignerDateMaximum(["NomDeMonItemApexJquery"],apex.item("MonItemApexDateValeur").getValue());
     * 
    */
    shqDatePicker.assignerDateMaximum = function (listApexItemName, valeurDate) {

        $.each(listApexItemName, function (indexInArray, valueOfElement) {
            var $apexItemName = $(valueOfElement.indexOf(diese, 0) === -1 ? diese.concat(valueOfElement) : valueOfElement);
            $apexItemName.datepicker("option", "maxDate", valeurDate);
            //
            // Permet de remettre le bouton du datepicker comme APEX.
            //  
            $apexItemName.next('button').addClass('a-Button a-Button--calendar');
        });
    };

})(shq.datePicker, shq, apex.theme42, apex.jQuery);