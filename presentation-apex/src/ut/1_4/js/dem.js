/* global apex */

//const { validate } = require("json-schema");

var shq = shq || {};
shq.dem = {};

(function (dem, shq, ut, $) {


    dem.assignerItemsIgSelectionne = function (colonneClef, itemApex, data, modelIg) {

        var i, elements = [];
        var value;
                
        for (i = 0; i < data.selectedRecords.length; i++) {
            value = modelIg.getValue(data.selectedRecords[i], colonneClef);
            if (elements.indexOf(value)) {
                elements.push(value);
            }
        }

        apex.item(itemApex).setValue(elements.join(':'));

    };

    dem.selectionneImportationDesjardins = function (event, data) {

        var i, elements = [];
        var value;
        var model = data.model;        
        var messageApex = apex.lang.getMessage('SHQ.AVERTISSEMENT.SOURCE_FICHIER.SELECTIONNER');

        apex.message.clearErrors();
        model.forEach(function(record,index,id){
            model.setValidity("valid",id,'FILENAME');
        });
        
        for (i = 0; i < data.selectedRecords.length; i++) {
            
            value = model.getValue(data.selectedRecords[i], 'NO_SEQ_FICHIER_EXTRN');
            var id = model.getRecordId(data.selectedRecords[i]);
            var valueSourceFichier = model.getValue(data.selectedRecords[i], 'SOURCE_FICHIER');

            if (valueSourceFichier !== 'SPC2') {

                var message = apex.lang.formatNoEscape(messageApex,valueSourceFichier);
                model.setValidity( apex.message.TYPE.ERROR, id, 'FILENAME',message );
                apex.message.showErrors([{type:apex.message.TYPE.ERROR,
                                         location:"page",
                                         message: message,
                                         unsafe:true}]);

            } else {
                elements.push(value);
            }
        }

        apex.item('P21_SELECTED_IG').setValue(elements.join(':'));

    };

    dem.sauvegarde_conseil_adm = function () {

        var vta_prenom_membre_ca = [];
        var vta_nom_membre_ca = [];
        var vta_no_seq_carac_ca = [];
        var vta_precision = [];
        var pThis;

        //obtenir la liste  des prenoms
        $('.cair_prenom_membre_ca').each(function () {
            pThis = $(this);
            pvalue = pThis.val();
            vta_prenom_membre_ca.push(pvalue);
        });

        //obtenir la liste des noms
        $('.cair_nom_membre_ca').each(function () {
            pThis = $(this);
            pvalue = pThis.val();
            vta_nom_membre_ca.push(pvalue);
        });

        //obtenir la liste des identifiants
        $('.cair_no_seq_carac_ca').each(function () {
            pThis = $(this);
            pvalue = pThis.val();
            vta_no_seq_carac_ca.push(pvalue);
        });

        //obtenir la liste des precisions
        $('.cair_precision').each(function () {
            pThis = $(this);
            pvalue = pThis.val();
            vta_precision.push(pvalue);
        });

        apex.server.process("SAVE_CA", {
            f01: vta_no_seq_carac_ca,
            f02: vta_prenom_membre_ca,
            f03: vta_nom_membre_ca,
            f04: vta_precision,
            pageItems: "#P4_NO_SEQ_DEMAN_PHAQ,#P4_IND_CONSEIL_ADMINISTRATION"
        }, {
            success: function (pData) {
                apex.region('conseilAdm').refresh();
            }
        });

    };

})(shq.dem, shq, apex.theme42, apex.jQuery);