/** @format */
/* eslint no-unused-expressions:0 */

define([
   "dojo/dom",
   "dojo/dom-style",
   "dojo/ready",
   /* dojo-data-type references */
   "dijit/form/ComboBox",
   "lsmb/SetupLoginButton"
], function (dom, domStyle, ready) {
   return {
      go: function () {
         ready(80, function () {
            domStyle.set(dom.byId("loading"), "display", "none");
         });
      }
   };
});
