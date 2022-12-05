/* global apex */

var shq = shq || {};
shq.dem_public = {};

(function (dem_public, shq, ut, $) {

    var GRID_LOGEMENT_SUPERFICIE = "SuperficieLogement";
    var diese = '#';

    dem_public.souscrireSuperficieLogement = function () {
        // the model gets released and created at various times such as when the report changes
        // listen for model created events so that we can subscribe to model notifications
        var $id = $(diese.concat(GRID_LOGEMENT_SUPERFICIE));

        $id.on("interactivegridviewmodelcreate", function (event, ui) {
            var sid,
                model = ui.model;
            // note this is only done for the grid veiw. It could be done for
            // other views if desired. The important thing to realize is that each
            // view has its own model
            if (ui.viewId === "grid") {
                sid = model.subscribe({
                    onChange: function (type, change) {
                        var actions = apex.region(GRID_LOGEMENT_SUPERFICIE).call("getActions");
                        if (apex.page.isChanged()) {
                            actions.disable('generer-logement');
                        } else {
                            actions.enable('generer-logement');
                        }   
                    },
                    progressView: this.element
                });
            }
        });

    };
    //
    // configuration de la barre d'outils de la grid interactive Pour la superficie.
    //   
    dem_public.configurerBarreOutilsSuperficie = function (config) {
        var toolbarData = $.apex.interactiveGrid.copyDefaultToolbar(); // copie la toolbar      
        var toolbarGroup = toolbarData.toolbarFind("actions1").controls;

        var toolbarGroupAction3 = toolbarData.toolbarFind("actions3").controls;
        var toolbarGroupAction2 = toolbarData.toolbarFind("actions2").controls;

        var addrowAction = toolbarData.toolbarFind("selection-add-row");
        var saveAction = toolbarData.toolbarFind("save");
        config.defaultGridViewOptions = config.defaultGridViewOptions || {};
        //
        // Bouton Ajouter
        //
        addrowAction.label = "Ajouter";
        addrowAction.icon = "fa fa-plus";
        addrowAction.iconBeforeLabel = true;
        addrowAction.hot = true;
        //
        // Bouton save
        //  
        saveAction.icon = "fa fa-save fam-arrow-down fam-is-info";
        saveAction.label = "Superficie";
        saveAction.iconBeforeLabel = true;
        saveAction.hot = true;
        toolbarGroupAction2.pop();
        //
        // Bouton Annuler modification
        //
        var modelBoutonAnnulerModif = {
            type: "BUTTON",
            name: "annuler-ligne",
            label: "Annuler",
            action: "selection-revert",
            icon: "fa fa-undo",
            iconBeforeLabel: true,
            hot: false
        };

        toolbarGroupAction3.push(modelBoutonAnnulerModif);
        toolbarGroupAction3.push(saveAction);
        //
        // Bouton télecharger
        // 
        var modelBoutonTelecharger = {
            type: "BUTTON",
            name: "telecharger",
            label: "Télécharger",
            action: "show-download-dialog" ,
            icon: "fa fa-download",
            iconBeforeLabel: true,
            hot: false
        };
        toolbarGroupAction2.push(modelBoutonTelecharger);
        //
        // Bouton Supprimer
        //
        var modelBoutonSupprimer = {
            type: "BUTTON",
            name: "supprimer-ligne",
            label: "Supprimer",
            action: "selection-delete",
            icon: "fa fa-trash-o",
            iconBeforeLabel: true,
            hot: false
        };
        toolbarGroupAction3.push(modelBoutonSupprimer);
        //
        // Bouton Générer logement
        //  
        config.initActions = function (actions) {
            actions.add({
                name: "generer-logement",
                label: "Générer logement",
                action: function (even, ui) {
                    if (!apex.item("P200_URL_PAGE_GENERER_LOGEMENT").isEmpty()) {
                        var itemUrl = apex.item("P200_URL_PAGE_GENERER_LOGEMENT");
                        var url = itemUrl.getValue();
                        apex.navigation.redirect(url);
                    }
                }
            });
        };

        var modelBoutonGenererLogement = {
            type: "BUTTON",
            action: "generer-logement",
            icon: "fa fa-gears",
            iconBeforeLabel: true,
            hot: false
        };
        toolbarGroupAction3.push(modelBoutonGenererLogement);
        //
        // Ajout du mode skipReadonlyCells
        // 
        var skipReadonlyCells = {
            skipReadonlyCells: true,
        };

        $.extend(config.defaultGridViewOptions, skipReadonlyCells);
        //
        // retourne la config
        //
        config.toolbarData = toolbarData;
        return config;
    };


    //
    // configuration de la barre d'outils de la grid interactive Pour la superficie.
    //   
    dem_public.configurerBarreOutilsAutresSuperficie = function (config) {
        var toolbarData = $.apex.interactiveGrid.copyDefaultToolbar(); // copie la toolbar      
        var toolbarGroup = toolbarData.toolbarFind("actions1").controls;

        var toolbarGroupAction3 = toolbarData.toolbarFind("actions3").controls;
        var toolbarGroupAction2 = toolbarData.toolbarFind("actions2").controls;

        var addrowAction = toolbarData.toolbarFind("selection-add-row");
        var saveAction = toolbarData.toolbarFind("save");
        config.defaultGridViewOptions = config.defaultGridViewOptions || {};
        //
        // Bouton Ajouter
        //
        addrowAction.label = "Ajouter";
        addrowAction.icon = "fa fa-plus";
        addrowAction.iconBeforeLabel = true;
        addrowAction.hot = true;
        //
        // Bouton save
        //  
        saveAction.icon = "fa fa-save fam-arrow-down fam-is-info";
        saveAction.label = "Superficie";
        saveAction.iconBeforeLabel = true;
        saveAction.hot = true;
        toolbarGroupAction2.pop();
        //
        // Bouton Annuler modification
        //
        var modelBoutonAnnulerModif = {
            type: "BUTTON",
            name: "annuler-ligne",
            label: "Annuler",
            action: "selection-revert",
            icon: "fa fa-undo",
            iconBeforeLabel: true,
            hot: false
        };

        toolbarGroupAction3.push(modelBoutonAnnulerModif);
        toolbarGroupAction3.push(saveAction);
        //
        // Bouton Supprimer
        //
        var modelBoutonSupprimer = {
            type: "BUTTON",
            name: "supprimer-ligne",
            label: "Supprimer",
            action: "selection-delete",
            icon: "fa fa-trash-o",
            iconBeforeLabel: true,
            hot: false
        };
        toolbarGroupAction3.push(modelBoutonSupprimer);
        //
        // Ajout du mode skipReadonlyCells
        // 
        var skipReadonlyCells = {
            skipReadonlyCells: true,
        };

        $.extend(config.defaultGridViewOptions, skipReadonlyCells);
        //
        // retourne la config
        //
        config.toolbarData = toolbarData;
        return config;
    };

    //
    // configuration de la barre d'outils de la grid interactive Pour la superficie.
    //   
    dem_public.configurerBarreOutilsRepartition = function (config) {
        var toolbarData = $.apex.interactiveGrid.copyDefaultToolbar(); // copie la toolbar      
        var toolbarGroup = toolbarData.toolbarFind("actions1").controls;

        var toolbarGroupAction3 = toolbarData.toolbarFind("actions3").controls;
        var toolbarGroupAction2 = toolbarData.toolbarFind("actions2").controls;

        var addrowAction = toolbarData.toolbarFind("selection-add-row");
        var saveAction = toolbarData.toolbarFind("save");
        config.defaultGridViewOptions = config.defaultGridViewOptions || {};
        //
        // Bouton Ajouter
        //
        addrowAction.label = "Ajouter";
        addrowAction.icon = "fa fa-plus";
        addrowAction.iconBeforeLabel = true;
        addrowAction.hot = true;
        //
        // Bouton save
        //  
        saveAction.icon = "fa fa-save fam-arrow-down fam-is-info";
        saveAction.label = "Répartition";
        saveAction.iconBeforeLabel = true;
        saveAction.hot = true;
        toolbarGroupAction2.pop();
        //
        // Bouton Annuler modification
        //
        var modelBoutonAnnulerModif = {
            type: "BUTTON",
            name: "annuler-ligne",
            label: "Annuler",
            action: "selection-revert",
            icon: "fa fa-undo",
            iconBeforeLabel: true,
            hot: false
        };

        toolbarGroupAction3.push(modelBoutonAnnulerModif);
        toolbarGroupAction3.push(saveAction);
        //
        // Bouton Supprimer
        //
        var modelBoutonSupprimer = {
            type: "BUTTON",
            name: "supprimer-ligne",
            label: "Supprimer",
            action: "selection-delete",
            icon: "fa fa-trash-o",
            iconBeforeLabel: true,
            hot: false
        };
        toolbarGroupAction3.push(modelBoutonSupprimer);

        //
        // Ajout du mode skipReadonlyCells
        // 
        var skipReadonlyCells = {
            skipReadonlyCells: true,
        };

        $.extend(config.defaultGridViewOptions, skipReadonlyCells);
        //
        // retourne la config
        //
        config.toolbarData = toolbarData;
        return config;
    };
})(shq.dem_public, shq, apex.theme42, apex.jQuery);