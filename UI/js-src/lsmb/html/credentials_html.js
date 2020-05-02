/** @format */
/* eslint no-unused-expressions:0 */

require([
   "dojo/dom",
   "dojo/dom-style",
   "dojo/ready",
   /* dojo-data-type references */
   "lsmb/SetupLoginButton",
   "dojo/dom",
   "dojo/dom-style",
   "dojo/ready"
], function (dom, domStyle, ready) {
   return {
      go: function () {
         ready(80, function () {
            domStyle.set(dom.byId("loading"), "display", "none");
         });
      }
   };
});
