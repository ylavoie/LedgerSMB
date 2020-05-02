/** @format */
/* eslint no-unused-expressions:0 */

require([
   "dojo/dom",
   "dojo/dom-style",
   "dojo/ready",
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
