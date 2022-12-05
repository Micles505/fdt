/* 
   * plug pour ie 11. À retirer à partir de juin 2022
   */

//
// Polyfill pour la finction includes
// 
if (!String.prototype.includes) {
    String.prototype.includes = function(search, start) {
      'use strict';
   
      if (search instanceof RegExp) {
        throw TypeError('first argument must not be a RegExp');
      }
      if (start === undefined) { start = 0; }
      return this.indexOf(search, start) !== -1;
    };
   }
