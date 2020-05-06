/** @format */
/* eslint no-unused-expressions:0 */

define([
   "dojo/dom",
   "dojo/dom-style",
   "dojo/ready",
   "lsmb/login",
   /* dojo-data-type references */
   "lsmb/Form",
   "lsmb/layout/TableContainer",
   "dijit/form/ValidationTextBox",
   "dijit/form/Button"
], function (dom, domStyle, ready) {
   return {
      go: function () {
         ready(80, function () {
            domStyle.set(dom.byId("loading"), "display", "none");
         });
      }
   };
});
