/* global apex */
/* global CKEDITOR */

//UNE MODIF POUR COMMIT 3
var shq = shq || {};
shq.cke = {};

(function (cke, shq, ut, $) {
    //#region CONSTANTES
    /* NON SUPPORTER SUR ES6
    const UNDEFINED = "undefined";
    const EXTRA_PLUGINS_STR = ["mentions","textwatcher","autocomplete"];
    const WIDGET_NAME = "AutoCompleteWidget";
    const AUTO_COMPLETE_PLUG_IN_NAME = "autocomplete";
    const AUTO_COMPLETE_CO_BINDING_TAG = "TestCodeName";
    const TEST_CODE = "TestCo"; // TODO:  enlever quand apex prendra plus cette constante la pour parametre, mais plutot le value du champs CO (la il est null à l'init) 
    */
    //#endregion
    //#region Related Functions
    //Obligatoirement lancé dans le bloc d'initialisation de la COMPOSANTE CKEDITOR avant de pouvoir instancié le widgets avec "createAutoCompleteWidgets".

    cke.UNDEFINED = "undefined";
    cke.EXTRA_PLUGINS_STR = ["mentions","textwatcher","autocomplete"];
    cke.WIDGET_NAME = "shq_widgets.AutoCompleteWidget"; //TODO: ENLEVER le widget à la fin et aller changer les string des appèles dans apex
    cke.AUTO_COMPLETE_TAG = "autocomplete";
    cke.TEST_CODE = "TestCo";
    
    //Obligatoirement lancé de le bloc d'initialisation des CKE pour les préparer à l'initialisation.
    cke.initAutoCompletePlugInCKE = function(editorOptions,autoCompCodeNoSeq)
    {
        for(var i in cke.EXTRA_PLUGINS_STR)
        {
            editorOptions.extraPlugins += ","+ cke.EXTRA_PLUGINS_STR[i];
        }
        $("#"+editorOptions.itemName).data(cke.AUTO_COMPLETE_TAG,autoCompCodeNoSeq);
    };
    //Obligatoirement lancé dans le bloc d'initialisation de la PAGE pour instancié les widget.
    cke.createAutoCompleteWidgets = function(ckeGetDataProcessName)
    {
        function scopeFunction(){
            var asyncInstance = editors[instance];
            asyncInstance.on("instanceReady",function(evt){initFn(evt,asyncInstance);});
        }

        if (typeof(CKEDITOR) != cke.UNDEFINED)
        { 
            var editors = CKEDITOR.instances;
            for(var instance in editors)
            {
                scopeFunction();
                
            }
        }

        
        var initFn = function(ckeInst,pAsyncInstance){ //TODO: ya moyen d'utilisé juste la première je pense ici
            //Verifying that we want an auto-complete on this CKEDITOR instance by looking for the JQuery appropriate attribute. . .
            var pluginList = editors[instance].config.extraPlugins.split(",");
            console.log(pluginList);
            //if (pluginList.indexOf(cke.AUTO_COMPLETE_TAG) >= 0)
            if (typeof($("#"+instance).data(cke.AUTO_COMPLETE_TAG)) != cke.UNDEFINED)
            {
                //If found, i Create an auto-complete widget. . .
                console.log("Contient le tag autocomplete, j'instance un widget");
                $("#"+ckeInst.editor.name).AutoCompleteWidget({ckeDataProcessName : ckeGetDataProcessName, ckeInst : pAsyncInstance});
            }
            else {
                //ERROR:
                console.log("Ne contient pas le tag autocomplete");
            } 
        };
    };

    //Obligatoirement créer une action dynamic "OnChange" sur les CHAMP dont la valeur représente le CODE à utilisé pour filtré les suggestions des autocompletes.
    //Permet de garder à jour le filtre de suggestions.
    cke.updateAutoCompCodeNoSeq = function(newCode){

        if (typeof(CKEDITOR) != cke.UNDEFINED)
        { 
            var editors = CKEDITOR.instances;
            for(var instance in editors)
            {
               if (typeof($("#"+instance).data(cke.AUTO_COMPLETE_TAG)) != cke.UNDEFINED)
                {
                    //If found, i Update the code value. . .
                    console.log("Contient le tag autocomplete, je l'update");
                    var a = $("#"+instance).data("shq_widgets-AutoCompleteWidget");
                    a.setCodeNoSeq(newCode);
                }
                else {
                    //ERROR:
                    console.log("Ne contient pas le tag autocomplete");
                } 
            }
        }
    };
    //#endregion
    //#region WIDGET_DEFINITION
    $.widget(cke.WIDGET_NAME, {
        jsonData: cke.UNDEFINED,
        options: {
            ckeInst: cke.UNDEFINED,
            ckeDataProcessName: cke.UNDEFINED,
            textTestCallback: function (range) 
            {
                if (!range.collapsed){ return null; }

                return CKEDITOR.plugins.textMatch.match(range, matchCallback);
                function matchCallback(text, offset) 
                {
                    //var pattern = /\#[A-z]*/gi;
                    var pattern = /(\#)[A-z]*(?!.*\1)/i;
                    var match   = text.slice(0, offset).match(pattern);

                    if (!match){ return null; }

                    return {
                        start: match.index,
                        end: offset
                    };
                }
            },
            dataCallback: function (matchInfo, callback) 
            {
                var query = matchInfo.query.substring( 1 );//matchInfo.query.toLowerCase() //Probablement besoin de faire une propriété privé alimenter par une options au moment du init
                var data = jsonData.jsonParam.filter( 
                    function(item) {
                        //var itemName = '[[' + item.NAME + ']]';
                        return item.name.indexOf(query) == 0;
                    }
                );
                callback(data);
            },
            itemTemplate : '<li data-id="{id}">{name}</li>',
            outputTemplate : '#{name}#',//<span>&nbsp;</span>',            
        },
        _init: function () 
        {
            // Executed Before _create()
        },
        _create: function () 
        {
           // Executed after _init()
            //Preparing the data
           this._getData();

           var autocomplete = new this.window[0].CKEDITOR.plugins.autocomplete(this.options.ckeInst.widgets.editor, {
            textTestCallback: this.options.textTestCallback,
            dataCallback: this.options.dataCallback,
            itemTemplate: this.options.itemTemplate,
            outputTemplate: this.options.outputTemplate
            });

            // Override default getHtmlToInsert to enable rich content output.
            autocomplete.getHtmlToInsert = function(item) {
                return this.outputTemplate.output(item);
            };
        },		
        // Fait appel au process apex pour récupérer les donnés dans la base de donnés avec une fonction PL/SQL.
        _getData: function()
        {
            var autoCompleteCo_Val = $("#"+this.options.ckeInst.widgets.editor.name).data(cke.AUTO_COMPLETE_TAG);
            if (typeof(autoCompleteCo_Val) != cke.UNDEFINED)
            {
                console.log("Et le data attribute vaux : " + autoCompleteCo_Val);
                //Appel au process. . .
                var result = apex.server.process( this.options.ckeDataProcessName, { x01 : $("#"+this.element[0].name).data(cke.AUTO_COMPLETE_TAG)} );
                //Réaction conséquente. . .
                result.done( function( data ) { 
                    // return le value
                    console.log("Le Widget a reussis a fetch du data");
                    console.log(data);
                    jsonData = data;
                } ).fail(function( jqXHR, textStatus, errorThrown )  { 
                    // handle error 
                    //ERROR:
                    console.log("Le Widget a fail a fetch du data");
                    console.log(jqXHR);
                    console.log(textStatus);
                    console.log(errorThrown);
                } ).always( function() { 
                    // code that needs to run for both success and failure cases 
                    console.log("au moin on c'est rendue a la requete. . .");
                } );
            }
            else {
                console.log("Le data attribute pour le CO n'est pas la . . .");
                //ERROR:
            }
        },
        //Permet de changer le Code après l'initialisation!
        setCodeNoSeq: function(newCode)
        {
			var diese = '#';
			
            //TODO: AJOUTER UN PARAMETRE QUI CORRESPONDRAIT A L'ITEM DE LA PAGE POUR METTRE A JOUR LA VALEUR DU CODE et ensuite relancer le fetch de data
            $(diese+this.options.ckeInst.widgets.editor.name).data(cke.AUTO_COMPLETE_TAG,newCode);
            this._getData();
        }
    });
    //#endregion
})(shq.cke, shq, apex.theme42, apex.jQuery);