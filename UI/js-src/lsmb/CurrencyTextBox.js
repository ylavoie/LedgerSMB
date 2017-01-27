define([
    "dojo/currency", // currency._mixInDefaults currency.format currency.parse currency.regexp
    "dojo/_base/declare", // declare
    "dijit/form/CurrencyTextBox",
    "dojo/number"],

    function(currency, declare, CurrencyTextBox, dnumber){

        return declare("lsmb.CurrencyTextBox", CurrencyTextBox, {

            // Why can't I override only that
            _mixInDefaults: function(options) {
                this.inherited(arguments);
                options.locale = this.locale;
                return options;
            },

            // Override CurrencyTextBox._formatter to use user locale
            _formatter: function(value, options){
                return dnumber.format(value, this._mixInDefaults(options));
            },

            _parser: function(expression, options){
                return dnumber.parse(expression, this._mixInDefaults(options));
            },

            _regExpGenerator: function(options){
                return dnumber.regexp(this._mixInDefaults(options)); // String
            },

            startup: function() {
               var self = this;
               this.inherited(arguments);
            }

       });
    });
