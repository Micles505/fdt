/* global apex */

//const { default: validation } = require("ajv/dist/vocabularies/validation");

var shq = shq || {};
shq.fdt = {};



(function (fdt, shq, ut, $) {

    "use strict";

    var diese = '#';
    var C_LOG_DEBUG = apex.debug.LOG_LEVEL.INFO;
    var FORMAT_DATE_HEURE = 'YYYY-MM-DD HH24:MI';
    var GRID_TEMPSSAISIEPERIODE = "tempsSaisiePeriode";
    var GRID_TEMPSINTERVENTION = "tempsIntervention";
    // 
    // Fonction qui valide les heures AM
    // 
    fdt.validerHeureAM = function (model, change) {
        apex.debug.info('On change validerHeureAM');

        // Élément modifié
        var heureDebutAm = model.getValue(change.record, "DH_DEBUT_AM_TEMPS_SAISIE");
        var heureFinAm = model.getValue(change.record, "DH_FIN_AM_TEMPS_SAISIE");
        var dateEnSaisieAm = model.getValue(change.record, "DT_TEMPS_JOUR");
        if (Boolean(heureDebutAm) && Boolean(heureFinAm)) {
            var dateDebutAm = apex.date.parse(dateEnSaisieAm + ' ' + heureDebutAm, FORMAT_DATE_HEURE);
            var dateFinAm = apex.date.parse(dateEnSaisieAm + ' ' + heureFinAm, FORMAT_DATE_HEURE);
            var heureDebutApresFinAm = apex.date.isAfter(dateDebutAm, dateFinAm);
            var apexItem = apex.item(change.field);
            if (heureDebutApresFinAm) {
                apexItem.node.setCustomValidity(apex.lang.getMessage("SHQ.ITEM.HEURE_INCOHERENTE"));
            } else {
                apexItem.node.setCustomValidity("");
            }
        }
    };
    // 
    // Fonction qui valide les heures PM
    // 
    fdt.validerHeurePM = function (model, change) {
        apex.debug.info('On change validerHeurePM');

        // Élément modifié

        var heureDebutPm = model.getValue(change.record, "DH_DEBUT_PM_TEMPS_SAISIE");
        var heureFinPm = model.getValue(change.record, "DH_FIN_PM_TEMPS_SAISIE");
        var dateEnSaisiePm = model.getValue(change.record, "DT_TEMPS_JOUR");

        if (Boolean(heureDebutPm) && Boolean(heureFinPm)) {
            var dateDebutPm = apex.date.parse(dateEnSaisiePm + ' ' + heureDebutPm, FORMAT_DATE_HEURE);
            var dateFinPm = apex.date.parse(dateEnSaisiePm + ' ' + heureFinPm, FORMAT_DATE_HEURE);
            var heureDebutApresFinPm = apex.date.isAfter(dateDebutPm, dateFinPm);
            var apexItem = apex.item(change.field);
            if (heureDebutApresFinPm) {
                apexItem.node.setCustomValidity(apex.lang.getMessage("SHQ.ITEM.HEURE_INCOHERENTE"));
            } else {
                apexItem.node.setCustomValidity("");
            }
        }
    };
    // 
    // Fonction qui met en évidence les enregistrement fériés.
    // 
    fdt.appliquerMiseEnEvidenceEnregistrement = function (model) {

        var cssFeriee = apex.lang.getMessage("FDT.CSS.FERIEE");

        model.forEach(function (record, index, id) {
            var journeeFerrie = model.getValue(record, "INDIC_FERIEE");
            var meta = model.getRecordMetadata(id);

            meta.highlight = journeeFerrie === 'O' ? cssFeriee : '';
        });
    };
    //
    // This is the general pattern for subscribing to model notifications
    //
    // need to do this here rather than in Execute when Page Loads so that the handler
    // is setup BEFORE the IG is initialized otherwise miss the first model created event
    fdt.souscrireFeuilleDeTemps = function () {
        // the model gets released and created at various times such as when the report changes
        // listen for model created events so that we can subscribe to model notifications
        var $id = $(diese.concat(GRID_TEMPSSAISIEPERIODE));

        $id.on("interactivegridviewmodelcreate", function (event, ui) {
            var sid,
                model = ui.model;
            // note this is only done for the grid veiw. It could be done for
            // other views if desired. The important thing to realize is that each
            // view has its own model
            if (ui.viewId === "grid") {
                fdt.appliquerMiseEnEvidenceEnregistrement(model);
                sid = model.subscribe({
                    onChange: function (type, change) {
                        var heureAM = ['DH_DEBUT_AM_TEMPS_SAISIE', 'DH_FIN_AM_TEMPS_SAISIE'];
                        var heurePM = ['DH_DEBUT_PM_TEMPS_SAISIE', 'DH_FIN_PM_TEMPS_SAISIE'];
                        if (type === "set") {
                            // don't bother to recalculate if other columns change
                            if (heureAM.indexOf(change.field) > -1) {
                                fdt.validerHeureAM(model, change);
                            } else if (heurePM.indexOf(change.field) > -1) {
                                fdt.validerHeurePM(model, change);
                            }
                        }
                        fdt.appliquerMiseEnEvidenceEnregistrement(model);
                    },
                    progressView: this.element
                });
            }
        });

    };
    //
    // Sélection des périodes dans la  page de saisie du temps 
    // 
    fdt.selectionPeriode = function (pRegionContainer, pIndexTab, pDebutPeriodeItem, pDebutPeriodeVal, pFinPeriodeItem, pFinPeriodeVal) {

        var TAB_CONTAINER_CLASS = 't-Tabs',
            TAB_ITEM_CLASS = 't-Tabs-item',
            IS_CURRENT_CLASS = 'is-active';

        //enlever la classe is-active de l'ancien élément sélectionné

        $('#' + pRegionContainer).find('.' + TAB_ITEM_CLASS + '.' + IS_CURRENT_CLASS).removeClass(IS_CURRENT_CLASS);

        //ajouter la classe is-active sur l'élément sélectionné

        $('#' + pRegionContainer).find('.' + TAB_ITEM_CLASS).eq(pIndexTab).addClass(IS_CURRENT_CLASS);
        apex.item(pDebutPeriodeItem).setValue(pDebutPeriodeVal);
        apex.item(pFinPeriodeItem).setValue(pFinPeriodeVal);
        apex.item('P2_REFRESH_FDT_INTERVENTION').setValue(pIndexTab);
    };
    //
    // Mise à jour du lien pour l'ajout d'absence
    // 
    fdt.obtenirHrefAjouterAbsence = function () {
        var itemUrl = apex.item("P2_URL_PAGE_ABSENCE");
        var url = itemUrl.getValue();

        return url;
    };
    // 
    // Configuration de la barre d'outils de la feuille de temps     
    //
    fdt.configurerSaisieTemps = function (config) {

        var toolbarData = $.apex.interactiveGrid.copyDefaultToolbar(); // copie la toolbar  
        // 
        // section de la toolbar
        //    
        var toolbarGroupAction1 = toolbarData.toolbarFind("actions1").controls,
            toolbarGroupAction2 = toolbarData.toolbarFind("actions2").controls,
            toolbarGroupAction3 = toolbarData.toolbarFind("actions3").controls,
            toolbarGroupAction4 = toolbarData.toolbarFind("actions3").controls;
        //
        // Constantes
        //
        var OUI = 'O',
            NON = 'N',
            ABSENCE = 'ABS',
            VACANCE = 'VAC';
        //
        // Boutons annuler modif
        //
        //var modelBoutonAnnulerModif = {
        //    type: "BUTTON",
        //    name: "annuler-ligne",
        //    label: "Annuler",
        //    action: "selection-revert",
        //    icon: "fa fa-undo",
        //    iconBeforeLabel: true,
        //    hot: false
        //};

        //toolbarGroupAction3.push(modelBoutonAnnulerModif);
        //
        // Bouton Enregistrer
        // 
        var saveAction = toolbarData.toolbarFind("save");
        saveAction.icon = "fa fa-table fam-arrow-down fam-is-info";
        saveAction.label = "Enregistrer mon temps ";
        saveAction.iconBeforeLabel = true;
        saveAction.hot = true;
        toolbarGroupAction2.pop();
        toolbarGroupAction3.push(saveAction);
        //
        // fonctions Filtre
        // 
        var actionFiltre = function (event, element) {

            var itemFiltreAbscence = apex.item("P2_FILTRE_TEMPS_SAISIE_ABS");
            var itemFiltreVacance = apex.item("P2_FILTRE_TEMPS_SAISIE_VAC");
            //
            // Détrermine quel bouton a été cliqué
            //         
            var dataAction = this.name;

            var itemvaleur;
            var item;

            switch (dataAction) {
                case 'filtre-absence':
                    itemvaleur = ABSENCE;
                    item = itemFiltreAbscence;
                    break;
                case 'filtre-vacance':
                    itemvaleur = VACANCE;
                    item = itemFiltreVacance;
                    break;
                default:
                    itemFiltre.setValue(null);
            }

            if (this.get()) {
                item.setValue('');
                this.set(false);
                $(element).removeClass("is-active-filtre-fdt");
            } else {
                item.setValue(itemvaleur);
                this.set(true);
                $(element).addClass("is-active-filtre-fdt");
            }

            apex.region(GRID_TEMPSSAISIEPERIODE).refresh();

            return this.get();

        };
        //
        // Appel de la page de saisie des absences
        //  
        var dialogueAbsence = function () {
            var url = fdt.obtenirHrefAjouterAbsence();
            apex.navigation.redirect(url);
        };
        //
        // Process qui sauvegarde la grid passé en paramètre.
        // 
        var processSave = function (ig, grid) {

            return new Promise(function (resolve, reject) {
                //
                // Si il y a des erreurs sur la gird alors on fait rien
                // 
                if (grid.model.hasErrors()) {
                    reject(false);
                } else {

                    var modelProcessSave = grid.model.save(resolve(true));
                    //
                    // Sauvegarde en cour ou rien à mettre à jour 
                    //
                    if (!modelProcessSave) {
                        resolve(true);
                    }
                }
            });
        };
        //
        // Boutons Filtre
        //        
        config.initActions = function (actions) {

            actions.add([{
                name: "filtre-absence",
                label: 'Absence',
                state: false,
                action: actionFiltre,
                get: function () {
                    return this.state;
                },
                set: function (v) {
                    this.state = v;
                    return this.state;
                }
            },
            {
                name: "filtre-vacance",
                label: 'Vacances',
                state: false,
                action: actionFiltre,
                get: function () {
                    return this.state;
                },
                set: function (v) {
                    this.state = v;
                    return this.state;
                }

            },
            //
            // définition de l'action du bouton Ajouter absence
            // 
            {
                name: "ajouter-absence",
                label: "Absence",
                action: function (event, el) {
                    //
                    // EA_RESSOURCE_SAISI_INTRV est une constante déclarer dans la page dans le
                    // Function and Global Variable Declaration
                    //                                         
                    var indicateurMoisComplet = apex.item("P2_IND_MOIS_COMPLET_INTERV").getValue(),
                        igTempsPeriode = apex.region(GRID_TEMPSSAISIEPERIODE),
                        gridTempPeriode = igTempsPeriode.call("getViews").grid,
                        igIntervention,
                        gridIntervention;

                    var promiseTempsPeriode = processSave(igTempsPeriode, gridTempPeriode),
                        promiseIntervention,
                        arrayPromise = new Array(0);

                    if (indicateurMoisComplet == 'N' &&
                        EA_RESSOURCE_SAISI_INTRV === 'O') {

                        igIntervention = apex.region(GRID_TEMPSINTERVENTION);
                        gridIntervention = igIntervention.call("getViews").grid;
                        promiseIntervention = processSave(igIntervention, gridIntervention);
                        arrayPromise.push(promiseTempsPeriode, promiseIntervention);
                    } else {
                        igIntervention = null;
                        gridIntervention = null;
                        promiseIntervention = null;
                        arrayPromise.push(promiseTempsPeriode);
                    }

                    Promise.all(arrayPromise).then(function (retours) {
                        if (retours.every(Boolean)) {
                            dialogueAbsence();
                        }
                    })
                        .catch(function (error) {
                            shq.page.alert(apex.lang.getMessage("FDT.ABSENCE.ERREUR"));
                        });
                }
            }]);
        };
        //
        // définition des boutons personnalisés de la grid
        // 
        var modelBoutonAjouterAbsence = {
            type: "BUTTON",
            icon: "fa fa-plus",
            action: "ajouter-absence",
            iconBeforeLabel: true,
            hot: true
        };

        var modelBoutonFiltreAbsence = {
            type: "BUTTON",
            action: "filtre-absence",
            icon: 'fa fa-filter',
            iconBeforeLabel: true,
        };

        var modelBoutonFiltreVacance = {
            type: "BUTTON",
            action: 'filtre-vacance',
            icon: 'fa fa-filter',
            iconBeforeLabel: true

        };
        //
        // Ajout des boutons filtres sur la grid.
        //     
        toolbarGroupAction2.push(modelBoutonFiltreAbsence);
        toolbarGroupAction2.push(modelBoutonFiltreVacance);
        //
        // Détermine si on affiche le bouton absence selon l'indicateur interne ou externe de la personne ressource
        // 
        var indicateurAjoutBoutonAbsence = function () {
            //
            // La variable EA_INTERNE_OU_EXTERNE est déclaré dans la page 2 dans Function and Global Variable Declaration
            //  
            if (EA_INTERNE_OU_EXTERNE === 'I') {
                return true;
            } else {
                return false;
            }
        };

        if (indicateurAjoutBoutonAbsence()) {
            toolbarGroupAction4.push(modelBoutonAjouterAbsence);
        }        
        //
        // Ajout du mode skipReadonlyCells
        // 
        config.defaultGridViewOptions = config.defaultGridViewOptions || {};
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
    // Configuration de la barre d'outils de la feuille de temps des intervention    
    //
    fdt.configurerSaisieIntervention = function (config) {

        var toolbarData = $.apex.interactiveGrid.copyDefaultToolbar(); // copie la toolbar  
        // 
        // section de la toolbar
        //    
        var toolbarGroupAction1 = toolbarData.toolbarFind("actions1").controls,
            toolbarGroupAction2 = toolbarData.toolbarFind("actions2").controls,
            toolbarGroupAction3 = toolbarData.toolbarFind("actions3").controls;           
        //
        // Bouton Ajouter
        //            
        var addrowAction = toolbarData.toolbarFind("selection-add-row");
        addrowAction.label = "Ajouter";
        addrowAction.icon = "fa fa-plus";
        addrowAction.iconBeforeLabel = true;
        addrowAction.hot = true;
        // toolbarGroupAction3.push(modelBoutonAnnulerModif);
        //
        // Bouton Enregistrer
        // 
        var saveAction = toolbarData.toolbarFind("save");
        saveAction.icon = "fa fa-table fam-arrow-down fam-is-info";
        saveAction.label = "Enregistrer";
        saveAction.iconBeforeLabel = true;
        saveAction.hot = true;
        toolbarGroupAction2.pop();
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
        config.defaultGridViewOptions = config.defaultGridViewOptions || {};
        $.extend(config.defaultGridViewOptions, skipReadonlyCells);
        //
        // retourne la config
        //
        config.toolbarData = toolbarData;
        return config;
    };

})(shq.fdt, shq, apex.theme42, apex.jQuery);