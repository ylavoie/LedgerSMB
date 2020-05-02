/** @format */
/* eslint no-unused-vars:0 */
/* global dojo, dijit */

require([
   "dojo/ready",
   /* dojo-data-type references */
   "dijit/form/Button"
], function (ready) {
   return {
      go: function () {
         ready(100, function () {
            dojo
               .query('input[name^="checkbox_"]', this.domNode)
               .forEach(function (node, index, arr) {
                  var n = dijit.getEnclosingWidget(node);
                  n.set("checked", !n.get("checked"));
               });
         });
      }
   };
});
