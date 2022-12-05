/* global apex */

var shq = shq || {};
shq.date = {};

(function (shqDate, shq, ut, $) {

    shqDate.UNITE = {
        JOUR: "JOUR",
        MINUTE: "MINUTE",
        HEURE: "HEURE",
        SECONDE: "SECONDE"
    };
    /* 
     * Fonction qui fait la diffrence entre deux objets dates selon l'unité passé
    */
    shqDate.differenceEntreDeuxDate = function (pDate1, pDate2, unite) {

        var utc1 = Date.UTC(pDate1.getFullYear(), pDate1.getMonth(), pDate1.getDate());
        var utc2 = Date.UTC(pDate2.getFullYear(), pDate2.getMonth(), pDate2.getDate());
        var diffMs = Math.abs(utc1  - utc2 );
        var differenceEntreDeuxDate;

        shqDate.UNITE_FORMULE = {
            JOUR: diffMs / (1000 * 60 * 60 * 24),
            HEURE: diffMs / (1000 * 60 * 60) / 24,
            MINUTE: diffMs / (1000 * 60) / 60,
            SECONDE: diffMs / (1000) / 60
        };

        switch (unite) {
            case shqDate.UNITE.JOUR:
                differenceEntreDeuxDate = Math.floor(shqDate.UNITE_FORMULE.JOUR);
                break;
            case shqDate.UNITE.MINUTE:
                differenceEntreDeuxDate = Math.floor(shqDate.UNITE_FORMULE.MINUTE);
                break;                
            case shqDate.UNITE.SECONDE:
                differenceEntreDeuxDate = Math.floor(shqDate.UNITE_FORMULE.SECONDE);
                break;
            default:
                differenceEntreDeuxDate = Math.floor(shqDate.UNITE_FORMULE.HEURE);
        }
        return differenceEntreDeuxDate;
    };

})(shq.date, shq, apex.theme42, apex.jQuery);