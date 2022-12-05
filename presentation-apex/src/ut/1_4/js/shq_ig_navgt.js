/* eslint-disable no-unused-vars */
/* global apex */
/* 

-  Dans l'option de la page Execute when Page Loads 
   
   Exemple:
	   
*/
var shq = shq || {};
shq.ig = shq.ig || {};
shq.ig.navgt = {};

(function (igNavgt, apex, $) {
	"use strict";


	var C_LOG_DEBUG = apex.debug.LOG_LEVEL.INFO;
	var diese = '#';

	var ig = $('.shq-navgt-ig');
	var $id = $(diese.concat(ig.attr('id')));


	$id.on("gridpagechange", function (event, data) {
		apex.debug.info('__gridpagechange');
		shq.ig.navgt.enregistrerDataIg();

	});

	igNavgt.enregistrerDataIg = function () {

		var selRecords;
		var selRecordsJSON;
		var ig = $('.shq-navgt-ig');
		var PROCESS_NAME = 'APX - Enregistrer navigation';
		var gridView;
		var model;
		var seq;
		var current_seq;

		ig.each(function (index, element) {
			if (element.hasAttribute('data-nvgt-pkeys')) {

				selRecords = {
					"rows": []
				};
				var keys = {

				};
				var id = element.id;
				apex.debug.info('__id__'.concat(id));
				var $id = $(diese.concat(id));
				var igKeysArr = $id.attr('data-nvgt-pkeys').split(',');


				var igkeysValue = {};
				var igKeysTitle;
				var gridName = $id.attr('data-nvgt-gridkey');


				if (element.hasAttribute('data-nvgt-title')) {
					igKeysTitle = $id.attr('data-nvgt-title');
				}

				gridView = apex.region(id).widget().interactiveGrid("getViews").grid;


				model = gridView.model;
				seq = 0;

				model.forEach(function (element) {
					igkeysValue = {};
					for (var k = 0; k < igKeysArr.length; k++)
						igkeysValue[igKeysArr[k]] = model.getValue(element, igKeysArr[k]);

					var igTitle = igKeysTitle !== undefined ? model.getValue(element, igKeysTitle) : "";

					seq++;

					selRecords.rows.push({
						"seq": seq,
						'keys': igkeysValue,
						'title': igTitle
					});
				});

				selRecordsJSON = JSON.stringify(selRecords);

				var promise = apex.server.process(PROCESS_NAME, {
					x01: selRecordsJSON,
					x02: gridName,
					x03: igKeysArr.join(':')
				}, {
					success: function (pData) {
						apex.debug.info('__success__'.concat(PROCESS_NAME));						
					}
				});

			}

		});

	};



})(shq.ig.navgt, apex, apex.jQuery);