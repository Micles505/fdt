/* global apex */
/* global moment */
var shq = shq || {};
shq.item = {};

(function (item, shq, ut, $) {
   "use strict";
   //
   var C_LOG_DEBUG = apex.debug.LOG_LEVEL.INFO;
   var diese = '#';
   //
   // Utiliser cette fonction à la place de repeat car pas supporté dans IE...c'est vraiment un cancer celui-là
   //
   function repeatStringNumTimes(string, times) {
      var repeatedString = "";
      while (times > 0) {
         repeatedString += string;
         times--;
      }
      return repeatedString;
   }

   item.appliquerMasque = function () {
      shq.item.appliquerMasqueTelephone();
      shq.item.appliquerMasqueCourriel();
      shq.item.appliquerMasqueDate();
      shq.item.appliquerMasqueHeure();
      shq.item.appliquerMasqueCodePostal();
      shq.item.appliquerMasqueCodeDebutAlpha();
      shq.item.appliquerMasqueCodeAlphaNum();
      shq.item.appliquerMasqueCodeNum();
      shq.item.appliquerMasqueCodeAlpha();
      shq.item.appliquerMasqueTvq();
      shq.item.appliquerMasqueTps();
      shq.item.appliquerMasqueMontantAucuneDecimal();
      shq.item.appliquerMasqueMontantDeuxDecimal();
      shq.item.appliquerMasquePourcentage();
      shq.item.appliquerMasquePourcentageSansSigne();
      shq.item.appliquerMasqueNumeriqueDeuxDecimales();
      shq.item.appliquerMasqueNumeriqueSansDecimal();
   };
   //
   //
   //
   item.validerDate = function (dateItem) {
      var item$ = $(diese.concat(dateItem));
      var l_dateFormat = 'YYYY-MM-DD';
      var l_dateValue = item$.val();
      // Valide la date 
      return moment(l_dateValue, l_dateFormat, true).isValid();
   };
   //
   // Applique le masque heure 
   //
   item.appliquerMasqueHeure = function (listeItems) {

      var l_item;

      var DEBUTAM = 'DAM',
         DEBUTPM = 'DPM',
         FINAM = 'FAM',
         FINPM = 'FPM',
         HEUREPLUSUNEJOURNEE = 'HPUJ',
         HEUREPLUSUNEJOURNEENEGATIVE = 'HPUJNEG',
         HEUREPLUSUNEJOURNEEACTIVITE = 'HAUJ',
         HEUREPLUSUNEJOURNEENEGATIVEACTIVITE = 'HAUJNEG',
         NEGATIVE = 'HNEG';



      var completerHeureSaisie = function (heure) {
         //
         //  Formatteur la partir heure, "padder" à gauche avec un zéro
         // 
         apex.debug.message(C_LOG_DEBUG, 'Fomatter Heure');

         var ArrayHeure = heure.split(':');

         if (ArrayHeure.length === 2) {

            apex.debug.message(C_LOG_DEBUG, 'Entre dans le if length 2');

            if ((/[1-2]/).test(ArrayHeure[0].length) && ArrayHeure[1].length === 2) {

               apex.debug.message(C_LOG_DEBUG, 'Entre dans le if mettre 0');

               var valeurHeure = ArrayHeure[0];

               var partieHeure;

               switch (valeurHeure.length) {
                  case 1:
                     partieHeure = '0';
                     break;

                  case 2:
                     if (/^-/.test(valeurHeure)) {
                        partieHeure = '-0';
                     } else if (/^0/.test(valeurHeure)) {
                        partieHeure = '0';
                     } else {
                        partieHeure = valeurHeure;
                     }
                     break;
                  default:
                     partieHeure = valeurHeure;
               }

               var valeurMinutes = ArrayHeure[1];

               valeurHeure = valeurHeure.replace(/^(-0|0|-)/, '');
               partieHeure = valeurHeure.length === 1 ? partieHeure + valeurHeure : partieHeure;
               heure = partieHeure.concat(':' + valeurMinutes);

               apex.debug.message(C_LOG_DEBUG, 'valeurHeure heureComplete : ' + heure);
            }
         }

         return heure;
      };

      var shqHeureTranslation = {

         "A": { pattern: /[0-2]/, optional: true },
         "B": { pattern: /[0-9]/, optional: false },
         "C": { pattern: /[0-5]/, optional: false },
         "D": { pattern: /[0-9]/, optional: false },
         "E": { pattern: /[0-3]/, optional: false },
         "F": { pattern: /[0-2]/, optional: false },
         "G": { pattern: /[1-9]/, optional: false },
         "H": { pattern: /[0-1]/, optional: false },
         "I": { pattern: /[2-9]/, optional: false },
         "J": { pattern: /[0-9]/, optional: true },
         "K": { pattern: /[7-9]/, optional: false },
         "M": { pattern: /-/, optional: true },
         "N": { pattern: /[0-3]/, optional: true },
         "O": { pattern: /[0-9]/, optional: true }
      };

      var SPMaskBehavior = function (val) {
         apex.debug.message(C_LOG_DEBUG, 'SPMaskBehavior', val);
         return val.replace(/\D/g, '')[0] === '2' ? 'AE:CD' : 'AB:CD';
      },
         SPMaskBehaviorNegative = function (val) {
            apex.debug.message(C_LOG_DEBUG, 'SPMaskBehaviorNegative', val);
            return val.replace(/\D/g, '')[0] === '2' ? 'MAN:CD' : 'MAO:CD';
         },
         spOptions = {
            onKeyPress: function (val, e, field, options) {
               field.mask(SPMaskBehavior.apply({}, arguments), options);
               var valArray = val.split(":");
               if (valArray.length == 2) {
                  field.val(completerHeureSaisie(val));
               }
            },
            translation: shqHeureTranslation,
            recursive: true
         },
         spOptionsNegative = {
            onKeyPress: function (val, e, field, options) {
               field.mask(SPMaskBehaviorNegative.apply({}, arguments), options);
               var valArray = val.split(":");
               if (valArray.length == 2) {
                  field.val(completerHeureSaisie(val));
               }
            },
            onChange: function (value, e) {
               e.target.value = value.replace(/(?!^)-/g, '')
                  .replace(/^(-[:])/, '-')
                  .replace(/(\d+\:*)\:(\d{2})$/, "$1:$2");
            },
            translation: shqHeureTranslation,
            recursive: true
         },
         shqMaskPlusUneJournee = function (val) {
            var mask = 'JJ:CD';
            apex.debug.message(C_LOG_DEBUG, 'shqMaskPlusUneJournee', val);
            return mask;
         },
         spOptionsPlusUneJournee = {
            onKeyPress: function (val, e, field, options) {
               //
               // Applique le masque de saisie
               // 
               field.mask(shqMaskPlusUneJournee.apply({}, arguments), options);
               var valArray = val.split(":");

               switch (valArray.length) {
                  case 2:
                     field.val(completerHeureSaisie(val));
                     break;
               }
            },
            translation: shqHeureTranslation,
            recursive: true
         },
         shqMaskPlusUneJourneeNegative = function (val) {
            apex.debug.message(C_LOG_DEBUG, 'shqMaskPlusUneJourneeNegative', val);
            var mask = 'MJJ:CD';
            return mask;

         },
         spOptionsPlusUneJourneeNegative = {
            onKeyPress: function (val, e, field, options) {
               //
               // Applique le masque de saisie
               // 
               field.mask(shqMaskPlusUneJourneeNegative.apply({}, arguments), options);
               var valArray = val.split(":");

               switch (valArray.length) {
                  case 2:
                     field.val(completerHeureSaisie(val));
                     break;
               }
            },
            onChange: function (value, e) {
               e.target.value = value.replace(/(?!^)-/g, '')
                  .replace(/^(-[:])/, '-')
                  .replace(/(\d+\:*)\:(\d{2})$/, "$1:$2");
            },
            translation: shqHeureTranslation,
            recursive: true
         },
         /* 3 positions */
         shqMaskPlusUneJourneeActivite = function (val) {
            var mask = 'JJJ:CD';
            apex.debug.message(C_LOG_DEBUG, 'shqMaskPlusUneJourneeActivite', val);
            return mask;
         },
         spOptionsPlusUneJourneeActivite = {
            onKeyPress: function (val, e, field, options) {
               //
               // Applique le masque de saisie
               // 
               field.mask(shqMaskPlusUneJourneeActivite.apply({}, arguments), options);
               var valArray = val.split(":");

               switch (valArray.length) {
                  case 2:
                     field.val(completerHeureSaisie(val));
                     break;
               }
            },
            translation: shqHeureTranslation,
            recursive: true
         },
         shqMaskPlusUneJourneeNegativeActivite = function (val) {
            apex.debug.message(C_LOG_DEBUG, 'shqMaskPlusUneJourneeNegativeActivite', val);
            var mask = 'MJJJ:CD';
            return mask;

         },
         spOptionsPlusUneJourneeNegativeActivite = {
            onKeyPress: function (val, e, field, options) {
               //
               // Applique le masque de saisie
               // 
               field.mask(shqMaskPlusUneJourneeNegativeActivite.apply({}, arguments), options);
               var valArray = val.split(":");

               switch (valArray.length) {
                  case 2:
                     field.val(completerHeureSaisie(val));
                     break;
               }
            },
            onChange: function (value, e) {
               e.target.value = value.replace(/(?!^)-/g, '')
                  .replace(/^(-[:])/, '-')
                  .replace(/(\d+\:*)\:(\d{2})$/, "$1:$2");
            },
            translation: shqHeureTranslation,
            recursive: true
         },
         /* Fin 3 positions */
         shqMaskAm = function (val) {

            apex.debug.message(C_LOG_DEBUG, 'shqMaskDebutAm', val);
            var valeur = val.replace(/\D/g, '').split(":")[0];
            var mask;

            if (/^13/g.test(valeur)) {
               mask = 'H3:HC';
            } else if (/^1/.test(valeur)) {
               mask = 'HE:CD';
            } else if (/^0|[^[0-1]]/.test(valeur)) {
               mask = 'AK:CD';
            } else {
               mask = 'AD:CD';
            }
            return mask;
         },
         spOptionsShqHeureAm = {
            onKeyPress: function (val, e, field, options) {
               //
               // Appliquer le masque de saisie
               //
               field.mask(shqMaskAm.apply({}, arguments), options);
               // 
               // Valider la saisie DEBUTAM
               // 
               var valArray = val.split(":");


               switch (valArray.length) {
                  case 1:
                     var heureAm = valArray.slice(0, 2).join("");
                     apex.debug.message(C_LOG_DEBUG, 'heureDebutAm', heureAm);
                     if (/^[7-9]/.test(heureAm)) {
                        field.val(completerHeureSaisie(val));
                     } else if (!(/^[0-1]/.test(heureAm))) {
                        field.val("");
                     }
                     break;
                  case 2:
                     field.val(completerHeureSaisie(val));
                     break;
               }
            },
            translation: shqHeureTranslation,
            recursive: true
         },
         shqMaskPm = function (val) {
            apex.debug.message(C_LOG_DEBUG, 'shqMaskPm', val);
            var valeur = val.replace(/\D/g, '').split("");
            var heure;
            var mask;

            switch (valeur.length) {
               case 1:
                  heure = parseInt(valeur.slice(0, 1).join(""));
                  break;
               case 2:
                  heure = parseInt(valeur.slice(0, 2).join(""));
                  break;

            }
            switch (true) {
               case heure === 1:
                  mask = 'GI:CD';
                  break;
               case heure === 2 || heure > 19:
                  mask = 'FE:CD';
                  break;
               default:
                  mask = 'FD:CD';
            }
            return mask;
         },
         spOptionsShqHeurePm = {
            onKeyPress: function (val, e, field, options) {
               //
               // Appliquer le masque de saisie
               //
               field.mask(shqMaskPm.apply({}, arguments), options);
               // 
               // Valider la saisie DEBUTAM
               // 

               var valArray = val.split(":");
               var PATTERNHEUREPM = /^([1][2-9]|2[0-3])$/;

               switch (valArray.length) {
                  case 1:
                     var heurePm = valArray.slice(0, 2).join("");
                     apex.debug.message(C_LOG_DEBUG, 'heurePm', heurePm);
                     if (!PATTERNHEUREPM.test(heurePm) && heurePm.length === 2) {
                        field.val("");
                     }
                     break;
                  case 2:
                     field.val(completerHeureSaisie(val));
               }
            },
            translation: shqHeureTranslation,
            recursive: true
         };

      listeItems = listeItems === undefined ? '' : listeItems;

      if (listeItems.length === 0) {
         $('.shq-heure').each(function (i, val) {

            l_item = val.id;
            var item$ = $(diese.concat(l_item));
            //
            // Obtenir le data attribut sur l'item
            // 
            var indicateurHeure = $(item$).attr('data-heure');
            //
            //  Application du masque
            //     
            switch (indicateurHeure) {
               case DEBUTAM:
                  $(diese.concat(val.id)).mask(shqMaskAm, spOptionsShqHeureAm);
                  break;
               case FINAM:
                  $(diese.concat(val.id)).mask(shqMaskAm, spOptionsShqHeureAm);
                  break;
               case DEBUTPM:
                  $(diese.concat(val.id)).mask(shqMaskPm, spOptionsShqHeurePm);
                  break;
               case FINPM:
                  $(diese.concat(val.id)).mask(shqMaskPm, spOptionsShqHeurePm);
                  break;
               case HEUREPLUSUNEJOURNEE:
                  $(diese.concat(val.id)).mask(shqMaskPlusUneJournee, spOptionsPlusUneJournee);
                  break;
               case HEUREPLUSUNEJOURNEENEGATIVE:
                  $(diese.concat(val.id)).mask(shqMaskPlusUneJourneeNegative, spOptionsPlusUneJourneeNegative);
                  break;
               case HEUREPLUSUNEJOURNEEACTIVITE:
                  $(diese.concat(val.id)).mask(shqMaskPlusUneJourneeActivite, spOptionsPlusUneJourneeActivite);
                  break;
               case HEUREPLUSUNEJOURNEENEGATIVEACTIVITE:
                  $(diese.concat(val.id)).mask(shqMaskPlusUneJourneeNegativeActivite, spOptionsPlusUneJourneeNegativeActivite);
                  break;
               case NEGATIVE:
                  $(diese.concat(val.id)).mask(SPMaskBehaviorNegative, spOptionsNegative);
                  break;

               default:
                  $(diese.concat(val.id)).mask(SPMaskBehavior, spOptions);
            }

            //
            // Application de la validation generale d'une heure de saisie HTML5
            // 
            var l_regexp;
            if (indicateurHeure == HEUREPLUSUNEJOURNEE) {
               l_regexp = new RegExp(/^([0-9][0-9]):[0-5][0-9]$/);
            } else if (indicateurHeure === HEUREPLUSUNEJOURNEENEGATIVE) {
               l_regexp = new RegExp(/^-?([0-9][0-9]):[0-5][0-9]$/);
            } else if (indicateurHeure == HEUREPLUSUNEJOURNEEACTIVITE) {
               l_regexp = new RegExp(/^([0-9]?[0-9][0-9]):[0-5][0-9]$/);
            } else if (indicateurHeure === NEGATIVE) {
               l_regexp = new RegExp(/^-?([0-9]|0[0-9]|1[0-9]|2[0-3]):[0-5][0-9]$/);
            } else if (indicateurHeure === HEUREPLUSUNEJOURNEENEGATIVEACTIVITE) {
               l_regexp = new RegExp(/^-?([0-9]?[0-9][0-9]):[0-5][0-9]$/);
            } else {
               l_regexp = new RegExp(/^([0-9]|0[0-9]|1[0-9]|2[0-3]):[0-5][0-9]$/);
            }

            var l_message = apex.lang.formatMessage("SHQ.ITEM.HEURE_INVALID");

            if (item$.is('pattern') === false) {
               item$.attr('pattern', l_regexp.source);
               item$.attr('data-valid-message', l_message);
            }
         });
      }
      else {
         $.each(listeItems, function (i, val) {
            var selecteurTel = val.indexOf(diese, 0) === -1 ? diese.concat(val) : val;
            $(selecteurTel).mask(l_maskHeure);
         });
      }
   };
   //
   // Applique le masque code postal
   //
   item.appliquerMasqueCodePostal = function (listeItems) {
      listeItems = listeItems === undefined ? '' : listeItems;
      var l_maskCodePostal = "S0S 0S0";
      var optionsMask = {
         onKeyPress: function (value, event) {
            event.currentTarget.value = value.toUpperCase();
         }
      };

      if (listeItems.length === 0) {
         $('.shq-code-postal').each(function (i, val) {
            $(diese.concat(val.id)).mask(l_maskCodePostal, optionsMask);
            var l_item = val.id;
            var item$ = $(diese.concat(l_item));
            var itemLabel$ = $(diese.concat(l_item.concat('_LABEL')));
            var l_regexp = new RegExp(/[A-Za-z][0-9][A-Za-z] [0-9][A-Za-z][0-9]/);
            var l_message = apex.lang.formatMessage("SHQ.ITEM.CODE_POSTAL_INVALID");

            if (item$.is('pattern') === false) {
               item$.attr('pattern', l_regexp.source);
               item$.attr('data-valid-message', l_message);
            }
         });
      }
      else {
         $.each(listeItems, function (i, val) {
            var selecteurTel = val.indexOf(diese, 0) === -1 ? diese.concat(val) : val;
            $(selecteurTel).mask(l_maskCodePostal);
         });
      }
   };
   //
   // Applique le masque date
   //
   item.appliquerMasqueDate = function (listeItems) {
      listeItems = listeItems === undefined ? '' : listeItems;
      var l_maskDate = "0000-00-00";

      if (listeItems.length === 0) {
         $('.shq-date').each(function (i, val) {
            $(diese.concat(val.id)).mask(l_maskDate);
            var l_dateFormat = 'AAAA-MM-JJ';
            var l_item = val.id;
            var item$ = $(diese.concat(l_item));
            var l_itemDateFormat = item$.attr('placeholder') ? item$.attr('placeholder') : l_dateFormat;
            var itemLabel$ = $(diese.concat(l_item.concat('_LABEL')));
            var l_regexp = new RegExp(/(?:19|20)[0-9]{2}-(?:(?:0[1-9]|1[0-2])-(?:0[1-9]|1[0-9]|2[0-9])|(?:(?!02)(?:0[1-9]|1[0-2])-(?:30))|(?:(?:0[13578]|1[02])-31))/);
            var l_message = apex.lang.formatMessage("APEX.DATEPICKER_VALUE_INVALID", l_itemDateFormat).replace('#LABEL#', itemLabel$.text());

            if (item$.is('pattern') === false) {
               item$.attr('pattern', l_regexp.source);
               item$.attr('data-valid-message', l_message);
            }
         });
      }
      else {
         $.each(listeItems, function (i, val) {
            var selecteurDate = val.indexOf(diese, 0) === -1 ? diese.concat(val) : val;
            $(selecteurDate).mask(l_maskDate);
         });
      }
   };
   //
   // Applique le masque téléphonique 
   //
   item.appliquerMasqueTelephone = function (listeItems) {
      var l_mask_phone = '000 000-0000';
      listeItems = listeItems === undefined ? '' : listeItems;
      if (listeItems.length === 0) {
         $('.shq-telephone').each(function (i, val) {
            var l_item = val.id;
            var item$ = $(diese.concat(l_item));
            var itemLabel$ = $(diese.concat(l_item.concat('_LABEL')));
            var l_regexp = new RegExp(/\d{3} \d{3}[\-]\d{4}/);
            var l_message = apex.lang.formatMessage("SHQ.ITEM.PHONENUMBER_INVALID", l_mask_phone).replace('#LABEL#', itemLabel$.text());

            item$.mask(l_mask_phone);

            if (item$.is('pattern') === false) {
               item$.attr('pattern', l_regexp.source);
               item$.attr('data-valid-message', l_message);
            }
         });
      }
      else {
         $.each(listeItems, function (i, val) {
            var selecteurTel = val.indexOf(diese, 0) === -1 ? diese.concat(val) : val;
            $(selecteurTel).mask(l_mask_phone);
         });
      }
   };
   //
   // Applique le masque pour la saisie d'un courriel  
   // 
   item.appliquerMasqueCourriel = function (listeItems) {
      listeItems = listeItems === undefined ? '' : listeItems;
      if (listeItems.length === 0) {
         $('.shq-courriel').each(function (i, val) {
            var l_item = val.id;
            var item$ = $(diese.concat(l_item));
            var itemLabel$ = $(diese.concat(l_item.concat('_LABEL')));
            var l_regexp = new RegExp(/(?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*|"(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])*")@(?:(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\[(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21-\x5a\x53-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])+)\])/);

            item$.mask('A', {
               translation: {
                  'A': { pattern: /[\w@\-.+]/, recursive: true }
               }
            });

            var l_message = apex.lang.formatMessage("SHQ.ITEM.COURRIEL_INVALID").replace('#LABEL#', itemLabel$.text());
            if (item$.is('pattern') === false) {
               item$.attr('pattern', l_regexp.source);
               item$.attr('data-valid-message', l_message);
            }
         });
      }
      else {
         $.each(listeItems, function (i, val) {
            var selecteurCourriel = val.indexOf(diese, 0) === -1 ? diese.concat(val) : val;
            $(selecteurCourriel).mask('A', {
               translation: {
                  'A': { pattern: /[\w@\-.+]/, recursive: true }
               }
            });
         });
      }
   };
   //
   // Appliquer le masque pour la saisie Aucune décimal
   // 
   /*
     Options format monétaire
  */
   var MoneyOpts = {
      reverse: true,
      maxlength: false,
      placeholder: '0,00',
      onKeyPress: function (v, ev, curField, opts) {
         var mask = curField.data('mask').mask;
         var decimalSep = (/0(.)00/gi).exec(mask)[1] || ',';
         if (curField.data('mask-isZero') && curField.data('mask-keycode') == 8)
            $(curField).val('');
         else if (v) {
            // remove previously added stuff at start of string
            v = v.replace(new RegExp('^0*\\' + decimalSep + '?0*'), ''); //v = v.replace(/^0*,?0*/, '');
            v = v.length == 0 ? '0' + decimalSep + '00' : (v.length == 1 ? '0' + decimalSep + '0' + v : (v.length == 2 ? '0' + decimalSep + v : v));
            $(curField).val(v).data('mask-isZero', (v == '0' + decimalSep + '00'));
         }
      }
   };

   item.appliquerMasqueMontantAucuneDecimal = function (listeItems) {
      listeItems = listeItems === undefined ? '' : listeItems;
      if (listeItems.length === 0) {
         $('.shq-montant-aucune-decimal').each(function (i, val) {
            $(diese.concat(val.id)).mask(" 00 000 000", { reverse: true });
         });
      } else {
         $.each(listeItems, function (i, val) {
            var selecteurMontant = val.indexOf(diese, 0) === -1 ? diese.concat(val) : val;
            $(selecteurMontant).mask(" 00 000 000", { reverse: true });
         });
      }
   };
   //
   // Appliquer le masque pour la saisie deux décimales
   // 
   item.appliquerMasqueMontantDeuxDecimal = function (listeItems) {

      /* 
      * à compléter et valider pour les nombre ngatif 
      * 
     

      var sOptions = {
         reverse: true,
         translation: {
            'S': {
               pattern: /-|\d/,
               optional: true,
               recursive: true
            }
         },
         onChange: function (value, e) {

            var target = e.target,
               position = target.selectionStart; // Capture initial position

            target.value = value.replace(/(?!^)-/g, '').replace(/^,/, '').replace(/^-(,| )/, '-');
            target.selectionEnd = position; // Set the cursor back to the initial position.
         }
      };
 */
      // Mascara para Dinheiro e Decimais com Prefixo e Sinal negativo
      // Font base: https://github.com/igorescobar/jQuery-Mask-Plugin/issues/670 point to http://jsfiddle.net/c6qj0e3u/15/
      // Edited by: Pyetro
      // New feature: Check if field value is "0,00" and Backspace was pressed, so clean Val
      // Accept decimals "." or ","
      var MoneyOptsMinus = {
         reverse: true,
         maxlength: false,
         placeholder: '0,00',
         byPassKeys: [9, 16, 17, 18, 35, 36, 37, 38, 39, 40, 46, 91],
         eventNeedChanged: false,
         onKeyPress: function (v, ev, curField, opts) {
            var mask = curField.data('mask').mask;
            var decimalSep = (/0(.)00/gi).exec(mask)[1] || ',';

            opts.prefixMoney = typeof (opts.prefixMoney) != 'undefined' ? opts.prefixMoney : '';

            if (curField.data('mask-isZero') && curField.data('mask-keycode') == 8)
               $(curField).val('');
            else if (v) {
               var key = curField.data('mask-key');
               var minus = (typeof (curField.data('mask-minus-signal')) == 'undefined' ? false : curField.data('mask-minus-signal'));

               if (['-', '+'].indexOf(key) >= 0) {
                  curField.val((opts.prefixMoney) + (key == '-' ? key + v : v.replace(/^-?/, '')));
                  curField.data('mask-minus-signal', key == '-');
                  return;
               }

               // remove previously added stuff at start of string
               v = v.replace(new RegExp('^-?'), '');
               v = v.replace(new RegExp('^0*\\' + decimalSep + '?0*'), ''); //v = v.replace(/^0*,?0*/, '');
               v = v.length == 0 ? '0' + decimalSep + '00' : (v.length == 1 ? '0' + decimalSep + '0' + v : (v.length == 2 ? '0' + decimalSep + v : v));
               curField.val((opts.prefixMoney) + (minus ? '-' : '') + v).data('mask-isZero', (v == '0' + decimalSep + '00'));
            }
         }
      };

      var MoneyOptsPrefix = {};
      MoneyOptsPrefix = $.extend(true, {}, MoneyOptsPrefix, MoneyOptsMinus);
      MoneyOptsPrefix.prefixMoney = 'R$ ';

      listeItems = listeItems === undefined ? '' : listeItems;
      if (listeItems.length === 0) {
         $('.shq-montant-deux-decimal').each(function (i, val) {
            //$(diese.concat(val.id)).mask("#.##0,00", MoneyOptsMinus).keydown().keyup();
            $(diese.concat(val.id)).mask("#.##0,00", {reverse: true});
         });
      } else {
         $.each(listeItems, function (i, val) {
            var selecteurMontant = val.indexOf(diese, 0) === -1 ? diese.concat(val) : val;
            $(selecteurMontant).mask("#.##0,00", MoneyOptsMinus).keydown().keyup();
         });
      }
   };
   //
   // Appliquer le masque pour la saisie de pourcentage
   // 
   item.appliquerMasquePourcentage = function (listeItems) {
      listeItems = listeItems === undefined ? '' : listeItems;
      if (listeItems.length === 0) {
         $('.shq-pourcentage').each(function (i, val) {
            $(diese.concat(val.id)).mask("##0,00%", { reverse: true });
         });
      } else {
         $.each(listeItems, function (i, val) {
            var selecteurPourcent = val.indexOf(diese, 0) === -1 ? diese.concat(val) : val;
            $(selecteurPourcent).mask("##0,00%", { reverse: true });
         });
      }
   };
   //
   // Appliquer le masque pour la saisie de pourcentage sans signe %
   // 
   item.appliquerMasquePourcentageSansSigne = function (listeItems) {
      var sOptions = {
         reverse: true
      };

      listeItems = listeItems === undefined ? '' : listeItems;
      if (listeItems.length === 0) {
         $('.shq-pourcentage-sans-signe').each(function (i, val) {
            $(diese.concat(val.id)).mask("##0,00", sOptions);
         });
      } else {
         $.each(listeItems, function (i, val) {
            var selecteurPourcent = val.indexOf(diese, 0) === -1 ? diese.concat(val) : val;
            $(selecteurPourcent).mask("##0,00", sOptions);
         });
      }
   };
   //
   // Appliquer le masque pour le numerique 2 décimales
   // 
   item.appliquerMasqueNumeriqueDeuxDecimales = function (listeItems) {

      var sOptions = {
         reverse: true,
         translation: {
            'S': {
               pattern: /-|\d/,
               recursive: true
            }
         },
         onChange: function (value, e) {
            var target = e.target,
               position = target.selectionStart; // Capture initial position

            target.value = value.replace(/(?!^)-/g, '').replace(/^,/, '').replace(/^-(,| )/, '-');

            target.selectionEnd = position;
         }
      };

      listeItems = listeItems === undefined ? '' : listeItems;
      if (listeItems.length === 0) {
         $('.shq-numerique-2d').each(function (i, val) {
            $(diese.concat(val.id)).mask(" 00 000 000 009,99", sOptions);
         });
      } else {
         $.each(listeItems, function (i, val) {
            var selecteurPourcent = val.indexOf(diese, 0) === -1 ? diese.concat(val) : val;
            $(selecteurPourcent).mask(" 00 000 000 009,99", sOptions);
         });
      }
   };
   //
   // Appliquer le masque pour le numerique aucune decimal
   // 
   item.appliquerMasqueNumeriqueSansDecimal = function (listeItems) {

      var sOptions = {
         reverse: true,
         translation: {
            'S': {
               pattern: /-|\d/,
               recursive: false
            }
         },
         onChange: function (value, e) {
            var target = e.target,
               position = target.selectionStart; // Capture initial position

            target.value = value.replace(/(?!^)-/g, '').replace(/^,/, '').replace(/^-(,| )/, '-');

            target.selectionEnd = position;
         }
      };

      listeItems = listeItems === undefined ? '' : listeItems;
      if (listeItems.length === 0) {
         $('.shq-numerique-sans-decimal').each(function (i, val) {
            $(diese.concat(val.id)).mask(" 00 000 000 009", sOptions);
         });
      } else {
         $.each(listeItems, function (i, val) {
            var selecteurPourcent = val.indexOf(diese, 0) === -1 ? diese.concat(val) : val;
            $(selecteurPourcent).mask(" 00 000 000 009", sOptions);
         });
      }
   };
   //
   // Permet de changer le libellé d'un item APEX
   // 
   item.changerLibelle = function (nomItemApex, nouveauLiblle) {
      var selecteurLibelle = nomItemApex.concat('_LABEL');
      selecteurLibelle = selecteurLibelle.indexOf(diese, 0) === -1 ? diese.concat(selecteurLibelle) : selecteurLibelle;
      if (selecteurLibelle !== undefined) {
         $(selecteurLibelle).text(nouveauLiblle);
      } else {
         apex.debug.log('Impossible de changer le libellé ', nomItemApex);
      }
   };
   //
   // Uppercase 
   // 
   item.appliquerMajuscule = function (document) {
      $(document).on('change', '.shq-uppercase', function (event) {
         var eventTarget = event.target;
         var elementJqApex = "#" + $(eventTarget).attr("id");
         $(elementJqApex).val($(elementJqApex).val().toUpperCase());
      });
   };

   // Applique le masque pour le format de code suivant : Premier caractère -> majuscule, caractères suivants -> chiffres, majuscules, _, -
   item.appliquerMasqueCodeDebutAlpha = function (listeItems) {
      listeItems = listeItems === undefined ? '' : listeItems;

      var optionsMask = {
         translation: {
            'Z': {
               pattern: /[A-Za-z]+/,
               recursive: true
            },
            '0': {
               pattern: /[A-Za-z0-9_\-]+/,
               recursive: true
            }
         },
         onKeyPress: function (value, event) {
            event.currentTarget.value = value.toUpperCase();
         }
      };

      if (listeItems.length === 0) {
         $('.shq-code-debut-alpha').each(function (i, val) {
            var l_item = val.id;
            var item$ = $(diese.concat(l_item));
            var l_regexp = new RegExp('[A-Z]+[A-Z0-9_\-]*');
            var l_message = apex.lang.formatMessage("SHQ.ITEM.CODE_DEBUT_ALPHA_INVALID");

            item$.mask('Z' + repeatStringNumTimes('0', item$[0].maxLength - 1), optionsMask);
            //item$.mask('Z' + '0'.repeat(item$[0].maxLength - 1), optionsMask);

            if (item$.is('pattern') === false) {
               item$.attr('pattern', l_regexp.source);
               item$.attr('data-valid-message', l_message);
            }
         });
      }
      else {
         $.each(listeItems, function (i, val) {
            var selecteur = val.indexOf(diese, 0) === -1 ? diese.concat(val) : val;
            var item$ = $(selecteur);
            item$.mask('Z' + repeatStringNumTimes('0', item$[0].maxLength - 1), optionsMask);
            // item$.mask('Z' + '0'.repeat(item$[0].maxLength - 1), optionsMask);
         });
      }
   };

   // Applique le masque pour le format de code suivant : Premier caractère -> majuscule ou chiffre, caractères suivants -> chiffres, majuscules, _, -
   item.appliquerMasqueCodeAlphaNum = function (listeItems) {
      listeItems = listeItems === undefined ? '' : listeItems;

      var optionsMask = {
         translation: {
            'Z': {
               pattern: /[A-Za-z0-9]+/,
               recursive: true
            },
            '0': {
               pattern: /[A-Za-z0-9_\-]+/,
               recursive: true
            }
         },
         onKeyPress: function (value, event) {
            event.currentTarget.value = value.toUpperCase();
         }
      };

      if (listeItems.length === 0) {
         $('.shq-code-alpha-num').each(function (i, val) {
            var l_item = val.id;
            var item$ = $(diese.concat(l_item));
            var l_regexp = new RegExp('[A-Z0-9]+[A-Z0-9_\-]*');
            var l_message = apex.lang.formatMessage("SHQ.ITEM.CODE_ALPHA_NUM_INVALID");

            item$.mask('Z' + repeatStringNumTimes('0', item$[0].maxLength - 1), optionsMask);
            // item$.mask('Z' + '0'.repeat(item$[0].maxLength - 1), optionsMask);

            if (item$.is('pattern') === false) {
               item$.attr('pattern', l_regexp.source);
               item$.attr('data-valid-message', l_message);
            }
         });
      }
      else {
         $.each(listeItems, function (i, val) {
            var selecteur = val.indexOf(diese, 0) === -1 ? diese.concat(val) : val;
            var item$ = $(selecteur);
            item$.mask('Z' + repeatStringNumTimes('0', item$[0].maxLength - 1), optionsMask);
            // item$.mask('Z' + '0'.repeat(item$[0].maxLength - 1), optionsMask);
         });
      }
   };

   // Applique le masque pour le format de code suivant : Numéro de TVQ
   item.appliquerMasqueTvq = function (listeItems) {
      listeItems = listeItems === undefined ? '' : listeItems;

      var optionsMask = {
         translation: {
            'T': {
               pattern: /[t]|[T]/,
               fallback: 'T'
            },
            'Q': {
               pattern: /[Q]|[q]/,
               fallback: 'Q'
            }
         },
         onKeyPress: function (value, event) {
            event.currentTarget.value = value.toUpperCase();
         }
      };

      if (listeItems.length === 0) {
         $('.shq-code-tvq').each(function (i, val) {
            var l_item = val.id;
            var item$ = $(diese.concat(l_item));
            var l_regexp = new RegExp('([0-9]{10})(\T|\t)(\Q|\q)([0-9]{04})');
            var l_message = apex.lang.formatMessage("SHQ.ITEM.CODE_TVQ_INVALID");

            item$.mask('0000000000TQ0000', optionsMask);

            if (item$.is('pattern') === false) {
               item$.attr('pattern', l_regexp.source);
               item$.attr('data-valid-message', l_message);
            }
         });
      }
      else {
         $.each(listeItems, function (i, val) {
            var selecteur = val.indexOf(diese, 0) === -1 ? diese.concat(val) : val;
            var item$ = $(selecteur);

            item$.mask('0000000000TQ0000', optionsMask);

         });
      }
   };

   // Applique le masque pour le format de code suivant : Numéro de TVQ
   item.appliquerMasqueTps = function (listeItems) {
      listeItems = listeItems === undefined ? '' : listeItems;

      var optionsMask = {
         translation: {
            'R': {
               pattern: /[r]|[R]/,
               fallback: 'R'
            },
            'T': {
               pattern: /[t]|[T]/,
               fallback: 'T'
            }
         },
         onKeyPress: function (value, event) {
            event.currentTarget.value = value.toUpperCase();
         }
      };

      if (listeItems.length === 0) {
         $('.shq-code-tps').each(function (i, val) {
            var l_item = val.id;
            var item$ = $(diese.concat(l_item));
            var l_regexp = new RegExp('([0-9]{9})(R|r)(T|t)([0-9]{04})');
            var l_message = apex.lang.formatMessage("SHQ.ITEM.CODE_TPS_INVALID");

            item$.mask('000000000RT0000', optionsMask);

            if (item$.is('pattern') === false) {
               item$.attr('pattern', l_regexp.source);
               item$.attr('data-valid-message', l_message);
            }
         });
      }
      else {
         $.each(listeItems, function (i, val) {
            var selecteur = val.indexOf(diese, 0) === -1 ? diese.concat(val) : val;
            var item$ = $(selecteur);

            item$.mask('000000000RT0000', optionsMask);

         });
      }
   };

   // Applique le masque pour le format de code suivant : Ne doit contenir que des chiffres
   item.appliquerMasqueCodeNum = function (listeItems) {
      listeItems = listeItems === undefined ? '' : listeItems;

      if (listeItems.length === 0) {
         $('.shq-code-num').each(function (i, val) {
            var l_item = val.id;
            var item$ = $(diese.concat(l_item));
            var l_regexp = new RegExp('[0-9]*');
            var l_message = apex.lang.formatMessage("SHQ.ITEM.CODE_NUM_INVALID");
            item$.mask('0' + repeatStringNumTimes('0', item$[0].maxLength - 1));
            //item$.mask('0'.repeat(item$[0].maxLength - 1));

            if (item$.is('pattern') === false) {
               item$.attr('pattern', l_regexp.source);
               item$.attr('data-valid-message', l_message);
            }
         });
      }
      else {
         $.each(listeItems, function (i, val) {
            var selecteur = val.indexOf(diese, 0) === -1 ? diese.concat(val) : val;
            var item$ = $(selecteur);
            item$.mask('0' + repeatStringNumTimes('0', item$[0].maxLength - 1));
            // item$.mask('0'.repeat(item$[0].maxLength - 1));
         });
      }
   };

   // Applique le masque pour le format de code suivant : Ne doit contenir que des majuscules
   item.appliquerMasqueCodeAlpha = function (listeItems) {
      listeItems = listeItems === undefined ? '' : listeItems;

      var optionsMask = {
         onKeyPress: function (value, event) {
            event.currentTarget.value = value.toUpperCase();
         }
      };

      if (listeItems.length === 0) {
         $('.shq-code-alpha').each(function (i, val) {
            var l_item = val.id;
            var item$ = $(diese.concat(l_item));
            var l_regexp = new RegExp('[A-Z]*');
            var l_message = apex.lang.formatMessage("SHQ.ITEM.CODE_ALPHA_INVALID");
            item$.mask(repeatStringNumTimes('S', item$[0].maxLength), optionsMask);
            // item$.mask('S'.repeat(item$[0].maxLength - 1), optionsMask);

            if (item$.is('pattern') === false) {
               item$.attr('pattern', l_regexp.source);
               item$.attr('data-valid-message', l_message);
            }
         });
      }
      else {
         $.each(listeItems, function (i, val) {
            var selecteur = val.indexOf(diese, 0) === -1 ? diese.concat(val) : val;
            var item$ = $(selecteur);
            item$.mask(repeatStringNumTimes('S', item$[0].maxLength), optionsMask);
            // item$.mask('S'.repeat(item$[0].maxLength - 1), optionsMask);
         });
      }
   };

   // 
   // Permet de vérifier si le enter a été pressé
   // 
   item.enterPresse = function (event) {
      var keyEnter = "Enter";
      var key = event.key === undefined ? null : event.key;
      return key === keyEnter ? true : false;
   };
   item.controlerInputPassword = function (event) {
      var classIconMasque = "fa-eye-slash";
      var classIconView = "fa-eye";

      var $button = $(this);
      var $spanButtonIcon = $("span", $button);
      var idInputPassword = diese.concat($button.data("id-input"));
      //
      // Ajust le type de la balise input du password
      // 
      var typeInput = $(idInputPassword).attr('type') === "password" ? "text" : "password";
      $(idInputPassword).attr("type", typeInput);
      //
      // Ajust l'icon selon le type de la balise input
      // 
      if (typeInput === "text") {
         $spanButtonIcon.removeClass(classIconView)
            .addClass(classIconMasque);
      } else {
         $spanButtonIcon.removeClass(classIconMasque)
            .addClass(classIconView);
      }

   };
   item.visualiserInputPassword = function () {
      //
      // Applique la visualisation du mot de passe pour les éléments input de type password 
      // 
      $('.shq-visualiser-password').on("click", shq.item.controlerInputPassword);

   };

   //
   // Objet shq,apex,Jquery
   //
})(shq.item, shq, apex.theme42, apex.jQuery);