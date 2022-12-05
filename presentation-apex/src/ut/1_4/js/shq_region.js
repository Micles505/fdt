/* global apex */
/* global moment */
var shq = shq || {};
shq.region = {};

(function (region, shq, ut, $) {
    "use strict";
    //
    var C_LOG_DEBUG = apex.debug.LOG_LEVEL.INFO;
    var diese = '#';

    region.appliquerSpinnerIframe = function (regionId) {

        var region$ = $(diese.concat(regionId)),
            iframe$ = region$.find('iframe'),
            lSpinner$ = apex.util.showSpinner();

        iframe$.on('load', function () {
            lSpinner$.remove();

        });
    };
})(shq.region, shq, apex.theme42, apex.jQuery);