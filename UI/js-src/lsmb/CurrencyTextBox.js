define([
    "dojo/currency", // currency._mixInDefaults currency.format currency.parse currency.regexp
    "dojo/_base/declare", // declare
    "dijit/form/CurrencyTextBox",
    "dojo/number"],

    function(currency, declare, CurrencyTextBox, dnumber){

        return declare("lsmb.CurrencyTextBox", CurrencyTextBox, {

            _mixInDefaults: function(options) {
                var _options = currency._mixInDefaults(options);
                _options.locale = this.locale;
                return _options;
            },

            // Override CurrencyTextBox._formatter to use user locale
            _formatter: function(/*Number*/ value, /*__FormatOptions?*/ options){
                var _options = currency._mixInDefaults(options);
                _options.locale = this.locale;
                return dnumber.format(value, _options);
            },

            _parser: function(/*String*/ expression, /*__ParseOptions?*/ options){
                var _options = currency._mixInDefaults(options);
                _options.locale = this.locale;
                return dnumber.parse(expression, _options);
            },

            _regExpGenerator: function(/*dnumber.__RegexpOptions?*/ options){
                var _options = currency._mixInDefaults(options);
                _options.locale = this.locale;
                return dnumber.regexp(currency._mixInDefaults(options)); // String
            }
        });
    });
