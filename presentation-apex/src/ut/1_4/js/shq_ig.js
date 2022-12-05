/* global apex */

var shq = shq || {};
shq.ig = {};

(function (ig, shq, ut, $) {
   "use strict";
   var diese = '#';
   var C_LOG_DEBUG = apex.debug.LOG_LEVEL.INFO;

   //
   // Obtenir une la valeur d'une cellule correspondant au record courant et à un nom de colonne.
   // 
   ig.obtenirValeurColonneRecordCourant = function (nomGrille, nomColonne) {
      var valeur = "";

      var widget = apex.region(nomGrille).widget();
      if (!(widget && widget !== "null" && widget !== "undefined")) {
         return ("");
      }

      var grid = widget.interactiveGrid('getViews', 'grid');
      if (!(grid && grid !== "null" && grid !== "undefined")) {
         return ("");
      }

      var model = grid.model;
      if (!(model && model !== "null" && model !== "undefined")) {
         return ("");
      }

      var selectedRecords = grid.getSelectedRecords();

      if (selectedRecords.length == 1) {
         valeur = model.getValue(selectedRecords[0], nomColonne);
      }

      return (valeur);
   };
   //
   // Définir la valeur par defaut pour une colonne d'une grid interactive
   // 
   ig.definirValeurDefautColonne = function (nomGrille, nomColonne, valeurDefaut) {

      var appliquerdefaut = true;

      var widget = apex.region(nomGrille).widget();
      if (!(widget && widget !== "null" && widget !== "undefined")) {
         appliquerdefaut = false;
      }

      var grid = widget.interactiveGrid('getViews', 'grid');
      if (!(grid && grid !== "null" && grid !== "undefined")) {
         appliquerdefaut = false;
      }

      var model = grid.model;
      if (!(model && model !== "null" && model !== "undefined")) {
         appliquerdefaut = false;
      }

      var igFields = model.getOption("fields").nomColonne;
      if (!(igFields && igFields !== "null" && igFields !== "undefined")) {
         appliquerdefaut = false;
      }

      if (appliquerdefaut) {
         model.getOption("fields").nomColonne.defaultValue = valeurDefaut;
      }
   };
   //
   // Permet de rengre une IG éditable ou non. Gère aussi l'affichage et des boutons concernés.
   // 
   ig.activerDesactiverEditable = function (igStaticID, activer) {
      if (igStaticID !== undefined && activer !== undefined) {

         var actions = ["edit", "selection-add-row", "selection-delete", "selection-duplicate", "row-add-row", "row-delete", "row-duplicate", "insert-record", "delete-record", "selection-revert"];
         apex.region(igStaticID).call("getCurrentView").model.setOption("editable", activer);

         actions.forEach(function (item) {
            switch (activer) {
               case true:
                  apex.region(igStaticID).call("getActions").show(item);
                  break;
               case false:
                  apex.region(igStaticID).call("getActions").hide(item);
                  break;
               default:
            }
         });
      }
   }; //Fin ig.activerDesactiverEditable
   //
   // Permet de d'activer l'option d'ajouter une ligne dans une grid.
   // 
   ig.activerDesactiverAjouterLigne = function (igStaticID, activer) {
      if (igStaticID !== undefined && activer !== undefined) {

         var actions = ["selection-add-row", "row-add-row", "row-duplicate", "selection-duplicate"];

         actions.forEach(function (item) {
            switch (activer) {
               case true:
                  apex.region(igStaticID).call("getActions").enable(item);
                  break;
               case false:
                  apex.region(igStaticID).call("getActions").disable(item);
                  break;
               default:
            }
         });
      }
   }; //Fin ig.activerDesactiverAjouterLigne
   //
   // Modifie la visibilité des colonnes passer en paramètre pour la région donné.
   // 
   ig.modifierVisibiliteColonnes = function (colArray, gridRegionId, visibility) {
      var gridView = apex.region(gridRegionId).call("getViews").grid;
      var gridView$ = gridView.view$;

      gridView.getColumns().forEach(function (element) {
         /*
         //if(colArray.includes(x.property)) -- Non supporté par IExplorer. . .
         */
         if (colArray.indexOf(element.property) >= 0) {
            if (visibility) {
               gridView$.grid("showColumn", element.property);
            }
            else {
               gridView$.grid("hideColumn", element.property);
            }
         }
      });
   };
   //
   // Configuration le tooltips des colonnes 
   // 
   ig.configTooltipColonne = function (options, listColonne) {
      options.defaultGridViewOptions = options.defaultGridViewOptions || {};
      var gridOptions = {
         tooltip: {
            content: function (callback, model, recordMeta, colMeta, columnDef) {
               var text;
               if (columnDef && recordMeta) {
                  if ($.inArray(columnDef.property, listColonne) >= 0) {
                     text = model.getValue(recordMeta.record, columnDef.property);
                  }
               }
               return text;
            }
         }
      };

      $.extend(options.defaultGridViewOptions, gridOptions);
      return options;
   };
   //
   // Configuration de la largeur de la colonne 
   // 
   ig.configColonneStretch = function (options, blStretch, largeur) {
      options.defaultGridColumnOptions = options.defaultGridColumnOptions || {};
      var configColonne;

      if (largeur !== undefined && largeur > 0) {
         configColonne = {
            noStretch: blStretch,
            width: largeur
         };
      }
      $.extend(options.defaultGridColumnOptions, configColonne);
      return options;
   };
   //
   // Mets un numéro de séquence comme première colonne
   // 
   ig.configColonneRowHeaderSequence = function (options) {
      options.defaultGridViewOptions = options.defaultGridColumnOptions || {};
      var rowHeader = {
         multiple: false,
         hideControl: true,
         rowHeader: "sequence"
      };
      $.extend(options.defaultGridViewOptions, rowHeader);
      return options;
   };
   //
   // Configuration da la colonne APEX$ROW_ACTION
   //
   ig.configApexRowAction = function (config) {
      config.defaultGridColumnOptions = config.defaultGridColumnOptions || {};
      // Désactive la sélection de l'entête de colonne. Empêche son déplacement
      var rowAction = {
         noHeaderActivate: true,
         usedAsRowHeader: false
      };
      //
      // Retour de la config de la colonne.
      // 
      $.extend(config.defaultGridColumnOptions, rowAction);
      return config;
   };
   //
   // Configuration da la colonne Edition Lien 
   // 
   ig.configurerOptionEditionLienIg = function (config) {
      config.defaultGridColumnOptions = config.defaultGridColumnOptions || {};
      // Désactive la sélection de l'entête de colonne pour l'edition d'un enregistrement.      
      var editionLien = {
         noHeaderActivate: true,
         label: '',
         noStretch: true,
         width: 45
      };
      //
      // Retire la possibilité d'enlever la colonne.
      //
      if (config.features !== undefined) {
         config.features.canHide = false;
      }
      //
      // Retour de la config de la colonne.
      // 
      $.extend(config.defaultGridColumnOptions, editionLien);
      return config;
   };
   // 
   // Ajout du bouton ajouter pour une boite de dialogue 
   // 
   ig.configurerBoutonAjouterDialogue = function (config) {
      var toolbarData = $.apex.interactiveGrid.copyDefaultToolbar(); // copie la toolbar      
      var toolbarGroup = toolbarData.toolbarFind("actions3").controls;

      toolbarGroup.push({
         type: "BUTTON",
         action: "ajouter-valeur-parametre",
         iconBeforeLabel: true
      });
      config.toolbarData = toolbarData;
      return config;
   };
   //
   // Retire l'option d'aggrégation dans la boite option
   // 

   //
   // configuration de la barre d'outils de la grid interactive.
   //   
   ig.configurerBarreOutilsBoutons = function (config, boutonAnnuler, boutonSupprimer, boutonSave) {
      var toolbarData = $.apex.interactiveGrid.copyDefaultToolbar(); // copie la toolbar      
      var toolbarGroup = toolbarData.toolbarFind("actions1").controls;

      /* indique si la grid on peut ajouter des données */
      var boutonAjouter = false;


      if (config.editable !== undefined) {
         if (config.editable.allowedOperations.create === undefined) {
            boutonAjouter = true;
         } else {
            boutonAjouter = config.editable.allowedOperations.create;
         }
      }

      boutonAnnuler = undefined ? false : boutonAnnuler;
      boutonSupprimer = undefined ? false : boutonSupprimer;
      boutonSave = undefined ? false : boutonSave;

      var toolbarGroupAction3 = toolbarData.toolbarFind("actions3").controls;
      var toolbarGroupAction2 = toolbarData.toolbarFind("actions2").controls;

      var addrowAction = toolbarData.toolbarFind("selection-add-row");
      var saveAction = toolbarData.toolbarFind("save");
      //
      // Sélection du nombre d'enregistrement 
      // 
      toolbarGroup.unshift({
         type: "SELECT",
         action: "change-rows-per-page"
      });
      //
      // Ajout des boutons
      //
      if (boutonAjouter) {
         //
         // Retirer le bouton ajouter "selection-add-row" 
         //
         addrowAction.label = "Ajouter";
         addrowAction.icon = "fa fa-plus";
         addrowAction.iconBeforeLabel = true;
         addrowAction.hot = true;
      } else {
         toolbarGroupAction3.pop();
      }
      if (boutonSave) {
         saveAction.icon = "fa fa-table-arrow-down";
         saveAction.label = "Enregistrer la grille";
         saveAction.iconBeforeLabel = true;
         saveAction.hot = true;
         toolbarGroupAction2.pop();

      }
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
      //
      // Bouton save 
      //
      if (boutonSave) {
         toolbarGroupAction3.push(saveAction);
      }
      //
      // Bouton Supprimer
      //
      if (boutonSupprimer) {
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
   // configuration de la barre d'outils de la grid interactive.
   //   
   ig.configurerBarreOutilsBoutonsLecture = function (config) {
      var toolbarData = $.apex.interactiveGrid.copyDefaultToolbar(); // copie la toolbar      
      var toolbarGroup = toolbarData.toolbarFind("actions1").controls;

      /* indique si la grid on peut ajouter des données */

      var toolbarGroupAction3 = toolbarData.toolbarFind("actions3").controls;
      var toolbarGroupAction2 = toolbarData.toolbarFind("actions2").controls;
      //
      // Sélection du nombre d'enregistrement 
      // 
      toolbarGroup.unshift({
         type: "SELECT",
         action: "change-rows-per-page"
      });
      //
      // Suppression des boutons
      //      
      toolbarGroupAction3.pop();
      toolbarGroupAction2.shift();
      toolbarGroupAction2.pop();

      //
      // retourne la config
      //
      config.toolbarData = toolbarData;
      return config;
   };

   ig.initialiserToolbarFacetedSearch = function (config) {

      var toolbarData = $.apex.interactiveGrid.copyDefaultToolbar(); // copie la toolbar
      var toolbarGroupAction2 = toolbarData.toolbarFind("actions2").controls;
      var toolbarGroup = toolbarData.toolbarFind("actions1");

      toolbarData.toolbarRemove("actions2");

      //
      // Sélection du nombre d'enregistrement 
      // 
      toolbarGroup.controls.push({
         type: "SELECT",
         action: "change-rows-per-page"
      });

      toolbarGroup.controls.push(
         {
            type: "BUTTON",
            action: "show-columns-dialog",
            iconBeforeLabel: true,
            hot: true
         });

      toolbarGroup.controls.push(
         {
            type: "BUTTON",
            action: "show-filter-dialog",
            iconBeforeLabel: true,
            hot: true
         });

      toolbarGroup.controls.push(
         {
            type: "BUTTON",
            action: "show-sort-dialog",
            iconBeforeLabel: true,
            hot: true
         });

      toolbarGroup.controls.push(
         {
            type: "BUTTON",
            action: "show-aggregate-dialog",
            iconBeforeLabel: true,
            hot: true
         });

      config.toolbarData = toolbarData;

      return config;

   };

   ig.assignerValeurJsChangeEvent = function (elementDeclancheur, ecraserValeur) {

      /* shq.ig.assignerValeurJsChangeEvent(this.triggeringElement); */

      // eslint-disable-next-line no-undef
      var valeur = elementDeclancheur.id === undefined ? null : $v2(elementDeclancheur.id);
      ecraserValeur = ecraserValeur === undefined ? false : ecraserValeur;

      switch (ecraserValeur) {
         case true:
            break;
         case false:
            // eslint-disable-next-line no-self-assign
            valeur = valeur;
            break;
         default:
            valeur = null;
      }
      return valeur;
   };

   /**
    * Initialisation de la grille interactive pour mémoriser la page et la selection.
    * @author Michel Lessard
    * @date 2020-12-01
    * @param 
    * @returns la fonction puiblique
    */
   ig.initialiserPageSelectionIg = (function () {

      var gInitialPages = {}; // map regionId -> {} map view -> init info
      var C_LOG_DEBUG = apex.debug.LOG_LEVEL.INFO;

      var urlParts = window.location.search.split(":"),
         resetPagination = urlParts[5] && urlParts[5].match(/RP/);

      // Move info from the session storage into gInitialPages structure so that
      // it can be used just once as the various widgets get initialized.
      function _setInitInfo(store, regionId, key) {
         var offset, count, info,
            sel = store.getItem(key + "LastSelection"),
            lastPage = store.getItem(key + "LastPage");

         // never trust session/local storage - validate!
         if (lastPage && lastPage.match(/\d+:\d+/)) {
            lastPage = lastPage.split(":");
            offset = parseInt(lastPage[0], 10);
            count = parseInt(lastPage[1], 10);
            info = { offset: offset, count: count };
            if (sel) {
               // not much validation of the selection that can be done
               info.sel = sel;
            }
            apex.util.getNestedObject(gInitialPages, regionId)[key] = info;
            apex.debug.message(C_LOG_DEBUG, '_setInitInfo:', info.offset, info.count);
         }
      }

      /*
       * At this point we don't know all the IG regions on the page because they 
       * haven't been inintialized yet. $(".a-IG") won't work yet!
       * But only care if info was put in sesson storage so use info from the keys
       * to get all the region ids.
       */
      var i, parts, len, store, regionId,
         igRegions = {};

      store = apex.storage.getScopedSessionStorage({ usePageId: true });
      len = store.length;

      for (i = 0; i < len; i++) {
         parts = store.key(i).split("."); // assume region id doesn't include "."!
         igRegions[parts[3]] = 1;
      }

      igRegions = Object.keys(igRegions);

      if (resetPagination) {
         // reset pagination for each of the possible views of each IG region
         igRegions.forEach(function (element) {
            regionId = element;
            store = apex.storage.getScopedSessionStorage({ usePageId: true, regionId: regionId });
            store.removeItem("gridLastPage");
            store.removeItem("iconLastPage");
            store.removeItem("detailLastPage");
         });
         apex.debug.message(C_LOG_DEBUG, 'resetPagination');
      } else {
         // prepare to restore the pagination offset for each of the possible veiws of each IG region
         igRegions.forEach(function (element) {
            regionId = element;
            // return to remembered IG page
            // store the lastPage info for when the IG view widgets are initalized
            store = apex.storage.getScopedSessionStorage({ usePageId: true, regionId: regionId });
            _setInitInfo(store, regionId, "grid");
            _setInitInfo(store, regionId, "icon");
            _setInitInfo(store, regionId, "detail");
            apex.debug.message(C_LOG_DEBUG, 'Preparation restauration page');
         });
      }

      /*
    * Step 1
    * When the page or selection changes remember it per view
    * Step 2
    * Store the information in browser session storage
    */
      ig.memoriserPageSelectionIg = function () {
         //
         // Bind les énements pour chaque IG.
         // 
         var igRegionsId = {};

         igRegionsId = $(".a-IG").map(function (index, element) { return (element.id); });

         igRegionsId.map(function (index, element) {

            var IgRegionId$ = '#'.concat(element);
            apex.debug.message(C_LOG_DEBUG, 'Bind event gridpagechange tablemodelviewpagechange id:', IgRegionId$);

            $(IgRegionId$).on("gridpagechange tablemodelviewpagechange", function (event, data) {
               var C_LOG_DEBUG = apex.debug.LOG_LEVEL.INFO;
               var initInfo, sel,
                  ig$ = $(this),
                  regionId = this.id, // not exactly the region id but in the spirt of the regionId option of getScopedSessionStorage
                  store = apex.storage.getScopedSessionStorage({ usePageId: true, regionId: regionId }),
                  viewId = ig$.interactiveGrid("getCurrentViewId");

               if (viewId.match(/icon|grid|detail/)) {
                  if (data.count === null) {
                     store.setItem(viewId + "LastPage", data.offset + ":0");
                  }
                  else {
                     store.setItem(viewId + "LastPage", data.offset + ":" + data.count);
                  }
                  // Also part of step 3 restore the selection
                  initInfo = gInitialPages[regionId] && gInitialPages[regionId][viewId];
                  if (initInfo && initInfo.sel) {
                     sel = initInfo.sel;
                     ig$.interactiveGrid("setSelectedRecords", sel.split("|"));
                     delete initInfo.sel;
                  }
               }
            });

            apex.debug.message(C_LOG_DEBUG, 'Bind event interactivegridselectionchange id:', IgRegionId$);
            $(IgRegionId$).on("interactivegridselectionchange", function (event, data) {
               var initInfo, sel, model,
                  ig$ = $(this),
                  regionId = this.id, // not exactly the region id but...
                  store = apex.storage.getScopedSessionStorage({ usePageId: true, regionId: regionId }),
                  view = ig$.interactiveGrid("getCurrentView"),
                  viewId = view.internalIdentifier;

               if (viewId.match(/icon|grid/)) {
                  model = view.model;
                  var lastPage = store.getItem(viewId + "LastPage");
                  initInfo = gInitialPages[regionId] && gInitialPages[regionId][viewId];
                  initInfo = initInfo === undefined ? {} : initInfo;
                  //
                  // Équivalent du P39_SELECTION_OVERRIDE mais pour la page 1
                  // 
                  if ($nvl(initInfo.sel === undefined ? false : initInfo.sel, false) && initInfo.offset === 0) {
                     sel = initInfo.sel;
                     lastPage = null;
                  } else {
                     sel = ig$.interactiveGrid("getSelectedRecords").map(function (r) { return model.getRecordId(r); }).join("|");
                  }
                  store.setItem(viewId + "LastSelection", sel);
                  if (lastPage === null) {
                     var nbRecPage = view.view$.grid("option", "rowsPerPage");
                     var dataEvent = { offset: 0, count: nbRecPage };
                     var IgRegionId$ = '#'.concat(regionId);
                     apex.event.trigger($(IgRegionId$), "gridpagechange", dataEvent);
                  }
                  apex.debug.message(C_LOG_DEBUG, "SAVED selection change: ", regionId, viewId, sel);
               }

            });
         });
      };

      /*
       * Step 3
       * Restore the IG page (row offset really) when IG view widgets are initalized.
       * See code above for how the session store info was gathered and made available for this step.
       */
      /*
       * The grid and tableModelView widgets just don't let you initialize them
       * with a starting offset. They always start at 0. This is a problem for
       * returning to a specific page. (See comments below on the first failed attempt that lead to this solution)
       * Extend the widgets in-place to allow setting an initial offset
       * Needs to happen after interactiveGrid and related widgets are loaded but before they are initalized
       *
       * Warning: using undocumented internal properties of the grid and tableModelView widgets.
       */

      $(function () {

         $.widget("apex.grid", $.apex.grid, {
            refresh: function (focus) {
               var regionId, initInfo;
               // if this grid is in an IG view
               if (this.element.hasClass("a-IG-gridView")) {
                  regionId = this.element.closest(".a-IG")[0].id; // id of IG region
                  initInfo = gInitialPages[regionId] && gInitialPages[regionId].grid;

                  if (initInfo && initInfo.offset) {

                     this.pageOffset = initInfo.offset;
                     delete initInfo.offset;
                     if (this.pageOffset > 0) {
                        // Workaround a failed assumption in the model that the first request
                        // will be for offset 0.
                        // Warning using undocumented member _data.
                        var igLenght = this.model._data.length === 0 ? 1 : this.model._data.length;
                        this.model._data.length = 1;
                        this.model._data.length = igLenght;
                     }
                     apex.debug.message(C_LOG_DEBUG, "RESTORE page offset", regionId, "grid", this.pageOffset, this.pageSize, "Sélection", initInfo.sel);
                  }
               }

               this._super(focus);
            }
         });
         $.widget("apex.tableModelView", $.apex.tableModelView, {
            refresh: function (focus) {
               var regionId, initInfo, viewId, key;

               // table model view is used for both icon view and detail view so figure out which one this instance is
               if (this.element.hasClass("a-IG-iconView")) {
                  viewId = "icon";
               } else if (this.element.hasClass("a-IG-detailView")) {
                  viewId = "detail";
               }
               if (viewId) {
                  key = viewId;
                  regionId = this.element.closest(".a-IG")[0].id; // id of IG region
                  initInfo = gInitialPages[regionId] && gInitialPages[regionId][key];
                  if (initInfo && initInfo.offset) {
                     this.pageOffset = initInfo.offset;
                     delete initInfo.offset;
                     if (this.pageOffset > 0) {
                        // Workaround a failed assumption in the model that the first request
                        // will be for offset 0.
                        // Warning using undocumented member _data.
                        this.model._data.length = 1;
                     }
                  }
               }
               this._super(focus);
            }
         });
      });

      // return app namespace
      return {
         memoriserPageSelectionIg: ig.memoriserPageSelectionIg
      };
   });

   ig.inactiverEnteteColonne = function (config) {
      config.defaultGridColumnOptions = config.defaultGridColumnOptions || {};
      // 
      // Désactive la sélection de l'entête de colonne 
      //       
      var noHeaderColonne = {
         noHeaderActivate: true,
      };

      $.extend(config.defaultGridColumnOptions, noHeaderColonne);
      return config;
   };
   /*
   /   Fonction qui permet de fixer le collapsable d'un groupement 
   */
   ig.DeactivercollapsableControlBreak = function (config) {
      config.defaultGridViewOptions = {
         collapsibleControlBreaks: false
      };

      return config;
   };
   /*
   /  Fonction qui permet d'afficher des minutes en heures formatté 99:99
   */
   ig.appliquerFormatHeure = function (staticId) {

      function padTo2Digits(num) {
         return num.toString().padStart(2, '0');
      }

      apex.item.create(staticId, {
         displayValueFor: function (value) {

            const totalMinutes = value;
            const minutes = totalMinutes % 60;
            const hours = Math.floor(totalMinutes / 60);

            return `${padTo2Digits(hours)}:${padTo2Digits(minutes)}`;
         }
      });
   };
})(shq.ig, shq, apex.theme42, apex.jQuery);