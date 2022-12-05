/* global apex */

//const { validate } = require("json-schema");

var shq = shq || {};
shq.ig_selection = {};

(function (ig_selection, shq, ut, $) {
    "use strict";
    var diese = '#';
    var C_LOG_DEBUG = apex.debug.LOG_LEVEL.INFO;

    ig_selection.assignerItemsIgSelectionne = function (colonneClef, collectionApex, data, modelIg) {


        var i, elements = [];
        var value;
        var id = data.model.getOption("regionStaticId");
        var view = apex.region(id).call("getCurrentView");


        if (view.singleRowMode) {
            return;
        }

        for (i = 0; i < data.selectedRecords.length; i++) {
            value = modelIg.getValue(data.selectedRecords[i], colonneClef);
            if (elements.indexOf(value)) {
                elements.push(value);
            }
        }

        var result = apex.server.process("ENREGISTRER_SELECTION_IG", {
            f01: elements,
            x01: collectionApex
        });

        apex.message.clearErrors();
        result.done(function (data) {
            var message = apex.lang.formatMessage('APEX.GV.SELECTION_COUNT',elements.length);
            apex.debug.info(message);
        }).fail(function (jqXHR, textStatus, errorThrown) {
            var message = apex.lang.getMessage('SHQ.ERREUR.SELECTION_ENREGISTREMENT');
            
            apex.message.showErrors([
                {
                    type: "error",
                    location: "page",
                    message: message,
                    unsafe: false
                }
            ]);
        });
    };

    ig_selection.enregistrementSelectione = function (data) {

        var id = data.model.getOption("regionStaticId");
        var view = apex.region(id).call("getCurrentView");
        
        var selectionne = false;
        

        if (view.singleRowMode) {
            return;
        }    

        /*
        if (view.view$.grid("inEditMode") && nbRecordSelected > 0) {
            return;
        }
        */

        var nbRecordSelected = data.selectedRecords === undefined ? 0 : data.selectedRecords.length;
        selectionne = nbRecordSelected === 0 ? false : true;        
        
        return selectionne;
        
    };

})(shq.ig_selection, shq, apex.theme42, apex.jQuery);