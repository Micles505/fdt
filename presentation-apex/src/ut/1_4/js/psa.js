/* global apex */


var shq = shq || {};
shq.psa  = {};

(function (psa, shq, ut, $) {
  
   //
   // Modifie la valeur du label sur les valeurs égale à 0 dans le graphique.
   // 
   psa.graph_subLabelValeurEgaleA0 = function (options,subString) 
   {
        options.dataFilter = function(data)
        {
            /*for (var serie of data.series) // NON SUPPORTER PAR Internet explorer
            {
                for (var item of serie.items)
                {
                    if(item.value == 0) 
                    {
                        item.label = subString;
                    }
                }
            }*/
            var serie;
            var item;
            for (serie in data.series)
            {
                for (item in data.series[serie].items)
                {
                    if(data.series[serie].items[item].value == 0)
                    {
                        data.series[serie].items[item].label = subString;
                    }
                }
            }
            return data;
        };
        return options;
   };
})(shq.psa, shq, apex.theme42, apex.jQuery);