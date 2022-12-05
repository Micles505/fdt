/* eslint-disable no-unused-vars */
/* global apex */

/* 

-  Dans l'option de la page Execute when Page Loads 
 
   shq.ig.action.asynMenugrilleShq ("static id de la grid" , "Code de menu");
   
   Exemple:
   shq.ig.action.asynMenugrilleShq ('repertoireCode','GPR_CLIENT')
     
*/


var shq = shq || {};
shq.ig = shq.ig || {};
shq.ig.action = {};

(function (actionGridMenu, apex, $) {
   "use strict";

   var C_LOG_DEBUG = apex.debug.LOG_LEVEL.INFO;
   var C_DIESE = '#';

   actionGridMenu.initialiserColoneMenu = function (options) {

      options.defaultGridColumnOptions = options.defaultGridColumnOptions || {};
      options.heading = options.heading || {};
      options.features = options.features || {};

      var optionColone = {
         seq: 1,
         headingAlignment: "center",
         noStretch: true,
         noHeaderActivate: true,
         width: "40px",
         canHide: false,
         heading: "",
         columnCssClasses: "has-button",
         alignment: "center",
         resizeColumns: false,
         usedAsRowHeader: false,
         canSort: false
      };
      var optionHeading = {
         label: "Menu enregistrement"
      };

      var optionFeatures = {
         canHide: false
      };

      $.extend(options.defaultGridColumnOptions, optionColone);
      $.extend(options.heading, optionHeading);
      $.extend(options.features, optionFeatures);

      apex.debug.message(C_LOG_DEBUG, 'initialiserColoneMenu', optionColone);
      apex.debug.message(C_LOG_DEBUG, 'initialiserColoneMenu', optionHeading);
      apex.debug.message(C_LOG_DEBUG, 'initialiserColoneMenu', optionFeatures);

      return options;
   };

   var _creerMarkupGrilleShqMenu = function (igMenuActionShq) {

      var divDataMenu = $("<div>");
      divDataMenu.attr("id", igMenuActionShq);
      divDataMenu.css("display", "none");
      divDataMenu.attr("tabindex", "-1");
      divDataMenu.attr("role", "menu");

      var divBody = $("body");
      // divBody.append(divDataMenu);
   };

   var _initialiserGrid = function (pRegionStaticId) {
      // Interactive Grid            
      var grid = apex.region(pRegionStaticId).call('getViews', 'grid');
      var gridObject = {
         grid: grid,
         record: null,
         fields: grid.model.getOption("fields"),
         recordId: null
      };
      return gridObject;
   };

   var _obtenirValeurColonesIg = function (gridObject) {
      var coloneGrids = [];

      $.each(gridObject.fields, function (index, val) {
         var coloneGrid = {
            nomColone: val.property,
            valeurColone: gridObject.grid.model.getRecordValue(gridObject.recordId, val.property)
         };
         coloneGrids.push(coloneGrid);
      });
      apex.debug.message(C_LOG_DEBUG, '_obtenirValeurColonesIg', coloneGrids);
   };

   actionGridMenu.asynMenugrilleShq = function (pRegionStaticId, pGridActionCode) {

      var C_IG_ROW_ACTION = '_ig_row_actions_menu';

      var igMenuActionShq = pRegionStaticId + "_ig_row_actions_menu",
         $igMenuActionShq = "#" + igMenuActionShq,
         $pRegionStaticId = '#'.concat(pRegionStaticId),
         igBody = '.a-IG-body';

      $($pRegionStaticId).on('click', '.js-menuButton', function (event) {
         //
         // Pas compatible ie
         // var targetMenuButton = event.target.closest("button");
         //
         var targetMenuButton = $(event.target).parent();
         var record = gridObject.grid.getContextRecord(targetMenuButton)[0];

         gridObject.record = record;
         //
         // Pas compatible ie
         //gridObject.recordId = $(targetMenuButton).closest('tr').data("id");
         // 
         gridObject.recordId = $(targetMenuButton).parents("tr:first").attr("data-id");
         // Logging
         apex.debug.message(C_LOG_DEBUG, 'asynMenugrilleShq - event.target', targetMenuButton);

      });

      var gridObject = _initialiserGrid(pRegionStaticId);


      //
      //      Ce code ne fonctionne pas pour une grille en maitre-detail...la grid detail le editable est à faux.
      //      Moi et Maxime on est en réflexion....
      //         
      //      if (gridObject.grid.model.getOption("editable") === false ) {
      //            _creerMarkupGrilleShqMenu(igMenuActionShq);
      //         $($igMenuActionShq).menu({
      //            items: [{ id: 'vide' }],
      //            create: function (event, ui) {
      //               apex.debug.message(C_LOG_DEBUG, "_initialiserGrid - Create menu", igMenuActionShq);
      //            }
      //         });
      //      }

      $($igMenuActionShq).menu(
         {
            asyncFetchMenu: function (menu, callback) {

               var processGrilleAction = 'APX - Grille action';

               console.log(gridObject.recordId);

               _obtenirValeurColonesIg(gridObject);

               if (!gridObject.grid.model.getRecordMetadata(gridObject.recordId).inserted) {
                  var promise = apex.server.process(processGrilleAction, {
                     x01: pGridActionCode,
                     x02: gridObject.recordId
                  });

                  apex.debug.message(C_LOG_DEBUG, "asyncFetchMenu", pGridActionCode, gridObject.recordId);

                  promise.done(function (data) {
                     // 
                     // Suppression des items de menu SHQ pour s'assurer d'avoir les items de menu correspondant à la ligne
                     // 
                     var nombreitemsMenu = menu.items.length;

                     menu.items.slice().reverse().forEach(function (currentValue, index, arr) {
                        if (currentValue.id && currentValue.id.indexOf('shq_') === 0) {
                           menu.items.splice(arr.length - 1 - index, 1);
                        }
                     });
                     // 
                     // Ajour des items de menu SHQ de la ligne en cours
                     // 
                     data.items.slice().reverse().forEach(function (currentValue, index, array) {
                        switch (currentValue.attr.positionType) {
                           case 'TOP':
                              menu.items.unshift(currentValue.item);
                              break;
                           default:
                        }
                     });

                     data.items.forEach(function (currentValue, index, array) {
                        switch (currentValue.attr.positionType) {
                           case 'BOTTOM':
                              menu.items.push(currentValue.item);
                              break;
                           default:
                        }
                     });

                     // 
                     apex.debug.message(C_LOG_DEBUG, "menu", menu);
                     //
                     // Retour du callback
                     //
                     callback();
                  }).fail(function (jqXHR, textStatus) {
                     // handle error         
                     apex.debug.error('Erreur  dans la function _obtenirGrilleShqMen Callback: ' + textStatus);
                     callback(false);
                  }).always(function () {
                     // code that needs to run for both success and failure cases
                  });
               }
               else {
                  //
                  // Simulation du code asynchrone 
                  // Pour un insertion d'un nouvel enregistrement on ne désire pas faire un hit au serveur.
                  // 
                  setTimeout(function () { callback(); }, 0);
               }
            }
         }
      );
   };

   actionGridMenu.gridMenuAction = function () {
      
      const C_IG_ROW_ACTION = '_ig_row_actions_menu';
      const igBody = '.a-IG-body';

      $('.t-Region[data-menu-grid]').each(function (index, element) {

         let gridMenu = {};
         gridMenu.staticId = element.id;
         gridMenu.$staticId = C_DIESE.concat(gridMenu.staticId);
         gridMenu.idMenuActionshq = gridMenu.staticId.concat(C_IG_ROW_ACTION);
         gridMenu.$idMenuActionshq = C_DIESE.concat(gridMenu.idMenuActionshq);
         gridMenu.actionCode = $(element).data("menu-grid");
          
         let gridObject = _initialiserGrid(gridMenu.staticId);

         $(gridMenu.$staticId).on('click', '.js-menuButton', function (event) {
            //
            // Pas compatible ie
            // var targetMenuButton = event.target.closest("button");
            //
            
            var targetMenuButton = $(event.target).parent();
            var record = gridObject.grid.getContextRecord(targetMenuButton)[0];
            
            gridObject.record = record;
            //
            // Pas compatible ie
            gridObject.recordId = $(targetMenuButton).closest('tr').data("id");
            // 
            //gridObject.recordId = $(targetMenuButton).parents("tr:first").attr("data-id");
            // Logging
            apex.debug.message(C_LOG_DEBUG, 'asynMenugrilleShq - event.target', targetMenuButton);
         });

         $(gridMenu.$idMenuActionshq).menu(
            {
               asyncFetchMenu: function (menu, callback) {
                  
                  var processGrilleAction = 'APX - Grille action';
   
                  console.log(gridObject.recordId);
   
                  _obtenirValeurColonesIg(gridObject);
   
                  if (!gridObject.grid.model.getRecordMetadata(gridObject.recordId).inserted) {
                     var promise = apex.server.process(processGrilleAction, {
                        x01: gridMenu.actionCode,
                        x02: gridObject.recordId
                     });
   
                     apex.debug.message(C_LOG_DEBUG, "asyncFetchMenu", gridMenu.actionCode, gridObject.recordId);
   
                     promise.done(function (data) {
                        // 
                        // Suppression des items de menu SHQ pour s'assurer d'avoir les items de menu correspondant à la ligne
                        // 
                        var nombreitemsMenu = menu.items.length;
   
                        menu.items.slice().reverse().forEach(function (currentValue, index, arr) {
                           if (currentValue.id && currentValue.id.indexOf('shq_') === 0) {
                              menu.items.splice(arr.length - 1 - index, 1);
                           }
                        });
                        // 
                        // Ajour des items de menu SHQ de la ligne en cours
                        // 
                        data.items.slice().reverse().forEach(function (currentValue, index, array) {
                           switch (currentValue.attr.positionType) {
                              case 'TOP':
                                 menu.items.unshift(currentValue.item);
                                 break;
                              default:
                           }
                        });
   
                        data.items.forEach(function (currentValue, index, array) {
                           switch (currentValue.attr.positionType) {
                              case 'BOTTOM':
                                 menu.items.push(currentValue.item);
                                 break;
                              default:
                           }
                        });
   
                        // 
                        apex.debug.message(C_LOG_DEBUG, "menu", menu);
                        //
                        // Retour du callback
                        //
                        callback();
                     }).fail(function (jqXHR, textStatus) {
                        // handle error         
                        apex.debug.error('Erreur  dans la function _obtenirGrilleShqMen Callback: ' + textStatus);
                        callback(false);
                     }).always(function () {
                        // code that needs to run for both success and failure cases
                     });
                  }
                  else {
                     //
                     // Simulation du code asynchrone 
                     // Pour un insertion d'un nouvel enregistrement on ne désire pas faire un hit au serveur.
                     // 
                     setTimeout(function () { callback(); }, 0);
                  }
               }
            }
         );         
      });

      


   


      //
      //      Ce code ne fonctionne pas pour une grille en maitre-detail...la grid detail le editable est à faux.
      //      Moi et Maxime on est en réflexion....
      //         
      //      if (gridObject.grid.model.getOption("editable") === false ) {
      //            _creerMarkupGrilleShqMenu(igMenuActionShq);
      //         $($igMenuActionShq).menu({
      //            items: [{ id: 'vide' }],
      //            create: function (event, ui) {
      //               apex.debug.message(C_LOG_DEBUG, "_initialiserGrid - Create menu", igMenuActionShq);
      //            }
      //         });
      //      }

      
   };
})(shq.ig.action, apex, apex.jQuery);