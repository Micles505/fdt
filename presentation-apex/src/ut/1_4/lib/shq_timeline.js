/* eslint-disable no-unused-vars */
/* global apex */

var shq = shq || {};
shq.widget = {};

(function (apex, $, region, debug, util) {
	'use-strict';
	var C_LOG_DEBUG = debug.LOG_LEVEL.INFO;

	shq.widget.timeline = {
		init: function (idTimeLine, pOptions, ajaxIdentifier) {
			require(["ojs/ojcore", "jquery", "ojs/ojtimeline"], function (oj) {
				var lWidgetType = 'Timeline',
					lWidgetName = 'ojTimeline',
					lRegion$ = $("#" + util.escapeCSS(idTimeLine) + "_jet", apex.gPageContext$),
					lOptions = pOptions || {};

				lRegion$[lWidgetName](lOptions);

				// Register Chart with our region interface
				region.create(idTimeLine, {
					type: lWidgetType,
					widgetName: lWidgetName,
					refresh: function () {
						refresh();
					},
					focus: function () {
						lRegion$.focus();
					},
					widget: function () {
						return lRegion$;
					}
				});

				region(idTimeLine).refresh();

				// 
				function refresh() {
					var promise = apex.server.plugin(ajaxIdentifier, {
						pageItems: lOptions.pageItems
					}, {
						dataType: "json",
						refreshObject: lRegion$,
						loadingIndicator: lRegion$,
						loadingIndicatorPosition: "centered",
						success: afficherResultatTimeline
					});

					promise.done(function (data) {
						// à déterminer 
						debug.info('Promise done ');
					});
				} // Refresh

				function afficherResultatTimeline(pdata) {
					debug.info('afficherResultatTimeline ' || pdata ); 				

					lRegion$[lWidgetName](pdata);
				} // afficherResultatTimeline
			});
		}
	};

})(apex, apex.jQuery, apex.region, apex.debug, apex.util);
